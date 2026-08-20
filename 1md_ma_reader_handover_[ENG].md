# MA Reader Termux, Handover

State of the app as of 18.8.2026, v3.14, everything in it verified. This file is rewritten on
every push. If it disagrees with the code, the code is right and this file is
a bug.

    repo      https://github.com/markoboskoauroville/ma-reader-thermux
    install   3sh_i_ma_reader_v3_termux.sh
    edition   v3

## Before anything else

Read 1md_working_rules_[ENG].md. FOUR progressing tests before shipping, real
keys only and shredded after, one spoon at a time, and say what was not
tested. Those rules bind whoever picks this up next.

The fourth test was added 18.8.2026 and is THE UPGRADE: install the previous
version for real, use it, leave its server running, then install the new one
on top and prove the library, the settings, the key files and the running
process all end up where they should. It exists because v3.11 changed what
text.txt MEANS, and a change like that cannot be proved on a clean install.

## What it is

A reader for Termux on Android. Paste text, it speaks it and lights each word
as it is spoken. Served from a local Flask server, read in the browser at
localhost. Built for one workflow above all others: article after article, all
day, one thumb.

## Install and update

First time, one paste:

    pkg install -y curl && curl -fsSL -O https://raw.githubusercontent.com/markoboskoauroville/ma-reader-thermux/main/update.sh && bash update.sh

After that, forever:

    maread-update     ask, then install if told to
    mareadweb         run it
    maread-adb        set up a privileged shell for the media keys

Installing is a WIPE, not an overwrite. It stops any running server, carries
keys and settings out, deletes the app folder, writes it fresh, puts the kept
files back. The library at ~/.maread is never touched.

## Shape

The installer is one shell script holding exactly three files:

    ~/.maread-web/server.py            Flask, about 3000 lines
    ~/.maread-web/static/index.html    one file, all CSS and JS inline
    ~/.maread-web/static/marked.umd.js the Markdown parser, vendored whole

Commands land in $PREFIX/bin: mareadweb, maread-update, maread-adb.
Texts and clips live in ~/.maread, shared with the terminal MA Reader.

## The engine, and why it is like that

1. ONE CLIP PER SENTENCE, IMMUTABLE, CACHED under (tid, vkey, index) and never
   regenerated. This is why changing speed or a pause or jumping around costs
   nothing. Do not merge this into one long mp3.

2. EDGE LIES ABOUT WORD TIMES. edge-tts reports boundaries from its own model
   and they drift, so every Edge clip is decoded after it is made and every
   word re-pinned to the real waveform. That is refine_tokens(). Speechify does
   not need this: its speech marks land exactly on the source characters,
   verified character for character, so they are used as given.

3. THE SILENCE MAP. measure_silence() records every quiet stretch between
   words using a two band envelope, pulled inward 18 ms at both ends so its
   edges are certainly silent. The word pause rides on it.

4. THE WORD PAUSE IS A REAL PAUSE. The player stops the mp3 inside a measured
   silence, waits, and plays it again. playbackRate is NEVER touched on that
   path. The old version raced through the quiet by changing rate and it
   clicked, chirped on consonants, and muted outright below about a quarter
   speed on some Android webviews. Range 0.00 to 2.00, upward only, because
   there is no way to have less silence than the voice recorded.

5. THE SENTENCE PAUSE can go negative, which is a real overlap: the next clip
   starts before the current one ends. That needs two audio elements sounding
   at once, which is why there is a pool of players rather than one.

## Two engines

Settings opens on two buttons and the cards below follow whichever is chosen.

    Edge        free, keyless, English and Croatian, two voices each. Times
                re-pinned to the waveform.
    Speechify   keyed, English only, UK and US. Brings its own word times.

Both appear on the top row together whenever each has voices to show:
Speechify first, Edge below, each scrolling on its own. Tapping a voice from
either row moves the engine to match it.

### The reading language

THREE STATES, one button: ENG, HR, AUTO. AUTO asks Groq whether the text is
English; anything that is not English is Croatian, because those are the only
two languages this app reads.

THE BUTTON IS PAINTED IN EXACTLY ONE PLACE, renderLangBtn. It used to be
painted inside applyEngineCards, which setPane calls and setLang does not, so
the language changed, the toast fired, and the button went on showing the old
word. One painter, called by everyone who can change the language.

## Word timing, MEASURED IN THIS REPOSITORY

2py_word_timing_lab.py is the experiment. Speechify returns exact speech marks
with its audio, so its own rendition is the only ground truth available; Edge
marks cannot be checked this way because a different voice says the same
sentence differently. So Speechify audio is the test subject, its marks are
the truth, and every candidate is handed nothing but the mp3 and the words.

GROUND TRUTH, 80 words over 6 sentences:

    proportional   mean 297 ms   median 204 ms   19% within 50 ms
    pcm2           mean 329 ms   median 215 ms   10% within 50 ms
    whisper        mean  80 ms   median  44 ms   56% within 50 ms

That reproduces MAHA_TRANSCRIBE_STREAMLIT's held-out result (79 ms mean, 48 ms
median) on different sentences and a different voice, which is about as good a
confirmation as an independent measurement gets.

ON EDGE AUDIO, with Whisper as the yardstick, 53 words:

    edge marks           mean 214 ms   median 87 ms
    edge marks + pcm2    mean 217 ms   median 92 ms

THE WAVEFORM REFINEMENT WAS TURNED OFF where the engine gives marks. It costs
a full waveform pass per sentence and buys nothing: three milliseconds worse
on Edge marks, and worse than plain proportional timing when it starts from a
flat guess. It is kept for the case it was built for, a clip with no marks at
all. This reproduces independently what that repo measured (88 against 89 ms)
and explains itself: there is no acoustic gap at a word boundary to snap to,
because speech does not stop between words.

## Word timing: three layers

Ported from MAHA_TRANSCRIBE_STREAMLIT ttt/wordtimes.py. Its docs/WORD_TIMINGS.md
carries the measurements and the failed approaches and should be read before
changing any of this.

    1  engine marks          Edge WordBoundary, Speechify speech marks
    2  Whisper timestamps    groq whisper-large-v3-turbo, median 48 ms
    3  proportional          always available, median 119 ms

The counter-intuitive parts, so nobody rebuilds them: speech has NO silence
between words (99.2 per cent of inter-word intervals measure exactly zero), so
hunting for boundaries in the amplitude envelope finds stop consonants instead
of words; and snapping anchors to low-energy frames afterwards measured 88 ms
against 89 ms unrefined, which is no improvement at all.

