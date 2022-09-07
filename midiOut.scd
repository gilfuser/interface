fork{
    MIDIClient.init;    // if not already done
    s.sync;
    5.wait;
    m = MIDIOut(0);  // use virtual source port "out0"
    0.2.wait;
    m.connect(2);  // connect to MIDIClient.destinations[1]
    0.2.wait;
    m.latency = 0;
    wait(0.2);
Pbind(\type, \midi, \midiout, m, \degree, Prand([1, 2, 3, [0, 5]], 32), \bend, Pwhite(0, 76, inf)).play;
}

