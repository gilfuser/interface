(
// GM Soundfont Integration using MFdef approach
// Based on the Tidal FX example and correct understanding of webaudiofontdata
// Author: Manus AI
// Date: 2025-10-01

// 1. Initialize MIDI for FluidSynth
MIDIClient.init;
~midiOut = MIDIOut.newByName("FLUID Synth", "Synth input port");
MIDIClient.init;
MIDIOut.findPort("FLUID Synth (1578)", "Synth input port (1578:0)", 8388608)
MIDIOut.connect(0,2)


~midiOut.noteOn(0, 60, 100); SystemClock.sched(1, { ~midiOut.noteOff(0, 60, 0); nil });

// 2. GM Instrument mapping with correct soundfont organization
// Each GM instrument has multiple variants from different soundfont sources
~gm_instrument_map = Dictionary.newFrom([
    \gm_piano, (
        program: 0,
        variants: [
            "0000_JCLive_sf2_file",        // n=0
            "0000_FluidR3_GM_sf2_file",    // n=1
            "0000_GeneralUserGS_sf2_file", // n=2
            "0000_Aspirin_sf2_file",       // n=3
            "0000_Chaos_sf2_file"          // n=4
        ]
    ),

    \gm_accordion, (
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

    // Add more instruments following the same pattern...
]);

// 3. Soundfont management
// Path to your cloned webaudiofontdata repository
~webaudiofont_path = "/home/skmecs/repos/webaudiofontdata/sound";
~current_soundfont = nil;

~loadSoundfontVariant = { |variantName|
    if(~current_soundfont != variantName) {
        var jsFile = ~webaudiofont_path ++ variantName ++ ".js";
        ("Loading soundfont variant: " ++ jsFile).postln;

        // TODO: Load the JavaScript wavetable data
        // This could be done by:
        // 1. Converting .js to .sf2 and loading in FluidSynth
        // 2. Or parsing the .js wavetable data directly in SuperCollider

        ~current_soundfont = variantName;
    };
};

// 4. Set up OSC responder using MFdef approach (like the Tidal FX example)
OSCdef(\gmFromStrudel, { |msg|
    MFdef(\gmHub).value(msg[1..]);
}, '/dirt/play').permanent_(true);

// 5. MFdef for GM sound processing
MFdef(\gmHub).add(\gmProcessor, { |msg|
    var event = ();
    var sound, instrumentData, variant, note, velocity, sustain;
    var selectedVariant, midiNote;

    // Parse OSC message into event dictionary
    msg.pairsDo { |key, value|
        if(key.isKindOf(Symbol)) {
            event[key] = value;
        };
    };

    sound = event[\s];

    // Check if this is a GM sound
    if(sound.notNil and: { sound.asString.beginsWith("gm_") }) {
        instrumentData = ~gm_instrument_map[sound.asSymbol];

        if(instrumentData.notNil and: ~midiOut.notNil) {
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
                // Simple note conversion (extend as needed)
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

            ("GM: " ++ sound ++ ".n(" ++ variant ++ ") -> " ++
             selectedVariant ++ ", MIDI note " ++ midiNote).postln;

            // Schedule note off
            SystemClock.sched(sustain, {
                ~midiOut.noteOff(0, midiNote, 0);
                nil;
            });
        };
    };
});

// Enable GM processing
MFdef(\gmHub).enable(\gmProcessor);

"GM Soundfont integration active using MFdef approach!".postln;
"".postln;
"Setup steps:".postln;
"1. Make sure you have webaudiofontdata cloned at ~/webaudiofontdata/".postln;
"2. Start FluidSynth with a base soundfont:".postln;
"   fluidsynth -a alsa -m alsa_seq /path/to/any/gm/soundfont.sf2".postln;
"3. Test with:".postln;
"   (type: \\dirt, dirt: ~dirt, s: \"gm_piano\", n: 0, note: 60).play;".postln;
"".postln;
"To disable: MFdef(\\gmHub).disable(\\gmProcessor);".postln;

)

// Notes on soundfont organization:
// - Each gm_ instrument corresponds to multiple variants from different sources
// - The n parameter selects which variant (JCLive, FluidR3_GM, GeneralUserGS, etc.)
// - The webaudiofontdata .js files contain wavetable data that needs to be:
//   a) Converted to .sf2 format for FluidSynth, OR
//   b) Parsed directly in SuperCollider for wavetable synthesis

// TODO: Implement wavetable data parsing or conversion
// The .js files contain zones with sample data, pitch info, and MIDI parameters
// that could be used to create SuperCollider SynthDefs or converted to .sf2 format
