# Working Rules

How work is done in this repo, and in any repo of Marko's. Set 17.8.2026,
fourth test added 18.8.2026.
These are not suggestions. If a rule and a deadline disagree, the rule wins.

---

## 1. Four tests before shipping

Every feature is tested FOUR times before it is delivered.

The four must PROGRESS. Running the same test four times proves nothing
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

    TEST 4    THE UPGRADE, FROM THE VERSION BEFORE
              Nobody installs this app fresh. Baba has a phone with the
              PREVIOUS version on it, a library of texts, a settings file, key
              files, caches, and quite possibly a server still running. So the
              test is not "does it install", it is "does it install OVER what
              is already there and leave every one of those intact".

              Install the previous version FOR REAL. Use it: make texts, change
              settings, let it write its files. Leave the server running. Then
              install the new version on top and prove:

                  every old text still opens and still reads
                  every setting survives, with its VALUE, not its default
                  key files survive the wipe and come back, still 0600
                  a file written by the OLD code is still understood by the NEW
                  a running server is stopped rather than left serving memory
                  every command is replaced, and no half-written .new is left
                  doing it a second time changes nothing and breaks nothing

              A feature that works perfectly on a clean install and loses his
              library is not a feature, it is an accident with a version
              number. Anything that changes the MEANING of a file already on
              his phone must be proved here or it is not done.

              Start the old server the way the LAUNCHER starts it, absolute
              path and all. Started any other way the installer cannot see it,
              and the test proves nothing about the phone.

Say what each of the four was and what it showed. If a test fails, fix it and
run ALL FOUR again, not just the one that failed.

Four is the number.

### Why these four, learned the hard way

Every real bug shipped from this repo would have been caught by test 3 or 4:

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

## 2c. Read his other repositories before inventing anything

Baba has more than 28 repositories and has ALREADY SOLVED most of the
recurring problems, usually better than a fresh idea will.

Before designing any parser, key ring, provider client, terminal screen,
installer menu or other shared mechanism: SEARCH HIS REPOS FIRST with the
GitHub API, read the existing implementation, and PORT it faithfully. Say in
the commit that it is a port and name the source.

Where the solved problems live:

    Key_Tester/.../KeyParser.kt   THE key parser, itself ported from TTT's
                                  MaKeys. Every app of his uses this shape.
    KEYRING                       encrypted vault, GitHub sync, biometric gate
    TTT_MINI                      Groq usage, Android keyboard patterns
    MA_READER_SPEECHIFY           SERVER_SCREEN.md, the terminal screen spec
    MA_READER_TERMUX_MACOS             the Speechify key ring, these rules

This rule was written on 19.8.2026 after I built a Groq key parser from
scratch that kept a URL, an email address, a file path and a row of identical
letters, and would have gravestoned all four as dead keys. The correct parser
already existed in his own repository and had for months.

---

## 2d. Give the terminal its echo back. Always.

A menu that reads ONE KEY has to turn echo off. If the script then dies
between turning it off and turning it back on, the terminal is left DEAF: the
person types and nothing appears on screen. They are typing correctly; the
terminal simply is not showing it. The damage outlives the script, survives
into every other command they run, and looks like the phone is broken.

This bug has been spreading through every app of Baba's that reads single
keys. It ends here. Two rules, both mandatory, both cheap.

FIRST: SAVE ONCE, TRAP EVERYTHING, ARM BEFORE YOU TOUCH.

    TTY_SAVED=""
    [ -t 0 ] && TTY_SAVED="$(stty -g 2>/dev/null || true)"
    tty_restore() {
      [ -n "$TTY_SAVED" ] && stty "$TTY_SAVED" 2>/dev/null || true
      [ -t 0 ] && stty echo 2>/dev/null || true
    }
    trap 'tty_restore' EXIT
    trap 'tty_restore; exit 130' INT
    trap 'tty_restore; exit 143' TERM
    trap 'tty_restore; exit 129' HUP

