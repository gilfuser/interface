(

fork {
    MKtl.find;
    if (currentEnvironment.class == ProxySpace) { topEnvironment.push };
    1.wait;

    ~xtm = MKtl(\xtm, "behringer-x-touch-mini");
    // ~xtm.gui;
    // ~xtm.desc.openFile;
    ~xtm.trace(false);
    // ~xtm.elAt(\ring, \mode).value_(2); // fan mode

    // -----------------------------------------------------------------
    // Nomes curtos dos elementos
    // -----------------------------------------------------------------

    ~a_enc_names = (1..8).collect { |n| "a_enc%".format(n).asSymbol };
    ~b_enc_names = (1..8).collect { |n| "b_enc%".format(n).asSymbol };
    ~mc_enc_names = (1..8).collect { |n| "mc_enc%".format(n).asSymbol };

    [\A, \B, \MC].do { |layer, i|
        var layer_name = layer.asString.toLower;
        var enc_names = [~a_enc_names, ~b_enc_names, ~mc_enc_names][i];

        enc_names.do { |name, j|
            var enc_push_on = "%_on".format(name).asSymbol;
            var enc_push_off = "%_off".format(name).asSymbol;
            var enc_ring = "%_ring".format(name).asSymbol;

            ~xtm.addNamed( name, ~xtm.elAt(layer, \chan, (j + 1).asSymbol, \enc, \turn));
            ~xtm.elAt(name).action_(MFunc.new);

            ~xtm.addNamed(enc_push_on, ~xtm.elAt(layer, \chan, (j + 1).asSymbol, \enc, \push, \on));
            ~xtm.elAt(enc_push_on).action_(MFunc.new);

            ~xtm.addNamed(enc_push_off, ~xtm.elAt(layer, \chan, (j + 1).asSymbol, \enc, \push, \off));
            ~xtm.elAt(enc_push_off).action_(MFunc.new);

            if (layer == \MC) {
                ~xtm.addNamed(enc_ring, ~xtm.elAt(\mc_ring, (j + 1).asSymbol));
            } {
                ~xtm.addNamed(enc_ring, ~xtm.elAt(\ring, \seg, (j + 1).asSymbol));
            };
        };

        ~xtm.addNamed(
            "%_sl".format(layer_name).asSymbol,
            ~xtm.elAt(layer, \sl)
        );
        ~xtm.elAt("%_sl".format(layer_name).asSymbol).action_(MFunc.new);
    };

    (1..8).do { |n|
        var number = n.asSymbol;

        // LEDs dos botões no modo normal
        ~xtm.addNamed( "bt_a%_led".format(n).asSymbol, ~xtm.elAt( \led, number, \A ) );
        ~xtm.addNamed( "bt_b%_led".format(n).asSymbol, ~xtm.elAt( \led, number, \B ) );

        // Layer A — fileira A
        // a_bt_a1_on, a_bt_a1_off etc.
        ~xtm.addNamed( "a_bt_a%_on".format(n).asSymbol, ~xtm.elAt( \A, \chan, number, \bt, \A, \on ) );
        ~xtm.addNamed( "a_bt_a%_off".format(n).asSymbol,~xtm.elAt( \A, \chan, number, \bt, \A, \off) );
        ~xtm.elAt( "a_bt_a%_on".format(n).asSymbol).action_(MFunc.new);
        ~xtm.elAt( "a_bt_a%_off".format(n).asSymbol).action_(MFunc.new);

        // Layer A — fileira B
        // a_bt_b1_on, a_bt_b1_off etc.
        ~xtm.addNamed( "a_bt_b%_on".format(n).asSymbol, ~xtm.elAt( \A, \chan, number, \bt, \B, \on ) );
        ~xtm.addNamed( "a_bt_b%_off".format(n).asSymbol,~xtm.elAt( \A, \chan, number, \bt, \B, \off) );
        ~xtm.elAt( "a_bt_b%_on".format(n).asSymbol).action_(MFunc.new);
        ~xtm.elAt( "a_bt_b%_off".format(n).asSymbol).action_(MFunc.new);

        // Layer B — fileira A
        // b_bt_a1_on, b_bt_a1_off etc.
        ~xtm.addNamed( "b_bt_a%_on".format(n).asSymbol, ~xtm.elAt( \B, \chan, number, \bt, \A, \on ) );
        ~xtm.addNamed( "b_bt_a%_off".format(n).asSymbol,~xtm.elAt( \B, \chan, number, \bt, \A, \off) );
        ~xtm.elAt( "b_bt_a%_on".format(n).asSymbol) .action_(MFunc.new);
        ~xtm.elAt( "b_bt_a%_off".format(n).asSymbol).action_(MFunc.new);

        // Layer B — fileira B
        // b_bt_b1_on, b_bt_b1_off etc.
        ~xtm.addNamed( "b_bt_b%_on".format(n).asSymbol, ~xtm.elAt( \B, \chan, number, \bt, \B, \on ) );
        ~xtm.addNamed( "b_bt_b%_off".format(n).asSymbol,~xtm.elAt( \B, \chan, number, \bt, \B, \off) );
        ~xtm.elAt( "b_bt_b%_on".format(n).asSymbol).action_(MFunc.new);
        ~xtm.elAt( "b_bt_b%_off".format(n).asSymbol).action_(MFunc.new);

        // Modo MC — fileira A
        // mc_bt_a1_on, mc_bt_a1_off etc.
        ~xtm.addNamed( "mc_bt_a%_on".format(n).asSymbol, ~xtm.elAt( \MC, \chan, number, \bt, \A, \on ) );
        ~xtm.addNamed( "mc_bt_a%_off".format(n).asSymbol,~xtm.elAt( \MC, \chan, number, \bt, \A, \off ) );
        ~xtm.elAt ("mc_bt_a%_on".format(n).asSymbol).action_(MFunc.new);
        ~xtm.elAt( "mc_bt_a%_off".format(n).asSymbol).action_(MFunc.new);
        // Modo MC — fileira B
        // mc_bt_b1_on, mc_bt_b1_off etc.
        ~xtm.addNamed( "mc_bt_b%_on".format(n).asSymbol, ~xtm.elAt( \MC, \chan, number, \bt, \B, \on) );
        ~xtm.addNamed( "mc_bt_b%_off".format(n).asSymbol,~xtm.elAt( \MC, \chan, number, \bt, \B, \off) );
        ~xtm.elAt("mc_bt_b%_on".format(n).asSymbol).action_(MFunc.new);
        ~xtm.elAt("mc_bt_b%_off".format(n).asSymbol).action_(MFunc.new);

        // LEDs dos botões no modo MC
        ~xtm.addNamed( "mc_bt_a%_led".format(n).asSymbol, ~xtm.elAt( \mc_led, \chan, number, \bt, \A ) );
        ~xtm.addNamed( "mc_bt_b%_led".format(n).asSymbol, ~xtm.elAt( \mc_led, \chan, number, \bt, \B ) );

    };

    ~xtm.addNamed( 'mc_layer_a_on', ~xtm.elAt( \MC, \layer, \A, \on ) );
    ~xtm.addNamed( 'mc_layer_b_on', ~xtm.elAt( \MC, \layer, \B, \on ) );
    ~xtm.addNamed( 'mc_layer_a_off',~xtm.elAt( \MC, \layer, \A, \off ) );
    ~xtm.addNamed( 'mc_layer_b_off',~xtm.elAt( \MC, \layer, \B, \off ) );
    ~xtm.elAt( 'mc_layer_a_on' ).action_(MFunc.new);
    ~xtm.elAt( 'mc_layer_b_on' ).action_(MFunc.new);
    ~xtm.elAt( 'mc_layer_a_off').action_(MFunc.new);
    ~xtm.elAt( 'mc_layer_b_off').action_(MFunc.new);
    ~xtm.addNamed(\mc_layer_a_led, ~xtm.elAt( \mc_led, \layer, \A ));
    ~xtm.addNamed(\mc_layer_b_led, ~xtm.elAt( \mc_led, \layer, \B ));

    0.1.wait;

    ~xtm.elAt( \a_bt_b1_on ).action.add( \enter_mc, {
        ~xtm.elAt( \mode ).value_(1);
        ~xtm.elAt(\mc_bt_b1_led).value_(127);
    });
    ~xtm.elAt(\mc_bt_b1_on).action.add(\enter_normal_mode, {
        ~xtm.elAt( \mode ).value_(0);
        ~xtm.elAt(\mc_bt_a1_led).value = 0;
    });

    1.wait;
/*
//MC mode
// Aceso
~xtm.elAt(\mc_bt_b1_led).value_(127);

// Piscando
~xtm.elAt(\mc_bt_b1_led).value_(1);

// Apagado
~xtm.elAt(\mc_bt_b1_led).value_(0);
*/
    // -----------------------------------------------------------------
    // Processos
    // -----------------------------------------------------------------

    ~controls = (
        tidal: (
            a_enc1: "1",
            a_enc2: "2",
            a_enc3: "3",
            a_enc4: "4",
            a_enc5: "5",
            a_enc6: "6",
            a_enc7: "7",
            a_enc8: "8"
        ),
        pho: (
            a_enc1: \Cutoff,
            a_enc2: \Resonance,
            a_enc3: \Envmod,
            a_enc4: \Decay,
            a_enc5: 'Slide Time',
            a_enc6: 'Sweep Amount',
            a_enc7: 'Envmod Attack',
            a_enc8: 'Accent Decay'
        ),
        dru: (
            a_enc1: 'BD Pitch',
            a_enc2: 'BD Tune Depth',
            a_enc3: 'SD Tone',
            a_enc4: 'SD Snappy',
            a_enc5: 'RS Tune',
            a_enc6: 'MT Tune',
        ),
        spacemod: (
            a_enc1: \wetDry,
            a_enc2: \rate,
            a_enc3: \depth,
            a_enc4: \feedback,
            a_enc5: 'manual',
            a_enc6: 'Mode',
        ),
        modelay: (
            a_enc1: 'mdtime',
            a_enc2: 'mdtimel',
            a_enc3: 'mdtimer',
            a_enc4: 'mdfb',
            a_enc5: 'mdff',
            a_enc6: 'mdfq',
            a_enc7: 'mwide',
            a_enc8: 'mdamp',
        ),
        pitch: (
            a_enc1: \pdeg,
            a_enc2: \pdisp,
            a_enc3: \tdisp,
            a_enc4: \slide
        ),
        lfo: (
            a_enc1: \lrate,
            a_enc2: \iphase,
            a_enc3: \lwidth,
            a_enc4: \sisap,
            a_enc5: \lmidfreq,
            a_enc6: \lhifreq
        ),
        wah: (
            a_enc1: \wrate,
            a_enc2: \wdepth,
            a_enc3: \sinsaw,
            a_enc4: \jrate,
            a_enc5: \jdepth
        ),
        strobe: (
            a_enc1: \strob,
            a_enc2: \sphase,
            a_enc3: \ontime,
            a_enc4: \offtime,
            a_enc5: \scurve
        ),
        tape: (
            a_enc1: \trate,
            a_enc2: \tphase,
            a_enc3: \tdepth,
            a_enc4: \toffset
        ),
        hpf: (
            a_enc1: \hpffreq,
            a_enc2: \hrq
        ),
        lpf: (
            a_enc1: \lpffreq,
            a_enc2: \lrq
        ),
        endFilt: (
            a_enc1: \highPass,
            a_enc2: \lowPass
        ),
    );

    ~orb_fx_names = [ \modelay, \pitch, \lfo, \wah, \strobe, \tape, \hpf, \lpf, \endFilt ];
    ~process_names = [ \tidal, \pho, \spacemod, \dru ] ++ ~orb_fx_names;
    ~orbit_names = (0..7).collect { |i| ( "orb" ++ i.asString.padLeft(2, "0") ).asSymbol };

    // Processos de áudio externos. Os instrumentos usam os slots 0..9;
    // os slots 10, 20, 30... continuam reservados para a ProxyChain.
    ~external_instrument_names = [\pho, \dru];
    ~external_instrument_sources = (pho: \pho, dru: \dru);
    ~external_effect_names = [\spacemod];
    ~external_effect_sources = (spacemod: \spacemod);

    if (~external_instrument_names.size > 10) {
        Error("Há mais de dez instrumentos externos para os slots 0..9.").throw;
    };

    // Guarda a órbita à qual cada efeito externo está ligado.
    ~external_fx_orbits = ~external_fx_orbits ? ();

    // Valores normalizados (0..1), independentes de o efeito estar ativo.
    ~orb_fx_values = ~orb_fx_values ? ();
    ~process_values = ~process_values ? ();

    // carrega vsts
    if(~pho.isNil) { (Platform.userHomeDir +/+ "SuperCollider" +/+ "instruments" +/+ "phoscyon_vst.scd").load };
    s.sync;
    2.wait;

    if(~dru.isNil) { (Platform.userHomeDir +/+ "SuperCollider" +/+ "instruments" +/+ "drumazon_vst.scd").load };
    s.sync;
    2.wait;

    if(~spacemod.isNil) { (Platform.userHomeDir +/+ "SuperCollider" +/+ "FX" +/+ "valhalla_space.scd").load };
    s.sync;
    2.wait;

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
                    "Sem spec: % em %\n".postf(parameter_name, effect_name);
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

    // MFunc compartilhada pelos oito encoders.
    // Todas as funções recebem valor normalizado e orbit separadamente.
    // Isso permite usar a mesma MFunc tanto manualmente quanto pelo KtlLoop.
    ~process_selector = MFunc([

        \tidal, { |element_name, value, orbit_name|
            var control_name = ~controls.tidal[element_name];

            if (control_name.notNil) {
                ~tidal_osc.sendMsg("/ctrl", control_name.asString, value);
                ~process_values[\tidal][control_name] = value;
            };
        },

        \pho, { |element_name, value, orbit_name|
            var parameter_name = ~controls.pho[element_name];

            if (parameter_name.notNil) {
                ~pho.set(parameter_name, value);
                ~process_values[\pho][parameter_name] = value;
            };
        },

        \spacemod, { |element_name, value, orbit_name|
            var parameter_name = ~controls.spacemod[element_name];

            if (parameter_name.notNil) {
                ~spacemod.set(parameter_name, value);
                ~process_values[\spacemod][parameter_name] = value;
            };
        },
        \dru, { |element_name, value, orbit_name|
            var parameter_name = ~controls.dru[element_name];

            if (parameter_name.notNil) {
                ~dru.set(parameter_name, value);
                ~process_values[\dru][parameter_name] = value;
            };
        },

    ]);


    // Adiciona os orbit_fx a ~process_selector
    ~orb_fx_names.do { |effect_name|
        ~process_selector.add( effect_name,
            { |element_name, value, orbit_name|
                var target_orbit = orbit_name ? ~selected_orbit_name;
                var proxy = Ndef(target_orbit);
                var parameter_name = ~controls[effect_name][element_name];
                var spec;

                if (parameter_name.notNil) {
                    spec = ~get_orb_fx_spec.value(
                        effect_name,
                        parameter_name,
                        proxy
                    );

                    if (spec.notNil) {
                        proxy.addSpec(parameter_name, spec);
                        proxy.set(parameter_name, spec.map(value));
                        ~orb_fx_values
                        [target_orbit]
                        [effect_name]
                        [parameter_name] = value;
                    } {
                        "Sem spec: % em %\n".postf(parameter_name, target_orbit);
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

    // O layer A envia valores absolutos. Guardamos o último valor físico e
    // usamos somente a diferença entre duas mensagens consecutivas. Assim o
    // encoder começa a atuar imediatamente sobre o valor mostrado no ring,
    // sem pickup. A referência inicial fica no centro do percurso (127 / 2).
    ~encoder_hardware_values = ();
    ~encoder_target_values = ();

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
        var ring_name = "%_ring".format(element_name).asSymbol;
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

            // Primeiro escolhe single; depois posiciona o segmento.
            ~xtm.elAt(\ring, \mode, i).value_(0);
            ~xtm.elAt(ring_name).value_(normalized_value * 13);
        } {
            // Encoder sem parâmetro no processo atual.
            ~encoder_target_values[element_name] = nil;

            ~xtm.elAt(\ring, \mode, i).value_(0);
            ~xtm.elAt(ring_name).value_(0);
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

    // LEDs A: ligados nas órbitas com ao menos um efeito ou instrumento.
    // A órbita selecionada, sozinha, não altera esta indicação.
    ~update_orbit_fx_leds = {
        ~orbit_names.do { |orbit_name, i|
            var led_name = "bt_a%_led".format(i + 1).asSymbol;

            ~xtm.elAt(led_name).value_(
                ~active_orbit_processes.value(orbit_name)
                .isEmpty.not.binaryValue
            );
        };
    };

    // Linha A: escolhe a órbita cujos parâmetros os encoders controlam.
    ~select_orbit = { |orbit_name|
        var active_processes;

        ~selected_orbit_name = orbit_name;
        ~sync_encoders.value;
        ~update_orbit_fx_leds.value;
        active_processes = ~active_orbit_processes.value(orbit_name);

        "orbit selecionada: % | ativos: %\n".postf(
            ~selected_orbit_name,
            if (active_processes.isEmpty) { \nenhum } { active_processes }
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

    // Controle manual: soma o delta físico ao valor lógico do processo/orbit.
    ~a_enc_names.do { |element_name, i|
        ~xtm.elAt(element_name).action.add(\process_selector, { |el|
            var hardware_value = el.value;
            var previous_value = ~encoder_hardware_values[element_name];
            var target_value = ~encoder_target_values[element_name];
            var delta;
            var next_value;

            ~encoder_hardware_values[element_name] = hardware_value;

            if (previous_value.notNil and: { target_value.notNil }) {
                delta = hardware_value - previous_value;
                next_value = (target_value + delta).clip(0, 1);

                ~encoder_target_values[element_name] = next_value;

                ~process_selector.value(
                    element_name,
                    next_value,
                    ~selected_orbit_name
                );

                // Durante o controle manual, a própria X-Touch mostra
                // o valor físico no modo fan.
                ~xtm.elAt(\ring, \mode, i).value_(2);
            };
        });
    };

    // ~process_selector.activeNames;

    // B3: ⏪︎ processo anterior
    ~xtm.elAt(\a_bt_b3_on).action.add( \previous_process, {
        var process_names = ~process_selector.modeLists[\processes];
        var current_index = process_names.indexOf( ~process_selector.mode );
        var previous_process = process_names.wrapAt( current_index - 1 );
        ~process_selector.mode_(previous_process);
        ~sync_encoders.value;
        // "processo: %\n".postf( ~process_selector.mode );
        ~process_selector.mode.asString.toUpper.warn;
    } );

    // B4: ⏩︎ próximo processo
    ~xtm.elAt(\a_bt_b4_on).action.add(\next_process, {
        var process_names = ~process_selector.modeLists[\processes];
        var current_index = process_names.indexOf(~process_selector.mode);
        var next_process = process_names.wrapAt(current_index + 1);

        ~process_selector.mode_(next_process);
        ~sync_encoders.value;
        ~process_selector.mode.asString.toUpper.warn;
    } );

    // Push do encoder N: liga/desliga o processo atual na órbita N.
    // Não muda ~selected_orbit_name; essa escolha continua sendo dos botões A.
    ~toggle_orbit_process = { |orbit_name|
        var process_name = ~process_selector.mode;
        var chain;
        var proxy;
        var slot_index;
        var source_name;

        case
        { ~orb_fx_names.includes(process_name) } {
            chain = ~chain_at.value(orbit_name);

            if (chain.isNil) {
                "Sem ProxyChain para %\n".postf(orbit_name);
            } {
                if (chain.activeSlotNames.includes(process_name)) {
                    ~store_orb_fx_values.value(orbit_name, process_name);
                    chain.remove(process_name);
                    "efeito % desligado em %\n".postf(
                        process_name,
                        orbit_name
                    );
                } {
                    chain.add(process_name, 1);
                    ~restore_orb_fx_values.value(orbit_name, process_name);
                    "efeito % ligado em %\n".postf(
                        process_name,
                        orbit_name
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
                "instrumento % retirado de %[%]\n".postf(
                    process_name,
                    orbit_name,
                    slot_index
                );
            } {
                proxy[slot_index] = \mix -> { Ndef(source_name).ar };
                "instrumento % inserido em %[%]\n".postf(
                    process_name,
                    orbit_name,
                    slot_index
                );
            };
        }
        { ~external_effect_names.includes(process_name) } {
            source_name = ~external_effect_sources[process_name];

            if (~external_fx_orbits[process_name] == orbit_name) {
                Ndef(source_name).set(\in, nil);
                ~external_fx_orbits[process_name] = nil;
                ~rebuild_all_orbs.value;
                "efeito externo % desligado de %\n".postf(
                    process_name,
                    orbit_name
                );
            } {
                Ndef(source_name).set(\in, Ndef(orbit_name));
                ~external_fx_orbits[process_name] = orbit_name;
                ~rebuild_all_orbs.value;
                "efeito externo % ligado a %\n".postf(
                    process_name,
                    orbit_name
                );
            };
        }
        {
            "% não possui roteamento de áudio por push\n".postf(process_name);
        };

        ~update_orbit_fx_leds.value;

        if (~selected_orbit_name == orbit_name) {
            ~sync_encoders.value;
        };
    };

    // Usado pelo duplo clique de B6. Preserva os instrumentos nos slots 0..9
    // e desliga somente efeitos internos e externos.
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
        ~sync_encoders.value;
        "todos os efeitos foram desligados".postln;
    };

    ~a_enc_names.do { |element_name, i|
        var push_on_name = "%_on".format(element_name).asSymbol;

        ~xtm.elAt(push_on_name).action.add(\toggle_orbit_process, {
            var play_held = ~play_button_state.notNil and: {
                ~play_button_state[\held]
            };
            var record_held = ~record_button_state.notNil and: {
                ~record_button_state[\held]
            };

            // Com B7/B8 pressionado, o push pertence ao gesto do KtlLoop.
            if ((play_held or: record_held).not) {
                ~toggle_orbit_process.value(~orbit_names[i]);
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

/* // para adicionar novos processos:
~process_selector.add(\outro_processo, { |element_name, value, orbit_name|
    var parameter_name = ~controls.outro_processo[element_name];

    if (parameter_name.notNil) {
        // ação do novo processo
    };
}, false);

~process_names = ~process_names.add(\outro_processo);

~process_selector.makeExclusiveModes( \processes, ~process_names );*/

    // Estado da seleção e das operações ativas

    ~record_encoders = IdentitySet.new;
    ~play_encoders = IdentitySet.new;
    ~recording_encoders = IdentitySet.new;
    ~playing_encoders = IdentitySet.new;
    ~held_encoders = IdentitySet.new;
    ~loop_taken_over = IdentitySet.new;

    // IdentitySet compara seus itens por identidade. A combinação é convertida
    // em Symbol para que eventos equivalentes produzam exatamente a mesma chave.
    ~loop_route_key = { |encoder_name, process_name, orbit_name|
        "%|%|%".format(
            encoder_name,
            process_name,
            orbit_name
        ).asSymbol;
    };

    ~play_button_state = (
        name: \play,
        held: false,
        chord_used: false,
        chord_encoders: IdentitySet.new,
        click_count: 0,
        click_task: nil,
        selected: ~play_encoders,
        active: ~playing_encoders
    );

    ~record_button_state = (
        name: \record,
        held: false,
        armed: false,
        chord_used: false,
        chord_encoders: IdentitySet.new,
        click_count: 0,
        click_task: nil,
        selected: ~record_encoders,
        active: ~recording_encoders
    );


    // Seleção de encoders para o KtlLoop. Os LEDs A não são usados aqui:
    // eles indicam somente quais órbitas possuem efeitos ativos.

    ~add_encoder_to_chord = { |state, encoder_name|
        if (state[\chord_used].not) {
            state[\chord_used] = true;
            state[\chord_encoders].clear;
        };

        state[\chord_encoders].add(encoder_name);
    };

    ~commit_chord_selection = { |state|
        state[\selected].addAll(state[\chord_encoders]);

        if (state[\active].isEmpty.not) {
            state[\active].addAll(state[\chord_encoders]);
        };

        // Por padrão, tudo que é escolhido para gravar também pode ser tocado.
        if (state[\name] == \record) {
            ~play_encoders.addAll(state[\chord_encoders]);

            // Se ainda não há gravação, o primeiro movimento de qualquer
            // encoder selecionado iniciará startRec.
            if (~recording_encoders.isEmpty) {
                state[\armed] = true;
            };
        };
    };

    // KtlLoop e modos B5/B2

    ~loop = KtlLoop(\xtm);
    ~loop.paramsToRecord_(~a_enc_names);
    ~loop.looped_(true);

    ~xtm.elAt(\a_bt_b5_on).action.add(\toggle_loop, {
        ~loop.looped_(~loop.looped.not);
        ~xtm.elAt(\bt_b5_led).value_(~loop.looped.binaryValue);
        postf("loop: %\n\n",~loop.looped);
    });

    ~xtm.elAt(\a_bt_b5_off).action.add(\toggle_loop, {
        ~xtm.elAt(\bt_b5_led).value_(~loop.looped.binaryValue);
    });

    ~loop_palindrome = true;

    ~xtm.elAt(\a_bt_b2_on).action.add(\toggle_palindrome, {
        ~loop_palindrome = ~loop_palindrome.not;
        ~xtm.elAt(\bt_b2_led).value_(~loop_palindrome.binaryValue);
        postf("palindrome: %\n\n",~loop_palindrome);
    });

    ~xtm.elAt(\a_bt_b2_off).action.add(\toggle_palindrome, {
        ~xtm.elAt(\bt_b2_led).value_(~loop_palindrome.binaryValue);
    });

    ~make_loop_palindrome = {
        var source = ~loop.list;
        var control_events, source_start, source_dur, palindrome;

        if (source.size > 2) {
            source_start = source.first[\absTime];
            source_dur = source.last[\absTime] - source_start;
            control_events = source.select { |event|
                [\start, \end].includes(event[\type]).not;
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

            // Omite o último evento da ida para não repetir o ponto de retorno.
            control_events.reverse.do { |event, i|
                var copy, relative_time;

                if (i > 0) {
                    relative_time = event[\absTime] - source_start;
                    copy = event.copy;
                    copy[\absTime] = (source_dur * 2) - relative_time;
                    copy.removeAt(\relDur);
                    copy.removeAt(\playDur);
                    copy.removeAt(\dur);
                    palindrome.addEvent(copy);
                };
            };

            palindrome.finish(source_dur * 2);
            ~loop.list_(palindrome);
        };
    };


    // Transporte e feedback visual

    ~update_transport_leds = {
        ~xtm.elAt(\bt_b7_led)
        .value_(~playing_encoders.isEmpty.not.binaryValue * 2);
        ~xtm.elAt(\bt_b8_led)
        .value_(~recording_encoders.isEmpty.not.binaryValue * 2);
    };

    ~start_loop_recording = {
        if (~record_encoders.isEmpty) {
            "[KTL] seleção de gravação vazia".warn;
        } {
            // Não há overdub: uma nova gravação encerra a reprodução atual.
            if (~loop.isPlaying) {
                ~loop.stop;
            };

            ~playing_encoders.clear;
            ~loop_taken_over.clear;
            ~recording_encoders.clear;
            ~recording_encoders.addAll(~record_encoders);
            ~record_button_state[\armed] = false;

            ~update_transport_leds.value;
            ~loop.startRec;
        };
    };

    ~stop_loop_recording = {
        var was_recording = ~recording_encoders.isEmpty.not;

        ~loop.stopRec;
        if (was_recording and: { ~loop_palindrome }) {
            ~make_loop_palindrome.value;
        };

        ~recording_encoders.clear;
        ~record_button_state[\armed] = false;
        ~update_transport_leds.value;
    };

    ~start_loop_playback = {
        if (~play_encoders.isEmpty) {
            "[KTL] seleção de reprodução vazia".warn;
        } {
            if (~recording_encoders.isEmpty.not) {
                ~stop_loop_recording.value;
            };

            ~playing_encoders.clear;
            ~playing_encoders.addAll(~play_encoders);
            ~loop_taken_over.clear;

            ~update_transport_leds.value;
            ~xtm.elAt(\ring, \mode).value_(0);
            ~loop.play;
        };
    };

    ~stop_loop_playback = {
        ~loop.stop;
        ~playing_encoders.clear;
        ~loop_taken_over.clear;
        ~update_transport_leds.value;
        ~sync_encoders.value;
    };

    // -----------------------------------------------------------------
    // Clique simples/duplo de B7 e B8
    // -----------------------------------------------------------------

    ~double_click_time = 0.3;
    ~stop_button_click_count = 0;
    ~stop_button_click_task = nil;

    ~cancel_loop_button_click = { |state|
        if (state[\click_task].notNil) {
            state[\click_task].stop;
        };
        state[\click_count] = 0;
        state[\click_task] = nil;
    };

    ~handle_loop_button_click = { |state, single_action|
        state[\click_count] = state[\click_count] + 1;

        if (state[\click_task].notNil) {
            state[\click_task].stop;
        };

        state[\click_task] = Task({
            ~double_click_time.wait;

            if (state[\click_count] > 1) {
                state[\selected].clear;
                state[\selected].addAll(~a_enc_names);

                if (state[\name] == \record) {
                    ~play_encoders.clear;
                    ~play_encoders.addAll(~a_enc_names);
                };

                if (state[\active].isEmpty.not) {
                    state[\active].clear;
                    state[\active].addAll(~a_enc_names);
                };

            } {
                single_action.value;
            };

            state[\click_count] = 0;
            state[\click_task] = nil;
        }).play(AppClock);
    };

    // -----------------------------------------------------------------
    // Pushes, gravação e takeover dos encoders
    // -----------------------------------------------------------------

    ~a_enc_names.do { |name, i|
        var push_on_name = "%_on".format(name).asSymbol;
        var push_off_name = "%_off".format(name).asSymbol;

        ~xtm.elAt(push_on_name).action.add(\loop_select, {
            ~held_encoders.add(name);

            if (~play_button_state[\held]) {
                ~cancel_loop_button_click.value(~play_button_state);
                ~add_encoder_to_chord.value(~play_button_state, name);
            };

            if (~record_button_state[\held]) {
                ~cancel_loop_button_click.value(~record_button_state);
                ~add_encoder_to_chord.value(~record_button_state, name);
            };
        });

        ~xtm.elAt(push_off_name).action.add(\loop_select, {
            ~held_encoders.remove(name);
        });

        ~xtm.elAt(name).action.add(\record, { |el|
            var value = ~encoder_target_values[name];

            if (
                ~record_button_state[\armed]
                and: { ~record_encoders.includes(name) }
            ) {
                ~start_loop_recording.value;
            };

            if (
                ~recording_encoders.includes(name)
                and: { value.notNil }
            ) {
                ~loop.recordEvent(
                    (
                        type: \set,
                        process: ~process_selector.mode,
                        orbit: ~selected_orbit_name
                    ).put(name, value.trunc(0.001))
                );
            };
        });

        // Executa antes de \process_selector. O takeover pertence à combinação
        // encoder/processo/orbit atual; o mesmo encoder pode continuar sendo
        // reproduzido pelo loop em outra combinação.
        ~xtm.elAt(name).action.addFirst(\takeover, {
            if (~playing_encoders.includes(name)) {
                var route_key = ~loop_route_key.value(
                    name,
                    ~process_selector.mode,
                    ~selected_orbit_name
                );

                ~loop_taken_over.add(route_key);
                ~xtm.elAt(\ring, \mode, i).value_(2);

                if (~encoder_target_values[name].notNil) {
                    ~xtm.elAt(\ring, \seg, i).value_(
                        ~encoder_target_values[name] * 13
                    );
                };
            };
        });
    };

    // -----------------------------------------------------------------
    // B7 = play, B8 = record, B6 = stop
    // -----------------------------------------------------------------

    ~xtm.elAt(\a_bt_b7_on).action.add(\loop_play, {
        if (~play_button_state[\held].not) {
            ~play_button_state[\held] = true;
            ~play_button_state[\chord_used] = false;
            ~play_button_state[\chord_encoders].clear;

            ~held_encoders.do { |name|
                ~cancel_loop_button_click.value(~play_button_state);
                ~add_encoder_to_chord.value(~play_button_state, name);
            };
        };
    });

    ~xtm.elAt(\a_bt_b7_off).action.add(\loop_play, {
        if (~play_button_state[\held]) {
            ~play_button_state[\held] = false;

            if (~play_button_state[\chord_used]) {
                ~commit_chord_selection.value(~play_button_state);
                ~start_loop_playback.value;
            } {
                ~handle_loop_button_click.value(
                    ~play_button_state,
                    ~start_loop_playback
                );
            };
        };
    });

    ~xtm.elAt(\a_bt_b8_on).action.add(\loop_record, {
        if (~record_button_state[\held].not) {
            ~record_button_state[\held] = true;
            ~record_button_state[\chord_used] = false;
            ~record_button_state[\chord_encoders].clear;

            ~held_encoders.do { |name|
                ~cancel_loop_button_click.value(~record_button_state);
                ~add_encoder_to_chord.value(~record_button_state, name);
            };
        };
    });

    ~xtm.elAt(\a_bt_b8_off).action.add(\loop_record, {
        if (~record_button_state[\held]) {
            ~record_button_state[\held] = false;

            if (~record_button_state[\chord_used]) {
                ~commit_chord_selection.value(~record_button_state);
            } {
                ~handle_loop_button_click.value(
                    ~record_button_state,
                    ~start_loop_recording
                );
            };
        };
    });

    ~xtm.elAt(\a_bt_b6_on).action.add(\loop_stop_all, {
        ~cancel_loop_button_click.value(~play_button_state);
        ~cancel_loop_button_click.value(~record_button_state);
        ~play_button_state[\held] = false;
        ~record_button_state[\held] = false;
        ~record_button_state[\armed] = false;
        ~play_button_state[\chord_used] = false;
        ~record_button_state[\chord_used] = false;
        ~held_encoders.clear;
        ~stop_loop_playback.value;
        ~stop_loop_recording.value;

        ~stop_button_click_count = ~stop_button_click_count + 1;

        if (~stop_button_click_task.notNil) {
            ~stop_button_click_task.stop;
        };

        if (~stop_button_click_count > 1) {
            ~stop_button_click_count = 0;
            ~stop_button_click_task = nil;
            ~disable_all_effects.value;
        } {
            ~stop_button_click_task = Task({
                ~double_click_time.wait;
                ~stop_button_click_count = 0;
                ~stop_button_click_task = nil;
            }).play(AppClock);
        };
    });

    // -----------------------------------------------------------------
    // Reprodução dos eventos gravados
    // -----------------------------------------------------------------

    ~loop_stop_action = { |player, action|
        if ([\userStopped, \stopped].includes(action)) {
            ~playing_encoders.clear;
            ~loop_taken_over.clear;
            ~update_transport_leds.value;
            ~sync_encoders.value;
        };
    };

    ~loop.func_({ |event|
        var process_name = event[\process] ? ~process_selector.mode;
        var orbit_name = event[\orbit] ? ~selected_orbit_name;

        if (~loop_player !== ~loop.task.player) {
            ~loop_player = ~loop.task.player;
            ~loop_player.addDependant(~loop_stop_action);

            // Também cobre play iniciado pela KtlLoopGui ou por ~loop.play.
            if (~playing_encoders.isEmpty) {
                ~recording_encoders.clear;
                ~playing_encoders.addAll(~play_encoders);
                ~update_transport_leds.value;
            };
        };

        if (event[\type] == \set) {
            ~a_enc_names.do { |name, i|
                var value = event[name];
                var route_key = ~loop_route_key.value(
                    name,
                    process_name,
                    orbit_name
                );

                if (
                    value.notNil
                    and: { ~playing_encoders.includes(name) }
                    and: { ~loop_taken_over.includes(route_key).not }
                ) {
                    if (~process_selector.at(process_name).notNil) {
                        // valueAt chama o processo gravado mesmo que outro modo
                        // esteja selecionado agora na MFunc.
                        ~process_selector.valueAt(
                            [process_name],
                            name,
                            value,
                            orbit_name
                        );

                        // O loop só assume o ring quando sua rota também está
                        // visível. Movimentos de outros processos/orbits não
                        // interferem no feedback do controle atual.
                        if (
                            process_name == ~process_selector.mode
                            and: { orbit_name == ~selected_orbit_name }
                        ) {
                            ~xtm.elAt(\ring, \mode, i).value_(0);
                            ~xtm.elAt(\ring, \seg, i).value_(value * 13);
                            ~encoder_target_values[name] = value;
                        };
                    } {
                        "Processo do loop não encontrado: %\n".postf(
                            process_name
                        );
                    };
                };
            };
        };
    });

    // -----------------------------------------------------------------
    // CmdPeriod e estado visual inicial
    // -----------------------------------------------------------------


    if (~xtm_cmd_period_action.notNil) {
        CmdPeriod.remove(~xtm_cmd_period_action);
    };

    ~xtm_cmd_period_action = {
        ~playing_encoders.clear;
        ~recording_encoders.clear;
        ~loop_taken_over.clear;
        ~held_encoders.clear;
        ~play_button_state[\held] = false;
        ~record_button_state[\held] = false;
        ~record_button_state[\armed] = false;
        ~play_button_state[\chord_used] = false;
        ~record_button_state[\chord_used] = false;
        ~stop_button_click_count = 0;
        if (~stop_button_click_task.notNil) {
            ~stop_button_click_task.stop;
            ~stop_button_click_task = nil;
        };
        ~update_transport_leds.value;
        ~update_orbit_fx_leds.value;
        ~xtm.elAt(\ring, \mode).value_(2);
    };
    CmdPeriod.add(~xtm_cmd_period_action);

    ~update_orbit_fx_leds.value;
    ~update_transport_leds.value;
    ~xtm.elAt(\ring, \mode).value_(2);
    ~xtm.elAt(\bt_b5_led).value_(~loop.looped.binaryValue);
    ~xtm.elAt(\bt_b2_led).value_(~loop_palindrome.binaryValue);


};
)

~process_selector.mode;        // deve ser \tidal
~selected_orbit_name;          // deve ser \orb00
~loop.looped;                  // deve ser true
~loop_palindrome;              // deve ser true
~xtm.elAt(\ring, \mode).value; // deve ser 2: fan

ProxyChain.sourceDicts.keys.postln;
q.fx.keys.postln;
~process_selector.activeNames.postln;



