(
var choose_synths = q.tonalDefs.scramble.keep(8);

q.synths = choose_synths;
q.synthsOn = ();
q.synths_before = q.synths;
q.synthsDefautVals = ();
// q.synthsSpecs = ();

q.ctrls_names_values = { |q synth ctrls |
    var namesVals = SynthDescLib.at(synth).defaultNamesVals;
    var names_values_array = [];
    var namesValsDict = Dictionary.newFrom( namesVals );
    ctrls.do{|name|
        names_values_array = names_values_array.add (
            namesValsDict.associationAt( name ) );
    };
    q.synthsDefautVals.put( synth, names_values_array );
    // q.synthsSpecs.put( synth, synth_specs );
};


q.set_npvoicers = { |q synth ctrls i|
    var npvoicer = format("synth%",i+1).asSymbol;

    q[npvoicer] = q[npvoicer] ? NPVoicer( Ndef(npvoicer) );
    Ndef(npvoicer).resetNodeMap;
    q.ctrls_names_values( synth, ctrls );
    q[npvoicer].proxy.key = synth;
    q[npvoicer].prime( synth );
    q.synthsDefautVals.keysValuesDo{|name, defaultVals|
        if ( q[npvoicer].proxy.key == name )
        {
            defaultVals.do{ |pair|
                q[npvoicer].proxy.set(pair.key, pair.value)
            }
        }
    };
    /*synth_specs.keysValuesDo{|spec, values|
    q[npvoicer].proxy.addSpec(spec, values);
    };*/
};

q.synths.do{ |synth i|
    var npvoicer = format("synth%",i+1).asSymbol;
    var set_npv_vol = format("setVol_%", npvoicer).asSymbol;
    var ctrls = SynthDescLib.at(synth).controlNames;
    [\out, \freq, \amp, \t_trig, \trig, \gate, \t_gate, \bendFac ].do { |notThis|
        ctrls = ctrls.reject {|ctrl| ( ctrl == notThis ) }
    };
    q.synthsOn.put( npvoicer, false);
    q.set_npvoicers(synth, ctrls, i);
    // use last knob for volume control of current ndgui proxy:
    MFdef(\kn8).add( set_npv_vol, { |kn_value|
        q[npvoicer].proxy.softVol_( \amp.asSpec.map(kn_value) )
    } );
    MFdef(\kn8).disable( set_npv_vol);
    q.mpk.elAt(\all, \bX).do { |el|
        el.action_{ q[npvoicer].proxy.set( \bendFac, (el.value - 0.5 * 12) ) };
    };
};

q.update_synths = { |q synth_before i|
    var npvoicer = format("synth%",i+1).asSymbol;
    var synth = q.tonalDefs.choose;
    var set_ctrls, spec, kn;
    var synth_specs = SynthDescLib.at(synth).specs;
    var ctrls = SynthDescLib.at(synth).controlNames;
    [\out, \freq, \amp, \t_trig, \trig, \gate, \t_gate, \bendFac ].do { |notThis|
        ctrls = ctrls.reject {|ctrl| ( ctrl == notThis ) }
    };

    if ( q.synths_before.includesEqual(synth) )
    {
        q.vai = q.vai + 1;
        q.synths_before.do {|synth_before, i| q.update_synths(synth_before, i) };
        "do it again!".toUpper.postln;
    };
    if ( q.synthsOn[npvoicer] == false )
    {
        q.synthsDefautVals[synth_before] = nil;
        q.set_npvoicers(synth, ctrls, i);
        postf("% <> %\n", synth_before, synth);
        q[npvoicer].proxy.resetNodeMap;
        q.synths[i] = synth;
        q.set_btn_to_knob_ctrls(synth, i);
    };
};

q.set_btn_to_knob_ctrls = { |q synth i|

    var ctrls = SynthDescLib.at(synth).controlNames;
    var bt = "bt%".format(i+1).asSymbol;
    var set_ctrls = format("setCtrls_%", i+1).asSymbol;
    var set_npv_vol = format("setVol_%", npvoicer).asSymbol;
    var npvoicer = format("synth%",i+1).asSymbol;

    MFdef(bt).add (\ctrlsOnOff, { |onOff|
        if (onOff > 0)
        {
            var synth_specs = SynthDescLib.at(synth).specs;
            var namesVals = SynthDescLib.at(synth).defaultNamesVals;
            var namesValsDict = Dictionary.newFrom( namesVals );
            [\out, \freq, \amp, \t_trig, \trig, \gate, \t_gate, \bendFac ].do { |notThis|
                ctrls = ctrls.reject {|ctrl| ( ctrl == notThis ) }
            };
            ctrls.do { |ctrl j|
                var spec = synth_specs.at(ctrl).asSpec;
                var kn = "kn%".format( j+1 ).asSymbol;
                MFdef(kn).enable(set_ctrls);
                q[ npvoicer ].proxy.set( ctrl, namesValsDict.at(ctrl) );
                if ( j < 7 )
                {
                    if ( synth_specs.at(ctrl).notNil )
                    {
                        q[ npvoicer ].proxy.addSpec( ctrl, spec );
                        MFdef(kn).add( set_ctrls, { |kn_val|
                            q[ npvoicer ].proxy.softSet( ctrl,
                                spec.map(kn_val),
                                within: 0.025,
                                lastVal: spec.map( q.mpk.elAt(kn).prevValue )
                            );
                        });
                        postf( "\n% is in SynthDef specs\n%\n", ctrl, spec );
                    }
                    {
                        if ( Spec.specs.at(ctrl).notNil )
                        {
                            MFdef(kn).add( set_ctrls, { |kn_val|
                                q[ npvoicer ].proxy.softSet( ctrl,
                                    ctrl.asSpec.map( kn_val ),
                                    within: 0.025,
                                    lastVal: spec.map( q.mpk.elAt(kn).prevValue )
                                );
                            });
                            postf( "\n% is in Specs dict\n", ctrl );
                            Spec.specs.at( ctrl ).postln;
                        }
                        {
                            format("\nYOU NEED TO CREATE A SPEC FOR %\nFROM SYNTHDEF %\n", ctrl, synth).toUpper.warn;
                        };
                    };
                };
            };
            MFdef(\kn8).enable( set_npv_vol );
        }
        {
            ctrls.do { |ctrl j|
                var kn = "kn%".format( j+1 ).asSymbol;
                if (j < 7)
                {
                    MFdef(kn).disable(set_ctrls);
                }
            };
            MFdef(\kn8).disable( set_npv_vol);
        };
    });
};

q.mpk.elAt(\pd9, \on).action_{
    q.vai = 0;
    q.synths_before = q.synths;
    q.synths_before.do {|synth_before, i| q.update_synths(synth_before, i) };
};

q.btns.drop(8).keep(8).do { |el, i|
    var npvoicer = format("synth%",i+1).asSymbol;
    var bt = "bt%".format(i+9).asSymbol;
    var bta = "bt%".format(i+1).asSymbol;
    MFdef(bt).add(\synthsOn, {|el|
        if (el.value > 0)
        {
            q.synthsOn[npvoicer] = true;
            MFdef(bta).enable(\ctrlsOnOff);
        }
        {
            q.synthsOn[npvoicer] = false;
            MFdef(bta).disable(\ctrlsOnOff);
        };
    });
};

q.piano.elAt(\all, \on).do { |el, i|
    MFdef( format("pkey%",i).asSymbol ).add( \note_on_off, {|note value|
        q.synthsOn.keysValuesDo{ | npvoicer on|
            if ( on == true)
            {
                if (value > 0)
                {
                    q[npvoicer].play;
                    q[npvoicer].put( note, [ \freq, note.midicps, \amp, value.squared ] );
                }
                { q[npvoicer].release( note ) }
            };
        }
    })
};

)