Layer 2 runs when the bounds are asked for, which is the moment before the
sentence is read. It is paid for ONCE per sentence per voice: the answer is
written into the same json the highlight already reads, so a re-read costs
nothing, and a wt_tried flag means even a failure is never retried. The
language is told to Whisper, taken from the voice, falling back to the app's
setting and resolving AUTO through whatever it last decided.

THE GATE, which is this app's addition to the method. The reference assumes
the call either works or fails. It can do a third thing: come back looking
well formed and be WRONG. Whisper can mishear a whole clip, or return times
that run backwards, and the interpolation then produces a smooth ramp of
nonsense or a row of identical numbers, freezing the highlight on one word for
a whole sentence. So an answer must earn its place on three counts: at least
half the displayed words actually matched, the times actually move across the
clip, and no start lies beyond the audio. Anything else is refused and the
engine marks are kept. Both failures were seen in testing before the gate was
written.

## One picker, and the router behind it

ONE file picker for the whole app, at the top of Settings. A key file is a
working note, not a machine file, so keys are found inside whatever text
surrounds them, each is CLASSIFIED BY ITS OWN SHAPE, and each is filed into
the provider that can use it. Nobody is asked which provider a key belongs to,
because the key already says.

Ported from TTT_MINI ttt/keyring.py and Key_Tester KeyParser.kt.

The app uses exactly two providers. A key for anything else is recognised,
REPORTED, and not stored, so it is clear it was understood and simply not
needed here. An unknown token could be a rebranded key for either provider, so
it is offered to both and shown as "?" rather than "live": a wrong guess costs
one refused request, a discarded key costs the key.

The list beneath the picker IS THE FALLBACK ORDER. The first live key does the
work; if it is refused the next takes over. Each row shows the provider, its
position, a masked key, the label taken from the line above it in the file,
and its state.

## Gemini is gone

Removed entirely: the key store, the cost-aware model router, the price table,
the usage tally, all four routes, the settings card, the Help section and the
KEEP entries. Roughly 290 lines of server code. The only mention left is the
key parser's Google label, which is correct: it still recognises a Google key
in order to report that this app does not need one.

## Groq

Used for one question only. GROQ IS SPELLED WITH A Q.

THE USER AGENT IS NOT OPTIONAL. api.groq.com sits behind Cloudflare, which
blocks Python's default agent and answers 403 with "error code: 1010" on every
endpoint including /models. That looks exactly like a ring of dead keys and is
not a key problem at all, so a 403 whose body mentions 1010 or cloudflare is
recorded as a request-shape problem and condemns nothing.

THE MODEL IS DISCOVERED, NEVER ASSUMED. A preference list is tried first, but
the app asks /models for what exists today, drops anything that cannot hold a
conversation (whisper, orpheus, prompt-guard, safeguard), and falls back to
ANY remaining model. If every preferred name is retired the app finds the
replacement by itself and remembers it. Measured order, fastest first:
groq/compound-mini, allam-2-7b, openai/gpt-oss-20b, groq/compound,
openai/gpt-oss-120b, qwen/qwen3.6-27b.

ANSWERS ARRIVE IN DIFFERENT SHAPES. The gpt-oss pair put reasoning in a
separate field and leave content empty unless given token headroom; qwen
writes <think> aloud inside the content. Both are handled, and a model that
will not answer plainly is skipped rather than trusted.

NOBODY ANSWERING IS NOT AN ANSWER. If no key, no network or no model can be
had, the app reads the text itself with looks_croatian rather than guessing
English and mangling a Croatian page. Text with fewer than eight letters is
never sent at all: a model asked whether 12345 is English says no, quite
correctly, and no here would mean Croatian.

THE PARSER IS A PORT of Key_Tester/KeyParser.kt, which is itself ported from
TTT's MaKeys. It is line-aware and token-level: each line is split on
separators so quotes, commas and brackets fall away and a key pasted out of a
line of code still works; each WHOLE token is classified with anchored
regexes; and the line above a key becomes its label, verbatim, which is how
"Auroville community." names the key beneath it.

A long token of an unknown shape is KEPT, because the next key format has not
been invented yet, but only if it carries BOTH a letter and a digit within 24
to 220 characters of the credential alphabet. That single test is what rejects
prose, an email address, a URL, a file path and a row of identical letters.

STRONG AND WEAK. A gsk_ token is strong: a 401 on it means the key is dead and
it is gravestoned. An unknown token is weak: it is still tried, but a failure
skips it for the session rather than carving it into the dead list, and it is
never counted in the dead total. Without this, a file with a comment line in
it would report six dead keys that were never keys.

Keys arrive by FILE PICKER, never typed, written 0600, never echoed. The dead
list stores SHA-256 fingerprints, never keys. 401/403 condemns, 429 rests the
key five minutes. Keys can arrive wrapped in quotes and trailing commas from
being pasted out of code, so they are unwrapped: Baba's own file holds every
key twice, once bare and once quoted.

ONE button beside the three tabs at the top of Settings, the same size and
shape as them. It shows the language IN FORCE, ENG or HR, and pressing it
flips to the other. It is always lit, because it names a state rather than a
destination.

It was a split control with two halves. That put two small zones where one
whole button belongs, and half of it was always the wrong half to press.

It says which language the app is reading, and everything follows from it.

    ENG   Edge offers Sonia and Ryan; Speechify offers the ticked voices
    HR    Edge offers Gabrijela and Srecko; Speechify offers the Croatian
          pair, because it has no Croatian voice of its own and those two
          auditioned foreigners ARE the whole set

A voice that cannot pronounce what is on screen has no business being offered,
and certainly none sitting on the top row where a pocket can press it. So the
filter applies to the top row and to both grids at once.

Changing the language leaves a usable voice behind and prefers the engine
already in hand: someone on Speechify who switches wants the Croatian seat,
not to be thrown across to Edge. With no Edge language ticked at all, the
Croatian seats remain, so there is always something to read with.

A Croatian seat is not a catalogue voice; it never becomes ST.voice. It is a
choice of WHICH foreign voice reads Croatian, stored as croVoice, and
voiceIsCurrent answers for it separately.

THE SWITCH IS THE AUTHORITY. Only AUTO is automatic; that is the whole point
of having three settings rather than two.

    ENG    the English voice, always, even on a Croatian page
    HR     the Croatian voice, always, even on an English page
    AUTO   whatever Groq decided, applied to the whole text

