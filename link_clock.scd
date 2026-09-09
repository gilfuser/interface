// https://scsynth.org/t/linkclock-tempobusclock-linkbusclock/6145
(
fork{

    s.sync;

    s.latency = 0.2;

    {
        Routine{
            t = t ? TempoClock.default;
            0.1.wait;
            l = l ? LinkClock.new;
            0.1.wait;
            l.latency_(s.latency);
            0.1.wait;
            l.permanent_(true);
            0.1.wait;
            l.quantum = 4;
            0.1.wait;
            s.sync;
            0.1.wait;
            s.sync;
            t = l;
            t.sched(0.2, {l.beatsPerBar = 4});
        }.play;
    }.defer(1);

    /*
0.1.wait;

    SynthDef(\krClick,{  |out, beatsPerSec = 1, beats = 1, subdiv = 4|
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
        if (currentEnvironment == topEnvironment)
        {p.push;};
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
*/
"***** linkClock Stuff loaded. *****\n*** Acess control click through Ndef(\\click).kr ***\n".postString
};
)