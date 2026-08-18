# The Four Tests

How to test anything before shipping it. Written to be carried into any
project, any language, any app. Nothing here is specific to MA Reader; the
examples come from it because that is where the lessons were paid for.

Written 18.8.2026.

---

## The principle, in one line

**Four tests, and each one must be able to fail while the other three pass.**

That is the whole idea. Everything below is a way of arriving at four tests
that genuinely have that property.

The number four is not sacred. What is sacred is that the tests PROGRESS.
Running the same test four times proves only that the computer is
deterministic, which was never in doubt. Four tests that all check the happy
path from slightly different angles is one test wearing four hats.

Before writing any test, ask the only question that matters:

    WHAT COULD BE TRUE THAT WOULD MAKE THIS TEST PASS
    AND THE FEATURE STILL BE BROKEN?

Every one of the four exists to close off one specific answer to that
question. Once you see them that way, you can derive them yourself rather than
remembering a list.

    TEST 1 closes    "the logic is wrong"
    TEST 2 closes    "the logic is right but nothing calls it"
    TEST 3 closes    "it works when the world behaves"
    TEST 4 closes    "it works on a machine that has never run the old version"

---

## The four

### TEST 1 — THE MECHANISM, ALONE

The logic on its own, outside the app, with inputs chosen by hand. A pure
function, a parser, a state machine, a rule of arithmetic, a regex, a
calculation.

No server, no network, no user interface, no database. If you cannot run the
thing without starting the whole application, that is itself a finding: the
logic is tangled into the plumbing and should be pulled out.

**What it catches.** Wrong rules. Off-by-one. A regex that matches more than
you meant. A boundary at zero, at one, at empty.

**What it CANNOT catch.** Whether the function is ever called. Whether it is
wired to the right button. Whether the real data looks anything like your
hand-written inputs.

**How to invent the cases.** Write down the rule the thing claims to follow,
then attack the rule itself:

    the case it is FOR              the obvious one, once
    the case it must REFUSE         and this is where most bugs live
    both sides of every boundary    0 and 1, empty and one item, the limit
                                    and the limit plus one
    two rules colliding             what if both conditions are true at once
    the same input twice            is it idempotent, and did you claim it was

A worked example. A detector decided whether pasted text was Markdown, using
"one strong signal, or two different weak ones". Test 1 fed it fourteen pieces
of ordinary prose that must NOT be Markdown, and twelve documents that must
be. One failed: a plain paragraph followed by a line of dashes was called
Markdown. Two of the weak signals were the same dash line read two ways, a
thematic break and a heading underline. Two hints drawn from ONE construct are
not two hints. The fix was to group the signals into families, each counting
once — a rule change that no amount of end-to-end testing would have located,
because end to end you would only have seen "it formatted something it should
not have" without knowing why.

### TEST 2 — INSIDE THE RUNNING APP, WITH REAL DATA

Wired up, end to end, against the real server, the real API, the real file
system. Not a mock.

**Drive it the way a person does.** Do not call the function under test. Press
the button that is supposed to call it. This is the difference between "the
function works" and "the feature works", and the gap between those two is
where an enormous number of shipped bugs live.

**Real dependencies, or the test is fiction.** A mocked API proves your mock
agrees with itself. If the feature needs a key, use a real one, then destroy
every copy afterwards and confirm the destruction by hunting for it. Never
invent a key to make a test pass. The one honest use of a fake credential is
testing the FAILURE path, and even then take a real one and change its last
four characters, so the shape and the rejection are both real.

**Find a number the outside world will confirm.** The strongest test 2 is one
where an independent party agrees with you. When proving that a text-to-speech
service was being sent clean text and not raw Markdown, the decisive check was
not reading the output — it was the provider's own billed character count.
It came back 254 against a source of 498, and 254 was exactly the length of
the cleaned string. The service counted the characters it received, and it
agreed. Look for that kind of number: a byte count, a checksum, a row count,
a receipt, a log line written by something you do not control.

