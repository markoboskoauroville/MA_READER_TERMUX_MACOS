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

    maread-update     ask, then install if told to
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

    Edge        free, keyless, English and Croatian, two voices each. Times
                re-pinned to the waveform.
    Speechify   keyed, English only, UK and US. Brings its own word times.

Both appear on the top row together whenever each has voices to show:
Speechify first, Edge below, each scrolling on its own. Tapping a voice from
either row moves the engine to match it.

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


## The version moves on every build

The visible version is v3.N and N goes up on every push, however small, so a
change can be pointed at and named. Run bump.py before pushing; it changes all
three places at once, the edition comment, the terminal banner and the
Settings line.

The FILENAME never changes. It names the line, 3, and maread-update fetches it
by that name; renaming the file on every build would break the one command
Baba actually types.

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
