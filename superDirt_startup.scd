// q.sampleFamilyFolders is in libs/_SampleLib.scd
q = q ? ();
/*
"cd /home/skmecs/tidal && nvim start.tidal".runInTerminal;
"cd /home/skmecs/tidal && echo \"sock <- carabiner tidal 4 (-0.14)\n\nsendMsg sock \"bpm 155\"\" > start.tidal".runInTerminal;
*/

q.addedSynthDefs = q.addedSynthDefs ? SynthDescLib.global.synthDescs.keys;

q.number_of_orbits = q.number_of_orbits ? 8; // escolher quantas orbits serão usadas em Ndefs

if ( currentEnvironment.class == ProxySpace ) { topEnvironment.push };
{
    0.2.wait;
    if (~dirt != nil ) {
        ~dirt.stop; ~dirt.freeAllSoundFiles; ~dirt.free; ~dirt = nil; "reseting ~dirt".postln
    };
    ~dirt = SuperDirt(2, s);
    q.orbits_out_chans = Array.fill ( q.number_of_orbits, { |i| 2 + (i * 2) } );
    ~dirt.start( 57120, q.orbits_out_chans, NetAddr("0.0.0.0") );
    0.2.wait;

    ">>>>>> check point from SuperDirt Startup <<<<<<".postln;

    "~/SuperCollider/instruments/tidalInstruments.scd".standardizePath.load;

    wait(1);
    "~/SuperCollider/FX/myTidalFx.scd".standardizePath.load;

    /*
    q.orb0 =  ~dirt.orbits[0];
    Ndef(\orb0).play(0);
    Ndef(\orb0).proxyspace.quant_(1);
    Ndef(\orb0).proxyspace.clock_(t);
    q.orb0.outBus = Ndef(\orb0).bus;
    Ndef(\orb0).vol_(0.5);
    */
    0.2.wait;
    (

        Task {
            ( q.number_of_orbits ).do { |i|
                // var j = i + 1;
                var orbit = format("orb%",i).asSymbol;
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
                    ( Ndef(\orb0).ar * \amp0.kr(1, spec:\ampx4.asSpec) ) +
                    ( Ndef(\orb1).ar * \amp1.kr(1, spec:\ampx4.asSpec) ) +
                    ( Ndef(\orb2).ar * \amp2.kr(1, spec:\ampx4.asSpec) ) +
                    ( Ndef(\orb3).ar * \amp3.kr(1, spec:\ampx4.asSpec) ) +
                    ( Ndef(\orb4).ar * \amp4.kr(1, spec:\ampx4.asSpec) ) +
                    ( Ndef(\orb5).ar * \amp5.kr(1, spec:\ampx4.asSpec) ) +
                    ( Ndef(\orb6).ar * \amp6.kr(1, spec:\ampx4.asSpec) ) +
                    ( Ndef(\orb7).ar * \amp7.kr(1, spec:\ampx4.asSpec) )
                );
            }).play.vol_(0.5);
        }.play;
    );

    wait(8);

    if (q.sampleFamilyFolders == nil) {
        "THERE WAS A PROBLEM IN THE _SAMPLIB LOAD SAMPLES FILE".warn;'';
        ~dirt.loadSoundFiles;
        q.ds = ~dirt.buffers.keys;
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
        ~dirt.loadSoundFiles("/home/skmecs/Samples/drumset/*");
        q.ds_drums = ~dirt.buffers.keys - q.ds;
        q.ds_drumset = {q.postSampleInfo(q.ds_drums)};
        ~dirt.loadSoundFiles("/home/skmecs/Samples/airstrip/*");
        q.ds_airs = ~dirt.buffers.keys - q.ds - q.ds_drums;
        q.ds_airstrip = {q.postSampleInfo(q.ds_airs)};
        ~dirt.loadSoundFiles("/home/skmecs/Samples/samples-extra/*");
        q.ds_xtra = ~dirt.buffers.keys - q.ds - q.ds_drums - q.ds_airs;
        q.ds_extra = {q.postSampleInfo(q.ds_xtra)};
        ~dirt.loadSoundFiles("/home/skmecs/Samples/brazilperc/*");
        q.ds_br = ~dirt.buffers.keys - q.ds - q.ds_drums - q.ds_airs - q.ds_xtra;
        q.ds_brasil = {q.postSampleInfo(q.ds_br)};
        ~dirt.loadSoundFiles("/home/skmecs/Samples/skmecs/*");
        q.ds_skm = ~dirt.buffers.keys - q.ds - q.ds_drums - q.ds_airs - q.ds_xtra - q.ds_br;
        q.ds_skmecs = {q.postSampleInfo(q.ds_skm)};
        ~dirt.loadSoundFiles("/home/skmecs/Samples/dirtedit/*");
        q.ds_ed = ~dirt.buffers.keys - q.ds - q.ds_drums - q.ds_airs - q.ds_xtra - q.ds_br - q.ds_skm;
        q.ds_edit = {q.postSampleInfo(q.ds_ed)};
        ~dirt.loadSoundFiles("/home/skmecs/Samples/bpm110/*");
        q.ds_b110 = ~dirt.buffers.keys - q.ds - q.ds_drums - q.ds_airs - q.ds_xtra - q.ds_br - q.ds_skm - q.ds_ed;
        q.ds_bpm110 = {q.postSampleInfo(q.ds_b110)};
        ~dirt.loadSoundFiles("/home/skmecs/Samples/tr808/*");
        q.ds_808 = ~dirt.buffers.keys - q.ds - q.ds_drums - q.ds_airs - q.ds_xtra - q.ds_br - q.ds_skm - q.ds_ed - q.ds_b110;
        q.ds_tr808 = {q.postSampleInfo(q.ds_808)};
        ~dirt.loadSoundFiles("/home/skmecs/Samples/THAT.SOUND.ORGANIC.PERCUSSION.(SCENE)-DISCOVER/ONE SHOTS/BASS DRUMS/*");
        ~dirt.loadSoundFiles("/home/skmecs/Samples/THAT.SOUND.ORGANIC.PERCUSSION.(SCENE)-DISCOVER/ONE SHOTS/BRUSH SNARE/*");
        ~dirt.loadSoundFiles("/home/skmecs/Samples/THAT.SOUND.ORGANIC.PERCUSSION.(SCENE)-DISCOVER/ONE SHOTS/CABASSA/*");
        ~dirt.loadSoundFiles("/home/skmecs/Samples/THAT.SOUND.ORGANIC.PERCUSSION.(SCENE)-DISCOVER/ONE SHOTS/RATTLIN/*");
        ~dirt.loadSoundFiles("/home/skmecs/Samples/THAT.SOUND.ORGANIC.PERCUSSION.(SCENE)-DISCOVER/ONE SHOTS/SHAKERS/*");
        ~dirt.loadSoundFiles("/home/skmecs/Samples/THAT.SOUND.ORGANIC.PERCUSSION.(SCENE)-DISCOVER/ONE SHOTS/STICKS AND SNARES/*");
        ~dirt.loadSoundFiles("/home/skmecs/Samples/THAT.SOUND.ORGANIC.PERCUSSION.(SCENE)-DISCOVER/ONE SHOTS/TAMBOS/*");
        q.ds_op = ~dirt.buffers.keys - q.ds - q.ds_drums - q.ds_airs - q.ds_xtra - q.ds_br - q.ds_skm - q.ds_ed - q.ds_b110 - q.ds_808;
        q.ds_organic = {q.postSampleInfo(q.ds_op)};
    } {

        Task{
            if ( q.sampleFamilyFolders.notNil )
            {
                if ( q.sampleFamilyFolders.notEmpty )
                {
                    q.sampleFamilyFolders.do { |pa|
                        ~dirt.loadSoundFiles(pa, appendToExisting: true);
                    };
                    q.sampleFamilyFolders.do { |pa|
                        ~dirt.loadSoundFiles((pa++"/*"),
                            appendToExisting: true);
                    };
                }
            };
        }.play;
    };
    wait(1);
    // start superdirt first
    (
        { var clockMods, clockBeats, screenW, screenH, clockW, clockH, clockX, clockY, resizable, border;

            clockMods = [4,6];
            clockBeats = 4;
            screenW = 1440;
            screenH = 900;
            clockW = 120;
            clockH = 22;
            clockX = screenW - clockW;
            clockY = screenH - 1;
            resizable = false;
            border = false;

            ~clockText = StaticText()
            .string_("[clock]")
            .font_(Font.defaultMonoFace)
            .align_(\center)
            .stringColor_(Color(1,1,1))
            .minHeight_(20);

            ~updateClock = { |cycle|
                var text, beat;
                text = clockMods.collect { |m| "" ++ (cycle.floor.asInteger.mod(m) + 1) ++ "/" ++ m; }.join(" ");
                beat = (cycle.mod(1)*clockBeats).round.asInteger + 1;
                text = text ++ " " ++ clockBeats.collect { |i| if(i < beat, ".", " "); }.join;
                ~clockText.string_(text);
            };

            ~clockWindow = Window("clock", Rect(clockX, clockY, clockW, clockH), resizable, border)
            .background_(Color(0.3,0.3,0.3))
            .layout_(
                HLayout(
                    ~clockText
                ).margins_(0!4)
            );

            ~clockWindow.alwaysOnTop_(true);
            ~clockWindow.visible_(true);

            SynthDef(\tick, { |cycle|
                SendReply.kr(Impulse.kr(0), "/tick", [cycle]);
                FreeSelf.kr(Impulse.kr(0));
            }).add;

            OSCdef(\tick, { |msg|
                var cycle;
                #cycle = msg[3..];
                Routine {
                    { ~updateClock.(cycle); }.defer;
                }.play(SystemClock);
            }, "/tick");
            Ndef(\allOrbs).gui;
        }.defer(1);
    );

    "super-dirt prepared".postln;
    "check all FX and synths with q.print_dirt_stuff_params".postln;
    "check all FX and synths and their parameters with q.print_dirt_stuff_params".postln;
}.fork;
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
q.print_dirt_stuff_params;
q.print_samples = {"print samples set with:\n%\n%\n%\n%\n%\n%\n%\n%\n%\n%\n%\n".postf("q.ds_default", "q.ds_drumset", "q.ds_airstrip", "q.ds_extra", "q.ds_brasil", "q.ds_skmecs", "q.ds_edit", "q.ds_bpm110", "q.ds_tr808", "q.ds_organic", "q.print_samples");''};
q.print_samples;
);

// q.ds_default