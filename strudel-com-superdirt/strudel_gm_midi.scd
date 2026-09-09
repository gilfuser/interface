(
// Strudel GM Soundfont Integration with FluidSynth
// Author: Manus AI
// Date: 2025-09-30

// 1. Initialize MIDI
MIDIClient.init;

// 2. Connect to FluidSynth MIDI Input
// Replace "FLUID Synth" and "Synth input port" with the actual names from `MIDIClient.destinations`
~midiOut = MIDIOut.newByName("FLUID Synth", "Synth input port (duplex)");

// 3. GM Soundfont Mapping
// This dictionary maps Strudel gm_ instrument names to General MIDI program numbers.
// The program number is derived from the first four digits of the soundfont file names in gm.mjs
~gm_map = Dictionary.newFrom([
    'gm_accordion', 21,
    'gm_piano', 0,
    'gm_epiano1', 4,
    'gm_epiano2', 5,
    'gm_harpsichord', 6,
    'gm_clavinet', 7,
    'gm_celesta', 8,
    'gm_glockenspiel', 9,
    'gm_music_box', 10,
    'gm_vibraphone', 11,
    'gm_marimba', 12,
    'gm_xylophone', 13,
    'gm_tubular_bells', 14,
    'gm_dulcimer', 15,
    'gm_drawbar_organ', 16,
    'gm_percussive_organ', 17,
    'gm_rock_organ', 18,
    'gm_church_organ', 19,
    'gm_reed_organ', 20,
    // Add more mappings as needed from the gm.mjs file
]);

// 4. Intercept Strudel OSC Messages
~dirt.orbits.do { |orbit|
    orbit.event = orbit.event;
	.addDependant({ |event|
        var sound = event[\s];
        if(sound.notNil and: { sound.asString.beginsWith("gm_") }) {
            var program = ~gm_map[sound];
            if(program.notNil) {
                // Block normal Dirt playback
                event[\type] = \none;

                // Translate Strudel params to MIDI
                var note = (event[\n] ? event[\note] ? 60).asInteger;
                var amp = (event[\amp] ? 0.8) * 127;
                var sustain = event[\sustain] ? 1;
                var chan = (event[\n] ? 0).asInteger % 16; // Use 'n' to select channel

                // Send Program Change if channel instrument is different
                if(~midiOut.latency > 0) { // Check if latency is set
                    ~midiOut.program(chan, program);
                } else {
                    // If no latency, send program change slightly before note on
                    SystemClock.sched(0.005, { ~midiOut.program(chan, program) });
                };

                // Send Note On
                ~midiOut.noteOn(chan, note, amp.asInteger.clip(0, 127));

                // Schedule Note Off
                SystemClock.sched(sustain, { ~midiOut.noteOff(chan, note, 0) });
            }
        }
    });
};

"Strudel GM to MIDI redirection is active.".postln;

// To stop the redirection, you will need to re-evaluate the ~dirt.orbits part of your SuperDirt startup script
// or restart SuperCollider.

)

