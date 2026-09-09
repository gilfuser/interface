(
// GM Soundfont Integration - DEBUGGED VERSION
// Fixes the instrumentData lookup error
s.latency = 0.2;
// 1. Initialize MIDI for FluidSynth
MIDIClient.init;
~midiOut = MIDIOut.newByName("FLUID Synth", "Synth input port");
~midiOut.latency = 0.3;

// 2. GM Instrument mapping - FIXED with proper symbol keys
~gm_instrument_map = Dictionary.newFrom([
    \gm_piano, (  // ✅ Use backslash symbol, not quote symbol
        program: 0,
        variants: [
            "0000_JCLive_sf2_file",        // n=0
            "0000_FluidR3_GM_sf2_file",    // n=1
            "0000_GeneralUserGS_sf2_file", // n=2
            "0000_Aspirin_sf2_file",       // n=3
            "0000_Chaos_sf2_file"          // n=4
        ]
    ),

    \gm_accordion, (  // ✅ Use backslash symbol, not quote symbol
        program: 21,
        variants: [
            "0210_JCLive_sf2_file",        // n=0
            "0210_FluidR3_GM_sf2_file",    // n=1
            "0210_GeneralUserGS_sf2_file", // n=2
            "0211_Aspirin_sf2_file",       // n=3
            "0211_FluidR3_GM_sf2_file",    // n=4
            "0211_GeneralUserGS_sf2_file"  // n=5
        ]
    )
]);

// Debug: Check the dictionary contents
"GM instrument map contents:".postln;
~gm_instrument_map.keysValuesDo { |key, value|
    ("Key: " ++ key ++ " -> " ++ value).postln;
};

// 3. Soundfont management
~webaudiofont_path = "/home/skmecs/repos/webaudiofontdata/sound";
~current_soundfont = nil;

~loadSoundfontVariant = { |variantName|
    if(~current_soundfont != variantName) {
        var jsFile = ~webaudiofont_path ++ variantName ++ ".js";
        ("Loading soundfont variant: " ++ jsFile).postln;
        ~current_soundfont = variantName;
    };
};

// 4. Set up OSC responder using MFdef approach
OSCdef(\gmFromStrudel, { |msg|
	MFdef(\gmHub).value(msg[1..]);
}, '/dirt/play').permanent_(true);

// 5. DEBUGGED MFdef for GM sound processing
MFdef(\gmHub).add(\gmProcessor, { |msg|
    var event = ();
    var sound, instrumentData, variant, note, velocity, sustain;
    var selectedVariant, midiNote, soundSymbol;

    // Debug: Show the raw message
    ("Raw OSC message: " ++ msg).postln;

    // Parse OSC message into event dictionary
    msg.pairsDo { |key, value|
        if(key.isKindOf(Symbol)) {
            event[key] = value;
        };
    };

    // Debug: Show parsed event
    ("Parsed event: " ++ event).postln;

    sound = event[\s];
    ("Sound parameter: " ++ sound ++ " (class: " ++ sound.class ++ ")").postln;

    // Check if this is a GM sound
    if(sound.notNil and: { sound.asString.beginsWith("gm_") }) {
        ("Detected GM sound: " ++ sound).postln;

        // Debug the dictionary lookup
        soundSymbol = sound.asSymbol;
        ("Looking up symbol: " ++ soundSymbol ++ " (class: " ++ soundSymbol.class ++ ")").postln;

        instrumentData = ~gm_instrument_map[soundSymbol];
        ("Instrument data: " ++ instrumentData).postln;

        if(instrumentData.notNil) {
            if(~midiOut.notNil) {
                variant = (event[\n] ? 0).asInteger;
                note = event[\note] ? 60;
                velocity = ((event[\amp] ? 0.8) * 127).clip(1, 127).asInteger;
                sustain = event[\sustain] ? 1.0;

                // Select the correct soundfont variant
                selectedVariant = instrumentData.variants.wrapAt(variant);
                ~loadSoundfontVariant.value(selectedVariant);

                // Send program change for the GM instrument
                ~midiOut.program(0, instrumentData.program);

                // Convert note to MIDI number
                midiNote = if(note.isKindOf(String)) {
                    switch(note.toLower,
                        "c4", 60, "d4", 62, "e4", 64, "f4", 65,
                        "g4", 67, "a4", 69, "b4", 71,
                        note.asInteger
                    );
                } {
                    note.asInteger;
                };

                // Send MIDI note
                ~midiOut.noteOn(0, midiNote, velocity);

                ("✅ GM: " ++ sound ++ ".n(" ++ variant ++ ") -> " ++
                 selectedVariant ++ ", MIDI note " ++ midiNote).postln;

                // Schedule note off
                SystemClock.sched(sustain, {
                    ~midiOut.noteOff(0, midiNote, 0);
                    nil;
                });
            } {
                "❌ MIDI output not available".postln;
            };
        } {
            ("❌ Unknown GM instrument: " ++ sound ++ " (symbol: " ++ soundSymbol ++ ")").postln;
            ("Available instruments: " ++ ~gm_instrument_map.keys).postln;
        };
    } {
        // ("Regular sound: " ++ sound).postln;
    };
});

// Enable GM processing
MFdef(\gmHub).enable(\gmProcessor);

"GM Soundfont integration active with debugging!".postln;
"Test with: (type: \\dirt, dirt: ~dirt, s: \"gm_piano\", n: 0, note: 60).play;".postln;

)

// Debug commands to run separately:
// Check if the dictionary is working:
// ~gm_instrument_map[\gm_piano]
// ~gm_instrument_map.keys
// \gm_piano.class
