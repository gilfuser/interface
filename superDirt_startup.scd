q = q ? ();
"cd /home/skmecs/tidal && nvim start.tidal".runInTerminal;
/*
"cd /home/skmecs/tidal && echo \"sock <- carabiner tidal 4 (-0.14)\n\nsendMsg sock \"bpm 155\"\" > start.tidal".runInTerminal;
*/
q.numOrbs = q.numOrbs ? 4; // escolher quantas orbits serão usadas em Ndefs
// q.sampleFamilyFolders is in libs/_SampleLib.scd

{
    if (p.class==ProxySpace) {p.pop};
    if (~dirt != nil ) { ~dirt.stop; ~dirt.freeAllSoundFiles; ~dirt.free; "reseting ~dirt".postln };
    0.1.wait;
    ~dirt = SuperDirt(s.options.numOutputBusChannels, s);
    0.1.wait;

    if (q.sampleFamilyFolders == nil) {
        "THERE WAS A PROBLEM IN THE _SAMPLIB LOAD SAMPLES FILE".warn;'';
        ~dirt.loadSoundFiles;
    } {

        Task({
            if (q.sampleFamilyFolders.notEmpty)
            {
                q.sampleFamilyFolders.do { |pa|
                    ~dirt.loadSoundFiles(pa, appendToExisting: true);
                    0.2.wait;
                };
                0.2.wait;
                q.sampleFamilyFolders.do { |pa|
                    ~dirt.loadSoundFiles((pa++"/*"),
                        appendToExisting: true);
                    0.2.wait;
                };
            };
        }).play;
    };
    10.wait;
    ">>>>>> check point <<<<<<".postln;
    s.sync;
    1.wait;
    fork{
        var orbArr = Array.fill( q.numOrbs, {|i| 2 + (i * 2) } );
        ~dirt.start(57120, (orbArr));
        0.5.wait;
        ~dirt.loadSynthDefs("~/SuperCollider/instruments/tidalInstruments.scd");
        q.numOrbs.do{|i|
            q[format("orb%",i).asSymbol] = ~dirt.orbits[i];
            Ndef(format("orb%",i).asSymbol).ar(~dirt.numChannels);
            wait(0.1);
            Ndef(format("orb%",i).asSymbol).proxyspace.quant_(1);
            wait(0.1);
            Ndef(format("orb%",i).asSymbol).proxyspace.clock_(t);
            q[format("orb%",i).asSymbol].outBus = Ndef(format("orb%",i).asSymbol).bus;
            wait(0.1);
            Ndef(format("orb%",i).asSymbol).play/*( 4 + (i * 2) )*/;
            Ndef(format("orb%",i).asSymbol).vol_(0.5);
            wait(0.1);
            // Ndef(\allOrbs, {
            // var in = [ InFeedback.ar( orbArr + 2 ,1), InFeedback.ar( orbArr + 3 ,1) ];
            // OffsetOut.ar(0, in)
            // }).play;
        };
    };
    1.wait;
    "super-dirt prepared".postln;
}.fork;