reading_lang() answers that question in one place and everything else asks it:
which voice speaks, which model it is asked for, and which language Whisper is
told when it times the words.

This was wrong until v3.27. sp_voice_for asked looks_croatian about every
sentence no matter what the switch said, so ENG quietly handed Croatian
sentences to the Croatian voice and a person who had pressed ENG was overruled
by a guess. looks_croatian now serves one purpose only: the local fallback for
AUTO when Groq cannot be reached.

A consequence worth knowing: a document that mixes the two languages is read
in ONE voice, chosen by the switch, rather than switching sentence by
sentence. That is the price of the switch meaning what it says.

### The voices are two short lists

Ported from TTT_MINI MaSpeechify.kt. Radio rows under two headings, Croatian
and English, four each, ordered as Baba ranked them by ear so the first entry
is the shipped default. The paged catalogue, the accent buttons, the tick
boxes and the separate Croatian card are all gone: a radio says plainly which
one is chosen where a grid of chips has to be read twice.

    English    Beatrice · Imogen · Edmund · Hugh
    Croatian   Lesya (uk) · Beatrice (gb) · Dominika (pl) · Daria (ru)

English is listed FIRST. The order of a list is a claim about what matters,
and English is the language read most.

BEATRICE IS IN BOTH LISTS, on a different model in each: simba-multilingual
for Croatian, simba-english for English. She is one voice with two jobs, and
that is the reason the model belongs to the VOICE ROW rather than to a global
default.

THE IDS CARRY THE _32 SUFFIX. TTT_MINI's table lists imogen, edmund and hugh
bare, and three of those answer HTTP 404 on this account; the curated British
voices are published as imogen_32, edmund_32 and hugh_32. Checked against the
live catalogue rather than copied. All eight seats were spoken for real before
this shipped.

Each row has a play button and THE VOICE SAYS ITS OWN NAME, "Hi, I am Lesya",
which tells the accent, the pace and the warmth in four words and ties the
sound to the row being looked at. The Croatian rows say it in Croatian.

### Croatian

Speechify has no Croatian voice at all: 985 voices walked, no hr-HR on any
model. So a foreign voice reads it, and a control under Speechify picks which.
Lesya, Ukrainian female, is the default; Beatrice, UK female, is the second
choice. Both are asked for on simba-multilingual. Each row has a play button
that speaks one fixed Croatian sentence chosen to exercise every sound English
gets wrong, so the two can be compared by ear without leaving Settings.

The choice applies per SENTENCE, so a document that mixes the two languages
switches voice as it reads. English is entirely unaffected.

### The Speechify key ring

Lazy. Nothing is tested in advance. The first key not already known to be dead
is used, and keeps being used until a request comes back 401 or 403; only then
is it condemned to a list on disk, permanently, and the ring rolls forward and
repeats the request. A dead key costs one wasted request in its whole life.
429 rests a key for five minutes rather than killing it. The dead list is
keyed by SHA-256 fingerprint and stores only a mask, so it gives up nothing.
Settings shows it with Retry and Remove.

The catalogue is fetched by walking the pagination cursor. /v1/voices defaults
to 50 and 50 alphabetically is all A names, which is one en-GB voice out of the
33 that exist. The four voice buttons are a window onto the whole list, paged
four at a time, ordered by Speechify's own curated set then its popular set
then by name, zipped so every full page is two women and two men.

Model is simba-english, NOT simba-3.2. The docs recommend 3.2, but measured
against the live API it answers HTTP 400 for any voice whose id does not end
_32, which is almost the whole catalogue.

Full detail in 1md_speechify_engine_handoff_[ENG].md, written to be portable
into other projects.

## The reading loop, one thumb

The floating P is the whole workflow and changes face to say which half it is
on.

    out of full screen    a P. Press: take the clipboard, replace what is
                          loaded, go full screen, start reading.
    in full screen        the full screen glyph. Press: leave, and pause.

Full screen and reading are the same state here. Leaving pauses, going back in
plays. The button is draggable and its position is kept as a fraction of the
screen so it survives turning the phone.

FULL SCREEN MEANS FULL SCREEN. Every direct child of the body is hidden and
only the few allowed to stay are named: the text, the floating button, the
toast, and the paste catcher when it opens itself. Inside the reader, every
child of the view is hidden except the scrolling text. Anything added to this
app in future is hidden by default and has to argue its way back on. The rule
used to name the things to hide, which is a list, and lists go stale; that is
exactly how the player bar and voice strip survived into full screen.

The browser's own furniture is handled by the real Fullscreen API, requested
inside the gesture, before the clipboard is read, because asking after it
resolves is refused. Installed to the home screen the request is skipped
entirely: there is no tab to hide, and skipping it also avoids Chrome's own
banner about how to leave full screen, which is drawn by the browser above the
page and cannot be dismissed from here. In a plain tab that banner comes with
the territory and no page can remove it. It is still not absolute: Chrome restores its bar when it
feels like it. The cure is Chrome menu, Add to Home screen. The app ships a
manifest with display standalone, so opened from that icon it has no browser
interface at all.

## The clipboard, and the trap

navigator.clipboard.readText() can do five things and all five are handled:

    no API at all           fall back to the catcher
    resolves with text      use it
    resolves empty          catcher
    rejects                 catcher
    NEVER ANSWERS           catcher, after a 1.2 second deadline

The last one is what actually happened on the phone. It neither resolves nor
rejects, so catch() never fires and the button looks dead. A settled flag stops
a late answer firing twice.

The catcher is a panel with a real textarea, already focused. Long press,
choose Paste, and reading starts the moment text lands. That path works in any
browser because it is only a text field.

## Other features

    three modes         read, text, edit on the left, play in the middle,
                        speed on the right
    time to read        "12 / 47   8:30", measured from clips already spoken
                        and estimated at 14.5 characters a second for the rest,
                        with speed and both pauses folded in. Pressing it
                        clears the session; nothing is lost, the text is in the
                        Archive.
    swipe               steps a sentence. Still works, a swipe is not a tap.
    tap text to paste   optional, same paste path as the floater
    offline tab         export a text as mp3 per sentence plus json, read it
                        back with no network
    Chrome on launch    mareadweb asks for Chrome by name, falling back to the
                        phone default. Override in Settings, Advanced.
    terminal hotkeys    while running: O open in Chrome, A open in the default
                        browser, Q stop
    media session       lock screen and headphone buttons drive the reader
    resume my music     optional. Stopping the music is free, Android does it.
                        Starting it again needs a privileged shell, see below.

