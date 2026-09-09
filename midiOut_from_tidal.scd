({
    MIDIClient.init;
    s.sync;
    0.2.wait;
    Platform.case(
        \osx,       { "OSX".postln },
        \linux,     { m = MIDIOut.newByName("Midi Through", "Midi Through Port-0"); },
        \windows,   { m = MIDIOut.newByName("loopMIDI Port", "loopMIDI Port"); }
        // \windows,   { m = MIDIOut.newByName("midi_base (A)", "midi_base (A)"); }
    );
    ~dirt.soundLibrary.addMIDI(\midiout, m);
    m.latency = 0;
}.fork;)
