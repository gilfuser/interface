# X-Touch Mini modular performance controller — r8.4

This SuperCollider patch turns a Behringer X-Touch Mini into a controller for:

- editing instruments and effects in eight SuperDirt orbits;
- mixing, muting and soloing those orbits;
- inserting and removing processes through a direct router;
- controlling process dry/wet where available;
- displaying a 32-cycle Tidal timeline;
- recording parameter automation with automatic four-take overdubbing;
- displaying the current context in an always-on-top HUD.

Revision r8.4 uses `Relative3` encoders in Layers A and B and adds an orbit-focus
view to the MC router. MC process buttons now show every active process in the
last orbit whose encoder was pressed or turned, while the currently selected
process blinks.

The r8.4 interaction model is intentionally small:

> **Layer A edits. Layer B mixes. MC connects. Record captures whatever you move.**

## Files

| File | Responsibility |
| --- | --- |
| `behringer-x-touch-mini.desc.scd` | Extended Modality description for normal and MC modes |
| `behringer_x_touch_mini.scd` | Loader, configuration and revision checks |
| `xtouch_device.scd` | Device lookup, virtual fallback, element aliases and BPM slider |
| `xtouch_processes.scd` | Declarative process registry, Layer A, routing and parameter state |
| `xtouch_layer_b.scd` | Eight-orbit mixer, mute and solo |
| `xtouch_mc.scd` | MC router, dry/wet rings and fake timeline view |
| `xtouch_ktlloop.scd` | Automatic capture, four-take overdub and takeover |
| `xtouch_hud.scd` | Context-sensitive always-on-top status window |
| `xtouch_log.scd` | Log window and bounded log history |
| `QUICK_REFERENCE.md` | Compact performance reference |

## Requirements

- SuperCollider;
- Modality-toolkit with the X-Touch Mini description;
- the bundled extended `behringer-x-touch-mini.desc.scd`, which maps MC inputs, rings, button LEDs and Layer A/B buttons;
- KtlLoop;
- JITLib/ProxySpace and ProxyChain;
- a running server and the existing `orb00` through `orb07` ProxyChains;
- a shared clock in `t`, normally a `LinkClock`.

## Required X-Touch Editor setup

Before using r8.4, program the **TURN** section of all eight encoders in both
Layer A and Layer B as follows:

| Field | Value |
| --- | --- |
| Type | `CC` |
| Channel | `11` |
| Encoder behavior | `Relative3` |
| LED ring | `Fan` |

Keep each layer's existing CC numbers: `CC1…CC8` in Layer A and `CC11…CC18`
in Layer B. Leave the pushes, buttons and slider unchanged. Exit the orange
`EDITOR` state and close X-Touch Editor before starting SuperCollider.

`Relative3` sends `65` for one step left and `1` for one step right. Faster
turns may send larger magnitudes, which the patch retains as acceleration.

The patch registers its own directory with `MKtlDesc`, loads the bundled
description and validates the MC elements before creating the controller. It
does not overwrite the description installed inside Modality-toolkit.

## Loading

Keep all files in one directory and evaluate:

```supercollider
(q.patch_dir +/+ "behringer_x_touch_mini.scd").load;
```

Expected revision:

```supercollider
q.xtouch.patch_revision.postln;
// 2026-09-10-r8.4

q.xtouch.loaded_modules.postln;
// [log, device, processes, layer_b, mc, ktlloop, hud]
```

If the physical controller is not found after `MKtl.find`, the patch creates:

```supercollider
MKtl(\loop, "behringer-x-touch-mini").gui
```

The virtual GUI is kept on top and uses the same actions as the hardware.

If description loading ever fails, inspect the exact bundled path and the
folders known by Modality:

```supercollider
q.xtouch.desc_path.postln;
MKtlDesc.descFolders.postln;
```

## Configuration

Set options before loading the main file:

```supercollider
~xtouch_config = (
    loopCount: 4,
    looped: true,
    palindrome: true,
    clearHoldSeconds: 1.2,
    timelineCycleBeats: 4,
    mcWetScale: 2.0,
    encoderLagTime: 0.2,
    encoderRelativeScale: 0.5,
    showHud: true,
    hudAlwaysOnTop: true
);
```

Missing keys receive these defaults automatically. `loopCount` accepts 1–8; four is the intended r8.4 setup. `encoderRelativeScale` multiplies Layer A/B movement; `0.5` gives approximately 128 slow steps across the normalized range.

## Shared transport controls

These bottom-row controls have the same meaning in Layers A and B:

| Control | Action |
| --- | --- |
| B1 | Enter MC router |
| B2 | Toggle palindrome recording |
| B5 | Toggle looping for every take |
| B6 | Stop recording and playback |
| Hold B6 | Clear every recorded take |
| B7 | Play/pause/resume all takes |
| B8 | Start/finish Record or Overdub |
| Slider | BPM, 40–200; center is 120 |

