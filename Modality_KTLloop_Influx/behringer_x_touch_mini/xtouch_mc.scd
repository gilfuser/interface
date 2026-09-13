(
    var mc_process_by_element = IdentityDictionary.new;

    ~xtouch_mc_revision = "2026-09-10-orbit-process-leds-r8.4";
    q.xtouch = q.xtouch ? ();
    q.xtouch.mc_revision = ~xtouch_mc_revision;

    ~mc_mode = false;
    ~mc_visual_mode = \router;
    ~mc_cycle_index = ~mc_cycle_index ? 0;
    ~tidal_cycle_beats = ~xtouch_config[\timelineCycleBeats];
    ~mc_button_led_cache = IdentityDictionary.new;
    ~mc_ring_cache = IdentityDictionary.new;
    ~mc_layer_held = (A: false, B: false);
    ~mc_layer_pending = nil;
    ~mc_layer_chord_used = false;
    ~mc_layer_chord_task = nil;
    ~mc_selected_orbit_name = ~selected_orbit_name ? ~orbit_names.first;
    q.xtouch.mc_selected_orbit_name = ~mc_selected_orbit_name;

    ~mc_process_button_names =
    (1..8).collect { |n| "mc_bt_a%".format(n).asSymbol }
    ++
    (1..8).collect { |n| "mc_bt_b%".format(n).asSymbol };

    ~set_mc_button_led = { |button_name, value, force = false|
        var led_name = "%_led".format(button_name).asSymbol;

        if (force or: { ~mc_button_led_cache[led_name] != value }) {
            ~mc_button_led_cache[led_name] = value;
            ~xtm.elAt(led_name).value_(value);
        };
    };

    ~set_mc_ring = { |index, raw_value, force = false|
        var ring_name = "mc_enc%_ring".format(index + 1).asSymbol;

        raw_value = raw_value.clip(0, 127).round.asInteger;
        if (force or: { ~mc_ring_cache[ring_name] != raw_value }) {
            ~mc_ring_cache[ring_name] = raw_value;
            ~xtm.elAt(ring_name).value_(raw_value);
        };
    };

    ~render_mc_router_buttons = { |force = false|
        if (~mc_mode and: { ~mc_visual_mode == \router }) {
            var active_processes = ~active_orbit_processes.value(
                ~mc_selected_orbit_name
            );

            ~mc_process_button_names.do { |button_name|
                var process_name = ~mc_button_processes[button_name];
                var value = case
                // A seleção tem prioridade visual sobre o estado de routing.
                { process_name == ~process_selector.mode } { 1 }
                {
                    process_name.notNil
                    and: { active_processes.includes(process_name) }
                } { 127 }
                { true } { 0 };

                ~set_mc_button_led.value(button_name, value, force);
            };
        };
    };

    // O último encoder MC pressionado ou girado define a orbit cujos processos
    // são mostrados pelos 16 botões. A seleção não altera a orbit do Layer A.
    ~select_mc_orbit = { |orbit_name|
        if (
            ~orbit_names.includes(orbit_name)
            and: { ~mc_selected_orbit_name != orbit_name }
        ) {
            ~mc_selected_orbit_name = orbit_name;
            q.xtouch.mc_selected_orbit_name = orbit_name;
            ~render_mc_router_buttons.value;
            if (~hud_refresh.notNil) { ~hud_refresh.value };
        };
    };

    ~render_mc_timeline_buttons = { |force = false|
        if (~mc_mode and: { ~mc_visual_mode == \timeline }) {
            var cycle_led = ~mc_cycle_index % 8;
            var bar_led = (~mc_cycle_index / 4).floor.asInteger % 8;

            8.do { |i|
                ~set_mc_button_led.value(
                    "mc_bt_a%".format(i + 1).asSymbol,
                    if (i <= cycle_led) { 127 } { 0 },
                    force
                );
                ~set_mc_button_led.value(
                    "mc_bt_b%".format(i + 1).asSymbol,
                    if (i <= bar_led) { 127 } { 0 },
                    force
                );
            };
        };
    };

    ~render_mc_buttons = { |force = false|
        if (~mc_visual_mode == \timeline) {
            ~render_mc_timeline_buttons.value(force);
        } {
            ~render_mc_router_buttons.value(force);
        };
    };

    // Os rings são sempre feedback do router, inclusive no fake timeline.
    // Off = processo ausente; wrap cheio = ativo sem wet; wrap proporcional
    // = wet disponível. No protocolo MC, wrap ocupa a faixa raw 32..43.
    ~update_mc_router_feedback = { |force = false|
        if (~mc_mode) {
            var process_name = ~process_selector.mode;

            ~orbit_names.do { |orbit_name, i|
                var active = ~active_orbit_processes.value(orbit_name)
                .includes(process_name);
                var wet_value;
                var ring_value = 0;

                if (active) {
                    wet_value = ~get_process_wet.value(
                        orbit_name,
                        process_name
                    );
                    ring_value = if (wet_value.notNil) {
                        32 + (wet_value.clip(0, 1) * 11).round.asInteger
                    } {
                        32 + 11
                    };
                };

                ~set_mc_ring.value(i, ring_value, force);
            };

            ~render_mc_buttons.value(force);
        };

        if (~hud_refresh.notNil) { ~hud_refresh.value };
    };

    ~update_mc_tidal_leds = {
        ~render_mc_timeline_buttons.value;
    };

    Tdef(\xtouch_mc_timeline).stop;
    Tdef(\xtouch_mc_timeline).clear;
    Tdef(\xtouch_mc_timeline, {
        loop {
            ~render_mc_timeline_buttons.value;
            ~tidal_cycle_beats.wait;
            ~mc_cycle_index = (~mc_cycle_index + 1) % 32;
        };
    }).clock_(t).quant_(~tidal_cycle_beats).play;

    ~on_enter_mc = {
        ~mc_mode = true;
        ~mc_selected_orbit_name = ~selected_orbit_name ? ~orbit_names.first;
        q.xtouch.mc_selected_orbit_name = ~mc_selected_orbit_name;
        ~mc_layer_held[\A] = false;
        ~mc_layer_held[\B] = false;
        ~mc_layer_pending = nil;
        ~mc_layer_chord_used = false;
        ~mc_button_led_cache.clear;
        ~mc_ring_cache.clear;
        ~update_mc_router_feedback.value(true);
        ~xtm.elAt(\mc_layer_a_led).value_(127);
        ~xtm.elAt(\mc_layer_b_led).value_(127);
        ~xtouch_log.value(
            "MC: %".format(~mc_visual_mode)
        );
    };

    ~on_leave_mc = {
        ~mc_mode = false;
        ~mc_layer_held[\A] = false;
        ~mc_layer_held[\B] = false;
        ~mc_layer_pending = nil;
        ~mc_layer_chord_used = false;
        if (~hud_refresh.notNil) { ~hud_refresh.value };
    };

    ~leave_mc_to_layer = { |layer|
        ~mc_mode = false;
        ~mc_layer_held[\A] = false;
        ~mc_layer_held[\B] = false;
        ~mc_layer_pending = nil;
        ~mc_layer_chord_used = false;
        ~xtm.elAt(\mode).value_(0);
        ~xtm.elAt(\layer).value_(if (layer == \A) { 0 } { 1 });
        ~set_xtouch_layer.value(layer, true);
        ~xtouch_log.value("Layer %".format(layer));
    };

    ~toggle_mc_visual_mode = {
        ~mc_visual_mode = if (~mc_visual_mode == \router) {
            \timeline
        } {
            \router
        };
        ~mc_button_led_cache.clear;
        ~render_mc_buttons.value(true);
        ~xtouch_log.value("MC visual: %".format(~mc_visual_mode));
        if (~hud_refresh.notNil) { ~hud_refresh.value };
    };

    // Em modo normal os botões A/B não produzem input. Em MC eles produzem;
    // uma janela curta distingue A ou B isolado do acorde A+B.
    ~handle_mc_layer_on = { |layer|
        var other = if (layer == \A) { \B } { \A };

        ~mc_layer_held[layer] = true;

        if (~mc_layer_held[other]) {
            if (~mc_layer_chord_task.notNil) {
                ~mc_layer_chord_task.stop;
                ~mc_layer_chord_task = nil;
            };
            ~mc_layer_pending = nil;
            ~mc_layer_chord_used = true;
            ~toggle_mc_visual_mode.value;
        } {
            ~mc_layer_pending = layer;
            if (~mc_layer_chord_task.notNil) {
                ~mc_layer_chord_task.stop;
            };

            ~mc_layer_chord_task = Task({
                0.15.wait;
                if (
                    ~mc_layer_chord_used.not
                    and: { ~mc_layer_pending == layer }
                ) {
                    ~leave_mc_to_layer.value(layer);
                };
                ~mc_layer_pending = nil;
                ~mc_layer_chord_task = nil;
            }).play(AppClock);
        };
    };

    ~handle_mc_layer_off = { |layer|
        ~mc_layer_held[layer] = false;
        if (~mc_layer_held[\A].not and: { ~mc_layer_held[\B].not }) {
            ~mc_layer_chord_used = false;
        };
    };

    ~xtm.elAt(\mc_layer_a_on).action.add(\mc_layer_chord, {
        ~handle_mc_layer_on.value(\A);
    });
    ~xtm.elAt(\mc_layer_b_on).action.add(\mc_layer_chord, {
        ~handle_mc_layer_on.value(\B);
    });
    ~xtm.elAt(\mc_layer_a_off).action.add(\mc_layer_chord, {
        ~handle_mc_layer_off.value(\A);
    });
    ~xtm.elAt(\mc_layer_b_off).action.add(\mc_layer_chord, {
        ~handle_mc_layer_off.value(\B);
    });

    // Push: liga/desliga o processo selecionado naquela orbit.
    ~mc_enc_names.do { |encoder_name, i|
        var push_on_name = "%_on".format(encoder_name).asSymbol;

        ~xtm.elAt(push_on_name).action_(MFunc.new);
        ~xtm.elAt(push_on_name).action.add(\toggle_mc_process, {
            ~select_mc_orbit.value(~orbit_names[i]);
            ~toggle_orbit_process.value(
                ~orbit_names[i],
                ~process_selector.mode
            );
            ~update_mc_router_feedback.value;
        });

        // Giro relativo: wet da mesma orbit, se o processo oferecer wet e
        // estiver ativo. relEnc chega normalizado em torno de 0.5.
        ~xtm.elAt(encoder_name).action.add(\mc_wet, { |el|
            var orbit_name = ~orbit_names[i];
            var process_name = ~process_selector.mode;
            var wet_value = ~get_process_wet.value(
                orbit_name,
                process_name
            );
            var delta = (el.value - 0.5) *
            ~xtouch_config[\mcWetScale];

            ~select_mc_orbit.value(orbit_name);

            if (wet_value.notNil and: { delta.abs > 0 }) {
                ~set_process_wet.value(
                    orbit_name,
                    process_name,
                    (wet_value + delta).clip(0, 1)
                );
                ~update_mc_router_feedback.value;
            };
        });
    };

    ~mc_button_processes = ();
    ~mc_process_by_element = mc_process_by_element;
    topEnvironment[\mc_process_by_element] = mc_process_by_element;
    q.xtouch.mc_process_by_element = mc_process_by_element;

    ~select_mc_registered_process = { |el|
        var process_name = mc_process_by_element[el];

        if (process_name.notNil) {
            topEnvironment.use {
                ~select_process.value(process_name, false);
                ~xtouch_log.value(
                    "[MC] processo: %".format(process_name)
                );
                ~update_mc_router_feedback.value;
            };
        };
    };

    ~mc_process_button_names.do { |button_name, i|
        var process_name = ~process_names.at(i);
        var button_on = ~xtm.elAt(
            "%_on".format(button_name).asSymbol
        );
        var button_off = ~xtm.elAt(
            "%_off".format(button_name).asSymbol
        );

        button_on.action_(MFunc.new);
        button_off.action_(MFunc.new);

        if (process_name.notNil) {
            ~mc_button_processes[button_name] = process_name;
            mc_process_by_element[button_on] = process_name;
            button_on.action.add(
                \select_registered_process,
                ~select_mc_registered_process
            );
        };

        button_off.action.add(\restore_mc_visual, {
            ~mc_button_led_cache.removeAt(
                "%_led".format(button_name).asSymbol
            );
            ~render_mc_buttons.value;
        });
    };

    q.xtouch.mc_button_processes = ~mc_button_processes;
    ~xtouch_log.value(
        "processos MC: %".format(~mc_button_processes)
    );
)
