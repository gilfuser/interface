q = q ? ();

q.addedSynthDefs = q.addedSynthDefs ? SynthDescLib.global.synthDescs.keys;

q.number_of_orbits = q.number_of_orbits ? 8; // escolher quantas orbits serão usadas em Ndefs

if ( currentEnvironment.class == ProxySpace ) { topEnvironment.push };
fork{

    0.2.wait;
    if (~dirt != nil ) {
        ~dirt.stop; ~dirt.freeAllSoundFiles; ~dirt.free; ~dirt = nil; "reseting ~dirt".postln
    };
    ~dirt = SuperDirt(2, s);
    q.orbits_out_chans = Array.fill ( q.number_of_orbits, { |i| 2 + (i * 2) } );
    ~dirt.start( 57120, q.orbits_out_chans, NetAddr("0.0.0.0") );
    0.2.wait;

    ">>>>>> check point from SuperDirt Startup <<<<<<".postln;

    "~/SuperCollider/instruments/01b_my_tidal_instruments.scd".standardizePath.load;
    wait(1);
    "~/SuperCollider/FX/01c_my_tidal_fx.scd".standardizePath.load;

    0.2.wait;
    (

        Task {
            ( q.number_of_orbits ).do { |i|
                 var j = i + 1;
                var orbit = format("orb%",j).asSymbol;
                q[ orbit ] = ~dirt.orbits[i];
                wait(0.05);
                Ndef( orbit ).ar(2);
                wait(0.05);
                Ndef( orbit ).proxyspace.quant_(1).clock_(t);
                wait(0.05);
                q[ orbit ].outBus = Ndef( orbit ).bus;
                wait(0.05);
                Ndef( orbit ).play( q.orbits_out_chans[i] );
                wait(0.05);
                Ndef( orbit ).vol_(0.5);
                wait(0.05);
            };
            Ndef( \allOrbs, {
                Limiter.ar(
                    ( Ndef(\orb1).ar * \amp1.kr(1, spec:\ampx4.asSpec) ) +
                    ( Ndef(\orb2).ar * \amp2.kr(1, spec:\ampx4.asSpec) ) +
                    ( Ndef(\orb3).ar * \amp3.kr(1, spec:\ampx4.asSpec) ) +
                    ( Ndef(\orb4).ar * \amp4.kr(1, spec:\ampx4.asSpec) ) +
                    ( Ndef(\orb5).ar * \amp5.kr(1, spec:\ampx4.asSpec) ) +
                    ( Ndef(\orb6).ar * \amp6.kr(1, spec:\ampx4.asSpec) ) +
                    ( Ndef(\orb7).ar * \amp7.kr(1, spec:\ampx4.asSpec) ) +
                    ( Ndef(\orb8).ar * \amp8.kr(1, spec:\ampx4.asSpec) )
                );
            }).play.vol_(0.5);
        }.play;
    );

    wait(8);

        /* ~dirt.loadSoundFiles;
        q.ds = ~dirt.buffers.keys; */
        (
            q.postSampleInfo = { |ev buffers|
                var keys = buffers.asArray.sort;
                keys.do { |name|
                    var all = ~dirt.buffers[name];
                    "% (%)   % - % sec (% kB)\n".postf(
                        name,
                        ~dirt.buffers[name].size,
                        all.minItem { |x| x.duration }.duration.round(0.01),
                        all.maxItem { |x| x.duration }.duration.round(0.01),
                        all.sum { |x| x.memoryFootprint } div: 1e3
                    )
                }; ''.postln;
            };
        );
        q.ds_default = {q.postSampleInfo(q.ds)};
        ~dirt.loadSoundFiles("~/Samples/drumset/*");
        q.ds_drums = ~dirt.buffers.keys - q.ds;
        q.ds_drumset = {q.postSampleInfo(q.ds_drums)};
        ~dirt.loadSoundFiles("~/Samples/airstrip/*");
        q.ds_airs = ~dirt.buffers.keys - q.ds - q.ds_drums;
        q.ds_airstrip = {q.postSampleInfo(q.ds_airs)};
        ~dirt.loadSoundFiles("~/Samples/samples-extra/*");
        q.ds_xtra = ~dirt.buffers.keys - q.ds - q.ds_drums - q.ds_airs;
        q.ds_extra = {q.postSampleInfo(q.ds_xtra)};
        ~dirt.loadSoundFiles("~/Samples/brazilperc/*");
        q.ds_br = ~dirt.buffers.keys - q.ds - q.ds_drums - q.ds_airs - q.ds_xtra;
        q.ds_brasil = {q.postSampleInfo(q.ds_br)};
        ~dirt.loadSoundFiles("~/Samples/skmecs/*");
        q.ds_skm = ~dirt.buffers.keys - q.ds - q.ds_drums - q.ds_airs - q.ds_xtra - q.ds_br;
        q.ds_skmecs = {q.postSampleInfo(q.ds_skm)};
        ~dirt.loadSoundFiles("~/Samples/dirtedit/*");
        q.ds_ed = ~dirt.buffers.keys - q.ds - q.ds_drums - q.ds_airs - q.ds_xtra - q.ds_br - q.ds_skm;
        q.ds_edit = {q.postSampleInfo(q.ds_ed)};
        ~dirt.loadSoundFiles("~/Samples/bpm110/*");
        q.ds_b110 = ~dirt.buffers.keys - q.ds - q.ds_drums - q.ds_airs - q.ds_xtra - q.ds_br - q.ds_skm - q.ds_ed;
        q.ds_bpm110 = {q.postSampleInfo(q.ds_b110)};
        ~dirt.loadSoundFiles("~/Samples/tr808/*");
        q.ds_808 = ~dirt.buffers.keys - q.ds - q.ds_drums - q.ds_airs - q.ds_xtra - q.ds_br - q.ds_skm - q.ds_ed - q.ds_b110;
        q.ds_tr808 = {q.postSampleInfo(q.ds_808)};
        ~dirt.loadSoundFiles("~/Samples/THAT.SOUND.ORGANIC.PERCUSSION.(SCENE)-DISCOVER/ONE SHOTS/BASS DRUMS/*");
        ~dirt.loadSoundFiles("~/Samples/THAT.SOUND.ORGANIC.PERCUSSION.(SCENE)-DISCOVER/ONE SHOTS/BRUSH SNARE/*");
        ~dirt.loadSoundFiles("~/Samples/THAT.SOUND.ORGANIC.PERCUSSION.(SCENE)-DISCOVER/ONE SHOTS/CABASSA/*");
        ~dirt.loadSoundFiles("~/Samples/THAT.SOUND.ORGANIC.PERCUSSION.(SCENE)-DISCOVER/ONE SHOTS/RATTLIN/*");
        ~dirt.loadSoundFiles("~/Samples/THAT.SOUND.ORGANIC.PERCUSSION.(SCENE)-DISCOVER/ONE SHOTS/SHAKERS/*");
        ~dirt.loadSoundFiles("~/Samples/THAT.SOUND.ORGANIC.PERCUSSION.(SCENE)-DISCOVER/ONE SHOTS/STICKS AND SNARES/*");
        ~dirt.loadSoundFiles("~/Samples/THAT.SOUND.ORGANIC.PERCUSSION.(SCENE)-DISCOVER/ONE SHOTS/TAMBOS/*");
        q.ds_op = ~dirt.buffers.keys - q.ds - q.ds_drums - q.ds_airs - q.ds_xtra - q.ds_br - q.ds_skm - q.ds_ed - q.ds_b110 - q.ds_808;
        q.ds_organic = {q.postSampleInfo(q.ds_op)};
        ~dirt.loadSoundFiles("~/Samples/invocation/*");
        q.ds_invocation = ~dirt.buffers.keys - q.ds_op;
        q.ds_invoca = {q.postSampleInfo(q.ds_invocation)};

(
q.print_dirt_stuff = {
    ( SynthDescLib.global.synthDescs.keys - q.addedSynthDefs ).
    asArray.sort.do { |key|
        // clean synthDefs names as e.g. '_dirt_squiz' and get only 'squiz'
        // as they are in ~dirt.modules
        key = key.asString;
        if ( key.beginsWith("dirt_") ) { key = key.replace("dirt_", "")};
        if (key.find("_").notNil) {
            var index = key.find("_");
            // the following if is just because of dirt_pitch_shift2 and dirt_sample_long_1_2
            if ( key.at(index+1).asString != "l" and: ( key.at(index+1).asString != "s" ) ) {
                while {index < key.size} {key.takeAt(index)}
            };
        };
        key.postln;
    };
    '';
};
q.print_dirt_stuff;
);
(
q.print_dirt_stuff_params = {
    ( SynthDescLib.global.synthDescs.keys - q.addedSynthDefs ).
    asArray.sort.keysValuesDo { |key|
        var desc = SynthDescLib.match(key).controls;
        key = key.asString;
        if ( key.beginsWith("dirt_") ) { key = key.replace("dirt_", "")};
        if (key.find("_").notNil) {
            var index = key.find("_");
            if ( key.at(index+1).asString != "l" and: (
                key.at(index+1).asString != "s" ) ) {
                while {index < key.size} {key.takeAt(index)}
            };
        };
        postf("% ->", key);
        desc.do { |ctr|
            if (ctr.name != \out) {
                postf(", % %", ctr.name, ctr.defaultValue.round(0.01));
            }
        };
        ".\n".postln;
    };
    '';
};

    "super-dirt prepared".postln;
    "check all FX and synths with:\n q.print_dirt_stuff_params\n".postln;
    "check all FX and synths AND their parameters with:\n q.print_dirt_stuff_params".postln;
q.print_dirt_stuff_params;
q.print_samples = {"print samples set with:\n%\n%\n%\n%\n%\n%\n%\n%\n%\n%\n%\n%\n".postf("q.ds_default", "q.ds_drumset", "q.ds_airstrip", "q.ds_extra", "q.ds_brasil", "q.ds_skmecs", "q.ds_edit", "q.ds_bpm110", "q.ds_tr808", "q.ds_organic", "q.ds_invoca", "q.print_samples");''};
q.print_samples;
);
    };
// q.ds_default;
