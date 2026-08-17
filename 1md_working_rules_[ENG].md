# Working Rules

How work is done in this repo, and in any repo of Marko's. Set 17.8.2026.
These are not suggestions. If a rule and a deadline disagree, the rule wins.

---

## 1. Three tests before shipping

Every feature is tested THREE times before it is delivered.

The three must PROGRESS. Running the same test three times proves nothing
except that the computer is deterministic, which was never in doubt.

    TEST 1    THE MECHANISM, ALONE
              The logic on its own, out of the app, with the inputs chosen by
              hand. Does the thing itself do what it claims? A pure function,
              a state machine, a parser, a rule of arithmetic.

    TEST 2    INSIDE THE RUNNING APP, WITH REAL DATA
              Wired up, end to end, against the real server and the real API.
              Not a mock. Test 1 can pass while the feature is unreachable,
              never called, or wired to the wrong button.

    TEST 3    THE UGLY CASES
              This is the one that earns its keep. Failure, empty, offline,
              restart, wrong order, the thing breaking halfway through, the
              user doing it twice, the value out of range, the file missing,
              the network hanging and never answering at all.

Say what each of the three was and what it showed. If a test fails, fix it and
run ALL THREE again, not just the one that failed.

Three is the number.

### Why three, learned the hard way

Every real bug shipped from this repo would have been caught by test 3:

    the picker stuck at 1 page       a cache written by older code was still
                                     readable by newer code. Caught by
                                     "restart with the old file present".
    full screen not full screen      the rule named the things to hide, so
                                     everything added later stayed visible.
                                     Caught by "add something new, look again".
    the paste button did nothing     the clipboard API neither resolved nor
                                     rejected. It NEVER ANSWERED. Caught only
                                     by asking what happens when a promise
                                     hangs forever.
    the update did nothing           a server already running kept serving old
                                     code out of memory. Caught by "do it
                                     twice in a row".
    colour escapes as rubbish        truecolour on a terminal that has eight
                                     colours. Caught by "run it somewhere
                                     poorer than my machine".

None of those would have been caught by testing that the happy path works.

---

## 2. Real keys only. Never synthetic.

Any feature that needs an API key is tested against a REAL key.

    ASK      say plainly that the feature needs a key and ask for it
    RECEIVE  Marko supplies it as a text file. He is the organic farmer of
             the keys.
    TEST     all three tests, against the live service
    SHRED    every copy, immediately, and CONFIRM the shred by hunting for
             the key across writable storage and reporting the count

Never invent, mock or fake a key to make a test pass. Never ship a
key-dependent feature untested and hope. A synthetic key proves that the code
runs; it proves nothing about whether the service agrees.

The only thing a fake key is good for is testing the FAILURE path, and even
then it should be a real key with its last four characters changed, so the
shape and the rejection are both real.

### While a key is in hand

    never print, echo, log or commit it
    never send it back to the browser
    mask as first6 then last4 if one must be named at all
    store fingerprints, never keys, in any list that outlives the session
    key file 0600, in .gitignore before the first commit
    an installer that wipes must carry the key file out and put it back

---

## 2b. Settings are kept, and kept privately

Every setting a person changes is remembered between sessions. Not most of
them, not usually, all of them and always. A preference that has to be set
twice is worse than one that was never offered.

WHERE. One file, inside the app's own folder in Termux private storage:

    ~/.maread-web/web_state.json

Nothing else on the phone can read or write it. It is not in shared storage,
not in the browser, not in localStorage, not in a cloud. It never leaves the
device. An installer that wipes and reinstalls carries it out and puts it
back, along with its backup and the key files.

HOW, and the two ways it goes wrong:

    NOT ATOMIC          Opening the file for writing truncates it at once, so
                        a phone that freezes or is killed mid write leaves
                        half a file, which parses as nothing, which reads back
                        as factory defaults. Write a temporary file, fsync it,
                        rename it over the top. Keep the previous good copy as
                        .bak and fall back to it.

    A FROZEN TAB        On Android a backgrounded tab is FROZEN and pending
                        timers never run. A debounced save loses anything
                        changed in the last moment before the phone went in a
                        pocket. Flush on visibilitychange, pagehide and blur,
                        using sendBeacon, which the browser delivers even as
                        the page is torn down. A plain fetch at that moment is
                        allowed to be abandoned.

CLAMP EVERYTHING ON THE WAY IN. What arrives came from a browser, and a
browser can be a corrupted beacon. A negative speed is not a preference, it is
a broken player. Clamp to the same limits the interface itself uses, or the
server will quietly disagree with the app about what is legal.

---

## 3. One spoon at a time

Spoon equals step.

Do ONE step. Show it. Get his word. Then the next.

Do not run ahead building three features because they seem related. Do not
bundle a fix with an improvement nobody asked for. A step that is finished,
tested three times and shipped is worth more than three steps in flight.

If a step turns out to need another step first, say so and ask, rather than
quietly doing both.

---

## 4. Listen to Baba

When Marko states a requirement, implement THAT requirement. Not a
reasonable-sounding version of it.

Do not quietly keep a piece of the old behaviour because it still seems
useful. If part of it should stay, ship what was asked for and SAY what would
be kept and why. Never decide for him and stay silent about it.

If he has to ask twice, something has gone wrong that is worth writing down.

---

## 5. Say what was not tested

Every delivery names what is still unproven, as plainly as what works.

    "verified against a simulated am, not a real phone"
    "the clipboard permission flow lives in Chrome and cannot be tested here"
    "the browser UI is checked by code inspection only"

A confident report on an untested feature is worse than no report, because it
spends trust that has to be earned back later.