## The media keys, honestly

Android will not take a media command from an ordinary app. Developer options
grant shell privileges without root two ways, both needing setup once per
reboot: Shizuku with its rish shell, or Termux's own adb over Wireless
debugging connecting to 127.0.0.1. maread-adb is a keypress menu that finds the
port by mDNS, pairs, connects and reports which route the phone accepts.

/api/mediakey walks seven routes and remembers whichever answers. It prefers
"cmd media_session dispatch play" over a key press, because that speaks to the
media session instead of throwing a key at whatever is listening.

TRAP, twice now: am and cmd print their failures and still exit zero. Read the
output, not just the exit code.


## Markdown, all four phases: it renders, it is one text, it lights up,
## and it knows what not to read

The reader shows pasted Markdown FORMATTED, the words spoken are the same
words that are wrapped in spans, and the sentence and the word light up as it
reads. All four phases are in. What is still open is named at the bottom of
this section.

WHAT CHANGED ON THE SERVER. text.txt used to hold the CLEANED text, because
api_prepare cleaned the paste before saving it. That threw the Markdown away
at the door and left nothing to format later. It now holds what was PASTED,
markers and all, and everything derived from it - title, char count, unit
count, sentences - is still taken from the cleaned form, so nothing
downstream ever sees a hash or an asterisk. text_payload carries the raw
`source` alongside the cleaned `sentences`.

Texts saved by v3.10 and earlier hold already-cleaned text. Their source is
therefore plain, the detector says so, and they open exactly as before.

MARKED IS VENDORED WHOLE, at static/marked.umd.js, 43,897 bytes, sha256
eaccee2f…3982a, version 18.0.10. Note the NAME: upstream no longer ships a
marked.min.js. Modern marked ships lib/marked.umd.js and that is the same
self-contained no-build-step file under a different name. Not markdown-it,
which is three times the size, and not snarkdown, which was abandoned in 2022.
Served from disk, never from a CDN, because the phone is often offline.

WHEN IS IT MARKDOWN. Plain text must come through completely untouched, so
one weak hint is never enough: a hyphen list and an emphatic *word* both
appear in ordinary pasted articles.

    STRONG, decides on its own      # heading, ``` fence, [text](url), an
                                    image, a table delimiter row
    WEAK, needs two DIFFERENT ones  bullets, > quotes, **bold**, *italic*,
                                    `code`, --- rules, setext underlines

The weak ones are grouped into FAMILIES and each family counts at most once.
That is not tidiness, it is a bug that was caught: "The end.\n---\nAnother
thought" matched the thematic-break rule AND the setext-underline rule, which
are the same single dash line read two ways, and two hints drawn from one
construct carried a plain paragraph over the line on its own.

PARSED ONCE. marked.parse runs exactly once per text, in renderDoc, and the
result is never re-parsed while reading. Rewriting the source with markers and
re-parsing per word would lose the scroll position and move every offset
underneath the highlight.

NO DOMPURIFY. A fixed tag allowlist over one known producer, run inside a
DOMParser document, which has no browsing context, so nothing in it can
execute or fetch while it is being cleaned. Unknown tags are UNWRAPPED so
their words survive; script, style, iframe, svg, form and their kin are
dropped whole. Every attribute goes except a short per-tag list, which kills
every on* handler by one rule rather than by name. href and src must be
relative, http, https or mailto, and control characters are stripped before
the scheme is read, because "java\tscript:" is a real evasion.

IF THE PARSER IS MISSING, mdRender returns null and every text falls back to
the plain path. That is exactly the behaviour of every version before this
one, so a failed asset is a lost feature and never a blank page.

STYLING is all in em, so the reader's own font-size setting still governs and
a heading stays a RATIO of the body text. Colour is deliberately restrained:
body text and headings both stay var(--page-text), told apart by size and
weight rather than ink, because the sentence highlight is a solid yellow block
and coloured text underneath it would have to fight it. Links are blue, the
one colour the highlight never uses.

### Proved across the upgrade, 18.8.2026

Test 4 installs v3.10 for real, makes three texts through its API, changes
seven settings, plants the key files, leaves the server RUNNING, and then
installs v3.11 on top. 53 checks, all passing:

    the running v3.10 server is seen and stopped, not left serving memory
    all seven settings keep their VALUES, not their defaults
    all five kept files come back, key files still 0600
    all three texts written under the OLD rule still open, with byte-identical
      sentences, and now carry a source
    none of them is mistaken for Markdown, so an old text cannot suddenly
      start rendering as headings because the cleaner left a dash list behind
    a second install straight after changes nothing and leaves no .new files

The key files in that test are OBVIOUS FAKES and prove only that the installer
carries them across a wipe. Real-key testing is rule 2 and was done separately
against the live Speechify API.

## Phase 2: one source of truth

THE VOICE AND THE HIGHLIGHT READ ONE STRING, by construction rather than by
careful agreement.

    the browser parses the Markdown ONCE, before /api/prepare is called
    it walks the rendered text nodes and wraps every word in a span
    it builds the spoken string FROM THOSE SPANS, recording each span's
      [s,e) offsets into it as it goes
    that string travels with the request as `spoken`
    the server splits THAT, never the Markdown source, and returns the
      sentences together with their character ranges inside it
    the page finds a sentence's words by offset, never by matching text

The parsed nodes are then MOVED into the page, not re-parsed and not
re-serialised, so there is exactly one parse per text however often the view
is rebuilt.

THE DOM AND THE SPOKEN STRING DIFFER IN WHITESPACE ON PURPOSE. The page keeps
whatever spacing it needs to look right; the spoken string collapses runs to a
single space and puts a blank line between blocks. That is not a mismatch to
be fixed, because nothing maps by comparing text.

A WORD CAN BE SPLIT ACROSS ELEMENTS. "<code>x</code>." is one run of non-space
in the spoken string but two spans. Spans are therefore sub-word pieces with
exact offsets, and anything that wants whole words groups them by the runs of
the spoken string.

WHERE IT IS STORED. spoken.txt, beside text.txt in the library folder. text.txt
is what was pasted; spoken.txt is what the voice was given. A plain text never
writes one and the old cleaner still decides, exactly as before.

THE INVARIANT, AND THE ONLY HONEST FALLBACK. The page maps ONLY when its own
spoken string is identical to the server's. If a text has no spoken.txt - saved
before v3.12, or the parser changed underneath it - the server falls back to
the cleaner, and the two strings may differ. Then the text is still shown
formatted and simply NOT mapped. Mapping on offsets taken from a different
string would light up the wrong words, which is worse than lighting up none.

