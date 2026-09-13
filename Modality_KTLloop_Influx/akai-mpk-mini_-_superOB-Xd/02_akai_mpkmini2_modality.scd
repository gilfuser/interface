(
// AKAI MPK mini mkII -> generic MFdef control buses.
//
// Requires:
//   - Modality-toolkit
//   - my-complete-mpkmini2.desc.scd in this same folder
//   - 01_mf_parameter_pages.scd evaluated first
//
// The custom description exposes 8 knobs in Program 1.
// Bank A/B changes the pads, not the knob CCs, so knob banks/pages are
// implemented in software through MFdef(\page).

q = q ? ();

MKtl.find(\midi);
MKtlDesc.addFolder(thisProcess.nowExecutingPath.dirname, "");
MKtlDesc.loadDescs("my-complete-mpkmini2");

q.mpk = MKtl(\mpk, "my-complete-mpkmini2");

q.mpkPiano = q.mpk.elementGroup.elAt(\p0, \pkey);
q.mpkPads = q.mpk.elementGroup.elAt(\p0, \pad);
q.mpkButtons = q.mpk.elementGroup.elAt(\p0, \bt);
q.mpkKnobs = q.mpk.elementGroup.elAt(\p0, \kn);

// Set true if you want the last used pad bank to select software knob page A/B.
// The MPK Bank A/B switch itself is not exposed as a MIDI element by this description.
if(q.mpkFollowPadBank.isNil) { q.mpkFollowPadBank = false };

// Piano: one generic MFdef instead of one MFdef per note.
q.mpkPiano.do { |el|
    var note = el.elemDesc.midiNum;

    el.action_ { |element|
        MFdef(\note).value(note, element.value);
    };
};

// Pads: preserve convenient pd1..pd16 MFdefs.
q.mpkPads.do { |el, i|
    var name = "pd%".format(i + 1).asSymbol;

    q.mpk.addNamed(name, el);

    el.action_ { |element|
        if(q.mpkFollowPadBank and: { element.value > 0 }) {
            MFdef(\page).value(if(i < 8) { \A } { \B });
        };

        MFdef(name).value(element.value, element.prevValue);
    };
};

// Pad CC/button mode: bt1..bt16.
q.mpkButtons.do { |el, i|
    var name = "bt%".format(i + 1).asSymbol;

    q.mpk.addNamed(name, el);

    el.action_ { |element|
        MFdef(name).value(element.value, element.prevValue);
    };
};

// Eight physical knobs -> kn1..kn8.
// Their values remain normalized; the active parameter page supplies each ControlSpec.
q.mpkKnobs.do { |el, i|
    var name = "kn%".format(i + 1).asSymbol;

    q.mpk.addNamed(name, el);

    el.action_ { |element|
        MFdef(name).value(element.value, element.prevValue);
    };
};

// Joystick X / pitch bend is available to any instrument profile that wants it.
q.mpk.elAt(\all, \bX).do { |el|
    el.action_ { |element|
        MFdef(\bend).value(element.value, element.prevValue);
    };
};

"MPK mini ready".postln;
)
