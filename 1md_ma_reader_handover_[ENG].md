# MA Reader Termux, Handover

State of the app as of 17.8.2026, commit 8f0b789, everything in it verified. This file is rewritten on
every push. If it disagrees with the code, the code is right and this file is
a bug.

    repo      https://github.com/markoboskoauroville/ma-reader-thermux
    install   3sh_i_ma_reader_v3_termux.sh
    edition   v3

## Before anything else

Read 1md_working_rules_[ENG].md. Three progressing tests before shipping, real
keys only and shredded after, one spoon at a time, and say what was not
tested. Those rules bind whoever picks this up next.

## What it is

A reader for Termux on Android. Paste text, it speaks it and lights each word
as it is spoken. Served from a local Flask server, read in the browser at
localhost. Built for one workflow above all others: article after article, all
day, one thumb.

## Install and update

First time, one paste:

    pkg install -y curl && curl -fsSL -O https://raw.githubusercontent.com/markoboskoauroville/ma-reader-thermux/main/update.sh && bash update.sh

After that, forever:

    maread-update     fetch the newest version and install it
    mareadweb         run it
    maread-adb        set up a privileged shell for the media keys

Installing is a WIPE, not an overwrite. It stops any running server, carries
keys and settings out, deletes the app folder, writes it fresh, puts the kept
files back. The library at ~/.maread is never touched.

## Shape

The installer is one shell script holding exactly two files:

    ~/.maread-web/server.py            Flask, about 3000 lines
    ~/.maread-web/static/index.html    one file, all CSS and JS inline

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

    Edge        free, keyless, 13 languages, two voices each. Word times
                re-pinned to the waveform.
    Speechify   keyed, English only, UK and US. Brings its own word times.

"Show both engines" puts them on screen together: Speechify on the first row,
Edge on the second, each scrolling on its own. Tapping a voice from either row
moves the engine to match it.

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
resolves is refused. It is still not absolute: Chrome restores its bar when it
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

    three controls      word pause and sentence pause on the left, play in the
                        middle, speed on the right
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


## Every setting

Generated from the shipped page, so it cannot drift. All live in the
Settings sheet and all are remembered.

    Show both engines        bothTog
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
