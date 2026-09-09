(
    var a_input_names = List.new;
    var b_input_names = List.new;

    ~xtouch_layer_b_revision = "2026-08-31-mixer-r8";

    // Layer B é deliberadamente um mixer puro:
    // giro = level, botão A = mute, push = solo.
    ~orbit_level_values = ~orbit_level_values ? ();
    ~muted_orbits = ~muted_orbits ? IdentitySet.new;
    ~soloed_orbits = ~soloed_orbits ? IdentitySet.new;
    ~b_encoder_hardware_values = ();
    ~b_encoder_target_values = ();
    ~ring_restore_task = nil;

    ~orbit_names.do { |orbit_name|
        var proxy = Ndef(orbit_name);
        var level_spec = proxy.getSpec(\level) ? \ampx4.asSpec;
        var current_level = proxy.get(\level);

        current_level = current_level ? level_spec.default;
        current_level = current_level ? level_spec.map(0.5);

        if (~orbit_level_values[orbit_name].isNil) {
            ~orbit_level_values[orbit_name] = level_spec
            .unmap(current_level)
            .clip(0, 1);
        };
    };

    ~b_enc_names.do { |element_name|
        ~b_encoder_hardware_values[element_name] = nil;
    };

    ~orbit_is_audible = { |orbit_name|
        ~muted_orbits.includes(orbit_name).not
        and: {
            ~soloed_orbits.isEmpty
            or: { ~soloed_orbits.includes(orbit_name) }
        };
    };

    // Off = inaudível, on = audível, blink = solo explícito.
    ~update_orbit_level_leds = {
        if (~current_xtouch_layer == \B and: { ~mc_mode != true }) {
            ~orbit_names.do { |orbit_name, i|
                var led_value;

                led_value = if (
                    ~soloed_orbits.includes(orbit_name)
                    and: { ~muted_orbits.includes(orbit_name).not }
                ) {
                    2
                } {
                    ~orbit_is_audible.value(orbit_name).binaryValue
                };

                ~xtm.elAt(
                    "bt_a%_led".format(i + 1).asSymbol
                ).value_(led_value);
            };
        };
    };

    ~apply_orbit_levels = {
        ~orbit_names.do { |orbit_name|
            var proxy = Ndef(orbit_name);
            var level_spec = proxy.getSpec(\level) ? \ampx4.asSpec;
            var level = if (~orbit_is_audible.value(orbit_name)) {
                level_spec.map(~orbit_level_values[orbit_name])
            } {
                0
            };

            proxy.set(\level, level);
        };

        ~update_orbit_level_leds.value;
        if (~hud_refresh.notNil) { ~hud_refresh.value };
    };

    ~sync_layer_b_encoders = {
        ~b_enc_names.do { |element_name, i|
            var target_value = ~orbit_level_values[~orbit_names[i]] ? 0;

            ~b_encoder_target_values[element_name] = target_value;
            ~reset_encoder_lag.value(element_name, target_value);
            ~set_ring_state.value(\B, i, target_value, 0);
        };
    };

    ~sync_current_encoders = {
        if (~current_xtouch_layer == \B) {
            ~sync_layer_b_encoders.value;
        } {
            ~sync_encoders.value;
        };
    };

    ~set_xtouch_layer = { |layer, force = false|
        if (~current_xtouch_layer != layer or: { force }) {
            ~a_wet_encoder = nil;
            ~current_xtouch_layer = layer;

            if (layer == \B) {
                ~update_orbit_level_leds.value;
            } {
                ~update_orbit_fx_leds.value;
            };

            ~sync_current_encoders.value;

            if (~ring_restore_task.notNil) {
                ~ring_restore_task.stop;
            };

            // A troca A/B não possui mensagem MIDI própria. O primeiro evento
            // da nova page seleciona a layer e esta confirmação restaura os
            // rings após o hardware terminar a troca interna.
            ~ring_restore_task = Task({
                0.08.wait;

                if (~current_xtouch_layer == layer) {
                    ~restore_ring_layer.value(layer);
                };

                ~ring_restore_task = nil;
            }).play(AppClock);

            if (~hud_refresh.notNil) { ~hud_refresh.value };
        };
    };

    (1..8).do { |n|
        a_input_names.add("a_enc%".format(n).asSymbol);
        a_input_names.add("a_enc%_on".format(n).asSymbol);
        a_input_names.add("a_enc%_off".format(n).asSymbol);
        b_input_names.add("b_enc%".format(n).asSymbol);
        b_input_names.add("b_enc%_on".format(n).asSymbol);
        b_input_names.add("b_enc%_off".format(n).asSymbol);

        [\a, \b].do { |row|
            [\on, \off].do { |state|
                a_input_names.add(
                    "a_bt_%%_%".format(row, n, state).asSymbol
                );
                b_input_names.add(
                    "b_bt_%%_%".format(row, n, state).asSymbol
                );
            };
        };
    };

    a_input_names.do { |element_name|
        ~xtm.elAt(element_name).action.addFirst(\layer_state, {
            ~set_xtouch_layer.value(\A);
        });
    };

    b_input_names.do { |element_name|
        ~xtm.elAt(element_name).action.addFirst(\layer_state, {
            ~set_xtouch_layer.value(\B);
        });
    };

    // Encoders: level das oito orbits.
    ~b_enc_names.do { |element_name, i|
        ~xtm.elAt(element_name).action.add(\layer_b_level, { |el|
            var orbit_name = ~orbit_names[i];
            var hardware_value = el.value;
            var previous_value = ~b_encoder_hardware_values[element_name];
            var target_value = ~b_encoder_target_values[element_name];
            var next_value;

            ~b_encoder_hardware_values[element_name] = hardware_value;

            if (previous_value.notNil and: { target_value.notNil }) {
                next_value = (
                    target_value + (hardware_value - previous_value)
                ).clip(0, 1);
                ~b_encoder_target_values[element_name] = next_value;
                ~orbit_level_values[orbit_name] = next_value;

                ~lag_encoder_value.value(
                    element_name,
                    next_value,
                    { |lagged_value|
                        var proxy = Ndef(orbit_name);
                        var level_spec =
                        proxy.getSpec(\level) ? \ampx4.asSpec;

                        ~orbit_level_values[orbit_name] = lagged_value;
                        if (~orbit_is_audible.value(orbit_name)) {
                            proxy.set(
                                \level,
                                level_spec.map(lagged_value)
                            );
                        };
                    }
                );

                ~set_ring_state.value(
                    \B, i, next_value, 2, true, false
                );
                if (~hud_refresh.notNil) { ~hud_refresh.value };
            };
        });
    };

    // Top buttons: mute individual.
    ~orbit_names.do { |orbit_name, i|
        var on_name = "b_bt_a%_on".format(i + 1).asSymbol;
        var off_name = "b_bt_a%_off".format(i + 1).asSymbol;

        ~xtm.elAt(on_name).action.add(\mute_orbit, {
            if (~muted_orbits.includes(orbit_name)) {
                ~muted_orbits.remove(orbit_name);
            } {
                ~muted_orbits.add(orbit_name);
            };
            ~apply_orbit_levels.value;
        });

        ~xtm.elAt(off_name).action.add(\refresh_mixer_led, {
            ~update_orbit_level_leds.value;
        });
    };

    // Encoder pushes: solo individual.
    ~b_enc_names.do { |element_name, i|
        var push_on_name = "%_on".format(element_name).asSymbol;
        var orbit_name = ~orbit_names[i];

        ~xtm.elAt(push_on_name).action.add(\solo_orbit, {
            if (~soloed_orbits.includes(orbit_name)) {
                ~soloed_orbits.remove(orbit_name);
            } {
                ~soloed_orbits.add(orbit_name);
            };
            ~apply_orbit_levels.value;
        });
    };

    // B3/B4 são ações de recuperação explícitas e imediatas.
    ~xtm.elAt(\b_bt_b3_on).action.add(\unmute_all, {
        ~muted_orbits.clear;
        ~apply_orbit_levels.value;
        ~xtouch_log.value("unmute all");
    });

    ~xtm.elAt(\b_bt_b4_on).action.add(\unsolo_all, {
        ~soloed_orbits.clear;
        ~apply_orbit_levels.value;
        ~xtouch_log.value("unsolo all");
    });

    ~apply_orbit_levels.value;
    ~sync_layer_b_encoders.value;
)
