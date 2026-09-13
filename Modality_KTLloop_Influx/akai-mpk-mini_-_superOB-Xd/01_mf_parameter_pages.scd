(
// Generic MFdef controller router.
// Hardware-specific code only needs to feed:
//   MFdef(\kn1) ... MFdef(\kn8) with (value, prevValue), normalized 0..1
//   MFdef(\note) with (midiNote, velocity)
//   MFdef(\bend) if desired
//   MFdef(\page) with a page Symbol, e.g. \A, \B, \filter, \lfo...
//
// Instrument-specific code supplies a target, pages and note handlers.

q = q ? ();
q.ctrl = q.ctrl ? ();

q.ctrl.pages = IdentityDictionary.new;
q.ctrl.page = \A;
q.ctrl.target = nil;
q.ctrl.pickup = 0.01;
q.ctrl.noteOn = nil;
q.ctrl.noteOff = nil;

q.ctrl.setTarget = { |self, target|
    self.target = target;
};

q.ctrl.setNoteHandlers = { |self, noteOn, noteOff|
    self.noteOn = noteOn;
    self.noteOff = noteOff;
};

q.ctrl.resolveSpec = { |self, binding|
    var spec = binding[\spec];
    var target = binding[\target];
    var param = binding[\param];

    if(target.isNil) { target = self.target };

    if(spec.isNil and: { target.notNil and: { target.respondsTo(\getSpec) } }) {
        spec = target.getSpec(param);
    };

    if(spec.isNil and: { Spec.specs.at(param).notNil }) {
        spec = param;
    };

    if(spec.isNil) {
        ("No spec found for %, using 0..1".format(param)).warn;
        spec = [0, 1, \lin, 0, 0];
    };

    spec.asSpec
};

q.ctrl.apply = { |self, binding, value, prevValue|
    var target, param, spec, mapped, previous, soft;

    if(binding.notNil) {
        if(binding[\action].notNil) {
            binding[\action].value(value, prevValue, binding);
        } {
            target = binding[\target];
            if(target.isNil) { target = self.target };

            param = binding[\param];

            if(target.notNil and: { param.notNil }) {
                spec = self.resolveSpec(binding);
                mapped = spec.map(value);

                previous = prevValue;
                if(previous.isNil) { previous = value };
                previous = spec.map(previous);

                soft = binding[\soft];
                if(soft.isNil) { soft = true };

                if(soft) {
                    // Soft takeover: changing page does not immediately jump the parameter
                    // to the physical knob position.
                    SoftSet(
                        target,
                        param,
                        mapped,
                        within: self.pickup,
                        lastVal: previous,
                        spec: spec
                    );
                } {
                    target.set(param, mapped);
                };
            };
        };
    };
};

q.ctrl.definePage = { |self, page, bindings|
    var mappings = Array.newClear(8);

    bindings.keep(8).do { |binding, i|
        if(binding.isKindOf(Symbol)) {
            mappings[i] = (param: binding);
        } {
            mappings[i] = binding;
        };
    };

    self.pages.put(page, mappings);
};

q.ctrl.assign = { |self, page, knob, param, spec, target, soft|
    var mappings = self.pages.at(page);

    if(mappings.isNil) {
        mappings = Array.newClear(8);
        self.pages.put(page, mappings);
    };

    mappings.put(
        knob - 1,
        (param: param, spec: spec, target: target, soft: soft)
    );
};

q.ctrl.unassign = { |self, page, knob|
    var mappings = self.pages.at(page);
    if(mappings.notNil) { mappings.put(knob - 1, nil) };
};

q.ctrl.usePage = { |self, page|
    if(self.pages.at(page).isNil) {
        ("Unknown controller page: %".format(page)).warn;
    } {
        self.page = page;
        "controller page: %".postf(page);
    };
};

q.ctrl.describePage = { |self, page|
    var mappings;
    if(page.isNil) { page = self.page };

    mappings = self.pages.at(page);

    if(mappings.isNil) {
        "No page named %".format(page).postln;
    } {
        "page %".format(page).postln;
        mappings.do { |binding, i|
            if(binding.isNil) {
                "  kn% -> --".format(i + 1).postln;
            } {
                "  kn% -> %".format(i + 1, binding[\param]).postln;
            };
        };
    };
};

// One permanent MFdef action per physical knob.
// Page changes only alter q.ctrl.page; mappings can be replaced live.
8.do { |i|
    var name = "kn%".format(i + 1).asSymbol;

    MFdef(name).add(\parameter_page_router, { |value, prevValue|
        var mappings = q.ctrl.pages.at(q.ctrl.page);
        var binding;

        if(mappings.notNil) {
            binding = mappings.at(i);
            if(binding.notNil) {
                q.ctrl.apply(binding, value, prevValue);
            };
        };
    });
};

MFdef(\page).add(\parameter_page_router, { |page|
    q.ctrl.usePage(page);
});

MFdef(\note).add(\instrument_note_router, { |note, velocity|
    if(velocity > 0) {
        if(q.ctrl[\noteOn].notNil) {
            q.ctrl[\noteOn].value(note, velocity)
        };
    } {
        if(q.ctrl[\noteOff].notNil) {
            q.ctrl[\noteOff].value(note)
        };
    };
});
)
