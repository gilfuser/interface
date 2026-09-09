(
// GM Soundfont Integration - TIMING CORRECTED VERSION
// Fixes OSC parsing and adds latency compensation

// 1. Initialize MIDI for FluidSynth
MIDIClient.init;
~midiOut = MIDIOut.newByName("FLUID Synth", "Synth input port");

// 2. Timing compensation settings
~gm_latency_offset = 0.1; // Adjust this value to align GM sounds with SuperDirt
~use_scheduled_midi = true; // Use SystemClock.sched for better timing

// 3. GM Instrument mapping
~gm_instrument_map = Dictionary.newFrom([
    \gm_piano, (
        program: 0, 
        variants: [
            "0000_JCLive_sf2_file",
            "0000_FluidR3_GM_sf2_file",
            "0000_GeneralUserGS_sf2_file",
            "0000_Aspirin_sf2_file",
            "0000_Chaos_sf2_file"
        ]
    ),
    \gm_accordion, (
        program: 21,
        variants: [
            "0210_JCLive_sf2_file",
            "0210_FluidR3_GM_sf2_file",
            "0210_GeneralUserGS_sf2_file",
            "0211_Aspirin_sf2_file",
            "0211_FluidR3_GM_sf2_file",
            "0211_GeneralUserGS_sf2_file"
        ]
    )
]);

// 4. Set up OSC responder - FIXED VERSION
OSCdef(\gmFromStrudel, { |msg|
    MFdef(\gmHub).value(msg[1..]); // ✅ Discard OSC address
}, '/dirt/play').permanent_(true);

// 5. GM processor with timing compensation
MFdef(\gmHub).add(\gmProcessor, { |msg|
    var event, sound, instrumentData, variant, note, velocity, sustain;
    var selectedVariant, midiNote, playTime;
    
    event = (); // ✅ All vars declared at top
    
    // Parse OSC message into event dictionary
    msg.pairsDo { |key, value|
        if(key.isKindOf(Symbol)) {
            event[key] = value;
        };
    };
    
    sound = event[\s];
    
    if(sound.notNil and: { sound.asString.beginsWith("gm_") }) {
        instrumentData = ~gm_instrument_map[sound.asSymbol];
        
        if(instrumentData.notNil and: ~midiOut.notNil) {
            variant = (event[\n] ? 0).asInteger;
            note = event[\note] ? 60;
            velocity = ((event[\amp] ? 0.8) * 127).clip(1, 127).asInteger;
            sustain = event[\sustain] ? 1.0;
            
            selectedVariant = instrumentData.variants.wrapAt(variant);
            
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
            
            if(~use_scheduled_midi) {
                // OPTION 1: Schedule MIDI with latency compensation
                playTime = ~gm_latency_offset;
                
                SystemClock.sched(playTime, {
                    ~midiOut.program(0, instrumentData.program);
                    ~midiOut.noteOn(0, midiNote, velocity);
                    nil;
                });
                
                SystemClock.sched(playTime + sustain, {
                    ~midiOut.noteOff(0, midiNote, 0);
                    nil;
                });
            } {
                // OPTION 2: Immediate MIDI (original behavior)
                ~midiOut.program(0, instrumentData.program);
                ~midiOut.noteOn(0, midiNote, velocity);
                
                SystemClock.sched(sustain, {
                    ~midiOut.noteOff(0, midiNote, 0);
                    nil;
                });
            };
            
            ("GM: " ++ sound ++ ".n(" ++ variant ++ ") -> " ++ 
             selectedVariant ++ ", Note " ++ midiNote ++ 
             ", Latency: " ++ ~gm_latency_offset ++ "s").postln;
        };
    };
});

// Enable GM processing
MFdef(\gmHub).enable(\gmProcessor);

"GM Soundfont integration active with timing correction!".postln;
"".postln;
"Timing adjustment commands:".postln;
"~gm_latency_offset = 0.05;  // Make GM sounds play later".postln;
"~gm_latency_offset = 0.15;  // Make GM sounds play even later".postln;
"~gm_latency_offset = 0;     // No delay (immediate)".postln;
"".postln;
"~use_scheduled_midi = true;   // Use scheduled timing".postln;
"~use_scheduled_midi = false;  // Use immediate timing".postln;

)

// TIMING ADJUSTMENT GUIDE:
// 
// If GM sounds play TOO EARLY:
// ~gm_latency_offset = 0.1;  // Add 100ms delay
//
// If GM sounds play TOO LATE:
// ~gm_latency_offset = 0.05; // Reduce to 50ms delay
//
// Test with:
// s("[gm_piano, bd]*4").n(0)
// 
// Adjust ~gm_latency_offset until GM piano and bass drum align perfectly