**What it CANNOT catch.** Anything about failure, because you are testing the
path where everything works.

### TEST 3 — THE UGLY CASES

This is the one that earns its keep. Failure, empty, offline, restart, wrong
order, breaking halfway, the user doing it twice, the value out of range, the
file missing, the network hanging and never answering at all.

**The generator questions.** Do not try to be creative. Go down the list:

    EMPTY           nothing, whitespace, a file of zero bytes, an empty list
    ENORMOUS        a thousand times the expected size, one line of 20,000 words
    MALFORMED       truncated halfway, unclosed, wrong type, wrong encoding
    HOSTILE         input written by someone who wants to break in
    TWICE           the same action twice in a row, and two at the same moment
    OUT OF ORDER    step two before step one, cancel before start
    ABSENT          the file, the network, the permission, the dependency
    NEVER ANSWERS   not an error - no reply at all, forever

**"Never answers" deserves its own paragraph** because it is the one people
skip. A promise that neither resolves nor rejects has no catch handler that
will ever run. A socket that accepts and then goes quiet is not a failure your
error path will see. Any wait on something outside your process needs a
deadline, and the deadline needs its own test. A paste button that looked
completely dead was exactly this: the clipboard call never answered, so the
failure branch was never reached and the fallback never appeared.

**Sabotage your own system on purpose.** Delete the file the feature depends
on and check it degrades to the old behaviour rather than showing a blank
page. Revoke the credential halfway through and check it rolls on. Then, when
you count errors at the end, remember to exclude the one you caused yourself —
or your own sabotage will be reported as a bug.

**Prove the degradation is the RIGHT degradation.** Do not settle for "it did
not crash". A wrong answer delivered confidently is worse than no answer. When
two components can disagree about their coordinates, the correct behaviour is
to notice the disagreement and do less, not to carry on and highlight the
wrong words. Test the invariant itself: "it acts only when the two agree."

### TEST 4 — THE UPGRADE, FROM THE VERSION BEFORE

**Nobody installs your software fresh.** They have the previous version, with
their data, their settings, their credentials, their caches, and quite
possibly the old process still running. The test is not "does it install". It
is "does it install OVER what is already there and leave every one of those
intact".

This test is usually missing, and it is the one whose failures hurt most,
because the cost is not a broken feature but lost work belonging to someone
who trusted you.

**How to run it.**

    1  install the PREVIOUS version, for real, not a simulation of it
    2  USE it: make data, change settings, let it write its own files
    3  leave it RUNNING
    4  install the new version on top
    5  check everything

**The checklist.**

    all old data still opens, and still means the same thing
    every setting keeps its VALUE, not its default
    credentials survive, and survive with their permissions
    a file written by the OLD code is still understood by the NEW
    a running process is stopped, not left serving stale code from memory
    every executable is replaced, including the one currently running
    no half-written temporary file is left behind
    doing it a second time changes nothing and breaks nothing

**The trigger that makes this test mandatory.** Any change to the MEANING of
something already on the user's disk. Not the format — the meaning. A field
that used to hold cleaned text now holding raw text is the same type, the same
name, the same size, and a completely different thing. No clean install can
detect that, because on a clean install there is nothing old to misread.

**Verify the OLD version is really old.** Assert its version number, and
assert the absence of the new feature, before you use it. Otherwise you may
have installed the new version twice and proved nothing.

**Reproduce the real conditions exactly.** Start the old process the way the
real launcher starts it. In one run the old server survived the upgrade and it
looked like a serious bug — the detector had missed it. It had missed it
because the test started the process with a relative path while the real
launcher uses an absolute one. The app was fine; the test was lying. Any
detail the system keys on — the path, the port, the user, the working
directory — has to match reality or the test proves nothing about reality.

---

## The meta-rules

### 1. Test the test

