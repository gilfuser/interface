// Evaluate the block below to start the mapping MIDI -> OSC.

(
var on, off, cc;
var osc;

osc = NetAddr.new("127.0.0.1", 6010);

/*MIDIClient.init;
MIDIIn.connectAll;*/

on = MIDIFunc.noteOn({ |val, num, chan, src|
    osc.sendMsg("/ctrl", num.asString, val/127);
    // postf("on:\n val = %\n num = %\n chan = %\n src = %\n\n", val/127, num, chan, src );
});

off = MIDIFunc.noteOff({ |val, num, chan, src|
    osc.sendMsg("/ctrl", num.asString, 0);
    // postf("off:\n val = %\n num = %\n chan = %\n src = %\n\n", val, num, chan, src);
});

cc = MIDIFunc.cc({ |val, num, chan, src|
    osc.sendMsg("/ctrl", num.asString, val/127);
    // postf("cc:\n val = %\n num = %\n chan = %\n src = %\n\n", val/127, num, chan, src);
});

if (~stopMidiToOsc != nil, {
    ~stopMidiToOsc.value;
});

~stopMidiToOsc = {
    on.free;
    off.free;
    cc.free;
};
)

// Evaluate the line below to stop it.
~stopMidiToOsc.value;

