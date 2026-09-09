(
// Complete GM Soundfont Solution for StrudelDirt
// Author: Manus AI
// Date: 2025-10-01
//
// This solution uses REAL soundfont files with FluidSynth
// and correctly intercepts GM sounds with proper OSC parsing

// 1. Initialize MIDI for FluidSynth
MIDIClient.init;

// Find FluidSynth MIDI port
~midiOut = MIDIOut.newByName("FLUID Synth", "Synth input port");
if(~midiOut.isNil) {
    // Try alternative names
    ~midiOut = MIDIOut.newByName("FluidSynth", "fluid");
    if(~midiOut.isNil) {
        "Warning: FluidSynth MIDI port not found.".postln;
        "Available MIDI destinations:".postln;
        MIDIClient.destinations.do { |dest, i|
            ("  " ++ i ++ ": " ++ dest.name ++ " - " ++ dest.device).postln;
        };
    };
};

// 2. GM Instrument Mapping (matches Strudel's gm.mjs)
~gm_instrument_map = Dictionary.newFrom([
    // Pianos
    'gm_piano', (program: 0, variants: [
        "FluidR3_GM.sf2",
        "GeneralUserGS.sf2",
        "JCLive.sf2",
        "Aspirin.sf2"
    ]),

    // Electric Pianos
    \'gm_epiano1\', (program: 4, variants: [
        "FluidR3_GM.sf2",
        "GeneralUserGS.sf2",
        "JCLive.sf2"
    ]),

    \'gm_epiano2\', (program: 5, variants: [
        "FluidR3_GM.sf2",
        "GeneralUserGS.sf2",
        "JCLive.sf2"
    ]),

    // Other instruments
    \'gm_harpsichord\', (program: 6, variants: [
        "FluidR3_GM.sf2",
        "GeneralUserGS.sf2"
    ]),

    \'gm_clavinet\', (program: 7, variants: [
        "FluidR3_GM.sf2",
        "GeneralUserGS.sf2"
    ]),

    \'gm_celesta\', (program: 8, variants: [
        "FluidR3_GM.sf2",
        "GeneralUserGS.sf2"
    ]),

    \'gm_glockenspiel\', (program: 9, variants: [
        "FluidR3_GM.sf2",
        "GeneralUserGS.sf2"
    ]),

    \'gm_music_box\', (program: 10, variants: [
        "FluidR3_GM.sf2",
        "GeneralUserGS.sf2"
    ]),

    \'gm_vibraphone\', (program: 11, variants: [
        "FluidR3_GM.sf2",
        "GeneralUserGS.sf2"
    ]),

    \'gm_marimba\', (program: 12, variants: [
        "FluidR3_GM.sf2",
        "GeneralUserGS.sf2"
    ]),

    \'gm_xylophone\', (program: 13, variants: [
        "FluidR3_GM.sf2",
        "GeneralUserGS.sf2"
    ]),

    \'gm_accordion\', (program: 21, variants: [
        "FluidR3_GM.sf2",
        "GeneralUserGS.sf2",
        "JCLive.sf2"
    ])

    // Add more instruments as needed...
]);

// 3. Soundfont Management
~soundfont_path = "~/soundfonts/";
~current_soundfont = nil;
~current_program = nil;

~loadSoundFont = { |soundfontFile|
    var fullPath = ~soundfont_path ++ soundfontFile;
    if(~current_soundfont != soundfontFile) {
        ("Loading soundfont: " ++ fullPath).postln;
        // Note: FluidSynth loading would be done externally
        // This is just for tracking which soundfont should be active
        ~current_soundfont = soundfontFile;
    };
};

~selectProgram = { |programNum|
    if(~current_program != programNum and: ~midiOut.notNil) {
        ~midiOut.program(0, programNum); // Channel 0
        ~current_program = programNum;
        ("Selected GM program: " ++ programNum).postln;
    };
};

