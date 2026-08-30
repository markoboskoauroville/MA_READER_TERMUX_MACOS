# The delivery gate

Nothing ships until every gate below is green. Each one is here because it
FAILED IN PRODUCTION at least once, and each names the incident, so nobody has
to take it on faith or rediscover it the expensive way.

This is written for MA Reader Termux but none of it is specific to it. Any app
of Baba's that reads keys in a terminal, holds API keys, writes settings, or
replaces itself on update has the same failure modes.

Version of record: v3.33, 22.8.2026.

---

## 0. Before writing anything: read his other repositories

He has 28+ repos and has already solved most recurring problems, usually
better than a fresh idea will. Search first with the GitHub API, read the
existing implementation, and PORT it faithfully. Say in the commit that it is
a port and name the source.

    Key_Tester/.../KeyParser.kt   THE key parser, itself ported from MaKeys
    KEYRING                       encrypted vault, GitHub sync, biometric gate
    TTT_MINI                      Groq usage, voice tables, Android patterns
    MAHA_TRANSCRIBE_STREAMLIT     docs/WORD_TIMINGS.md, the timing method
    MA_READER_TERMUX_MACOS             the Speechify key ring, these rules

INCIDENT: a Groq key parser written from scratch kept a URL, an email address,
a file path and a row of identical letters, and would have gravestoned all
four as dead keys. The correct parser had been in his own repository for
months.

PORTING FAITHFULLY IS NOT PORTING BLINDLY. The same port carried three voice
ids that answer HTTP 404 on this account. Check every borrowed constant
against the live thing before shipping it.

---

## 1. The terminal must get its echo back

A menu that reads ONE KEY has to turn echo off. If the script dies in between,
the terminal is left DEAF: the person types and nothing appears, and the
damage outlives the script.

    GATE  every script that reads a key saves the tty state ONCE, before
          anything touches it, and traps EXIT INT TERM HUP to restore it
    GATE  the trap is armed BEFORE the first stty
    GATE  no `stty raw` anywhere. Use `stty -icanon -echo min 1 time 0`,
          or bash's own `read -rsn1`

WHY THE SECOND RULE: full raw mode also turns SIGNALS off, so Ctrl+C stops
being a signal and becomes a plain byte. The INT trap never fires and the
terminal stays deaf no matter how careful the traps are.

HOW TO TEST, because this cannot be checked by reading: drive the script
through a pty, write a REAL 0x03 byte into the master, then read the terminal
attributes and check the ECHO bit. Signalling the process directly is NOT the
same thing and will pass when the real case fails.

    measured: stty raw          → Ctrl+C mid-keypress left echo OFF
              -icanon -echo     → all seven ways out restored it

Seven ways out worth checking: normal exit, unknown command, TERM, INT, a real
Ctrl+C while waiting for a key, TERM while waiting, HUP when the app closes.

---

## 2. Settings must survive being interrupted

    GATE  writes are ATOMIC: temp file, fsync, rename over the top
    GATE  a .bak of the previous good copy, used when the main will not parse
    GATE  flushed on visibilitychange and pagehide with sendBeacon, never
          trusted to a timer alone
    GATE  every value CLAMPED on the way in, to the same limits the interface
          uses
    GATE  nothing is saved until the app has finished restoring

INCIDENT ONE: opening the file for writing truncates it at once, so a phone
frozen mid-write left half a file, which parses as nothing, which reads back
as FACTORY DEFAULTS. That is what losing every setting looks like.

INCIDENT TWO: on Android a backgrounded tab is FROZEN and pending timers never
run. A 250ms debounce lost anything changed in the last moment before the
phone went in a pocket.

INCIDENT THREE, the worst: the interface went live at bind() but the settings
were not restored until five requests returned. In that window the app ran on
FACTORY DEFAULTS, and any of the 34 places that call persist() wrote those
defaults over the file. A `booted` flag now gates every save path.

---

## 3. API keys

    GATE  keys arrive by FILE PICKER, never typed
    GATE  written 0600, never echoed, never logged, never committed
    GATE  the dead list stores SHA-256 FINGERPRINTS, never keys
    GATE  shape RANKS, it never discards: a long unknown token is still tried,
          because the next key format has not been invented yet
    GATE  a known-prefix key that gets 401 is dead and gravestoned; an unknown
          token that fails is SKIPPED for the session and never counted as a
          dead key
    GATE  the key file is in the installer's KEEP list

THE CANONICAL PARSER, ported from Key_Tester: split each LINE into TOKENS on
`[\s,;:"'=|\[\](){}<>]+`, classify each WHOLE token with anchored regexes, and
keep an unknown token of 24 to 220 characters ONLY IF it carries both a letter
and a digit. That single test is what rejects prose, emails, URLs, file paths
and rows of identical letters. The line above a key is its label.