Proved against the live Speechify API: a Markdown document was billed 254
characters, which is exactly the length of the string built from the spans,
and no hash, asterisk, backtick, pipe or URL was ever sent.

## Phase 3: the highlight, over the formatting

Nothing re-renders. The sentence being read and the word being spoken are a
CLASS on spans that already exist, which is what the app has always done for
plain text. All that changed is that a sentence is now a RANGE of spans
rather than one element wrapping them.

    .w.lit / .g.lit      the sentence being read
    .w.litp / .g.litp    the same, paused
    .w.now               the single word being spoken, on top of the band

THE GAPS ARE LIT TOO. The whitespace inside a sentence gets its own span, so
the band is a continuous ribbon rather than a row of separately lit words with
pale stripes between them. Gaps are kept OUT of the word span list, which is
the contract phase 2 established and which nothing else may enter. A block
boundary has no span and needs none: there is nothing to see between two
blocks, they are on different lines.

THE COLOURS DO NOT FIGHT THE FORMATTING.

    headings      told apart by size and weight, never by ink, so the yellow
                  band has nothing to argue with
    links         blue on yellow is unreadable, so a lit word takes the band's
                  ink; the underline was moved onto the word span itself so it
                  follows that colour instead of staying blue underneath
    inline code   its chip background and border are dropped under the band,
                  via :has. Where :has is missing the chip keeps its frame,
                  which is untidy and perfectly readable
    focus mode    dims unlit words and gaps, the same as it does plain text

SPEECHIFY'S SPEECH MARKS ARE NOT WORD RUNS. A real sentence produced a token
of "Two\n" and then a token of "\n" on its own. A token can therefore cover
one span, several spans, or NONE. The empty ones are KEPT, with no elements,
so the array stays one for one with the server's timings. Dropping them would
slide every later index up by one and the highlight would run a word ahead of
the voice for the rest of the sentence. Kept, a pure-whitespace token simply
lights nothing, which is exactly what is happening: a pause.

THE OFFSET SHIFT IS DEFENCE, AND SAYS SO. Word timings are offsets into the
STRIPPED sentence; spans are numbered against the whole spoken string. The
code adds the leading whitespace strip() removed. Measured against the
splitter the server actually uses, that lead is ALWAYS ZERO, because the
splitter consumes the space after the full stop. The line is kept because it
costs one subtraction and a future change to the splitter would otherwise move
every word by a word, silently. It is tested on a constructed case so the
arithmetic can still be caught if it is ever wrong.

TAPPING A WORD reads from that sentence, which is what tapping a sentence has
always done in plain text. Without it a Markdown text could not be started
from the middle at all, because there is no .sent to tap.

TEXT MODE STRIPS EVERYTHING. Not "formatting with the colours off": every
heading back to body size and weight, every chip, border, underline and image
gone, one white ink.

EDIT MODE EDITS THE MARKDOWN SOURCE. A separate editor holds text.txt, markers
and all, and the rendered document is hidden while it is open. Making the
rendered HTML contentEditable would have let a heading be typed into and then,
on commit, read back as flat text with every marker already consumed - the
formatting would quietly disappear the first time anything was fixed.
Committing sends the edited source back down the same road a paste takes, so
formatting and highlight both come back. The editor is emptied whenever a text
is opened, or it would commit the previous text over this one.

Plain text is completely unaffected: same .sent spans, same highlight, same
sentences, byte for byte.

Also still owed, and belonging to the later phases:

    the browser side has never been seen in a browser. Every visual claim in
      this section is code inspection and a headless DOM only
    Edge is untested for Markdown; every timing proof used Speechify, because
      edge-tts was not installed where the tests ran
    maread-update replacing ITSELF while running is still not covered by the
      upgrade test

The visible version is v3.N and N goes up on every push, however small, so a
change can be pointed at and named. Run bump.py before pushing; it changes all
three places at once, the edition comment, the terminal banner and the
Settings line.

The FILENAME never changes. It names the line, 3, and maread-update fetches it
by that name; renaming the file on every build would break the one command
Baba actually types.

## Two gestures on the text, and no others

Scroll it with a finger. Tap a sentence to read from there. That is all.

Removed outright: the swipe between sentences and its whole engine, the
Reverse swipe setting, tap-to-paste on the text, and tap-the-playing-sentence
to pause. Every one fired by accident while a finger was only trying to
scroll, and someone listening should not have to be careful where he touches.
Tapping the sentence already playing now restarts it; the player bar pauses.
Gone from the client, the page, the Help text, the chips and the server state.

## A finished text starts again

Press play on a text that has reached its end and it starts from the FIRST
sentence, not the last one. Once the end is reached that is the only reading
of the button that makes sense.

A FLAG, not an inference. "On the last sentence and its audio has ended" is
also true after a deliberate jump to the last sentence, and those two
situations deserve different answers. atEnd is raised when the last sentence
ends, and cleared by any start, any jump, and any new text.

Stop deliberately does NOT clear it: stopping a text that has already finished
leaves it finished, so play still starts from the top.

Loop still wins. When loop is on the end never arrives, so the flag is never
raised. The offline reader carries the same flag under OFF.atEnd.

## The teleprompter rule

EVERY sentence begins at the top of the screen. Not only when it has wandered
out of view: every one, every time, unconditionally. One function,
sentenceToTop, called from all three readers: plain, Markdown and offline.

The old rule only moved when a sentence had crossed an edge, so the reading
line landed wherever the previous sentence happened to leave it, sometimes at
the top, sometimes halfway down, sometimes at the very bottom with nothing
after it. The eye had to hunt for the line each time. A teleprompter does not
make you hunt: the line you are on is always in the same place and everything
below it is what is coming.

THE JUMP IS INSTANT. A smooth scroll is a small animation, and an animation
is a delay by another name: the line slides for a few hundred milliseconds
while the voice is already speaking it, so the eye arrives after the ear. It
lands at once instead. No smooth scroll survives anywhere in the reading path.

If a pause before the jump is wanted it is a SETTING, in seconds, rather than
something baked into an easing curve. The "scroll delay" stepper sits beside
the sentence pause in the first row of Settings, 0.00 to 3.00 in steps of
0.05, and 0.00 is the default: nothing at all between the sentence starting
and the page moving.

