~init_xtouch_device = {
    var xtouch_info;
    var lookup_wait = 0.0;

    ~xtouch_device_revision = "2026-09-09-device-r8.1";

    // MKtl.find trabalha em segundo plano. Em vez de supor que um segundo é
    // suficiente, esperamos a X-Touch aparecer de fato no MKtlLookup.
    MKtl.find(\midi);
    xtouch_info = MKtlLookup.findByIDInfo("X-TOUCH MINI");

    while {
        (xtouch_info.isNil or: { xtouch_info.isEmpty })
        and: { lookup_wait < 10.0 }
    } {
        0.1.wait;
        lookup_wait = lookup_wait + 0.1;
        xtouch_info = MKtlLookup.findByIDInfo("X-TOUCH MINI");
    };

    // MKtl.find pode recarregar a descrição padrão durante a descoberta.
    // Reaplicamos explicitamente a cópia empacotada antes de criar o MKtl.
    MKtlDesc.fromPath(q.xtouch.desc_path);

    // Uma carga anterior pode ter deixado uma instância construída com a
    // descrição padrão. Ela precisa ser recriada para ganhar a árvore MC.
    [\xtm, \loop].do { |mktl_name|
        var previous = MKtl.all[mktl_name];

        if (previous.notNil) {
            previous.free;
        };
    };

    if (xtouch_info.isNil or: { xtouch_info.isEmpty }) {
        // Com o nome \loop, o mesmo patch continua utilizável pela GUI quando
        // a controladora física não está conectada. Um MKtl criado a partir da
        // descrição permanece virtual se nenhum dispositivo correspondente
        // estiver disponível.
        ~xtm = MKtl(\loop, "behringer-x-touch-mini");
        ~xtm_is_virtual = true;

        {
            ~xtm_gui = MKtl(\loop).gui;
            ~xtm_gui.parent.alwaysOnTop_(true);
        }.defer;

        "X-TOUCH MINI não encontrada; usando MKtl(\\loop) virtual."
        .warn;
    } {
        ~xtm = MKtl(\xtm, "behringer-x-touch-mini");
        ~xtm_is_virtual = false;
    };
    // ~xtm.gui;
    // ~xtm.desc.openFile;
    ~xtm.trace(false);

    if (
        ~xtm.elAt(\mc_ring, \1).isNil
        or: { ~xtm.elAt(\mc_led, \layer, \A).isNil }
    ) {
        Error(
            "A descrição MC empacotada não foi aplicada. "
            "Confira q.xtouch.desc_path e MKtlDesc.descFolders."
        ).throw;
    };

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

    // -----------------------------------------------------------------
    // Tempo: os sliders A, B e MC controlam o LinkClock em t
    // -----------------------------------------------------------------

    // A Tdef só é tocada quando um slider fornece um novo BPM. Não há loop
    // nem consulta periódica.
    Tdef(\xtouch_bpm).stop;
    Tdef(\xtouch_bpm).clear;

    [\a_sl, \b_sl, \mc_sl].do { |slider_name|
        ~xtm.elAt(slider_name).action.add(\tempo, { |el|
            topEnvironment.use {
                var slider_value = el.value;
                var bpm;

                // Nos sliders MIDI de 7 bits, o centro cai entre 63 e 64.
                // Ambos são tratados como 0.5 para que o centro seja 120 BPM.
                if ((slider_value - 0.5).abs <= (0.5 / 127)) {
                    slider_value = 0.5;
                };

                bpm = slider_value.linlin(0, 1, 40, 200);

                Tdef(\xtouch_bpm, {
                    t.tempo_(bpm / 60);
                    ~xtouch_log.value(
                        "BPM: %".format(bpm.round(0.1))
                    );
                })
                .clock_(t)
                .quant_(0)
                .play;
            };
        });
    };

    ~enter_mc_mode = {
        ~xtm.elAt( \mode ).value_(1);
        if (~on_enter_mc.notNil) { ~on_enter_mc.value };
    };

    ~enter_normal_mode = {
        ~xtm.elAt( \mode ).value_(0);
        if (~on_leave_mc.notNil) { ~on_leave_mc.value };
    };

    // B1 tem a mesma função nas layers A e B.
    ~xtm.elAt(\a_bt_b1_on).action.add(\enter_mc, ~enter_mc_mode);
    ~xtm.elAt(\b_bt_b1_on).action.add(\enter_mc, ~enter_mc_mode);
};
