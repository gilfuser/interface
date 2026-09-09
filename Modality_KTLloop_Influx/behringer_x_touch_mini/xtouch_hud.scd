~init_xtouch_hud = {
    ~xtouch_hud_revision = "2026-08-31-hud-r8";
    q.xtouch = q.xtouch ? ();
    q.xtouch.hud_revision = ~xtouch_hud_revision;
    ~xtouch_hud_views = ();

    ~hud_refresh = {
        {
            var process_name;
            var process_entry;
            var mode_text;
            var parameter_text;
            var routing_text;
            var looper_text;
            var help_text;
            var stored_takes = 0;
            var playing_takes = 0;

            if (
                ~xtouch_hud_window.notNil
                and: { ~xtouch_hud_window.isClosed.not }
            ) {
                process_name = ~process_selector.mode;
                process_entry = ~process_by_name[process_name];

                mode_text = if (~mc_mode == true) {
                    "MC / %".format(~mc_visual_mode.asString.toUpper)
                } {
                    "LAYER %".format(~current_xtouch_layer)
                };

                ~xtouch_hud_views[\header].string_(
                    "%  |  %  |  %".format(
                        mode_text,
                        ~selected_orbit_name.asString.toUpper,
                        process_entry[\label] ? process_name.asString
                    )
                );

                parameter_text = if (~mc_mode == true) {
                    ~orbit_names.collect { |orbit_name, i|
                        var active = ~active_orbit_processes
                        .value(orbit_name)
                        .includes(process_name);
                        var wet = ~get_process_wet.value(
                            orbit_name,
                            process_name
                        );

                        "%:%".format(
                            i + 1,
                            if (active) {
                                if (wet.notNil) {
                                    "wet %".format(wet.round(0.01))
                                } {
                                    "on"
                                }
                            } {
                                "off"
                            }
                        )
                    }.join("   ")
                } {
                    if (~current_xtouch_layer == \B) {
                        ~orbit_names.collect { |orbit_name, i|
                            "%:%".format(
                                i + 1,
                                (~orbit_level_values[orbit_name] ? 0)
                                .round(0.01)
                            )
                        }.join("   ")
                    } {
                        ~a_enc_names.collect { |encoder_name, i|
                            var label = process_entry[\controls]
                            [encoder_name];
                            var value = ~encoder_target_values
                            [encoder_name];

                            "%:% %".format(
                                i + 1,
                                label ? "—",
                                if (value.notNil) {
                                    value.round(0.01)
                                } {
                                    ""
                                }
                            )
                        }.join("   ")
                    }
                };
                ~xtouch_hud_views[\parameters].string_(parameter_text);

                routing_text = ~orbit_names.select { |orbit_name|
                    ~active_orbit_processes.value(orbit_name)
                    .includes(process_name)
                }.collect(_.asString).join("  ");
                if (routing_text.isEmpty) { routing_text = "none" };
                ~xtouch_hud_views[\routing].string_(
                    "ROUTING: %".format(routing_text)
                );

                if (~loop_states.notNil) {
                    stored_takes = ~loop_states.count { |state|
                        state[\recorded_routes].isEmpty.not
                    };
                    playing_takes = ~loop_states.count { |state|
                        state[\playing].isEmpty.not
                    };
                };

                looper_text = "LOOPER: % | takes %/% | playing % | palindrome % | looped %"
                .format(
                    if (~recording_loop_state.notNil) {
                        "RECORDING"
                    } {
                        if (~loops_paused == true) { "PAUSED" } { "READY" }
                    },
                    stored_takes,
                    ~loop_count ? 0,
                    playing_takes,
                    ~loop_palindrome ? false,
                    if (~loops.notNil and: { ~loops.notEmpty }) {
                        ~loops[0].looped
                    } {
                        false
                    }
                );
                ~xtouch_hud_views[\looper].string_(looper_text);

                help_text = if (~mc_mode == true) {
                    "BUTTON = process | PUSH = route orbit | TURN = wet | A+B = router/timeline | A or B = exit"
                } {
                    if (~current_xtouch_layer == \B) {
                        "TURN = level | TOP = mute | PUSH = solo | B3 = unmute all | B4 = unsolo all"
                    } {
                        "TOP = select orbit | TURN = parameter | PUSH+TURN selected orbit = wet | B3/B4 = process"
                    }
                };
                ~xtouch_hud_views[\help].string_(help_text);
            };
        }.defer;
    };

    ~show_xtouch_hud = {
        {
            if (
                ~xtouch_hud_window.isNil
                or: { ~xtouch_hud_window.isClosed }
            ) {
                ~xtouch_hud_window = Window(
                    "X-Touch Mini r8",
                    Rect(80, 80, 860, 250)
                );
                ~xtouch_hud_window.alwaysOnTop_(
                    ~xtouch_config[\hudAlwaysOnTop]
                );
                ~xtouch_hud_window.background_(Color.grey(0.12));

                ~xtouch_hud_views[\header] = StaticText(
                    ~xtouch_hud_window,
                    Rect(18, 12, 824, 28)
                )
                .font_(Font.default.boldVariant.size_(17))
                .stringColor_(Color.white);

                ~xtouch_hud_views[\parameters] = StaticText(
                    ~xtouch_hud_window,
                    Rect(18, 48, 824, 42)
                )
                .font_(Font.monospace(12))
                .stringColor_(Color.grey(0.9));

                ~xtouch_hud_views[\routing] = StaticText(
                    ~xtouch_hud_window,
                    Rect(18, 96, 824, 22)
                ).stringColor_(Color.cyan(0.8));

                ~xtouch_hud_views[\looper] = StaticText(
                    ~xtouch_hud_window,
                    Rect(18, 122, 824, 22)
                ).stringColor_(Color.yellow(0.8));

                ~xtouch_hud_views[\help] = StaticText(
                    ~xtouch_hud_window,
                    Rect(18, 150, 824, 36)
                )
                .font_(Font.default.size_(11))
                .stringColor_(Color.grey(0.75));

                Button(~xtouch_hud_window, Rect(18, 198, 150, 28))
                .states_([["Disable all FX"]])
                .action_({ ~disable_all_effects.value });

                Button(~xtouch_hud_window, Rect(178, 198, 150, 28))
                .states_([["Reset timeline"]])
                .action_({
                    ~mc_cycle_index = 0;
                    ~render_mc_buttons.value(true);
                });

                Button(~xtouch_hud_window, Rect(692, 198, 150, 28))
                .states_([["Close HUD"]])
                .action_({ ~xtouch_hud_window.close });

                ~xtouch_hud_window.onClose_({
                    ~xtouch_hud_window = nil;
                });
                ~xtouch_hud_window.front;
            };

            ~hud_refresh.value;
        }.defer;
    };

    q.xtouch.show_hud = ~show_xtouch_hud;
    q.xtouch.refresh_hud = ~hud_refresh;

    if (~xtouch_config[\showHud]) {
        ~show_xtouch_hud.value;
    };
};
