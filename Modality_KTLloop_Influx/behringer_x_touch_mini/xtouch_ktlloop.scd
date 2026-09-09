(
    ~xtouch_ktlloop_revision = "2026-08-31-auto-capture-r8";

    ~loop_count = ~xtouch_config[\loopCount].clip(1, 8).asInteger;
    ~loop_record_generation = 0;
    ~loop_route_encoders = IdentityDictionary.new;
    ~playing_encoders = IdentitySet.new;
    ~recording_encoders = IdentitySet.new;
    ~recording_loop_state = nil;
    ~next_record_loop_index = 0;
    ~loops_paused = false;
    ~loop_palindrome = ~xtouch_config[\palindrome];
    ~stop_button_held = false;
    ~clear_loop_task = nil;

    // A rota inclui o tipo de controle. Assim, parâmetro, wet e level podem
    // ser gravados e tomados separadamente.
    ~loop_route_key = {
        |control_kind, encoder_name, process_name, orbit_name|
        var route_key = "%|%|%|%".format(
            control_kind,
            encoder_name,
            process_name,
            orbit_name
        ).asSymbol;

        ~loop_route_encoders[route_key] = encoder_name;
        route_key;
    };

    // O usuário vê um looper com overdubs; as instâncias são apenas o pool
    // interno de takes.
    ~loops = Array.fill(~loop_count, { |i|
        var name = ("xtouch_r8_take" ++ (i + 1)).asSymbol;
        var loop = KtlLoop(name);

        loop.stopRec;
        loop.stop;
        loop.list_(EventList[]);
        loop.paramsToRecord_(~a_enc_names ++ ~b_enc_names);
        loop.looped_(~xtouch_config[\looped]);
        loop.verbosity_(0);
        loop;
    });

    // Compatibilidade com avaliações manuais já usadas.
    ~loop = ~loops[0];
    ~loop1 = ~loops.at(0);
    ~loop2 = ~loops.at(1);
    ~loop3 = ~loops.at(2);
    ~loop4 = ~loops.at(3);

    ~loop_states = ~loops.collect { |loop, i|
        (
            name: ("take" ++ (i + 1)).asSymbol,
            loop: loop,
            playing: IdentitySet.new,
            taken_over: IdentitySet.new,
            shadowed: IdentitySet.new,
            recorded_routes: IdentitySet.new,
            generation: 0,
            player: nil
        )
    };
    q.xtouch = q.xtouch ? ();
    q.xtouch.loops = ~loops;
    q.xtouch.loop_states = ~loop_states;

    ~refresh_loop_activity = {
        ~playing_encoders.clear;

        ~loop_states.do { |state|
            state[\playing].do { |route_key|
                var encoder_name = ~loop_route_encoders[route_key];
                if (encoder_name.notNil) {
                    ~playing_encoders.add(encoder_name);
                };
            };
        };

        if (~hud_refresh.notNil) { ~hud_refresh.value };
    };

    ~update_transport_leds = {
        var any_playing = ~loop_states.any { |state|
            state[\playing].isEmpty.not
        };
        var play_led = if (~loops_paused and: { any_playing }) {
            2
        } {
            any_playing.binaryValue
        };

        ~xtm.elAt(\bt_b7_led).value_(play_led);
        ~xtm.elAt(\bt_b8_led).value_(
            if (~recording_loop_state.notNil) { 2 } { 0 }
        );
        ~xtm.elAt(\bt_b5_led).value_(
            ~loops[0].looped.binaryValue
        );
        ~xtm.elAt(\bt_b2_led).value_(
            ~loop_palindrome.binaryValue
        );
        if (~hud_refresh.notNil) { ~hud_refresh.value };
    };

    ~make_loop_palindrome = { |loop|
        var source = loop.list;
        var control_events;
        var source_start;
        var source_dur;
        var palindrome;

        if (source.notNil and: { source.size > 2 }) {
            source_start = source.first[\absTime];
            source_dur = source.last[\absTime] - source_start;
            control_events = source.select { |event|
                [\start, \end].includes(event[\type]).not
            };

            palindrome = EventList[];
            palindrome.start(0);

            control_events.do { |event|
                var copy = event.copy;

                copy[\absTime] = event[\absTime] - source_start;
                copy.removeAt(\relDur);
                copy.removeAt(\playDur);
                copy.removeAt(\dur);
                palindrome.addEvent(copy);
            };

            control_events.reverse.do { |event, i|
                var copy;
                var relative_time;

                if (i > 0) {
                    relative_time = event[\absTime] - source_start;
                    copy = event.copy;
                    copy[\absTime] =
                    (source_dur * 2) - relative_time;
                    copy.removeAt(\relDur);
                    copy.removeAt(\playDur);
                    copy.removeAt(\dur);
                    palindrome.addEvent(copy);
                };
            };

            palindrome.finish(source_dur * 2);
            loop.list_(palindrome);
        };
    };

    ~collect_loop_routes = { |state|
        state[\recorded_routes].clear;

        if (state[\loop].list.notNil) {
            state[\loop].list.do { |event|
                var encoder_name = event[\encoder];
                var process_name = event[\process];
                var orbit_name = event[\orbit];
                var control_kind = event[\control] ? \parameter;

                if (
                    encoder_name.notNil
                    and: { process_name.notNil }
                    and: { orbit_name.notNil }
                    and: { event[\value].notNil }
                ) {
                    state[\recorded_routes].add(
                        ~loop_route_key.value(
                            control_kind,
                            encoder_name,
                            process_name,
                            orbit_name
                        )
                    );
                };
            };
        };
    };

    // A geração mais recente é dona de uma rota sobreposta. Takes antigos
    // continuam tocando suas demais rotas.
    ~resolve_loop_route_ownership = {
        var owners = IdentityDictionary.new;
        var active_states = ~loop_states.select { |state|
            state[\playing].isEmpty.not
        };

        ~loop_states.do { |state| state[\shadowed].clear };

        active_states.sort { |a, b|
            a[\generation] < b[\generation]
        }.do { |state|
            state[\recorded_routes].do { |route_key|
                owners[route_key] = state;
            };
        };

        active_states.do { |state|
            state[\recorded_routes].do { |route_key|
                if (owners[route_key] !== state) {
                    state[\shadowed].add(route_key);
                };
            };
        };
    };

    ~loop_has_active_routes = {
        ~loop_states.any { |state|
            state[\playing].any { |route_key|
                state[\taken_over].includes(route_key).not
                and: { state[\shadowed].includes(route_key).not }
            };
        };
    };

    ~choose_record_loop_state = {
        var chosen;

        ~loop_count.do { |offset|
            var index = (~next_record_loop_index + offset) % ~loop_count;
            var state = ~loop_states[index];

            if (
                chosen.isNil
                and: { state[\playing].isEmpty }
                and: { state !== ~recording_loop_state }
            ) {
                chosen = state;
            };
        };

        // Pool cheio: substitui o take mais antigo e mantém os outros.
        if (chosen.isNil) {
            chosen = ~loop_states.sort { |a, b|
                a[\generation] < b[\generation]
            }.first;
        };

        ~next_record_loop_index =
        (~loop_states.indexOf(chosen) + 1) % ~loop_count;
        chosen;
    };

    ~make_loop_stop_action = { |state|
        { |player, action|
            if ([\userStopped, \stopped].includes(action)) {
                // stop/pause comandados pelo patch atualizam o estado antes;
                // este dependant cobre término natural e GUI externa.
                if (~loops_paused.not) {
                    state[\playing].clear;
                    state[\taken_over].clear;
                    state[\shadowed].clear;
                    ~resolve_loop_route_ownership.value;
                    ~refresh_loop_activity.value;
                    ~update_transport_leds.value;
                };
            };
        };
    };

    ~make_loop_func = { |state|
        { |event|
            var loop = state[\loop];
            var process_name = event[\process];
            var orbit_name = event[\orbit];
            var encoder_name = event[\encoder];
            var value = event[\value];
            var control_kind = event[\control] ? \parameter;
            var route_key;
            var encoder_index;

            if (state[\player] !== loop.task.player) {
                state[\player] = loop.task.player;
                state[\player].addDependant(
                    ~make_loop_stop_action.value(state)
                );
            };

            if (
                event[\type] == \set
                and: { process_name.notNil }
                and: { orbit_name.notNil }
                and: { encoder_name.notNil }
                and: { value.notNil }
            ) {
                route_key = ~loop_route_key.value(
                    control_kind,
                    encoder_name,
                    process_name,
                    orbit_name
                );

                if (
                    state[\playing].includes(route_key)
                    and: { state[\taken_over].includes(route_key).not }
                    and: { state[\shadowed].includes(route_key).not }
                ) {
                    if (control_kind == \level) {
                        var proxy = Ndef(orbit_name);
                        var level_spec =
                        proxy.getSpec(\level) ? \ampx4.asSpec;

                        ~orbit_level_values[orbit_name] = value;
                        if (~orbit_is_audible.value(orbit_name)) {
                            proxy.set(\level, level_spec.map(value));
                        };
                    } {
                        if (control_kind == \wet) {
                            ~set_process_wet.value(
                                orbit_name,
                                process_name,
                                value
                            );
                        } {
                            if (~process_selector.at(process_name).notNil) {
                                ~process_selector.valueAt(
                                    [process_name],
                                    encoder_name,
                                    value,
                                    orbit_name
                                );
                            };
                        };
                    };

                    if (control_kind == \level) {
                        encoder_index =
                        ~b_enc_names.indexOf(encoder_name);

                        if (
                            encoder_index.notNil
                            and: { ~current_xtouch_layer == \B }
                        ) {
                            ~b_encoder_target_values[encoder_name] = value;
                            ~set_ring_state.value(
                                \B,
                                encoder_index,
                                value,
                                0,
                                false,
                                true
                            );
                        };
                    } {
                        if (
                            process_name == ~process_selector.mode
                            and: { orbit_name == ~selected_orbit_name }
                        ) {
                            encoder_index =
                            ~a_enc_names.indexOf(encoder_name);

                            if (encoder_index.notNil) {
                                ~set_ring_state.value(
                                    \A,
                                    encoder_index,
                                    value,
                                    0,
                                    false,
                                    true
                                );
                                ~encoder_target_values[encoder_name] = value;
                            };
                        };
                    };
                };
            };
        };
    };

    ~loop_states.do { |state|
        state[\loop].func_(~make_loop_func.value(state));
    };

    ~start_state_playback = { |state|
        if (state[\recorded_routes].isEmpty.not) {
            state[\playing].clear;
            state[\playing].addAll(state[\recorded_routes]);
            state[\taken_over].clear;
            state[\shadowed].clear;
            state[\loop].play;

            state[\recorded_routes].do { |route_key|
                var encoder_name = ~loop_route_encoders[route_key];
                var a_index = ~a_enc_names.indexOf(encoder_name);
                var b_index = ~b_enc_names.indexOf(encoder_name);

                if (a_index.notNil) {
                    ~set_ring_state.value(
                        \A,
                        a_index,
                        ~ring_states[\A][a_index][\value],
                        0,
                        true,
                        false
                    );
                };

                if (b_index.notNil) {
                    ~set_ring_state.value(
                        \B,
                        b_index,
                        ~ring_states[\B][b_index][\value],
                        0,
                        true,
                        false
                    );
                };
            };
        };
    };

    ~start_loop_recording = {
        var state;

        if (~recording_loop_state.notNil) {
            ~finish_loop_recording.value(true);
        } {
            if (~loops_paused) {
                ~loop_states.do { |loop_state|
                    if (loop_state[\playing].isEmpty.not) {
                        loop_state[\loop].resume;
                    };
                };
                ~loops_paused = false;
            };

            state = ~choose_record_loop_state.value;
            state[\loop].stop;
            state[\playing].clear;
            state[\taken_over].clear;
            state[\shadowed].clear;
            state[\recorded_routes].clear;
            state[\generation] = 0;
            ~recording_encoders.clear;
            ~recording_loop_state = state;
            ~resolve_loop_route_ownership.value;
            state[\loop].startRec;
            ~refresh_loop_activity.value;
            ~update_transport_leds.value;
            ~xtouch_log.value("[KTL] recording new take");
        };
    };

    ~finish_loop_recording = { |auto_play = true|
        var state = ~recording_loop_state;

        if (state.notNil) {
            state[\loop].stopRec;

            if (
                state[\loop].list.notNil
                and: { state[\loop].list.size > 2 }
            ) {
                if (~loop_palindrome) {
                    ~make_loop_palindrome.value(state[\loop]);
                };

                ~loop_record_generation = ~loop_record_generation + 1;
                state[\generation] = ~loop_record_generation;
                ~collect_loop_routes.value(state);
            } {
                state[\recorded_routes].clear;
                ~xtouch_log.value("[KTL] empty take discarded");
            };

            ~recording_loop_state = nil;
            ~recording_encoders.clear;

            if (auto_play and: { state[\recorded_routes].isEmpty.not }) {
                ~start_state_playback.value(state);
                ~xtouch_log.value(
                    "[KTL] % playing (% routes)".format(
                        state[\name],
                        state[\recorded_routes].size
                    )
                );
            };

            ~resolve_loop_route_ownership.value;
            ~refresh_loop_activity.value;
            ~update_transport_leds.value;
        };
    };

    ~toggle_loop_recording = {
        if (~recording_loop_state.notNil) {
            ~finish_loop_recording.value(true);
        } {
            ~start_loop_recording.value;
        };
    };

    ~toggle_loop_playback = {
        var states_with_recordings;
        var any_playing;

        if (~recording_loop_state.notNil) {
            ~finish_loop_recording.value(true);
        };

        states_with_recordings = ~loop_states.select { |state|
            state[\recorded_routes].isEmpty.not
        };
        any_playing = ~loop_states.any { |state|
            state[\loop].isPlaying
        };

        if (~loops_paused) {
            states_with_recordings.do { |state|
                if (state[\playing].isEmpty.not) {
                    state[\loop].resume;
                };
            };
            ~loops_paused = false;
            ~xtouch_log.value("[KTL] resumed");
        } {
            if (any_playing) {
                states_with_recordings.do { |state|
                    if (state[\loop].isPlaying) {
                        state[\loop].pause;
                    };
                };
                ~loops_paused = true;
                ~xtouch_log.value("[KTL] paused");
            } {
                if (states_with_recordings.isEmpty) {
                    ~xtouch_log.value("[KTL] no takes");
                } {
                    states_with_recordings.do { |state|
                        ~start_state_playback.value(state);
                    };
                    ~resolve_loop_route_ownership.value;
                    ~loops_paused = false;
                    ~xtouch_log.value("[KTL] playing all takes");
                };
            };
        };

        ~refresh_loop_activity.value;
        ~update_transport_leds.value;
    };

    ~stop_loop_playback = {
        ~loop_states.do { |state|
            state[\loop].stop;
            state[\playing].clear;
            state[\taken_over].clear;
            state[\shadowed].clear;
        };
        ~loops_paused = false;
        ~refresh_loop_activity.value;
        ~update_transport_leds.value;
        ~sync_current_encoders.value;
    };

    ~stop_all_looper_transport = {
        if (~recording_loop_state.notNil) {
            ~finish_loop_recording.value(false);
        };
        ~stop_loop_playback.value;
        ~xtouch_log.value("[KTL] stopped");
    };

    ~clear_all_loop_takes = {
        ~stop_all_looper_transport.value;
        ~loop_states.do { |state|
            state[\loop].list_(EventList[]);
            state[\recorded_routes].clear;
            state[\taken_over].clear;
            state[\shadowed].clear;
            state[\generation] = 0;
        };
        ~loop_record_generation = 0;
        ~xtouch_log.value("[KTL] all takes cleared");
        ~update_transport_leds.value;
    };

    // Qualquer encoder A movimentado durante Record é capturado como parâmetro
    // ou wet. Não há seleção prévia de encoders.
    ~a_enc_names.do { |encoder_name, i|
        ~xtm.elAt(encoder_name).action.add(\auto_record, {
            var state = ~recording_loop_state;
            var value = ~encoder_target_values[encoder_name];
            var control_kind = if (~a_wet_encoder == encoder_name) {
                \wet
            } {
                \parameter
            };

            if (state.notNil and: { value.notNil }) {
                state[\loop].recordEvent((
                    type: \set,
                    control: control_kind,
                    encoder: encoder_name,
                    process: ~process_selector.mode,
                    orbit: ~selected_orbit_name,
                    value: value.trunc(0.001)
                ));
                state[\recorded_routes].add(
                    ~loop_route_key.value(
                        control_kind,
                        encoder_name,
                        ~process_selector.mode,
                        ~selected_orbit_name
                    )
                );
                ~recording_encoders.add(encoder_name);
                ~update_transport_leds.value;
            };
        });

        // Executa antes da alteração manual. Takeover é específico à rota.
        ~xtm.elAt(encoder_name).action.addFirst(\takeover, {
            var control_kind = if (~a_wet_encoder == encoder_name) {
                \wet
            } {
                \parameter
            };
            var route_key = ~loop_route_key.value(
                control_kind,
                encoder_name,
                ~process_selector.mode,
                ~selected_orbit_name
            );
            var took_over = false;

            ~loop_states.do { |state|
                if (
                    state[\playing].includes(route_key)
                    and: { state[\shadowed].includes(route_key).not }
                ) {
                    state[\taken_over].add(route_key);
                    took_over = true;
                };
            };

            if (took_over) {
                if (~loop_has_active_routes.value.not) {
                    ~stop_loop_playback.value;
                    ~xtouch_log.value(
                        "[KTL] stopped by complete takeover"
                    );
                };

                ~set_ring_state.value(
                    \A,
                    i,
                    ~ring_states[\A][i][\value],
                    2,
                    true,
                    false
                );
            };
        });
    };

    // Os encoders B entram na mesma tomada, gravando level por orbit. A
    // identidade \mixer evita que o processo selecionado faça parte da rota.
    ~b_enc_names.do { |encoder_name, i|
        ~xtm.elAt(encoder_name).action.add(\auto_record, {
            var state = ~recording_loop_state;
            var orbit_name = ~orbit_names[i];
            var value = ~b_encoder_target_values[encoder_name];

            if (state.notNil and: { value.notNil }) {
                state[\loop].recordEvent((
                    type: \set,
                    control: \level,
                    encoder: encoder_name,
                    process: \mixer,
                    orbit: orbit_name,
                    value: value.trunc(0.001)
                ));
                state[\recorded_routes].add(
                    ~loop_route_key.value(
                        \level,
                        encoder_name,
                        \mixer,
                        orbit_name
                    )
                );
                ~recording_encoders.add(encoder_name);
                ~update_transport_leds.value;
            };
        });

        ~xtm.elAt(encoder_name).action.addFirst(\takeover, {
            var route_key = ~loop_route_key.value(
                \level,
                encoder_name,
                \mixer,
                ~orbit_names[i]
            );
            var took_over = false;

            ~loop_states.do { |state|
                if (
                    state[\playing].includes(route_key)
                    and: { state[\shadowed].includes(route_key).not }
                ) {
                    state[\taken_over].add(route_key);
                    took_over = true;
                };
            };

            if (took_over) {
                if (~loop_has_active_routes.value.not) {
                    ~stop_loop_playback.value;
                    ~xtouch_log.value(
                        "[KTL] stopped by complete takeover"
                    );
                };

                ~set_ring_state.value(
                    \B,
                    i,
                    ~ring_states[\B][i][\value],
                    2,
                    true,
                    false
                );
            };
        });
    };

    // B2/B5/B6/B7/B8 mantêm o mesmo significado em A e B.
    [\a_bt_b2_on, \b_bt_b2_on].do { |name|
        ~xtm.elAt(name).action.add(\toggle_palindrome, {
            ~loop_palindrome = ~loop_palindrome.not;
            ~xtouch_log.value(
                "palindrome: %".format(~loop_palindrome)
            );
            ~update_transport_leds.value;
        });
    };
    [\a_bt_b2_off, \b_bt_b2_off].do { |name|
        ~xtm.elAt(name).action.add(\restore_transport_led, {
            ~update_transport_leds.value;
        });
    };

    [\a_bt_b5_on, \b_bt_b5_on].do { |name|
        ~xtm.elAt(name).action.add(\toggle_looped, {
            var looped = ~loops[0].looped.not;

            ~loops.do { |loop| loop.looped_(looped) };
            ~xtouch_log.value("looped: %".format(looped));
            ~update_transport_leds.value;
        });
    };
    [\a_bt_b5_off, \b_bt_b5_off].do { |name|
        ~xtm.elAt(name).action.add(\restore_transport_led, {
            ~update_transport_leds.value;
        });
    };

    [\a_bt_b7_on, \b_bt_b7_on].do { |name|
        ~xtm.elAt(name).action.add(
            \play_pause,
            ~toggle_loop_playback
        );
    };
    [\a_bt_b7_off, \b_bt_b7_off].do { |name|
        ~xtm.elAt(name).action.add(\restore_transport_led, {
            ~update_transport_leds.value;
        });
    };

    [\a_bt_b8_on, \b_bt_b8_on].do { |name|
        ~xtm.elAt(name).action.add(
            \record_overdub,
            ~toggle_loop_recording
        );
    };
    [\a_bt_b8_off, \b_bt_b8_off].do { |name|
        ~xtm.elAt(name).action.add(\restore_transport_led, {
            ~update_transport_leds.value;
        });
    };

    [\a_bt_b6_on, \b_bt_b6_on].do { |name|
        ~xtm.elAt(name).action.add(\stop_or_clear, {
            ~stop_button_held = true;
            ~stop_all_looper_transport.value;

            if (~clear_loop_task.notNil) {
                ~clear_loop_task.stop;
            };
            ~clear_loop_task = Task({
                ~xtouch_config[\clearHoldSeconds].wait;
                if (~stop_button_held) {
                    ~clear_all_loop_takes.value;
                };
                ~clear_loop_task = nil;
            }).play(AppClock);
        });
    };

    [\a_bt_b6_off, \b_bt_b6_off].do { |name|
        ~xtm.elAt(name).action.add(\stop_or_clear, {
            ~stop_button_held = false;
            if (~clear_loop_task.notNil) {
                ~clear_loop_task.stop;
                ~clear_loop_task = nil;
            };
        });
    };

    if (~xtm_cmd_period_action.notNil) {
        CmdPeriod.remove(~xtm_cmd_period_action);
    };

    ~xtm_cmd_period_action = {
        ~recording_loop_state = nil;
        ~recording_encoders.clear;
        ~loop_states.do { |state|
            state[\playing].clear;
            state[\taken_over].clear;
            state[\shadowed].clear;
        };
        ~loops_paused = false;
        ~stop_button_held = false;
        if (~clear_loop_task.notNil) {
            ~clear_loop_task.stop;
            ~clear_loop_task = nil;
        };
        ~refresh_loop_activity.value;
        ~update_transport_leds.value;
        ~update_orbit_fx_leds.value;
        ~sync_current_encoders.value;
    };
    CmdPeriod.add(~xtm_cmd_period_action);

    ~refresh_loop_activity.value;
    ~update_transport_leds.value;
)
