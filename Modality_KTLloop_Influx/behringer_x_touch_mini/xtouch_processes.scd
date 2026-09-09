~init_xtouch_processes = {
    ~xtouch_processes_revision =
    "2026-08-31-process-registry-r8";

    // -----------------------------------------------------------------
    // Processos
    // -----------------------------------------------------------------

    // Registro declarativo único. Ordem, tipo, fonte, mapeamento, rótulo e
    // suporte a wet são derivados daqui pelos layers, MC e HUD.
    ~process_registry = [
        (
            name: \tidal, label: "Tidal OSC", kind: \osc,
            controls: (
            a_enc1: "1",
            a_enc2: "2",
            a_enc3: "3",
            a_enc4: "4",
            a_enc5: "5",
            a_enc6: "6",
            a_enc7: "7",
            a_enc8: "8"
            )
        ),
        (
            name: \pho, label: "Phoscyon", kind: \externalInstrument,
            source: \pho,
            loadPath: {
                Platform.userHomeDir +/+ "SuperCollider" +/+
                "instruments" +/+ "phoscyon_vst.scd"
            },
            controls: (
            a_enc1: \Cutoff,
            a_enc2: \Resonance,
            a_enc3: \Envmod,
            a_enc4: \Decay,
            a_enc5: 'Slide Time',
            a_enc6: 'Sweep Amount',
            a_enc7: 'Envmod Attack',
            a_enc8: 'Accent Decay'
            )
        ),
        (
            name: \spacemod, label: "SpaceMod", kind: \externalEffect,
            source: \spacemod, wetKind: \parameter,
            wetParameter: \wetDry,
            loadPath: {
                Platform.userHomeDir +/+ "SuperCollider" +/+
                "FX" +/+ "valhalla_space.scd"
            },
            controls: (
            a_enc1: \wetDry,
            a_enc2: \rate,
            a_enc3: \depth,
            a_enc4: \feedback,
            a_enc5: 'manual',
            a_enc6: 'Mode'
            )
        ),
        (
            name: \dru, label: "Drumazon", kind: \externalInstrument,
            source: \dru,
            loadPath: {
                Platform.userHomeDir +/+ "SuperCollider" +/+
                "instruments" +/+ "drumazon_vst.scd"
            },
            controls: (
            a_enc1: 'BD Pitch',
            a_enc2: 'BD Tune Depth',
            a_enc3: 'SD Tone',
            a_enc4: 'SD Snappy',
            a_enc5: 'RS Tune',
            a_enc6: 'MT Tune'
            )
        ),
        (
            name: \modelay, label: "Modelay", kind: \proxyFx,
            wetKind: \proxy,
            controls: (
            a_enc1: 'mdtime',
            a_enc2: 'mdtimel',
            a_enc3: 'mdtimer',
            a_enc4: 'mdfb',
            a_enc5: 'mdff',
            a_enc6: 'mdfq',
            a_enc7: 'mwide',
            a_enc8: 'mdamp'
            )
        ),
        (
            name: \pitch, label: "Pitch", kind: \proxyFx,
            wetKind: \proxy,
            controls: (
            a_enc1: \pdeg,
            a_enc2: \pdisp,
            a_enc3: \tdisp,
            a_enc4: \slide
            )
        ),
        (
            name: \lfo, label: "LFO", kind: \proxyFx,
            wetKind: \proxy,
            controls: (
            a_enc1: \lrate,
            a_enc2: \iphase,
            a_enc3: \lwidth,
            a_enc4: \sisap,
            a_enc5: \lmidfreq,
            a_enc6: \lhifreq
            )
        ),
        (
            name: \wah, label: "Wah", kind: \proxyFx,
            wetKind: \proxy,
            controls: (
            a_enc1: \wrate,
            a_enc2: \wdepth,
            a_enc3: \sinsaw,
            a_enc4: \jrate,
            a_enc5: \jdepth
            )
        ),
        (
            name: \strobe, label: "Strobe", kind: \proxyFx,
            wetKind: \proxy,
            controls: (
            a_enc1: \strob,
            a_enc2: \sphase,
            a_enc3: \ontime,
            a_enc4: \offtime,
            a_enc5: \scurve
            )
        ),
        (
            name: \tape, label: "Tape", kind: \proxyFx,
            wetKind: \proxy,
            controls: (
            a_enc1: \trate,
            a_enc2: \tphase,
            a_enc3: \tdepth,
            a_enc4: \toffset
            )
        ),
        (
            name: \hpf, label: "HPF", kind: \proxyFx,
            wetKind: \proxy,
            controls: (
            a_enc1: \hpffreq,
            a_enc2: \hrq
            )
        ),
        (
            name: \lpf, label: "LPF", kind: \proxyFx,
            wetKind: \proxy,
            controls: (
            a_enc1: \lpffreq,
            a_enc2: \lrq
            )
        ),
        (
            name: \endFilt, label: "End filter", kind: \proxyFx,
            wetKind: \proxy,
            controls: (
            a_enc1: \highPass,
            a_enc2: \lowPass
            )
        )
    ];

    ~process_by_name = IdentityDictionary.new;
    ~controls = ();
    ~process_registry.do { |entry|
        ~process_by_name[entry[\name]] = entry;
        ~controls[entry[\name]] = entry[\controls];
    };
    q.xtouch = q.xtouch ? ();
    q.xtouch.process_registry = ~process_registry;

    ~process_names = ~process_registry.collect { |entry| entry[\name] };
    ~orb_fx_names = ~process_registry.select { |entry|
        entry[\kind] == \proxyFx
    }.collect { |entry| entry[\name] };
    ~orbit_names = (0..7).collect { |i| ( "orb" ++ i.asString.padLeft(2, "0") ).asSymbol };

    // Processos de áudio externos. Os instrumentos usam os slots 0..9;
    // os slots 10, 20, 30... continuam reservados para a ProxyChain.
    ~external_instrument_names = ~process_registry.select { |entry|
        entry[\kind] == \externalInstrument
    }.collect { |entry| entry[\name] };
    ~external_effect_names = ~process_registry.select { |entry|
        entry[\kind] == \externalEffect
    }.collect { |entry| entry[\name] };
    ~external_instrument_sources = ();
    ~external_effect_sources = ();
    ~external_instrument_names.do { |name|
        ~external_instrument_sources[name] = ~process_by_name[name][\source];
    };
    ~external_effect_names.do { |name|
        ~external_effect_sources[name] = ~process_by_name[name][\source];
    };

    if (~external_instrument_names.size > 10) {
        Error("Há mais de dez instrumentos externos para os slots 0..9.").throw;
    };

    // Guarda a órbita à qual cada efeito externo está ligado.
    ~external_fx_orbits = ~external_fx_orbits ? ();

    // Valores normalizados (0..1), independentes de o efeito estar ativo.
    ~orb_fx_values = ~orb_fx_values ? ();
    ~process_values = ~process_values ? ();
    ~orbit_wet_values = ~orbit_wet_values ? ();

    // Fontes externas também são carregadas a partir do registro. O wait é
    // mantido porque os arquivos VST atuais inicializam controladores de forma
    // assíncrona.
    ~process_registry.do { |entry|
        if (
            entry[\loadPath].notNil
            and: { topEnvironment[entry[\source]].isNil }
        ) {
            entry[\loadPath].value.load;
            s.sync;
            2.wait;
        };
    };

    ~tidal_osc = NetAddr("127.0.0.1", 6010);


    // Procura a ProxyChain tanto no dicionário do projeto quanto no registro
    // mantido pela própria classe ProxyChain.
    ~chain_at = { |orbit_name|
        var chain;

        if ( q.fx.notNil ) {
            chain = q.fx[orbit_name];
        };

        if (chain.isNil) {
            chain = ProxyChain.all[orbit_name];
        };

        chain;
    };

    // Ndef(\allOrbs) continua sendo a única saída das oito órbitas. Quando
    // um efeito externo é ligado, sua saída substitui somente a órbita seca
    // correspondente. A instância do VST não precisa ser duplicada.
    ~rebuild_all_orbs = {
        var orbit_names = ~orbit_names.copy;
        var routed_sources = ();

        ~orbit_names.do { |orbit_name|
            var effect_name = ~external_effect_names.detect { |name|
                ~external_fx_orbits[name] == orbit_name
            };

            if (effect_name.notNil) {
                routed_sources[orbit_name] =
                ~external_effect_sources[effect_name];
            };
        };

        Ndef(\allOrbs, {
            var signal = Array.fill(orbit_names.size, { |i|
                var orbit_name = orbit_names[i];
                var source_name = routed_sources[orbit_name];
                var orbit_signal;

                orbit_signal = if (source_name.notNil) {
                    Ndef(source_name).ar
                } {
                    Ndef(orbit_name).ar
                };

                orbit_signal *
                ("amp" ++ i).asSymbol.kr(1, spec: \ampx4.asSpec);
            }).sum;

            Limiter.ar(signal);
        });
    };

    // A spec declarada por ProxyChain existe mesmo quando o efeito está desligado.
    ~get_orb_fx_spec = { |effect_name, parameter_name, proxy|
        var source_dict = ProxyChain.sourceDicts[effect_name];
        var specs;
        var spec;

        if (source_dict.notNil) {
            specs = source_dict[\specs];
        };

        if (specs.notNil) {
            spec = specs[parameter_name];
        };

        spec = spec ? proxy.getSpec(parameter_name);
        spec = spec ? parameter_name.asSpec;
        spec;
    };

    // ProxyChain.sourceDicts.keys.postln;
    // q.fx.keys.postln;

    // Cria as coleções de valores e instala todas as specs nas oito Ndefs.
    // Assim um parâmetro pode ser preparado antes de o efeito ser ligado.
    ~orbit_names.do { |orbit_name|
        var proxy = Ndef(orbit_name);

        ~orb_fx_values[orbit_name] = ~orb_fx_values[orbit_name] ? ();
        ~orbit_wet_values[orbit_name] =
        ~orbit_wet_values[orbit_name] ? ();

        ~orb_fx_names.do { |effect_name|
            var parameter_map = ~controls[effect_name];
            var value_map;

            ~orb_fx_values[orbit_name][effect_name] =
            ~orb_fx_values[orbit_name][effect_name] ? ();
            value_map = ~orb_fx_values[orbit_name][effect_name];

            parameter_map.keysValuesDo { |element_name, parameter_name|
                var spec = ~get_orb_fx_spec.value(
                    effect_name,
                    parameter_name,
                    proxy
                );
                var current_value;

                if (spec.notNil) {
                    proxy.addSpec(parameter_name, spec);

                    if (value_map[parameter_name].isNil) {
                        current_value = proxy.get(parameter_name);
                        current_value = current_value ? spec.default;
                        current_value = current_value ? spec.map(0);
                        value_map[parameter_name] =
                        spec.unmap(current_value).clip(0, 1);
                    };
                } {
                    ~xtouch_log.value(
                        "Sem spec: % em %".format(parameter_name, effect_name)
                    );
                };
            };
        };
    };

    (~process_names - ~orb_fx_names).do { |process_name|
        ~process_values[process_name] =
        ~process_values[process_name] ? ();

        ~controls[process_name].keysValuesDo {
            |element_name, parameter_name|

            if (~process_values[process_name][parameter_name].isNil) {
                ~process_values[process_name][parameter_name] = 0;
            };
        };
    };

    // Copia os valores atuais da Ndef para a coleção antes de retirar um efeito.
    ~store_orb_fx_values = { |orbit_name, effect_name|
        var proxy = Ndef(orbit_name);
        var parameter_map = ~controls[effect_name];
        var value_map = ~orb_fx_values[orbit_name][effect_name];

        parameter_map.keysValuesDo { |element_name, parameter_name|
            var spec = ~get_orb_fx_spec.value(
                effect_name,
                parameter_name,
                proxy
            );
            var current_value = proxy.get(parameter_name);

            if (spec.notNil and: { current_value.isNumber }) {
                value_map[parameter_name] =
                spec.unmap(current_value).clip(0, 1);
            };
        };
    };

    // Reaplica à Ndef os valores guardados quando o efeito volta à ProxyChain.
    ~restore_orb_fx_values = { |orbit_name, effect_name|
        var proxy = Ndef(orbit_name);
        var parameter_map = ~controls[effect_name];
        var value_map = ~orb_fx_values[orbit_name][effect_name];

        parameter_map.keysValuesDo { |element_name, parameter_name|
            var spec = ~get_orb_fx_spec.value(
                effect_name,
                parameter_name,
                proxy
            );
            var normalized_value = value_map[parameter_name];

            if (spec.notNil) {
                if (normalized_value.isNil) {
                    normalized_value = spec.unmap(
                        spec.default ? spec.map(0)
                    ).clip(0, 1);
                    value_map[parameter_name] = normalized_value;
                };

                proxy.addSpec(parameter_name, spec);
                proxy.set(parameter_name, spec.map(normalized_value));
            };
        };
    };

    // MFunc compartilhada pelos oito encoders. O registro decide como cada
    // processo aplica um valor, portanto um novo processo não requer outra
    // lista paralela de ações.
    ~process_selector = MFunc.new;

    ~process_registry.do { |entry|
        var process_name = entry[\name];
        var process_kind = entry[\kind];

        ~process_selector.add(
            process_name,
            { |element_name, value, orbit_name|
                var target_orbit = orbit_name ? ~selected_orbit_name;
                var parameter_name = entry[\controls][element_name];
                var proxy;
                var spec;
                var controller;

                if (parameter_name.notNil) {
                    case
                    { process_kind == \osc } {
                        ~tidal_osc.sendMsg(
                            "/ctrl",
                            parameter_name.asString,
                            value
                        );
                        ~process_values[process_name][parameter_name] = value;
                    }
                    { process_kind == \proxyFx } {
                        proxy = Ndef(target_orbit);
                        spec = ~get_orb_fx_spec.value(
                            process_name,
                            parameter_name,
                            proxy
                        );

                        if (spec.notNil) {
                            proxy.addSpec(parameter_name, spec);
                            proxy.set(parameter_name, spec.map(value));
                            ~orb_fx_values
                            [target_orbit]
                            [process_name]
                            [parameter_name] = value;
                        } {
                            ~xtouch_log.value(
                                "Sem spec: % em %".format(
                                    parameter_name,
                                    target_orbit
                                )
                            );
                        };
                    }
                    {
                        controller = topEnvironment[entry[\source]];

                        if (controller.notNil) {
                            controller.set(parameter_name, value);
                            ~process_values
                            [process_name]
                            [parameter_name] = value;
                        } {
                            ~xtouch_log.value(
                                "Controlador ausente: %".format(
                                    entry[\source]
                                )
                            );
                        };
                    };
                };
            },
            false
        );
    };

    // As funções passam a ser modos mutuamente exclusivos.
    ~process_selector.makeExclusiveModes( \processes, ~process_names );

    // Modo inicial.
    ~process_selector.mode_(\tidal);
    ~selected_orbit_name = \orb00;
    ~current_xtouch_layer = \A;

    // Os rings A e B são a mesma saída MIDI física. Guardar o estado de cada
    // layer separadamente impede que a restauração de uma page reutilize os
    // valores da outra. Toda escrita normal nos rings passa por estas funções.
    ~ring_states = (
        A: Array.fill(8, { (value: 0.0, mode: 0) }),
        B: Array.fill(8, { (value: 0.0, mode: 0) })
    );

    ~set_ring_state = {
        |layer, index, value, mode = 0, send_mode = true, send_value = true|
        var state = ~ring_states[layer][index];

        value = (value ? 0).clip(0, 1);
        state[\value] = value;
        state[\mode] = mode;

        if (
            ~mc_mode != true
            and: { ~current_xtouch_layer == layer }
        ) {
            if (send_mode) {
                ~xtm.elAt(\ring, \mode, index).value_(mode);
            };

            if (send_value) {
                ~xtm.elAt(\ring, \seg, index).value_(value * 13);
            };
        };
    };

    ~restore_ring_layer = { |layer|
        if (
            ~mc_mode != true
            and: { ~current_xtouch_layer == layer }
        ) {
            ~ring_states[layer].do { |state, index|
                ~xtm.elAt(\ring, \mode, index).value_(state[\mode]);
                ~xtm.elAt(\ring, \seg, index)
                .value_(state[\value] * 13);
            };
        };
    };

    // O layer A envia valores absolutos. Guardamos o último valor físico e
    // usamos somente a diferença entre duas mensagens consecutivas. O primeiro
    // CC recebido estabelece a referência e não altera o parâmetro; a partir
    // do seguinte, o encoder atua imediatamente sobre o valor mostrado no ring.
    ~encoder_hardware_values = ();
    ~encoder_target_values = ();

    // Lag2 no lado da linguagem: dois filtros de primeira ordem em cascata.
    // A Task só existe enquanto algum encoder está convergindo para um novo
    // valor; não há monitor permanente nem polling quando o controle está parado.
    ~encoder_lag_time = ~xtouch_config[\encoderLagTime];
    ~encoder_lag_dt = 0.02;
    ~encoder_lag_states = ();

    ~reset_encoder_lag = { |element_name, value|
        var state = ~encoder_lag_states[element_name];

        if (state.notNil and: { state[\task].notNil }) {
            state[\task].stop;
        };

        ~encoder_lag_states[element_name] = (
            first: value,
            second: value,
            target: value,
            action: nil,
            task: nil
        );
    };

    ~lag_encoder_value = { |element_name, value, action|
        var state = ~encoder_lag_states[element_name];

        if (state.isNil) {
            ~reset_encoder_lag.value(element_name, value);
            state = ~encoder_lag_states[element_name];
        };

        state[\target] = value;
        state[\action] = action;

        if (state[\task].isNil) {
            state[\task] = Task({
                var coefficient = 1 - (
                    0.001.pow(~encoder_lag_dt / ~encoder_lag_time)
                );
                var running = true;

                while { running } {
                    state[\first] = state[\first] + (
                        (state[\target] - state[\first]) * coefficient
                    );
                    state[\second] = state[\second] + (
                        (state[\first] - state[\second]) * coefficient
                    );

                    state[\action].value(state[\second]);

                    running = (
                        (state[\target] - state[\first]).abs > 0.0001
                    ) or: {
                        (state[\target] - state[\second]).abs > 0.0001
                    };

                    if (running) { ~encoder_lag_dt.wait };
                };

                state[\first] = state[\target];
                state[\second] = state[\target];
                state[\action].value(state[\target]);
                state[\task] = nil;
            }).play(SystemClock);
        };
    };

    ~a_enc_names.do { |element_name|
        ~encoder_hardware_values[element_name] = nil;
    };

    // Sincroniza rings e valores lógicos ao trocar processo ou orbit.
    ~sync_encoders = {
        var process_name = ~process_selector.mode;
        var parameter_map = ~controls[process_name];
        var proxy = Ndef(~selected_orbit_name);

        ~a_enc_names.do { |element_name, i|
            var parameter_name;
            var spec;
            var current_value;
            var normalized_value;

            if (parameter_map.notNil) {
                parameter_name = parameter_map[element_name];
            };

            if (parameter_name.notNil) {
                if (~orb_fx_names.includes(process_name)) {
                    spec = ~get_orb_fx_spec.value(
                        process_name,
                        parameter_name,
                        proxy
                    );

                    if (spec.notNil) {
                        current_value = proxy.get(parameter_name);

                        if (current_value.isNumber) {
                            normalized_value =
                            spec.unmap(current_value).clip(0, 1);
                            ~orb_fx_values
                            [~selected_orbit_name]
                            [process_name]
                            [parameter_name] = normalized_value;
                        } {
                            normalized_value = ~orb_fx_values
                            [~selected_orbit_name]
                            [process_name]
                            [parameter_name];
                        };
                    };
                } {
                    normalized_value =
                    ~process_values[process_name][parameter_name];
                };

                normalized_value = normalized_value ? 0;
                normalized_value = normalized_value.clip(0, 1);
                ~encoder_target_values[element_name] = normalized_value;

                ~reset_encoder_lag.value(element_name, normalized_value);

                // O segmento é enviado em single para representar exatamente
                // o parâmetro guardado. O fan volta somente durante movimento.
                ~set_ring_state.value(\A, i, normalized_value, 0);
            } {
                // Encoder sem parâmetro no processo atual.
                ~encoder_target_values[element_name] = nil;
                ~reset_encoder_lag.value(element_name, 0);
                ~set_ring_state.value(\A, i, 0, 0);
            };
        };
    };

    // Retorna os efeitos e instrumentos presentes em uma órbita.
    ~active_orbit_processes = { |orbit_name|
        var active = List.new;
        var chain = ~chain_at.value(orbit_name);
        var proxy = Ndef(orbit_name);

        if (chain.notNil) {
            (chain.activeSlotNames ? []).do { |process_name|
                if (~orb_fx_names.includes(process_name)) {
                    active.add(process_name);
                };
            };
        };

        ~external_instrument_names.do { |process_name, slot_index|
            if (proxy.objects[slot_index].notNil) {
                active.add(process_name);
            };
        };

        ~external_effect_names.do { |process_name|
            if (~external_fx_orbits[process_name] == orbit_name) {
                active.add(process_name);
            };
        };

        active.asArray;
    };

    ~process_supports_wet = { |process_name|
        var entry = ~process_by_name[process_name];

        entry.notNil and: { entry[\wetKind].notNil };
    };

    ~wet_key_for = { |orbit_name, process_name|
        var chain = ~chain_at.value(orbit_name);
        var slot_index;

        if (
            chain.notNil
            and: { chain.activeSlotNames.includes(process_name) }
        ) {
            slot_index = chain.slotNames.indexOf(process_name);
        };

        if (slot_index.notNil) {
            ("wet" ++ slot_index).asSymbol
        } {
            nil
        };
    };

    ~get_process_wet = { |orbit_name, process_name|
        var entry = ~process_by_name[process_name];
        var wet_kind;
        var wet_value;
        var wet_key;

        if (entry.notNil) { wet_kind = entry[\wetKind] };

        case
        { wet_kind == \proxy } {
            wet_key = ~wet_key_for.value(orbit_name, process_name);

            if (wet_key.notNil) {
                wet_value = ~chain_at.value(orbit_name).proxy.get(wet_key);
                wet_value = wet_value ?
                ~orbit_wet_values[orbit_name][process_name];
                wet_value = wet_value ? 1.0;
            };
        }
        { wet_kind == \parameter } {
            if (~active_orbit_processes.value(orbit_name).includes(process_name)) {
                wet_value = ~process_values
                [process_name]
                [entry[\wetParameter]];
                wet_value = wet_value ? 0.0;
            };
        };

        wet_value;
    };

    ~set_process_wet = { |orbit_name, process_name, value|
        var entry = ~process_by_name[process_name];
        var wet_kind;
        var wet_key;
        var element_name;

        value = value.clip(0, 1);
        if (entry.notNil) { wet_kind = entry[\wetKind] };

        case
        { wet_kind == \proxy } {
            wet_key = ~wet_key_for.value(orbit_name, process_name);

            if (wet_key.notNil) {
                ~chain_at.value(orbit_name).proxy.set(wet_key, value);
                ~orbit_wet_values[orbit_name][process_name] = value;
            };
        }
        { wet_kind == \parameter } {
            element_name = entry[\controls].keys.detect { |key|
                entry[\controls][key] == entry[\wetParameter]
            };

            if (
                element_name.notNil
                and: {
                    ~active_orbit_processes.value(orbit_name)
                    .includes(process_name)
                }
            ) {
                ~process_selector.valueAt(
                    [process_name],
                    element_name,
                    value,
                    orbit_name
                );
            };
        };

        value;
    };

    // LEDs A: a órbita selecionada pisca; as demais ficam acesas somente
    // quando contêm o processo atualmente selecionado.
    ~update_orbit_fx_leds = {
        if (~current_xtouch_layer == \A and: { ~mc_mode != true }) {
            ~orbit_names.do { |orbit_name, i|
                var led_name = "bt_a%_led".format(i + 1).asSymbol;
                var has_selected_process =
                ~active_orbit_processes.value(orbit_name)
                .includes(~process_selector.mode);

                ~xtm.elAt(led_name).value_(
                    if (orbit_name == ~selected_orbit_name) {
                        2
                    } {
                        has_selected_process.binaryValue
                    }
                );
            };
        };
    };

    // Linha A: escolhe a órbita cujos parâmetros os encoders controlam.
    ~select_orbit = { |orbit_name|
        var active_processes;

        ~a_wet_encoder = nil;
        ~selected_orbit_name = orbit_name;
        ~sync_encoders.value;
        ~update_orbit_fx_leds.value;
        if (~update_mc_router_feedback.notNil) {
            ~update_mc_router_feedback.value;
        };
        if (~hud_refresh.notNil) { ~hud_refresh.value };
        active_processes = ~active_orbit_processes.value(orbit_name);

        ~xtouch_log.value(
            "orbit selecionada: % | ativos: %".format(
                ~selected_orbit_name,
                if (active_processes.isEmpty) {
                    \nenhum
                } {
                    active_processes
                }
            )
        );

        nil;
    };

    ~orbit_names.do { |orbit_name, i|
        var button_on_name = "a_bt_a%_on".format(i + 1).asSymbol;
        var button_off_name = "a_bt_a%_off".format(i + 1).asSymbol;

        ~xtm.elAt(button_on_name).action.add(\select_orbit, {
            ~select_orbit.value(orbit_name);
        });

        // O noteOff físico apaga momentaneamente o LED. Reaplicamos o estado
        // real da órbita logo depois de soltar o botão.
        ~xtm.elAt(button_off_name).action.add(\refresh_orbit_led, {
            ~update_orbit_fx_leds.value;
        });
    };

    ~a_wet_encoder = nil;

    // Controle manual: normalmente edita o parâmetro do encoder. Enquanto o
    // push da coluna da orbit selecionada estiver pressionado, o mesmo giro
    // edita o wet do processo, quando esse processo oferece wet.
    ~a_enc_names.do { |element_name, i|
        ~xtm.elAt(element_name).action.add(\process_selector, { |el|
            var hardware_value = el.value;
            var previous_value = ~encoder_hardware_values[element_name];
            var target_value = ~encoder_target_values[element_name];
            var process_name = ~process_selector.mode;
            var orbit_name = ~selected_orbit_name;
            var delta;
            var next_value;

            ~encoder_hardware_values[element_name] = hardware_value;

            if (previous_value.notNil and: { target_value.notNil }) {
                delta = hardware_value - previous_value;
                next_value = (target_value + delta).clip(0, 1);
                ~encoder_target_values[element_name] = next_value;

                if (~a_wet_encoder == element_name) {
                    ~lag_encoder_value.value(
                        element_name,
                        next_value,
                        { |lagged_value|
                            ~set_process_wet.value(
                                orbit_name,
                                process_name,
                                lagged_value
                            );
                        }
                    );
                } {
                    ~lag_encoder_value.value(
                        element_name,
                        next_value,
                        { |lagged_value|
                            ~process_selector.valueAt(
                                [process_name],
                                element_name,
                                lagged_value,
                                orbit_name
                            );
                        }
                    );
                };

                // O hardware já move os segmentos durante o giro. Atualizamos
                // o cache e enviamos somente o modo fan; reenviar \seg aqui
                // faria o ring alternar entre duas fontes.
                ~set_ring_state.value(\A, i, next_value, 2, true, false);
                if (~hud_refresh.notNil) { ~hud_refresh.value };
            };
        });
    };

    // ~process_selector.activeNames;

    // O layer B substitui esta função para sincronizar seus próprios rings.
    ~sync_current_encoders = { ~sync_encoders.value };

    ~select_process = { |process_name, post = true|
        if (~process_names.includes(process_name)) {
            ~process_selector.mode_(process_name);
            ~sync_current_encoders.value;
            ~update_orbit_fx_leds.value;
            if (~update_mc_router_feedback.notNil) {
                ~update_mc_router_feedback.value;
            };
            if (~hud_refresh.notNil) { ~hud_refresh.value };

            if (post) {
                ~xtouch_log.value(process_name.asString.toUpper);
            };
        } {
            ~xtouch_log.value("Processo desconhecido: %".format(process_name));
        };
    };

    ~select_previous_process = {
        var process_names = ~process_selector.modeLists[\processes];
        var current_index = process_names.indexOf( ~process_selector.mode );
        var previous_process = process_names.wrapAt( current_index - 1 );

        ~select_process.value(previous_process);
    };

    ~select_next_process = {
        var process_names = ~process_selector.modeLists[\processes];
        var current_index = process_names.indexOf(~process_selector.mode);
        var next_process = process_names.wrapAt(current_index + 1);

        ~select_process.value(next_process);
    };

    // B3/B4: processo anterior/próximo.
    ~xtm.elAt(\a_bt_b3_on).action.add(
        \previous_process,
        ~select_previous_process
    );
    ~xtm.elAt(\a_bt_b4_on).action.add(
        \next_process,
        ~select_next_process
    );

    // Push do encoder N: liga/desliga o processo atual na órbita N.
    // Não muda ~selected_orbit_name; essa escolha continua sendo dos botões A.
    ~toggle_orbit_process = { |orbit_name, process_name|
        var chain;
        var proxy;
        var slot_index;
        var source_name;

        // Não usamos ~process_selector.mode como fallback: cada interface deve
        // informar explicitamente qual processo pretende ligar ou desligar.
        if (process_name.isNil) {
            Error(
                "toggle_orbit_process requer orbit_name e process_name."
            ).throw;
        };

        case
        { ~orb_fx_names.includes(process_name) } {
            chain = ~chain_at.value(orbit_name);

            if (chain.isNil) {
                ~xtouch_log.value(
                    "Sem ProxyChain para %".format(orbit_name)
                );
            } {
                if (chain.activeSlotNames.includes(process_name)) {
                    ~store_orb_fx_values.value(orbit_name, process_name);
                    chain.remove(process_name);
                    ~xtouch_log.value(
                        "efeito % desligado em %".format(
                            process_name,
                            orbit_name
                        )
                    );
                } {
                    chain.add(process_name, 1);
                    ~restore_orb_fx_values.value(orbit_name, process_name);
                    ~xtouch_log.value(
                        "efeito % ligado em %".format(
                            process_name,
                            orbit_name
                        )
                    );
                };
            };
        }
        { ~external_instrument_names.includes(process_name) } {
            proxy = Ndef(orbit_name);
            slot_index = ~external_instrument_names.indexOf(process_name);
            source_name = ~external_instrument_sources[process_name];

            if (proxy.objects[slot_index].notNil) {
                proxy[slot_index] = nil;
                ~xtouch_log.value(
                    "instrumento % retirado de %[%]".format(
                        process_name,
                        orbit_name,
                        slot_index
                    )
                );
            } {
                proxy[slot_index] = \mix -> { Ndef(source_name).ar };
                ~xtouch_log.value(
                    "instrumento % inserido em %[%]".format(
                        process_name,
                        orbit_name,
                        slot_index
                    )
                );
            };
        }
        { ~external_effect_names.includes(process_name) } {
            source_name = ~external_effect_sources[process_name];

            if (~external_fx_orbits[process_name] == orbit_name) {
                Ndef(source_name).set(\in, nil);
                ~external_fx_orbits[process_name] = nil;
                ~rebuild_all_orbs.value;
                ~xtouch_log.value(
                    "efeito externo % desligado de %".format(
                        process_name,
                        orbit_name
                    )
                );
            } {
                Ndef(source_name).set(\in, Ndef(orbit_name));
                ~external_fx_orbits[process_name] = orbit_name;
                ~rebuild_all_orbs.value;
                ~xtouch_log.value(
                    "efeito externo % ligado a %".format(
                        process_name,
                        orbit_name
                    )
                );
            };
        }
        {
            ~xtouch_log.value(
                "% não possui roteamento de áudio por push".format(
                    process_name
                )
            );
        };

        ~update_orbit_fx_leds.value;
        if (~update_mc_router_feedback.notNil) {
            ~update_mc_router_feedback.value;
        };
        if (~hud_refresh.notNil) { ~hud_refresh.value };

        if (
            ~current_xtouch_layer == \A
            and: { ~selected_orbit_name == orbit_name }
        ) {
            ~sync_current_encoders.value;
        };
    };

    // Usado pelo botão correspondente no HUD. Preserva os instrumentos nos
    // slots 0..9 e desliga somente efeitos internos e externos.
    ~disable_all_effects = {
        ~orbit_names.do { |orbit_name|
            var chain = ~chain_at.value(orbit_name);

            if (chain.notNil) {
                (chain.activeSlotNames ? []).copy.do { |effect_name|
                    if (~orb_fx_names.includes(effect_name)) {
                        ~store_orb_fx_values.value(orbit_name, effect_name);
                        chain.remove(effect_name);
                    };
                };
            };
        };

        ~external_effect_names.do { |process_name|
            var source_name = ~external_effect_sources[process_name];

            Ndef(source_name).set(\in, nil);
            ~external_fx_orbits[process_name] = nil;
        };

        ~rebuild_all_orbs.value;
        ~update_orbit_fx_leds.value;
        ~sync_current_encoders.value;
        if (~update_mc_router_feedback.notNil) {
            ~update_mc_router_feedback.value;
        };
        if (~hud_refresh.notNil) { ~hud_refresh.value };
        ~xtouch_log.value("todos os efeitos foram desligados");
    };

    ~a_enc_names.do { |element_name, i|
        var push_on_name = "%_on".format(element_name).asSymbol;
        var push_off_name = "%_off".format(element_name).asSymbol;

        ~xtm.elAt(push_on_name).action.add(\wet_modifier, {
            var selected_index = ~orbit_names.indexOf(~selected_orbit_name);
            var wet_value;

            if (i == selected_index) {
                wet_value = ~get_process_wet.value(
                    ~selected_orbit_name,
                    ~process_selector.mode
                );

                if (wet_value.notNil) {
                    ~a_wet_encoder = element_name;
                    ~encoder_target_values[element_name] = wet_value;
                    ~reset_encoder_lag.value(element_name, wet_value);
                    ~set_ring_state.value(\A, i, wet_value, 2);
                    ~xtouch_log.value(
                        "wet: % em %".format(
                            ~process_selector.mode,
                            ~selected_orbit_name
                        )
                    );
                } {
                    ~xtouch_log.value(
                        "wet indisponível: % em %".format(
                            ~process_selector.mode,
                            ~selected_orbit_name
                        )
                    );
                };
            };
        });

        ~xtm.elAt(push_off_name).action.add(\wet_modifier, {
            if (~a_wet_encoder == element_name) {
                ~a_wet_encoder = nil;
                ~sync_encoders.value;
                if (~hud_refresh.notNil) { ~hud_refresh.value };
            };
        });
    };

    // Restaura o roteamento visual e de áudio se o bloco for reavaliado com
    // algum efeito externo já associado a uma órbita.
    ~external_effect_names.do { |process_name|
        var orbit_name = ~external_fx_orbits[process_name];
        var source_name = ~external_effect_sources[process_name];

        if (orbit_name.notNil) {
            Ndef(source_name).set(\in, Ndef(orbit_name));
        };
    };
    ~rebuild_all_orbs.value;

    ~select_orbit.value(~selected_orbit_name);
};
