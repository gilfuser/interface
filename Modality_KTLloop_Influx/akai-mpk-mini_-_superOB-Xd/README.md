# MPK mini + Modality + superOB-Xd

## Files

1. `01_mf_parameter_pages.scd`  
   Generic MFdef router. It knows nothing about the MPK or OB-Xd.

2. `02_akai_mpkmini2_modality.scd`  
   MPK-specific adapter. It converts Modality elements into generic MFdef buses:
   `kn1..kn8`, `note`, `bend`, `pd1..pd16`, `bt1..bt16`.

3. `my-complete-mpkmini2.desc.scd`  
   Your existing custom Modality description, copied unchanged.

4. `03_superOB-Xd_mpk_profile.scd`  
   OB-Xd-specific target, note handling, and initial parameter pages.

## Load order

Evaluate the OB-Xd SynthDef/Ndef first, then:

```supercollider
"01_mf_parameter_pages.scd".loadRelative;
"02_akai_mpkmini2_modality.scd".loadRelative;
"03_superOB-Xd_mpk_profile.scd".loadRelative;
```

If you evaluate the files manually in the IDE, use the same order.

## Knob pages

There are eight physical knobs. The supplied Modality description has 16 pad elements for
Bank A/B but only eight knob elements, so A/B knob pages are implemented in software.

```supercollider
q.ctrl.usePage(\A);
q.ctrl.usePage(\B);
```

Pages are arbitrary symbols, not limited to A/B:

```supercollider
q.ctrl.usePage(\C);
```

## Live reassignment

```supercollider
q.ctrl.assign(\A, 1, \lfo_rate, [0.01, 100, \exp, 0, 1]);
q.ctrl.assign(\A, 1, \cutoff, \freq);
```

The router uses `SoftSet` by default, preserving the pickup behavior from the older patches
when switching mappings.
