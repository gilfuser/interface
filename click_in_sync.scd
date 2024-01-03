// https://scsynth.org/t/linkclock-tempobusclock-linkbusclock/6145
fork{
    var ctl;
    s.sync;
    0.2.wait;
    p = p ?? ProxySpace;
    0.2.wait;
    p.know = true;
    t = t ? TempoClock.default;
    l = l ? LinkClock.new.latency_(s.latency).permanent_(true);
    s.sync;
    wait(0.1);
    t = l;
    wait(0.1);
    p.tempo = t.tempo;  // numeric proxy
    0.1.wait;
    SynthDef(\krClick, { |out, beatsPerSec = 1, beats = 1, subdiv = 4|
        var click = Impulse.kr(beatsPerSec * subdiv);
        var count = PulseCount.kr(click);
        FreeSelf.kr(Delay1.kr(count >= (subdiv * beats)));
        Out.kr(out, click);
    }).add;
    0.1.wait;
    Ndef(\click, { DC.kr(0) }).quant_(1).clock_(t);
    0.1.wait;

    ctl = SimpleController(t)
    .put(\tempo, { p.tempo = t.tempo })
    .put(\stop, { ctl.remove });

    Ndef(\click, Pbind(
        \instrument, \krClick,
        \beatsPerSec, p.tempo.bus.asMap,
        \subdiv,4,
        \dur, 1,
    ));
/*    0.1.wait;
    p.click.clear;
    0.1.wait;
    p.click.kr;
    0.1.wait;
    p.click = Pbind(
        \instrument, \krClick,
        \beatsPerSec, p.tempo.bus.asMap,
        \subdiv,1,
        \dur, 1,
    );*/
    /*
    0.1.wait;
    p.click2.clear;
    0.1.wait;
    p.click2.kr;
    0.1.wait;
    p.click2 = Pbind(
        \instrument, \krClick,
        \beatsPerSec, p.tempo.bus.asMap,
        \subdiv,3,
        \dur, 1,
    );
    0.1.wait;
    p.click3.clear;
    0.1.wait;
    p.click3.kr;
    0.1.wait;
    p.click3 = Pbind(
        \instrument, \krClick,
        \beatsPerSec, p.tempo.bus.asMap,
        \subdiv,3,
        \dur, 1,
    );
    0.1.wait;
    p.click4.clear;
    0.1.wait;
    p.click4.kr;
    0.1.wait;
    p.click4 = Pbind(
        \instrument, \krClick,
        \beatsPerSec, p.tempo.bus.asMap,
        \subdiv,4,
        \dur, 1,
    );*/

    ">>> access tempo proxy: ~tempo.kr in synths \n>>> or ~tempo.bus.asMap in patterns <<<\n".postString;
    /*{
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
    };*/
};
"***** linkClock Stuff loaded. *****\n*** Acess control click through Ndef(\\click).kr ***\n".postString