Roughly half of all "failures" you find will be in the test, not the code.
That is normal and healthy. What is dangerous is the opposite: a test that
PASSES for the wrong reason. Those are invisible and they rot.

Real examples, all from a single feature's development:

    a cleanup command matched its own shell's command line and killed the
      process that was running it, so every attempt died silently with no
      output at all and no error to read

    keypresses were fed to an installer on a timer rather than on the prompt.
      An answer meant for one question was read by a different question, which
      took it as "change nothing". The installer correctly changed nothing —
      and the test, which was grepping for words that did appear, PASSED

    a killed child process that was never reaped stays as a zombie, and
      asking the operating system whether that process exists returns yes.
      "The old process was stopped" failed when it had in fact stopped

    an expected version number was hardcoded, so the test failed the moment
      the version was bumped, for no reason connected to the feature

The habit that catches these: after a test passes, **make it fail on purpose**.
Break the thing it is watching and confirm it goes red. A test you have never
seen fail is a rumour.

### 2. Expectations come from the previous behaviour, not from your taste

When you assert what the system should do, do not write what seems reasonable.
Go and measure what the previous version actually did, and assert that, unless
you have deliberately decided to change it.

A test once expected a lone hyphen to be rejected as empty input. It was
accepted. That looked like a bug — until the old version was executed on the
same input and accepted it too. The behaviour was unchanged and the
expectation was invented. Had it been "fixed", a silent behaviour change would
have been smuggled in alongside an unrelated feature.

When a test does fail, the first question is not "how do I fix the code". It
is **"is this a regression, or was it always like this?"** Answer it by running
the old version, not by reasoning.

### 3. If one fails, run all four again

Not just the one that failed. A fix is a change, and a change can break
anything. This costs minutes and buys the only thing that matters, which is
that the four green results all describe the same build.

### 4. Say what you did NOT test

Every delivery names what is still unproven as plainly as what works.

    "the visual layout is code inspection only, it lives in a browser"
    "one of the two engines was never exercised, it is not installed here"
    "the permission dialog belongs to the operating system and cannot be
      reached from a test harness"

A confident report on an untested feature is worse than no report, because it
spends trust that has to be earned back later. If you cannot test something,
say so once, clearly, and let the person decide whether that matters.

### 5. Keep the count and show it

"Four tests: 202, 69, 47, 53 passed, 0 failed" is worth more than four
paragraphs of reassurance. It is checkable, it is comparable to last time, and
a number that drops is a question somebody will ask.

---

## Adapting the four to other kinds of work

The four questions survive the change of domain; only their clothes change.

    A DATA PIPELINE
      1  the transform on ten hand-made rows
      2  the real pipeline on real source data, row counts reconciled
      3  nulls, duplicates, wrong types, a source that half-loads and stops
      4  yesterday's output still parses, and a re-run produces the same thing

    A WEB API
      1  the handler function, called directly
      2  a real request over real HTTP against the real database
      3  malformed body, missing auth, huge payload, two identical requests
         arriving at once
      4  the previous client version still works against the new server

    A DOCUMENT OR A BOOK
      1  does each claim stand up on its own
      2  read it start to finish as a reader, not as its author
      3  read only the headings; read it on a phone; read it out of order
      4  does it still agree with the previous edition, and with the thing it
         describes, which has since changed

    A PIECE OF MUSIC OR A FILM
      1  the part alone, the loop, the single cut
      2  in the whole piece, at real volume, on the real system
      3  on the worst speaker anyone will use it on, in a noisy room, quiet
      4  next to the previous version, so the change is a change and not
         merely a difference

---

## The shortest version

    1  Does the thing itself work?
    2  Does the app actually use it, for real, with real data?
    3  What happens when the world misbehaves?
    4  What happens to the person who already had the old one?

Four answers, four ways to be wrong, and each able to fail while the others
pass. If two of your tests cannot fail independently, you have three tests and
a duplicate.