B3/B4 are intentionally layer-specific because they belong to editing in A and mixer recovery in B.

## Layer A — process editor

| Control | Action |
| --- | --- |
| Top button 1–8 | Select `orb00`–`orb07` |
| Encoder 1–8 | Edit parameter 1–8 of the selected process and orbit |
| Push and turn the selected-orbit encoder | Edit dry/wet when available |
| B3 | Previous process |
| B4 | Next process |

### Orbit LEDs

- The selected orbit blinks.
- Other LEDs are solid when the selected process is active in that orbit.
- Changing process redraws this routing view immediately.

### Dry/wet gesture

Suppose `orb03` is selected. Top button 4 blinks.

1. Press and hold encoder 4.
2. Turn encoder 4.
3. Release encoder 4.

While held, its ring and movement represent dry/wet. On release, the eight rings return to the normal parameter values.

The gesture works for:

- active ProxyChain effects, through their generated `wetNN` control;
- registered external effects that declare `wetKind: \parameter` and a `wetParameter`.

It does nothing destructive when the selected process has no wet control or is not active in the selected orbit.

Layer A encoder pushes no longer insert or remove processes in unrelated orbits. Routing belongs to MC.

## Layer B — orbit mixer

Layer B contains no process editing and no hidden wet modifiers.

| Control | Action |
| --- | --- |
| Encoder 1–8 | Level of `orb00`–`orb07` |
| Top button 1–8 | Mute/unmute the corresponding orbit |
| Encoder push 1–8 | Solo/unsolo the corresponding orbit |
| B3 | Unmute all |
| B4 | Unsolo all |

The stored level is independent of audibility. Muting or soloing never destroys the previous encoder level.

LED states:

- off: inaudible;
- solid: audible;
- blinking: explicitly soloed and not muted.

## MC — process router

Enter MC from either normal layer with B1.

The sixteen buttons select the first sixteen entries in the process registry. With the default registry:

| MC button | Process | MC button | Process |
| --- | --- | --- | --- |
| Top 1 | `tidal` | Top 8 | `wah` |
| Top 2 | `pho` | Bottom 1 | `strobe` |
| Top 3 | `spacemod` | Bottom 2 | `tape` |
| Top 4 | `dru` | Bottom 3 | `hpf` |
| Top 5 | `modelay` | Bottom 4 | `lpf` |
| Top 6 | `pitch` | Bottom 5 | `endFilt` |
| Top 7 | `lfo` | Bottom 6–8 | unassigned |

Router controls:

| Control | Action |
| --- | --- |
| Any assigned button | Select process |
| Encoder push N | Focus orbit N, then insert/remove the selected process |
| Encoder turn N | Focus orbit N, then change wet when available |
| Layer A alone | Exit to Layer A |
| Layer B alone | Exit to Layer B |
| Layer A + Layer B | Toggle router/timeline button visualization |

### Router button LEDs

In router view, the last encoder pressed or turned defines the focused orbit:

- blinking: the currently selected process, whether routed or not;
- solid: another process active in the focused orbit;
- off: process inactive in the focused orbit.

Entering MC initially focuses the orbit selected in Layer A. The HUD header
shows the current MC orbit focus. The timeline view retains its own button-LED
display and does not show these routing states until returning to router view.

### Router rings

The rings continue to show routing in both MC visual views:

- off: selected process absent from the orbit;
- full wrap: process active without a separate wet control;
- proportional wrap: process active, showing wet.

### Fake timeline view

The timeline changes only the sixteen button LEDs. All buttons, encoder pushes, encoder turns and process selection remain functional.

To enter it:

1. Press B1 from Layer A or B to enter MC.
2. Press the physical Layer A and Layer B buttons together.
3. Press A+B again to return to router LEDs.

This two-stage access is required because the X-Touch Mini does not transmit normal-mode Layer A/B button presses. Those buttons become visible to SuperCollider only in MC protocol mode.

Timeline display:

- top row: one LED per Tidal cycle, repeating after eight;
- bottom row: one LED every four cycles;
- full phrase: 32 cycles;
- default: four Link beats per cycle.

Reset after Tidal `resetCycles`:

```supercollider
~mc_cycle_index = 0;
~render_mc_buttons.value(true);
```

MC LED output is diff-based: only changed button or ring values are transmitted.

## Automatic KtlLoop recording

There is no record-selection or playback-selection gesture in r8.4.

### Record a first take

1. Select a process and orbit in Layer A, or start from the Layer B mixer.
2. Press B8.
3. Move any encoder you want to record.
4. Change process, orbit or layer and move more encoders if desired.
5. Press B8 again.