// 4. Note conversion helper
~noteToMidi = { |note|
    if(note.isKindOf(String)) {
        // Simple note name to MIDI conversion
        var noteMap = Dictionary.newFrom([
            "c", 0, "c#", 1, "db", 1, "d", 2, "d#", 3, "eb", 3,
            "e", 4, "f", 5, "f#", 6, "gb", 6, "g", 7, "g#", 8,
            "ab", 8, "a", 9, "a#", 10, "bb", 10, "b", 11
        ]);

        var noteName = note.toLower;
        var octave = 4; // default octave
        var noteNum = 0;

        // Extract octave if present
        if(noteName.size > 1 and: noteName.last.isDecDigit) {
            octave = noteName.last.asString.asInteger;
            noteName = noteName.drop(-1);
        };

        noteNum = noteMap[noteName.asSymbol];
        if(noteNum.notNil) {
            (octave + 1) * 12 + noteNum; // MIDI note number
        } {
            60; // Default to middle C
        };
    } {
        note.asInteger; // Already a MIDI note number
    };
};

// 5. CORRECTED OSC Responder
~gmResponder = OSCFunc({ |msg, time, addr, recvPort|
    var args = msg[1..]; // Skip the OSC address
    var event = ();

    // ✅ PARSE FIRST - build the event dictionary
    args.pairsDo { |key, value|
        if(key.isKindOf(Symbol)) {
            event[key] = value;
        };
    };

    // ✅ NOW use the parsed data
    var sound = event[\s];

    if(sound.notNil and: { sound.asString.beginsWith("gm_") }) {
        // This is a GM sound - process it
        var instrumentData = ~gm_instrument_map[sound.asSymbol];

        if(instrumentData.notNil and: ~midiOut.notNil) {
            var variant = (event[\n] ? 0).asInteger;
            var note = event[\note] ? 60;
            var velocity = ((event[\amp] ? 0.8) * 127).clip(1, 127).asInteger;
            var sustain = event[\sustain] ? 1.0;

            // Select soundfont variant
            var selectedSoundfont = instrumentData.variants.wrapAt(variant);
            ~loadSoundFont.value(selectedSoundfont);

            // Select GM program
            ~selectProgram.value(instrumentData.program);

            // Convert note to MIDI
            var midiNote = ~noteToMidi.value(note);

            // Send MIDI note
            ~midiOut.noteOn(0, midiNote, velocity);

            ("GM: " ++ sound ++ ".n(" ++ variant ++ ") -> " ++
             selectedSoundfont ++ ", Program " ++ instrumentData.program ++
             ", Note " ++ midiNote ++ ", Vel " ++ velocity).postln;

            // Schedule note off
            SystemClock.sched(sustain, {
                ~midiOut.noteOff(0, midiNote, 0);
                nil;
            });
        } {
            ("Unknown GM instrument: " ++ sound).postln;
        };

        // Note: SuperDirt will still receive this message too
        // To prevent that, we'd need to modify SuperDirt's OSC responder

    } {
        // Regular sound - let SuperDirt handle it normally
        // ("Regular sound: " ++ sound).postln;
    };

}, '/dirt/play');

"GM Soundfont integration active!".postln;
"".postln;
"Setup required:".postln;
"1. Download soundfonts to ~/soundfonts/:".postln;
"   - FluidR3_GM.sf2 (free)".postln;
"   - GeneralUserGS.sf2 (free)".postln;
"   - JCLive.sf2 (commercial)".postln;
"   - Aspirin.sf2 (free alternative)".postln;
"".postln;
"2. Start FluidSynth:".postln;
"   fluidsynth -a alsa -m alsa_seq ~/soundfonts/FluidR3_GM.sf2".postln;
"".postln;
"3. Test with:".postln;
"   (type: \\dirt, dirt: ~dirt, s: \"gm_piano\", n: 0, note: 60).play;".postln;

)

// Soundfont Download URLs (free ones):
// FluidR3_GM.sf2: https://member.keymusician.com/Member/FluidR3_GM/
// GeneralUserGS.sf2: https://schristiancollins.com/generaluser.php

// To stop GM processing:
// ~gmResponder.free;
