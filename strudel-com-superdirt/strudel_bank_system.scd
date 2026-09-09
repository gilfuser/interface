/*
    Strudel Sound Bank System for SuperCollider

    This script implements Strudel-style sound bank functionality by intercepting events
    within SuperDirt and transforming sound names based on the 'bank' parameter.

    - Intercepts events using the SuperDirt 'diversion' hook.
    - Transforms the 's' (sound) parameter by prepending the bank name.
    - Supports bank name aliases (e.g., "tr909" -> "rolandtr909").
*/

(
    // --- Bank Alias Map ---
    // A dictionary to map short aliases to full bank names.
    // Customize this with your own bank names and aliases.
    ~bankAliases = Dictionary.newFrom([
        \tr808 -> \rolandtr808,
        \tr909 -> \rolandtr909,
        // Add more aliases here, e.g.:
        // \linn -> \linndrum
    ]);

    // --- Event Diversion Logic ---
    // This function is applied to every SuperDirt orbit.
    ~dirt.orbits.do { |orbit|
        // Use the 'diversion' hook to intercept and modify events before they are played.
        orbit.defaultParentEvent.diversion = { |dirtEvent|
            var event = dirtEvent.event; // The dictionary of event parameters
            var sound = event[\s];
            var bank = event[\bank];

            // Check if both 's' and 'bank' parameters exist
            if(bank.notNil and: { sound.notNil }) {
                var resolvedBank, transformedSound;

                // 1. Resolve alias: Look up the bank name in the alias map.
                //    If not found, use the original bank name.
                resolvedBank = ~bankAliases[bank.asSymbol] ? bank;

                // 2. Transform sound name: Prepend the resolved bank name.
                //    e.g., "rolandtr909" + "-" + "bd" -> "rolandtr909-bd"
                transformedSound = resolvedBank.asString ++ "-" ++ sound.asString;

                // 3. Modify the event in-place.
                event[\s] = transformedSound;

                // 4. Remove the 'bank' parameter to avoid any potential issues.
                event.removeAt(\bank);
            };

            // IMPORTANT: Always return nil to allow the event to be processed normally.
            nil;
        };
    };

    "Strudel Bank System loaded successfully.".postln;
);
/*
    --- How to Use ---

    1.  Ensure your samples are named and organized correctly in your SuperDirt
        'Samples' folder. The script assumes a 'bank-sound' naming convention.
        - /Samples/rolandtr909-bd/0.wav
        - /Samples/rolandtr909-sd/0.wav
        - /Samples/linndrum-cp/0.wav

    2.  Run this script in SuperCollider after starting SuperDirt.

    3.  Use the `.bank()` function in Strudel. The sound names will be transformed
        automatically before being played by SuperDirt.

    --- Test Patterns (from Strudel) ---

    // Uses the full bank name
    s("bd sd").bank("rolandtr808")

    // Uses an alias defined in ~bankAliases
    s("bd sd").bank("tr909")

    // Patterns the bank name
    s("bd sd").bank("<rolandtr808 tr909>")

    // A pattern without a bank will play the standard sample
    s("cp")
*/