A pending delayed jump is cancelled the moment another sentence begins, and by
anything that stops the reading, so a fast passage cannot queue a row of jumps
that all land together. Only the current sentence ever lands.

TOP_PAD is 12px of air below the top edge. A move smaller than 2px is skipped,
so an already-placed sentence does not jitter. The sentence jump is NEVER
throttled: it is the main movement of the app and a sentence change is a
deliberate event, not the per-word chatter the throttle exists to damp.

The reader carries 78vh of blank padding after the last word. Without it the
document runs out, the scroll clamps, and the reading line drifts down the
screen for the final few sentences, which is exactly the wandering this rule
exists to stop.

## The lit word stays on the screen

Following the SENTENCE is not enough: a sentence can be taller than the
window, and then the word being spoken is lit where nobody can see it. The
word itself is watched.

While it sits comfortably inside the reading area nothing moves, because a
page that creeps on every word is worse than one that never moves. When the
word crosses an edge the view jumps so the START of its sentence sits near the
top: spoken words above, coming words below.

Since every sentence now begins at the top, a word can only fall off the
bottom inside a sentence TALLER than the screen, and then the WORD is what is
brought up, never the sentence: the sentence starts above the top edge by
definition, and going back to it would undo the reading.

Throttled to one move per 250 ms so a hand scroll is never fought, and off
outside READ mode. The offline player follows the same rule, with its own
scroller passed in. No centre scroll survives in any reading path: centring
wasted the whole upper half of the screen on words already spoken.

## Read, text, edit

Three small words where the two pauses used to sit.

    READ   the app as it has always been: it speaks, the word lights up
    TEXT   every colour and marker stripped, plain white, scroll and read
           it with the eye
    EDIT   the text itself becomes editable, to cut a header off or fix a
           mistype before reading

Play belongs to READ alone and is dimmed in the other two: there is nothing to
follow, and a voice talking over an edit is a nuisance. Switching out of EDIT
commits what was typed, re-splitting it into sentences, but only if it
actually changed. EDIT is never restored on startup; coming back into a text
editor nobody asked for is a surprise.

## The word pause was removed

Interface and engine. It worked, and the mechanism was sound, but it was not
used: a pause long enough to notice made a page take half an hour, and
anything shorter was indistinguishable from nothing. The silence map it rode
on is still measured, because the word highlight needs it.

The sentence pause moved into the first row of Settings, in the same stepper
shape, since it is set once and left.

## Edge speaks two languages

English and Croatian, four voices. The other eleven were removed outright
rather than hidden. An old settings file listing them simply loses them on
load, and a text cached under a removed voice answers a clean error rather
than half-playing.

## One app, one look

The terminal wears the same three colours everywhere: gold for a key, dim for
a label, white for a value. Same rule line, same aligned rows, same shape of
menu in the server screen, the updater and the installer.

NO RED. Red says something is wrong, and a server that started is not wrong.
The only red left is on an actual failure.

The launcher no longer calls the shared ma_banner from ~/.ma/banner.sh, which
drew the name in red and wrapped its key line across two rows. It draws its
own header instead, after the real port is known, so the address shown is the
one being served.

## Three panes, not two engines

Edge, Speechify, Settings. WHICH PANE is showing is not the same question as
WHICH ENGINE speaks; they used to be one value, which is why everything that
was not about a voice had to be crammed into whichever engine happened to be
selected, and why nobody could say whether the font lived under Edge or under
Speechify. Picking Edge or Speechify still switches the engine. Picking
Settings changes nothing about the voice.

Inside Settings the text card comes first, because it is the one reached for.
The sheet opens on Settings.

## The dyslexia font is gone

Interface, engine, licence file and both embedded base64 payloads. The
installer lost 320 KB, which is 46 per cent of it. Typefaces are now sans,
book, serif, mono, in that order, and sans is the default. An old settings
file naming the removed font is corrected to sans on load rather than left as
a value nobody recognises.

## Fresh installs start where Baba starts

    font          sans
    size          13   (39px)
    line spacing  3
    theme         night
    word highlight on
    tab row       hidden
    after pasting normal view
    sheet opens   Settings

These are DEFAULTS, not overrides: an existing settings file keeps every
choice already made in it.

## The two toggles in the head

The two things changed most often sit above everything, reachable without
scrolling, to the left of the X:

    ENGINE     EDGE / SPEECHIFY     which engine SPEAKS
    LANGUAGE   ENG / HR / AUTO      which language is being READ

Both name the state they are in and flip on a press.

WHICH ENGINE SPEAKS IS NOT WHICH PANE IS OPEN. The Edge and Speechify tabs
below choose which cards are shown and nothing else; the engine toggle changes
who talks and leaves the pane exactly where it was. They were one value once
and that was the source of a whole family of surprises.

The engine toggle reports a choice, it cannot invent a key. Switching to
Speechify with no key loads the choice and the reading then fails honestly
rather than silently staying on Edge.

## The Settings sheet

No Done button. One X, centred, pinned to the top of the sheet, no text on it.
A tap anywhere outside the sheet closes it too.

Every way out SAVES, at once, not on the 250 ms timer. Without a Done button
every exit is a commit, and waiting for a timer would leave a quarter second
in which the phone can be put away and the change lost, which has happened
before.

The floating P is hidden while the sheet is open. It would cover the panel,
and now that a tap outside closes the sheet, a stray press of it would both
close Settings and paste.

## The header can be emptied

"Hide the tabs" removes the Read / Paste / Player / Offline / Help row and
leaves only the gear. The gear lives in the header but OUTSIDE .topbar, which
is what body.notabs hides, so the way back is structurally guaranteed rather
than merely remembered: gear, Settings, toggle. With the voice row also off,
the whole header is one gear.

## Where the settings live

One file, ~/.maread-web/web_state.json, in Termux private storage. Nothing
else on the phone can touch it. Not localStorage, not shared storage, never
off the device. Carried out and put back on every install, together with its
.bak and the key files.

Written atomically: temp file, fsync, rename over the top, previous copy kept
as .bak and used if the main one will not parse. Read back through clamps, so
a corrupted beacon cannot leave a negative speed behind.

NOTHING is saved until boot has finished restoring. bind() makes every control
live at the top of boot, but ST is not filled in until five requests return,
one of which asks Speechify for its catalogue and can be slow. In that window
the interface runs on FACTORY DEFAULTS, and any of the 34 places that call
persist() would write those defaults over the file. A booted flag gates all
three save paths, and the Speechify lookup is raced against a four second
clock so it can never hold the app in defaults.

