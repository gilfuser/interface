~dirt.loadSoundFiles(Platform.userAppSupportDir +/+ "downloaded-quarks" +/+ "Dirt-Samples/*");
q = q ? ();
(
// Connect to ALSA port (check with `MIDIClient.init; MIDIClient.sources`)
MIDIClient.init;
~midiOut = MIDIOut.newByName("FLUID Synth (1578)", "Synth input port (1578:0)", 8388608);

// Filter Tidal events
~dirt.orbits.do { |o|
    o.event = o.event.addDependant({ |event|
        var snd = event[\sound];
        if(snd.notNil and: { snd.asString.beginsWith("gm_") }) {
            // Block normal Dirt playback
            event[\type] = \none;

            // Parse GM name
            var note = event[\n].asInteger ? 60;
            var vel  = (event[\amp] ? 0.8 * 127).clip(0,127);
            var chan = 0; // you could map gm_instrument → channel

            ~midiOut.noteOn(chan, note, vel);

            // Optionally send noteOff after release time
            (event[\rel] ? 0.5).wait;
            ~midiOut.noteOff(chan, note, 0);
        };
    });
};
)


(type: \dirt, dirt: ~dirt, sound: "drum", speed: 0.5, n: 0, amp: 1, squiz:1).play;


// The CORRECT way to intercept events
~dirt.orbits.do { |orbit|
    orbit.defaultParentEvent.diversion = nil
/*{ |dirtEvent|
        var sound = dirtEvent.event[\s];
        if(sound.notNil and: { sound.asString.beginsWith("gm_") }) {
			"boing!".postln;
            // Modify the event here
            // Return nil to continue processing
        }
    }*/;
};
