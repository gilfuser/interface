(
fork{
    MKtl.find(\midi);
    s.sync;
    // TODO:
    1- Diminuir quantidade de processos. Está quebrando o server a.t.m.
    // 3 notes[] näo desliga synth. criar um array pra cada synth
    // 7- implementar /home/skmecs/SuperCollider/interface/loop Machines/midi_LoopStation.scd

    q.mpk = /*q.mpk ? */MKtl(\mpk, "my-complete-mpkmini2");
    s.sync;
}
);

// q.mpk.rebuild("my-complete-mpkmini2"); // this won't work on Linux
// q.mpk.gui;
// q.mpk.free;
/*
q.mpk.trace(true);
q.mpk.gui;
*/
(
fork{
    // Elements Groups Naming __________________________________________________________________

    q.piano = q.mpk.elementGroup.elAt(\p0, \pkey);
    q.pads = q.mpk.elementGroup.elAt(\p0, \pad);
    q.btns = q.mpk.elementGroup.elAt(\p0, \bt);
    q.knobs = q.mpk.elementGroup.elAt(\p0, \kn);

    s.sync;
    // make initial shorter names
    q.allNotes = [
        "df0", "d0", "ef0", "e0", "f0", "gf0", "g0", "af0", "a0", "bf0", "b0", "c0",
        "df1", "d1", "ef1", "e1", "f1", "gf1", "g1", "af1", "a1", "bf1", "b1", "c1",
        "df2", "d2", "ef2", "e2", "f2", "gf2", "g2", "af2", "a2", "bf2", "b2", "c2",
        "df3", "d3", "ef3", "e3", "f3", "gf3", "g3", "af3", "a3", "bf3", "b3", "c3",
        "df4", "d4", "ef4", "e4", "f4", "gf4", "g4", "af4", "a4", "bf4", "b4", "c4",
        "cs5", "d5", "ds5", "e5", "f5", "fs5", "g5", "gs5", "a5", "as5", "b5", "c5",
        "cs6", "d6", "ds6", "e6", "f6", "fs6", "g6", "gs6", "a6", "as6", "b6", "c6",
        "cs7", "d7", "ds7", "e7", "f7", "fs7", "g7", "gs7", "a7", "as7", "b7", "c7",
        "cs8", "d8", "ds8", "e8", "f8", "fs8", "g8", "gs8", "a8", "as8", "b8", "c8",
        "cs9", "d9", "ds9", "e9", "f9", "fs9", "g9", "gs9", "a9", "as9", "b9", "c9",
    ];
    q.piano.do {|el, i|
        var name = ( q.allNotes.at(i) ).asSymbol;
        q.mpk.addNamed( name, el );
        q.mpk.elAt(name).action = { |el|
            MFdef(name).value(el.value) }
    };
    q.pads.do { |el, i|
        var name = "pd%".format(i+1).asSymbol;
        q.mpk.addNamed(name, el );
        q.mpk.elAt(name).action = { |el|
            MFdef(name).value(el.value) }
    };
    q.btns.do { |el, i|
        var name = "bt%".format(i+1).asSymbol;
        q.mpk.addNamed( name, el );
        q.mpk.elAt(name).action = { |el|
            MFdef(name).value(el.value, name) }
    };
    q.mpk.elAt(\bt1).value = 1;
    q.knobs.do { |el, i|
        var name = "kn%".format(i+1).asSymbol;
        q.mpk.addNamed( name, el );
        q.mpk.elAt(name).action = { |el|
            MFdef(name).value(el.value, el.prevValue) }
    };
    s.sync;
}
);