Saved on a 250 ms timer to coalesce a burst, AND flushed by sendBeacon on
visibilitychange, pagehide and blur. That second half is not optional: on
Android a backgrounded tab is frozen and the timer never fires, so anything
changed in the last quarter second before the phone went in a pocket was
being lost.

## Every setting

Generated from the shipped page, so it cannot drift. All live in the
Settings sheet and all are remembered.

    Go full screen           fullPasteTog
    Hide the tabs            hideTabsTog
    Voice buttons on top     voiceBarTog
    Auto-play on open        autoplayTog
    Remember position        resumeTog
    Focus mode               focusTog
    Loop                     loopBtn
    Reverse swipe            swipeTog
    Floating paste button    floatTog
    Tap text to paste        tapPasteTog
    Resume my music          bgResumeTog
    Test it                  bgTestBtn
    Open in Chrome           chromeTog
    AI title and summary     aiMetaTog

### Hearing a voice before choosing it

Tapping a voice in either Settings grid makes it say "This is <name>. Hi
there." A name in a list says nothing about a sound, and with 963 of them that
is the whole difficulty.

Route /api/preview/<vkey>, its own folder, one file per voice, made once and
kept. Deliberately NOT routed through the library: a preview is not a text
Marko saved and has no business in his Archive. If the reader was speaking it
is paused for the sample and resumed after, so a preview never talks over the
article and never abandons the reading. Tapping the same voice again stops it.

Takes the same per-item lock the article cache takes. Without it, a fast thumb
tapping four voices produced five failures out of ten and served a
half-written file.

Proven on BOTH engines, 17.8.2026, Speechify against a real 21 key file that
was shredded afterwards. Edge: four voices, cached copy served 2800 times
faster than the first. Speechify: page one of the UK catalogue, plus Jean from
page eleven of the US list to show it is not only the first page. Ten
simultaneous taps returned 10 of 10 on each engine with every voice one
consistent size. A key revoked mid-preview rolled forward and still delivered.
With all 21 keys dead, previews already made still played from disk and a new
one failed cleanly leaving no empty file. Forget removed the Speechify
previews and kept the Edge ones. The usage counter recorded 27 characters for
"This is Beatrice. Hi there.", which is exactly its length.

### What appears on the top row

spPicked is NULL when the voices have never been chosen and an ARRAY once
they have, and the two mean different things. Null lets the app offer the
first four; an empty array is a decision and is honoured. Treating them as the
same value is what made unticked voices reappear on every restart: the seed
could not tell a decision from a blank.

Every Speechify voice in the paged grid carries a tick box. Ticked
voices go on the top row, ANY NUMBER of them, because the row scrolls. Four
was only ever the size of the window in Settings, never a limit on the row.
Untick everything and nothing shows.

The cell has two hit areas: the box on the left decides whether the voice is
on top, the rest of the cell chooses it and plays it. The picked list is
de-duped on the way out, since a state file edited by hand or merged between
devices can repeat an entry.

Unticking the voice that is currently speaking does not stop it. It keeps
reading and simply stops being shown, which is the least surprising thing.

The old "Show both engines" switch is retired: two rows appear whenever both
engines have something to show. The per-engine Hide switches are retired too,
as redundant: an engine with nothing ticked, or no language ticked, already
contributes nothing, and the ticks are the honest control because they say
WHICH voices as well as whether.

That row now carries "Go full screen" under the heading "After pasting".

THE APP ALWAYS OPENS NORMAL. Full screen is a consequence of PASTING, never of
launching. That is both what Baba wants and the only thing that can work: a
page cannot demand the browser's full screen without a gesture to hang the
request on, and a page that has just loaded has none. Pasting is a gesture.

With the setting on, a press of the P asks for full screen inside that gesture
and then pastes. With it off, the paste happens and the view stays normal.
Tapping the text to paste follows exactly the same rule, so the two can never
disagree. If the browser refuses the request, our own furniture still hides
and the reading still starts.

In a tab the address bar stays until the first press of the P; installed to
the home screen there is nothing to hide and this is genuinely full screen.

If the floating P is switched off, the corner exit button comes back in full
screen. Full screen with no way out is a trap, and the app promises he is
never stuck in that view.

### The voice strip can be switched off

"Voice buttons on top", in the Edge card, on by default. Off and the whole row
of voice buttons leaves the top of the reader, giving that band back to the
text. The voice is then chosen from a grid in Settings instead, which exists
either way and stays in step with the strip. Same shape and the same female
pink, male blue colour coding as the Speechify grid, because it is the same
job.

## Every route

Generated from server.py.

  reading
    /api/audio/<tid>/<vkey>/<int:idx>.mp3 GET
    /api/bounds/<tid>/<vkey>/<int:idx> GET
    /api/langs                         GET
    /api/prepare                       POST
    /api/state                         GET,POST
    /api/voices                        GET

  library
    /api/library                       GET
    /api/library/<tid>                 GET
    /api/library/<tid>/delete          POST
    /api/library/<tid>/enrich          POST
    /api/library/delete_all            POST
    /api/library/delete_bulk           POST

  offline
    /api/export                        POST
    /api/offline/clip/<name>/<int:idx>.mp3 GET
    /api/offline/delete                POST
    /api/offline/delete_all            POST
    /api/offline/delete_bulk           POST
    /api/offline/list                  GET
    /api/offline/open/<name>           GET
    /api/offline/pos                   POST
    /api/offline/pos/<name>            GET

  speechify
    /api/speechify/accent              POST
    /api/speechify/drop                POST
    /api/speechify/forget              POST
    /api/speechify/keys                POST
    /api/speechify/refresh             POST
    /api/speechify/revive              POST
    /api/speechify/status              GET

  gemini
    /api/gemini/forget                 POST
    /api/gemini/key                    POST
    /api/gemini/status                 GET
    /api/gemini/usage/reset            POST

  system
    /                                  GET
    /api/browser                       GET,POST
    /api/mediakey                      POST
    /api/mediastatus                   GET
    /manifest.webmanifest              GET
    /static/<path:fn>                  GET

## The AI title and summary (Gemini)

Carried over from earlier versions and still shipped. A Gemini key, loaded by
file picker in Settings, gives each saved text a short title and summary in
the Archive instead of its first line. Optional in every sense: with no key
the app behaves exactly as if the feature were not there. Routes under
/api/gemini, key in gemini_key.txt, usage counted in gemini_state.json, both
kept across an install.

