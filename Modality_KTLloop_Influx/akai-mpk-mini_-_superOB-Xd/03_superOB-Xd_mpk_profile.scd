(
// superOB-Xd profile for the generic MFdef controller router.
//
// The SAME parameter pages control either host:
//   \poly -> SynthDef(\obXd) through NPVoicer
//   \mono -> persistent Ndef(\obXd)
//
// Requires:
//   superOB-Xd-load.scd
//   01_mf_parameter_pages.scd
//   02_akai_mpkmini2_modality.scd
//
// Change host live with:
//   q.obXd.useMode(\poly);
//   q.obXd.useMode(\mono);

q = q ? ();
q.obXd = q.obXd ? ();


// POLYPHONIC HOST -------------------------------------------------------------
//
// Use a separate proxy key so the real monophonic Ndef(\obXd) remains independent.
q.obXd[\poly] = q.obXd[\poly] ? NPVoicer(Ndef(\obXdPoly));
q.obXd[\poly].prime(\obXd);


// PARAMETER PAGES -------------------------------------------------------------

// PARAMETER PAGES -------------------------------------------------------------

// PAGE A — OSCILLATORS
q.ctrl.definePage(\A, [
    (param: \osc_1_amp,  spec: \amp),                              // 1 OSC1 AMP
    (param: \osc_1_wave, spec: [0, 3, \lin, 0, 0]),                // 2 OSC1 WAVE
    (param: \o1_pitch,   spec: [-24, 24, \lin, 0, 0, " st"]),      // 3 OSC1 PITCH
    (param: \detune,     spec: [-1, 1, \lin, 0, 0, " st"]),        // 4 DETUNE
    (param: \osc_2_amp,  spec: \amp),                              // 5 OSC2 AMP
    (param: \osc_2_wave, spec: [0, 3, \lin, 0, 0]),                // 6 OSC2 WAVE
    (param: \o2_pitch,   spec: [-24, 24, \lin, 0, 0, " st"]),      // 7 OSC2 PITCH
    (param: \cross_mod,  spec: [0, 1, \lin, 0, 0])                 // 8 CROSS MOD
]);


// PAGE B — AMP ENVELOPE / FILTER
q.ctrl.definePage(\B, [
    (param: \attack,     spec: [0, 1, \lin, 0, 0.04]),             // 1 AMP ATTACK
    (param: \decay,      spec: [0, 1, \lin, 0, 0.1]),              // 2 AMP DECAY
    (param: \sust_level, spec: \amp),                              // 3 AMP SUSTAIN
    (param: \release,    spec: [0, 4, \lin, 0, 0.2]),              // 4 AMP RELEASE
    (param: \cutoff,     spec: \freq),                             // 5 FILTER CUTOFF
    (param: \resonance,  spec: [0.01, 0.99, \lin, 0, 0.5]),        // 6 RESONANCE
    (param: \filter_mix, spec: [0, 2, \lin, 0, 0.5]),              // 7 LP / BP / HP
    (param: \fenv_amt,   spec: [0, 60, \lin, 0, 0])                // 8 ENV AMT
]);


// PAGE C — FILTER ENVELOPE / LFO
q.ctrl.definePage(\C, [
    (param: \filt_att,      spec: [0, 1, \lin, 0, 0.01]),          // 1 FILTER ENV ATTACK
    (param: \filt_dec,      spec: [0, 1, \lin, 0, 0.1]),           // 2 FILTER ENV DECAY
    (param: \filt_sus,      spec: \amp),                           // 3 FILTER ENV SUSTAIN
    (param: \filt_rel,      spec: [0, 2, \lin, 0, 0.2]),           // 4 FILTER ENV RELEASE
    (param: \lfo_rate,      spec: [0.01, 100, \exp, 0, 1]),        // 5 LFO RATE
    (param: \lfo_amt,       spec: [0, 1, \lin, 0, 0]),             // 6 LFO AMOUNT
    (param: \lfo_sync_rate, spec: [0, 8, \lin, 1, 4]),             // 7 LFO SYNC RATE
    (param: \lfo_wave,      spec: [0, 2, \lin, 1, 0])              // 8 LFO WAVE
]);

q.ctrl.usePage(\A);

// ---------------------------------------------------------------------------


MFdef(\bend).add(\superOBXd_pitchbend, { |value|
    if(q.ctrl.target.notNil) {
        q.ctrl.target.set(\pitch_bend, ((value - 0.5) * 2).clip(-1, 1));
    };
});


// HOST SWITCH ----------------------------------------------------------------

q.obXd.useMode = { |self, mode|

    switch(mode,

        \poly, {
            self[\mode] = \poly;
            self[\heldNotes] = List.new; // All knob pages now set the NPVoicer proxy, hence all new/current
            // polyphonic voices receive the shared synth parameters.
            q.ctrl.setTarget(self[\poly].proxy);
            q.ctrl.setNoteHandlers(
                { |note, velocity|
                    self[\poly].play;
                    self[\poly].put(
                        note,
                        [
                            \freq, note.midicps,
                            \velocity, velocity,
                            \note_gate, 1
                        ]
                    );
                },
                { |note|
                    self[\poly].setAt(note, \note_gate, 0);
                }
            );
            "superOB-Xd host: POLY / SynthDef".postln;
        },

        \mono, {
            self[\mode] = \mono;
            self[\heldNotes] = List.new;

            q.ctrl.setTarget(Ndef(\obXd));
            Ndef(\obXd).play;
            Ndef(\obXd).set(\note_gate, 0);

            q.ctrl.setNoteHandlers(
                { |note, velocity|
                    self[\heldNotes].remove(note);
                    self[\heldNotes].add(note);
                    Ndef(\obXd).set(
                        \freq, note.midicps,
                        \velocity, velocity,
                        \note_gate, 1,
                        \t_trig, 1
                    );
                },
                { |note|
                    var wasCurrent = self[\heldNotes].notEmpty and: { self[\heldNotes].last == note };
                    self[\heldNotes].remove(note);

                    if(self[\heldNotes].isEmpty) {
                        Ndef(\obXd).set(\note_gate, 0);
                    } {
                        if(wasCurrent) { Ndef(\obXd).set(\freq, self[\heldNotes].last.midicps) };
                    };
                }
            );

            "superOB-Xd host: MONO / Ndef".postln;
        },

        {
            "Unknown superOB-Xd mode: % (use \\poly or \\mono)"
            .format(mode).warn;
        }
    );
};


// Default: keyboard behaves as a conventional polyphonic synth.
q.obXd.useMode(\poly);

q[\obXdTempoTask].tryPerform(\stop);

q[\obXdTempoTask] = Routine({
    var lastTempo;
    loop {
        var tempo = t.tempo;

        if(lastTempo.isNil or: { (tempo - lastTempo).abs > 0.000001 }) {
            Ndef(\obXd).set(\clock_tempo, tempo);
            if(q.obXd[\poly].notNil) { q.obXd[\poly].proxy.set(\clock_tempo, tempo) };
            lastTempo = tempo;
        };

        0.05.wait;
    };
}).play(AppClock);

"superOB-Xd MPK profile ready".postln;
)

/*
LIVE CODING

// Host:
q.obXd.useMode(\poly);
q.obXd.useMode(\mono);

// Same eight physical knobs, same pages, whichever host is active:
q.ctrl.usePage(\A);
q.ctrl.usePage(\B);

// Reassign a knob live:
q.ctrl.assign(\A, 1, \lfo_rate, [0.01, 100, \exp, 0, 1]);
q.ctrl.assign(\A, 1, \cutoff, \freq);

// Arbitrary additional page:
q.ctrl.definePage(\C, [
    (param: \filt_att,   spec: [0, 1]),
    (param: \filt_dec,   spec: [0, 1]),
    (param: \filt_sus,   spec: \amp),
    (param: \filt_rel,   spec: [0, 2]),
    (param: \attack,     spec: [0, 1]),
    (param: \decay,      spec: [0, 1]),
    (param: \sust_level, spec: \amp),
    (param: \release,    spec: [0, 4])
]);
q.ctrl.usePage(\C);
*/