Every moved encoder in Layer A or B is captured automatically. A take may
combine process parameters, push+turn dry/wet and Layer B orbit levels.
Finishing the recording starts that take immediately.

The recorded route is:

```text
control kind + encoder + process + orbit
```

`control kind` distinguishes a normal parameter, push+turn wet automation and
Layer B level automation.

### Overdub

While takes are playing:

1. Press B8.
2. Move any parameters, wet controls or orbit levels for the overdub.
3. Press B8 again.

The current takes continue playing while a free internal KtlLoop records. With the default configuration, up to four takes can coexist. When all four are occupied, the oldest take is replaced and the other three continue.

The internal objects remain available for diagnosis:

```supercollider
~loops;   // array
~loop1;
~loop2;
~loop3;
~loop4;
```

They are implementation details, not part of the performance workflow.

### Play, pause, stop and clear

- B7 pauses active takes.
- B7 again resumes them from the paused position.
- If stopped takes exist, B7 restarts all of them.
- B6 stops transport but preserves the takes.
- Holding B6 for `clearHoldSeconds` clears every take.

There is no double-click delay on Play or Record.

### Palindrome and looping

- B2 controls whether a newly finished recording is transformed into forward → backward motion.
- B5 changes the `looped` property of every take.
- Both controls exist in Layers A and B and retain LED feedback.
- Changing palindrome does not rebuild recordings that were already completed.

### Overlapping routes

If two takes contain the same route, the newer take owns that route. The older take continues to play all non-overlapping routes.

### Manual takeover

Moving an automated parameter manually takes over only its exact route. Other parameters, processes and orbits continue.

When no effective route remains, playback is officially stopped: the KtlLoop tasks stop, B7 goes dark and the HUD reports zero playing takes.

## HUD

The HUD opens automatically by default and shows:

- current layer or MC visual view;
- selected orbit and process;
- eight parameter labels and normalized values;
- routing of the selected process;
- stored, playing and recording take counts;
- loop and palindrome state;
- a one-line context-sensitive control reminder.

Reopen or refresh it manually:

```supercollider
q.xtouch.show_hud.value;
q.xtouch.refresh_hud.value;
```

The HUD also provides buttons for disabling every effect and resetting the timeline.

## Declarative process registry

`~process_registry` is the only ordered process definition. Each entry may contain:

```supercollider
(
    name: \modelay,
    label: "Modelay",
    kind: \proxyFx,
    wetKind: \proxy,
    controls: (
        a_enc1: \mdtime,
        a_enc2: \mdtimel
    )
)
```

The registry derives:

- `~process_names` and selection order;
- `~controls`;
- the MC button map;
- internal/external process categories;
- source routing;
- HUD labels;
- wet behavior.

Supported kinds:

| Kind | Purpose |
| --- | --- |
| `\osc` | OSC control process such as Tidal |
| `\externalInstrument` | External source inserted into orbit slots 0–9 |
| `\externalEffect` | A single external processor routed from an orbit |
| `\proxyFx` | Internal ProxyChain effect |

External entries may include `source` and a `loadPath` function. A parameter-based wet control uses:

```supercollider
wetKind: \parameter,
wetParameter: \wetDry
```

Adding, removing or reordering an entry changes every selection interface together. ProxyChain DSP order remains a separate audio-chain concern and is still defined by the chain slot order.

## Useful diagnostics

```supercollider
[
    revision: q.xtouch.patch_revision,
    modules: q.xtouch.loaded_modules,
    virtual: ~xtm_is_virtual,
    layer: ~current_xtouch_layer,
    mc: ~mc_mode,
    mc_visual: ~mc_visual_mode,
    mc_orbit: ~mc_selected_orbit_name,
    process: ~process_selector.mode,
    orbit: ~selected_orbit_name,
    muted: ~muted_orbits,
    soloed: ~soloed_orbits,
    stored_takes: ~loop_states.count { |state|
        state[\recorded_routes].isEmpty.not
    },
    playing_takes: ~loop_states.count { |state|
        state[\playing].isEmpty.not
    },
    recording: ~recording_loop_state
].postln;
```

## Notes and limitations

- Normal A/B switching is inferred from the first control event from the new hardware page because the controller emits no dedicated normal-mode layer message.
- Rings are restored after that first event and confirmed again after 80 ms.
- Layer A/B encoders must use `Relative3`; their movement has no absolute endpoint and requires no calibration message after changing context.
- Relative input does not alter KtlLoop route identity or takeover: only a physical encoder event takes over `encoder + control kind + process + orbit`.
- The MC encoder sensitivity depends on the extended description's `relEnc` mapping.
- The patch has structural validation, but hardware timing, VST paths and live KtlLoop behavior must be tested in the target SuperCollider installation.
