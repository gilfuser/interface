fork{
    MIDIClient.init;    // if not already done
    s.sync;
    5.wait;
    m = MIDIOut(0, MIDIClient.destinations.at(1).uid);
    0.2.wait;
    m.latency = 0;
    wait(0.2);
x = Pbind(\type, \midi, \midiout, m, \degree, Prand([1, 2, 3, [0, 5]], 32), \bend, Pwhite(0, 76, inf), \dur, 0.25).play;
}