(
fork{
    (
q.synths = q.synths ? q.tonalDefs.scramble.keep(8);
q.synths = SortedList[].addAll(q.synths);
q.synths_on = q.synths_on ? ();
q.synths_before = q.synths;
q.default_values = ();
q.ctrls_values_now = ();
q.synths_ctrls = ();
q.notes_per_synth = Dictionary.with(*[
    \synth1->[],\synth2->[],\synth3->[],\synth4->[],
    \synth5->[],\synth6->[],\synth7->[],\synth8->[]
]); // keep track of notes per synth
q.synths_specs = NamedList();
);

(
q.get_ctrls = { |q synth|
    var ctrls = SynthDescLib.at(synth).controlNames;
    [\out, \freq, \amp, \t_trig, \trig, \gate, \t_gate, \bendFac ].do { |notThis|
        ctrls = ctrls.reject {|ctrl| ( ctrl == notThis ) }
    };
    q.synths_ctrls.put( synth, ctrls );
};
);

(
q.get_default_values = { |q synth |
    var names_values = [];
    var default_names_vals = Dictionary.newFrom(
        SynthDescLib.at(synth).defaultNamesVals
    );
    q.synths_ctrls.at(synth).do { | ctrl |
        names_values = names_values.add (
            default_names_vals.associationAt( ctrl ) );
    };
    q.default_values.put( synth, names_values );
    q.ctrls_values_now = q.default_values;
};
);

(
q.set_specs = { |q synth|
    var specs = SynthDescLib.at(synth).specs;
    var spec_list = NamedList();
    q.synths_specs.put(synth, spec_list);
    q.synths_ctrls.at(synth).do { |ctrl i|
            if ( specs.keys.includes(ctrl) == true ) {
            q.synths_specs.at(synth).add( ctrl, specs.at(ctrl) );
        }
        // if ( specs.keys.includes(ctrl) == false )
        {
            if ( Spec.specs.at(ctrl).notNil ) {
                q.synths_specs.at(synth).add( ctrl, ctrl );
            }
            {
                format("\nquando possível crie uma spec para %\nda synthdef %\n", ctrl, synth).toUpper.warn;
                // tenta adivinhar valores razoáveis
                q.default_values.at(synth).do {|key_value_pair|
                    // postf("Control -> Value: %\n", key_value_pair );
                    if (key_value_pair.key == ctrl ) {
                        var value = key_value_pair.value;
                        case
                        { value == 0 }
                        { q.synths_specs.at(synth).add(ctrl, \pan) }
                        { (value > 0) && (value <= 1) }
                        { q.synths_specs.at(synth).add(ctrl, [0.01, 1]) }
                        { (value > 1)&&(value < 25) }
                        { q.synths_specs.at(synth).add(ctrl,[1,25,\lin,8,1]) }
                        { (value > 25)&&(value <= 4200)}
                        { q.synths_specs.at(synth).add(ctrl, \midfreq) }
                        { value > 4200 }
                        { q.synths_specs.at(synth).add(ctrl, \freq) };
                    };
                };
            };
        };
    };
};
);

(
q.set_npvoicers = { |q synth i|
    var npvoicer = format("synth%",i+1).asSymbol;
    q[npvoicer] = q[npvoicer] ? NPVoicer( Ndef(synth) );
    // Ndef(npvoicer).resetNodeMap;
    q[npvoicer].proxy.key = synth;
    q[npvoicer].prime( synth );
    // isso a seguir funciona? Tentando controlar o número de processos ativos
    q[npvoicer][27] = \filter -> {|in| DetectSilence.ar(in, doneAction: Done.freeGroup); in};
};
);

(
q.set_knobs = { |q synth|
    q.synths_specs.at(synth).do { |value key j|
        var spec = value.asSpec;
        if (j < 7)
        {
            var kn = "kn%".format( j+1 ).asSymbol;
            var set_ctrls = format("%_%", synth, key ).asSymbol;
            // set_ctrls.postln;
            MFdef(kn).add ( set_ctrls, { |kn_val kn_prev_val|
                SoftSet( q[synth].proxy,
                    key, spec.map( kn_val ),
                    within: 0.01,
                    lastVal: spec.map( kn_prev_val ),
                    spec: spec
                );
            } ).disable(set_ctrls);
        };
    };
};
);

(
q.btns_set_knobs = { |q synth i|
    var bt = format("bt%", i+1).asSymbol;
    MFdef(bt).add ( \ctrls_on, { |btn_value|
        if ( btn_value > 0 )
        {
            q.synths_specs.at(synth).do { |value key j|
                if (j < 7)
                {
                    var kn = "kn%".format( j+1 ).asSymbol;
                    var set_ctrls = format("%_%", synth, key ).asSymbol;
                    MFdef(kn).enable(set_ctrls);
                }
            };
        }
        {
            q.synths_specs.at(synth).do { |value key j|
                if (j < 7)
                {
                    var kn = "kn%".format( j+1 ).asSymbol;
                    var set_ctrls = format("%_%", synth, key ).asSymbol;
                    MFdef(kn).disable(set_ctrls);
                }
            };
        };
    } );
};
);

(
q.btns_set_vol_knob = { |q synth i|
    var set_vol = format( "set_vol_%", synth ).asSymbol;
    var bt = format("bt%", i+1).asSymbol;
    // use last knob for volume control of current ndgui proxy:
    MFdef(\kn8).add( set_vol, { |kn_value|
        Ndef(synth).softVol_( \amp.asSpec.map(kn_value) )
    } ).disable( set_vol);
    MFdef(bt).add ( \vol_on, { |btn_value|
        if ( btn_value > 0 )
        {
            MFdef(\kn8).enable( set_vol)
        }
        {
            MFdef(\kn8).disable( set_vol)
        };
    } );
};
);

(
q.turn_synths_on = { |q synth i|
    var btb = "bt%".format(i+9).asSymbol;
    // var bta = "bt%".format(i+1).asSymbol;
    MFdef(btb).add(\synths_on, {|value|
        if (value > 0)
        {
            q.synths_on[synth] = true;
            // q.mpk.elAt(bta).value = 1;
            // MFdef(bt).funcDict//at( \ctrls_on_off)//.value //TEST
        }
        {
            q.synths_on[synth] = false;
        };
    });
};
);

(
q.ctrls_vals_specs_npv_kn_b2k_b2vol_synths = { |q synth i|
    q.get_ctrls(synth);
    q.get_default_values(synth);
    q.set_specs(synth);
    q.set_npvoicers(synth, i);
    q.set_knobs(synth);
    q.btns_set_knobs(synth, i);
    q.btns_set_vol_knob(synth, i);
    q.turn_synths_on(synth, i);
};
);
};
);
(
//set initial state
q.synths.do { |synth i|
    var npvoicer = synth; //format("synth%",i+1).asSymbol;
    q.synths_on.put( synth, false);
    q.ctrls_vals_specs_npv_kn_b2k_b2vol_synths(synth, i);
    q.synths_specs.at(synth).do { |value key j|
        var spec = value.asSpec;
        Ndef(synth).addSpec(key, spec);
    };
    q.mpk.elAt(\all, \bX).do { |el|
        el.action_{
            q[npvoicer].proxy.set( \bendFac, (el.value - 0.5 * 12))
        };
    };
};
);

