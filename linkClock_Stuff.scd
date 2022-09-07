// https://scsynth.org/t/linkclock-tempobusclock-linkbusclock/6145
fork{
    "cd /home/skmecs/Carabiner && ./Carabiner".runInTerminal;
    s.sync;
    0.2.wait;
    t = t ? TempoClock.default;
    l = l ? LinkClock.new.latency_(s.latency).permanent_(true);
    s.sync;
    wait(0.1);
    t = l;
    0.1.wait;
    SynthDef(\krClick, { |out, beatsPerSec = 1, beats = 1, subdiv = 4|
        var click = Impulse.kr(beatsPerSec * subdiv);
        var count = PulseCount.kr(click);
        FreeSelf.kr(Delay1.kr(count >= (subdiv * beats)));
        Out.kr(out, click);
    }).add;
    0.1.wait;
    Ndef(\click, { DC.kr(0) }).quant_(1).clock_(l);
    0.1.wait;
    if (p != nil)
    {
        var ctl;
        p.push;
        ~tempo = l.tempo;  // numeric proxy

        ctl = SimpleController(l)
        .put(\tempo, { ~tempo = l.tempo })
        .put(\stop, { ctl.remove });

        Ndef(\click, Pbind(
            \instrument, \krClick,
            \beatsPerSec, ~tempo.bus.asMap,
            \subdiv,1,
            \dur, 1,
        ));
        ">>> access tempo proxy: ~tempo.kr in synths \n>>> or ~tempo.bus.asMap in patterns <<<\n".postString;
    }
    {
        var ctl;
        Ndef(\tempo, l.tempo);  // numeric proxy

        ctl = SimpleController(l)
        .put(\tempo, { Ndef(\tempo, l.tempo) })
        .put(\stop, { ctl.remove });

        Ndef(\click, Pbind(
        \instrument, \krClick,
        \beatsPerSec, Ndef(\tempo).bus.asMap,
        \dur, 1
        ));
        ">>> access tempo proxy: Ndef(\\tempo).kr in synths \n>>> or Ndef(\\tempo).bus.asMap in patterns <<<".postln;
    };
};
"***** linkClock Stuff loaded. *****\n*** Acess control click through Ndef(\\click).kr ***\n".postString
