// Simple FluidSynth MIDI Test
// Run this to check if MIDI communication is working

// Initialize MIDI and find FluidSynth
(
MIDIClient.init;
~midiOut = MIDIOut.newByName("FLUID Synth", "Synth input port");
if(~midiOut.isNil) {
    ~midiOut = MIDIOut.newByName("FluidSynth", "fluid");
    if(~midiOut.isNil) {
        "❌ FluidSynth MIDI port not found!".postln;
        "Available MIDI destinations:".postln;
        MIDIClient.destinations.do { |dest, i|
            ("  " ++ i ++ ": " ++ dest.name ++ " - " ++ dest.device).postln;
        };
    } {
        "✅ Found FluidSynth MIDI port".postln;
    };
} {
    "✅ Found FluidSynth MIDI port".postln;
};
)

// ONE-LINER TEST: Play middle C for 1 second
~midiOut.noteOn(0, 60, 100); SystemClock.sched(1, { ~midiOut.noteOff(0, 60, 0); nil });

// If you hear a piano note, MIDI is working!
// If not, check:
// 1. Is FluidSynth running? (fluidsynth -a alsa -m alsa_seq soundfont.sf2)
// 2. Is a soundfont loaded in FluidSynth?
// 3. Are the MIDI port names correct?