(
q.update_synths = { |q synth_before i|
    // var npvoicer = synth_before; //format("synth%",i+1).asSymbol;
    var new_synth = q.tonalDefs.choose;
    if ( q.synths_before.includesEqual(new_synth) )
    {
        q.synths_before.do {|synth_before, i|
            q.update_synths(synth_before, i);
        };
        "do it again!".toUpper.postln;
    };

    if ( q.synths_on[synth_before] == false )
    {
        q.default_values[synth_before] = nil;
        postf("% <> %\n", synth_before, new_synth);
        // q[npvoicer].proxy.resetNodeMap;
        q.synths[i] = new_synth;
        // Ndef(synth_before).clear;
        q.synths_on.removeAt(synth_before);
        q.synths_on.put( new_synth, false);
        q.synths_specs.at(new_synth).do { |value key j|
            var spec = value.asSpec;
            Ndef(new_synth).addSpec(key, spec);
        };
        q.ctrls_vals_specs_npv_kn_b2k_b2vol_synths(new_synth, i);
    };
};
);

(
// Bank B 1st pad
q.mpk.elAt(\pd9, \on).action_{
    q.synths_before = q.synths;
    q.synths_before.do { | synth_before, i |
        q.update_synths(synth_before, i)
    };
};
);

(
var solta, notes = [];
var add_notes = "";
q.piano.elAt(\all, \on).do { |el, i|
    var name = ( q.allNotes.at(i) ).asSymbol;
    var note = el.elemDesc.midiNum;
    MFdef( name ).add( \note_on, { | value |
        q.synths_on.keysValuesDo{ | synth on|
            if ( on == true)
            {
                if (value > 0)
                {
                    // synth.postln;
                    // q[synth].proxy.key.postln;
                    /*fork{
                        1.do{
                            wait(20);
                            Ndef(synth).pause;
                        }
                    };*/
                    q[synth].resume;
                    q[synth].play;
                    q[synth].put(note, [\freq, note.midicps, \vel, el.value.sqrt, \amp, el.value.sqrt ]);
                    notes = notes.add(note);
                    add_notes = add_notes + notes;
                }
                {
                    q[synth].release(note, 5);
                    postf("notes: %\n", notes.size);
                    notes.remove(note);
                    add_notes = add_notes + notes;

                    // ~tidalSocket.sendMsg('/ctrl', "notes", (~notes - 60).asString);
                };
            };
        }
    })
};

);
(
Ndef(\SOStom).clear;
Ndef(\acid).clear;
Ndef(\dessur).clear;
Ndef(\default).clear;
Ndef(\grainFM_a).clear;
Ndef(\hatXLRev).clear;
Ndef(\press2).clear;
Ndef(\rain).clear;
);
