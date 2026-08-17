# MA Reader Termux, Handover

State of the app as of 17.8.2026, commit 68f6432. This file is rewritten on
every push. If it disagrees with the code, the code is right and this file is
a bug.

    repo      https://github.com/markoboskoauroville/ma-reader-thermux
    install   3sh_i_ma_reader_v3_termux.sh
    edition   v3

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
    US voice pages 20 and 21 are not two women and two men, because there are
      45 women and 37 men and the tail runs out
    MA_READER_SPEECHIFY (private) holds a v34 line that went further than the
      v26 this was forked from. Not yet diffed against this v3.
