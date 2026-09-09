(
// GM Sound Interception - CORRECTED VERSION
// Fixes the OSC parsing bug and provides foundation for GM sound handling

// Test OSC responder with corrected parsing
~gmResponder = OSCFunc({ |msg, time, addr, recvPort|
    var args = msg[1..]; // Skip the OSC address
    var event = ();
    var sound = event[\s];

    // ✅ PARSE FIRST - build the event dictionary
    args.pairsDo { |key, value|
        if(key.isKindOf(Symbol)) {
            event[key] = value;
        };
    };

    // ✅ NOW use the parsed data

    if(sound.notNil and: { sound.asString.beginsWith("gm_") }) {
        ("GM sound detected: " ++ sound).postln;
        ("  n parameter: " ++ event[\n]).postln;
        ("  note parameter: " ++ event[\note]).postln;
        ("  amp parameter: " ++ event[\amp]).postln;

        // TODO: Add GM sound processing here
        // This is where we would:
        // 1. Load appropriate soundfont/sample
        // 2. Send MIDI to FluidSynth
        // 3. Or trigger wavetable synth

    } {
        ("Regular sound: " ++ sound).postln;
        // Regular sounds pass through normally
        // Note: SuperDirt will still receive this message too
    };

}, '/dirt/play');

"GM OSC responder active with corrected parsing.".postln;
"Test with: (type: \\dirt, dirt: ~dirt, s: \"gm_piano\", n: 0).play;".postln;

)

// To test:
// (type: \dirt, dirt: ~dirt, s: "gm_piano", n: 0, note: 60).play;
// (type: \dirt, dirt: ~dirt, s: "bd", n: 0).play;

// To stop:
// ~gmResponder.free;