INCIDENT: the Groq key file was not in the KEEP list, so every update wiped it
and the keys had to be re-added each time. Found only by test 4.

---

## 4. Replacing yourself

    GATE  a running server is DETECTED and stopped before files are replaced,
          not left serving old code out of memory
    GATE  commands are written to name.new and RENAMED over the top
    GATE  the process detector matches the real thing, not anything that
          merely mentions its path

WHY THE RENAME: a plain `cat >` truncates the file a running shell is reading
from, and it then carries on at its old byte offset into whatever is there
now. Measured: a 230 KB script overwritten while running stopped dead without
reaching its last line; the same script replaced by rename ran to the end.

WHY THE THIRD: `pgrep -f <path>` also matches an editor with the file open, a
tail on it, or any shell whose command line mentions the path, INCLUDING the
installer itself, which then refuses to run because it detected itself.
Require the path AND a python as the first token of the command line.

---

## 5. Talking to a provider

    GATE  the User-Agent is a browser. api.groq.com sits behind Cloudflare and
          answers 403 "error code: 1010" to Python's default agent on EVERY
          endpoint, which looks exactly like a ring of dead keys
    GATE  a 403 whose body mentions 1010 or cloudflare condemns NOTHING
    GATE  the model is DISCOVERED, never assumed: ask what exists today, drop
          what cannot hold a conversation, fall back to anything left
    GATE  a plausible answer is not a correct one. Gate it.

ON THE LAST: a recogniser can come back looking perfectly well formed and be
WRONG. It can mishear a whole clip, or return times that run backwards, and
interpolation then produces a smooth ramp of nonsense. An answer must earn its
place: enough of it matched, the values actually move, nothing lies outside
the bounds. Both failures were seen in testing before the gate was written.

---

## 6. The four tests

Three is not enough and one is theatre. Every feature passes four, and they
must PROGRESS rather than repeat.

    1  THE MECHANISM ALONE, with inputs by hand. No app, no network.
    2  INSIDE THE RUNNING APP with real data and real keys.
    3  THE UGLY CASES: empty, missing, corrupt, refused, offline, hung,
       out of order, twice in a row, out of range.
    4  THE UPGRADE, which is the one that gets skipped and the one that
       breaks his phone.

TEST 4 IS NOT OPTIONAL AND NOT A SUMMARY. Install the PREVIOUS version for
real, USE it, leave its SERVER RUNNING, then install over the top and prove:

    the running server is stopped, not left serving memory
    every command replaced, no half-written .new left behind
    key files survive and are still 0600
    every old text still opens and still reads
    files written by the OLD code are still understood
    every setting keeps its VALUE, not its default
    a second install changes nothing and breaks nothing

Say plainly what was NOT tested. "I could not test this on a real phone" is a
finding, not a failure.

---

## 7. When a test fails, believe it

A failing test is a gift. The instinct to explain it away is the enemy.

But equally: when the test is wrong, FIX THE TEST, do not change correct code
to match it. Two tests in one session cried wolf. One sent SIGINT to a shell
instead of writing a Ctrl+C byte; the other looked for a trap by name when the
code called its restore from a differently named function. Both were recorded
rather than quietly corrected, because a test that cries wolf is worse than no
test.

---

## 8. Before the push

    GATE  bash -n on the installer, node --check on the script, py_compile
          on the server
    GATE  every NEW NAME grepped for: defined, and called. A syntax check
          passes a ReferenceError happily
    GATE  no duplicate function names. In Python the later definition silently
          wins and the symptom is a TypeError about argument counts
    GATE  a clean install, then a second install over it
    GATE  the version bumped, in all three places, by bump.py
    GATE  the handover updated in the same commit
    GATE  every key copy shredded, and VERIFIED gone by searching for the key
          material itself rather than the filename

INCIDENT: a patch script printed all its successes, then hit a bad anchor and
exited BEFORE writing the file. Its work was silently lost while a follow-up
script had already written edits that depended on it. The result referenced a
constant that no longer existed. The syntax check passed it; the running app
would have thrown on the first sentence.

RULE THAT FOLLOWS: validate every anchor BEFORE writing anything, so a failure
cannot leave the file half-changed.

---

## 9. The habits underneath

ONE SPOON AT A TIME. Do one step, show it, get his word, then the next.

LISTEN TO BABA. Implement the stated requirement, not a reasonable-sounding
version of it. If part of the old behaviour should stay, ship what he asked
for and SAY what would be kept. Never decide for him quietly.

REAL KEYS ONLY. Ask him for the file, test against the live API, then shred
every copy and confirm the shred. Never invent a key to make a test pass.

SAY WHAT YOU DID THAT HE DID NOT ASK FOR. Name it so he can take it out.

RIGHT CHAT. Before starting any work, check the request belongs to the project
this chat has been building. If it names a different app, stop and say so.