The trap is armed BEFORE the first stty. A trap armed afterwards has a hole in
it exactly where the bug lives. The second line of tty_restore is a belt as
well as braces: if the saved string is unusable, plain "stty echo" still gets
the person their keyboard back.

SECOND, AND THIS IS THE ONE EVERYBODY MISSES: NEVER USE stty raw.

    WRONG   stty raw -echo
    RIGHT   stty -icanon -echo min 1 time 0

Full raw mode also turns SIGNALS off. Ctrl+C stops being a signal and becomes
a plain byte, so the INT trap never fires, and the terminal stays deaf no
matter how carefully the traps were written. Measured: with "stty raw" a real
Ctrl+C left echo off in every test; with "-icanon -echo" all seven ways out
restored it.

THE OTHER CORRECT WAY is bash's own single-key read, which never touches
stty at all:

    IFS= read -rsn1 -t 1 K

-s does the silencing itself and puts it back when it returns. mareadweb uses
this; the installer, the updater and maread-adb use stty because they must
work under sh as well. Either is fine. What is NOT fine is stty raw, or stty
without a trap.

HOW TO TEST IT, since this cannot be checked by reading: drive the script
through a pty, write a REAL Ctrl+C byte (0x03) into the master, and then read
the terminal attributes and check the ECHO bit. Signalling the process
directly is not the same thing and will pass when the real case fails. Seven
ways out are worth checking: a normal exit, an unknown command, TERM, INT, a
real Ctrl+C while a key is being waited for, TERM while waiting, and HUP when
the app is closed.

---

## 2e. The delivery gate

modules/delivery-gate.md is the short form of all of this: every gate that
must be green before a release ships, each one carrying the incident that put
it there. Read it before a release and after any failure.

It is written to be portable. Nothing in it is specific to this app; any of
Baba's apps that read keys in a terminal, hold API keys, write settings or
replace themselves on update has the same failure modes.

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

## 3b. The wrong chat sanity check

Marko runs many projects in many chats at once, and sometimes types into the
wrong one. It is easily done and costs nothing IF it is caught in one line.

Before starting ANY work, check the request belongs to the project this chat
has been building. If it names a different app, a different repo, a different
domain, or a screen that has never appeared here, STOP.

Say it plainly and immediately:

    I think you are in the wrong chat. This one is <project>.
    Did you mean to send that to <the other thing>?

Then WAIT. Do not start work. Do not begin anyway on the theory that it might
be related. A question that costs him one word to answer is far cheaper than
work begun on the wrong thing, and much cheaper than a change made to an app
nobody in this chat has read.

SAY IT AS PLAINLY AS THAT. Not "this looks like it might belong elsewhere",
not a paragraph of hedging. Sorry, you are in the wrong chat. He asked for
exactly that wording, because a soft version invites him to say "just do it
anyway" and then both of us are working blind.

IDENTIFYING THE OTHER PROJECT IS ALLOWED AND WELCOME. Naming which repo it
probably belongs to costs one lookup and saves him hunting for the right tab.
What is not allowed is CHANGING it. Look, name it, stop.

    5.9.2026. He sent a screenshot of a SPEAK / TRANSCRIBE / KEYS screen with
    Gemini voices called Orus, Leda and Puck, and asked for four changes to
    it. None of that exists in MA Reader. It was GOOGLE_TTS_STT, his gtt app.
    Said so, named the repo, wrote his four requests down so they were not
    lost in the wrong chat, and stopped.

THE SECOND REASON, which matters as much as competence: TWO CHATS EDITING ONE
REPO COLLIDE. It has already happened here. A push to main was rejected
because another chat had shipped four commits underneath it, and the only
reason nothing was lost is that the rejection was investigated instead of
forced. Working on another project's repo from this chat invites exactly that,
in a repo this chat is not watching.

THIS CHAT IS: MA Reader Termux, the repo MA_READER_TERMUX_MACOS, a Flask server in
Termux read in a browser at localhost. Anything about a Streamlit app, a
transcription app, an Android keyboard, a book, a website or a music project
belongs somewhere else.

The same applies in reverse. If work here starts drifting toward another
project, say so rather than quietly widening the scope.

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