Not part of the reading engine. If porting the reader elsewhere, strip it.
## Brought over from the v34 line

v34 lives in the private MA_READER_SPEECHIFY repo. It is a PATCHER over the
same v26 this was forked from, not a standalone app, so the two are siblings
rather than ancestor and descendant. Diffed 17.8.2026. Three things it had
right that this did not:

    NO 24-BIT COLOUR       this terminal does not do it and a 38;2;r;g;b
                           escape prints as literal rubbish. Three tiers now,
                           decided by asking tput rather than assuming: 256
                           where there are 256, the basic eight below that,
                           and no colour at all when not a terminal. Both the
                           installer and the server banner were offenders.
    KEYS NEVER DROPPED     shape only RANKS candidates now, it never discards
      FOR THEIR SHAPE      one. Testing a label costs one wasted request;
                           discarding a real key because a provider changed
                           its format loses the key silently, and Google has
                           already done that once. Anything on its own line,
                           20 characters or more with no spaces, is tried;
                           sk_ shaped ones first, the rest after. A non sk_
                           candidate that fails is skipped for the session
                           rather than written to the dead list, because a
                           long word in a notes file is not a dead key.
    WHAT EACH KEY SPENT    counted from Speechify's own
                           billable_characters_count and shown per key in
                           Settings. Shared files get used unevenly and there
                           was no other way to see whose account is carrying
                           everyone.

Not taken from v34: it removed the word pause entirely because it never worked
there. Here it was fixed instead, see the engine notes above.

Also fixed while in there: the installer menu is now the standard one, and
uninstall removes all three commands rather than only the launcher, which had
left maread-update behind able to reinstall an uninstalled app.

## Installing while it is running

A live server holds the old code in memory and keeps serving it after every
file underneath has changed, which is how an update comes to look like it did
nothing. The installer used to kill it silently. It now says so and asks:

    MA Reader is running right now
      serving on   http://localhost:8081
      process      12345
      [K] kill it and install
      [Q] leave it alone, change nothing

If there are saved settings and the menu was used, it also offers [K] keep or
[W] wipe them, so a settings file written by a much older version can be
thrown away deliberately. Keys are never part of that question and are always
kept. maread-update never asks, because it runs in the same terminal and the
question would appear on every single update.

Q changes nothing and exits. K stops it, TERM first and KILL after five
seconds, and only installs once nothing is left running. If it cannot be
stopped at all, nothing is touched and it exits 1 rather than installing over
a live server.

When there is no terminal, which is how maread-update runs it, there is nobody
to ask and it was asked to install, so it stops the server, says that it did,
and carries on.

Finding the server is fussier than it looks. A bare pgrep on the path also
matches an editor with the file open, a tail on it, or any shell whose command
line mentions the path, including the installer itself in some invocations,
which made it refuse to run because it had detected itself. So it requires the
path in the command line AND the first token to be a python, and never matches
its own pid or its parent.

## Replacing a command that is running

maread-update is a shell script that runs the installer, so while the
installer writes, the old updater is still alive and bash is still reading it.
A plain "cat >" truncates the very file the running shell is reading from; it
then carries on at its old byte offset into whatever is there now. Small files
survive by luck because bash had already buffered them whole. Luck is not a
mechanism, and the updater has been growing.

Every command is therefore written to name.new and renamed over the top. A
rename swaps the directory entry, so the running shell keeps its open file and
reads it to the end. The real name only ever appears once the file behind it
is complete, so a half written command is never reachable. Stale .new files
from a run that died in between are cleared at the start of the next install.

Demonstrated rather than assumed: a 230 KB script overwritten with cat > while
running stops dead without reaching its last line; the same script replaced by
rename runs to the end.

## maread-update asks first

It never installs by itself. It downloads to a temporary folder, names the
version it found against the version installed, and then offers:

    [U]  update, keep my settings
    [W]  update, wipe my settings   (keys are kept)
    [D]  update and fetch dependencies too
    [Q]  quit, change nothing

W passes --wipe to the installer, which is how the installer can wipe without
asking a second time. With no terminal there is nobody to answer, so it quits
and changes nothing; an update is never applied to a machine that could not be
asked.

The download shows a real percentage, taken from Content-Length against the
bytes on disk, not a decorative animation. The install shows six real steps:
making room, the server, the page, the fonts, the commands, done. Both go
silent when output is not a terminal, so a log file does not fill with bars.

## The menu

    [I]  install or update
    [D]  dependencies only, add what the table says
    [U]  uninstall, then [A] app only or [E] everything
    [enter]  offline, replace only the code already here
    [Q]  quit

One keypress, no Enter, no command line switches. Before any install, the
dependency table: one row per piece, what it is needed for, green + if present
and red - if not, optional ones labelled and never blocking. If a required
piece is missing it offers [D] fetch it, [C] carry on anyway, [Q] back.

## Traps worth keeping

    a running server keeps serving old code out of memory after an update, so
      installing kills it first
    a cache written by older code is still readable by newer code, which is
      how the voice picker got stuck at four voices out of 963. The voice
      cache carries a schema version now and is not preserved across installs
    serve the HTML with Cache-Control: no-store or the browser shows yesterday
    a shell colour escape in single quotes prints as text, use $'...'
    the clipboard can hang forever, see above

## Conventions

    one self contained .sh installer, install and uninstall in the same file
    version at the start of the filename and again inside, bumped every change
    near black surfaces, gold ink, no blur or backdrop-filter anywhere
    single keypress menus, no command line switches
    big touch targets
    version shown in Settings only
    keys never printed, never sent to the browser, masked first6 last4, dead
      list stores fingerprints, key file 0600 and in .gitignore

## Known and open

    the Chrome intent is tested against a simulated am, not a real phone
    maread-adb is untested on a real phone; Baba has Developer options
    the browser side of full screen, the floating button and the paste catcher
      are checked by code inspection and simulation only. They live in Chrome,
      not in a sandbox, so Baba is the first to actually see them
    US voice pages 20 and 21 are not two women and two men, because there are
      45 women and 37 men and the tail runs out
    MA_READER_SPEECHIFY (private) also holds a v34 line. Diffed 17.8.2026 and
      merged, see above. It is a patcher over the same v26, so it is a sibling
      of this line rather than ahead of it. Nothing further outstanding there.
    mareader, the old Streamlit repo, is to be deleted by Baba. The token here
      lacks delete_repo scope, so it cannot be done from this side.
