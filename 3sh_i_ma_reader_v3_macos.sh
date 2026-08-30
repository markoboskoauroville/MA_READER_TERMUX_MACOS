#!/usr/bin/env bash
###############################################################################
# MA READER TERMUX  (Edge / Speechify)  -  installer for Termux   edition: v3.40
#
# repo: MA_READER_TERMUX_MACOS
#
# v3 is the first version with two engines in it, and the first where the
# pause between words is an actual pause. It needs nothing new installed:
# the whole Speechify side is stdlib, so the dependency list is unchanged.
#
#
# THREE CONTROLS, NOT TWO
#
# The bar under the text used to carry speed and one pause. It carries three
# things now, arranged the way a hand wants them rather than the way they were
# added: the two pauses sit together on the left, because they are the same
# idea at two scales, silence between words and silence between sentences.
# Play stays in the middle. Speed is alone on the right.
#
# The right hand stepper used to say WORDS and did not really work. It says
# SPEED now. The pause between sentences, hidden in Settings since v26, is on
# the bar where it belongs, and it says SENTENCES.
#
#
# THE PAUSE BETWEEN WORDS IS A PAUSE NOW
#
# The old one changed playbackRate to race through the quiet the voice leaves
# between words. Every rate change was audible: clicks on the joins, chirping
# consonants, and on several Android webviews the audio muted outright below
# about a quarter speed. It was the wrong mechanism for the job.
#
# Rate is no longer touched anywhere on that path. The server already measures,
# once per clip, exactly where each between-word silence falls, using the same
# two-band envelope the word highlight is built on, and pulls each run inward
# by 18 ms at both ends so its edges are certainly quiet and never sit on the
# tail of an s or an f. The player now does the one honest thing available to
# it: inside one of those measured silences it PAUSES the mp3, waits the time
# you asked for, and plays it again. A pause inside silence cannot be heard.
# Nothing is re-recorded, nothing is resampled, no word is clipped, and no
# consonant is cut in half.
#
# It runs from 0.00 up to 2.00 seconds and no lower, because lengthening a
# silence is free while shortening one would mean cutting audio, and there is
# no way to have less silence than the voice actually recorded.
#
#
# TWO ENGINES
#
# Settings opens on two buttons, Edge and Speechify, and the cards below them
# follow whichever is chosen, so neither engine ever has to look at the other
# one's knobs. Speed, the two pauses, the text and the colours belong to both.
#
#   Edge      free, keyless, thirteen languages, two voices each. Its reported
#             word times are guesses, so every Edge clip is decoded after it
#             is made and every word re-pinned to the real waveform.
#
#   Speechify keyed, English only. It returns speech marks whose character
#             offsets land exactly on the text it was given and whose times
#             are measured from the audio it just made, so on this engine the
#             highlight needs no guessing at all.
#
# Speechify has no Croatian and no other Slavic voice, so the engine offers the
# two English accents and nothing else. Choosing one fills the four seats at
# the top of the reader with that accent's voices, two female and two male, in
# pairs. Four is the whole picker; there is no room for a fifth.
#
# The voice list is fetched by walking the cursor to the end rather than
# reading the first page. This matters: /v1/voices is paginated and defaults to
# fifty, and fifty alphabetically is all A names, which is one single British
# voice out of the thirty three that are really there.
#
#
# THE KEY RING, AND WHY IT IS LAZY
#
# One file, one key per line, with a name above each saying whose it is.
# Anything that is not sk_ followed by a long tail is read as a label, so a
# heading or a note in the file is never mistaken for a credential.
#
# Nothing is tested in advance. The obvious ring tests every key at startup and
# picks a winner, which with twenty keys spends twenty round trips to learn
# what it could have learned by simply trying. This one takes the first key not
# already known to be dead and just uses it. Only when a real request comes
# back 401 or 403 is that key condemned - written to a dead list on disk,
# permanently - and only then does the ring roll forward and repeat the very
# sentence that failed. A dead key costs one wasted request in its whole life,
# and a healthy ring costs none at all.
#
# The dead list survives restarts, so a revoked key is never paid for twice.
# Settings shows it, named and dated, with two ways out: Retry, which clears
# the mark in case an account was only suspended, and Remove, which strikes the
# key out of the file for good.
#
# 429 is not condemnation. A throttled key is valid, so it is stood down for a
# few minutes and tried again rather than thrown away, and a key is never
# blamed for the network being down.
#
# Keys are never printed, never logged, and never sent back to the browser.
# Nothing but the first six and last four characters is ever shown, and the
# dead list stores a SHA-256 fingerprint rather than the key, so that file can
# be read by anyone and gives up nothing.
#
#
# WHAT CAME BEFORE
#
# v26 split the gap in two, because it was never one thing.
#
# The knob on the player called GAP moved the silence between one sentence and
# the next. That is a real setting and it stays, but it is not the silence you
# notice while you are actually listening. The one you notice is the quiet
# INSIDE a sentence, between one word and the next, and there was no way to
# touch it. So there are two now. The gap between sentences moved into
# Settings, under Playback, where a set-once setting belongs. The right hand
# stepper on the player, beside play, is now the gap between WORDS.
#
# It does not re-record anything. The voice has already spoken the sentence
# with its pauses baked into one clip, and building a new clip per setting
# would cost a synthesis and would break the immutable cache the flow depends
# on. Instead the server measures, once per clip, exactly where the quiet
# between words falls, using the same two-band envelope the word highlight is
# built on, so a fricative tail is never mistaken for silence. The player then
# crosses that quiet differently: below zero it runs fast through it, above
# zero it stops inside it and waits. Speech is never touched at any setting, so
# no word is clipped and no consonant is cut in half. Clips cached before v26
# get their map measured once, on first touch, with no re-synthesis.
#
# v25 is a handful of small things that were wrong in the hand rather than on
# paper, plus a settings sheet you can navigate by colour.
#
# Tap the number. Speed and the gap sit between a minus and a plus on the player,
# and holding a button travels a long way quickly, which left no cheap way
# back. The number between them is a button now: tapping it returns that
# control to its resting value, 1.00 for speed and 0.00 for the gap.
#
# The swipe was backwards. Dragging left moved forwards, which reads as the
# text sliding the wrong way under the finger. Dragging RIGHT now brings the
# next sentence in from the right, the way a hand turns a page, and dragging
# left goes back. Anyone who had learnt the old direction can put it back with
# Reverse swipe in Settings, remembered like everything else.
#
# Settings are five cards instead of eight bare headings, each tinted and
# edged in its own colour so the block you want is findable by colour before
# you have read a word of it: Playback green, Text orange, Colour purple,
# Voices blue, Advanced teal. Text now holds letter size, line spacing and
# typeface together; Colour holds the page theme and the whole word highlight
# section. The order inside is still how often a thing is touched, not how
# important it sounds.
#
# v24 closed the seam between sentences, and moved speed and gap onto the
# player itself.
#
# The reading used to catch between one sentence and the next, which is fatal
# to a train of thought. Three separate causes were stacked on top of each
# other. The prefetch fetched each clip ahead of time and then threw the bytes
# away, trusting the browser cache to still hold them, while the audio route
# sent no Cache-Control at all, so the browser cached heuristically and often
# revalidated: a round trip of unpredictable length between every pair of
# sentences. The player then reused the same audio element, so setting src
# forced a fresh load and decode before the first sample. And the advance
# waited on the browser's 'ended' event, which arrives late by an amount that
# differs on every clip. That last one is what the ear reads as the break.
#
# All three are gone. Fetched clips are kept as blob URLs, so src touches no
# network and no disk. Three sentences are held ready at all times rather than
# two. There are three audio elements instead of two, one speaking and one
# holding the next sentence already decoded, so the handover is a swap and a
# play() on the same tick. And the handover is made by us, a hair before the
# clip ends, rather than waited for. Measured on a two second clip under a
# virtual clock: sentence starts now fall 1960 ms apart at gap zero, exactly
# the clip length minus the 40 ms lead, on every step including the first.
#
# The gap now runs into the minus, down to a whole second. A negative gap is a
# real overlap: the next sentence begins that much before the current one has
# finished and the two clips speak together, which closes the seam completely.
# Verified as two elements sounding at once. If a clip is genuinely slow to
# arrive the early handover simply does not fire and the old 'ended' path
# carries the run, so nothing stalls and nothing is skipped.
#
# The four outer transport buttons are replaced by two controls, one either
# side of play: speed on the left, gap on the right, each a minus, the number
# and a plus. Both step in twentieths so a press is a nudge, and both repeat
# while held. A double tap in the middle of the page now opens immersive
# reading and starts speaking; a double tap in the same place closes it and
# pauses, so you stop where you were reading. Settings are reordered with the
# most used first. The server picks the first free port at or above 8081 and
# writes it to a portfile, and o opens the page from the terminal.
#
# v23 rebuilt the timing measurement and adds a quick-turnaround workflow.
#
# One real bug first. edge-tts 7.x changed the default boundary type from
# WordBoundary to SentenceBoundary, so on any current install the app was
# receiving no word events at all and every clip was falling back to spreading
# words evenly across the audio. synth_unit now asks for WordBoundary
# explicitly, with a fallback for older edge-tts.
#
# Then the timing itself. Measured against hand-checked word onsets on a
# 15-clip, 6-language corpus, v22 put the highlight 50 ms late on average and
# up to 190 ms late on words starting with s, sh or f. The cause: a word was
# being pinned to its loudest moment, which is the vowel, not to where it
# actually starts. Three changes fix it. The envelope is now measured in two
# bands, broadband plus a pre-emphasised band that makes fricatives visible, at
# 16 kHz on a 5 ms hop instead of 8 kHz on 10 ms. Every detected onset is then
# walked back down its own energy slope to the foot of the rise. And the anchor
# solver's skip price went from 0.18 to 0.35, so a measured onset is no longer
# thrown away in favour of a badly placed engine guess. Result on the same
# corpus: RMS error 80 ms -> 18 ms, a 77% reduction, and the systematic
# lateness is gone (+50 ms -> -7 ms). Old cached clips upgrade themselves once,
# on first touch, with no re-synthesis, under the new engine tag "pcm2".
#
# Workflow: paste now reads. The Paste button, and the new P shortcut, replace
# whatever was in the box and start playing immediately, so a new text is one
# keystroke. Clicking or tapping a sentence jumps there and reads from it;
# clicking the sentence already playing pauses it. A mouse drag across the text
# moves a sentence, the same gesture as a touch swipe, so previous/next is
# reachable without a touchscreen. The timing nudge slider now steps in 5 ms
# instead of 20 ms and reads out in milliseconds.
#
# v22 shows the gap between sentences as a bare number, nothing else: no unit,
# no word at zero, just the figure.
#
# v21 is mostly about the silence between sentences. The old prefetch built a
# throwaway Audio element that the browser was free to collect before it ever
# finished loading, and it only ever looked one sentence ahead, so the player
# often sat waiting while the next sentence was still being synthesised. Now
# each sentence is fetched properly and kept, the reader runs two sentences
# ahead of itself, and it starts warming the opening sentences the moment a text
# is loaded, so playback should flow without stalling.
#
# The transport changes with it. The left button is now Home: it jumps back to
# the first sentence instead of stepping back one. Tapping the text pauses and
# resumes rather than jumping to that sentence, and moving between sentences is
# a swipe: left for the next one, right for the previous. The gap between
# sentences is now a plain 0 to 3 seconds in Settings, in tenths, so you can
# find the spacing that suits you.
#
# v20 adds a fourth RGB colour: the default reading font colour, the plain text
# of the reader when nothing is highlighted. Like the other three it is typed as
# R, G and B from 0 to 255. Left alone it follows the theme, so it stays right
# in night, sepia and day; type your own values to override it everywhere, and
# an Auto button hands it back to the theme whenever you want.
#
# v19 simplifies the highlight settings to three plain RGB colours you type by
# hand. Under Word highlight there are now three rows, each with an R, G and B
# box you fill from 0 to 255: the sentence highlight background, the word
# highlight background, and the font colour of the highlighted word. The
# sentence's own text stays readable on its own (light or dark is chosen for
# you from the colour you enter), and a live sample shows a highlighted word
# inside a highlighted sentence so you see all three at once. Remembered across
# themes; the old colour, intensity and font chips are gone.
#
# v18 adds a font colour to the word highlight, sitting right beside the colour
# and intensity rows. You can now set the highlighted word's own letters to
# white, middle grey or black, independently of the background behind them. The
# live sample updates as you choose, so you can dial in a pairing you like.
#
# v17 lets you dress the highlighted word to taste. In Settings, under Word
# highlight, there are now two little rows: a base colour (red, yellow or grey)
# and an intensity (muted, middle or screaming). The colour is the background
# that sits behind the word as it is spoken; muted is a soft tint, middle is a
# firmer wash, and screaming is a full solid block with readable text on top. A
# small live sample shows the pairing before you leave the sheet. Whatever you
# pick is remembered, and it holds across all three themes.
#
# v16 restyles the player controls in the flat, monochrome spirit of the Tidal
# transport bar. The controls are now solid filled icons on no background: the
# play and pause is the brightest, a clean white triangle and two rounded bars;
# the previous and next are the classic filled triangle with a bar; and the
# outer full screen and last controls sit dimmer, the way Tidal keeps shuffle
# and repeat quieter than the middle. No circles, no coloured fill, just a calm
# grey to white hierarchy that reads at a glance.
#
# v15 cleans up the top and the transport, and lets the picker be empty. A bare
# X sits next to Help; tapping it closes whatever is playing, wipes the current
# text and drops you back to a fresh paste box. The gear and the X are now plain
# icons with no circle around them. The two sentence skip controls beside the
# play button lost their coloured fill and are now simple hollow arrows on no
# background. And in Settings you may now untick every language: with zero
# languages the voice strip at the top disappears entirely, and the reader just
# uses the last voice you picked, remembered quietly in the background.
#
# v14 tidies the language list down to real languages only. The borrowed
# "Dalmatian", "Istrian" and "Sanskrit" language buttons are gone; instead the
# languages that can stand in for them now carry a plain "Can be used for:" line
# in the Settings language list. Croatian shows "Can be used for: Dalmatian,
# Čakavština", and Hindi (now a real language of its own, Swara and Madhur)
# shows "Can be used for: Sanskrit". So the picker only ever offers genuine
# neural voices, and the dialect uses are written underneath the voice that
# reads them. Thirteen languages, twenty six voices.
#
# v13 opens the reader to many more languages. Fifteen language groups are now
# built in, each with two top tier neural voices, one female and one male, at
# the same quality as Sonia and Ryan for English or Gabrijela and Srecko for
# Croatian: Croatian, Dalmatian (cakavian), Istrian (cakavian), Bosnian,
# Serbian, Macedonian, Albanian, Slovenian, German, French, Italian, Tamil,
# Sanskrit and Spanish, alongside the original English. Because that is a long
# list, Settings now carries a full Languages panel with a checkbox per
# language; whatever you tick shows up as a voice button at the top of the
# reader, so the picker stays short and personal. Three of these have no native
# neural voice anywhere (Microsoft ships none for cakavian Croatian or for
# Sanskrit), so they use the closest engine: Dalmatian and Istrian read through
# the standard Croatian voice, and Sanskrit reads through the Hindi voice, which
# speaks Devanagari. Those three are marked as such in the Languages panel.
#
# v12 adds live keyboard control to the running server. Press q to quit at once
# with no Enter, or b to detach and keep serving in the background so you get
# your terminal back. The background copy holds its own wake lock and logs to
# ~/.maread-web/server.log.
#
# v11 replaces the word-highlight timing with a WAVEFORM ENGINE. The old way
# trusted the voice engine's reported word times, but those live on a different
# clock than the finished mp3 (encoder padding, pause stretching), so the red
# word drifted off the speech. Caption tools like DaVinci Resolve stay glued to
# the voice because they analyse the actual audio; v11 does the same: after
# every sentence is synthesized, the app decodes that clip with ffmpeg,
# measures where speech really starts, ends and rises after each pause, and
# pins every word to the real waveform. The players also run a smoothed clip
# clock, so the highlight lands on each word exactly as it is spoken, online
# and offline alike. Clips cached before v11 are repaired automatically the
# first time they are used, with no re-synthesis.
#
# v10 added Select / Delete-all management to the Archive and Offline lists.
# v9 made the offline reader speak one sentence-clip at a time. Exporting a
# text writes, into Downloads/MA Reader Audio:
#     name.txt         the plain text
#     name.json        the manifest (sentence list + per clip word timing)
#     name/ sNNNN.mp3  one small mp3 per sentence, played in order
#
#
# Install:  bash 3sh_i_ma_reader_v3_macos.sh        Run:  maread
#           then open  http://localhost:8081  in any browser on the phone.
###############################################################################
set -e

APPDIR="$HOME/.maread-web"
LIBDIR="$HOME/.maread"
BIN="$HOME/.local/bin"
CMD="$BIN/maread"

# ------------------------------------------------------------------ palette --
# MA Reader is Fire | the Word, so the installer wears fire: light lands on the
# top of the letterform and cools into ember at its foot, the way it falls on a
# page. Removal wears the same shape in ash and violet, cold instead of warm, so
# the two operations are told apart by temperature before a word is read.
# NO 24-BIT COLOUR. This terminal does not do it, and a 38;2;r;g;b escape comes
# out as literal rubbish across the screen. Three tiers, decided by asking
# rather than assuming: 256 colours where tput says there are 256, the basic
# eight where there are fewer, and nothing at all when this is not a terminal.
NCOL=0
if [ -t 1 ]; then
  NCOL="$(tput colors 2>/dev/null || echo 8)"
  case "$NCOL" in ''|*[!0-9]*) NCOL=8 ;; esac
  B=$'\033[1m'; OFF=$'\033[0m'
else
  B=''; OFF=''
fi
if [ "$NCOL" -ge 256 ] 2>/dev/null; then
  c() { printf '\033[38;5;%sm' "$1"; }
  GLOW="$(c 223)"; GOLD="$(c 222)"; AMBER="$(c 214)"
  FLAME="$(c 208)"; EMBER="$(c 166)"; COAL="$(c 131)"
  VIOLET="$(c 141)"; CYAN="$(c 87)"
  GREEN="$(c 114)"; RED="$(c 203)"; DIM="$(c 245)"
  ASH1="$(c 252)"; ASH2="$(c 247)"; ASH3="$(c 243)"; ASH4="$(c 240)"
elif [ -t 1 ]; then
  GLOW=$'\033[1;33m'; GOLD=$'\033[1;33m'; AMBER=$'\033[0;33m'
  FLAME=$'\033[0;33m'; EMBER=$'\033[0;31m'; COAL=$'\033[0;31m'
  VIOLET=$'\033[0;35m'; CYAN=$'\033[0;36m'
  GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; DIM=$'\033[0;37m'
  ASH1=$'\033[0;37m'; ASH2=$'\033[0;37m'; ASH3=$'\033[0;37m'; ASH4=$'\033[0;37m'
else
  GLOW=''; GOLD=''; AMBER=''; FLAME=''; EMBER=''; COAL=''
  VIOLET=''; CYAN=''; GREEN=''; RED=''; DIM=''
  ASH1=''; ASH2=''; ASH3=''; ASH4=''
fi
KEY="$B$GLOW"; F="$AMBER"; OK="$GREEN"
RULE="─────────────────────────────────────────────"

logo() {   # six row colours, top light to bottom ember
  printf '\n'
  printf '   %s███╗   ███╗ █████╗ %s\n' "$1" "$OFF"
  printf '   %s████╗ ████║██╔══██╗%s\n' "$2" "$OFF"
  printf '   %s██╔████╔██║███████║%s\n' "$3" "$OFF"
  printf '   %s██║╚██╔╝██║██╔══██║%s\n' "$4" "$OFF"
  printf '   %s██║ ╚═╝ ██║██║  ██║%s\n' "$5" "$OFF"
  printf '   %s╚═╝     ╚═╝╚═╝  ╚═╝%s\n' "$6" "$OFF"
}
banner_fire() {
  logo "$GLOW" "$GOLD" "$AMBER" "$FLAME" "$EMBER" "$COAL"
  printf '   %sR E A D E R%s  %sv3.33%s\n' "$KEY" "$OFF" "$VIOLET" "$OFF"
  printf '   %sFire | the Word, the MA ecosystem%s\n\n' "$DIM" "$OFF"
}
banner_ash() {
  logo "$ASH1" "$ASH2" "$ASH3" "$ASH4" "$ASH4" "$ASH4"
  printf '   %sR E A D E R%s  %sremove%s\n' "$B$ASH1" "$OFF" "$VIOLET" "$OFF"
  printf '   %sputting the fire out%s\n\n' "$DIM" "$OFF"
}
rule() { printf '   %s%s%s\n' "$DIM" "$RULE" "$OFF"; }
row()  { printf '    %s%-10s%s %s%s%s\n' "$DIM" "$1" "$OFF" "$3" "$2" "$OFF"; }

MODE=""
WIPEFLAG=0
for a in "$@"; do
  case "$a" in
    --online|--full|--deps) MODE="online" ;;
    --offline)              MODE="offline" ;;
    --wipe)                 WIPEFLAG=1 ;;
    --uninstall|--remove)   MODE="remove" ;;
    --purge)                MODE="purge" ;;
  esac
done

# ---------------------------------------------------------------- removal --
# The uninstaller used to be a second file. It was small, it drifted out of step
# with the installer, and worst of all its name sat next to the installer's in a
# file list where the only difference was a word at the far end. One file now
# does both: the same script you ran to put it here takes it away again.
lib_note() {
  local n sz
  if [ -d "$LIBDIR" ]; then
    n="$(ls -1 "$LIBDIR/library" 2>/dev/null | wc -l | tr -d ' ')"
    sz="$(du -sh "$LIBDIR" 2>/dev/null | cut -f1)"
    printf '%s, %s texts' "$sz" "$n"
  else
    printf 'none'
  fi
}
do_remove() {
  local want="$1" pids ans
  banner_ash
  rule
  if [ -d "$APPDIR" ]; then
    row "app" "$APPDIR" "$ASH1"
  else
    row "app" "not installed" "$DIM"
  fi
  if [ -f "$CMD" ]; then row "command" "$CMD" "$ASH1"; else row "command" "not installed" "$DIM"; fi
  row "library" "$LIBDIR  ($(lib_note))" "$VIOLET"
  rule
  printf '\n'

  # stop it first, or we delete the server out from under itself
  pids="$(pgrep -f "$APPDIR/server.py" 2>/dev/null || true)"
  if [ -n "$pids" ]; then
    printf '   %sstopping the running server%s\n' "$CYAN" "$OFF"
    kill $pids 2>/dev/null || true
    sleep 1
    pids="$(pgrep -f "$APPDIR/server.py" 2>/dev/null || true)"
    if [ -n "$pids" ]; then kill -9 $pids 2>/dev/null || true; fi
  fi
  kill "$CAFF" 2>/dev/null || true

  # The one and only question this script ever asks, and only on the path that
  # cannot be undone. Every clip in the library cost a synthesis to make.
  if [ "$want" = "purge" ] && [ -d "$LIBDIR" ]; then
    printf '   %sThe library holds every text you have read and every clip that%s\n' "$RED" "$OFF"
    printf '   %swas synthesised for it. Removing it cannot be undone.%s\n\n' "$RED" "$OFF"
    printf '   %stype%s %sYES%s %sto destroy it. Anything else keeps it.%s\n' \
      "$DIM" "$OFF" "$B$RED" "$OFF" "$DIM" "$OFF"
    printf '\n   %s>%s ' "$RED" "$OFF"
    IFS= read -r ans || ans=""
    if [ "$ans" != "YES" ]; then
      want="remove"
      printf '   %slibrary kept%s\n' "$DIM" "$OFF"
    fi
  fi

  if [ -d "$APPDIR" ] || [ -f "$CMD" ]; then
    # all three commands, not just the launcher: leaving maread-update behind
    # means an uninstalled app can still be told to reinstall itself
    rm -f "$CMD" "$BIN/maread-update" "$BIN/maread-adb" 2>/dev/null || true
    rm -rf "$APPDIR" 2>/dev/null || true
    printf '   %sapp removed%s\n' "$GREEN" "$OFF"
  else
    printf '   %snothing was installed here%s\n' "$DIM" "$OFF"
  fi
  if [ "$want" = "purge" ]; then
    rm -rf "$LIBDIR" 2>/dev/null || true
    printf '   %slibrary removed%s\n' "$GREEN" "$OFF"
  else
    printf '   %slibrary kept at %s, reinstalling will find it%s\n' "$DIM" "$LIBDIR" "$OFF"
  fi
  printf '\n   %sExported books in MA Reader Audio are never touched by this%s\n' "$DIM" "$OFF"
  printf '   %sscript. Remove them by hand if you want them gone.%s\n' "$DIM" "$OFF"
  printf '\n   %sdone%s\n\n' "$GREEN" "$OFF"
}

if [ "$MODE" = "remove" ] || [ "$MODE" = "purge" ]; then
  do_remove "$MODE"
  exit 0
fi
banner_fire
# On a Mac the app owns a VENV and never touches the system Python, which on
# recent macOS refuses pip outright with "externally-managed-environment".
# PYBIN is the interpreter used to BUILD the venv; PYRUN is what actually runs
# the server. Once the venv exists they are different, and that is the point.
# Ported from his own 26sh_i_ma_reader_v26_macos.sh, which solved this already.
PYBIN="$(command -v python3 2>/dev/null || command -v python 2>/dev/null)"
VENV="$APPDIR/venv"
if [ -x "$VENV/bin/python" ]; then PYRUN="$VENV/bin/python"; else PYRUN="$PYBIN"; fi

# --------------------------------------------------------- dependency check --
# Shown before the install prompt so the decision is informed rather than a
# guess: all green means Enter is enough, any red means y is worth the wait.
dep_row() {
  # $1 label, $2 "ok"|"missing", $3 detail
  local mark colour
  if [ "$2" = "ok" ]; then
    mark="ok     "; colour="$GREEN"
  else
    mark="MISSING"; colour="$RED"
  fi
  printf '    %s%-9s%s %s%-7s%s  %s%s%s\n' \
    "$DIM" "$1" "$OFF" "$colour" "$mark" "$OFF" "$DIM" "$3" "$OFF"
}

have_cmd() { command -v "$1" >/dev/null 2>&1; }

check_deps() {
  DEPS_OK=1
  printf '   %sdependencies%s\n' "$B$GOLD" "$OFF"
  rule
  local v

  if [ -n "$PYBIN" ]; then
    v="$("$PYBIN" -c 'import sys;print("%d.%d.%d"%sys.version_info[:3])' 2>/dev/null)"
    dep_row "python3" "ok" "$v  $PYBIN"
  else
    dep_row "python3" "no" "required, everything else needs it"
    DEPS_OK=0
  fi

  if have_cmd ffmpeg; then
    v="$(ffmpeg -version 2>/dev/null | head -1 | awk '{print $3}')"
    dep_row "ffmpeg" "ok" "$v"
  else
    dep_row "ffmpeg" "no" "brew install ffmpeg"
    DEPS_OK=0
  fi

  if have_cmd ffprobe; then
    dep_row "ffprobe" "ok" "ships with ffmpeg"
  else
    dep_row "ffprobe" "no" "ships with ffmpeg"
    DEPS_OK=0
  fi

  for m in flask edge_tts; do
    if [ -n "$PYRUN" ] && "$PYRUN" -c "import $m" >/dev/null 2>&1; then
      v="$("$PYRUN" -c "
import $m, importlib.metadata as md
n={'edge_tts':'edge-tts'}.get('$m','$m')
print(getattr($m,'__version__','') or md.version(n))" 2>/dev/null)"
      dep_row "$m" "ok" "$v"
    else
      dep_row "$m" "no" "python package"
      DEPS_OK=0
    fi
  done
  if [ -n "$PYRUN" ] && "$PYRUN" -c "import numpy" >/dev/null 2>&1; then
    dep_row "numpy" "ok" "optional, only speeds up the word timing"
  else
    printf '    %s%-9s%s %s%-7s%s  %s%s%s\n' "$DIM" "numpy" "$OFF" "$DIM" "absent" \
      "$OFF" "$DIM" "optional, timing is identical without it" "$OFF"
  fi

  rule
  if [ "$DEPS_OK" = "1" ]; then
    printf '   %severything is here%s\n\n' "$GREEN" "$OFF"
  else
    printf '   %ssomething is missing, choose y below%s\n\n' "$RED" "$OFF"
  fi
}
# The old inline check printed its own table, and the standard dependency
# table below says the same thing in the agreed shape. Two tables is one too
# many, so this one only runs when a flag skipped the menu entirely.
if [ -n "$MODE" ]; then check_deps; fi
# ------------------------------------------------------------- progress -----
# One line, redrawn in place, with a real percentage against the real steps.
# Silent when this is not a terminal, so a log file does not fill with bars.
prog() {   # $1 percent, $2 what is happening
  [ -t 1 ] || return 0
  _w=22; _f=$(( $1 * _w / 100 )); _b=""; _i=0
  while [ "$_i" -lt "$_w" ]; do
    if [ "$_i" -lt "$_f" ]; then _b="$_b#"; else _b="$_b."; fi
    _i=$((_i+1))
  done
  printf '\r   %s[%s]%s %3d%%  %s%-26s%s' "$AMBER" "$_b" "$OFF" "$1" "$DIM" "$2" "$OFF"
  [ "$1" -ge 100 ] && printf '\n'
  return 0
}

# ----------------------------------------------------- the dependency table --
# Before anything is installed, one row per dependency: what it is, what it is
# needed for, and a green + if it is here or a red - if it is not. Optional
# pieces say so and never block anything.
dep_have() { command -v "$1" >/dev/null 2>&1; }
PYBIN="$(command -v python3 || command -v python || echo python)"
[ -x "$HOME/.maread-web/venv/bin/python" ] && PYBIN="$HOME/.maread-web/venv/bin/python"
dep_pymod() { "$PYBIN" -c "import $1" >/dev/null 2>&1; }

dep_table() {
  HAVE=0; MISS=0; MISSREQ=0
  printf '   %sdependencies%s\n' "$B$GOLD" "$OFF"
  rule
  row() {  # name, needed-for, present(0/1), optional(0/1)
    if [ "$3" = "1" ]; then
      printf '    %s+%s  %-13s %s%s%s\n' "$GREEN" "$OFF" "$1" "$DIM" "$2" "$OFF"
      HAVE=$((HAVE+1))
    else
      printf '    %s-%s  %-13s %s%s%s\n' "$RED" "$OFF" "$1" "$DIM" "$2" "$OFF"
      MISS=$((MISS+1)); [ "$4" = "1" ] || MISSREQ=$((MISSREQ+1))
    fi
  }
  dep_have python3 && P1=1 || P1=0
  row "python"   "runs the server"                      "$P1" 0
  dep_pymod flask && P2=1 || P2=0
  row "flask"    "serves the page"                      "$P2" 0
  dep_pymod edge_tts && P3=1 || P3=0
  row "edge-tts"  "the free voices"                     "$P3" 0
  dep_have ffmpeg && P4=1 || P4=0
  row "ffmpeg"    "exact clip lengths, optional"        "$P4" 1
  dep_have curl && P5=1 || P5=0
  row "curl"      "one word updates, optional"          "$P5" 1
  dep_have am && P6=1 || P6=0
  row "am"        "opens Chrome by name, optional"      "$P6" 1
  rule
  printf '    %s%s of %s present   %s missing%s\n' "$DIM" "$HAVE" "$((HAVE+MISS))" "$MISS" "$OFF"
  echo ""
}

# one keypress, no Enter, exactly like every other tool here
# ---------------------------------------------------- the echo guarantee ----
# READING ONE KEY MEANS TURNING ECHO OFF. If the script then dies between
# turning it off and turning it back on, the terminal is left deaf: the person
# types and nothing appears. Ctrl+C during a menu does exactly that, and so
# does closing the app, and the damage outlives the script.
#
# So the terminal's state is saved ONCE, before anything touches it, and a
# trap puts it back on EVERY way out: normal exit, Ctrl+C, TERM, HUP. The trap
# is armed BEFORE the first stty, because a trap armed afterwards is a trap
# with a hole in it exactly where the bug lives.
TTY_SAVED=""
[ -t 0 ] && TTY_SAVED="$(stty -g 2>/dev/null || true)"
tty_restore() {
  [ -n "$TTY_SAVED" ] && stty "$TTY_SAVED" 2>/dev/null || true
  # a second belt: sane puts echo back even if the saved string is unusable
  [ -t 0 ] && stty echo 2>/dev/null || true
}
trap 'tty_restore' EXIT
trap 'tty_restore; exit 130' INT
trap 'tty_restore; exit 143' TERM
trap 'tty_restore; exit 129' HUP

getkey() {
  if [ -t 0 ]; then
    old="$(stty -g 2>/dev/null)"
    # -icanon -echo, NOT raw. Full raw mode also turns OFF signals, so Ctrl+C
    # stops being a signal and becomes a plain byte: the trap never fires and
    # the terminal is left deaf. This reads one key AND leaves Ctrl+C working.
    stty -icanon -echo min 1 time 0 2>/dev/null
    k="$(dd bs=1 count=1 2>/dev/null)"
    stty "$old" 2>/dev/null
    printf '%s' "$k"
  else
    IFS= read -r k || k=""
    printf '%s' "$k"
  fi
}

if [ -z "$MODE" ]; then
  dep_table
  if [ "$MISSREQ" -gt 0 ]; then
    printf '   %s%s required piece(s) missing%s\n' "$RED" "$MISSREQ" "$OFF"
    printf '    %s[D]%s %sinstall them now, then carry on%s\n' "$KEY" "$OFF" "$DIM" "$OFF"
    printf '    %s[C]%s %scarry on anyway%s\n' "$KEY" "$OFF" "$DIM" "$OFF"
    printf '    %s[Q]%s %sback%s\n' "$KEY" "$OFF" "$DIM" "$OFF"
    printf '\n   %s>%s ' "$AMBER" "$OFF"
    K="$(getkey)"; echo ""
    case "$K" in
      d|D) MODE="online" ;;
      c|C) MODE="offline" ;;
      *)   echo ""; exit 0 ;;
    esac
  fi
fi

FROMMENU=0
while [ -z "$MODE" ]; do
  FROMMENU=1
  printf '   %swhat now%s\n' "$B$GOLD" "$OFF"
  rule
  printf '    %s[I]%s %sinstall or update, add whatever is missing%s\n' "$KEY" "$OFF" "$DIM" "$OFF"
  printf '    %s[D]%s %sdependencies only, add what the table says%s\n' "$KEY" "$OFF" "$DIM" "$OFF"
  printf '    %s[U]%s %suninstall%s\n' "$KEY" "$OFF" "$DIM" "$OFF"
  printf '    %s[\xe2\x86\xb5]%s %soffline, replace only the code already here%s\n' "$KEY" "$OFF" "$DIM" "$OFF"
  printf '    %s[Q]%s %squit%s\n' "$KEY" "$OFF" "$DIM" "$OFF"
  rule
  printf '\n   %s>%s ' "$AMBER" "$OFF"
  K="$(getkey)"; echo ""
  case "$K" in
    i|I)  MODE="online" ;;
    d|D)  MODE="deps" ;;
    u|U)
      printf '\n    %s[A]%s %sthe app only, keep my texts and keys%s\n' "$KEY" "$OFF" "$DIM" "$OFF"
      printf '    %s[E]%s %severything, the library as well%s\n' "$B$RED" "$OFF" "$DIM" "$OFF"
      printf '    %s[Q]%s %sback%s\n' "$KEY" "$OFF" "$DIM" "$OFF"
      printf '\n   %s>%s ' "$AMBER" "$OFF"
      K2="$(getkey)"; echo ""
      case "$K2" in
        a|A) MODE="remove" ;;
        e|E) MODE="purge" ;;
        *)   MODE="" ;;
      esac ;;
    q|Q)  echo ""; exit 0 ;;
    "")   MODE="offline" ;;
    *)    MODE="" ;;
  esac
done

if [ "$MODE" = "deps" ]; then
  printf '   %sfetching what is missing%s\n' "$AMBER" "$OFF"
  ( pkg update -y || true ) >/dev/null 2>&1 || true
  brew install python ffmpeg curl >/dev/null 2>&1 || true
  "$PYRUN" -m pip install --upgrade flask edge_tts >/dev/null 2>&1 || true
  echo ""
  dep_table
  exit 0
fi
if [ "$MODE" = "remove" ] || [ "$MODE" = "purge" ]; then
  do_remove "$MODE"
  exit 0
fi
printf '\n   %s%s%s\n\n' "$DIM" "$MODE" "$OFF"

# ---------------------------------------------------------- hard reinstall --
# Installing over the top of a previous version was the wrong idea. A file that
# moved or got renamed between versions simply stayed behind, and worse, a
# server still running from the last install keeps serving the page out of the
# process that is already in memory, so the browser shows the old app and the
# update looks like it did nothing at all. That is exactly what happened.
#
# So installing now means: stop whatever is running, put the things worth
# keeping somewhere safe, delete the whole app folder, write it fresh, and put
# the kept things back. Keys and settings survive. Nothing else does.
#
# The library at ~/.maread is never touched by any of this. Texts and their
# clips live there and are not part of the app.

# things that must survive a wipe. Keys above all: typing them again every
# update is the kind of small friction that makes a person stop updating.
# NOT speechify_voices.json: that is a cache of the voice catalogue, it costs
# a single request to rebuild, and carrying a stale one across an update is
# how the picker got stuck showing four voices out of nine hundred.
KEEP="adb_port.txt speechify_api.txt speechify_failed.json speechify_usage.json groq_api.txt groq_failed.json groq_model.json web_state.json web_state.json.bak browser.txt"

# --------------------------------------------------- is it running already? --
# A live server holds the old code in memory and keeps serving it after every
# file underneath it has changed, so an install over the top looks like it did
# nothing at all. It also has the files open while they are being replaced.
#
# The last version killed it silently. That was the wrong call: the person at
# the keyboard may be in the middle of listening to something. So it is
# detected, said plainly, and killed only when asked.
# Finding the server, without finding things that merely MENTION it.
#
# A bare "pgrep -f $APPDIR/server.py" matches far too much: an editor with the
# file open, a tail on it, and worst of all any shell whose command line
# happens to contain that path, which includes the installer itself in some
# invocations. It would then refuse to run because it had detected itself.
#
# The server is always started as: python <appdir>/server.py
# So require BOTH: the path is in the command line, AND the first token is a
# python. A shell is /bin/sh or /bin/bash and is excluded by that alone.
srv_pids() {
  for p in $(pgrep -f "$APPDIR/server.py" 2>/dev/null); do
    [ "$p" = "$$" ] && continue
    [ "$p" = "$PPID" ] && continue
    c="$(tr '\0' ' ' < "/proc/$p/cmdline" 2>/dev/null)"
    [ -z "$c" ] && continue
    first="${c%% *}"
    case "${first##*/}" in
      python|python2|python2.*|python3|python3.*) ;;
      *) continue ;;
    esac
    case "$c" in *"$APPDIR/server.py"*) echo "$p" ;; esac
  done
}

srv_stop() {   # returns 0 if nothing is running afterwards
  P="$(srv_pids)"
  [ -z "$P" ] && return 0
  kill $P 2>/dev/null || true
  n=0
  while [ "$n" -lt 20 ]; do
    sleep 0.25
    [ -z "$(srv_pids)" ] && return 0
    n=$((n+1))
  done
  P="$(srv_pids)"
  [ -n "$P" ] && kill -9 $P 2>/dev/null || true
  n=0
  while [ "$n" -lt 12 ]; do
    sleep 0.25
    [ -z "$(srv_pids)" ] && return 0
    n=$((n+1))
  done
  [ -z "$(srv_pids)" ]
}

RUNNING="$(srv_pids)"
if [ -n "$RUNNING" ]; then
  NPID="$(printf '%s\n' "$RUNNING" | wc -l | tr -d ' ')"
  PORTNOW=""
  [ -s "$APPDIR/port.txt" ] && PORTNOW="$(cat "$APPDIR/port.txt" 2>/dev/null)"
  echo ""
  printf '   %sMA Reader is running right now%s\n' "$B$AMBER" "$OFF"
  rule
  if [ -n "$PORTNOW" ]; then
    printf '    %sserving on%s   %shttp://localhost:%s%s\n' "$DIM" "$OFF" "$ASH1" "$PORTNOW" "$OFF"
  fi
  printf '    %sprocess%s      %s%s%s\n' "$DIM" "$OFF" "$ASH1" "$(printf '%s' "$RUNNING" | tr '\n' ' ')" "$OFF"
  printf '    %sthe files cannot be replaced underneath it, and it would go on%s\n' "$DIM" "$OFF"
  printf '    %sserving the old app out of memory even after they changed.%s\n' "$DIM" "$OFF"
  rule
  printf '    %s[K]%s %skill it and install%s\n' "$KEY" "$OFF" "$DIM" "$OFF"
  printf '    %s[Q]%s %sleave it alone, change nothing%s\n' "$KEY" "$OFF" "$DIM" "$OFF"
  echo ""
  if [ -t 0 ]; then
    printf '   %s>%s ' "$AMBER" "$OFF"
    KK="$(getkey)"; echo ""
  else
    # not a terminal, so this is maread-update or a script. Nobody is there to
    # answer, and it was asked to install, so take that as the answer.
    KK="K"
    printf '   %snot a terminal, so stopping it and carrying on%s\n' "$DIM" "$OFF"
  fi
  case "$KK" in
    k|K)
      printf '   %sstopping it%s\n' "$CYAN" "$OFF"
      if srv_stop; then
        printf '   %sstopped%s\n' "$GREEN" "$OFF"
      else
        echo ""
        printf '   %sit will not stop. Nothing has been changed.%s\n' "$B$RED" "$OFF"
        printf '   %sClose the Termux session that is running it, or reboot,%s\n' "$DIM" "$OFF"
        printf '   %sand run this again.%s\n' "$DIM" "$OFF"
        echo ""
        exit 1
      fi ;;
    *)
      echo ""
      printf '   %sleft running. Nothing has been changed.%s\n' "$DIM" "$OFF"
      echo ""
      exit 0 ;;
  esac
  kill "$CAFF" 2>/dev/null || true
fi

STASH=""
if [ -d "$APPDIR" ]; then

  # 2. keep or wipe?
  # Settings gain and lose keys as the app changes, and a file written by a
  # much older version can leave the app in a state nobody designed. So when
  # there is one, say so and let it be thrown away deliberately. Keys are
  # never part of this question: they are always kept.
  # Asked only when the menu was used, never on maread-update. An update runs
  # in the same terminal, so the tty test alone would put this question in
  # front of him on every single update, which is friction he did not ask for.
  WIPESET=0
  # asked for outright by maread-update, which has already put the question
  if [ "$WIPEFLAG" = "1" ] && [ -f "$APPDIR/web_state.json" ]; then
    WIPESET=1
    printf '   %ssettings will be wiped%s\n' "$CYAN" "$OFF"
  fi
  if [ "$WIPESET" = "0" ] && [ -f "$APPDIR/web_state.json" ] && [ -t 0 ] && [ "$FROMMENU" = "1" ]; then
    echo ""
    printf '   %syou have saved settings%s\n' "$B$GOLD" "$OFF"
    rule
    printf '    %s[K]%s %skeep them%s\n' "$KEY" "$OFF" "$DIM" "$OFF"
    printf '    %s[W]%s %swipe them, start at the factory settings%s\n' "$KEY" "$OFF" "$DIM" "$OFF"
    printf '    %s(your keys are kept either way)%s\n' "$DIM" "$OFF"
    rule
    printf '\n   %s>%s ' "$AMBER" "$OFF"
    KS="$(getkey)"; echo ""
    case "$KS" in
      w|W) WIPESET=1
           printf '   %ssettings will be wiped%s\n' "$CYAN" "$OFF" ;;
      *)   printf '   %ssettings kept%s\n' "$DIM" "$OFF" ;;
    esac
  fi

  # 3. carry the keys and settings out
  STASH="$(mktemp -d "${TMPDIR:-/tmp}/maread-keep.XXXXXX")"
  SAVED=0
  for f in $KEEP; do
    case "$f" in
      web_state.json|web_state.json.bak)
        [ "$WIPESET" = "1" ] && continue ;;   # deliberately left behind
    esac
    if [ -f "$APPDIR/$f" ]; then
      cp -p "$APPDIR/$f" "$STASH/$f" 2>/dev/null && SAVED=$((SAVED+1))
    fi
  done
  [ "$SAVED" -gt 0 ] && printf '   %skeeping %s file(s): keys and settings%s\n' "$DIM" "$SAVED" "$OFF"

  # 3. wipe. Not an upgrade, a clean slate.
  printf '   %sremoving the old version%s\n' "$DIM" "$OFF"
  rm -rf "$APPDIR"
fi

# only now, once installing is certain, does anything appear on disk
# a previous run that died between writing and renaming would leave these
for _c in maread maread-update maread-adb; do
  rm -f "$BIN/$_c.new" 2>/dev/null || true
done
prog 20 "making room"
# On Termux $PREFIX/bin always exists. On a Mac ~/.local/bin very often does
# not, and cat > into a missing folder fails silently enough that the install
# looks fine and leaves no commands behind.
mkdir -p "$BIN"
mkdir -p "$APPDIR/static"
SETUP_LOG="$APPDIR/install.log"; : > "$SETUP_LOG"

# a plain gold M on near black, so the home screen entry is not a blank square
cat > "$APPDIR/static/icon.svg" << 'ICONEOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img"
     aria-label="MA Reader">
  <!-- Three lines of text with the one being read lit. That is the whole app
       in one glyph, and it is the only shape that survives 16 pixels: an
       earlier version broke the middle line into separate words and they
       merged into mush in a browser tab. -->
  <rect width="64" height="64" rx="14" fill="#0a0d14"/>
  <rect x="11" y="15" width="42" height="6" rx="3" fill="#3f4557"/>
  <rect x="11" y="28" width="30" height="9" rx="4.5" fill="#ebcd2d"/>
  <rect x="11" y="44" width="34" height="6" rx="3" fill="#3f4557"/>
</svg>
ICONEOF

if [ "$MODE" = "online" ]; then
  printf '   %sfetching python, ffmpeg, flask and edge-tts%s\n' "$AMBER" "$OFF"
  ( pkg update -y || true ) >>"$SETUP_LOG" 2>&1 || true
  brew install python ffmpeg >>"$SETUP_LOG" 2>&1 || true
  # build the venv first, then fill it. Never the system Python.
  if [ -n "$PYBIN" ] && [ ! -x "$VENV/bin/python" ]; then
    "$PYBIN" -m venv "$VENV" >>"$SETUP_LOG" 2>&1 || true
  fi
  [ -x "$VENV/bin/python" ] && PYRUN="$VENV/bin/python"
  "$PYRUN" -m pip install --no-cache-dir --upgrade pip >>"$SETUP_LOG" 2>&1 || true
  "$PYRUN" -m pip install --no-cache-dir --upgrade flask edge-tts >>"$SETUP_LOG" 2>&1 || true
  # numpy only makes the waveform measurement faster; the engine has a pure
  # Python path that produces bit-identical times without it, so a failed
  # build here is harmless.
  "$PYRUN" -m pip install --no-cache-dir numpy >>"$SETUP_LOG" 2>&1 || true
  printf '   %sffmpeg lets the app listen to each clip and pin every word to%s\n' "$DIM" "$OFF"
  printf '   %sthe real waveform; without it timing falls back to edge%s\n' "$DIM" "$OFF"
  printf '   %swriting the app%s\n' "$GOLD" "$OFF"
else
  printf '   %sskipping the dependency check%s\n' "$DIM" "$OFF"
  printf '   %sif flask or edge-tts turn out to be missing, run again and press y%s\n' "$DIM" "$OFF"
  printf '   %swriting the app%s\n' "$GOLD" "$OFF"
fi

prog 35 "the server"
cat > "$APPDIR/server.py" << 'PYEOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MA READER WEB - Flask engine for the browser front end.

Same per-sentence engine as the terminal MA Reader: text is cleaned, split into
sentences, and each sentence is spoken by edge-tts into its own mp3 with word
timings. The browser plays those clips and drives the highlight, so the
highlighted sentence stays lit when playback is paused or stopped.

The library lives at ~/.maread/library, shared with the terminal app.
"""
import os, re, json, time, shutil, threading, asyncio, base64, hashlib, uuid
import struct, subprocess, urllib.request, urllib.error, urllib.parse
from flask import (Flask, request, jsonify, send_file, abort,
                   send_from_directory)
import unicodedata

# ---------- storage (shared with the terminal MA Reader) ----------
HOME = os.path.expanduser("~")
BASE = os.path.join(HOME, ".maread")
LIB_DIR = os.path.join(BASE, "library")
STATE_FILE = os.path.join(HOME, ".maread-web", "web_state.json")
WEB_DIR = os.path.join(HOME, ".maread-web")
MANIFEST_SCHEMA = "mareader-karaoke/3"       # per-sentence clips (v9)
MANIFEST_SCHEMA_LEGACY = "mareader-karaoke/2"  # old single stitched mp3
STATIC_DIR = os.path.join(HOME, ".maread-web", "static")
os.makedirs(LIB_DIR, exist_ok=True)

BASE_PORT = int(os.environ.get("MAREAD_WEB_PORT", "8081"))
PORT = BASE_PORT          # the real one is picked at startup by _pick_port
HOST = os.environ.get("MAREAD_WEB_HOST", "127.0.0.1")
PORT_FILE = os.path.join(HOME, ".maread-web", "port.txt")

# ---------- languages & voices ----------
# Every language group ships exactly two Microsoft neural voices, one female
# and one male, at the same top tier as the English and Croatian pair the app
# started with. LANGS is the source of truth; VOICES (the flat id -> tuple map
# the rest of the engine already speaks) is derived from it below, keeping the
# original ids 1..4 and disk vkeys (ukF/ukM/hrF/hrM) untouched so nothing that
# was cached or saved before breaks.
#
# Only real languages appear here. Some voices can also stand in for a dialect
# or a related tongue that has no neural voice of its own; that is written as a
# plain "uses" line shown under the language in Settings, NOT as its own button.
#   Croatian -> also reads Dalmatian and Čakavština (same Latin letters, read in
#               standard Croatian pronunciation).
#   Hindi    -> also reads Sanskrit (Devanagari script; romanised IAST will not
#               read well).
#
# Each language: key, label, native name, an optional "uses" note, and
# (female, male) where each voice is (edge voice id, display name). "vkeys"
# pins the on-disk cache/id keys so ids and folders stay stable across versions.
LANGS = [
    {"key":"en",  "label":"English (UK)",           "native":"",
     "vkeys":("ukF","ukM"),
     "female":("en-GB-SoniaNeural",     "Sonia"),
     "male":  ("en-GB-RyanNeural",      "Ryan")},
    {"key":"hr",  "label":"Croatian",                "native":"Hrvatski",
     "uses":"Dalmatian, Čakavština",
     "vkeys":("hrF","hrM"),
     "female":("hr-HR-GabrijelaNeural", "Gabrijela"),
     "male":  ("hr-HR-SreckoNeural",    "Srecko")},
]

# Default set of languages shown in the top picker (the two the app has always
# shown). Everything else is one checkbox away in Settings.
DEFAULT_LANGS = ["en", "hr"]

# Derive the flat id -> (edge voice, name, lang code, sex, vkey) map the engine
# uses everywhere else. ids stay stable: en gets 1/2, hr gets 3/4, then the
# rest follow in the LANGS order.
VOICES = {}
LANG_BY_KEY = {}
def _build_voices():
    vid = 1
    for lg in LANGS:
        LANG_BY_KEY[lg["key"]] = lg
        for sex, slot, vk in (("F", "female", lg["vkeys"][0]),
                              ("M", "male",   lg["vkeys"][1])):
            edge, name = lg[slot]
            VOICES[vid] = (edge, name, lg["key"], sex, vk)
            vid += 1
_build_voices()
VKEYS = {v[4] for v in VOICES.values()}
VOICE_BY_VKEY = {v[4]: v for v in VOICES.values()}
# vkey -> language key, so a voice can report which language group it belongs to
VKEY_LANG = {v[4]: v[2] for v in VOICES.values()}
UNIT_CAP = 320

def voice_label(langkey, sex):
    """Human label like 'Croatian female' shown under a voice button."""
    lg = LANG_BY_KEY.get(langkey)
    base = lg["label"] if lg else langkey
    return base + (" female" if sex == "F" else " male")

# ---------- text -> sentences -> units ----------
_SENT_RE = re.compile(r"(?<=[.!?\u2026])\s+")

def split_sentences(text, lo=0, hi=None):
    if hi is None:
        hi = len(text)
    spans, start = [], lo
    for m in _SENT_RE.finditer(text, lo, hi):
        spans.append((start, m.start())); start = m.end()
    if start < hi:
        spans.append((start, hi))
    return [(a, b) for a, b in spans if text[a:b].strip()]

# A blank line in the RENDERED text is a real boundary: a heading, a list item,
# a table row, a paragraph. The sentence splitter only breaks on . ! and ?, so
# without this a heading is glued to the paragraph under it and every list item
# runs into the next one. Only ever applied to Markdown, never to plain text,
# where a blank line means only that someone pressed return twice.
_BLOCK_RE = re.compile(r"\n{2,}")

def split_units(text, cap=UNIT_CAP, blocks=False):
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    if blocks:
        ranges, start = [], 0
        for m in _BLOCK_RE.finditer(text):
            ranges.append((start, m.start())); start = m.end()
        ranges.append((start, len(text)))
        ranges = [(a, b) for a, b in ranges if text[a:b].strip()]
    else:
        ranges = [(0, len(text))]
    units = []
    for ra, rb in ranges:
        for a, b in split_sentences(text, ra, rb):
            s = a
            while b - s > cap:
                cut = text.rfind(" ", s, s + cap)
                if cut <= s:
                    cut = s + cap
                if text[s:cut].strip():
                    units.append((s, cut))
                s = cut
                while s < b and text[s] in " \n\t":
                    s += 1
            if b > s and text[s:b].strip():
                units.append((s, b))
    return units

# ---------- clean: strip links + Markdown so only plain words are read ----------
_FENCE_RE   = re.compile(r"^\s*(?:```+|~~~+).*$", re.M)
_IMG_RE     = re.compile(r"!\[[^\]]*\]\([^)]*\)")
_AUTOLINK_RE= re.compile(r"<((?:https?|ftp|mailto):[^>\s]+)>", re.I)
_LINK_RE    = re.compile(r"\[([^\]]*)\]\([^)]*\)")
_REFLINK_RE = re.compile(r"\[([^\]]+)\]\[[^\]]*\]")
_REFDEF_RE  = re.compile(r"^\s{0,3}\[[^\]]+\]:\s+\S.*$", re.M)
_URL_RE     = re.compile(r"(?:(?:https?|ftp)://|www\.)[^\s<>)\]}\"']+", re.I)
_MAILTO_RE  = re.compile(r"\bmailto:[^\s<>)\]}\"']+", re.I)
_HTML_RE    = re.compile(r"</?[A-Za-z][^>]*>")
_CODE_RE    = re.compile(r"`+([^`]*)`+")
_EMPH_AST_RE= re.compile(r"(\*\*|\*|~~)(?=\S)(.+?)(?<=\S)\1", re.S)
_EMPH_US_RE = re.compile(r"(?<![\w])(__|_)(?=\S)(.+?)(?<=\S)\1(?![\w])", re.S)
_HEADING_RE = re.compile(r"^\s{0,3}#{1,6}\s*")
_QUOTE_RE   = re.compile(r"^\s{0,3}>+\s?")
_BULLET_RE  = re.compile(r"^(\s*)(?:[-*+]|\d+[.)])\s+")
_RULE_RE    = re.compile(r"^\s{0,3}(?:(?:[-*_]\s*){3,}|=+)\s*$")

def clean_text(text):
    if not text:
        return ""
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = _FENCE_RE.sub("", text)
    text = _IMG_RE.sub("", text)
    text = _AUTOLINK_RE.sub("", text)
    text = _LINK_RE.sub(r"\1", text)
    text = _REFLINK_RE.sub(r"\1", text)
    text = _REFDEF_RE.sub("", text)
    text = _URL_RE.sub("", text)
    text = _MAILTO_RE.sub("", text)
    text = _HTML_RE.sub("", text)
    text = _CODE_RE.sub(r"\1", text)
    for _ in range(3):
        new = _EMPH_AST_RE.sub(r"\2", text)
        new = _EMPH_US_RE.sub(r"\2", new)
        if new == text:
            break
        text = new
    out = []
    for ln in text.split("\n"):
        if _RULE_RE.match(ln):
            continue
        ln = _HEADING_RE.sub("", ln)
        ln = _QUOTE_RE.sub("", ln)
        ln = _BULLET_RE.sub(r"\1", ln)
        if "|" in ln:
            stripped = ln.strip()
            if stripped and set(stripped) <= set("|:- "):
                continue
            ln = ln.replace("|", " ")
        out.append(ln)
    text = "\n".join(out)
    text = re.sub(r"\(\s*\)", "", text)
    text = re.sub(r"\[\s*\]", "", text)
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\s+([.,;:!?])", r"\1", text)
    text = re.sub(r" *\n", "\n", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()

# ---------- library ----------
def _slug(title):
    s = "".join(c if c.isalnum() else "-" for c in title.lower())
    s = re.sub(r"-+", "-", s).strip("-")[:40] or "text"
    return "%s-%d" % (s, int(time.time()))

def lib_spoken(tid):
    """The RENDERED text, as the browser built it out of the word spans. Empty
    for a plain text and for anything saved before v3.12."""
    try:
        return open(os.path.join(LIB_DIR, tid, "spoken.txt"),
                    encoding="utf-8").read()
    except Exception:
        return ""

def lib_save(raw, spoken=""):
    """text.txt holds what was PASTED, markers and all. It used to hold the
    cleaned text, which threw the Markdown away at the door and left nothing
    to format later.

    spoken.txt holds what the VOICE is given. For Markdown that is the string
    the browser built by walking the rendered text nodes, so the words spoken
    and the words highlighted come from one place. For plain text it is not
    written at all and the old cleaner still decides."""
    text = spoken if spoken.strip() else clean_text(raw)
    title = next((ln.strip()[:48] for ln in text.splitlines() if ln.strip()),
                 "Untitled")
    tid = _slug(title)
    d = os.path.join(LIB_DIR, tid)
    os.makedirs(d, exist_ok=True)
    open(os.path.join(d, "text.txt"), "w", encoding="utf-8").write(raw)
    if spoken.strip():
        open(os.path.join(d, "spoken.txt"), "w", encoding="utf-8").write(spoken)
    meta = {"title": title, "created": int(time.time()),
            "chars": len(text),
            "units": len(split_units(text, blocks=bool(spoken.strip())))}
    json.dump(meta, open(os.path.join(d, "meta.json"), "w", encoding="utf-8"),
              ensure_ascii=False)
    return tid

def lib_list():
    out = []
    for tid in (os.listdir(LIB_DIR) if os.path.isdir(LIB_DIR) else []):
        mf = os.path.join(LIB_DIR, tid, "meta.json")
        if not os.path.isfile(mf):
            continue
        try:
            meta = json.load(open(mf, encoding="utf-8"))
        except Exception:
            continue
        meta["id"] = tid
        meta.setdefault("summary", "")
        out.append(meta)
    out.sort(key=lambda m: m.get("created", 0), reverse=True)
    return out

def lib_text(tid):
    try:
        return open(os.path.join(LIB_DIR, tid, "text.txt"),
                    encoding="utf-8").read()
    except Exception:
        return ""

def lib_delete(tid):
    shutil.rmtree(os.path.join(LIB_DIR, tid), ignore_errors=True)


def unit_seat(vkey):
    """What ACTUALLY produced the sound, as a short folder-safe tag.

    THE CACHE MUST BE KEYED ON WHAT MADE THE AUDIO, not on what was asked for.
    A Speechify vkey says only "Speechify"; which voice and which model speak
    is decided later, from the language switch and the two voice seats. So a
    clip made in English and one made in Croatian used to land in the SAME
    file, and switching to HR replayed the English clip for ever. That is the
    bug where the app looked deaf to its own settings.

    An Edge vkey names its own voice, so it needs no tag."""
    if not str(vkey).startswith("sp_"):
        return ""
    try:
        vid, model = sp_voice_for("", vkey)
    except Exception:
        return ""
    tag = "%s-%s" % (vid, model.replace("simba-", ""))
    # Letters, digits, underscore and hyphen ONLY. A dot is dropped as well:
    # without a separator a run of dots cannot traverse anywhere, but a folder
    # named with ".." in it is a thing someone will later read as dangerous and
    # have to reason about, and a name nobody has to reason about is better.
    return "__" + re.sub(r"[^A-Za-z0-9_-]", "", tag)[:40]


def unit_paths(tid, vkey, idx):
    ad = os.path.join(LIB_DIR, tid, "audio", vkey + unit_seat(vkey))
    os.makedirs(ad, exist_ok=True)
    base = os.path.join(ad, "s%04d" % idx)
    return base + ".mp3", base + ".tok.json"

def text_payload(tid):
    """Everything the front end needs to render and play a text.

    `source` is what was pasted. `spoken` is the exact string the voice is
    given, and `spans` are the character ranges of each sentence INSIDE it.
    Those offsets are how the page finds which word spans belong to which
    sentence; matching by text would be guesswork, and matching against the
    Markdown source would be wrong, because the source is never spoken.

    For a plain text `spoken` is simply the cleaned text, exactly as before.
    Texts saved before v3.12 have no spoken.txt and fall back to the cleaner,
    so nothing already on the phone changes meaning."""
    src = lib_text(tid)
    sp = lib_spoken(tid)
    rendered = bool(sp.strip())
    text = sp if rendered else clean_text(src)
    units = split_units(text, blocks=rendered)
    title = ""
    try:
        title = json.load(open(os.path.join(LIB_DIR, tid, "meta.json"),
                               encoding="utf-8")).get("title", "")[:64]
    except Exception:
        title = (text.strip().splitlines() or ["Untitled"])[0][:64]
    sentences = [text[a:b].strip() for a, b in units]
    return {"id": tid, "title": title, "sentences": sentences,
            "count": len(sentences), "source": src,
            "spoken": text, "spans": [[a, b] for a, b in units]}


# ---------- align edge-tts word timings to exact character ranges ----------
_TOKEN_RE = re.compile(r"\S+")

def _norm(s):
    """alnum-only, lowercased, accents folded — for matching spoken words to
    the visible text even when the voice normalises punctuation/case."""
    s = unicodedata.normalize("NFKD", s)
    s = "".join(c for c in s if not unicodedata.combining(c))
    return "".join(c.lower() for c in s if c.isalnum())

def align_tokens(sentence, bounds, total=None):
    """Return [{s,e,t,e_t}] — for every visible word run in `sentence`, its start
    and end character offsets, the start time `t` (seconds) and the end time
    `e_t` (when the highlight should leave it). Times come from edge-tts word
    boundaries where they can be matched; everywhere else they are interpolated
    so the sweep is always monotonic, always spans the whole clip, and NEVER
    collapses onto a single word.

    `total` is the clip duration in seconds when known; it anchors the tail so
    the last word un-highlights at the right moment.

    The critical robustness rule: if matching fails for some or all words (the
    voice expanded numbers, spelled an acronym, read symbols, or simply emitted
    odd boundaries), we still hand back a left-to-right spread proportional to
    each word's length, instead of dumping every word at t=0 (which used to make
    the highlight stick to the last word for the whole sentence)."""
    tokens = [(m.start(), m.end()) for m in _TOKEN_RE.finditer(sentence)]
    out = [{"s": a, "e": b, "t": None, "d": None} for (a, b) in tokens]
    n = len(tokens)
    if not n:
        return []
    bn = [(_norm(x["w"]), x["t"], x.get("d", 0.0)) for x in bounds]
    bn = [(w, t, d) for (w, t, d) in bn if w]
    bi, nB = 0, len(bn)
    for ti, (a, b) in enumerate(tokens):
        tok = _norm(sentence[a:b])
        if not tok:
            continue                       # pure punctuation: interpolate later
        start_bi = bi
        guard = 0
        found = False                      # skip stray boundaries to resync
        while bi < nB and guard < 6:
            bw = bn[bi][0]
            if tok.startswith(bw) or bw.startswith(tok) or bw == tok:
                found = True; break
            bi += 1; guard += 1
        if not found:                      # no boundary for this word: leave it
            bi = start_bi                  # for interpolation, don't consume any
            continue
        out[ti]["t"] = bn[bi][1]           # exact engine start time
        last_t, last_d = bn[bi][1], bn[bi][2]
        acc = ""                           # consume boundaries that build it up
        while bi < nB:
            acc += bn[bi][0]
            last_t, last_d = bn[bi][1], bn[bi][2]
            bi += 1
            if acc == tok or not tok.startswith(acc):
                break
        out[ti]["d"] = last_t + last_d     # spoken end of this word

    known = [(i, o["t"]) for i, o in enumerate(out) if o["t"] is not None]

    # widths used to spread any words we could not time directly
    widths = [max(1, b - a) for (a, b) in tokens]

    if not known:
        # NOTHING matched: spread proportionally across the whole clip so the
        # highlight still travels word by word instead of freezing on the last.
        span = total if (total and total > 0.1) else (0.32 * n)
        acc = 0.0
        wsum = float(sum(widths))
        for i, w in enumerate(widths):
            out[i]["t"] = span * (acc / wsum)
            acc += w
            out[i]["d"] = span * (acc / wsum)
        return out

    # fill before the first known time, holding it steady
    fi, ft = known[0]
    for i in range(fi):
        out[i]["t"] = ft
    # interpolate gaps between known anchors, weighting by word width so long
    # words get proportionally more time than short ones
    for (i0, t0), (i1, t1) in zip(known, known[1:]):
        gap = i1 - i0
        if gap <= 1:
            continue
        seg = widths[i0 + 1:i1]
        ws = float(sum(seg)) or 1.0
        acc = 0.0
        for k, j in enumerate(range(i0 + 1, i1)):
            acc += seg[k]
            out[j]["t"] = t0 + (t1 - t0) * (acc / ws) - (t1 - t0) * (seg[k] / ws)
    # fill after the last known time, spreading toward the clip end
    li, lt = known[-1]
    tail_end = total if (total and total > lt + 0.05) else lt + 0.45 * (n - li)
    rest = list(range(li + 1, n))
    if rest:
        seg = [widths[j] for j in rest]
        ws = float(sum(seg)) or 1.0
        acc = 0.0
        for k, j in enumerate(rest):
            out[j]["t"] = lt + (tail_end - lt) * (acc / ws)
            acc += seg[k]

    # enforce non-decreasing start times
    prev = 0.0
    for o in out:
        if o["t"] is None or o["t"] < prev:
            o["t"] = prev
        prev = o["t"]
    # derive a sensible end time for every word: it ends when the next begins,
    # and the last word ends at the clip end (or just after its own start)
    for i in range(n):
        nxt = out[i + 1]["t"] if i + 1 < n else (
            total if (total and total > out[i]["t"]) else out[i]["t"] + 0.4)
        if out[i]["d"] is None or out[i]["d"] <= out[i]["t"] or out[i]["d"] > nxt:
            out[i]["d"] = nxt
        if out[i]["d"] <= out[i]["t"]:     # never zero-length: hold to next word
            out[i]["d"] = nxt
    return out

# ---------- waveform alignment (the v11 engine) ----------
# Edge-tts reports word times on ITS OWN clock, which is not the clock of the
# final mp3: the encoder pads the start, the voice pads pauses, and the two
# drift apart. Caption tools like DaVinci stay glued to speech because they
# LISTEN to the finished audio. This engine does the same on a phone budget:
# it decodes each little clip to raw samples with ffmpeg, measures where speech
# energy actually starts, ends, and rises after every pause, then re-anchors
# and snaps the engine's word times onto that real waveform. The result is
# per-word timing measured from the very audio that will be played.

_FFMPEG = shutil.which("ffmpeg")

_ENV_SR = 16000         # decode rate: Nyquist 8 kHz, so fricatives are visible
_ENV_HOP_MS = 5         # one envelope frame every 5 ms
_ENV_WIN_MS = 20        # each frame measures a 20 ms window (frames overlap)

try:
    import numpy as _np
except Exception:
    _np = None

def _win_rms(sq, n_hop, n_win, count):
    """RMS of every overlapping window from a prefix sum of squares: the
    window cost is O(1), so overlapping frames are free."""
    out = []
    for k in range(count):
        a = k * n_hop
        out.append(((sq[a + n_win] - sq[a]) / n_win) ** 0.5)
    return out

def _pcm_env(mp3_path):
    """Decode the mp3 to mono 16 kHz and return (env, hi, dur).

    `env` is the broadband RMS of a 20 ms window taken every 5 ms. `hi` is the
    same measurement on a pre-emphasised copy of the signal (y[n]-0.97*y[n-1]),
    which lifts fricatives and plosive bursts -- s, f, sh, th, t, k -- far above
    the noise floor.

    Why two bands. A word does not begin at its loudest point. `Sunce` begins
    at the s, `she` at the sh, `first` at the f. Those consonants carry real
    energy but almost none of it is low frequency, so on a broadband envelope
    alone they are nearly invisible and the word looks like it starts at the
    vowel, up to 150 ms late. `hi` sees them. Returns (None, None, 0.0) if
    ffmpeg is missing or the clip is unusable."""
    if not _FFMPEG:
        return None, None, 0.0
    try:
        p = subprocess.run(
            [_FFMPEG, "-v", "quiet", "-i", mp3_path,
             "-ac", "1", "-ar", str(_ENV_SR), "-f", "s16le", "-"],
            capture_output=True, timeout=90)
        raw = p.stdout
    except Exception:
        return None, None, 0.0
    if not raw or len(raw) < _ENV_SR // 5:       # under 0.1 s: not usable
        return None, None, 0.0

    n_hop = _ENV_SR * _ENV_HOP_MS // 1000        # 80 samples
    n_win = _ENV_SR * _ENV_WIN_MS // 1000        # 320 samples

    if _np is not None:
        a = _np.frombuffer(raw[:len(raw) // 2 * 2], dtype="<i2").astype(_np.float64)
        dur = len(a) / float(_ENV_SR)
        count = (len(a) - n_win) // n_hop + 1
        if count < 4:
            return None, None, dur
        pre = _np.empty_like(a)
        pre[0] = a[0]
        pre[1:] = a[1:] - 0.97 * a[:-1]
        idx = _np.arange(count) * n_hop
        bands = []
        for sig in (a, pre):
            sq = _np.concatenate(([0.0], _np.cumsum(sig * sig)))
            bands.append(_np.sqrt((sq[idx + n_win] - sq[idx]) / n_win).tolist())
        return bands[0], bands[1], dur

    import array
    a = array.array("h")
    a.frombytes(raw[:len(raw) // 2 * 2])
    dur = len(a) / float(_ENV_SR)
    count = (len(a) - n_win) // n_hop + 1
    if count < 4:
        return None, None, dur
    n = len(a)
    sq = [0.0] * (n + 1)
    sqp = [0.0] * (n + 1)
    prev = 0
    t1 = t2 = 0.0
    for i in range(n):
        v = a[i]
        t1 += float(v) * v
        sq[i + 1] = t1
        d = v - 0.97 * prev
        prev = v
        t2 += d * d
        sqp[i + 1] = t2
    return (_win_rms(sq, n_hop, n_win, count),
            _win_rms(sqp, n_hop, n_win, count), dur)

def _levels(env):
    """Noise floor, speech peak and dynamic range, measured from the clip
    itself. Thresholds taken from the floor upward survive a clip with one
    shouted word in it, which a plain fraction-of-peak threshold does not:
    there, every quiet word falls under the bar and stops being detected."""
    s = sorted(env)
    floor = s[int(len(s) * 0.05)]
    peak = s[int(len(s) * 0.97)]
    if peak <= floor:
        peak = s[-1]
    return floor, peak, max(peak - floor, 1e-9)

def _speech_span(env, hi, W):
    """First and last sustained speech in seconds, taken from whichever band
    shows it first, so a clip that opens on a fricative is not clipped off."""
    f1, p1, s1 = _levels(env)
    f2, p2, s2 = _levels(hi)
    thr1, thr2 = f1 + s1 * 0.10, f2 + s2 * 0.10
    onset = None
    for i in range(len(env) - 3):
        if ((env[i] > thr1 and env[i + 1] > thr1 and env[i + 2] > thr1) or
                (hi[i] > thr2 and hi[i + 1] > thr2 and hi[i + 2] > thr2)):
            onset = i * W
            break
    last = None
    for i in range(len(env) - 1, 0, -1):
        if ((env[i] > thr1 and env[i - 1] > thr1) or
                (hi[i] > thr2 and hi[i - 1] > thr2)):
            last = (i + 1) * W
            break
    return onset, last

# ---------- the quiet between words (v26) ----------
# Word gap never re-synthesises anything. It changes how the player crosses the
# quiet the voice ALREADY leaves between one word and the next, so that quiet
# has to be measured once and shipped alongside the word times.
#
# A frame counts as quiet only when BOTH bands are down. The broadband envelope
# alone calls a fricative tail silence, and cutting there eats the s off the end
# of a word. Each run is then pulled in by a guard at both ends, so an edit made
# inside it can never reach a consonant, and a run that does not survive the
# guard was never a pause between words in the first place.
_SIL_THR = 0.06        # of the clip's own dynamic range, measured from the floor
_SIL_MIN_MS = 70       # anything shorter is inside a word, not between two
_SIL_GUARD_MS = 18     # untouchable margin kept at each end of every run

def silence_runs(env, hi, W, onset, last):
    """Quiet stretches strictly between the first and last speech, in seconds."""
    if not env or not hi:
        return []
    f1, p1, s1 = _levels(env)
    f2, p2, s2 = _levels(hi)
    thr1, thr2 = f1 + s1 * _SIL_THR, f2 + s2 * _SIL_THR
    n = min(len(env), len(hi))
    raw, i = [], 0
    while i < n:
        if env[i] <= thr1 and hi[i] <= thr2:
            j = i
            while j < n and env[j] <= thr1 and hi[j] <= thr2:
                j += 1
            raw.append((i * W, j * W))
            i = j
        else:
            i += 1
    lo = onset if onset is not None else 0.0
    hg = last if last is not None else 1e9
    g = _SIL_GUARD_MS / 1000.0
    out = []
    for (a, b) in raw:
        a, b = max(a, lo) + g, min(b, hg) - g
        if b - a >= _SIL_MIN_MS / 1000.0:
            out.append([round(a, 3), round(b, 3)])
    return out

def measure_silence(mp3_path):
    """The silence map for one clip, or [] if it cannot be measured."""
    env, hi, dur = _pcm_env(mp3_path)
    if not env or not hi or dur <= 0.2:
        return []
    W = _ENV_HOP_MS / 1000.0
    onset, last = _speech_span(env, hi, W)
    return silence_runs(env, hi, W, onset, last)

_MIN_PAUSE_MS = 90   # a rise only anchors a word if this much real quiet led in
_BACKTRACK_MS = 220  # never walk an onset back further than this

def _rise_points(env, hi, W):
    """Audible starts of words or word groups, each backtracked to its true
    onset.

    Detection stays deliberately strict: the energy must climb clear of the
    floor after a real pause and must stay up afterwards, so plosives inside a
    word, clicks and breaths do not invent word starts. But detection fires on
    the unambiguous, loud part of the word, which is usually the vowel, and
    that is not where the word begins. So every detection is then walked back
    down its own energy slope to the foot of the rise, the point where the
    sound actually left the noise floor. The strictness decides *whether* there
    is a word here; the backtrack decides *when* it started. Measured against
    hand-checked onsets this removes about 50 ms of systematic lateness, and
    around 150 ms on words that open with s, sh or f."""
    f1, p1, s1 = _levels(env)
    f2, p2, s2 = _levels(hi)
    thr1, low1 = f1 + s1 * 0.10, f1 + s1 * 0.04
    thr2, low2 = f2 + s2 * 0.10, f2 + s2 * 0.04
    gap = int(_MIN_PAUSE_MS / (W * 1000.0))
    look = max(3, int(50 / (W * 1000.0)))
    back = int(_BACKTRACK_MS / (W * 1000.0))
    need = look * 0.6
    rises = []
    quiet = 10 ** 6                    # treat the file start as a long pause
    n = len(env)
    for i in range(n):
        loud = env[i] > thr1 or hi[i] > thr2
        if env[i] < low1 and hi[i] < low2:
            quiet += 1
            continue
        if loud and quiet >= gap:
            hits = 0
            for k in range(i, min(i + look, n)):
                if env[k] > thr1 * 0.7 or hi[k] > thr2 * 0.7:
                    hits += 1
            if hits >= need:
                j = i
                stop = max(0, i - back)
                while j > stop:
                    q = j - 1
                    if env[q] < low1 and hi[q] < low2:
                        break                      # reached the silence
                    if env[q] > env[j] and hi[q] > hi[j]:
                        break                      # reached a local minimum
                    j = q
                rises.append(j * W)
        if loud:
            quiet = 0
    out = []                            # collapse feet that backtracked together
    for r in rises:
        if not out or r > out[-1] + 0.03:
            out.append(r)
    return out

_ANCHOR_SKIP = 0.35   # price of declaring a detected rise "not a word"
_ANCHOR_CAP = 0.50    # a word/rise pair further apart than this is junk

def _match_anchors(word_ts, rises):
    """Assign audible rises to word starts, in order, so the TOTAL
    disagreement is smallest (dynamic programming, the same idea real forced
    aligners use). Not every rise is a word and not every word has a rise:
    words inside a continuous phrase have no onset of their own. So the
    alignment may skip either side at a cost. Greedy nearest-matching cannot
    do this; the global view can.

    `_ANCHOR_SKIP` is the important number. Once onsets are backtracked they
    are trustworthy, so throwing one away has to be expensive; at the old
    price of 0.18 the solver would rather discard a real onset than accept a
    word the engine had placed 0.4 s off, which is exactly the case where the
    measurement was needed most. Raising it to 0.35 cut alignment error by
    two thirds on the test corpus. Returns [(word_index, rise_time)]."""
    n, m = len(word_ts), len(rises)
    if not n or not m:
        return []
    SKIP = _ANCHOR_SKIP
    CAP = _ANCHOR_CAP
    dp = [[0.0] * (n + 1) for _ in range(m + 1)]
    for j in range(1, m + 1):
        dp[j][0] = dp[j - 1][0] + SKIP
    for j in range(1, m + 1):
        for i in range(1, n + 1):
            best = dp[j][i - 1]                       # word i has no rise
            c = dp[j - 1][i] + SKIP                   # rise j is not a word
            if c < best:
                best = c
            pair = abs(word_ts[i - 1] - rises[j - 1])
            if pair <= CAP:
                c = dp[j - 1][i - 1] + pair           # rise j starts word i
                if c < best:
                    best = c
            dp[j][i] = best
    out = []
    j, i = m, n
    while j > 0 and i > 0:
        pair = abs(word_ts[i - 1] - rises[j - 1])
        if pair <= CAP and abs(dp[j][i] - (dp[j - 1][i - 1] + pair)) < 1e-9:
            out.append((i - 1, rises[j - 1]))
            j -= 1
            i -= 1
        elif abs(dp[j][i] - (dp[j - 1][i] + SKIP)) < 1e-9:
            j -= 1
        else:
            i -= 1
    out.reverse()
    return out

def refine_tokens(mp3_path, tokens):
    """Re-anchor word times onto the real decoded waveform of `mp3_path`.
    Three passes, like a caption tool: (1) stretch the whole engine timeline so
    first and last speech land where the audio really starts and ends, (2) pin
    every audible onset to the word it belongs to and warp the words in between
    proportionally, (3) tidy so every word holds until the next begins. Returns
    (tokens, dur, changed); on any trouble the original tokens come back
    untouched."""
    if not tokens:
        return tokens, 0.0, False
    env, hi, dur = _pcm_env(mp3_path)
    if not env or not hi or dur <= 0.2:
        return tokens, dur if dur else 0.0, False
    W = _ENV_HOP_MS / 1000.0
    onset, last = _speech_span(env, hi, W)
    if onset is None or last is None or last - onset < 0.15:
        return tokens, dur, False

    t0 = float(tokens[0].get("t", 0.0))
    t1 = max(float(t.get("d", t.get("t", 0.0))) for t in tokens)
    if t1 - t0 < 0.05:
        return tokens, dur, False

    # 1) affine re-anchor: first word -> measured speech onset, last word end
    #    -> measured speech end. Kills constant lag and overall drift.
    a = (last - onset) / (t1 - t0)
    if not (0.5 < a < 2.0):
        a = 1.0
    b = onset - a * t0
    ref = []
    for t in tokens:
        nt = a * float(t.get("t", 0.0)) + b
        nd = a * float(t.get("d", t.get("t", 0.0))) + b
        ref.append({"s": t.get("s", 0), "e": t.get("e", 0), "t": nt, "d": nd})

    # 2) anchor warp: every audible onset is the true start of a word (or
    #    phrase). A global order-keeping match decides which word each onset
    #    belongs to, then all times are warped piecewise-linearly so those
    #    words land exactly on their onsets and everything between stretches
    #    proportionally with them.
    rises = _rise_points(env, hi, W)
    word_ts = [w["t"] for w in ref]
    pairs = _match_anchors(word_ts, rises)
    anchors = [(word_ts[i], r) for (i, r) in pairs]
    anchors.append((max(ref[-1]["d"], anchors[-1][0] + 0.01 if anchors else 0),
                    min(last, dur)))
    clean = []
    for (x, y) in anchors:
        if not clean or (x > clean[-1][0] + 1e-3 and y > clean[-1][1] + 1e-3):
            clean.append((x, y))
    if len(clean) >= 2:
        def warp(x):
            if x <= clean[0][0]:
                return clean[0][1] + (x - clean[0][0])
            for (x0, y0), (x1, y1) in zip(clean, clean[1:]):
                if x <= x1:
                    return y0 + (x - x0) * (y1 - y0) / (x1 - x0)
            xN, yN = clean[-1]
            return yN + (x - xN)
        for w in ref:
            w["t"] = warp(w["t"])
            w["d"] = warp(w["d"])

    # 3) tidy: strictly increasing starts, each word holds until the next
    #    begins, never past the real clip end, never zero length.
    prev = -1.0
    for w in ref:
        if w["t"] <= prev:
            w["t"] = prev + 0.01
        prev = w["t"]
    for i, w in enumerate(ref):
        nxt = ref[i + 1]["t"] if i + 1 < len(ref) else min(last + 0.05, dur)
        if w["d"] <= w["t"] or w["d"] > nxt:
            w["d"] = nxt
        if w["d"] <= w["t"]:
            w["d"] = w["t"] + 0.05
        w["t"] = round(w["t"], 3)
        w["d"] = round(w["d"], 3)
    return ref, dur, True

def refine_unit_json(mp3_path, json_path):
    """Upgrade a cached unit's timing file in place with waveform-measured
    times, once. Old cached clips synthesized before v11 get repaired the
    first time they are touched, with no re-synthesis."""
    try:
        tok = json.load(open(json_path, encoding="utf-8"))
    except Exception:
        return
    # v26: a clip cached before word gap existed has no silence map. Measure it
    # once, here, and write it back. Deliberately ABOVE the early return below,
    # because a "pcm2" clip is fully timed and would otherwise never get one,
    # and deliberately not an engine bump, because nothing about the word times
    # has changed and re-measuring every cached clip would cost far more.
    if "sil" not in tok:
        tok["sil"] = measure_silence(mp3_path)
        try:
            json.dump(tok, open(json_path, "w", encoding="utf-8"),
                      ensure_ascii=False)
        except Exception:
            pass
    # "pcm2" is the v23 two-band backtracked engine. Clips measured by the
    # older "pcm" engine are re-measured exactly once, here, on first touch and
    # without re-synthesising anything; after that this returns immediately, so
    # a cache hit never decodes audio twice.
    # A Speechify clip is already timed from its own speech marks. Never
    # re-measure it: the marks are truer than anything a decode can infer.
    if tok.get("engine") in ("pcm2", "edge2", "speechify", "speechify-pcm"):
        return
    tokens = tok.get("tokens") or []
    ref, dur, changed = refine_tokens(mp3_path, tokens)
    tok["engine"] = "pcm2" if changed else "edge2"
    if changed:
        tok["tokens"] = ref
        if dur > 0:
            tok["total"] = round(dur, 3)
    try:
        json.dump(tok, open(json_path, "w", encoding="utf-8"),
                  ensure_ascii=False)
    except Exception:
        pass

# ---------- speech ----------
def _communicate(edge_tts, text, voice):
    """Build an edge-tts Communicate that really emits WordBoundary events.

    edge-tts 7.x changed the default boundary type from WordBoundary to
    SentenceBoundary. Constructing it the old way on a current install returns
    no word events at all, which silently drops the whole app onto the
    proportional fallback in align_tokens: words spread evenly across the clip
    rather than measured. Ask for WordBoundary explicitly, and fall back for
    older versions that do not take the keyword."""
    try:
        return edge_tts.Communicate(text, voice, boundary="WordBoundary")
    except TypeError:
        return edge_tts.Communicate(text, voice)

def synth_unit(text, voice, mp3_path, json_path):
    try:
        import edge_tts
    except Exception:
        return "edge-tts not installed"

    async def go():
        bounds = []
        com = _communicate(edge_tts, text, voice)
        with open(mp3_path + ".part", "wb") as f:
            async for ch in com.stream():
                if ch["type"] == "audio":
                    f.write(ch["data"])
                elif ch["type"] == "WordBoundary":
                    bounds.append({"t": ch["offset"] / 1e7,
                                   "d": ch["duration"] / 1e7, "w": ch["text"]})
        return bounds
    loop = asyncio.new_event_loop()
    try:
        bounds = loop.run_until_complete(go())
    except Exception as e:
        try:
            os.remove(mp3_path + ".part")
        except Exception:
            pass
        return "TTS failed: %s" % e
    finally:
        loop.close()
    try:
        if not os.path.getsize(mp3_path + ".part"):
            return "no audio"
    except Exception:
        return "no audio"
    os.replace(mp3_path + ".part", mp3_path)
    # best estimate of the clip length: end of the last timed word. This anchors
    # the highlight sweep so the final word releases at the right moment.
    total = 0.0
    for b in bounds:
        end = b.get("t", 0.0) + b.get("d", 0.0)
        if end > total:
            total = end
    tokens = align_tokens(text, bounds, total or None)
    engine = "edge2"
    # THE WAVEFORM REFINEMENT IS NOT RUN WHEN THE ENGINE GAVE US MARKS.
    #
    # Measured here, in this repository, against Speechify's exact speech
    # marks as ground truth (80 words, 6 sentences):
    #
    #     proportional   mean 297 ms   median 204 ms   19% within 50 ms
    #     pcm2           mean 329 ms   median 215 ms   10% within 50 ms
    #     whisper        mean  80 ms   median  44 ms   56% within 50 ms
    #
    # and on Edge audio with Whisper as the yardstick (53 words):
    #
    #     edge marks           mean 214 ms   median 87 ms
    #     edge marks + pcm2    mean 217 ms   median 92 ms
    #
    # The refinement costs a full waveform analysis per sentence and buys
    # nothing: three milliseconds worse on Edge marks, and worse than plain
    # proportional timing when it starts from a flat guess. This reproduces
    # independently what MAHA_TRANSCRIBE_STREAMLIT measured (88 ms against 89
    # ms unrefined) and explains itself: there is no acoustic gap at a word
    # boundary to snap to, because speech does not stop between words.
    #
    # It is kept for the case it was actually built for, a clip with NO marks
    # at all, where something is better than nothing.
    if not bounds:
        ref, dur, changed = refine_tokens(mp3_path, tokens)
        if changed:
            tokens = ref
            engine = "pcm2"
            if dur > 0:
                total = dur
    json.dump({"tokens": tokens, "bounds": bounds, "total": total,
               "engine": engine, "sil": measure_silence(mp3_path)},
              open(json_path, "w", encoding="utf-8"), ensure_ascii=False)
    return ""

def export_dir():
    cands = [os.path.join(HOME, "storage", "downloads"),
             os.path.join(HOME, "Downloads"),
             os.path.join(HOME, "downloads")]
    base = next((d for d in cands if os.path.isdir(d)), None)
    if base is None:
        base = os.path.join(HOME, "Downloads")
    d = os.path.join(base, "MA Reader Audio")
    os.makedirs(d, exist_ok=True)
    return d

# ---------- Speechify: the second engine ----------
# Edge and Speechify are two ways of turning the same sentence into the same
# kind of clip. Everything downstream - the per-sentence cache, the silence
# map the word pause rides on, the offline export - is identical. Two things
# differ, and both were confirmed against the live API rather than assumed:
#
#   1. Edge is free and keyless. Speechify is keyed, so the ring below exists.
#   2. Edge reports word times its own engine invented, which is why every Edge
#      clip is decoded afterwards and every word re-pinned to the waveform.
#      Speechify returns speech marks whose character offsets land exactly on
#      the text it was given - verified character-for-character - and whose
#      times are measured from the audio it just made. So on Speechify the
#      highlight needs no guessing at all.
#
# THE RING, AND WHY IT IS LAZY
#
# The obvious ring tests every key at startup and picks a winner. That is a
# waste: with twenty keys it spends twenty round trips to learn something it
# could have learned by simply trying. So this ring never tests speculatively.
# It takes the first key that is not already known to be dead and just uses it.
# Only when a real request comes back 401 or 403 is that key condemned - marked
# dead on disk, permanently - and the ring rolls forward to the next one and
# retries the same sentence. Steady state costs zero extra requests.
#
# A condemned key stays condemned across restarts, so a dead key is paid for
# exactly once, ever. The Settings sheet lists them and offers two ways out:
# Retry, which clears the mark in case the account was only suspended, and
# Remove, which strikes the key from the file for good.
#
# 429 is never condemnation. A throttled key is valid, so it is stood down for
# a few minutes and tried again later rather than thrown away, and a network
# failure is never blamed on the key at all.
SP_API = "https://api.sws.speechify.com"
SPEECHIFY_KEY_FILE = os.path.join(WEB_DIR, "speechify_api.txt")
SP_CACHE_FILE = os.path.join(WEB_DIR, "speechify_voices.json")
# The cache is derived data, and its SHAPE changed when the picker went from
# holding four voices to holding the whole catalogue. A cache written by the
# older code is still perfectly readable by the newer code, which is exactly
# the problem: it hands back four voices and the app believes there is only
# one page. Version it, and treat any other version as if it were not there.
SP_CACHE_V = 2
SP_FAIL_FILE = os.path.join(WEB_DIR, "speechify_failed.json")
SP_USE_FILE = os.path.join(WEB_DIR, "speechify_usage.json")

# Telling a key from a label in a shared key file, WITHOUT ever throwing a key
# away for its shape.
#
# Two mistakes are possible and only one of them is recoverable. Testing a
# label costs one wasted request. Discarding a real key because a provider
# quietly changed its format costs the key, silently, with nothing on screen
# to say so. Google has already done exactly that once, moving Gemini keys
# from AIza to AQ.
#
# So shape only RANKS. Anything on its own line, long enough and with no
# spaces in it, is a candidate. Ones that look like Speechify keys are tried
# first; the rest are tried after, and are never condemned to the dead list
# when they fail, because a long word in a notes file is not a dead key.
SP_KEY_RE = re.compile(r"^sk_[A-Za-z0-9_\-]{20,}$")
SP_MAYBE_RE = re.compile(r"^[A-Za-z0-9_\-\.]{20,}$")

# Speechify has no Croatian and no other Slavic voice, checked rather than
# guessed, so this engine is English and offers exactly the two accents.
SP_ACCENTS = [
    {"key": "uk", "label": "English (UK)", "locale": "en-GB"},
    {"key": "us", "label": "English (US)", "locale": "en-US"},
]
SP_ACCENT_KEYS = [a["key"] for a in SP_ACCENTS]

# The picker at the top of the reader has room for four buttons and not one
# more. But the catalogue holds 33 UK and 84 US voices and there is no way to
# know from a name whether you will like a voice, so the four buttons are a
# WINDOW onto the whole list rather than the whole list itself: the front end
# pages through it four at a time. Everything here is about the ORDER those
# pages arrive in, so the ones worth hearing first come first.
#
# The order is taken from Speechify's own documentation rather than invented.
# It names a curated set for new integrations, and separately calls four
# voices popular. Those go first, then everything else alphabetically.
SP_CURATED = ["beatrice", "dominic", "edmund", "geffen",
              "harper", "hugh", "imogen", "wyatt"]
SP_POPULAR = ["george", "henry", "carly", "sabrina"]
SP_PER_SET = 4                # four buttons, and no room for a fifth
SP_PER_SEX = 2                # so each page is two female and two male
SP_MODEL = "simba-english"


# ===========================================================================
# GROQ
#
# Used for one job only: deciding whether a text is English. Everything that
# is not English is Croatian, because those are the only two languages this
# app reads. One question, one word back.
#
# THE USER AGENT IS NOT OPTIONAL. api.groq.com sits behind Cloudflare, which
# blocks Python's default "Python-urllib/3.x" and answers 403 with "error
# code: 1010" on EVERY endpoint including /models. That looks exactly like ten
# dead keys and is not a key problem at all. Measured, not guessed.
GROQ_API = "https://api.groq.com/openai/v1"
GROQ_UA = ("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
           "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36")
GROQ_KEYFILE = os.path.join(WEB_DIR, "groq_api.txt")
GROQ_FAILED = os.path.join(WEB_DIR, "groq_failed.json")
GROQ_STATE = os.path.join(WEB_DIR, "groq_model.json")

# Preference order, measured on Baba's account 18.8.2026. compound-mini is
# fastest and answers in one clean word; allam-2-7b is nearly as quick; the
# gpt-oss pair put their thinking in a separate field and need token headroom;
# qwen writes <think> aloud inside the content and must be stripped.
# The app is NOT limited to this list: if Groq retires every one of them it
# discovers what is on offer and tries whatever can hold a conversation.
GROQ_PREFERRED = ["groq/compound-mini", "allam-2-7b", "openai/gpt-oss-20b",
                  "groq/compound", "openai/gpt-oss-120b", "qwen/qwen3.6-27b"]
# these cannot answer a question: speech in, speech out, or a safety filter
GROQ_NOT_CHAT = ("whisper", "orpheus", "prompt-guard", "safeguard", "tts")

_groq_i = 0
_groq_err = ""
_groq_rest = {}          # key fingerprint -> resting until (a 429 is not death)
_groq_skip = set()       # weak candidates that failed: skipped, never gravestoned


def _groq_fp(k):
    return hashlib.sha256(k.encode("utf-8")).hexdigest()[:16]


# Key recognition PORTED FROM Key_Tester/KeyParser.kt, which is itself ported
# from TTT's MaKeys. It is Baba's established parser and this is a faithful
# translation, not a fresh idea:
#
#   TOKEN LEVEL, NOT LINE LEVEL. Each line is split on separators, so quotes,
#   commas, brackets and equals signs fall away by themselves and several keys
#   can share a line. That is why a key pasted out of code works.
#
#   WHOLE TOKEN CLASSIFICATION, anchored. A gsk_ token is Groq and never a
#   stray sk_ match inside a longer string.
#
#   A LONG KEY-LIKE TOKEN OF AN UNKNOWN SHAPE IS KEPT, not dropped, because
#   providers rebrand key formats without notice. But it must look like a
#   credential: 24 characters or more, from the credential alphabet, and
#   carrying BOTH a letter and a digit. That one test is what rejects prose,
#   an email address, a URL, a file path and a row of identical letters.
#
#   THE LINE ABOVE A KEY IS ITS LABEL, verbatim, when it is not itself a key
#   line. That is how "Auroville community." names the key beneath it.
_K_HEX32 = re.compile(r"^[0-9a-fA-F]{32}$")
_K_GROQ = re.compile(r"^gsk_[0-9A-Za-z_-]{20,}$")
_K_GOOGLE = re.compile(r"^(AQ\.[0-9A-Za-z._-]{20,}|AIza[0-9A-Za-z_-]{20,})$")
_K_ANTHROPIC = re.compile(r"^sk-ant-[0-9A-Za-z_-]{20,}$")
_K_OPENAI = re.compile(r"^sk-(?!ant-)[0-9A-Za-z_-]{20,}$")
_K_SK_US = re.compile(r"^sk_[0-9A-Za-z_-]{16,}$")
_K_LOOSE = re.compile(r"^[A-Za-z0-9._-]{24,220}$")
_K_SEP = re.compile(r"[\s,;:\"'=|\[\](){}<>]+")


def key_classify(tok):
    """Which provider does this token belong to, or None if it is not a key."""
    if not tok:
        return None
    if _K_ANTHROPIC.match(tok): return "anthropic"
    if _K_GOOGLE.match(tok):    return "gemini"
    if _K_GROQ.match(tok):      return "groq"
    if _K_SK_US.match(tok):     return "speechify" if len(tok) >= 44 else "elevenlabs"
    if _K_OPENAI.match(tok):    return "openai"
    if _K_HEX32.match(tok):     return "assemblyai"
    if _K_LOOSE.match(tok):
        has_d = any(c.isdigit() for c in tok)
        has_a = any(c.isalpha() for c in tok)
        if has_d and has_a:
            return "unknown"
    return None


def key_extract(text, want=None):
    """Every key in the text, in order, each with the label line above it.

    Returns a list of dicts: {key, provider, label}. De-duped by key, keeping
    the first appearance and its label."""
    lines = (text or "").split("\n")

    def line_has_key(line):
        for t in _K_SEP.split(line):
            if key_classify(t.strip().strip(".-_")):
                return True
        return False

    out, seen = [], set()
    for i, line in enumerate(lines):
        label = ""
        if i > 0:
            prev = lines[i - 1].strip()
            if prev and not line_has_key(prev):
                label = prev
        for rawtok in _K_SEP.split(line):
            t = rawtok.strip().strip(".-_")
            if not t or t == "DELETED" or t in seen:
                continue
            pid = key_classify(t)
            if not pid:
                continue
            if want and pid not in (want, "unknown"):
                continue
            seen.add(t)
            out.append({"key": t, "provider": pid, "label": label})
    return out


def groq_entries():
    """Groq candidates, strongest first. A gsk_ token is STRONG and a failure
    on it means a dead key. An unknown token is WEAK: it is still tried, since
    the next key format has not been invented yet, but a failure on it is
    skipped for the session rather than carved into the gravestone list."""
    try:
        raw = open(GROQ_KEYFILE, encoding="utf-8", errors="replace").read()
    except Exception:
        return []
    found = key_extract(raw, want="groq")
    strong = [f for f in found if f["provider"] == "groq"]
    weak = [f for f in found if f["provider"] != "groq"]
    for f in strong: f["strong"] = True
    for f in weak: f["strong"] = False
    return strong + weak


def groq_keys():
    return [e["key"] for e in groq_entries()]


def groq_dead():
    try:
        return set(json.load(open(GROQ_FAILED, encoding="utf-8")))
    except Exception:
        return set()


def groq_condemn(key, reason):
    d = groq_dead(); d.add(_groq_fp(key))
    try:
        tmp = GROQ_FAILED + ".part"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(sorted(d), f)
        os.replace(tmp, GROQ_FAILED)
    except Exception:
        pass


def groq_live():
    dead = groq_dead(); now = time.time()
    return [e for e in groq_entries()
            if _groq_fp(e["key"]) not in dead
            and e["key"] not in _groq_skip
            and _groq_rest.get(_groq_fp(e["key"]), 0) < now]


def groq_call(path, payload=None, timeout=45, tries=None):
    """One request, carried by the ring. 401/403 condemns the key and the same
    request is retried on the next. A 429 rests that key for five minutes and
    moves on: rate limiting is not death."""
    global _groq_i, _groq_err
    live = groq_live()
    if not live:
        return None, ("every Groq key is resting or dead" if groq_entries()
                      else "no Groq key")
    tries = tries if tries is not None else min(len(live), 4)
    last = "no Groq key"
    for _ in range(tries):
        live = groq_live()
        if not live:
            return None, last
        ent = live[_groq_i % len(live)]
        key = ent["key"]
        try:
            data = json.dumps(payload).encode("utf-8") if payload is not None else None
            req = urllib.request.Request(GROQ_API + path, data=data)
            req.add_header("Authorization", "Bearer " + key)
            req.add_header("User-Agent", GROQ_UA)     # never remove this
            if data is not None:
                req.add_header("Content-Type", "application/json")
            body = urllib.request.urlopen(req, timeout=timeout).read()
            _groq_err = ""
            return json.loads(body.decode("utf-8", "replace")), ""
        except urllib.error.HTTPError as e:
            if e.code in (401, 403):
                txt = ""
                try:
                    txt = e.read()[:120].decode("utf-8", "replace")
                except Exception:
                    pass
                if "1010" in txt or "cloudflare" in txt.lower():
                    # the User-Agent was refused, not the key. Condemning here
                    # would wipe the whole ring for a header mistake.
                    last = "Groq refused the request shape, not the key"
                elif ent.get("strong"):
                    groq_condemn(key, "HTTP %d" % e.code)
                    last = "a Groq key was rejected and marked dead"
                else:
                    # almost certainly a long word out of the file rather than
                    # a credential. Skip it for the session; do not gravestone
                    # something that was never a key.
                    _groq_skip.add(key)
                    last = "a token that was not a key was skipped"
            elif e.code == 429:
                _groq_rest[_groq_fp(key)] = time.time() + 300
                last = "Groq is rate limiting; resting that key"
            else:
                last = "Groq HTTP %d" % e.code
            _groq_i += 1
        except Exception as e:
            last = "Groq unreachable: %s" % str(e)[:60]
            _groq_i += 1
    _groq_err = last
    return None, last




# ===========================================================================
# WORD TIMING, LAYER 2: WHISPER WORD TIMESTAMPS
#
# Ported from MAHA_TRANSCRIBE_STREAMLIT ttt/wordtimes.py. The method, its
# measurements and the approaches that FAILED are written up in that repo's
# docs/WORD_TIMINGS.md and are worth reading before changing anything here.
# The counter-intuitive parts, so nobody rebuilds them:
#
#   * Speech has NO silence between words. Measured against exact engine
#     marks, 99.2 per cent of inter-word intervals are exactly zero. Hunting
#     for word boundaries in the amplitude envelope is hunting for something
#     that is not there; it finds stop consonants instead.
#   * Snapping anchors to low-energy frames afterwards measured 88 ms against
#     89 ms unrefined. No improvement, and wider windows made it worse. This
#     follows directly from the point above.
#   * What works is a recogniser used purely as a MEASURING INSTRUMENT. The
#     transcript is thrown away except as a key for alignment. Median error
#     48 ms against 119 ms for proportional timing.
#   * The hard part is not the timing, it is MAPPING what was heard onto what
#     is on screen. Whisper writes "12%" where the text says "12 percent" and
#     "1," where it says "One". That is a sequence alignment.
#
# THIS CODE NEVER RAISES. A highlight is a courtesy; the audio is the point.
# Every failure falls through to the layer below.
WT_MODEL = "whisper-large-v3-turbo"
WT_ENDPOINT = "/audio/transcriptions"
_WT_ONES = ["zero", "one", "two", "three", "four", "five", "six", "seven",
            "eight", "nine", "ten", "eleven", "twelve"]


def wt_fetch(mp3_path, language=None, model=WT_MODEL, timeout=90):
    """[{'word','start','end'}] from Groq, or None. Carried by the key ring.

    response_format MUST be verbose_json and the granularity parameter MUST
    be sent with its literal square brackets. With anything else the reply
    arrives looking perfectly fine and carrying no timings at all.
    """
    try:
        data = open(mp3_path, "rb").read()
    except Exception:
        return None
    if not data:
        return None

    def one_call(key):
        b = uuid.uuid4().hex
        fields = {"model": model, "response_format": "verbose_json",
                  "timestamp_granularities[]": "word"}
        if language:
            fields["language"] = language
        body = b""
        for k, v in fields.items():
            body += ("--%s\r\nContent-Disposition: form-data; name=\"%s\""
                     "\r\n\r\n%s\r\n" % (b, k, v)).encode("utf-8")
        body += ("--%s\r\nContent-Disposition: form-data; name=\"file\"; "
                 "filename=\"audio.mp3\"\r\nContent-Type: "
                 "application/octet-stream\r\n\r\n" % b).encode("utf-8")
        body += data + b"\r\n" + ("--%s--\r\n" % b).encode("utf-8")
        req = urllib.request.Request(GROQ_API + WT_ENDPOINT, data=body)
        req.add_header("Authorization", "Bearer " + key)
        req.add_header("User-Agent", GROQ_UA)       # never remove this
        req.add_header("Content-Type",
                       "multipart/form-data; boundary=%s" % b)
        raw = urllib.request.urlopen(req, timeout=timeout).read()
        return json.loads(raw.decode("utf-8", "replace"))

    out = None
    for ent in groq_live()[:3]:
        try:
            out = one_call(ent["key"])
            break
        except urllib.error.HTTPError as e:
            txt = ""
            try:
                txt = e.read()[:120].decode("utf-8", "replace")
            except Exception:
                pass
            if e.code in (401, 403) and not ("1010" in txt
                                             or "cloudflare" in txt.lower()):
                if ent.get("strong"):
                    groq_condemn(ent["key"], "HTTP %d" % e.code)
                else:
                    _groq_skip.add(ent["key"])
            elif e.code == 429:
                _groq_rest[_groq_fp(ent["key"])] = time.time() + 300
            continue
        except Exception:
            continue
    if not out:
        return None
    words = out.get("words")
    if not words:
        return None
    clean = []
    for w in words:
        try:
            if w.get("start") is None:
                continue
            clean.append({"word": str(w.get("word", "")),
                          "start": float(w["start"]),
                          "end": float(w.get("end", w["start"]))})
        except Exception:
            continue
    return clean or None


def wt_norm(tok):
    """See through the spelling differences that break the alignment.

    Whisper writes digits where the text has words and the reverse, so
    without this every numeral is a mismatch and drags the alignment out of
    step for the rest of the sentence."""
    t = re.sub(r"[^\w]", "", str(tok).lower(), flags=re.UNICODE)
    if t.isdigit() and len(t) <= 2 and int(t) < len(_WT_ONES):
        return _WT_ONES[int(t)]
    return t


def wt_align(heard, words):
    """Needleman-Wunsch. Per displayed word, the heard index or None."""
    n, m = len(words), len(heard)
    if not n or not m:
        return [None] * n
    a = [wt_norm(w) for w in words]
    b = [wt_norm(h.get("word", "")) for h in heard]
    GAP = -1.0
    sc = [[0.0] * (m + 1) for _ in range(n + 1)]
    bk = [[0] * (m + 1) for _ in range(n + 1)]
    for i in range(1, n + 1):
        sc[i][0] = i * GAP; bk[i][0] = 1
    for j in range(1, m + 1):
        sc[0][j] = j * GAP; bk[0][j] = 2
    for i in range(1, n + 1):
        ai = a[i - 1]
        for j in range(1, m + 1):
            bj = b[j - 1]
            if ai and ai == bj:
                s = 2.0
            elif ai and bj and (ai.startswith(bj) or bj.startswith(ai)):
                s = 1.0                      # 'people' inside '3,500 people'
            else:
                s = -1.0
            diag = sc[i - 1][j - 1] + s
            up = sc[i - 1][j] + GAP
            left = sc[i][j - 1] + GAP
            best = diag if diag >= up and diag >= left else (
                up if up >= left else left)
            sc[i][j] = best
            bk[i][j] = 0 if best == diag else (1 if best == up else 2)
    out = [None] * n
    i, j = n, m
    while i > 0 and j > 0:
        d = bk[i][j]
        if d == 0:
            out[i - 1] = j - 1; i -= 1; j -= 1
        elif d == 1:
            i -= 1
        else:
            j -= 1
    return out


def wt_times(heard, words, total=None):
    """One (start, end) per displayed word, or None."""
    if not heard or not words:
        return None
    idx = wt_align(heard, words)
    if all(j is None for j in idx):
        return None
    starts = [None] * len(words)
    for i, j in enumerate(idx):
        if j is not None:
            try:
                starts[i] = float(heard[j].get("start"))
            except Exception:
                starts[i] = None
    if all(s is None for s in starts):
        return None
    if starts[0] is None:
        starts[0] = 0.0
    if starts[-1] is None:
        starts[-1] = max(s for s in starts if s is not None)
    # Interpolate anything unmatched. A word with no time would freeze the
    # highlight, which reads as worse than being slightly early.
    i = 0
    while i < len(words):
        if starts[i] is not None:
            i += 1; continue
        j = i
        while j < len(words) and starts[j] is None:
            j += 1
        left = starts[i - 1] if i > 0 else 0.0
        right = starts[j] if j < len(words) else (total or left)
        for k in range(i, j):
            starts[k] = left + (right - left) * (k - i + 1) / (j - i + 1)
        i = j
    # Monotonic, always. A highlight that jumps backwards is a bug the reader
    # sees instantly.
    for i in range(1, len(starts)):
        if starts[i] < starts[i - 1]:
            starts[i] = starts[i - 1]
    try:
        last_end = float(heard[-1].get("end") or starts[-1])
    except Exception:
        last_end = starts[-1]
    ends = starts[1:] + [max(starts[-1], total or last_end)]
    return list(zip(starts, ends))


def wt_sane(heard, words, times, total):
    """Is this answer worth believing?

    The reference method assumes the call either works or fails. It can do a
    third thing: come back looking perfectly well formed and be WRONG. Whisper
    can mishear a whole clip, or hand back times that run backwards, and the
    interpolation then dutifully produces a smooth ramp of nonsense or a row
    of identical numbers. A highlight frozen on the first word for a whole
    sentence is worse than the engine marks it replaced.

    So the answer has to earn its place on three counts. Every one of them was
    written after watching this exact failure in a test.
    """
    n = len(words)
    if n == 0 or not times:
        return False

    # 1. ENOUGH OF IT WAS ACTUALLY RECOGNISED. If barely any displayed word
    #    found a partner, the times are almost all interpolated guesses
    #    dressed up as measurements.
    idx = wt_align(heard, words)
    matched = sum(1 for j in idx if j is not None)
    need = 2 if n <= 3 else max(2, int(n * 0.5))
    if matched < need:
        return False

    # 2. IT MUST MOVE. Times that all collapse onto one another freeze the
    #    highlight; that is the shape of a backwards answer after it has been
    #    forced monotonic.
    starts = [a for a, _ in times]
    spread = starts[-1] - starts[0]
    if total and total > 0.4 and spread < total * 0.25:
        return False

    # 3. IT MUST FIT THE CLIP. A start beyond the end of the audio means the
    #    recogniser was describing something else.
    if total and total > 0 and starts[-1] > total * 1.5:
        return False
    return True


def wt_apply(mp3_path, json_path, language=None):
    """Re-time an already-spoken clip from Whisper, and remember the result.

    Paid for ONCE per sentence per voice: the answer is written into the same
    json the highlight already reads, so a re-read costs nothing. Returns
    True if the clip was re-timed."""
    try:
        d = json.load(open(json_path, encoding="utf-8"))
    except Exception:
        return False
    # LAYER 2 MUST NOT OVERWRITE LAYER 1 WHEN LAYER 1 IS EXACT.
    # Speechify returns the true word marks free with its audio: they are not
    # a measurement, they are what the engine did. Whisper is a measurement,
    # and a good one at about 80ms, but 80ms is worse than nothing at all.
    # Re-timing a Speechify clip therefore made the highlight WORSE and spent
    # a call to do it. Only clips whose times were inferred are re-timed.
    if d.get("engine") in ("whisper", "speechify"):
        return False
    if d.get("wt_tried"):
        return False
    toks = d.get("tokens") or []
    words = [t.get("w", "") for t in toks]
    if not words:
        return False
    heard = wt_fetch(mp3_path, language=language)
    d["wt_tried"] = True                    # never pay for the same clip twice
    if heard:
        t = wt_times(heard, words, d.get("total"))
        if t and len(t) == len(toks) and wt_sane(heard, words, t, d.get("total")):
            for tok, (a, b) in zip(toks, t):
                tok["t"] = round(float(a), 3)
                tok["d"] = round(max(0.01, float(b) - float(a)), 3)
            d["tokens"] = toks
            d["engine"] = "whisper"
    try:
        tmp = json_path + ".part"
        json.dump(d, open(tmp, "w", encoding="utf-8"), ensure_ascii=False)
        os.replace(tmp, json_path)
    except Exception:
        return False
    return d.get("engine") == "whisper"

# ---------------------------------------------------------------------------
# THE KEY ROUTER
#
# ONE file picker for the whole app. A key file is a working note, not a
# machine file, so keys are found inside whatever text surrounds them, each is
# CLASSIFIED BY ITS OWN SHAPE, and each is filed into the provider that can
# use it. Nobody is asked "which provider is this?" because the key already
# says so.
#
# Ported from TTT_MINI ttt/keyring.py and Key_Tester KeyParser.kt. Two rules
# from those repos kept verbatim, each learned the hard way:
#   * never drop a key for its shape, shape only ranks
#   * the line directly above a key is its label, usually an account note
#
# This app uses exactly two providers. A key for anything else is recognised,
# reported, and not stored, so a person can see that it was understood and
# simply not needed here.
ROUTE_TARGETS = {"speechify": SPEECHIFY_KEY_FILE, "groq": GROQ_KEYFILE}


def route_import(raw):
    """File every key in this text into the provider that can use it.

    Returns a report: how many of each provider were added, which were
    recognised but not needed, and how many were already known."""
    found = key_extract(raw or "")
    report = {"added": {}, "known": {}, "other": {}, "total": len(found)}
    for provider, path in ROUTE_TARGETS.items():
        mine = [f for f in found if f["provider"] == provider]
        # An unknown token could be a rebranded key for either provider, so it
        # is offered to both rather than thrown away. A wrong guess costs one
        # refused request; a discarded key costs the key.
        mine += [f for f in found if f["provider"] == "unknown"]
        if not mine:
            continue
        try:
            have = open(path, encoding="utf-8", errors="replace").read()
        except Exception:
            have = ""
        existing = {e["key"] for e in key_extract(have)}
        new = [f for f in mine if f["key"] not in existing]
        report["known"][provider] = len(mine) - len(new)
        if not new:
            continue
        lines = []
        for f in new:
            if f.get("label"):
                lines.append(f["label"])
            lines.append(f["key"])
        try:
            os.makedirs(WEB_DIR, exist_ok=True)
            body = (have.rstrip("\n") + "\n" if have.strip() else "")
            tmp = path + ".part"
            with open(tmp, "w", encoding="utf-8") as fh:
                fh.write(body + "\n".join(lines) + "\n")
            os.replace(tmp, path)
            os.chmod(path, 0o600)
        except Exception:
            continue
        report["added"][provider] = len(new)
    for f in found:
        p = f["provider"]
        if p not in ROUTE_TARGETS and p != "unknown":
            report["other"][p] = report["other"].get(p, 0) + 1
    return report


def route_list():
    """Every key the app holds, masked, with its label and state.

    Order is the order they will be TRIED, so the list doubles as the
    fallback order: the first live one does the work, and if it is refused
    the next takes over."""
    out = []
    dead_sp = set()
    try:
        dead_sp = {d.get("fp") if isinstance(d, dict) else d
                   for d in json.load(open(SP_FAIL_FILE, encoding="utf-8"))}
    except Exception:
        pass
    dead_gq = groq_dead()
    for provider, path in (("speechify", SPEECHIFY_KEY_FILE), ("groq", GROQ_KEYFILE)):
        try:
            raw = open(path, encoding="utf-8", errors="replace").read()
        except Exception:
            continue
        for i, e in enumerate(key_extract(raw)):
            k = e["key"]
            fp16 = hashlib.sha256(k.encode("utf-8")).hexdigest()[:16]
            fp12 = fp16[:12]
            dead = (fp16 in dead_gq) if provider == "groq" else \
                   (fp12 in dead_sp or fp16 in dead_sp)
            strong = e["provider"] == provider
            out.append({
                "provider": provider, "order": i + 1,
                "mask": (k[:5] + "\u2026" + k[-4:]) if len(k) > 10 else "\u2026",
                "label": e.get("label", ""),
                "state": ("dead" if dead else ("live" if strong else "?")),
                "strong": strong,
            })
    return out

def groq_model_saved():
    try:
        return json.load(open(GROQ_STATE, encoding="utf-8")).get("model") or ""
    except Exception:
        return ""


def groq_model_save(m):
    try:
        tmp = GROQ_STATE + ".part"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump({"model": m, "at": int(time.time())}, f)
        os.replace(tmp, GROQ_STATE)
    except Exception:
        pass


def groq_candidates():
    """What is actually on offer today, best first.

    Asked of Groq rather than assumed, so that a model being retired is a
    normal Tuesday rather than a broken app. The preferred ones come first if
    they still exist; anything else that can hold a conversation follows, so
    the app keeps working even if every name below is gone."""
    d, err = groq_call("/models", timeout=30)
    have = []
    if d:
        have = [m.get("id") for m in d.get("data", []) if m.get("id")]
    if not have:
        return list(GROQ_PREFERRED), err
    good = [m for m in have if not any(b in m.lower() for b in GROQ_NOT_CHAT)]
    ordered = [m for m in GROQ_PREFERRED if m in good]
    ordered += [m for m in sorted(good) if m not in ordered]
    return ordered, ""


def _groq_answer(text):
    """Pull YES or NO out of whatever shape the model replied in.

    Some models write their reasoning inside the content between <think> tags;
    others put it in a separate field and leave content empty. Only the answer
    is wanted, and only if it is unambiguous."""
    if not text:
        return ""
    t = re.sub(r"<think>.*?</think>", " ", text, flags=re.S | re.I)
    t = re.sub(r"<[^>]+>", " ", t)
    up = t.upper()
    yes = re.search(r"\bYES\b", up)
    no = re.search(r"\bNO\b", up)
    if yes and not no:
        return "YES"
    if no and not yes:
        return "NO"
    if yes and no:                      # both words appear: take the first
        return "YES" if yes.start() < no.start() else "NO"
    return ""


def groq_is_english(text):
    """Ask Groq whether this is English. Returns (True/False/None, model, err).

    None means nobody could be asked, which is different from 'not English'
    and must never be turned into Croatian by accident."""
    body = text or ""
    spans = split_sentences(body)[:5]
    sample = " ".join(body[a:b].strip() for a, b in spans).strip()[:1200]
    if not sample:
        return None, "", "nothing to look at"
    # A model asked "is 12345 English?" answers NO, quite correctly, and NO
    # here means Croatian. Digits and punctuation are neither language, so
    # they are never worth a question.
    if len(re.findall(r"[^\W\d_]", sample, flags=re.UNICODE)) < 8:
        return None, "", "not enough words to judge"
    order = []
    saved = groq_model_saved()
    if saved:
        order.append(saved)
    cands, err = groq_candidates()
    order += [m for m in cands if m not in order]
    if not order:
        return None, "", err or "no Groq model available"
    last = err or "no Groq model answered"
    for model in order[:5]:
        payload = {
            "model": model, "temperature": 0, "max_tokens": 512,
            "messages": [
                {"role": "system",
                 "content": "You identify languages. Answer with exactly one "
                            "word: YES or NO. No explanation."},
                {"role": "user",
                 "content": "Is the following text written in English?\n\n" + sample},
            ],
        }
        d, e = groq_call("/chat/completions", payload=payload, timeout=40)
        if not d:
            last = e or last
            continue
        try:
            msg = d["choices"][0]["message"]
        except Exception:
            last = "Groq replied in an unexpected shape"
            continue
        ans = _groq_answer(msg.get("content") or "")
        if not ans:
            # a model that will not answer plainly is the wrong model for this
            last = "%s did not answer yes or no" % model
            continue
        if model != saved:
            groq_model_save(model)
        return (ans == "YES"), model, ""
    return None, "", last

# ---------------------------------------------------------------------------
# CROATIAN
#
# Speechify has NO Croatian voice. The full catalogue was walked, 985 voices,
# every page: there is no hr-HR on any model. The only Slavic locales that
# exist at all are ru-RU (50), pl-PL (2) and uk-UA (2). So Croatian is always
# read by a foreign voice, and the question is only which foreign voice
# mangles it least.
#
# Marko compared five renderings of the same Croatian sentence and chose a
# Ukrainian voice first: Slavic phonetics handle c-caron, c-acute, z-caron,
# s-caron, d-stroke and the -lj- -nj- clusters that English simply cannot.
# Do not substitute other voices for these two without asking him.
#
# MODEL COVERAGE, measured rather than taken from the documentation:
#     simba-english        5 locales   en-AU en-GB en-IN en-NG en-US
#     simba-3.2            2 locales   en-GB en-US
#     simba-multilingual  36 locales
#     simba-3.0           36 locales
# lesya exists ONLY on simba-multilingual and simba-3.0, so calling it with
# simba-english fails. Beatrice supports all four, but for Croatian she must
# be asked for on simba-multilingual, which is the whole point of offering
# her as the second option.
SP_MODEL_MULTI = "simba-multilingual"
# Ported from TTT_MINI MaSpeechify.kt, ordered as Baba ranked them by ear, so
# the first entry is the shipped default and the settings screen can simply
# show the list.
#
# THE MODEL FOLLOWS THE VOICE, never a global default. lesya exists only on
# simba-multilingual and simba-3.0; simba-3.2 answers HTTP 400 for any voice
# outside the eight curated _32 ids. Both measured, not read.
#
# Beatrice appears in BOTH lists, on a different model in each. She is the
# same voice; asked for on simba-multilingual she will attempt Croatian, and
# on simba-english she is the English reader.
CRO_VOICES = [
    {"id": "lesya",       "name": "Lesya",    "sub": "Ukrainian female \u2014 Slavic sounds",
     "model": SP_MODEL_MULTI},
    {"id": "beatrice_32", "name": "Beatrice", "sub": "British female \u2014 warm",
     "model": SP_MODEL_MULTI},
    {"id": "dominika",    "name": "Dominika", "sub": "Polish female",
     "model": SP_MODEL_MULTI},
    {"id": "daria",       "name": "Daria",    "sub": "Russian female",
     "model": SP_MODEL_MULTI},
]
# THE IDS CARRY THE _32 SUFFIX. TTT_MINI's table lists imogen, edmund and hugh
# bare, and three of those four answer HTTP 404 on this account: the curated
# British voices are published as imogen_32, edmund_32 and hugh_32. Checked
# against the live catalogue rather than copied, and every one of the eight
# seats below was spoken for real before this shipped.
ENG_VOICES = [
    {"id": "beatrice_32", "name": "Beatrice", "sub": "British female \u2014 warm",
     "model": SP_MODEL},
    {"id": "imogen_32",   "name": "Imogen",   "sub": "British female",
     "model": SP_MODEL},
    {"id": "edmund_32",   "name": "Edmund",   "sub": "British male",
     "model": SP_MODEL},
    {"id": "hugh_32",     "name": "Hugh",     "sub": "British male",
     "model": SP_MODEL},
]
CRO_DEFAULT = "lesya"
ENG_DEFAULT = "beatrice_32"
CRO_SAMPLE = ("Dobar dan. Rije\u010d je o \u010di\u0161\u0107enju, "
              "\u0111aci u\u010de \u017euto sunce, a \u0161uma \u0161umi "
              "tiho pokraj Kukljice.")

_CRO_MARKS = set("\u010d\u0107\u017e\u0161\u0111\u010c\u0106\u017d\u0160\u0110")
_CRO_WORDS = {
    "je", "su", "da", "se", "ne", "sam", "smo", "ste", "bi", "biti", "nije",
    "ima", "nema", "kao", "ali", "ili", "jer", "pa", "te", "sve", "vi\u0161e",
    "ovo", "ono", "taj", "ta", "to", "koji", "koja", "koje", "kada", "gdje",
    "\u0161to", "kako", "jo\u0161", "samo", "vec", "ve\u0107", "bez", "pod",
    "nad", "pri", "kroz", "prema", "izme\u0111u", "hvala", "dobar", "dobro",
}
_ENG_WORDS = {
    "the", "and", "of", "to", "in", "is", "it", "that", "for", "on", "with",
    "as", "was", "at", "by", "an", "be", "this", "have", "from", "or", "one",
    "had", "but", "what", "all", "were", "when", "we", "there", "can", "said",
}

def looks_croatian(text):
    """Is this sentence Croatian?

    Two signals, and either is enough on its own, because a short sentence may
    carry only one of them. Diacritics are decisive: no English text contains
    c-caron or d-stroke. Otherwise a count of Croatian function words against
    English ones, which settles sentences like 'To je bilo dobro' that happen
    to have no accents in them at all.
    """
    if not text:
        return False
    for ch in text:
        if ch in _CRO_MARKS:
            return True
    words = re.findall(r"[a-z\u0161\u0111\u010d\u0107\u017e]+", text.lower())
    if not words:
        return False
    hr = sum(1 for w in words if w in _CRO_WORDS)
    en = sum(1 for w in words if w in _ENG_WORDS)
    if en > hr:
        return False
    return hr >= 2 or (hr >= 1 and len(words) <= 4)


def cro_voice_id():
    v = load_state().get("croVoice") or CRO_DEFAULT
    return v if any(c["id"] == v for c in CRO_VOICES) else CRO_DEFAULT


def eng_voice_id():
    v = load_state().get("engVoice") or ENG_DEFAULT
    return v if any(c["id"] == v for c in ENG_VOICES) else ENG_DEFAULT


def sp_seat(vid, table, default):
    """The chosen row from one of the two voice lists.

    Named sp_seat rather than sp_pick because sp_pick already exists further
    down for the catalogue ordering, and the later definition silently wins in
    Python. Two functions with one name is a bug that compiles."""
    for v in table:
        if v["id"] == vid:
            return v
    for v in table:
        if v["id"] == default:
            return v
    return table[0]


def reading_lang():
    """Which language the app is reading, resolved to eng or hr.

    THE SWITCH IS THE AUTHORITY. Only AUTO is automatic; that is the whole
    point of having three settings rather than two. ENG means English even
    when the page is Croatian, because a person who has pressed ENG has said
    what they want and being overruled by a guess is not help.
    """
    st = load_state()
    mode = st.get("lang", "eng")
    if mode == "hr":
        return "hr"
    if mode == "eng":
        return "eng"
    return "hr" if st.get("langAuto") == "hr" else "eng"


def sp_voice_for(text, voice_id):
    """Which voice and which model this sentence should be spoken with.

    The pairing matters as much as the choice: a voice asked for on a model
    that does not carry it returns an error, not a fallback.

    This used to ask looks_croatian about every sentence no matter what the
    switch said, so ENG quietly handed Croatian sentences to the Croatian
    voice. The switch decides; the text does not get a vote unless the switch
    has handed it one by being set to AUTO."""
    if reading_lang() == "hr":
        v = sp_seat(cro_voice_id(), CRO_VOICES, CRO_DEFAULT)
    else:
        v = sp_seat(eng_voice_id(), ENG_VOICES, ENG_DEFAULT)
    return v["id"], v["model"]
SP_PAGE = 200                 # the API caps a page here; default is only 50
SP_MAX_PAGES = 12
SP_LIMITED_REST = 300         # seconds a 429'd key is stood down before retry

SP_VOICES = {}
_sp_lock = threading.Lock()
_sp_key = None                # the key in use right now
_sp_err = ""
_sp_limited = {}              # key -> unix time it may be tried again
_sp_skip = set()             # candidates that turned out not to be keys
_sp_last = None              # the key that carried the last successful call


def sp_vkey(voice_id):
    """Stable on-disk folder name for one Speechify voice. Clips cache under
    the voice, so this depends on the voice id and nothing else."""
    return "sp_" + re.sub(r"[^A-Za-z0-9]", "", str(voice_id))[:40]


def sp_mask(key):
    """Never show a key. If one must be named at all, name it like this."""
    if not key:
        return ""
    return key[:6] + "\u2026" + key[-4:]


def sp_fingerprint(key):
    """Identify a key without storing it. The dead list is keyed by this, so
    that file can be read by anyone and gives up nothing."""
    return hashlib.sha256(key.encode("utf-8")).hexdigest()[:16]


def sp_load_keys():
    """Every candidate in the file, strong ones first, each with the label
    written above it. File order is try order within each tier. A line that is
    not a candidate becomes the label for the next one, which is how a shared
    file says whose key is whose."""
    try:
        raw = open(SPEECHIFY_KEY_FILE, encoding="utf-8").read()
    except Exception:
        return []
    strong, weak, seen, label = [], [], set(), ""
    for line in raw.splitlines():
        s = line.strip()
        if not s or s == "[DELETED]":
            continue
        if SP_MAYBE_RE.match(s):
            if s in seen:
                continue
            seen.add(s)
            rec = {"key": s, "label": label or "unnamed",
                   "strong": bool(SP_KEY_RE.match(s))}
            (strong if rec["strong"] else weak).append(rec)
            label = ""
        else:
            label = s[:40]
    return strong + weak


def sp_fail_load():
    try:
        d = json.load(open(SP_FAIL_FILE, encoding="utf-8"))
        return d if isinstance(d, dict) else {}
    except Exception:
        return {}


def sp_use_load():
    try:
        d = json.load(open(SP_USE_FILE, encoding="utf-8"))
        return d if isinstance(d, dict) else {}
    except Exception:
        return {}


def sp_note_usage(key, chars):
    """Speechify says what each request cost in billable_characters_count, so
    keep a running total per key. Shared files get spent unevenly and there is
    no other way to see which account is carrying everyone."""
    if not key:
        return
    try:
        chars = int(chars or 0)
    except (TypeError, ValueError):
        return
    d = sp_use_load()
    fp = sp_fingerprint(key)
    rec = d.get(fp) or {"chars": 0, "calls": 0}
    rec["chars"] = int(rec.get("chars", 0)) + max(0, chars)
    rec["calls"] = int(rec.get("calls", 0)) + 1
    rec["at"] = int(time.time())
    d[fp] = rec
    try:
        os.makedirs(WEB_DIR, exist_ok=True)
        json.dump(d, open(SP_USE_FILE, "w", encoding="utf-8"), ensure_ascii=False)
    except Exception:
        pass


def sp_fail_save(d):
    try:
        os.makedirs(WEB_DIR, exist_ok=True)
        json.dump(d, open(SP_FAIL_FILE, "w", encoding="utf-8"), ensure_ascii=False)
    except Exception:
        pass


def sp_condemn(key, label, reason):
    """Mark a key dead, for good, so it is never spent on again."""
    global _sp_key
    d = sp_fail_load()
    d[sp_fingerprint(key)] = {"mask": sp_mask(key), "label": label or "",
                              "reason": reason, "at": int(time.time())}
    sp_fail_save(d)
    with _sp_lock:
        if _sp_key == key:
            _sp_key = None


def sp_revive(fp):
    d = sp_fail_load()
    if fp in d:
        del d[fp]
        sp_fail_save(d)
        return True
    return False


def sp_drop(fp):
    """Strike a key out of the file itself. The line is replaced rather than
    deleted so the label above it still lines up with nothing."""
    entries = sp_load_keys()
    target = next((e for e in entries if sp_fingerprint(e["key"]) == fp), None)
    if target is None:
        sp_revive(fp)
        return False
    try:
        lines = open(SPEECHIFY_KEY_FILE, encoding="utf-8").read().splitlines()
        out = ["[DELETED]" if ln.strip() == target["key"] else ln for ln in lines]
        with open(SPEECHIFY_KEY_FILE, "w", encoding="utf-8") as f:
            f.write("\n".join(out) + "\n")
        try:
            os.chmod(SPEECHIFY_KEY_FILE, 0o600)
        except Exception:
            pass
    except Exception:
        return False
    sp_revive(fp)
    return True


def sp_live_keys():
    """The candidates still worth trying: not condemned, not resting off a
    429, and not already shown to be something other than a key."""
    dead = sp_fail_load()
    now = time.time()
    out = []
    for e in sp_load_keys():
        if sp_fingerprint(e["key"]) in dead:
            continue
        if e["key"] in _sp_skip:
            continue
        if _sp_limited.get(e["key"], 0) > now:
            continue
        out.append(e)
    return out


def sp_current(advance=False):
    """The key to speak through. No network, no speculative testing: the first
    key not known to be dead simply gets used. `advance` steps past the one in
    hand after it has just failed."""
    global _sp_key, _sp_err
    with _sp_lock:
        live = sp_live_keys()
        if not live:
            total = len(sp_load_keys())
            dead = len(sp_fail_load())
            if not total:
                _sp_err = "no Speechify keys loaded"
            elif dead >= total:
                _sp_err = "all %d keys are marked dead" % total
            else:
                _sp_err = "every key is rate limited just now"
            _sp_key = None
            return None, ""
        if advance or not _sp_key:
            if advance and _sp_key:
                nxt = None
                for i, e in enumerate(live):
                    if e["key"] == _sp_key and i + 1 < len(live):
                        nxt = live[i + 1]
                        break
                _sp_key = (nxt or live[0])["key"]
            else:
                _sp_key = live[0]["key"]
        elif not any(e["key"] == _sp_key for e in live):
            _sp_key = live[0]["key"]
        lbl = next((e["label"] for e in live if e["key"] == _sp_key), "")
        _sp_err = ""
        return _sp_key, lbl


def sp_note_limited(key):
    _sp_limited[key] = time.time() + SP_LIMITED_REST


def sp_call(path, method="GET", payload=None, timeout=60, tries=None):
    """One request, carried by the ring. A 401/403 condemns the key in hand and
    the very same request is retried on the next one, so a revoked key costs a
    single wasted call and is never tried again in this life."""
    global _sp_err
    global _sp_last
    live = sp_live_keys()
    strong = {e["key"]: e.get("strong", True) for e in live}
    tries = tries if tries is not None else max(1, len(live))
    last = "no Speechify key"
    for attempt in range(tries):
        key, label = sp_current(advance=(attempt > 0))
        if not key:
            return None, _sp_err or last
        try:
            data = json.dumps(payload).encode("utf-8") if payload is not None else None
            req = urllib.request.Request(SP_API + path, data=data)
            req.add_header("Authorization", "Bearer " + key)
            if data is not None:
                req.add_header("Content-Type", "application/json")
            if method != "GET" and data is None:
                req.method = method
            body = urllib.request.urlopen(req, timeout=timeout).read()
            _sp_err = ""
            _sp_last = key
            return json.loads(body.decode("utf-8", "replace")), ""
        except urllib.error.HTTPError as e:
            if e.code in (401, 403):
                if strong.get(key, True):
                    sp_condemn(key, label, "rejected (HTTP %d)" % e.code)
                    last = "a key was rejected and marked dead"
                else:
                    # almost certainly a long word from the file rather than a
                    # credential. Skip it for the session, do not gravestone it.
                    _sp_skip.add(key)
                    last = "skipped something that was not a key"
                continue                      # same request, next key
            if e.code == 429:
                sp_note_limited(key)
                last = "rate limited"
                continue
            last = "Speechify HTTP %d" % e.code
            break
        except Exception as e:
            last = "Speechify unreachable: %s" % str(e)[:80]
            break
    _sp_err = last
    return None, last


def sp_probe(entry):
    """Deliberately test ONE key. Only the Settings button does this."""
    key = entry["key"]
    try:
        req = urllib.request.Request(SP_API + "/v1/voices?limit=1")
        req.add_header("Authorization", "Bearer " + key)
        code = urllib.request.urlopen(req, timeout=15).getcode()
        return "WORKING" if 200 <= code < 300 else "OTHER"
    except urllib.error.HTTPError as e:
        if e.code in (401, 403):
            sp_condemn(key, entry.get("label", ""), "rejected (HTTP %d)" % e.code)
            return "REJECTED"
        if e.code == 429:
            sp_note_limited(key)
            return "LIMITED"
        return "OTHER"
    except Exception:
        return "OFFLINE"


def sp_test_all():
    """The whole ring, on demand. Condemns whatever is dead along the way."""
    counts = {"WORKING": 0, "REJECTED": 0, "LIMITED": 0, "OTHER": 0, "OFFLINE": 0}
    dead = sp_fail_load()
    for e in sp_load_keys():
        if sp_fingerprint(e["key"]) in dead:
            counts["REJECTED"] += 1
            continue
        counts[sp_probe(e)] += 1
    with _sp_lock:
        globals()["_sp_key"] = None
    return counts


# ---------- Speechify voice catalogue ----------
def _sp_sex(v):
    g = str(v.get("gender") or v.get("sex") or "").lower()
    return "F" if g.startswith("f") else ("M" if g.startswith("m") else "")


def _sp_locales(v):
    out = set()
    for k in ("locale", "language", "lang"):
        if v.get(k):
            out.add(str(v[k]).replace("_", "-"))
    for m in (v.get("models") or []):
        if not isinstance(m, dict):
            continue
        for lg in (m.get("languages") or []):
            if isinstance(lg, dict):
                for k in ("locale", "language", "lang"):
                    if lg.get(k):
                        out.add(str(lg[k]).replace("_", "-"))
            elif lg:
                out.add(str(lg).replace("_", "-"))
    return out


def _sp_name(v):
    return str(v.get("display_name") or v.get("name") or v.get("id") or "Voice").strip()


def _sp_tone(v):
    """The one-word character Speechify prints beside a name lives in the tags
    as timbre:warm and the like."""
    for t in (v.get("tags") or []):
        s = str(t)
        if s.startswith("timbre:"):
            return s.split(":", 1)[1].replace("-", " ").capitalize()
    return ""


def sp_fetch_all_voices():
    """Every voice, not the first page of them.

    /v1/voices is paginated and defaults to fifty, which is why an earlier
    version of this saw only names beginning with A and could find exactly one
    British voice in a catalogue that actually holds thirty three. Walk the
    cursor to the end."""
    out, cursor = [], None
    for _ in range(SP_MAX_PAGES):
        q = "?limit=%d" % SP_PAGE + (("&cursor=" + urllib.parse.quote(cursor)) if cursor else "")
        d, err = sp_call("/v1/voices" + q, timeout=30)
        if d is None:
            return (out, "") if out else (None, err)
        items = d.get("voices") if isinstance(d, dict) else d
        if not isinstance(items, list):
            break
        out.extend(items)
        cursor = d.get("next_cursor") if isinstance(d, dict) else None
        if not (isinstance(d, dict) and d.get("has_more")) or not cursor:
            break
    return out, ""


def _sp_rank(v):
    """Lower sorts earlier. Curated first, then the ones the docs call
    popular, then alphabetical."""
    n = v["name"].lower()
    if n in SP_CURATED:
        return (0, SP_CURATED.index(n), n)
    if n in SP_POPULAR:
        return (1, SP_POPULAR.index(n), n)
    return (2, 0, n)


def sp_pick(raw_voices, accent):
    """EVERY voice for one accent, ordered, and zipped female, male, female,
    male so that any four consecutive entries are two of each. The front end
    slices this four at a time, so page one is the curated pairs and the rest
    of the catalogue follows behind it in a predictable order."""
    loc = next((a["locale"] for a in SP_ACCENTS if a["key"] == accent), "en-GB")
    pool, seen = {"F": [], "M": []}, set()
    for v in raw_voices:
        if not isinstance(v, dict):
            continue
        sex = _sp_sex(v)
        if sex not in pool:
            continue
        if not any(l == loc or l.startswith(loc) for l in _sp_locales(v)):
            continue
        vid = v.get("id") or v.get("voice_id")
        nm = _sp_name(v)
        if not vid or nm.lower() in seen:
            continue                      # the catalogue repeats a few names
        seen.add(nm.lower())
        pool[sex].append({"id": str(vid), "name": nm, "sex": sex,
                          "tone": _sp_tone(v), "accent": accent})
    for sex in ("F", "M"):
        pool[sex].sort(key=_sp_rank)
    out = []
    # zip the two lists in pairs. When one sex runs out the other simply
    # continues, so no voice is ever dropped for want of a partner.
    i = j = 0
    while i < len(pool["F"]) or j < len(pool["M"]):
        for _ in range(SP_PER_SEX):
            if i < len(pool["F"]):
                out.append(pool["F"][i]); i += 1
        for _ in range(SP_PER_SEX):
            if j < len(pool["M"]):
                out.append(pool["M"][j]); j += 1
    return out


def sp_register(voices):
    out = []
    for i, v in enumerate(voices):
        rec = dict(v)
        rec["vkey"] = sp_vkey(v["id"])
        rec["fid"] = 1000 + i
        acc = next((a for a in SP_ACCENTS if a["key"] == v["accent"]), None)
        rec["label"] = (acc["label"] if acc else "English") + \
                       (" female" if v["sex"] == "F" else " male")
        SP_VOICES[rec["vkey"]] = rec
        out.append(rec)
    return out


def sp_cache_read():
    """The cached catalogue, or nothing if it was written by an older shape."""
    try:
        d = json.load(open(SP_CACHE_FILE, encoding="utf-8"))
    except Exception:
        return {}
    if not isinstance(d, dict) or d.get("v") != SP_CACHE_V:
        return {}
    return d


def sp_catalogue(accent, refresh=False):
    """The four voices for an accent, from a small on-disk cache so the picker
    still draws with no network, refreshed on demand."""
    global _sp_err
    if accent not in SP_ACCENT_KEYS:
        accent = SP_ACCENT_KEYS[0]
    cached = sp_cache_read()
    have = cached.get("byAccent", {}).get(accent) if isinstance(cached, dict) else None
    # A belt as well as braces: anything at or under one page is not a
    # catalogue, it is the remains of an older picker. Go and fetch properly.
    if have and len(have) <= SP_PER_SET:
        have = None
    if have and not refresh:
        return sp_register(have), ""
    voices, err = sp_fetch_all_voices()
    if not voices:
        if have:
            return sp_register(have), err or _sp_err
        return [], err or _sp_err or "no working Speechify key"
    store = cached.get("byAccent", {}) if isinstance(cached, dict) else {}
    for acc in SP_ACCENT_KEYS:                 # both accents from one fetch
        picked = sp_pick(voices, acc)
        if picked:
            store[acc] = picked
    try:
        json.dump({"v": SP_CACHE_V, "byAccent": store, "at": int(time.time())},
                  open(SP_CACHE_FILE, "w", encoding="utf-8"), ensure_ascii=False)
    except Exception:
        pass
    if not store.get(accent):
        _sp_err = "no %s voices in this catalogue" % accent.upper()
        return [], _sp_err
    _sp_err = ""
    return sp_register(store[accent]), ""


# ---------- Speechify speech marks -> the token shape the highlight speaks --
def sp_tokens(text, marks):
    """Speechify hands back character offsets into the very text it was given
    and millisecond times measured from the audio it just made. Verified
    character-for-character against the source, so nothing is inferred here:
    the marks are flattened, converted to seconds, clamped, and tidied so each
    word holds until the next begins."""
    flat = []

    def walk(node):
        if not isinstance(node, dict):
            return
        kids = node.get("chunks") or node.get("nestedChunks") or []
        if kids:
            for c in kids:
                walk(c)
            return
        if "start_time" in node or "startTime" in node:
            flat.append(node)

    if isinstance(marks, list):
        for m in marks:
            walk(m)
    else:
        walk(marks)
    if not flat:
        return []
    n = len(text)
    out = []
    for m in flat:
        try:
            s = int(m.get("start", m.get("startOffset", 0)))
            e = int(m.get("end", m.get("endOffset", s)))
            t = float(m.get("start_time", m.get("startTime", 0))) / 1000.0
            d = float(m.get("end_time", m.get("endTime", 0))) / 1000.0
        except (TypeError, ValueError):
            continue
        s = max(0, min(n, s))
        e = max(s, min(n, e))
        if e <= s:
            continue
        out.append({"s": s, "e": e, "t": round(t, 3), "d": round(d, 3)})
    if not out:
        return []
    out.sort(key=lambda w: (w["t"], w["s"]))
    prev = -1.0
    for w in out:
        if w["t"] <= prev:
            w["t"] = round(prev + 0.01, 3)
        prev = w["t"]
    for i, w in enumerate(out):
        nxt = out[i + 1]["t"] if i + 1 < len(out) else w["d"]
        if w["d"] <= w["t"] or w["d"] > nxt:
            w["d"] = nxt
        if w["d"] <= w["t"]:
            w["d"] = round(w["t"] + 0.05, 3)
        w["d"] = round(w["d"], 3)
    return out


def synth_unit_speechify(text, voice_id, mp3_path, json_path):
    """One sentence, one mp3, one timing file. The ring handles a key dying
    mid-sentence: sp_call condemns it and retries this very request."""
    voice_id, model = sp_voice_for(text, voice_id)
    payload = {"input": text, "voice_id": voice_id,
               "audio_format": "mp3", "model": model}
    body, err = sp_call("/v1/audio/speech", payload=payload, timeout=120)
    if body is None:
        return err or "Speechify failed"
    try:
        audio = base64.b64decode(body.get("audio_data") or "")
    except Exception:
        audio = b""
    if not audio:
        return "Speechify returned no audio"
    try:
        with open(mp3_path + ".part", "wb") as f:
            f.write(audio)
        os.replace(mp3_path + ".part", mp3_path)
    except Exception as e:
        return "could not write the clip: %s" % e
    sp_note_usage(_sp_last, body.get("billable_characters_count"))
    tokens = sp_tokens(text, body.get("speech_marks") or {})
    engine = "speechify"
    if not tokens:
        tokens = align_tokens(text, [], None)
        ref, dur, changed = refine_tokens(mp3_path, tokens)
        if changed:
            tokens = ref
        engine = "speechify-pcm"
    total = 0.0
    for t in tokens:
        if t.get("d", 0.0) > total:
            total = t["d"]
    json.dump({"tokens": tokens, "bounds": [], "total": round(total, 3),
               "engine": engine, "sil": measure_silence(mp3_path)},
              open(json_path, "w", encoding="utf-8"), ensure_ascii=False)
    return ""


# ---------- per-sentence generation, guarded so we never synth twice ----------
_gen_locks = {}
_gen_guard = threading.Lock()

def _lock_for(key):
    with _gen_guard:
        lk = _gen_locks.get(key)
        if lk is None:
            lk = threading.Lock(); _gen_locks[key] = lk
        return lk

def ensure_unit(tid, vkey, idx):
    """Make sure sentence (tid,vkey,idx) has an mp3 + bounds json. Returns
    (mp3_path, json_path, error). Units cached before v11 get their timing
    upgraded to waveform-measured times the first time they are used."""
    if vkey not in VKEYS and vkey not in SP_VOICES:
        # A Speechify voice the catalogue has not been asked for yet this run
        # (a resume, say). Rebuild the catalogue once and look again.
        if vkey.startswith("sp_"):
            st = load_state()
            sp_catalogue(st.get("spAccent", "uk"))
            if vkey not in SP_VOICES:
                for acc in SP_ACCENT_KEYS:
                    sp_catalogue(acc)
                    if vkey in SP_VOICES:
                        break
        if vkey not in VKEYS and vkey not in SP_VOICES:
            return None, None, "bad voice"
    mp3, js = unit_paths(tid, vkey, idx)
    if os.path.isfile(mp3) and os.path.isfile(js):
        refine_unit_json(mp3, js)
        return mp3, js, ""
    lk = _lock_for((tid, vkey, idx))
    with lk:
        if os.path.isfile(mp3) and os.path.isfile(js):
            refine_unit_json(mp3, js)
            return mp3, js, ""
        payload = text_payload(tid)
        if idx < 0 or idx >= payload["count"]:
            return None, None, "out of range"
        sent = payload["sentences"][idx]
        if vkey in SP_VOICES:
            err = synth_unit_speechify(sent, SP_VOICES[vkey]["id"], mp3, js)
        else:
            err = synth_unit(sent, VOICE_BY_VKEY[vkey][0], mp3, js)
        if err:
            return None, None, err
        return mp3, js, ""

# ---------- state ----------
_DEFAULT_STATE = {"voice": 1, "speed": 1.0, "volume": 100, "gap": 0.0, "lag": 0.0,
                  "wgap": 0.0,
                  "engine": "edge", "spAccent": "uk", "spVkey": "",
                  "spSet": 0, "bothEngines": False,
                  "floatPaste": True, "floatFull": True, "ffX": 0.82, "ffY": 0.58,
                  "floatSwap": True, "fsX": 0.82, "fsY": 0.44, "adbMode": True, "voiceBar": True,
                  "spPicked": None, "fullOnPaste": False, "hideTabs": True, "pane": "app",
                  "croVoice": "lesya", "engVoice": "beatrice_32", "lang": "eng", "langAuto": "eng", "wtime": True,
                  "mode": "read",
                  "fpX": 0.82, "fpY": 0.72,
                  "loop": False, "autoplay": False, "size": 13, "focus": False,
                  "theme": "night", "font": "sans", "lineheight": 3,
                  "wordhl": True, "wordoffsets": {}, 
                  "rgbSent": [255, 217, 59], "rgbWord": [226, 59, 78],
                  "rgbFont": [255, 255, 255], "rgbText": None,
                  "enabledLangs": list(DEFAULT_LANGS)}

def load_state():
    st = dict(_DEFAULT_STATE)
    got = False
    for path in (STATE_FILE, STATE_FILE + ".bak"):
        try:
            data = json.load(open(path, encoding="utf-8"))
            if isinstance(data, dict):
                st.update(data)
                got = True
                break
        except Exception:
            continue
    del got
    if not st.get("_wseed4"):           # word highlight is on by default now
        st["wordhl"] = True
        st["_wseed4"] = True
    if not isinstance(st.get("wordoffsets"), dict):
        st["wordoffsets"] = {}
    # Everything that reaches this comes from a browser, and a browser can be
    # a corrupted beacon or somebody with the console open. A negative speed
    # is not a preference, it is a broken player.
    def _num(key, lo, hi, default, nd=2):
        try:
            v = round(float(st.get(key, default)), nd)
        except (TypeError, ValueError):
            v = default
        st[key] = max(lo, min(hi, v))
    # the same limits the player itself uses, or the server would quietly
    # shrink a size the browser considers perfectly legal
    _num("lag", 0.0, 3.0, 0.0)
    _num("speed", 0.5, 3.0, 1.0)
    _num("volume", 0, 100, 100, 0)
    _num("size", 1, 14, 2, 0)
    _num("lineheight", 1.0, 3.0, 1.6)
    st["volume"] = int(st["volume"]); st["size"] = int(st["size"])
    # v3: the pause between WORDS. It is a real pause of the clip inside the
    # quiet the voice already leaves, so it only ever runs upward from zero:
    # there is no such thing as less silence than the voice recorded. Up to
    # two whole seconds, in twentieths, like everything else on the bar.
    try:
        st["wgap"] = max(0.0, min(2.0, round(float(st.get("wgap", 0.0)), 2)))
    except (TypeError, ValueError):
        st["wgap"] = 0.0
    # None = never chosen, [] = chosen to be none. Anything else is nonsense
    # and becomes None so the app can offer a starting set again.
    sp = st.get("spPicked")
    if sp is not None and not isinstance(sp, list):
        st["spPicked"] = None
    elif isinstance(sp, list):
        st["spPicked"] = [str(x) for x in sp if isinstance(x, str)]
    # A font or a pane that no longer exists must not survive on disk. The
    # client copes with either, but a stored value nobody recognises is a
    # small lie that outlives the release that made it.
    st["wtime"] = bool(st.get("wtime", True))
    # Both floaters: the switch is a yes or no, and the remembered corner is a
    # FRACTION of the screen. Anything else arriving here would be placed by
    # the browser as a pixel offset of NaN, which puts the button nowhere at
    # all and there is no way to drag back something you cannot see.
    st["floatFull"] = bool(st.get("floatFull", True))
    st["floatPaste"] = bool(st.get("floatPaste", True))
    st["floatSwap"] = bool(st.get("floatSwap", True))
    st["adbMode"] = bool(st.get("adbMode", True))
    # Keys from features that no longer exist are dropped rather than carried
    # forever. A settings file that still names a switch nobody can see is a
    # small lie, and the next person to read it will wonder what it does.
    # ONLY keys that are dead on BOTH sides. A key the client still writes
    # would be dropped here and written again on the next save, which is a
    # loop that does nothing and looks like a bug to whoever finds it. So
    # spPicked, wgap and aimeta stay: the client still persists all three.
    for _dead in ("bgResume", "swipeRev", "tapPaste"):
        st.pop(_dead, None)
    for _k, _d in (("ffX", 0.82), ("ffY", 0.58), ("fpX", 0.82), ("fpY", 0.72),
                   ("fsX", 0.82), ("fsY", 0.44)):
        try:
            _v = float(st.get(_k, _d))
        except (TypeError, ValueError):
            _v = _d
        if _v != _v:                      # NaN is never equal to itself
            _v = _d
        st[_k] = max(0.0, min(1.0, _v))
    if st.get("lang") not in ("eng", "hr", "auto"):
        st["lang"] = "eng"
    if st.get("langAuto") not in ("eng", "hr"):
        st["langAuto"] = "eng"
    if st.get("croVoice") not in [c["id"] for c in CRO_VOICES]:
        st["croVoice"] = CRO_DEFAULT
    if st.get("engVoice") not in [c["id"] for c in ENG_VOICES]:
        st["engVoice"] = ENG_DEFAULT
    if st.get("font") not in ("sans", "book", "serif", "mono"):
        st["font"] = "sans"
    if st.get("pane") not in ("edge", "speechify", "app"):
        st["pane"] = "app"
    if st.get("mode") not in ("read", "text"):
        st["mode"] = "read"          # edit is never restored
    if st.get("engine") not in ("edge", "speechify"):
        st["engine"] = "edge"
    if st.get("spAccent") not in SP_ACCENT_KEYS:
        st["spAccent"] = SP_ACCENT_KEYS[0]
    try:
        st["spSet"] = max(0, int(st.get("spSet", 0)))
    except (TypeError, ValueError):
        st["spSet"] = 0
    # Gap between sentences runs -1.0 to 3.0 seconds. A negative gap is an
    # overlap: the next sentence starts that much before the current one has
    # finished, which closes the seam between sentences completely. Two
    # decimals, because the control on the player steps in twentieths.
    try:
        st["gap"] = max(-1.0, min(3.0, round(float(st.get("gap", 0.0)), 2)))
    except (TypeError, ValueError):
        st["gap"] = 0.0
    def _clamp_rgb(v, d):
        if not (isinstance(v, list) and len(v) == 3):
            return list(d)
        out = []
        for x in v:
            try:
                x = int(x)
            except (TypeError, ValueError):
                x = 0
            out.append(max(0, min(255, x)))
        return out
    st["rgbSent"] = _clamp_rgb(st.get("rgbSent"), [255, 217, 59])
    st["rgbWord"] = _clamp_rgb(st.get("rgbWord"), [226, 59, 78])
    st["rgbFont"] = _clamp_rgb(st.get("rgbFont"), [255, 255, 255])
    rt = st.get("rgbText")
    st["rgbText"] = _clamp_rgb(rt, None) if isinstance(rt, list) and len(rt) == 3 else None
    # keep only real language keys, in catalog order. An empty list is allowed
    # (the user may choose zero languages); only a missing/invalid value falls
    # back to the default pair.
    valid = [lg["key"] for lg in LANGS]
    en = st.get("enabledLangs")
    if isinstance(en, list):
        st["enabledLangs"] = [k for k in valid if k in set(en)]
    else:
        st["enabledLangs"] = list(DEFAULT_LANGS)
    return st

def save_state(st):
    """Write the settings so that being interrupted cannot destroy them.

    Opening the file "w" truncates it immediately, so a phone that freezes or
    is killed mid-write leaves a half a file, which parses as nothing, which
    reads back as factory defaults. That is precisely what "my settings are
    not remembered" looks like. So: write a temporary file, flush it to the
    disk, and rename it over the top, which is atomic. The previous good copy
    is kept beside it as .bak for load_state to fall back on."""
    cur = load_state(); cur.update(st or {})
    try:
        os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
        tmp = STATE_FILE + ".part"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(cur, f)
            f.flush()
            os.fsync(f.fileno())
        if os.path.exists(STATE_FILE):
            try:
                shutil.copy2(STATE_FILE, STATE_FILE + ".bak")
            except Exception:
                pass
        os.replace(tmp, STATE_FILE)
    except Exception:
        pass
    return cur


# ===========================================================================
# v2 additions: mp3 duration, one-file karaoke export (mp3 + txt + json),
# an offline library scanner, and the key rings
# router used for optional titles and summaries in the archive.
# ===========================================================================

# ---------- mp3 duration (ffprobe first, then a pure-python frame sum) ------
_BR_V1L3 = [0,32,40,48,56,64,80,96,112,128,160,192,224,256,320,0]
_BR_V2L3 = [0,8,16,24,32,40,48,56,64,80,96,112,128,144,160,0]
_SR_TAB  = {0:{0:11025,1:12000,2:8000}, 3:{0:44100,1:48000,2:32000},
            2:{0:22050,1:24000,2:16000}}  # index by (version_bits) then sr_index

def _mp3_duration_frames(path):
    """Sum MPEG audio frame durations. Handles MPEG-1/2/2.5 Layer III, which is
    what edge-tts emits (24 kHz mono => MPEG-2 Layer III)."""
    try:
        data = open(path, "rb").read()
    except Exception:
        return None
    n = len(data); i = 0
    # skip an ID3v2 tag if present
    if data[:3] == b"ID3" and n > 10:
        size = ((data[6] & 0x7f) << 21) | ((data[7] & 0x7f) << 14) | \
               ((data[8] & 0x7f) << 7) | (data[9] & 0x7f)
        i = 10 + size
    total = 0.0; frames = 0
    while i + 4 <= n:
        if data[i] != 0xFF or (data[i+1] & 0xE0) != 0xE0:
            i += 1; continue
        b1, b2 = data[i+1], data[i+2]
        ver = (b1 >> 3) & 3          # 3=MPEG1, 2=MPEG2, 0=MPEG2.5
        layer = (b1 >> 1) & 3        # 1 => Layer III
        if layer != 1 or ver == 1:
            i += 1; continue
        br_i = (b2 >> 4) & 0xF
        sr_i = (b2 >> 2) & 3
        pad  = (b2 >> 1) & 1
        if br_i == 0 or br_i == 15 or sr_i == 3:
            i += 1; continue
        br = (_BR_V1L3 if ver == 3 else _BR_V2L3)[br_i] * 1000
        sr = _SR_TAB.get(ver, {}).get(sr_i)
        if not sr or not br:
            i += 1; continue
        spf = 1152 if ver == 3 else 576          # samples per frame, Layer III
        flen = int((spf // 8) * br / sr) + pad
        if flen < 4:
            i += 1; continue
        total += spf / float(sr)
        frames += 1
        i += flen
    return total if frames else None

def mp3_duration(path):
    # ffprobe is exact when present; the frame sum is a dependency-free fallback.
    try:
        out = subprocess.run(
            ["ffprobe", "-v", "quiet", "-show_entries", "format=duration",
             "-of", "csv=p=0", path],
            capture_output=True, text=True, timeout=20)
        v = float((out.stdout or "").strip())
        if v > 0:
            return v
    except Exception:
        pass
    return _mp3_duration_frames(path)

# Cheapest first. -latest aliases follow Google's newest tier so the ladder
# keeps working as models come and go. The router only climbs when a cheaper
# model fails validation, so easy jobs never touch a pricier model.
def _safe_name(s):
    s = re.sub(r"[^\w .()\-]+", "_", s or "").strip()
    return s[:60] or "export"

def _load_tok(js_path):
    try:
        return json.load(open(js_path, encoding="utf-8"))
    except Exception:
        return {"tokens": [], "bounds": [], "total": 0.0}

def build_trio(tid, vkey, timing="edge", use_ai_meta=False, force=False):
    """Produce the offline export: one small mp3 clip per sentence plus a txt
    and a json manifest. There is NO stitched mp3. The Offline player lights up
    the whole sentence and then plays that sentence's clip, so no cross-file
    timing is ever needed and the highlight can never run off the end.

    Word times inside a clip are relative to that clip (it starts at zero) and,
    when ffmpeg is present, they are the v11 waveform-measured times: pinned to
    the real decoded audio of that very clip (timing_source "pcm" in the
    manifest). Without ffmpeg they fall back to the engine's reported times.
    The `timing` argument is kept for older clients and ignored. Re-exporting
    the same title in the same voice is skipped unless forced, so a double tap
    does not resynthesise."""
    if vkey not in VKEYS and vkey not in SP_VOICES:
        return None, "bad voice"
    payload = text_payload(tid)
    sentences = payload["sentences"]
    if not sentences:
        return None, "That text is empty."
    if vkey in SP_VOICES:
        vname = SP_VOICES[vkey]["name"]
        vlang = SP_VOICES[vkey]["accent"]
    else:
        vname = VOICE_BY_VKEY[vkey][1]
        vlang = VOICE_BY_VKEY[vkey][2]

    app_title = payload["title"] or "Untitled"
    base = _safe_name("%s (%s)" % (app_title, vname))
    d = export_dir()
    clip_dir = os.path.join(d, base)            # sentence clips live in here
    txt_out = os.path.join(d, base + ".txt")
    json_out = os.path.join(d, base + ".json")

    # dedup: same title + same voice already fully exported -> skip
    if not force and os.path.isfile(json_out):
        try:
            prev = json.load(open(json_out, encoding="utf-8"))
            if prev.get("schema") == MANIFEST_SCHEMA and prev.get("vkey") == vkey:
                clips = prev.get("sentences", [])
                if clips and all(os.path.isfile(os.path.join(clip_dir,
                        s.get("clip", ""))) for s in clips):
                    return {"base": base, "txt": txt_out, "json": json_out,
                            "already": True,
                            "timing_source": prev.get("timing_source", "edge"),
                            "voice": vname}, ""
        except Exception:
            pass

    os.makedirs(clip_dir, exist_ok=True)
    timing_source = "edge"
    sent_objs = []
    duration = 0.0

    # --- one clip per sentence: synth, cache, copy into the export folder -----
    for i, sent in enumerate(sentences):
        mp3, js, err = ensure_unit(tid, vkey, i)
        if err:
            return None, "Sentence %d failed: %s" % (i + 1, err)
        clip_name = "s%04d.mp3" % i
        try:
            shutil.copyfile(mp3, os.path.join(clip_dir, clip_name))
        except Exception as e:
            return None, "Could not write clip %d: %s" % (i + 1, e)
        tok = _load_tok(js)
        toks = tok.get("tokens") or []
        total_rel = tok.get("total") or 0.0
        # timing measured from the decoded waveform (v11) is the truth; the
        # mp3 frame parser is only the fallback when ffmpeg was unavailable
        if tok.get("engine") in ("pcm", "pcm2") and total_rel > 0:
            dur = total_rel
            timing_source = "pcm"
        else:
            dur = mp3_duration(mp3)
            if not dur or dur <= 0:
                dur = (total_rel or 0.0) + 0.25

        words = []
        for t in toks:
            wt = float(t.get("t", 0.0))
            wd = float(t.get("d", t.get("t", 0.0)))
            if wd <= wt:
                wd = wt + 0.08
            if wd > dur:
                wd = dur
            words.append({"s": t.get("s", 0), "e": t.get("e", 0),
                          "t": round(wt, 3), "d": round(wd, 3)})
        sent_objs.append({"i": i, "text": sent, "clip": clip_name,
                          "dur": round(dur, 3), "words": words,
                          "sil": tok.get("sil") or measure_silence(mp3)})
        duration += dur

    ai_title = ""; summary = ""
    if False:
        obj, merr = (None, "")
        if obj:
            ai_title = obj["ai_title"]; summary = obj["summary"]

    open(txt_out, "w", encoding="utf-8").write("\n".join(sentences) + "\n")
    manifest = {
        "schema": MANIFEST_SCHEMA,
        "title": app_title, "ai_title": ai_title, "summary": summary,
        "voice": vname, "vkey": vkey, "lang": vlang,
        "created": int(time.time()),
        "duration": round(duration, 3),
        "clipdir": base, "text": base + ".txt",
        "timing_source": timing_source,
        "sentences": sent_objs,
    }
    json.dump(manifest, open(json_out, "w", encoding="utf-8"), ensure_ascii=False)
    return {"base": base, "txt": txt_out, "json": json_out,
            "already": False, "timing_source": timing_source, "voice": vname}, ""

# ---------- offline library: recognise the mp3 + txt + json trio -----------
def _offline_base(name):
    """Sanitise an offline manifest name to a bare, existing base in the export
    folder (blocks path traversal)."""
    name = os.path.basename(name or "")
    if name.endswith(".json"):
        name = name[:-5]
    d = export_dir()
    js = os.path.join(d, name + ".json")
    if os.path.isfile(js):
        return name, d, js
    return None, d, None

OFFPOS_FILE = os.path.join(WEB_DIR, "offline_pos.json")
def _load_pos():
    try:
        return json.load(open(OFFPOS_FILE, encoding="utf-8"))
    except Exception:
        return {}
def offline_get_pos(name):
    return float(_load_pos().get(os.path.basename(name or ""), 0) or 0)
def offline_set_pos(name, pos):
    d = _load_pos(); d[os.path.basename(name or "")] = round(float(pos or 0), 2)
    try:
        os.makedirs(WEB_DIR, exist_ok=True)
        json.dump(d, open(OFFPOS_FILE, "w", encoding="utf-8"))
    except Exception:
        pass

def _offline_clip_path(name, idx):
    """Resolve one sentence clip for a manifest, blocking path traversal.
    Returns the on-disk mp3 path or None."""
    base, d, js = _offline_base(name)
    if not base:
        return None
    try:
        m = json.load(open(js, encoding="utf-8"))
    except Exception:
        return None
    sents = m.get("sentences") or []
    if idx < 0 or idx >= len(sents):
        return None
    clip = os.path.basename(sents[idx].get("clip", "") or "")
    if not clip:
        return None
    clipdir = os.path.basename(m.get("clipdir", base) or base)
    p = os.path.join(d, clipdir, clip)
    return p if os.path.isfile(p) else None

def offline_list():
    d = export_dir()
    out = []
    for fn in (os.listdir(d) if os.path.isdir(d) else []):
        if not fn.endswith(".json"):
            continue
        base = fn[:-5]
        js = os.path.join(d, fn)
        try:
            m = json.load(open(js, encoding="utf-8"))
        except Exception:
            continue
        schema = m.get("schema")
        sents = m.get("sentences") or []
        if schema == MANIFEST_SCHEMA:
            clipdir = os.path.join(d, os.path.basename(m.get("clipdir", base)))
            ready = bool(sents) and all(
                os.path.isfile(os.path.join(clipdir,
                    os.path.basename(s.get("clip", "") or "x")))
                for s in sents)
            legacy = False
        elif schema == MANIFEST_SCHEMA_LEGACY:
            # old single-file export: still shown, but must be re-exported to
            # play with the new one-sentence-at-a-time engine
            ready = False
            legacy = True
        else:
            continue
        out.append({"name": base, "title": m.get("title", base),
                    "ai_title": m.get("ai_title", ""),
                    "summary": m.get("summary", ""),
                    "voice": m.get("voice", ""),
                    "duration": m.get("duration", 0),
                    "created": m.get("created", 0),
                    "count": len(sents),
                    "ready": ready, "legacy": legacy})
    out.sort(key=lambda x: x.get("created", 0), reverse=True)
    return out

def offline_delete(name):
    """Remove one export: its manifest, txt, clip folder, and any legacy mp3.
    Only touches files inside the export folder (path traversal blocked)."""
    base = os.path.basename(name or "")
    if base.endswith(".json"):
        base = base[:-5]
    if not base:
        return False
    d = export_dir()
    js = os.path.join(d, base + ".json")
    clipdir = base
    try:
        m = json.load(open(js, encoding="utf-8"))
        clipdir = os.path.basename(m.get("clipdir", base) or base)
    except Exception:
        pass
    for p in (js, os.path.join(d, base + ".txt"), os.path.join(d, base + ".mp3")):
        try:
            if os.path.isfile(p):
                os.remove(p)
        except Exception:
            pass
    folder = os.path.join(d, clipdir)
    if os.path.isdir(folder) and os.path.dirname(folder) == d:
        shutil.rmtree(folder, ignore_errors=True)
    # clear any saved resume position
    try:
        pos = _load_pos(); pos.pop(base, None)
        json.dump(pos, open(OFFPOS_FILE, "w", encoding="utf-8"))
    except Exception:
        pass
    return True
app = Flask(__name__, static_folder=None)

@app.after_request
def _no_cache_html(resp):
    if resp.mimetype == "text/html":
        resp.headers["Cache-Control"] = "no-store"
    return resp

@app.route("/")
def index():
    return send_file(os.path.join(STATIC_DIR, "index.html"))

@app.route("/static/<path:fn>")
def static_files(fn):
    return send_from_directory(STATIC_DIR, fn)

@app.route("/api/voices")
def api_voices():
    """Edge voices only. Speechify has its own route because its four are
    fetched live from the account rather than baked into this file."""
    out = [{"id": i, "vkey": v[4], "name": v[1], "lang": v[2], "sex": v[3],
            "engine": "edge", "label": voice_label(v[2], v[3])}
           for i, v in sorted(VOICES.items())]
    return jsonify(out)


def _sp_payload(accent, refresh=False):
    voices, err = sp_catalogue(accent, refresh=refresh)
    entries = sp_load_keys()
    dead = sp_fail_load()
    live = [e for e in entries if sp_fingerprint(e["key"]) not in dead]
    cur, cur_label = sp_current()
    use = sp_use_load()
    failed = []
    for e in entries:
        fp = sp_fingerprint(e["key"])
        if fp in dead:
            rec = dead[fp]
            failed.append({"fp": fp, "mask": rec.get("mask", ""),
                           "label": e.get("label") or rec.get("label", ""),
                           "reason": rec.get("reason", ""), "at": rec.get("at", 0)})
    # a key condemned and then struck from the file still deserves a line
    known = {sp_fingerprint(e["key"]) for e in entries}
    for fp, rec in dead.items():
        if fp not in known:
            failed.append({"fp": fp, "mask": rec.get("mask", ""),
                           "label": rec.get("label", ""), "reason": rec.get("reason", ""),
                           "at": rec.get("at", 0), "gone": True})
    return {"accent": accent,
            "accents": SP_ACCENTS,
            "perSet": SP_PER_SET,
            "sets": (len(voices) + SP_PER_SET - 1) // SP_PER_SET,
            "voices": [{"id": v["fid"], "vkey": v["vkey"], "name": v["name"],
                        "sex": v["sex"], "tone": v.get("tone", ""),
                        "accent": v["accent"], "engine": "speechify",
                        "label": v["label"]} for v in voices],
            "keys": len(entries),
            "live": len(live),
            "failed": failed,
            "keyList": [{"fp": sp_fingerprint(e["key"]),
                         "mask": sp_mask(e["key"]),
                         "label": e.get("label", ""),
                         "strong": bool(e.get("strong", True)),
                         "dead": sp_fingerprint(e["key"]) in dead,
                         "using": e["key"] == cur,
                         "chars": int((use.get(sp_fingerprint(e["key"])) or {}).get("chars", 0)),
                         "calls": int((use.get(sp_fingerprint(e["key"])) or {}).get("calls", 0))}
                        for e in entries],
            "charsTotal": sum(int((v or {}).get("chars", 0)) for v in use.values()),
            "ready": bool(cur),
            "using": sp_mask(cur),
            "usingLabel": cur_label,
            "error": err or _sp_err}


# ---------- reaching the rest of the phone ----------
# A page in a browser cannot touch another app, and neither can Termux by
# itself: Android only accepts a media command from a process holding shell
# privileges. There are two ways to get those without root, both of which the
# phone's own Developer options provide, and both of which need doing once per
# reboot rather than once per lifetime:
#
#   Shizuku   an app that holds an ADB-started service and lends it out. Its
#             osascript presses Cmd+Tab once Accessibility is granted. It
#             survives Wi-Fi changes because the service is already running.
#
#   self-ADB  Termux's own adb connecting to the phone it is running on, over
#             Wireless debugging. Inside Termux the address is always
#             127.0.0.1, so only the port matters.
#
# Rather than guess which one this phone has, try them in order and remember
# whichever answers. `cmd media_session dispatch` is preferred over a key
# press everywhere it exists, because it speaks to the media session itself
# instead of throwing a key at whatever happens to be listening.
# The media keys are gone. Asking Android to restart another player was a
# whole feature built on a privileged shell, and Baba does not want it: the
# half that mattered was always free, since this app taking the audio focus
# stops the other player by itself. What remains of that work is the shell
# runner below, which the app switcher uses.
_MK_GONE_DISPATCH = {"play": "play", "pause": "pause", "toggle": "play-pause",
               "next": "next", "previous": "previous", "stop": "stop"}
_MK_GONE_KEYCODE = {"play": "126", "pause": "127", "toggle": "85",
              "next": "87", "previous": "88", "stop": "86"}


def _mk_ok(p):
    """Exit zero is not enough. A denied `cmd` still exits zero on some builds
    and prints the refusal instead, so read what came back."""
    if p.returncode != 0:
        return False
    blob = ((p.stdout or b"") + (p.stderr or b"")).decode("utf-8", "replace").lower()
    for bad in ("exception", "permission deni", "security", "not allowed",
                "error:", "no devices", "device unauthorized", "must be root"):
        if bad in blob:
            return False
    return True


def _mk_try(name, argv):
    try:
        p = subprocess.run(argv, capture_output=True, timeout=8)
        return _mk_ok(p), None
    except FileNotFoundError:
        return False, "not installed"
    except subprocess.TimeoutExpired:
        return False, "timed out"
    except Exception as e:
        return False, str(e)[:40]


# ---------------------------------------------------------------------------
# SWITCHING APPS, on a Mac
#
# On Android this needed Shizuku, a paired shell and a keycode. A Mac already
# has the thing: Cmd+Tab goes to the app you were last in, which is exactly
# what was wanted. osascript asks System Events to press it.
#
# THE ONE CATCH is Accessibility. macOS refuses synthetic keystrokes from an
# app that has not been granted it, and answers -1719 or -1743 when it does.
# That is a permission to be given once in System Settings, not an error to
# be worked around, so it is reported as such.
SW_SCRIPT = 'tell application "System Events" to keystroke tab using command down'


def sw_deps():
    """What this Mac can offer, WITHOUT pressing anything.

    Asked before the first switch rather than after it fails, so the answer
    names the cause instead of a button that quietly does nothing."""
    have_osa = bool(shutil.which("osascript"))
    if not have_osa:
        return {"ready": False, "have": {"osascript": False}, "how": "",
                "missing": ["osascript"],
                "hint": "osascript is missing. That is unusual on a Mac."}
    # a harmless System Events question. If Accessibility is refused it fails
    # here, with the same error the real keystroke would give.
    ok, why = _mk_try("probe", ["osascript", "-e",
                                'tell application "System Events" to get name'])
    if ok:
        return {"ready": True, "have": {"osascript": True}, "how": "Cmd+Tab",
                "missing": [], "hint": ""}
    return {"ready": False, "have": {"osascript": True}, "how": "",
            "missing": ["accessibility"],
            "hint": "System Settings, Privacy and Security, Accessibility: "
                    "allow your terminal. Then try again."}


def _sw_routes():
    return [("cmd-tab", ["osascript", "-e", SW_SCRIPT])]


BROWSER_FILE = os.path.join(WEB_DIR, "browser.txt")


def browser_pref():
    """chrome, or auto for whatever the phone decided. Kept as a plain line in
    a file rather than inside the state json, because the launcher is a shell
    script and has to read it before Python is even running."""
    try:
        v = open(BROWSER_FILE, encoding="utf-8").read().strip().lower()
    except Exception:
        return "chrome"
    return "auto" if v == "auto" else "chrome"


# ---------- hearing a voice before choosing it ----------
# A name in a list says nothing about what a voice sounds like, and with 963
# of them that is the whole difficulty. So tapping one in Settings makes it
# introduce itself.
#
# Deliberately NOT routed through the library: a preview is not a text Marko
# saved and has no business appearing in his Archive. Its own folder, its own
# cache, one file per voice, made once and kept. Wiped by Forget along with
# everything else Speechify.
PREVIEW_DIR = os.path.join(WEB_DIR, "preview")
PREVIEW_LINE = "This is %s. Hi there."


def preview_name(vkey):
    if vkey in SP_VOICES:
        return SP_VOICES[vkey]["name"]
    if vkey in VOICE_BY_VKEY:
        return VOICE_BY_VKEY[vkey][1]
    return None


@app.route("/api/preview_v/<vid>")
def api_preview_v(vid):
    """A voice says its own name.

    Ported from TTT_MINI: "Hi, I am Lesya" tells him the accent, the pace and
    the warmth in four words, and ties the sound to the row he is looking at,
    which a neutral sentence would not."""
    v = None
    for t in (CRO_VOICES, ENG_VOICES):
        for c in t:
            if c["id"] == vid:
                v = c
                break
        if v:
            break
    if not v:
        return jsonify({"error": "unknown voice"}), 404
    hr = any(c["id"] == vid for c in CRO_VOICES) and request.args.get("hr") == "1"
    line = ("Bok, ja sam %s. \u010citam hrvatski." % v["name"]) if hr \
        else ("Hi, I am %s." % v["name"])
    safe = re.sub(r"[^A-Za-z0-9_]", "", vid)[:48] + ("_hr" if hr else "_en")
    mp3 = os.path.join(PREVIEW_DIR, "v_" + safe + ".mp3")
    if not os.path.exists(mp3) or os.path.getsize(mp3) < 400:
        with _lock_for(("preview_v", safe)):
            if not os.path.exists(mp3) or os.path.getsize(mp3) < 400:
                os.makedirs(PREVIEW_DIR, exist_ok=True)
                body, err = sp_call("/v1/audio/speech", payload={
                    "input": line, "voice_id": vid, "audio_format": "mp3",
                    "model": v["model"]}, timeout=120)
                if body is None:
                    return jsonify({"error": err or "Speechify failed"}), 502
                try:
                    audio = base64.b64decode(body.get("audio_data") or "")
                except Exception:
                    audio = b""
                if not audio:
                    return jsonify({"error": "no audio"}), 502
                with open(mp3 + ".part", "wb") as f:
                    f.write(audio)
                os.replace(mp3 + ".part", mp3)
                sp_note_usage(_sp_last, body.get("billable_characters_count"))
    return send_file(mp3, mimetype="audio/mpeg")


@app.route("/api/preview_hr/<vid>")
def api_preview_hr(vid):
    """One fixed Croatian sentence, so the two can be compared by ear without
    leaving Settings. It exercises every sound English gets wrong."""
    if not any(c["id"] == vid for c in CRO_VOICES):
        return jsonify({"error": "unknown voice"}), 404
    safe = re.sub(r"[^A-Za-z0-9_]", "", vid)[:48]
    mp3 = os.path.join(PREVIEW_DIR, "hr_" + safe + ".mp3")
    if not os.path.exists(mp3) or os.path.getsize(mp3) < 400:
        with _lock_for(("preview_hr", safe)):
            if not os.path.exists(mp3) or os.path.getsize(mp3) < 400:
                os.makedirs(PREVIEW_DIR, exist_ok=True)
                payload = {"input": CRO_SAMPLE, "voice_id": vid,
                           "audio_format": "mp3", "model": SP_MODEL_MULTI}
                body, err = sp_call("/v1/audio/speech", payload=payload, timeout=120)
                if body is None:
                    return jsonify({"error": err or "Speechify failed"}), 502
                try:
                    audio = base64.b64decode(body.get("audio_data") or "")
                except Exception:
                    audio = b""
                if not audio:
                    return jsonify({"error": "no audio"}), 502
                with open(mp3 + ".part", "wb") as f:
                    f.write(audio)
                os.replace(mp3 + ".part", mp3)
                sp_note_usage(_sp_last, body.get("billable_characters_count"))
    return send_file(mp3, mimetype="audio/mpeg")


@app.route("/api/keys/import", methods=["POST"])
def api_keys_import():
    """ONE picker for every key the app uses. No provider question is asked."""
    f = request.files.get("file")
    if not f:
        return jsonify({"error": "no file"}), 400
    raw = f.read().decode("utf-8", "replace")
    return jsonify(route_import(raw))


@app.route("/api/keys")
def api_keys():
    return jsonify({"keys": route_list()})


@app.route("/api/groq/status")
def api_groq_status():
    ents = groq_entries(); dead = groq_dead()
    strong = [e for e in ents if e.get("strong")]
    live = [e for e in strong if _groq_fp(e["key"]) not in dead]
    # The count reports REAL keys. A weak candidate that turned out to be a
    # word from the file is not a dead key and is not counted as one.
    return jsonify({
        "total": len(strong), "live": len(live),
        "dead": len(strong) - len(live),
        "extra": len(ents) - len(strong),
        "labels": [e.get("label", "") for e in strong],
        "model": groq_model_saved(), "err": _groq_err,
    })


@app.route("/api/groq/keyfile", methods=["POST"])
def api_groq_keyfile():
    """Keys arrive as a file, never typed. Written 0600 and never echoed."""
    f = request.files.get("file")
    if not f:
        return jsonify({"error": "no file"}), 400
    raw = f.read().decode("utf-8", "replace")
    try:
        os.makedirs(WEB_DIR, exist_ok=True)
        tmp = GROQ_KEYFILE + ".part"
        with open(tmp, "w", encoding="utf-8") as fh:
            fh.write(raw)
        os.replace(tmp, GROQ_KEYFILE)
        os.chmod(GROQ_KEYFILE, 0o600)
    except Exception as e:
        return jsonify({"error": str(e)[:80]}), 500
    return jsonify({"ok": True, "keys": len(groq_keys())})


@app.route("/api/groq/test", methods=["POST"])
def api_groq_test():
    """Prove the ring end to end on a sentence we already know the answer to."""
    eng, model, err = groq_is_english("This is a plain English sentence.")
    return jsonify({"ok": eng is True, "model": model, "err": err})


@app.route("/api/lang/detect", methods=["POST"])
def api_lang_detect():
    data = request.get_json(force=True, silent=True) or {}
    text = data.get("text") or ""
    if not text and data.get("tid"):
        try:
            raw = lib_text(data["tid"]) or ""
            text = " ".join(raw[a:b] for a, b in split_sentences(raw)[:5])
        except Exception:
            text = ""
    eng, model, err = groq_is_english(text)
    if eng is None:
        # Nobody could be asked. Fall back to reading the text ourselves
        # rather than guessing English and mangling a Croatian page.
        guess = "hr" if looks_croatian(text) else "eng"
        return jsonify({"lang": guess, "by": "local", "model": "", "err": err})
    return jsonify({"lang": "eng" if eng else "hr", "by": "groq",
                    "model": model, "err": ""})


@app.route("/api/cro_voices")
def api_cro_voices():
    """Both lists, and which one is chosen in each."""
    return jsonify({"cro": CRO_VOICES, "eng": ENG_VOICES,
                    "croChosen": cro_voice_id(), "engChosen": eng_voice_id(),
                    "voices": CRO_VOICES, "chosen": cro_voice_id(),
                    "sample": CRO_SAMPLE})


@app.route("/api/preview/<vkey>")
def api_preview(vkey):
    name = preview_name(vkey)
    if name is None and vkey.startswith("sp_"):
        # a Speechify voice from a page the catalogue has not built this run
        st = load_state()
        sp_catalogue(st.get("spAccent", "uk"))
        if vkey not in SP_VOICES:
            for acc in SP_ACCENT_KEYS:
                sp_catalogue(acc)
                if vkey in SP_VOICES:
                    break
        name = preview_name(vkey)
    if name is None:
        return jsonify({"error": "unknown voice"}), 404

    safe = re.sub(r"[^A-Za-z0-9_]", "", vkey)[:48]
    if not safe:
        return jsonify({"error": "bad voice"}), 400
    mp3 = os.path.join(PREVIEW_DIR, safe + ".mp3")
    # A fast thumb taps four voices in a second, and without this two requests
    # for the SAME voice both synthesise into the same path and one of them
    # serves a half-written file. The article cache has always taken this lock;
    # the preview simply forgot to, which cost five failures out of ten the
    # first time it was tested under a real thumb.
    if not os.path.exists(mp3) or os.path.getsize(mp3) < 400:
        lk = _lock_for(("preview", safe))
        with lk:
            if not os.path.exists(mp3) or os.path.getsize(mp3) < 400:
                try:
                    os.makedirs(PREVIEW_DIR, exist_ok=True)
                except Exception as e:
                    return jsonify({"error": str(e)}), 500
                line = PREVIEW_LINE % name
                js = mp3 + ".json"
                if vkey in SP_VOICES:
                    err = synth_unit_speechify(line, SP_VOICES[vkey]["id"], mp3, js)
                else:
                    err = synth_unit(line, VOICE_BY_VKEY[vkey][0], mp3, js)
                if err:
                    return jsonify({"error": err}), 502
    resp = send_file(mp3, mimetype="audio/mpeg", conditional=True)
    resp.headers["Cache-Control"] = "private, max-age=604800"
    return resp


@app.route("/manifest.webmanifest")
def api_manifest():
    """The only truly bulletproof way to be rid of the browser furniture.

    The Fullscreen API hides the address bar while the page asks for it, but
    Chrome puts it back on any hint of a scroll or a gesture, and some skins
    keep a sliver of it no matter what. Installed to the home screen with
    display standalone, there is no browser interface at all, because there is
    no browser tab: it opens as its own window. Nothing can pin a bar to a
    window that has none."""
    return jsonify({
        "name": "MA Reader", "short_name": "MA Reader",
        "start_url": "/", "scope": "/",
        "display": "standalone", "display_override": ["fullscreen", "standalone"],
        "orientation": "any",
        "background_color": "#080a10", "theme_color": "#080a10",
        "icons": [{"src": "/static/icon.svg", "sizes": "any",
                   "type": "image/svg+xml", "purpose": "any"}]
    })


@app.route("/api/browser", methods=["GET", "POST"])
def api_browser():
    if request.method == "POST":
        data = request.get_json(force=True, silent=True) or {}
        v = "auto" if str(data.get("mode", "chrome")).lower() == "auto" else "chrome"
        try:
            os.makedirs(WEB_DIR, exist_ok=True)
            with open(BROWSER_FILE, "w", encoding="utf-8") as f:
                f.write(v + "\n")
        except Exception as e:
            return jsonify({"error": str(e)}), 400
    return jsonify({"mode": browser_pref()})




@app.route("/api/speechify/status")
def api_sp_status():
    st = load_state()
    return jsonify(_sp_payload(st.get("spAccent", "uk")))


@app.route("/api/speechify/accent", methods=["POST"])
def api_sp_accent():
    data = request.get_json(force=True, silent=True) or {}
    acc = data.get("accent", "uk")
    if acc not in SP_ACCENT_KEYS:
        acc = SP_ACCENT_KEYS[0]
    save_state({"spAccent": acc})
    return jsonify(_sp_payload(acc))


@app.route("/api/speechify/refresh", methods=["POST"])
def api_sp_refresh():
    """The one place that deliberately spends a request per key. Everywhere
    else the ring learns a key is dead by simply using it."""
    st = load_state()
    counts = sp_test_all()
    out = _sp_payload(st.get("spAccent", "uk"), refresh=True)
    out["tested"] = counts
    return jsonify(out)


@app.route("/api/speechify/keys", methods=["POST"])
def api_sp_keys():
    """Take the key file. It is written into the app folder and never leaves
    it, never appears in a response, and never goes back to the browser."""
    raw = ""
    f = request.files.get("file")
    if f is not None:
        raw = f.read().decode("utf-8", "replace")
    else:
        data = request.get_json(force=True, silent=True) or {}
        raw = data.get("text", "")
    # Accept on CANDIDATES, not on shape. Refusing a file because nothing in
    # it starts with sk_ is the same mistake as discarding a key for its
    # shape, one step earlier.
    if not any(SP_MAYBE_RE.match(ln.strip()) for ln in raw.splitlines()):
        return jsonify({"error": "nothing in that file looks like a key"}), 400
    try:
        os.makedirs(WEB_DIR, exist_ok=True)
        with open(SPEECHIFY_KEY_FILE, "w", encoding="utf-8") as fh:
            fh.write(raw if raw.endswith("\n") else raw + "\n")
        try:
            os.chmod(SPEECHIFY_KEY_FILE, 0o600)
        except Exception:
            pass
    except Exception as e:
        return jsonify({"error": "could not save the keys: %s" % e}), 400
    with _sp_lock:
        globals()["_sp_key"] = None
    st = load_state()
    return jsonify(_sp_payload(st.get("spAccent", "uk"), refresh=True))


@app.route("/api/speechify/revive", methods=["POST"])
def api_sp_revive():
    """Clear a dead mark. For a key that was only suspended, not revoked."""
    data = request.get_json(force=True, silent=True) or {}
    sp_revive(str(data.get("fp", "")))
    with _sp_lock:
        globals()["_sp_key"] = None
    st = load_state()
    return jsonify(_sp_payload(st.get("spAccent", "uk")))


@app.route("/api/speechify/drop", methods=["POST"])
def api_sp_drop():
    """Strike a dead key out of the file for good, so it is never read again."""
    data = request.get_json(force=True, silent=True) or {}
    sp_drop(str(data.get("fp", "")))
    with _sp_lock:
        globals()["_sp_key"] = None
    st = load_state()
    return jsonify(_sp_payload(st.get("spAccent", "uk")))


@app.route("/api/speechify/forget", methods=["POST"])
def api_sp_forget():
    global SP_VOICES
    try:
        for f in os.listdir(PREVIEW_DIR):
            if f.startswith("sp_"):
                os.remove(os.path.join(PREVIEW_DIR, f))
    except Exception:
        pass
    for p in (SPEECHIFY_KEY_FILE, SP_CACHE_FILE, SP_FAIL_FILE, SP_USE_FILE):
        try:
            os.remove(p)
        except Exception:
            pass
    with _sp_lock:
        globals()["_sp_key"] = None
    SP_VOICES = {}
    st = load_state()
    return jsonify(_sp_payload(st.get("spAccent", "uk")))


@app.route("/api/langs")
def api_langs():
    """Full language catalogue for the Settings checkbox list. Each entry
    carries its two voices (with the flat ids the picker uses) and, where a
    voice can also stand in for a dialect or related tongue, a "uses" string
    shown as a 'Can be used for:' line."""
    out = []
    by_key_voices = {}
    for vid, v in sorted(VOICES.items()):
        by_key_voices.setdefault(v[2], []).append(
            {"id": vid, "name": v[1], "sex": v[3], "vkey": v[4]})
    for lg in LANGS:
        out.append({"key": lg["key"], "label": lg["label"],
                    "native": lg.get("native", ""),
                    "uses": lg.get("uses", ""),
                    "voices": by_key_voices.get(lg["key"], [])})
    return jsonify({"langs": out, "default": list(DEFAULT_LANGS)})

@app.route("/api/appswitch/status")
def api_appswitch_status():
    return jsonify(sw_deps())


@app.route("/api/appswitch", methods=["POST"])
def api_appswitch():
    """Back to the app you were in before this one.

    A web page cannot switch Android apps: there is no API for it and there
    should not be. This goes through the privileged shell, and it CHECKS
    FIRST, so a refusal names its cause."""
    d = sw_deps()
    if not d["ready"]:
        return jsonify({"ok": False, "error": d["hint"],
                        "missing": d["missing"], "tried": []})
    tried = []
    for name, argv in _sw_routes():
        ok, why = _mk_try(name, argv)
        tried.append("%s: %s" % (name, "ok" if ok else (why or "refused")))
        if ok:
            return jsonify({"ok": True, "route": name, "tried": tried})
    return jsonify({"ok": False, "tried": tried,
                    "error": "The shell is there but refused. Run maread-adb "
                             "in Termux to check the connection."})


@app.route("/api/state", methods=["GET", "POST"])
def api_state():
    if request.method == "POST":
        return jsonify(save_state(request.get_json(force=True, silent=True) or {}))
    return jsonify(load_state())

@app.route("/api/prepare", methods=["POST"])
def api_prepare():
    data = request.get_json(force=True, silent=True) or {}
    raw = data.get("text", "")
    # The browser sends `spoken` when it has rendered Markdown: the string it
    # built by walking the rendered text nodes. It is NOT cleaned again here,
    # because it has no markers left in it and cleaning would move every
    # offset out from under the word spans that were numbered against it.
    spoken = data.get("spoken", "") or ""
    if not isinstance(spoken, str):
        spoken = ""
    spoken = spoken.replace("\r\n", "\n").replace("\r", "\n")
    text = spoken if spoken.strip() else clean_text(raw)
    if not text.strip():
        return jsonify({"error": "Paste some text first."}), 400
    tid = lib_save(raw, spoken)
    return jsonify(text_payload(tid))

@app.route("/api/library")
def api_library():
    return jsonify(lib_list())

@app.route("/api/library/<tid>")
def api_library_open(tid):
    if not os.path.isdir(os.path.join(LIB_DIR, tid)):
        abort(404)
    return jsonify(text_payload(tid))

@app.route("/api/library/<tid>/delete", methods=["POST"])
def api_library_delete(tid):
    lib_delete(tid)
    return jsonify({"ok": True})

@app.route("/api/library/delete_bulk", methods=["POST"])
def api_library_delete_bulk():
    data = request.get_json(force=True, silent=True) or {}
    ids = data.get("ids") or []
    n = 0
    for tid in ids:
        tid = os.path.basename(str(tid))       # block path traversal
        if tid and os.path.isdir(os.path.join(LIB_DIR, tid)):
            lib_delete(tid); n += 1
    return jsonify({"ok": True, "deleted": n})

@app.route("/api/library/delete_all", methods=["POST"])
def api_library_delete_all():
    n = 0
    for m in lib_list():
        lib_delete(m["id"]); n += 1
    return jsonify({"ok": True, "deleted": n})

@app.route("/api/audio/<tid>/<vkey>/<int:idx>.mp3")
def api_audio(tid, vkey, idx):
    mp3, js, err = ensure_unit(tid, vkey, idx)
    if err:
        return jsonify({"error": err}), 400
    resp = send_file(mp3, mimetype="audio/mpeg", conditional=True)
    # The url carries the text id, the voice and the sentence number, so a clip
    # at a given url never changes. Saying so removes the revalidation round
    # trip the browser was making between every pair of sentences.
    resp.headers["Cache-Control"] = "private, max-age=31536000, immutable"
    return resp

@app.route("/api/bounds/<tid>/<vkey>/<int:idx>")
def api_bounds(tid, vkey, idx):
    mp3, js, err = ensure_unit(tid, vkey, idx)
    if err:
        return jsonify({"error": err}), 400
    # LAYER 2. The clip exists and is about to be read, so this is the moment
    # to ask Whisper where the words actually fall. Paid for once per sentence
    # per voice: the answer is written into this same json. If there is no key,
    # no network, or no answer, the engine's own marks stay exactly as they
    # were and nothing is lost but precision.
    if load_state().get("wtime", True) and groq_live():
        try:
            # Telling Whisper the language measurably improves its word
            # timings. The voice knows it; the app's own setting is the
            # fallback, and AUTO resolves to whatever it last decided.
            # An Edge voice knows its own language; a Speechify voice does
            # not, so the switch answers for it. Same authority either way.
            lang = VKEY_LANG.get(vkey)
            if lang:
                lang = "hr" if lang == "hr" else "en"
            else:
                lang = "hr" if reading_lang() == "hr" else "en"
            wt_apply(mp3, js, language=lang)
        except Exception:
            pass
    try:
        data = json.load(open(js, encoding="utf-8"))
    except Exception:
        data = {"tokens": []}
    return jsonify(data)

@app.route("/api/export", methods=["POST"])
def api_export():
    data = request.get_json(force=True, silent=True) or {}
    tid = data.get("tid", ""); vkey = data.get("vkey", "ukF")
    if vkey not in VKEYS and vkey not in SP_VOICES:
        if vkey.startswith("sp_"):
            sp_catalogue(load_state().get("spAccent", "uk"))
        if vkey not in VKEYS and vkey not in SP_VOICES:
            vkey = "ukF"
    use_meta = bool(data.get("meta"))
    force = bool(data.get("force"))
    res, err = build_trio(tid, vkey, use_ai_meta=use_meta, force=force)
    if err:
        return jsonify({"error": err}), 400
    return jsonify({"base": res["base"],
                    "txt": res["txt"], "json": res["json"],
                    "already": res.get("already", False),
                    "timing_source": res.get("timing_source", "edge"),
                    "voice": res.get("voice", ""),
                    "dir": export_dir()})

@app.route("/api/offline/pos/<name>")
def api_offline_get_pos(name):
    return jsonify({"pos": offline_get_pos(name)})

@app.route("/api/offline/pos", methods=["POST"])
def api_offline_set_pos():
    data = request.get_json(force=True, silent=True) or {}
    offline_set_pos(data.get("name", ""), data.get("pos", 0))
    return jsonify({"ok": True})

# ---------- offline reader (plays per-sentence clips, no synthesis) ----------
@app.route("/api/offline/list")
def api_offline_list():
    return jsonify(offline_list())

@app.route("/api/offline/open/<name>")
def api_offline_open(name):
    base, d, js = _offline_base(name)
    if not base:
        abort(404)
    try:
        return jsonify(json.load(open(js, encoding="utf-8")))
    except Exception:
        return jsonify({"error": "That manifest could not be read."}), 400

@app.route("/api/offline/clip/<name>/<int:idx>.mp3")
def api_offline_clip(name, idx):
    p = _offline_clip_path(name, idx)
    if not p:
        abort(404)
    resp = send_file(p, mimetype="audio/mpeg", conditional=True)
    resp.headers["Cache-Control"] = "private, max-age=604800"
    return resp

@app.route("/api/offline/delete", methods=["POST"])
def api_offline_delete():
    data = request.get_json(force=True, silent=True) or {}
    offline_delete(data.get("name", ""))
    return jsonify({"ok": True})

@app.route("/api/offline/delete_bulk", methods=["POST"])
def api_offline_delete_bulk():
    data = request.get_json(force=True, silent=True) or {}
    names = data.get("names") or []
    n = 0
    for nm in names:
        if offline_delete(nm):
            n += 1
    return jsonify({"ok": True, "deleted": n})

@app.route("/api/offline/delete_all", methods=["POST"])
def api_offline_delete_all():
    n = 0
    for m in offline_list():
        if offline_delete(m["name"]):
            n += 1
    return jsonify({"ok": True, "deleted": n})

def _bg_wake_lock():
    # when running detached in the background, hold our own wake lock so the
    # server keeps serving after the foreground launcher releases its lock.
    try:
        subprocess.Popen(["caffeinate", "-dimsu"],
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass


def _pick_port(host, start, span=40):
    """Take the first free port at or above the base one.

    Marko runs many small servers at once, so binding a fixed port means one
    of them silently loses. Test-bind upward instead, then write the winner to
    a portfile so the launcher knows where to point the browser.
    """
    import socket
    probe = host if host not in ("0.0.0.0", "") else ""
    for p in range(start, start + span):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            s.bind((probe, p))
            s.close()
            return p
        except OSError:
            try:
                s.close()
            except Exception:
                pass
    return start


def _write_port(p):
    try:
        os.makedirs(WEB_DIR, exist_ok=True)
        with open(PORT_FILE, "w", encoding="utf-8") as f:
            f.write(str(p))
    except Exception:
        pass


def _open_page():
    """Open the reader in whatever browser this machine has."""
    url = "http://localhost:%d" % PORT
    for cmd in ("open", "xdg-open"):
        if shutil.which(cmd):
            try:
                subprocess.Popen([cmd, url],
                                 stdout=subprocess.DEVNULL,
                                 stderr=subprocess.DEVNULL)
                return True
            except Exception:
                pass
    return False


def _app_version():
    """The version lives in index.html and nowhere else. Read it, do not
    repeat it, or the banner and the Help tab drift apart."""
    try:
        with open(os.path.join(STATIC_DIR, "index.html"), encoding="utf-8") as f:
            m = re.search(r'id="appVer">([^<]+)<', f.read())
        if m:
            return m.group(1).strip()
    except Exception:
        pass
    return "unknown"


def _banner():
    """A terminal is a place too, so it gets a proper front page."""
    tty_ok = False
    try:
        import sys as _s
        tty_ok = _s.stdout.isatty()
    except Exception:
        pass

    def c(code, text):
        return ("\033[%sm%s\033[0m" % (code, text)) if tty_ok else text

    # NO 24-BIT COLOUR here either: 256 where the terminal has 256, the
    # basic eight otherwise, nothing when this is not a terminal.
    ncol = 0
    if tty_ok:
        try:
            import curses
            curses.setupterm()
            ncol = curses.tigetnum("colors") or 0
        except Exception:
            ncol = 8
    # Gold for the name, dim for labels, white for values. The same three
    # the launcher and the updater use, because it is one app. No red: red
    # says something is wrong, and a server that started is not wrong.
    if ncol >= 256:
        fire, ember, ash, ink = "1;38;5;222", "38;5;222", "38;5;245", "38;5;252"
    else:
        fire, ember, ash, ink = "1;33", "0;33", "0;37", "0;37"
    art = [
        "   __  __   _     ___ ___   _   ___  ___ ___ ",
        "  |  \\/  | /_\\   | _ \\ __| /_\\ |   \\| __| _ \\",
        "  | |\\/| |/ _ \\  |   / _| / _ \\| |) | _||   /",
        "  |_|  |_/_/ \\_\\ |_|_\\___/_/ \\_\\___/|___|_|_\\",
    ]
    print("")
    for i, line in enumerate(art):
        print(c(fire if i < 2 else ember, line))
    print(c(ash, "        Fire | the Word, the MA ecosystem"))
    print("")
    rows = [("version", _app_version()),
            ("address", "http://localhost:%d" % PORT),
            ("port", "%d  (base %d)" % (PORT, BASE_PORT)),
            ("library", "~/.maread/library")]
    w = max(len(k) for k, _ in rows)
    bar = "   " + "-" * 42
    print(c(ash, bar))
    for k, v in rows:
        print("  " + c(ash, k.ljust(w)) + "  " + c(ink, v))
    print(c(ash, bar))
    print("   " + c(fire, "[Q]") + " " + c(ash, "stop"))
    print("   " + c(fire, "[O]") + " " + c(ash, "open the page"))
    print("   " + c(fire, "[B]") + " " + c(ash, "keep serving in the background"))
    print(c(ash, bar))
    print("")


def _serve_with_keys():
    """Serve Flask in a background thread and watch raw keyboard input.

    q / Q  -> quit the server right away, no Enter needed
    o / O  -> open the reader in the browser, for a tab closed by mistake
    b / B  -> detach and keep serving in the background, freeing the terminal
    Ctrl-C -> quit as well
    """
    import sys, termios, tty, select
    from werkzeug.serving import make_server

    srv = make_server(HOST, PORT, app, threaded=True)
    t = threading.Thread(target=srv.serve_forever, daemon=True)
    t.start()

    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    quiet = "\033[0;90m"; off = "\033[0m"
    try:
        tty.setcbreak(fd)
        while True:
            r, _, _ = select.select([fd], [], [], 0.3)
            if not r:
                if not t.is_alive():
                    break
                continue
            ch = os.read(fd, 1).decode(errors="ignore")
            if ch in ("q", "Q", "\x03", "\x04"):
                break
            if ch in ("o", "O"):
                if not _open_page():
                    print(f"  {quiet}no browser opener found; visit "
                          f"http://localhost:{PORT}{off}", flush=True)
                continue
            if ch in ("b", "B"):
                termios.tcsetattr(fd, termios.TCSADRAIN, old)
                # release the port, then relaunch a detached copy that keeps
                # serving without reading keys.
                srv.shutdown()
                try:
                    srv.server_close()
                except Exception:
                    pass
                t.join(timeout=3)
                logf = os.path.join(WEB_DIR, "server.log")
                env = dict(os.environ, MA_NO_KEYS="1", MA_BG="1",
                           MAREAD_WEB_PORT=str(PORT))
                try:
                    lf = open(logf, "ab")
                except Exception:
                    lf = subprocess.DEVNULL
                subprocess.Popen(
                    [sys.executable, os.path.abspath(__file__)],
                    stdin=subprocess.DEVNULL, stdout=lf, stderr=lf,
                    start_new_session=True, env=env)
                print(f"  {quiet}MA Reader is now running in the background "
                      f"on http://localhost:{PORT}{off}", flush=True)
                os._exit(0)
    finally:
        try:
            termios.tcsetattr(fd, termios.TCSADRAIN, old)
        except Exception:
            pass
    srv.shutdown()
    try:
        srv.server_close()
    except Exception:
        pass
    os._exit(0)


if __name__ == "__main__":
    import logging, sys
    logging.getLogger("werkzeug").setLevel(logging.ERROR)
    try:
        import werkzeug.serving as _ws
        _ws.show_server_banner = lambda *a, **k: None
    except Exception:
        pass
    try:                      # flask prints its own line too; we have a banner
        import flask.cli as _fc
        _fc.show_server_banner = lambda *a, **k: None
    except Exception:
        pass
    if os.environ.get("MA_BG") == "1":
        _bg_wake_lock()
    else:
        PORT = _pick_port(HOST, BASE_PORT)
    _write_port(PORT)
    interactive = (sys.stdin.isatty()
                   and os.environ.get("MA_NO_KEYS") != "1")
    if interactive:
        _banner()
    if interactive:
        try:
            _serve_with_keys()
        except Exception:
            # if anything about the raw-key path fails, fall back to plain run
            app.run(host=HOST, port=PORT, threaded=True)
    else:
        app.run(host=HOST, port=PORT, threaded=True)
PYEOF
printf '    %s\xe2\x9c\x93%s %sserver.py%s\n' "$GREEN" "$OFF" "$DIM" "$OFF"
prog 55 "the page"
cat > "$APPDIR/static/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="theme-color" content="#080a10">
<link rel="manifest" href="/manifest.webmanifest">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<link rel="icon" type="image/svg+xml" href="/static/icon.svg">
<link rel="mask-icon" href="/static/icon.svg" color="#ebcd2d">
<link rel="apple-touch-icon" href="/static/icon.svg">
<title>MA Reader</title>
<style>


/* ---------- themes (Night is the default house look) ---------- */
body[data-theme="night"]{
  --bg:#080a10; --bg2:#0b0e15; --panel:#11141d; --line:#1d2230;
  --text:#cdd0d6; --dim:#7c8294; --faint:#565d6e;
  --page:#080a10; --page-text:#cdd0d6;
  --sent:#ffd93b; --sent-fg:#10120a; --sent-soft:rgba(255,217,59,.34);
  --wordbg:#e23b4e; --wordfg:#ffffff;     /* the word being read, in red */
}
body[data-theme="sepia"]{
  --bg:#efe3cc; --bg2:#ece0c6; --panel:#e6d9bd; --line:#d6c5a1;
  --text:#4a3f2e; --dim:#8a7a5c; --faint:#a99a78;
  --page:#f4ead4; --page-text:#43392a;
  --sent:#e7b53f; --sent-fg:#2a2113; --sent-soft:rgba(231,181,63,.40);
  --wordbg:#c0392b; --wordfg:#ffffff;
}
body[data-theme="day"]{
  --bg:#f6f7fa; --bg2:#eef0f5; --panel:#ffffff; --line:#e1e4ea;
  --text:#1c2026; --dim:#5a616e; --faint:#9aa0ac;
  --page:#ffffff; --page-text:#1b1f25;
  --sent:#ffd93b; --sent-fg:#10120a; --sent-soft:rgba(245,196,0,.30);
  --wordbg:#d62828; --wordfg:#ffffff;
}
:root{
  --screen:#4696e6; --play:#37c878; --tune:#ebcd2d;
  --mode:#be82eb; --act:#f09646; --exit:#e15f5f; --teal:#3fb9c8;
  --read:21px; --col:680px; --read-lh:1.72;
  --read-font:Georgia,"Times New Roman",serif;
}
*{box-sizing:border-box}
html,body{margin:0;height:100%}
body{
  background:var(--bg); color:var(--text);
  font-family:system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;
  -webkit-text-size-adjust:100%;
  display:flex; flex-direction:column; min-height:100%;
  transition:background .25s,color .25s;
}
button{font-family:inherit; cursor:pointer; color:inherit}
.hidden{display:none !important}

/* ---------- top bar ---------- */
header{
  position:sticky; top:0; z-index:20;
  background:var(--bg2); border-bottom:1px solid var(--line);
  padding:calc(10px + env(safe-area-inset-top)) 12px 10px 12px;
}
.appver{position:absolute; top:calc(6px + env(safe-area-inset-top)); right:10px;
  font-size:10px; color:var(--faint); letter-spacing:.04em; opacity:.7}
.brand{display:flex; align-items:center; gap:10px; margin-bottom:8px}
.brand .dot{width:10px;height:10px;border-radius:50%;
  background:var(--play); box-shadow:0 0 10px var(--play)}
.brand b{font-size:15px; letter-spacing:.18em; font-weight:700;
  color:var(--text); text-transform:uppercase}
.brand .sub{font-size:11px; color:var(--faint); letter-spacing:.04em;
  margin-left:auto}

/* the picker is a horizontal strip: one tidy row you swipe through, so any
   number of enabled languages stays out of the way. The right padding keeps
   the last chip clear of the gear button in the corner. */
.voices{display:flex; gap:6px; margin-bottom:8px; flex-wrap:nowrap;
  overflow-x:auto; overflow-y:hidden; padding:1px 46px 3px 1px;
  -webkit-overflow-scrolling:touch; scrollbar-width:none}
.voices::-webkit-scrollbar{display:none}
/* Both engines at once. The strip becomes a column of two strips, each one
   scrolling on its own, so Speechify on top and Edge underneath never fight
   over the same sideways swipe. */
.voices.dual{flex-direction:column; gap:5px; overflow-x:hidden;
  padding-right:1px}
.vrow{display:flex; gap:6px; flex-wrap:nowrap; overflow-x:auto;
  overflow-y:hidden; padding:1px 46px 2px 1px;
  -webkit-overflow-scrolling:touch; scrollbar-width:none}
.vrow::-webkit-scrollbar{display:none}
.voice{flex:0 0 auto; min-width:96px; padding:7px 10px; border-radius:9px;
  border:1px solid var(--line); background:var(--panel);
  color:var(--dim); font-size:12px; line-height:1.15; text-align:center}
.voice b{display:block; color:var(--text); font-size:12.5px; white-space:nowrap}
.voice small{font-size:10px; color:var(--faint); white-space:nowrap}
.voice.on{border-color:var(--screen); background:rgba(70,150,230,.16);
  color:var(--text)}
.voice.on b{color:var(--text)}
.voices-empty{flex:0 0 auto; color:var(--faint); font-size:12px;
  padding:9px 4px; white-space:nowrap}

/* ---------- Languages panel (Settings) ---------- */
.langhint{font-size:11.5px; color:var(--faint); line-height:1.5; margin:2px 0 10px}
.lang-tools{display:flex; gap:8px; margin-bottom:10px}
.lang-tools button{border:1px solid var(--line); background:var(--bg2);
  color:var(--dim); border-radius:9px; padding:6px 12px; font-size:12.5px}
.langlist{display:flex; flex-direction:column; gap:7px}
.langrow{display:flex; align-items:flex-start; gap:11px; padding:10px 12px;
  border:1px solid var(--line); border-radius:11px; background:var(--panel);
  text-align:left; width:100%; color:inherit}
.langrow .box{flex:0 0 auto; width:22px; height:22px; margin-top:1px;
  border-radius:6px; border:1.5px solid var(--faint); background:transparent;
  display:flex; align-items:center; justify-content:center;
  font-size:14px; color:transparent; line-height:1}
.langrow.on{border-color:var(--screen); background:rgba(70,150,230,.12)}
.langrow.on .box{border-color:var(--screen); background:var(--screen);
  color:#fff}
.langrow .meta{flex:1 1 auto; min-width:0}
.langrow .name{font-size:14px; color:var(--text); font-weight:600}
.langrow .name em{font-style:normal; color:var(--dim); font-weight:400;
  font-size:12.5px; margin-left:6px}
.langrow .vv{font-size:11.5px; color:var(--faint); margin-top:2px}
.langrow .usetxt{font-size:11.5px; color:var(--dim); line-height:1.45;
  margin-top:5px}
.langrow .usetxt::before{content:""}

/* ---------- views ---------- */
main{flex:1; display:flex; flex-direction:column; min-height:0}
.view{flex:1; display:flex; flex-direction:column; min-height:0}

/* ---------- home ---------- */
.home{padding:14px 12px 22px}
.home h2{font-size:12px; letter-spacing:.14em; text-transform:uppercase;
  color:var(--faint); margin:2px 0 8px; font-weight:600}
textarea{width:100%; min-height:148px; resize:vertical;
  background:var(--panel); color:var(--text);
  border:1px solid var(--line); border-radius:12px; padding:12px 13px;
  font-size:15px; line-height:1.5; font-family:inherit}
textarea::placeholder{color:var(--faint)}
.home-actions{display:flex; gap:8px; margin-top:10px; align-items:center}
.btn{border:1px solid var(--line); background:var(--panel); color:var(--text);
  padding:11px 16px; border-radius:11px; font-size:14px; font-weight:600}
.btn:active{transform:translateY(1px)}
.btn.primary{border-color:var(--play); background:rgba(55,200,120,.18);
  color:var(--text)}
.btn.ghost{background:transparent; color:var(--dim)}
.hint{font-size:12px; color:var(--faint); margin-left:auto; text-align:right}

.lib{margin-top:22px}
.lib-row{display:flex; align-items:center; gap:10px; padding:11px 12px;
  border:1px solid var(--line); border-radius:11px; background:var(--panel);
  margin-bottom:8px}
.lib-row .meta{flex:1; min-width:0}
.lib-row .meta b{display:block; font-size:14px; color:var(--text);
  white-space:nowrap; overflow:hidden; text-overflow:ellipsis}
.lib-row .meta small{font-size:11px; color:var(--faint)}
.iconbtn{border:1px solid var(--line); background:var(--bg2); border-radius:9px;
  padding:7px 10px; font-size:12px; color:var(--dim); font-weight:600}
.iconbtn.open{color:var(--screen); border-color:rgba(70,150,230,.4)}
.iconbtn.exp{color:var(--act); border-color:rgba(240,150,70,.4)}
.iconbtn.del{color:var(--exit); border-color:rgba(225,95,95,.4)}
.empty{color:var(--faint); font-size:13px; padding:14px 2px}

/* ---------- reader (the page follows the chosen theme) ---------- */
.reader-scroll{flex:1; overflow-y:auto; padding:18px 16px 24px;
  background:var(--page); -webkit-overflow-scrolling:touch;
  transition:background .25s}
.reader-title{font-size:12px; letter-spacing:.08em; color:var(--faint);
  text-transform:uppercase; margin:0 0 14px}
.doc{font-family:var(--read-font); font-size:var(--read);
  line-height:var(--read-lh); color:var(--page-text);
  max-width:var(--col); margin:0 auto;
  /* Room after the last word, so the LAST sentence can also travel to the
     top. Without it the document runs out, the scroll clamps, and the
     reading line drifts down the screen for the final few sentences, which
     is precisely the wandering the teleprompter rule exists to stop. The
     space is blank page, not content, and only ever seen at the very end. */
  padding-bottom:78vh}
.sent{padding:1px 2px; border-radius:5px; transition:background .12s,color .12s}
.sent.active{background:var(--sent); color:var(--sent-fg); font-weight:600;
  box-shadow:0 0 0 3px var(--sent)}
.sent.paused{background:var(--sent-soft); color:var(--page-text);
  box-shadow:0 0 0 3px var(--sent-soft)}
.sent .w{border-radius:4px}
/* the single word being read right now, highlighted in red */
body.wordhl .sent.active .w.now,
body.wordhl .sent.paused .w.now{
  background:var(--wordbg); color:var(--wordfg);
  padding:0 2px; margin:0 -2px;
  -webkit-box-decoration-break:clone; box-decoration-break:clone}
.sent:hover{cursor:pointer}
.focus .reader-title{display:none}
.focus .sent:not(.active):not(.paused){opacity:.45}

/* ---------- Markdown in the reader ----------
   Every size is an em, so the reader's own font-size setting still governs
   the page and a heading stays a RATIO of the body text rather than a fixed
   number of pixels that ignores it.

   Colour is deliberately restrained. Body text stays var(--page-text) and
   headings are told apart by size and weight, not by ink, because the
   sentence highlight is a solid yellow block and anything coloured
   underneath it would have to fight it. Links are blue, which is the one
   colour on the page the highlight never uses. */
.doc.md > :first-child{margin-top:0}
.doc.md > :last-child{margin-bottom:0}
.doc.md p{margin:0 0 .7em}
.doc.md h1,.doc.md h2,.doc.md h3,
.doc.md h4,.doc.md h5,.doc.md h6{
  color:var(--page-text); font-weight:700; line-height:1.25;
  margin:1.1em 0 .4em}
.doc.md h1{font-size:1.5em}
.doc.md h2{font-size:1.3em}
.doc.md h3{font-size:1.15em}
.doc.md h4,.doc.md h5,.doc.md h6{font-size:1em; letter-spacing:.03em}
.doc.md strong{font-weight:700}
.doc.md em{font-style:italic}
.doc.md del{opacity:.6}
.doc.md a{color:var(--screen); text-decoration:underline;
  text-underline-offset:.15em}
.doc.md ul,.doc.md ol{margin:0 0 .7em; padding-left:1.4em}
.doc.md li{margin:.15em 0}
.doc.md li > ul,.doc.md li > ol{margin:.15em 0}
.doc.md blockquote{margin:.7em 0; padding:.1em 0 .1em .9em;
  border-left:3px solid var(--line); color:var(--dim)}
.doc.md hr{border:0; border-top:1px solid var(--line); margin:1.1em 0}
.doc.md code{font-family:ui-monospace,"SF Mono",Menlo,Consolas,monospace;
  font-size:.88em; background:var(--panel); border:1px solid var(--line);
  border-radius:4px; padding:.05em .3em}
/* A fenced block scrolls sideways rather than forcing the whole page wide. */
.doc.md pre{margin:.7em 0; padding:.7em .8em; background:var(--panel);
  border:1px solid var(--line); border-radius:8px;
  overflow-x:auto; -webkit-overflow-scrolling:touch}
.doc.md pre code{background:none; border:0; padding:0; font-size:.85em;
  white-space:pre}
.doc.md img{max-width:100%; height:auto; border-radius:6px}
.doc.md table{border-collapse:collapse; margin:.7em 0; display:block;
  overflow-x:auto; font-size:.92em}
.doc.md th,.doc.md td{border:1px solid var(--line); padding:.3em .55em;
  text-align:left}
.doc.md th{font-weight:700}

/* ---------- the highlight, over the formatting ----------
   A sentence is a RANGE of spans, not one box, so the band is painted on the
   words AND on the spaces between them. Without the gaps lit the sentence
   would read as a row of separate yellow blocks with pale stripes between. */
.doc.md .w,.doc.md .g{padding:1px 0; border-radius:0;
  transition:background .12s,color .12s}
.doc.md .w.lit,.doc.md .g.lit{background:var(--sent); color:var(--sent-fg)}
.doc.md .w.litp,.doc.md .g.litp{background:var(--sent-soft); color:var(--page-text)}
/* Round only the two ends of the band, which are the first and last thing lit
   on each line, so it reads as one ribbon rather than many tiles. */
.doc.md .lit:not(.g) + .g.lit{border-radius:0}
.doc.md .w.lit:first-child,.doc.md .w.litp:first-child{
  border-top-left-radius:5px; border-bottom-left-radius:5px; padding-left:2px}
.doc.md .w.lit:last-child,.doc.md .w.litp:last-child{
  border-top-right-radius:5px; border-bottom-right-radius:5px; padding-right:2px}
/* the single word being spoken, same red as everywhere else */
body.wordhl .doc.md .w.lit.now,
body.wordhl .doc.md .w.litp.now{
  background:var(--wordbg); color:var(--wordfg);
  padding:0 2px; margin:0 -2px;
  -webkit-box-decoration-break:clone; box-decoration-break:clone}
/* THE COLOURS MUST NOT FIGHT THE FORMATTING. A link is blue and the band is
   yellow, and blue on yellow is unreadable, so a lit word takes the band's
   ink whatever its element wanted. The underline is moved onto the word span
   itself so it follows that colour instead of staying blue underneath. */
.doc.md a{text-decoration:none}
.doc.md a .w{text-decoration:underline; text-underline-offset:.15em}
/* An inline code chip has its own background and border; under the band they
   would box the highlight in. :has is a nicety - where it is missing the
   chip simply keeps its frame, which is untidy but perfectly readable. */
.doc.md code:has(.w.lit),.doc.md code:has(.w.litp){
  background:none; border-color:transparent}
.doc.md pre:has(.w.lit),.doc.md pre:has(.w.litp){border-color:var(--sent)}
/* Focus mode dims what is not being read, the same as it does for plain text */
.focus .doc.md .w:not(.lit):not(.litp),
.focus .doc.md .g:not(.lit):not(.litp){opacity:.45}

/* ---------- TEXT mode: plain white, no formatting at all ----------
   Not "formatting with the colours off": every heading back to body size,
   every chip, border, rule and underline gone, one ink. */
body.mode-text .doc.md,
body.mode-text .doc.md *{background:none !important; color:#fff !important;
  border-color:transparent !important; box-shadow:none !important;
  font-size:inherit !important; font-weight:400 !important;
  font-style:normal !important; text-decoration:none !important;
  opacity:1 !important}
body.mode-text .doc.md hr{border-top:1px solid #444 !important}
body.mode-text .doc.md img{display:none}

/* ---------- EDIT mode edits the MARKDOWN SOURCE ----------
   Not the rendered HTML. Editing the rendering would silently throw the
   formatting away the moment it was committed, because what came back out of
   the page would be flat text with the markers already consumed. */
.md-edit{display:none; width:100%; min-height:60vh; box-sizing:border-box;
  background:var(--page); color:var(--page-text); border:1px solid var(--line);
  border-radius:8px; padding:10px 12px; resize:none; outline:none;
  font-family:ui-monospace,"SF Mono",Menlo,Consolas,monospace;
  font-size:calc(var(--read) * .8); line-height:1.55;
  caret-color:var(--tune); -webkit-text-size-adjust:100%}
body.mode-edit .md-edit.on{display:block}
body.mode-edit .md-edit.on ~ .doc,
body.mode-edit .doc.mdhidden{display:none}

/* ---------- transport / controls ---------- */
.controls{border-top:1px solid var(--line); background:var(--bg2);
  padding:10px 12px calc(10px + env(safe-area-inset-bottom))}
.progress{display:flex; align-items:center; gap:10px; margin-bottom:9px}
.bar{flex:1; height:5px; border-radius:3px; background:var(--line); overflow:hidden}
.bar > i{display:block; height:100%; width:0;
  background:linear-gradient(90deg,var(--teal),var(--play))}
/* The counter is a button now. It says how far in you are and how long is
   left, and pressing it clears the session and puts the time back to zero.
   That is what replaced the small cross in the corner: a wide target that
   says what it does, instead of a tiny one that looked like danger. */
.counter{font-size:12px; color:var(--dim); min-width:108px; text-align:right;
  font-variant-numeric:tabular-nums; border:1px solid transparent;
  background:transparent; border-radius:9px; padding:5px 8px; line-height:1.2}
.counter b{color:var(--text); font-weight:600; margin-left:5px}
.counter:active{border-color:var(--line); color:var(--text)}

/* An empty paste box is a paste button the size of the screen. When there is
   text in it, it goes back to being an ordinary box. */
#pasteBox.port{border-style:dashed; border-color:var(--tune);
  background:color-mix(in srgb, var(--tune) 6%, var(--panel)); cursor:copy}

.transport{display:flex; align-items:center; justify-content:center; gap:7px}
.tbtn{border:1px solid var(--line); background:var(--panel); border-radius:12px;
  width:48px; height:46px; font-size:17px; display:flex; align-items:center;
  justify-content:center; color:var(--text)}
.tbtn.play{width:70px; border-color:var(--play); background:rgba(55,200,120,.18);
  font-size:20px}
.tbtn.on{border-color:var(--play); background:rgba(55,200,120,.18)}
.tbtn.aa{font-family:Georgia,serif; font-weight:700; font-size:18px}
.tbtn:active{transform:translateY(1px)}

.tune{display:flex; gap:8px; margin-top:9px; flex-wrap:wrap; justify-content:center}
.stepper{display:flex; align-items:center; gap:2px; border:1px solid var(--line);
  border-radius:10px; background:var(--panel); padding:2px; flex:1 1 132px;
  min-width:118px}
.stepper > span{flex:1; text-align:center; font-size:12px; color:var(--dim);
  font-variant-numeric:tabular-nums}
.stepper > span b{color:var(--text); font-weight:600}
.stepper button{width:34px; height:32px; border:none; background:transparent;
  color:var(--tune); font-size:16px; border-radius:8px; font-weight:700}
.stepper button:active{background:var(--line)}
.stepper.size button{color:var(--act)}
.stepper.size .a-sm{font-size:12px} .stepper.size .a-lg{font-size:18px}
.volwrap{flex:1 1 100%; display:flex; align-items:center; gap:9px;
  border:1px solid var(--line); border-radius:10px; background:var(--panel);
  padding:7px 11px}
.volwrap label{font-size:12px; color:var(--dim); min-width:46px}
.volwrap input[type=range]{flex:1; accent-color:var(--tune)}
.volwrap .pct{font-size:12px; color:var(--text); min-width:40px; text-align:right;
  font-variant-numeric:tabular-nums}

.toggles{display:flex; gap:8px; margin-top:9px; justify-content:center}
.toggle{flex:1; border:1px solid var(--line); background:var(--panel);
  border-radius:10px; padding:8px 6px; font-size:12px; color:var(--dim);
  text-align:center; font-weight:600}
.toggle.on{border-color:var(--mode); background:rgba(190,130,235,.16);
  color:var(--text)}

.status{display:none}

/* ---------- reading-settings sheet (the "Aa" panel) ---------- */
.backdrop{position:fixed; inset:0; background:rgba(0,0,0,.5); z-index:40;
  opacity:0; pointer-events:none; transition:opacity .2s}
.backdrop.show{opacity:1; pointer-events:auto}
.sheet{position:fixed; left:0; right:0; bottom:0; z-index:45;
  background:var(--bg2); border-top:1px solid var(--line);
  border-radius:18px 18px 0 0; padding:14px 16px calc(18px + env(safe-area-inset-bottom));
  transform:translateY(110%); transition:transform .26s cubic-bezier(.2,.7,.2,1);
  box-shadow:0 -10px 40px rgba(0,0,0,.45); max-height:82vh; overflow-y:auto}
.sheet.show{transform:translateY(0)}
.sheet .grab{width:38px; height:4px; border-radius:2px; background:var(--line);
  margin:2px auto 14px}
/* Every group is a card with its own tint and a coloured edge, so scrolling
   the sheet you find the block you want by colour before you have read a word
   of it. The tint is a flat wash laid over the panel colour rather than a
   blend function, so it behaves the same on old Android webviews and in all
   three themes. */
.sheet .group{margin-bottom:14px; padding:13px 13px 15px;
  border:1px solid var(--line); border-left:3px solid var(--gc,var(--line));
  border-radius:14px; background:var(--panel)}
.sheet h3{margin:0 0 11px; font-size:11px; letter-spacing:.14em;
  text-transform:uppercase; color:var(--gc,var(--faint)); font-weight:700;
  display:flex; align-items:center; gap:9px}
.sheet h3::after{content:""; flex:1; height:1px; background:var(--line)}
.group.g-play{--gc:var(--play);
  background:linear-gradient(rgba(55,200,120,.07),rgba(55,200,120,.07)),var(--panel)}
.group.g-text{--gc:var(--act);
  background:linear-gradient(rgba(240,150,70,.07),rgba(240,150,70,.07)),var(--panel)}
.group.g-colour{--gc:var(--mode);
  background:linear-gradient(rgba(190,130,235,.07),rgba(190,130,235,.07)),var(--panel)}
.group.g-voice{--gc:var(--screen);
  background:linear-gradient(rgba(70,150,230,.07),rgba(70,150,230,.07)),var(--panel)}
.group.g-groq{--gc:#e879f9}
.group.g-keys{--gc:#fbbf24}
.keylist{display:flex; flex-direction:column; gap:6px; margin-top:4px}
.keyrow{display:flex; align-items:center; gap:8px; padding:8px 10px;
  border:1px solid var(--line); border-radius:10px; background:var(--panel)}
.keyrow .kp{flex:0 0 auto; font-size:9px; letter-spacing:.08em;
  text-transform:uppercase; color:var(--faint); min-width:62px}
.keyrow .km{flex:0 0 auto; font-family:ui-monospace,monospace; font-size:11px;
  color:var(--text)}
.keyrow .kl{flex:1; min-width:0; font-size:11px; color:var(--faint);
  overflow:hidden; text-overflow:ellipsis; white-space:nowrap}
.keyrow .ks{flex:0 0 auto; font-size:9px; letter-spacing:.06em;
  text-transform:uppercase; color:var(--good)}
.keyrow.dead{opacity:.55}
.keyrow.dead .ks{color:var(--bad)}
.keyrow .kn{flex:0 0 auto; font-size:10px; color:var(--faint); min-width:16px}
.group.g-adv{--gc:var(--teal);
  background:linear-gradient(rgba(63,185,200,.06),rgba(63,185,200,.06)),var(--panel)}
/* inside a card the rows sit on the sheet colour, one step back from the card,
   so a row still reads as a row and not as part of the tint */
.sheet .group .rowctl,
.sheet .group .langrow,
.sheet .group .exp,
.sheet .group .keybox,
.sheet .group .gem-usage,
.sheet .group .chip{background:var(--bg2)}
.sheet .group .chip.on{background:rgba(70,150,230,.16)}
.sheet .group .chip.theme-day{background:#ffffff}
.sheet .group .chip.theme-sepia{background:#f4ead4}
.sheet .group .chip.theme-night{background:#0c0f16}
.sheet .group > .wsub:first-of-type{margin-top:0}
.chips{display:flex; gap:8px; flex-wrap:wrap}
/* word highlight colour + intensity pickers */
.wcolor{margin-top:12px}
.wsub{font-size:11px; color:var(--dim); letter-spacing:.06em;
  text-transform:uppercase; margin:12px 0 7px}
.wsub:first-child{margin-top:0}
.rgbrow{display:flex; align-items:center; gap:10px}
.rgbsw{flex:0 0 auto; width:30px; height:30px; border-radius:7px;
  border:1px solid var(--line)}
.rgbrow label{display:flex; align-items:center; gap:5px; font-size:12px;
  color:var(--dim)}
.rgbrow input{width:58px; padding:8px 6px; border-radius:8px;
  border:1px solid var(--line); background:var(--bg2); color:var(--text);
  font-size:15px; text-align:center; -moz-appearance:textfield}
.rgbrow input::-webkit-outer-spin-button,
.rgbrow input::-webkit-inner-spin-button{-webkit-appearance:none; margin:0}
.rgbauto{margin-left:2px; border:1px solid var(--line); background:var(--bg2);
  color:var(--dim); border-radius:8px; padding:7px 12px; font-size:12.5px}
.rgbauto.on{color:var(--text); border-color:var(--screen)}
.wprev{margin-top:16px; font-size:13px; color:var(--dim)}
.docprev{display:block; margin-top:6px; font-size:15px; color:var(--page-text)}
.sentprev{background:var(--sent); color:var(--sent-fg); padding:2px 6px;
  border-radius:6px}
.wprevword{background:var(--wordbg); color:var(--wordfg); padding:1px 4px;
  border-radius:4px; -webkit-box-decoration-break:clone;
  box-decoration-break:clone}
.chip{flex:1 1 0; min-width:64px; border:1px solid var(--line);
  background:var(--panel); color:var(--dim); border-radius:11px;
  padding:11px 8px; font-size:13px; font-weight:600; text-align:center}
.chip.on{border-color:var(--screen); background:rgba(70,150,230,.16);
  color:var(--text)}
.chip.f-serif{font-family:Georgia,"Times New Roman",serif}
.chip.f-sans{font-family:system-ui,sans-serif}
.chip.f-book{font-family:"Iowan Old Style","Palatino Linotype",Palatino,Georgia,serif}
.chip.f-mono{font-family:ui-monospace,"DejaVu Sans Mono",Menlo,Consolas,monospace}
.chip.theme-day{background:#ffffff;color:#1c2026;border-color:#d8dbe2}
.chip.theme-sepia{background:#f4ead4;color:#43392a;border-color:#d6c5a1}
.chip.theme-night{background:#0c0f16;color:#cdd0d6;border-color:#272d3b}
.chip.theme-day.on,.chip.theme-sepia.on,.chip.theme-night.on{
  outline:2px solid var(--screen); outline-offset:1px}
/* ---------- v9: multi-select + delete-all toolbar for the lists ---------- */
.listbar{display:flex; gap:8px; align-items:center; margin:0 0 10px;
  flex-wrap:wrap}
.minibtn{border:1px solid var(--line); background:var(--panel); color:var(--dim);
  padding:8px 12px; border-radius:9px; font-size:12.5px; font-weight:600}
.minibtn:active{transform:translateY(1px)}
.minibtn.on{color:var(--text); border-color:var(--screen);
  background:rgba(70,150,230,.16)}
.minibtn.danger{color:var(--exit); border-color:rgba(225,95,95,.4)}
.minibtn.hidden{display:none !important}
.selcount{margin-left:auto; font-size:12px; color:var(--faint);
  font-variant-numeric:tabular-nums}
.selbox{width:24px; height:24px; flex:0 0 auto; border-radius:7px;
  border:2px solid var(--line); display:none; align-items:center;
  justify-content:center; color:#fff; font-size:15px; font-weight:800}
#libList.selecting .selbox, #offList.selecting .selbox{display:flex}
.selbox.sel{background:var(--screen); border-color:var(--screen)}
/* in select mode the per-row action buttons step aside; the whole row toggles */
#libList.selecting .iconbtn, #offList.selecting .iconbtn{display:none}
#libList.selecting .lib-row, #offList.selecting .off-row{cursor:pointer}
.rowctl{display:flex; align-items:center; gap:10px;
  border:1px solid var(--line); background:var(--panel); border-radius:11px;
  padding:6px 8px}
.rowctl .lab{flex:1; font-size:13px; color:var(--text)}
.rowctl button{width:42px; height:38px; border:1px solid var(--line);
  background:var(--bg2); border-radius:9px; color:var(--act); font-weight:700;
  font-size:16px}
.rowctl .val{min-width:30px; text-align:center; font-size:13px; color:var(--text);
  font-variant-numeric:tabular-nums}
.rowctl .a-sm{font-size:13px} .rowctl .a-lg{font-size:19px}
.exp{display:flex; align-items:flex-start; gap:12px; border:1px solid var(--line);
  background:var(--panel); border-radius:11px; padding:12px 12px}
.exp .check{width:26px; height:26px; flex:0 0 auto; border-radius:7px;
  border:2px solid var(--line); display:flex; align-items:center;
  justify-content:center; color:transparent; font-size:16px; font-weight:800}
.exp.on .check{background:var(--wordbg); border-color:var(--wordbg); color:#fff}
.exp .txt b{display:block; font-size:13px; color:var(--text)}
.exp .txt small{font-size:11.5px; color:var(--faint); line-height:1.4}
.exp .tag{font-size:9.5px; letter-spacing:.1em; color:var(--act);
  border:1px solid var(--act); border-radius:5px; padding:1px 5px; margin-left:6px;
  vertical-align:middle; text-transform:uppercase}
.synctop{display:flex; justify-content:space-between; align-items:center;
  margin:14px 2px 4px; font-size:13px; color:var(--text)}
.synctop em{font-style:normal; color:var(--faint); font-size:11px;
  letter-spacing:.04em}
.synctop .val{color:var(--act); font-variant-numeric:tabular-nums}
#syncRange{width:100%; accent-color:var(--act)}
.syncends{display:flex; justify-content:space-between; font-size:11px;
  color:var(--faint); margin-top:2px}
/* One X and nothing else. The version sits in the corner beside it, so it
   costs no row of its own. */
/* The head carries three things now: the two toggles on the left, the X in
   the middle, and the version in the corner. The X stays centred because it
   is the thing a thumb reaches for blind. */
.headtogs{position:absolute; left:16px; top:50%; transform:translateY(-50%);
  display:flex; gap:6px}
.htog{border:1px solid var(--line); background:var(--panel);
  color:var(--text); border-radius:11px; padding:9px 11px;
  font-size:11px; font-weight:700; letter-spacing:.06em; line-height:1}
.htog.sp{border-color:var(--tune);
  background:color-mix(in srgb, var(--tune) 16%, var(--panel))}
.htog.auto b{font-size:10px}
.sheet-head{position:sticky; top:0; z-index:6; background:var(--bg2);
  display:flex; align-items:center; justify-content:center;
  margin:0 -16px 12px; padding:2px 16px 10px; border-bottom:1px solid var(--line)}
.sheet-ver{position:absolute; right:16px; top:50%; transform:translateY(-60%);
  font-size:11px; color:var(--faint); letter-spacing:.02em}
/* One X, in the middle, pinned to the top of the sheet. It does not scroll
   away and it says nothing, because there is nothing to say. */
.sheet-x{flex:0 0 auto; width:46px; height:46px; margin:0 0 6px; padding:0;
  border:1px solid var(--line); background:var(--panel); color:var(--dim);
  border-radius:50%; font-size:19px; line-height:1;
  display:flex; align-items:center; justify-content:center}
.sheet-x:active{color:var(--text); border-color:var(--tune)}

.toast{position:fixed; left:50%; bottom:calc(18px + env(safe-area-inset-bottom));
  transform:translateX(-50%); background:var(--panel); color:var(--text);
  border:1px solid var(--line); border-radius:10px; padding:10px 16px;
  font-size:13px; z-index:60; box-shadow:0 6px 24px rgba(0,0,0,.5);
  max-width:90%; opacity:0; transition:opacity .2s; pointer-events:none}
.toast.show{opacity:1}

/* ---------- v2: tabs, offline reader, help ---------- */
.topbar{display:flex; align-items:center; gap:6px; margin-bottom:8px}
nav.tabs{display:flex; gap:6px; flex:1}
.tab{border:1px solid var(--line); background:var(--panel); color:var(--dim);
  border-radius:11px; padding:7px 13px; font-size:14px; font-weight:600}
.tab.on{color:var(--text); border-color:var(--screen);
  background:rgba(70,150,230,.14)}
body:not(.inreader):not(.onhome) .voices{display:none}
.sub{color:var(--dim); font-size:13.5px; line-height:1.5; margin:-2px 0 12px}
.searchbox{width:100%; box-sizing:border-box; border:1px solid var(--line);
  background:var(--panel); color:var(--text); border-radius:11px;
  padding:11px 14px; font-size:15px; margin-bottom:12px}
.off-row{display:flex; align-items:center; gap:10px; border:1px solid var(--line);
  background:var(--panel); border-radius:12px; padding:12px; margin-bottom:10px}
.off-row .ometa{flex:1; min-width:0}
.off-row .ometa b{display:block; font-size:15px; white-space:nowrap;
  overflow:hidden; text-overflow:ellipsis}
.off-row .ometa small{color:var(--faint); font-size:12px}
.off-row .osum{color:var(--dim); font-size:12.5px; margin-top:3px;
  display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden}
.off-row.pending{opacity:.55}
.seek{flex:1; accent-color:var(--play)}
.help h3{margin:18px 0 6px; font-size:16px; color:var(--text)}
.help p{color:var(--dim); font-size:14px; line-height:1.62; margin:6px 0}
.help code{background:var(--panel); border:1px solid var(--line);
  border-radius:6px; padding:1px 6px; font-size:13px; color:var(--text)}
.help .lead{color:var(--text)}
.keybox{border:1px solid var(--line); background:var(--panel);
  border-radius:11px; padding:12px}
.keyhead{font-weight:600; display:flex; justify-content:space-between;
  align-items:center; gap:8px}
.keystate{font-size:12px; color:var(--faint)}
.keystate.ok{color:#39d98a}
.keybtn{display:inline-block; margin-top:10px; margin-right:8px;
  border:1px solid var(--line); background:var(--bg2); color:var(--text);
  border-radius:10px; padding:8px 14px; font-size:14px; cursor:pointer}
.keybtn.ghost{color:var(--dim)}
.keyerr{color:#ff6b6b; font-size:13px; margin-top:9px; min-height:1px}
.lib-row .lsum{color:var(--dim); font-size:12px; margin-top:2px;
  display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden}

/* ---------- v3: bottom player, corner gear, spend readout ---------- */
#offlineReaderView{position:relative}
.off-gear{position:absolute; top:10px; right:12px; z-index:6; width:42px;
  height:42px; border-radius:50%; border:1px solid var(--line);
  background:var(--panel); color:var(--text); font-size:19px; line-height:1}
.off-controls{padding-bottom:16px}
/* v3: three controls, not two. The two pauses live together on the left
   because they are the same idea at two scales - silence between words and
   silence between sentences - and the hand learns them as a pair. Speed sits
   alone on the right. Play stays in the middle, where it always was. */
.yt-bar{display:flex; align-items:center; justify-content:center; gap:2px;
  margin-top:4px}
.ytgroup{display:flex; align-items:center; gap:2px}
/* a hairline between the two pauses, so the pair reads as two controls and
   not one wide smear of buttons */
.ytgroup .ytstep + .ytstep{border-left:1px solid var(--line); padding-left:3px;
  margin-left:1px}
/* Named ytstep, not stepper: an older dead .stepper rule is still in this
   sheet and would drop a panel border round these. */
.ytstep{display:flex; align-items:center; gap:0}
.yt-mini{width:27px; height:46px; border:none; background:transparent;
  color:var(--dim); font-size:20px; line-height:1; padding:0}
.yt-mini:active{color:var(--text)}
/* the number is a button too: tap it to send that control back to its
   resting value, 1.00 for speed and 0.00 for the word gap */
.yt-num{min-width:39px; display:flex; flex-direction:column; align-items:center;
  line-height:1.1; border:none; background:transparent; padding:2px 0}
.yt-num:active b{color:var(--tune)}
.yt-num b{font-size:13.5px; font-weight:600; color:var(--text);
  font-variant-numeric:tabular-nums}
.yt-num i{font-size:7.5px; font-style:normal; letter-spacing:.06em;
  text-transform:uppercase; color:var(--faint); margin-top:3px}
/* play/pause: brightest, flat, no circle or coloured fill */
.yt-play{width:52px; height:52px; border:none; background:transparent;
  color:var(--text); display:flex; align-items:center; justify-content:center;
  padding:0; margin:0 2px}
.yt-play svg{width:38px; height:38px; display:block}
.yt-play:active{opacity:.55}
/* previous/next: filled, a step softer than the play */
.yt-skip{width:54px; height:54px; border:none; background:transparent;
  color:var(--text); opacity:.85; display:flex; align-items:center;
  justify-content:center; padding:0}
.yt-skip svg{width:30px; height:30px; display:block}
.yt-skip:active{opacity:.5}
/* outer controls (full screen, last): dimmer, flat, like shuffle/repeat */
.yt-side{min-width:44px; height:50px; padding:0 6px; border:none;
  background:transparent; color:var(--dim); font-size:18px; line-height:1}
.yt-side.fs{font-size:20px}
.yt-side.on{color:var(--text)}
.gem-usage{border:1px solid var(--line); background:var(--panel);
  border-radius:11px; padding:11px; margin-top:12px; font-size:13px; color:var(--dim)}
.gem-usage b{color:var(--text)}
.gem-usage .note{margin-top:6px; font-size:11.5px; color:var(--faint); line-height:1.5}
.gem-reset{margin-top:8px; border:1px solid var(--line); background:var(--bg2);
  color:var(--dim); border-radius:9px; padding:6px 12px; font-size:12.5px}
.timing-help{font-size:11.5px; color:var(--faint); line-height:1.5; margin-top:8px}

/* ---------- v4: global gear, player jump, fullscreen, paste ---------- */
/* gear is a plain icon now, no circle around it */
.gear-corner{position:absolute; top:calc(6px + env(safe-area-inset-top));
  right:10px; z-index:30; width:34px; height:34px; border:none;
  background:transparent; color:var(--dim); font-size:22px; line-height:1;
  padding:0}
.gear-corner:active{color:var(--text)}
/* the X reset: a bare icon in the tab row, no circle */
.tab-x{border:none; background:transparent; color:var(--dim); font-size:19px;
  line-height:1; padding:6px 8px; margin-left:2px}
.tab-x:active{color:var(--text)}
/* with zero languages the voice strip is gone, so the gear drops onto the tab
   row line; reserve room on the right so tabs never slide under it */
body.novoice nav.tabs{padding-right:40px}
/* The tab row can go, leaving only the gear. Nothing else is lost: the reader
   is where the app already is, and the gear brings the row back. */
body.notabs .topbar{display:none !important}
/* The floating P has no business sitting on top of Settings. It would cover
   the panel and, now that a tap outside closes the sheet, a stray press of it
   would both close Settings and paste. */
body.sheetopen .floatp{display:none !important}
/* The strip switched off by hand. Same result as having no voices at all,
   so it borrows the same rule and gives the reader back that whole band. */
body.nobar .voices{display:none !important}
body.nobar nav.tabs{padding-right:40px}
.tab.player{color:var(--play); border-color:var(--play); display:none}
body.hassession .tab.player{display:block}
.paste-top{display:flex; gap:8px; margin-bottom:8px}
.pastebtn{border:1px solid var(--line); background:var(--panel); color:var(--text);
  border-radius:11px; padding:9px 16px; font-size:14.5px; font-weight:600}
.fs-btn{position:sticky; top:0; z-index:5; float:left; width:40px; height:40px;
  margin:0 8px 4px 0; border-radius:50%; border:1px solid var(--line);
  background:var(--panel); color:var(--text); font-size:17px; line-height:1;
  opacity:1; transition:opacity .25s; }
.fs-btn.faded{opacity:0; pointer-events:none}
/* ---------- the two engines ----------
   Settings used to be one long column with every knob in it. Two engines
   would have made that twice as long, so instead there are two buttons at the
   top and the cards below them are filtered: a card marked for one engine is
   simply not there while the other is chosen. Anything unmarked - speed, the
   pauses, the text, the colours - belongs to both and always shows. */
.engtabs{display:flex; gap:8px; margin:2px 0 14px; align-items:stretch}
/* The language button is an engtab like the others, but it names a state
   rather than a destination, so it is always lit. */
#langBtn{min-width:52px}
#langBtn.on b{letter-spacing:.06em}
.engtab{flex:1; border:1px solid var(--line); background:var(--panel);
  color:var(--dim); border-radius:13px; padding:11px 8px 9px; text-align:center;
  line-height:1.25}
.engtab b{display:block; font-size:15px; font-weight:700}
.engtab small{display:block; font-size:10.5px; color:var(--faint);
  margin-top:3px; letter-spacing:.02em}
.engtab.on{color:var(--text); border-color:var(--tune);
  background:color-mix(in srgb, var(--tune) 12%, var(--panel))}
.engtab.on small{color:var(--dim)}
.group.g-sp{--gc:#7dd3fc}
/* One row per voice: a radio, a name, a detail line, and a play button that
   speaks the voice's own name. Nothing to page through, nothing to hunt. */
.radios{display:flex; flex-direction:column; margin:2px 0 14px}
.rrow{display:flex; align-items:center; gap:12px; padding:12px 4px;
  border:none; background:none; width:100%; text-align:left;
  border-bottom:1px solid color-mix(in srgb, var(--line) 55%, transparent)}
.rrow:last-child{border-bottom:none}
.rdot{flex:0 0 auto; width:22px; height:22px; border-radius:50%;
  border:2px solid var(--faint); position:relative}
.rrow.on .rdot{border-color:var(--tune)}
.rrow.on .rdot::after{content:""; position:absolute; inset:4px;
  border-radius:50%; background:var(--tune)}
.rtxt{flex:1; min-width:0}
.rtxt b{display:block; font-size:15px; color:var(--text); font-weight:600}
.rtxt small{display:block; font-size:11.5px; color:var(--faint); margin-top:3px}
.rplay{flex:0 0 auto; width:40px; height:40px; padding:0; border-radius:50%;
  border:1px solid var(--line); background:transparent; color:var(--tune);
  font-size:13px; line-height:1}
.crogrid{display:flex; flex-direction:column; gap:8px; margin:2px 0 6px}
.crorow{display:flex; align-items:center; gap:10px; padding:10px 12px;
  border:1px solid var(--line); border-radius:12px; background:var(--panel)}
.crorow.on{box-shadow:0 0 0 2px var(--tune);
  background:color-mix(in srgb, var(--tune) 12%, var(--panel))}
.crorow .cropick{flex:1; min-width:0; text-align:left; background:none;
  border:none; padding:0; color:inherit}
.crorow .cropick b{display:block; font-size:14px; color:var(--text);
  font-weight:600}
.crorow .cropick small{display:block; font-size:10.5px; color:var(--faint);
  margin-top:2px}
.crorow .croplay{flex:0 0 auto; width:38px; height:38px; padding:0;
  border:1px solid var(--line); border-radius:50%; background:transparent;
  color:var(--tune); font-size:14px; line-height:1}
.crorow .croplay:active{border-color:var(--tune)}
.accrow{display:flex; gap:8px; margin-bottom:12px}
.accbtn{flex:1; border:1px solid var(--line); background:var(--panel);
  color:var(--dim); border-radius:11px; padding:10px 8px; font-size:14px;
  font-weight:600}
.accbtn.on{color:var(--text); border-color:var(--tune);
  background:color-mix(in srgb, var(--tune) 12%, var(--panel))}
/* Sex is read by colour before a name is read at all: deep pink for the
   women, deep blue for the men. The colour IS the frame. No stripe, no extra
   element, nothing added to the box that was already there, because the
   border was sitting there doing nothing anyway.

   Selection is then shown by the gold tint inside plus a gold ring drawn
   outside the frame, so the two meanings sit one within the other rather
   than fighting over the same edge. */
:root{--femme:#8E3358; --homme:#274C7C}
.spgrid{display:grid; grid-template-columns:1fr 1fr; gap:7px; margin:10px 0 4px}
.spcell{border:2px solid var(--line); background:var(--panel);
  border-radius:11px; padding:9px 10px; text-align:left; line-height:1.3}
.spcell.f{border-color:var(--femme)}
.spcell.m{border-color:var(--homme)}
.spcell b{display:block; font-size:14px; color:var(--text); font-weight:600}
.spcell small{display:block; font-size:10.5px; color:var(--faint); margin-top:2px}
.spcell.on{background:color-mix(in srgb, var(--tune) 12%, var(--panel));
  box-shadow:0 0 0 2px var(--tune)}
/* Two things in one cell, with their own hit areas: the box on the left says
   whether this voice appears on top, the rest of the cell chooses it and
   plays it. */
.spcell{display:flex; align-items:center; gap:10px}
.spbox{flex:0 0 auto; width:26px; height:26px; border-radius:7px;
  border:2px solid var(--line); background:transparent; color:var(--tune);
  display:flex; align-items:center; justify-content:center; font-size:16px;
  line-height:1; padding:0}
.spbox.ticked{border-color:var(--tune);
  background:color-mix(in srgb, var(--tune) 18%, transparent)}
.spname{flex:1; min-width:0; text-align:left; background:transparent;
  border:none; padding:0; color:inherit}
.spname b{display:block; font-size:14px; color:var(--text); font-weight:600;
  white-space:nowrap; overflow:hidden; text-overflow:ellipsis}
.spname small{display:block; font-size:10.5px; color:var(--faint); margin-top:2px}
/* the same frame on the four buttons at the top of the reader */
.voice.f{border-color:var(--femme)}
.voice.m{border-color:var(--homme)}
.voice.on.f, .voice.on.m{box-shadow:0 0 0 2px var(--tune)}
/* paging: two arrows with the count between them, then a row of numbers */
.setbar{display:flex; align-items:center; gap:8px; margin:10px 0 8px}
.setarrow{flex:0 0 auto; width:52px; height:40px; border:1px solid var(--line);
  background:var(--panel); color:var(--text); border-radius:11px; font-size:19px;
  line-height:1; padding:0}
.setarrow:disabled{color:var(--faint); opacity:.4}
.setarrow:active:not(:disabled){border-color:var(--tune)}
.setcount{flex:1; text-align:center; font-size:13.5px; color:var(--dim);
  font-variant-numeric:tabular-nums}
.setcount b{color:var(--text); font-weight:600}
.setnums{display:flex; flex-wrap:wrap; gap:6px; margin-bottom:4px}
.setnum{min-width:34px; height:34px; border:1px solid var(--line);
  background:var(--panel); color:var(--dim); border-radius:9px; font-size:13px;
  padding:0 6px; font-variant-numeric:tabular-nums}
.setnum.on{color:var(--text); border-color:var(--tune);
  background:color-mix(in srgb, var(--tune) 14%, var(--panel))}
.setnum:active{color:var(--text)}
.setlegend{display:flex; gap:14px; font-size:11px; color:var(--faint);
  margin:2px 0 10px; align-items:center}
/* the first row: two switches and the sentence pause, sharing the width */
.toprow{display:flex; flex-wrap:wrap; gap:8px; align-items:center}
.toprow .chip{flex:1 1 auto}
.setstep{flex:0 0 auto; border:1px solid var(--line); border-radius:12px;
  padding:0 2px; background:var(--panel)}
/* The three modes, in the space the two pauses used to take. Same small
   uppercase lettering as the labels under the steppers, because they sit in
   the same row and should read as the same kind of thing. */
.modes{gap:2px}
.modebtn{border:none; background:transparent; color:var(--faint);
  font-size:8.5px; letter-spacing:.09em; text-transform:uppercase;
  padding:10px 9px; line-height:1; border-radius:8px}
.modebtn.on{color:var(--text); font-weight:700}
.modebtn:active{color:var(--dim)}
/* TEXT mode: nothing but the words. No sentence tinting, no word marker, no
   colour at all, so it can simply be read with the eye. */
body.mode-text .sent, body.mode-text .sent *{background:none !important;
  color:#fff !important; box-shadow:none !important; border-radius:0 !important}
body.mode-text .doc, body.mode-text #offDoc{color:#fff; padding-bottom:78vh}
/* EDIT mode: the text becomes a real editable field. */
body.mode-edit .reader-scroll .doc{outline:none; caret-color:var(--tune);
  -webkit-user-select:text; user-select:text; white-space:pre-wrap}
body.mode-edit .sent, body.mode-edit .sent *{background:none !important;
  color:#fff !important; box-shadow:none !important}
body.mode-edit .yt-play{opacity:.3; pointer-events:none}
body.mode-text .yt-play{opacity:.3; pointer-events:none}
.setlegend i{display:inline-block; width:12px; height:12px; border-radius:4px;
  margin-right:5px; vertical-align:-2px; border:2px solid; background:none}
.spstate{font-size:12px; color:var(--faint); margin:8px 0 2px; line-height:1.5}
.deadhead{font-size:11px; letter-spacing:.08em; text-transform:uppercase;
  color:var(--faint); margin:14px 0 6px}
.deadrow{display:flex; align-items:center; gap:8px; padding:8px 10px;
  border:1px solid var(--line); border-radius:10px; margin-bottom:6px;
  background:var(--panel)}
.deadrow .dmeta{flex:1; min-width:0; line-height:1.3}
.deadrow .dname{font-size:13.5px; color:var(--text); font-weight:600;
  white-space:nowrap; overflow:hidden; text-overflow:ellipsis}
.deadrow .dsub{font-size:10.5px; color:var(--faint); font-variant-numeric:tabular-nums}
.deadbtn{border:1px solid var(--line); background:transparent; color:var(--dim);
  border-radius:8px; padding:6px 10px; font-size:12px; flex:0 0 auto}
.deadbtn.warn{color:#f87171; border-color:#f8717155}
.deadbtn:active{color:var(--text)}
.spstate b{color:var(--text); font-weight:600}
.spstate.bad{color:#f87171}
/* the fullscreen pair: a button on the player strip to go in, and a faint
   one in the corner to come back out, which is the only thing on screen once
   everything else has gone */
.fsbtn{flex:0 0 auto; width:38px; height:32px; border:1px solid var(--line);
  background:var(--panel); color:var(--dim); border-radius:9px; padding:0;
  display:flex; align-items:center; justify-content:center}
.fsbtn svg{width:17px; height:17px; display:block}
.fsbtn:active{color:var(--text); border-color:var(--tune)}
/* ---------- the floating P ----------
   Dragged anywhere, pressed to paste. It sits above everything because the
   whole point is that it is reachable without looking for it. */
.floatp{position:fixed; z-index:80; width:56px; height:56px; border-radius:50%;
  border:1px solid var(--line); background:var(--panel); color:var(--text);
  font-size:23px; font-weight:600; line-height:1; padding:0; display:none;
  align-items:center; justify-content:center; touch-action:none;
  box-shadow:0 3px 14px rgba(0,0,0,.45); opacity:.88}
.floatp svg{width:24px; height:24px; display:block}
/* in full screen it is the only control on the screen, so it earns its keep */
body.fullread .floatp{opacity:.72; background:rgba(127,127,127,.16);
  border-color:transparent}
body.fullread .floatp:active{opacity:1}
body.hasfloat .floatp{display:flex}
.floatp:active{border-color:var(--tune); opacity:1}
.floatp.moving{opacity:1; border-color:var(--tune); transform:scale(1.06)}

/* The full-screen floater. Same size, same weight, same drag, so the two read
   as a pair rather than as two unrelated buttons that happen to be round. */
.floatf{position:fixed; z-index:80; width:56px; height:56px; border-radius:50%;
  border:1px solid var(--line); background:var(--panel); padding:0; display:none;
  align-items:center; justify-content:center; touch-action:none;
  box-shadow:0 3px 14px rgba(0,0,0,.45); opacity:.88}
.floatf .fdot{width:14px; height:14px; border-radius:50%; background:#fff;
  display:block; transition:width .12s, height .12s}
body.hasfloatf .floatf{display:flex}
.floatf:active{border-color:var(--tune); opacity:1}
.floatf.moving{opacity:1; border-color:var(--tune); transform:scale(1.06)}
/* in full screen it dims with everything else, and the dot shrinks so the
   ring reads as "you are inside it" without adding a second glyph */
body.fullread .floatf{opacity:.72; background:rgba(127,127,127,.16);
  border-color:transparent}
body.fullread .floatf:active{opacity:1}
body.fullread .floatf .fdot{width:8px; height:8px}
body.sheetopen .floatf{display:none !important}

/* The app switcher. Same size and drag as the other two. */
.floats{position:fixed; z-index:80; width:56px; height:56px; border-radius:50%;
  border:1px solid var(--line); background:var(--panel); color:var(--text);
  padding:0; display:none; align-items:center; justify-content:center;
  touch-action:none; box-shadow:0 3px 14px rgba(0,0,0,.45); opacity:.88}
.floats .sarr{font-size:22px; line-height:1; display:block}
body.hasfloats .floats{display:flex}
.floats:active{border-color:var(--tune); opacity:1}
.floats.moving{opacity:1; border-color:var(--tune); transform:scale(1.06)}
/* dimmed until the phone can actually do it, so it never looks ready and
   then does nothing */
.floats.notready{opacity:.4}
.floats.notready .sarr{opacity:.6}
body.fullread .floats{opacity:.72; background:rgba(127,127,127,.16);
  border-color:transparent}
body.fullread .floats:active{opacity:1}
body.sheetopen .floats{display:none !important}

/* The catcher. Some browsers will not hand a page the clipboard at all, and
   no amount of asking changes that. So when the quick way is refused, this
   opens: a real text field, already focused, that the phone will happily
   paste into by long press or by a keyboard. The moment anything lands in it
   the reading starts, so it costs one extra press and never a typed word. */
.catchwrap{position:fixed; inset:0; z-index:90; display:none;
  background:rgba(0,0,0,.62); align-items:center; justify-content:center;
  padding:18px}
.catchwrap.on{display:flex}
.catchbox{width:100%; max-width:520px; background:var(--panel);
  border:1px solid var(--line); border-radius:16px; padding:15px}
.catchbox h4{margin:0 0 4px; font-size:16px; color:var(--text)}
.catchbox p{margin:0 0 11px; font-size:12.5px; color:var(--faint); line-height:1.5}
.catchbox textarea{width:100%; min-height:110px; border-radius:11px;
  border:2px dashed var(--tune); background:var(--bg); color:var(--text);
  padding:11px; font-size:15px; line-height:1.4}
.catchrow{display:flex; gap:8px; margin-top:10px}
.catchrow button{flex:1; border:1px solid var(--line); background:transparent;
  color:var(--dim); border-radius:11px; padding:11px; font-size:14px}
.catchrow button.go{color:var(--text); border-color:var(--tune)}
.fsout{position:fixed; z-index:60; display:none;
  top:calc(8px + env(safe-area-inset-top)); right:10px;
  width:44px; height:44px; border:none; border-radius:50%;
  background:rgba(127,127,127,.13); color:var(--dim);
  align-items:center; justify-content:center; padding:0}
.fsout svg{width:20px; height:20px; display:block}
.fsout:active{background:rgba(127,127,127,.26); color:var(--text)}
body.fullread .fsout{display:none !important}
/* ...unless the floating P has been switched off, in which case the corner
   button is the ONLY way out and must come back. Full screen with no exit is
   a trap, and this app promises he is never stuck in that view. */
body.fullread:not(.hasfloat):not(.hasfloatf) > .fsout{display:flex !important}
/* while the text is a paste target, say so with the cursor and kill the
   text selection that a tap would otherwise start */
/* ---------- FULL SCREEN MEANS FULL SCREEN ----------
   The old rules named the things to hide: header, controls, gear. That is a
   list, and a list goes stale the moment anything is added, which is exactly
   what happened; the player and the voice strip were still sitting there.

   So this is turned inside out. Hide EVERY direct child of the body, then name
   the few that are allowed to stay. Anything added to this app in future is
   hidden by default in full screen and has to argue its way back on, which is
   the right way round.

   What stays: the text, and the one floating button to get out. That is all.
   The toast stays too, because a message you cannot see is worse than useless,
   and the paste catcher stays because it only opens when it is wanted. */
body.fullread > *{display:none !important}
body.fullread > main{display:block !important}
body.fullread > .floatp{display:flex !important}
body.fullread > .floatf{display:flex !important}
body.fullread > .floats{display:flex !important}
body.fullread > .toast{display:block !important}
body.fullread > .catchwrap.on{display:flex !important}

/* Inside the reader, the same idea again: only the scrolling text survives.
   The progress row, the player bar, the status line, anything else, gone. */
body.fullread .view > *:not(.reader-scroll){display:none !important}

/* and the text takes the whole screen, not the space the player left behind */
body.fullread .reader-scroll{position:fixed; inset:0; max-height:none;
  height:auto; overflow-y:auto; -webkit-overflow-scrolling:touch;
  padding:calc(20px + env(safe-area-inset-top)) 17px
          calc(28px + env(safe-area-inset-bottom))}
</style>
</head>
<body data-theme="night">
<header>
  <button class="gear-corner" id="gearCorner" title="Settings">&#9881;</button>
  <div class="voices" id="voices"></div>
  <div class="topbar">
    <nav class="tabs" id="tabs">
      <button class="tab on" data-tab="home">Read</button>
      <button class="tab" id="pasteTab">Paste</button>
      <button class="tab player" id="playerJump" title="Jump to the player">Player</button>
      <button class="tab" data-tab="offline">Offline</button>
      <button class="tab" data-tab="help">Help</button>
    </nav>
  </div>
</header>

<main>
  <!-- HOME -->
  <section class="view home" id="homeView">
    <h2>Paste a text to read</h2>
    <textarea id="pasteBox" placeholder="Tap here to paste and start reading. Or type. Links and Markdown are stripped automatically, so only the words are read."></textarea>
    <div class="home-actions">
      <button class="btn primary" id="readBtn">Read it</button>
      <button class="btn" id="saveOfflineBtn">Save offline</button>
      <button class="btn ghost" id="clearBtn">Clear</button>
      <span class="hint" id="pasteHint"></span>
    </div>
    <div class="lib">
      <h2>Archive</h2>
      <input class="searchbox" id="libSearch" placeholder="Search your archive">
      <div class="listbar" id="libBar">
        <button class="minibtn" id="libSelToggle">Select</button>
        <button class="minibtn hidden" id="libSelAll">Select all</button>
        <button class="minibtn danger hidden" id="libDelSel">Delete (0)</button>
        <button class="minibtn danger" id="libDelAll">Delete all</button>
        <span class="selcount hidden" id="libSelCount"></span>
      </div>
      <div id="libList"></div>
    </div>
  </section>

  <!-- READER -->
  <section class="view hidden" id="readerView">
    <div class="reader-scroll" id="readerScroll">
      <p class="reader-title" id="readerTitle"></p>
      <div class="doc" id="doc"></div>
      <!-- EDIT mode for a Markdown text edits the SOURCE, markers and all -->
      <textarea class="md-edit" id="mdEdit" spellcheck="false"
                autocapitalize="off" autocorrect="off"></textarea>
    </div>
    <div class="controls off-controls">
      <div class="progress">
        <button class="fsbtn" id="fsBtn" title="Full screen"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 3H5a2 2 0 0 0-2 2v3M16 3h3a2 2 0 0 1 2 2v3M8 21H5a2 2 0 0 1-2-2v-3M16 21h3a2 2 0 0 0 2-2v-3"/></svg></button>
        <div class="bar"><i id="barFill"></i></div>
        <button class="counter" id="counter"
          title="How much is left. Press to clear and start again.">0 / 0</button>
      </div>
      <div class="yt-bar">
        <div class="ytgroup modes" id="modeRow">
          <button class="modebtn on" data-mode="read">read</button>
          <button class="modebtn" data-mode="text">text</button>
          <button class="modebtn" data-mode="edit">edit</button>
        </div>
        <button class="yt-play" id="playBtn" title="Play / Pause"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M7 5.5v13a1 1 0 0 0 1.53.85l10.2-6.5a1 1 0 0 0 0-1.7L8.53 4.65A1 1 0 0 0 7 5.5z"/></svg></button>
        <div class="ytstep">
          <button class="yt-mini" data-step="speed" data-d="-1" title="Slower">&#8722;</button>
          <button class="yt-num" data-reset="speed" title="Tap to reset to 1.00"><b id="spdNum">1.00</b><i>speed</i></button>
          <button class="yt-mini" data-step="speed" data-d="1" title="Faster">+</button>
        </div>
      </div>
      <div class="status" id="status"></div>
    </div>
  </section>

  <!-- OFFLINE LIST -->
  <section class="view hidden" id="offlineView">
    <h2>Offline reader</h2>
    <p class="sub">Reads a text you already exported, one sentence at a time,
      straight from your MA Reader Audio folder. Each sentence lights up and then
      its own small clip plays, so there is nothing to stream and no internet
      needed. Voice cannot be changed here because the clips are already made.</p>
    <input class="searchbox" id="offSearch" placeholder="Search exported texts">
    <div class="listbar" id="offBar">
      <button class="minibtn" id="offSelToggle">Select</button>
      <button class="minibtn hidden" id="offSelAll">Select all</button>
      <button class="minibtn danger hidden" id="offDelSel">Delete (0)</button>
      <button class="minibtn danger" id="offDelAll">Delete all</button>
      <span class="selcount hidden" id="offSelCount"></span>
    </div>
    <div id="offList"></div>
  </section>

  <!-- OFFLINE PLAYER -->
  <section class="view hidden" id="offlineReaderView">
    <div class="reader-scroll" id="offReaderScroll">
      <p class="reader-title" id="offTitle"></p>
      <div class="doc" id="offDoc"></div>
    </div>
    <div class="controls off-controls">
      <div class="progress">
        <button class="fsbtn" id="offFsBtn" title="Full screen"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 3H5a2 2 0 0 0-2 2v3M16 3h3a2 2 0 0 1 2 2v3M8 21H5a2 2 0 0 1-2-2v-3M16 21h3a2 2 0 0 0 2-2v-3"/></svg></button>
        <input type="range" id="offSeek" class="seek" min="0" max="1000" value="0">
        <button class="counter" id="offCounter"
          title="How much is left. Press to clear and start again.">0 / 0</button>
      </div>
      <div class="yt-bar">
        <div class="ytgroup modes" id="offModeRow">
          <button class="modebtn on" data-mode="read">read</button>
          <button class="modebtn" data-mode="text">text</button>
          <button class="modebtn" data-mode="edit">edit</button>
        </div>
        <button class="yt-play" id="offPlay" title="Play / Pause"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M7 5.5v13a1 1 0 0 0 1.53.85l10.2-6.5a1 1 0 0 0 0-1.7L8.53 4.65A1 1 0 0 0 7 5.5z"/></svg></button>
        <div class="ytstep">
          <button class="yt-mini" data-step="speed" data-d="-1" title="Slower">&#8722;</button>
          <button class="yt-num" data-reset="speed" title="Tap to reset to 1.00"><b id="spdNum2">1.00</b><i>speed</i></button>
          <button class="yt-mini" data-step="speed" data-d="1" title="Faster">+</button>
        </div>
      </div>
      <div class="status" id="offStatus"></div>
    </div>
  </section>

  <!-- HELP -->
  <section class="view hidden" id="helpView">
    <div class="help">
      <h2>How MA Reader works</h2>
      <p class="sub">MA Reader <span id="appVer">v3.40 &middot; Edge / Speechify</span></p>
      <p class="lead">MA Reader turns any text into speech and lights up each
        word as it is spoken. There are two ways to read.</p>

      <h3>Read (online)</h3>
      <p>Paste text and press Read it. The app speaks it sentence by sentence
        with the voice you pick and highlights the word being read. Everything
        you read is saved to your Archive so you can open it again.</p>

      <h3>How the highlight stays on the word</h3>
      <p>The timing does not trust the voice engine's reported clock, which is
        what used to make the red word drift off the speech. Instead, after a
        sentence is spoken the app decodes that very clip, measures where
        speech truly begins and ends and where it rises after every pause, and
        pins each word to the real waveform, the same idea caption tools like
        DaVinci Resolve use. During playback a smoothed clock follows the clip
        so the highlight moves with the voice, not in jumps. Clips made by
        older versions are repaired automatically the first time they play.</p>

      <h3>Offline reader</h3>
      <p>Open a text, choose a voice, then press Export. The app speaks each
        sentence into its own small <code>.mp3</code> clip inside a folder named
        after the text, and writes a plain <code>.txt</code> and a
        <code>.json</code> manifest beside it. The Offline tab reads that
        manifest and plays the clips one sentence at a time: it lights up the
        whole sentence, then plays that sentence's clip, then moves to the next.
        There is no long stitched file, so the highlight always stays on the
        sentence being read and never jumps ahead. Voices cannot be changed
        there because the clips are already made.</p>

      <h3>Where files live</h3>
      <p>Everything offline uses one folder, created automatically the first time
        you export: <code>MA Reader Audio</code> inside your Downloads. On
        Android that is <code>Downloads/MA Reader Audio</code>; on a Mac it is
        <code>~/Downloads/MA Reader Audio</code>. On Android, run
        Exports land in your Downloads folder.</p>

      <h3>Fastest way to read something</h3>
      <p>Copy any text, come back to this page and tap <b>Paste</b>. The
        clipboard replaces whatever was here and starts reading immediately.
        Tap any sentence to read from there. That is the only gesture on the
        text; otherwise you simply scroll it with a finger.</p>

      <h3>The player</h3>
      <p>Either side of the play button is a small control with a minus, a
        number and a plus. The left one is the speaking speed, the right one is
        the gap between <b>words</b>. Both move in twentieths, so one press is a
        small nudge rather than a jump; hold a button down and it repeats,
        quickening after a second. Tapping the number itself puts that control
        back where it started, 1.00 for speed and 0.00 for the word gap, so coming
        home from a long hold costs one tap.</p>
      <p>The word gap is the quiet the voice already leaves inside a sentence,
        between one word and the next. Nothing is re-recorded and no word is
        ever cut: below zero the player runs quickly through that quiet, above
        zero it stops inside it and waits. It is the one you reach for while you
        are actually listening, which is why it sits on the player.</p>
      <p>The gap between <b>sentences</b> is a different silence and lives in
        Settings, under Playback, because it is set once and left. It goes below
        zero, down to minus one second, and a negative gap there is an overlap:
        the next sentence starts that much before this one has finished, so
        there is no seam at all between them.</p>

      <h3>Swiping</h3>
      <p>Scroll the text with a finger, the way you would any page. Tapping a
        sentence starts reading from it. That is the only gesture on the
        text.</p>

      <h3>Immersive reading</h3>
      <p>Double tap the middle of the page and everything except the text goes
        away, like an ebook, and it starts speaking. Double tap the middle again
        and the controls come back and it pauses, so you always stop exactly
        where you were reading. While immersive, a single tap anywhere pauses
        and resumes.</p>

      <h3>Why it does not stutter between sentences</h3>
      <p>Each sentence is its own small clip, so there is a join between every
        pair of them. Three sentences ahead are always fetched and kept in
        memory, the next one is loaded into a second player and left decoded and
        waiting, and the changeover is made a fraction before the current clip
        ends rather than after the browser gets round to reporting it. Nothing
        is fetched, opened or decoded at the moment of the handover, so the
        reading runs on without a break.</p>

    </div>
  </section>
</main>

<!-- reading settings sheet -->
<div class="backdrop" id="backdrop"></div>
<div class="sheet" id="sheet">
  <div class="sheet-head">
    <!-- The two things changed most often, so they sit above everything and
         are reachable without scrolling: WHICH ENGINE speaks, and WHICH
         LANGUAGE is being read. Both name the state they are in and flip on
         a press. -->
    <div class="headtogs">
      <button class="htog" id="engBtn"><b>EDGE</b></button>
      <button class="htog" id="langBtn"><b>ENG</b></button>
    </div>
    <button class="sheet-x" id="sheetX" title="Close">&#10005;</button>
    <span class="sheet-ver" id="appVerTop"></span>
  </div>

  <!-- Two engines, two buttons, and the cards below follow whichever is
       chosen. Everything to do with voices is engine-shaped, so it hides;
       speed, the pauses, the text and the colours belong to both and stay. -->
  <div class="chips toprow" id="bothWrap" style="margin:0 0 14px">
    <button class="chip" id="fullPasteTog">Go full screen</button>
    <button class="chip" id="hideTabsTog">Hide the tabs</button>
    <div class="ytstep setstep">
      <button class="yt-mini" data-step="gap" data-d="-1" title="Shorter pause between sentences">&#8722;</button>
      <button class="yt-num" data-reset="gap" title="Tap to reset to 0.00"><b id="gapNum">0.00</b><i>sentences</i></button>
      <button class="yt-mini" data-step="gap" data-d="1" title="Longer pause between sentences">+</button>
    </div>
    <div class="ytstep setstep">
      <button class="yt-mini" data-step="lag" data-d="-1" title="Jump sooner">&#8722;</button>
      <button class="yt-num" data-reset="lag" title="Tap to reset to 0.00"><b id="lagNum">0.00</b><i>scroll delay</i></button>
      <button class="yt-mini" data-step="lag" data-d="1" title="Wait longer before jumping">+</button>
    </div>
  </div>
  <!-- Three panes, not two engines. A person looking for the font should
       not have to guess whether it lives under Edge or under Speechify. -->
  <div class="engtabs" id="engTabs">
    <button class="engtab" data-pane="edge"><b>Edge</b></button>
    <button class="engtab" data-pane="speechify"><b>Speechify</b></button>
    <button class="engtab" data-pane="app"><b>Settings</b></button>
  </div>


  <!-- Voices come first in both tabs. It is the thing reached for most and
       the only part of Settings that differs between the two engines, so it
       sits directly under the buttons that choose them. -->
  <div class="group g-voice" data-eng="edge">
    <h3>Edge voices</h3>
    <div class="chips">
      <button class="chip" id="voiceBarTog">Voice buttons on top</button>
    </div>

    <div class="wsub">The voice</div>
    <div class="spgrid" id="edgeVoiceGrid"></div>
    <div class="setlegend">
      <span><i style="border-color:var(--femme)"></i>female</span>
      <span><i style="border-color:var(--homme)"></i>male</span>
    </div>
    <div class="wsub">Languages</div>

    <div class="lang-tools">
      <button id="langAll">Select all</button>
      <button id="langNone">Clear</button>
    </div>
    <div class="langlist" id="langList"></div>
  </div>

  <div class="group g-sp" data-eng="speechify">
    <h3>Speechify voices</h3>

    <!-- Two short lists of radio rows rather than a paged catalogue. Ported
         from TTT_MINI: a radio says plainly which one is chosen, where a grid
         of chips has to be read twice. -->
    <!-- English first: it is the language read most, and the order of a list
         is a claim about what matters. -->
    <div class="wsub">English</div>
    <div class="radios" id="engList"></div>

    <div class="wsub">Croatian</div>
    <div class="langhint">Speechify has no Croatian voice &mdash; none exists on
      any model. These read Croatian with a foreign accent, best first.</div>
    <div class="radios" id="croList"></div>

    <div class="wsub">Keys</div>
    <div class="keybox">
      <div class="keyhead">Key ring
        <span class="keystate" id="spKeyState">not set</span></div>
      <button class="keybtn ghost" id="spRefresh">Test again</button>
      <button class="keybtn ghost" id="spForget">Forget</button>
      <div class="keyerr" id="spKeyErr"></div>
    </div>
    <div class="spstate" id="spState"></div>
    <div id="spList"></div>
    <div id="spDead"></div>
    <div class="langhint">One key per line, a name above each. Tried in order, first good one used.</div>
  </div>

  <!-- Then the rest, ordered by how often a thing is touched, not how
       important it sounds. Each card is tinted so the block you want is
       findable by colour. -->
  <div class="group g-text" data-eng="app">
    <h3>Text</h3>
    <div class="wsub">Letter size</div>
    <div class="rowctl">
      <span class="lab">Size of the letters</span>
      <button class="a-sm" data-step="size" data-d="-1">A&#8722;</button>
      <span class="val" id="sizeVal2">21</span>
      <button class="a-lg" data-step="size" data-d="1">A+</button>
    </div>
    <div class="wsub">Line spacing</div>
    <div class="rowctl">
      <span class="lab">Space between lines</span>
      <button data-step="lh" data-d="-1">&#8722;</button>
      <span class="val" id="lhVal">3</span>
      <button data-step="lh" data-d="1">+</button>
    </div>
    <div class="wsub">Typeface</div>
    <div class="chips">
      <button class="chip f-sans"  data-font="sans">Sans</button>
      <button class="chip f-book"  data-font="book">Book</button>
      <button class="chip f-serif" data-font="serif">Serif</button>
      <button class="chip f-mono"  data-font="mono">Mono</button>
    </div>
  </div>

  <div class="group g-keys" data-eng="app">
    <div class="gtitle">Keys</div>
    <div class="chips" style="margin:6px 0">
      <button class="chip" id="keyPick">Choose .txt key file</button>
      <button class="chip" id="keyRefresh">Refresh</button>
    </div>
    <div class="langhint">One file, any mess. Each key is filed by its own
      shape; you are never asked which is which.</div>
    <div class="keylist" id="keyList"></div>
    <input type="file" id="keyImport" accept=".txt,text/plain" style="display:none">
  </div>

  <div class="group g-play" data-eng="app">
    <h3>Playback</h3>
    <div class="rowctl">
      <span class="lab">Speed</span>
      <button data-step="speed" data-d="-1">&#8722;</button>
      <span class="val" id="speedVal">1.00&times;</span>
      <button data-step="speed" data-d="1">+</button>
    </div>
    <div class="rowctl">
      <span class="lab">Pause between sentences</span>
      <button data-step="gap" data-d="-1">&#8722;</button>
      <span class="val" id="gapVal">0.00</span>
      <button data-step="gap" data-d="1">+</button>
    </div>
    <div class="langhint">Also on the player. Word pause is a real pause, sentence pause can overlap.</div>
    <div class="synctop" style="margin-top:10px">
      <span>Volume</span><span class="val" id="volVal">100%</span>
    </div>
    <input type="range" id="volRange" min="0" max="100" step="5" value="100">
    <div class="chips" id="playToggles" style="margin-top:12px">
      <button class="chip" id="autoplayTog">Auto-play on open</button>
      <button class="chip" id="resumeTog">Remember position</button>
      <button class="chip" id="focusTog">Focus mode</button>
      <button class="chip" id="loopBtn">Loop</button>
      <button class="chip" id="floatTog">Floating paste button</button>
      <button class="chip" id="floatFTog">Floating full screen button</button>
      <button class="chip" id="floatSTog">Floating app switcher</button>
      <button class="chip" id="adbTog">ADB mode on start</button>
      <button class="chip" id="swTest">Test the switcher</button>
    </div>
    <div class="langhint"><b>Floating paste button.</b> Drag it anywhere. Press: paste, full screen, read. In full screen it is the way out.</div>

  </div>

  <div class="group g-colour" data-eng="app">
    <h3>Colour</h3>
    <div class="wsub">Page theme</div>
    <div class="chips" id="themeChips">
      <button class="chip theme-day"   data-theme="day">Day</button>
      <button class="chip theme-sepia" data-theme="sepia">Sepia</button>
      <button class="chip theme-night" data-theme="night">Night</button>
    </div>
    <div class="wsub">Word highlight</div>
    <button class="exp on" id="wordExp">
      <span class="check">&#10003;</span>
      <span class="txt">
        <b>Highlight the word being read</b>
        <small>Lights up the exact word as it is spoken, on top of the
        sentence highlight. Pick its colour and intensity below.</small>
      </span>
    </button>
    <div class="wcolor">
      <div class="wsub">Sentence highlight background</div>
      <div class="rgbrow"><span class="rgbsw" id="swSent"></span>
        <label>R<input type="number" min="0" max="255" data-rgb="sent" data-i="0" inputmode="numeric"></label>
        <label>G<input type="number" min="0" max="255" data-rgb="sent" data-i="1" inputmode="numeric"></label>
        <label>B<input type="number" min="0" max="255" data-rgb="sent" data-i="2" inputmode="numeric"></label>
      </div>
      <div class="wsub">Word highlight background</div>
      <div class="rgbrow"><span class="rgbsw" id="swWord"></span>
        <label>R<input type="number" min="0" max="255" data-rgb="word" data-i="0" inputmode="numeric"></label>
        <label>G<input type="number" min="0" max="255" data-rgb="word" data-i="1" inputmode="numeric"></label>
        <label>B<input type="number" min="0" max="255" data-rgb="word" data-i="2" inputmode="numeric"></label>
      </div>
      <div class="wsub">Highlighted word font colour</div>
      <div class="rgbrow"><span class="rgbsw" id="swFont"></span>
        <label>R<input type="number" min="0" max="255" data-rgb="font" data-i="0" inputmode="numeric"></label>
        <label>G<input type="number" min="0" max="255" data-rgb="font" data-i="1" inputmode="numeric"></label>
        <label>B<input type="number" min="0" max="255" data-rgb="font" data-i="2" inputmode="numeric"></label>
      </div>
      <div class="wsub">Default reading font colour</div>
      <div class="rgbrow"><span class="rgbsw" id="swText"></span>
        <label>R<input type="number" min="0" max="255" data-rgb="text" data-i="0" inputmode="numeric"></label>
        <label>G<input type="number" min="0" max="255" data-rgb="text" data-i="1" inputmode="numeric"></label>
        <label>B<input type="number" min="0" max="255" data-rgb="text" data-i="2" inputmode="numeric"></label>
        <button class="rgbauto" id="textAuto" title="Follow the theme">Auto</button>
      </div>
      <div class="wprev">Sample
        <span class="docprev">A plain reading line, then <span class="sentprev">the <span class="wprevword" id="wPrevWord">word</span> being read</span>, then more.</span>
      </div>
    </div>
    <div class="synctop">
      <span>Timing nudge <em id="syncVoice"></em></span>
      <span class="val" id="syncVal">0.00s</span>
    </div>
    <input type="range" id="syncRange" min="-300" max="300" step="5" value="0">
    <div class="syncends"><span>later</span><span>earlier</span></div>
  </div>

  <div class="group g-groq" data-eng="app">
    <div class="gtitle">Automatic language</div>
    <div class="langhint">Groq is asked whether the text is English. Anything
      that is not English is Croatian. Only used when the button says AUTO.</div>
    <div class="chips" style="margin:6px 0">
      <button class="chip" id="groqTest">Test</button>
    </div>
    <div class="setlegend" id="groqInfo">no key</div>
  </div>

  <div class="group g-adv" data-eng="app">
    <h3>Advanced</h3>
    <div class="chips">
      <button class="chip" id="chromeTog">Open in Chrome</button>
    </div>
    <div class="langhint">Ask for Chrome by name instead of the phone default.</div>
    <div class="wsub">Word timing</div>
    <div class="timing-help">Timing is measured from the audio itself: after a
      sentence is spoken, the app listens to the finished clip, finds where
      speech really starts, ends, and rises after each pause, and pins every
      word to that waveform. It is automatic, free, and works offline. If the
      red word still feels early or late on a particular voice, nudge it with
      the Sync slider in the player settings.</div>
  </div>
</div>

<button class="floatp" id="floatP" title="Paste and read. Drag to move.">P</button>
<!-- The second floater. One job and one job only: full screen on, full screen
     off. A ring with a dot, because it is a state rather than an action and a
     glyph that changes would be a third thing to learn. -->
<button class="floatf" id="floatF" title="Full screen on and off. Drag to move.">
  <span class="fdot"></span>
</button>
<!-- The third floater: back to whatever app you were in before this one, and
     back again. The same thing as double-tapping the recents square. It needs
     the privileged shell that maread-adb sets up, because a web page cannot
     switch Android apps on its own. -->
<button class="floats" id="floatS" title="Switch to the last app. Drag to move.">
  <span class="sarr">&#8646;</span>
</button>

<div class="catchwrap" id="catchWrap">
  <div class="catchbox">
    <h4>Paste here</h4>
    <p>This browser will not hand the page your clipboard by itself. Long press
      the box below and choose Paste, and reading starts the moment it lands.</p>
    <textarea id="catchBox" placeholder="Long press, then Paste"></textarea>
    <div class="catchrow">
      <button id="catchCancel">Cancel</button>
      <button class="go" id="catchGo">Read it</button>
    </div>
  </div>
</div>

<button class="fsout" id="fsOut" title="Leave full screen">
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
       stroke-linecap="round" stroke-linejoin="round">
    <path d="M4 9h3a2 2 0 0 0 2-2V4M20 9h-3a2 2 0 0 1-2-2V4M4 15h3a2 2 0 0 1 2 2v3M20 15h-3a2 2 0 0 0-2 2v3"/>
  </svg></button>
<div class="toast" id="toast"></div>

<!-- marked, vendored whole. No build step, no CDN, no network: the phone is
     often offline and this is a local server. If the file is missing or fails
     to parse, `marked` is simply undefined and every text is treated as plain,
     which is exactly the behaviour of every version before this one. -->
<script src="/static/marked.umd.js"></script>
<script>
"use strict";
const $ = s => document.querySelector(s);
const api = (u,o)=>fetch(u,o);

/* ---------- typography options ---------- */
/* In Baba's order: sans first, because that is what he reads with. */
const FONTS = {
  sans :'system-ui,-apple-system,"Segoe UI",Roboto,sans-serif',
  book :'"Iowan Old Style","Palatino Linotype",Palatino,Georgia,serif',
  serif:'Georgia,"Times New Roman",serif',
  mono :'ui-monospace,"DejaVu Sans Mono",Menlo,Consolas,monospace',
};
/* Base perceptual lead: light the word a hair before the voice reaches it, to
   cancel the audio-output latency the browser adds. In v22 raising this looked
   like it helped and then overshot, because the server was handing back word
   starts that were about 50 ms late and late by a DIFFERENT amount per word; a
   single constant can flatten an average but not a spread. The v23 engine
   removes that bias at the source (measured residual about -7 ms), so 20 ms is
   now doing only the job it was written for and should stay where it is. Per
   voice trimming belongs in the Sync slider, which steps in 5 ms. */
const WORD_LEAD = 0.02;
function curOffsetSec(){ return (ST.wordoffsets[ST.vkey]||0)/1000; }

/* ---- drift-corrected media clock (the heart of smooth highlighting) ----
   Mobile <audio> only updates currentTime a few times a second, which makes a
   naive highlight jump in chunks and fall up to a few words behind. Instead we
   run our own predicted clock: between native updates it advances by real wall
   time multiplied by the playback rate, and when a fresh currentTime arrives we
   ease toward it (or snap on a seek). This yields glassy, karaoke-smooth motion
   that stays locked to the audio. */
const CLK = { pred: 0, lastWall: 0, lastObs: -1, ready: false, lastWord: -2 };
function clockReset(t){
  CLK.pred = t || 0; CLK.lastWall = (performance.now ? performance.now() : Date.now());
  CLK.lastObs = -1; CLK.ready = true; CLK.lastWord = -2;
}
function clockSample(observed, rate, playing){
  const now = (performance.now ? performance.now() : Date.now());
  if(!CLK.ready){ clockReset(observed); return CLK.pred; }
  const dt = (now - CLK.lastWall) / 1000; CLK.lastWall = now;
  if(playing) CLK.pred += dt * (rate || 1);          // free-run between updates
  if(observed !== CLK.lastObs){                        // a real currentTime tick
    CLK.lastObs = observed;
    const err = observed - CLK.pred;
    if(Math.abs(err) > 0.35) CLK.pred = observed;      // seek / big drift: snap
    else CLK.pred += err * 0.5;                        // otherwise ease halfway
  }
  if(CLK.pred < 0) CLK.pred = 0;
  return CLK.pred;
}
function applySync(){
  const ms = ST.wordoffsets[ST.vkey]||0;
  const r = document.querySelector("#syncRange"); if(r) r.value = ms;
  const v = document.querySelector("#syncVal");
  if(v) v.textContent = (ms>0?"+":"") + ms + " ms";
  const lbl = document.querySelector("#syncVoice");
  if(lbl){ const vc = anyVoice(ST.voice);
           lbl.textContent = vc ? "for "+vc.name : ""; }
}
const LH = {1:1.35, 2:1.5, 3:1.72, 4:1.95, 5:2.2};
const SIZE_MIN = 1, SIZE_MAX = 14;
/* Speed and the WORD gap are the two knobs that live on the transport bar, so
   they step finely: a press is a nudge, not a jump. Hold a button to repeat.
   The gap between SENTENCES moved into Settings in v26; it still runs into the
   minus, where the next sentence starts BEFORE the current one has finished
   and the two overlap by that much. */
const SPEED_MIN = 0.5, SPEED_MAX = 3.0, SPEED_STEP = 0.05;
const GAP_MIN = -1.0, GAP_MAX = 3.0, GAP_STEP = 0.05;
const LAG_MIN = 0.00, LAG_MAX = 3.00, LAG_STEP = 0.05;
/* The pause between WORDS is a different animal from the pause between
   sentences. Sentences are separate clips, so the space between them is ours
   to make. The words inside one clip are not: the voice has already spoken
   them into a single piece of audio with its own small silences baked in.

   v3 stops trying to be clever about it. The old version changed playbackRate
   to race through those silences, and every rate change was audible - clicks,
   chirps, a chipmunk on the consonants, and on some Android webviews the audio
   simply muted below about a quarter speed. Rate is never touched now. The
   server has already measured exactly where each between-word silence sits, so
   the player does the one honest thing: it PAUSES the clip inside a silence,
   waits the time you asked for, and plays it again. A pause in silence is
   inaudible by definition. Nothing is re-recorded, nothing is resampled, no
   word is clipped, no consonant is cut in half.

   That is also why it only runs upward from zero. Making a silence longer is
   free; making it shorter would mean cutting audio, and there is no way to
   have less silence than the voice actually recorded. */
/* The pause between WORDS is gone, in the interface and in the engine.
   It worked, but it was not used: a pause long enough to notice made a page
   take half an hour, and anything shorter was indistinguishable from nothing.
   The silence map it rode on is still measured, because the word highlight
   and the reading time estimate both use it for other purposes. */
const THEMES = ["day","sepia","night"];

/* ---------- app state ---------- */
const ST = {
  /* What was pasted, markers and all, as opposed to `sentences`, which is the
     cleaned text the voice is given. Not a setting and never persisted: it
     belongs to whichever text is open. */
  source: "",
  voices: [], voice: 1, vkey: "ukF",
  langs: [], enabledLangs: ["en","hr"],
  /* v3: two engines. Edge is the free Microsoft one this app started on;
     Speechify is keyed, English only, and brings its own word timings. */
  engine: "edge", spAccent: "uk", spVkey: "", spVoices: [], spInfo: {},
  spSet: 0, spPerSet: 4, bothEngines: false,
  floatPaste: true, fpX: 0.82, fpY: 0.72,
  floatFull: true, ffX: 0.82, ffY: 0.58,
  floatSwap: true, fsX: 0.82, fsY: 0.44, adbMode: true, browser: "chrome",
  /* null means never chosen, so the first four can be offered. An empty
     ARRAY means chosen to be none, and must be left alone. Treating those
     two as the same value is what made unticked voices come back on every
     restart: the seed could not tell a decision from a blank. */
  /* Baba's own starting point, so a fresh install is not a chore. */
  lang: "eng", langAuto: "eng", croVoice: "lesya", engVoice: "beatrice_32",
  voiceBar: true, spPicked: null, fullOnPaste: false, hideTabs: true,
  pane: "app",
  mode: "read",
  tid: "", title: "", sentences: [],
  idx: 0, playing: false,
  speed: 1.0, volume: 100, gap: 0.0, lag: 0.0, wgap: 0.0, loop: false,
  size: 4, autoplay: false, focus: false,
  theme: "night", font: "serif", lineheight: 3, wordhl: true,
  rgbSent: [255,217,59], rgbWord: [226,59,78], rgbFont: [255,255,255],
  rgbText: null,
  wordoffsets: {}, aimeta:false, resume:true,
};

/* Three elements, not two. One speaks, one holds the next sentence already
   decoded and waiting, and the third is spare so a negative gap can overlap
   two clips while a fourth is still being armed. */
const players = [new Audio(), new Audio(), new Audio()];
players.forEach(p => { p.preload = "auto"; });
let cur = 0, rafId = null, gapTimer = null;
let handedOff = false;              // has this clip already launched its successor
let playSeq = 0;                    // rises on every start, so stale ended events die
let armed = { slot:-1, idx:-1 };    // which element is holding which sentence
let armWanted = -1;
const boundsCache = new Map();
const wordCache = new Map();
/* idx -> [[from,to],...] the quiet stretches between the words of that clip,
   measured on the server from the decoded waveform and shipped beside the
   word times. Empty for a clip the server could not measure. */
const silCache = new Map();

/* ---------- helpers ---------- */
function toast(msg){
  const t = $("#toast"); t.textContent = msg; t.classList.add("show");
  clearTimeout(toast._t); toast._t = setTimeout(()=>t.classList.remove("show"),2600);
}
/* THE URL MUST NAME THE VOICE THAT WILL SPEAK.
   A Speechify vkey says only "Speechify"; which voice and which model
   actually speak is decided from the language switch and the two seats. So
   two different voices produced the SAME url, and the browser, quite
   correctly, replayed the clip it already had. The server had been fixed to
   store them apart and it changed nothing, because the browser never asked.
   The seat now rides along, and a different voice is a different url. */
function seatTag(){
  if(!String(ST.vkey || "").indexOf) return "";
  if(String(ST.vkey).indexOf("sp_") !== 0) return "";   /* Edge names itself */
  const l = (ST.lang === "auto") ? (ST.langAuto || "eng") : ST.lang;
  const seat = (l === "hr") ? (ST.croVoice || "lesya")
                            : (ST.engVoice || "beatrice_32");
  return "?v=" + encodeURIComponent(seat + "-" + (l === "hr" ? "m" : "e"));
}
function audioUrl(i){ return `/api/audio/${ST.tid}/${ST.vkey}/${i}.mp3` + seatTag(); }
function boundsUrl(i){ return `/api/bounds/${ST.tid}/${ST.vkey}/${i}` + seatTag(); }
function clampIdx(i){ return Math.max(0, Math.min(i, ST.sentences.length-1)); }
function active(){ return players[cur]; }

/* ---------- voices ----------
   Two engines, one strip. Edge fills it from whichever languages are ticked
   in Settings and scrolls if there are many; Speechify fills it with exactly
   four, two female and two male, because that is all the room there is. */
function enabledSet(){ return new Set(ST.enabledLangs||[]); }
/* The reading language filters everything. A voice that cannot pronounce the
   language on screen has no business being offered, and certainly no business
   sitting on the top row where a pocket can press it. */
/* AUTO is not a language, it is a promise to find out. Until Groq answers,
   the last answer stands, and English is the opening assumption. */
function langCode(){
  const l = (ST.lang === "auto") ? (ST.langAuto || "eng") : ST.lang;
  return l === "hr" ? "hr" : "en";
}
function autoDetect(text){
  if(ST.lang !== "auto") return;
  const body = text || (ST.sentences || []).slice(0, 5).join(" ");
  if(!body.trim()) return;
  api("/api/lang/detect", {method:"POST",
      headers:{"Content-Type":"application/json"},
      body: JSON.stringify({text: body})})
    .then(r=>r.json()).then(d=>{
      if(ST.lang !== "auto") return;          /* switched away while waiting */
      const was = ST.langAuto;
      ST.langAuto = (d.lang === "hr") ? "hr" : "eng";
      if(was !== ST.langAuto){
        renderVoices(); renderEdgeGrid();
        try{ renderCroGrid(); }catch(e){}
        toast((ST.langAuto === "hr" ? "Croatian" : "English") +
              (d.by === "groq" ? "" : " (guessed here)"));
      }
      persist();
    }).catch(()=>{});
}
function edgeVoices(){
  const on = enabledSet(), want = langCode();
  return ST.voices.filter(v => v.lang === want && on.has(v.lang));
}
/* In Croatian, Speechify's offering IS the Croatian pair: it has no Croatian
   voice of its own, so the two auditioned foreigners are the whole set. */
function croPseudoVoices(){
  const l = (ST.lang === "auto") ? (ST.langAuto || "eng") : ST.lang;
  const list = (CROV && (l === "hr" ? CROV.cro : CROV.eng)) || [];
  return list.map(v => ({
    id: "cro:" + v.id, vkey: "cro_" + v.id, name: v.name,
    label: v.sub, sex: /female/i.test(v.sub) ? "F" : "M",
    engine: "speechify", cro: v.id, forLang: l
  }));
}
/* The Speechify catalogue is far longer than the four buttons at the top of
   the reader, so those four are a WINDOW onto it. This is that window, and
   everything else, the strip and the grid in Settings, reads from here so the
   two can never disagree about which four are showing. */
function spSets(){
  const n = (ST.spVoices || []).length;
  return Math.max(1, Math.ceil(n / (ST.spPerSet || 4)));
}
function spClampSet(){
  ST.spSet = Math.max(0, Math.min(spSets() - 1, ST.spSet | 0));
  return ST.spSet;
}
function spWindow(){
  const per = ST.spPerSet || 4, s = spClampSet();
  return (ST.spVoices || []).slice(s * per, s * per + per);
}
/* The Speechify voices ticked for the top row. Any number of them, because
   the row scrolls; four was only ever the size of the window in Settings. */
function spPickedVoices(){
  const want = ST.spPicked || [];   /* null behaves as empty until seeded */
  if(!want.length) return [];
  const by = {}, seen = {};
  (ST.spVoices || []).forEach(v => { by[v.vkey] = v; });
  /* de-duped on the way out. Ticking cannot produce a repeat, but a state
     file edited by hand or merged from two devices can, and the same voice
     twice in the row is confusing rather than harmless. */
  return want.filter(k => {
    if(!by[k] || seen[k]) return false;
    seen[k] = 1; return true;
  }).map(k => by[k]);
}
function isPicked(vkey){ return (ST.spPicked || []).indexOf(vkey) >= 0; }
function togglePick(vkey){
  const a = (ST.spPicked || []).slice();   /* a decision from here on */
  const i = a.indexOf(vkey);
  if(i >= 0) a.splice(i, 1); else a.push(vkey);
  ST.spPicked = a;
}
/* What each engine contributes to the top row. There used to be a switch per
   engine to hide it, which was redundant: an engine with nothing ticked, or
   no language ticked, already contributes nothing. Two ways to say the same
   thing is one way too many, and the ticks are the honest one because they
   say WHICH voices as well as whether. */
function topEdge(){ return edgeVoices(); }
function topSp(){ return croPseudoVoices(); }
function shownVoices(){
  return ST.engine === "speechify" ? topSp() : topEdge();
}
/* the whole list, for looking a voice up by id even when it is not on screen */
function spAll(){ return ST.spVoices || []; }
/* Is this the voice in hand? A Croatian seat answers on croVoice, since it
   is not a catalogue voice and never becomes ST.voice. */
function voiceIsCurrent(v){
  if(!v) return false;
  if(v.cro) return v.cro === ((v.forLang === "hr") ? ST.croVoice : ST.engVoice)
                  && ST.engine === "speechify";
  return v.id === ST.voice;
}
function anyVoice(id){
  return spAll().find(x=>x.id===id) || ST.voices.find(x=>x.id===id);
}
function sexClass(v){ return v.sex === "F" ? "f" : (v.sex === "M" ? "m" : ""); }
function voiceSub(v){
  if(v.engine !== "speechify") return v.label;
  /* four buttons across a phone leaves no room for "English (United Kingdom)
     female", so Speechify says it the short way. */
  const acc = (v.accent === "us") ? "US" : "UK";
  const sex = (v.sex === "F") ? "female" : "male";
  return acc + " " + sex + (v.tone ? " \u00b7 " + v.tone : "");
}
function voiceBtn(v){
  const b = document.createElement("button");
  b.className = "voice " + sexClass(v) + (voiceIsCurrent(v) ? " on":"");
  b.innerHTML = `<b>${v.name}</b><small>${voiceSub(v)}</small>`;
  b.onclick = ()=> setVoice(v.id);
  return b;
}
/* ---------- hearing a voice ----------
   A name says nothing about a sound. Tapping a voice in Settings has it say
   its own name, so 963 of them can be told apart by ear rather than by
   guessing from a word.

   If the reader was speaking, it is paused for the sample and started again
   afterwards, so a preview never talks over the article and never leaves the
   reading abandoned halfway. */
let PREVIEW = null, PREVIEW_WAS = false;
function stopPreview(){
  if(!PREVIEW) return;
  try{ PREVIEW.pause(); }catch(e){}
  PREVIEW.onended = PREVIEW.onerror = null;
  PREVIEW = null;
}
function previewVoice(v){
  if(!v || !v.vkey) return;
  const again = PREVIEW && PREVIEW.dataset && PREVIEW.dataset.vkey === v.vkey;
  const wasPlaying = PREVIEW ? PREVIEW_WAS : !!ST.playing;
  stopPreview();
  if(again) return;                 /* tapping the same one again stops it */
  PREVIEW_WAS = wasPlaying;
  if(wasPlaying){ try{ pause(); }catch(e){} }
  const a = new Audio("/api/preview/" + encodeURIComponent(v.vkey));
  a.dataset.vkey = v.vkey;
  try{ a.volume = Math.max(0, Math.min(1, (ST.volume==null?100:ST.volume)/100)); }catch(e){}
  PREVIEW = a;
  const done = (msg)=>{
    if(PREVIEW !== a) return;
    stopPreview();
    if(msg) toast(msg);
    if(PREVIEW_WAS){ PREVIEW_WAS = false; try{ resume(); }catch(e){} }
  };
  a.onended = ()=> done("");
  a.onerror = ()=> done("Could not play that voice.");
  const p = a.play();
  if(p && p.catch) p.catch(()=> done("Could not play that voice."));
}

/* The Edge voices, in Settings, so the strip on top is never the only way to
   choose one. Same shape and the same colour coding as the Speechify grid,
   because they are the same job. */
function renderEdgeGrid(){
  const wrap = $("#edgeVoiceGrid"); if(!wrap) return;
  wrap.innerHTML = "";
  const list = edgeVoices();
  if(!list.length){
    const d = document.createElement("div");
    d.className = "spstate";
    d.textContent = "No languages ticked, so there are no voices to choose.";
    wrap.appendChild(d); return;
  }
  list.forEach(v=>{
    const row = document.createElement("div");
    row.className = "spcell " + sexClass(v) + (v.id === ST.voice ? " on" : "");
    const nm = document.createElement("button");
    nm.className = "spname";
    nm.innerHTML = `<b>${v.name}</b><small>${v.label}</small>`;
    nm.onclick = ()=>{ if(ST.engine !== "edge") setEngine("edge", true);
                       setVoice(v.id); renderEdgeGrid(); previewVoice(v); };
    row.appendChild(nm);
    wrap.appendChild(row);
  });
}
function renderVoices(){
  const wrap = $("#voices"); wrap.innerHTML = "";
  /* Both engines at once, when asked for and when there is something in
     both. Speechify goes on top because its row is the one that changes as
     you page through it; Edge underneath is the settled one. */
  /* switched off by hand: the strip goes entirely, and the voice keeps
     working from whatever was last chosen in Settings */
  if(!ST.voiceBar){
    wrap.style.display = "none";
    document.body.classList.add("nobar");
    renderEdgeGrid();
    return;
  }
  document.body.classList.remove("nobar");
  const sp = topSp(), ed = topEdge();
  /* Two rows whenever both engines have something to show. The old separate
     switch for this is gone: the two hide switches say it better. */
  const dual = sp.length > 0 && ed.length > 0;
  wrap.classList.toggle("dual", dual);
  const list = dual ? sp.concat(ed) : shownVoices();
  // nothing to show: the whole strip disappears, the reader quietly keeps
  // using the last voice that was picked (ST.voice stays as it was)
  if(!list.length){ wrap.style.display = "none";
    document.body.classList.add("novoice"); return; }
  wrap.style.display = "";
  document.body.classList.remove("novoice");
  if(dual){
    [sp, ed].forEach(rowList => {
      const row = document.createElement("div");
      row.className = "vrow";
      rowList.forEach(v => row.appendChild(voiceBtn(v)));
      wrap.appendChild(row);
    });
  } else {
    list.forEach(v => wrap.appendChild(voiceBtn(v)));
  }
  renderEdgeGrid();
  // keep the selected chip in view when the strip scrolls
  const onChip = wrap.querySelector(".voice.on");
  if(onChip && onChip.scrollIntoView) try{
    onChip.scrollIntoView({inline:"nearest", block:"nearest"});
  }catch(e){}
}

/* ---------- languages (Settings checkbox list) ---------- */
function renderLangList(){
  const wrap = $("#langList"); if(!wrap) return;
  wrap.innerHTML = "";
  const on = enabledSet();
  (ST.langs||[]).forEach(lg => {
    const row = document.createElement("button");
    const isOn = on.has(lg.key);
    row.className = "langrow" + (isOn ? " on":"");
    const names = (lg.voices||[]).map(v=>v.name).join(" \u00b7 ");
    const nat = lg.native ? `<em>${lg.native}</em>` : "";
    const uses = lg.uses
      ? `<div class="usetxt">Can be used for: ${lg.uses}</div>` : "";
    row.innerHTML =
      `<span class="box">\u2713</span>` +
      `<span class="meta"><div class="name">${lg.label}${nat}</div>` +
      `<div class="vv">${names}</div>${uses}</span>`;
    row.onclick = ()=> toggleLang(lg.key);
    wrap.appendChild(row);
  });
}
function toggleLang(key){
  const on = enabledSet();
  if(on.has(key)) on.delete(key); else on.add(key);
  applyEnabledLangs(on);
}
function setAllLangs(all){
  const on = new Set(all ? (ST.langs||[]).map(l=>l.key) : []);
  applyEnabledLangs(on);
}
function applyEnabledLangs(onSet){
  // preserve catalogue order; empty is allowed (zero languages)
  let keys = (ST.langs||[]).map(l=>l.key).filter(k=>onSet.has(k));
  ST.enabledLangs = keys;
  const shown = shownVoices();
  // if some languages are shown but the active voice's language was hidden,
  // move to the first shown voice. If nothing is shown (zero languages), keep
  // ST.voice exactly as it is so the reader remembers the last choice.
  if(shown.length && !shown.some(v=>voiceIsCurrent(v))){
    setVoice(shown[0].id);
  }
  renderLangList();
  soundChanged("");
}
function setVoice(id, quiet){
  /* A Croatian seat is not a catalogue voice, it is a choice of WHICH foreign
     voice reads Croatian, so it is stored as that and nothing else moves. */
  if(typeof id === "string" && id.indexOf("cro:") === 0){
    const _l = (ST.lang === "auto") ? (ST.langAuto || "eng") : ST.lang;
    if(_l === "hr") ST.croVoice = id.slice(4); else ST.engVoice = id.slice(4);
    if(ST.engine !== "speechify"){ ST.engine = "speechify"; applyEngineCards(); }
    renderVoices(); try{ renderCroGrid(); }catch(e){}
    persist();
    if(!quiet){
      const cv = (CROV || []).find(x => x.id === ST.croVoice);
      toast((cv ? cv.name : "That voice") + " reads Croatian");
    }
    return;
  }
  const v = anyVoice(id); if(!v) return;
  /* With both rows on screen a voice can be picked from the engine that is
     not currently selected. The voice wins: the engine follows it, rather
     than the tap being quietly ignored. */
  const want = (v.engine === "speechify") ? "speechify" : "edge";
  if(ST.engine !== want){ ST.engine = want; applyEngineCards(); }
  const wasPlaying = ST.playing;
  ST.voice = id; ST.vkey = v.vkey; boundsCache.clear(); silCache.clear(); clearWarm();
  renderVoices(); applySync(); persist();
  if(ST.tid && wasPlaying){ startAt(ST.idx); }
  else if(ST.wordhl && ST.tid && !ST.playing){
    highlightWordAt(ST.idx, active().currentTime);
  }
  if(ST.tid) prefetch(ST.idx);
  if(v.engine === "speechify") ST.spVkey = v.vkey;
  try{ renderEdgeGrid(); renderSpGrid(); }catch(e){}
  setStatus("Voice: " + v.name + " (" + voiceSub(v) + ")");
}

/* ---------- the two engines ---------- */
/* WHICH PANE is showing is not the same question as WHICH ENGINE speaks.
   They used to be one value, which is why everything that was not about a
   voice had to be crammed into whichever engine happened to be selected.
   Picking Edge or Speechify still switches the engine, because that is what
   those two panes are for; picking Settings changes nothing about the voice. */
function applyEngineCards(){
  try{ renderLangBtn(); }catch(e){}
  const pane = ST.pane || ST.engine || "edge";
  document.querySelectorAll("#engTabs .engtab").forEach(b=>
    b.classList.toggle("on", b.dataset.pane === pane));
  renderLangBtn();
  document.querySelectorAll("#sheet .group[data-eng]").forEach(g=>{
    g.style.display = (g.dataset.eng === pane) ? "" : "none";
  });
}
/* Changing the language must leave a usable voice behind. If the one in hand
   cannot speak the new language, the first that can is taken. */


/* ---------- a setting that changes the SOUND takes effect at once ----------
   Settings used to be a place you visited and left. Change the language while
   a Croatian page was being read in English and nothing happened: the clips
   already made were cached, the sentence in hand kept playing, and the app
   looked deaf to its own switches.
   Now every control that changes what is HEARD calls this. It drops the
   caches the old voice filled, and if a sentence is playing it is re-spoken
   from its own beginning in the new voice, so the change is audible on the
   line being read rather than the one after next. */
function soundChanged(why){
  /* The three players hold decoded audio from the old voice. Emptying their
     src is what makes the next play fetch rather than replay. */
  try{ players.forEach(p=>{ try{ p.pause(); }catch(e){} p.removeAttribute("src");
                            try{ p.load(); }catch(e){} }); }catch(e){}
  boundsCache.clear(); silCache.clear();
  try{ wordCache.clear(); }catch(e){}
  try{ clearWarm(); }catch(e){}
  renderVoices();
  const wasPlaying = ST.playing;
  const at = ST.idx;
  try{ pause(); }catch(e){}
  if(wasPlaying){
    /* the same sentence again, in the new voice, from its first word */
    setTimeout(()=>{ try{ startAt(at); }catch(e){} }, 40);
  }
  persistNow();
  if(why) toast(why);
}

function setLang(l){
  l = (l === "hr" || l === "auto") ? l : "eng";
  if(l === ST.lang) return;
  ST.lang = l;
  /* Leave a usable voice behind, and prefer the engine already in hand: a
     person on Speechify who switches language wants the Croatian seat, not to
     be thrown across to Edge. Only when the engine has nothing to offer does
     the other one get a turn. */
  const mine = (ST.engine === "speechify") ? topSp() : topEdge();
  const other = (ST.engine === "speechify") ? topEdge() : topSp();
  if(!mine.concat(other).some(v => voiceIsCurrent(v))){
    const first = mine[0] || other[0];
    if(first) setVoice(first.id, true);   /* quiet: setLang says it instead */
  }
  renderLangBtn();
  refreshToggles(); renderEdgeGrid(); renderLangList();
  soundChanged("");
  try{ renderCroGrid(); }catch(e){}
  persist();
  toast(l === "auto" ? "Language decided automatically"
      : l === "hr"   ? "Reading Croatian" : "Reading English");
  if(l === "auto") autoDetect();
}
/* THE BUTTON IS PAINTED IN EXACTLY ONE PLACE.
   It used to be painted inside applyEngineCards, which setPane calls and
   setLang does not. So the language changed, the toast fired, and the button
   went on showing the old word. One painter, called by everyone who can
   change the language, is the whole fix. */
function renderLangBtn(){
  const eb = $("#engBtn");
  if(eb){
    const sp = ST.engine === "speechify";
    eb.innerHTML = "<b>" + (sp ? "SPEECHIFY" : "EDGE") + "</b>";
    eb.classList.add("sp");
    eb.title = sp ? "Speechify is speaking. Tap for Edge."
                  : "Edge is speaking. Tap for Speechify.";
  }
  const lb = $("#langBtn"); if(!lb) return;
  lb.classList.add("sp");
  const l = ST.lang || "eng";
  lb.innerHTML = "<b>" + (l === "hr" ? "HR" : l === "auto" ? "AUTO" : "ENG") + "</b>";
  lb.classList.toggle("auto", l === "auto");
  lb.title = l === "auto" ? "Groq decides. Tap for English."
           : l === "hr"   ? "Reading Croatian. Tap for automatic."
                          : "Reading English. Tap for Croatian.";
}
/* ENG -> HR -> AUTO -> ENG. Three states on one button, because a second
   button would be a second small target. */
function nextLang(){
  const l = ST.lang || "eng";
  return l === "eng" ? "hr" : l === "hr" ? "auto" : "eng";
}
function setPane(p){
  if(p !== "edge" && p !== "speechify" && p !== "app") p = "edge";
  ST.pane = p;
  if(p === "edge" || p === "speechify") setEngine(p, true);
  applyEngineCards();
  persist();
}
function setEngine(e, quiet){
  if(e !== "edge" && e !== "speechify") return;
  const changed = (e !== ST.engine);
  ST.engine = e;
  applyEngineCards();
  const list = shownVoices();
  if(list.length && !list.some(v=>v.id===ST.voice)){
    /* remember which Speechify voice was last used, so switching back and
       forth does not keep resetting to the first of the four */
    const want = (e === "speechify" && ST.spVkey)
      ? list.find(v=>v.vkey === ST.spVkey) : null;
    setVoice((want || list[0]).id);
  } else {
    renderVoices();
  }
  persist();
  if(changed && !quiet){
    toast(e === "speechify" ? "Speechify" : "Edge");
  }
}

/* ---------- Speechify: accents, its four voices, and the key ring ---------- */
function renderSpAccents(){ /* the accent row is gone: two radio lists replaced it */ }
function renderSpGrid(){ /* the paged grid is gone: two radio lists replaced it */ }

/* Paging. Two arrows and a count, then a row of numbers so any page is one
   tap away rather than forty. With 84 American voices that is 21 pages, and
   walking to page 19 with an arrow would be absurd. */
function renderSpPager(){ /* its pager is gone: two radio lists replaced it */ }
function spGoSet(i){
  const total = spSets();
  ST.spSet = Math.max(0, Math.min(total - 1, i));
  /* The window moved, so the four at the top of the reader are different
     voices now. Show them, but do not switch the voice that is speaking:
     changing page is browsing, choosing a voice is a tap on one. */
  renderSpGrid(); renderVoices(); persist();
}
function spWhen(ts){
  if(!ts) return "";
  const d = Math.floor(Date.now()/1000) - ts;
  if(d < 3600) return Math.max(1,Math.floor(d/60)) + " min ago";
  if(d < 86400) return Math.floor(d/3600) + " h ago";
  return Math.floor(d/86400) + " d ago";
}
function fmtChars(n){
  n = n|0;
  if(n >= 1000000) return (n/1000000).toFixed(1) + "M";
  if(n >= 1000) return Math.round(n/1000) + "k";
  return String(n);
}
/* Every key, not only the dead ones, and what each has spent. Shared files
   get used unevenly and there is no other way to see whose account is
   carrying everyone. */
/* The Croatian rows. Two hit areas, as with the voice tick boxes: the name
   chooses the voice, the round button speaks one fixed Croatian sentence so
   the two can be compared by ear without leaving Settings. */
let CROV = null, croAudio = null;
function stopCroPreview(){
  if(croAudio){ try{ croAudio.pause(); }catch(e){} croAudio = null; }
  document.querySelectorAll("#croGrid .croplay")
    .forEach(b => b.innerHTML = "&#9654;");
}
function renderVoiceRadios(){
  const draw = (boxId, list, chosen, pick, hrSample)=>{
    const box = $(boxId); if(!box) return;
    box.innerHTML = "";
    (list || []).forEach(v => {
      const row = document.createElement("button");
      row.className = "rrow" + (v.id === chosen ? " on" : "");
      const dot = document.createElement("span"); dot.className = "rdot";
      const txt = document.createElement("span"); txt.className = "rtxt";
      txt.innerHTML = "<b>" + v.name + "</b><small>" + (v.sub || "") + "</small>";
      const play = document.createElement("button");
      play.className = "rplay"; play.innerHTML = "&#9654;";
      play.title = "Hear " + v.name;
      play.onclick = (e)=>{
        e.stopPropagation();
        const url = "/api/preview_v/" + encodeURIComponent(v.id) +
                    (hrSample ? "?hr=1" : "");
        const mine = croAudio && croAudio.dataset && croAudio.dataset.u === url;
        stopCroPreview();
        if(mine) return;                       /* a second tap stops it */
        try{ pause(); }catch(e2){}
        const a = new Audio(url); a.dataset.u = url; croAudio = a;
        play.innerHTML = "&#9632;";
        a.onended = stopCroPreview;
        a.onerror = ()=>{ stopCroPreview(); toast("Could not play that voice."); };
        a.play().catch(()=>{ stopCroPreview(); toast("Could not play that voice."); });
      };
      row.onclick = ()=> pick(v);
      row.appendChild(dot); row.appendChild(txt); row.appendChild(play);
      box.appendChild(row);
    });
  };
  draw("#croList", (CROV && CROV.cro) || [], ST.croVoice, v=>{
    ST.croVoice = v.id; renderVoiceRadios();
    soundChanged(v.name + " reads Croatian");
  }, true);
  draw("#engList", (CROV && CROV.eng) || [], ST.engVoice, v=>{
    ST.engVoice = v.id; renderVoiceRadios();
    soundChanged(v.name + " reads English");
  }, false);
}
function renderCroGrid(){ renderVoiceRadios(); }

function loadCroVoices(){
  api("/api/cro_voices").then(r=>r.json()).then(d=>{
    CROV = d;
    if(d.croChosen && !ST.croVoice) ST.croVoice = d.croChosen;
    if(d.engChosen && !ST.engVoice) ST.engVoice = d.engChosen;
    renderVoiceRadios(); renderVoices();
  }).catch(()=>{});
}

/* ONE picker for every key. The list below it is the FALLBACK ORDER: the
   first live key does the work and, if it is refused, the next takes over. */
function renderKeyList(){
  api("/api/keys").then(r=>r.json()).then(d=>{
    const box=$("#keyList"); if(!box) return;
    box.innerHTML="";
    const keys=d.keys||[];
    if(!keys.length){
      const p=document.createElement("div");
      p.className="langhint"; p.textContent="No keys yet.";
      box.appendChild(p); return;
    }
    keys.forEach(k=>{
      const row=document.createElement("div");
      row.className="keyrow"+(k.state==="dead"?" dead":"");
      row.innerHTML =
        '<span class="kp">'+k.provider+'</span>'+
        '<span class="kn">'+k.order+'</span>'+
        '<span class="km">'+k.mask+'</span>'+
        '<span class="kl">'+(k.label||"")+'</span>'+
        '<span class="ks">'+k.state+'</span>';
      box.appendChild(row);
    });
  }).catch(()=>{});
}
function wireKeys(){
  const pick=$("#keyPick"), file=$("#keyImport"), ref=$("#keyRefresh");
  if(pick && file){
    pick.onclick = ()=> file.click();
    file.onchange = ()=>{
      const f=file.files && file.files[0]; if(!f) return;
      const fd=new FormData(); fd.append("file", f);
      toast("Reading the file...");
      api("/api/keys/import",{method:"POST", body:fd}).then(r=>r.json()).then(d=>{
        if(d.error){ toast(d.error); return; }
        const bits=[];
        Object.keys(d.added||{}).forEach(p=>bits.push(d.added[p]+" "+p));
        const other=Object.keys(d.other||{});
        let msg = bits.length ? ("Added " + bits.join(", ")) : "Nothing new to add";
        if(other.length) msg += " \u00b7 " + other.join(", ") + " not needed here";
        toast(msg);
        renderKeyList(); renderGroq(); try{ renderSpKeyList(); }catch(e){}
      }).catch(()=>toast("Could not read that file."));
      file.value="";
    };
  }
  if(ref) ref.onclick = ()=>{ renderKeyList(); renderGroq(); };
}
function renderGroq(){
  api("/api/groq/status").then(r=>r.json()).then(d=>{
    const el=$("#groqInfo"); if(!el) return;
    el.textContent = d.total
      ? (d.live + " of " + d.total + " keys live" +
         (d.model ? " \u00b7 " + d.model : "") + (d.dead ? " \u00b7 " + d.dead + " dead" : ""))
      : "no key";
  }).catch(()=>{});
}
function wireGroq(){
  const test=$("#groqTest");
  if(test) test.onclick = ()=>{
    toast("Asking Groq...");
    api("/api/groq/test", {method:"POST"}).then(r=>r.json()).then(d=>{
      toast(d.ok ? ("Groq answered, using " + d.model) : (d.err || "Groq did not answer"));
      renderGroq();
    }).catch(()=>toast("Groq could not be reached."));
  };
}
function renderSpKeyList(){
  const wrap = $("#spList"); if(!wrap) return;
  const list = (ST.spInfo && ST.spInfo.keyList) || [];
  wrap.innerHTML = "";
  if(!list.length) return;
  const h = document.createElement("div");
  h.className = "deadhead";
  const tot = (ST.spInfo && ST.spInfo.charsTotal) || 0;
  h.textContent = list.length + " keys" + (tot ? "  \u00b7  " + fmtChars(tot) + " characters spent" : "");
  wrap.appendChild(h);
  list.forEach(k=>{
    const row = document.createElement("div");
    row.className = "deadrow";
    const meta = document.createElement("div");
    meta.className = "dmeta";
    const tag = k.using ? " \u00b7 in use" : (k.dead ? " \u00b7 dead" : "");
    const weak = k.strong ? "" : " \u00b7 not key shaped";
    meta.innerHTML = `<div class="dname">${k.label || "unnamed"}</div>` +
      `<div class="dsub">${k.mask}${tag}${weak}` +
      `${k.chars ? " \u00b7 " + fmtChars(k.chars) + " chars, " + k.calls + " calls" : ""}</div>`;
    row.appendChild(meta);
    if(k.using) row.style.borderColor = "var(--tune)";
    wrap.appendChild(row);
  });
}
function renderSpDead(){
  const wrap = $("#spDead"); if(!wrap) return;
  const list = (ST.spInfo && ST.spInfo.failed) || [];
  wrap.innerHTML = "";
  if(!list.length) return;
  const h = document.createElement("div");
  h.className = "deadhead";
  h.textContent = list.length + (list.length===1 ? " dead key" : " dead keys");
  wrap.appendChild(h);
  list.forEach(k=>{
    const row = document.createElement("div");
    row.className = "deadrow";
    const meta = document.createElement("div");
    meta.className = "dmeta";
    meta.innerHTML = `<div class="dname">${k.label || "unnamed"}</div>` +
      `<div class="dsub">${k.mask} \u00b7 ${k.reason || "rejected"}` +
      `${k.at ? " \u00b7 " + spWhen(k.at) : ""}${k.gone ? " \u00b7 removed" : ""}</div>`;
    row.appendChild(meta);
    if(!k.gone){
      const retry = document.createElement("button");
      retry.className = "deadbtn"; retry.textContent = "Retry";
      retry.title = "Clear the mark and let this key be used again";
      retry.onclick = ()=> spKeyAction("/api/speechify/revive", k.fp,
                                       "Will try " + (k.label||k.mask) + " again");
      row.appendChild(retry);
      const drop = document.createElement("button");
      drop.className = "deadbtn warn"; drop.textContent = "Remove";
      drop.title = "Strike this key out of the file for good";
      drop.onclick = ()=> spKeyAction("/api/speechify/drop", k.fp,
                                      "Removed " + (k.label||k.mask));
      row.appendChild(drop);
    }
    wrap.appendChild(row);
  });
}
function spKeyAction(url, fp, msg){
  api(url, {method:"POST", headers:{"Content-Type":"application/json"},
            body: JSON.stringify({fp: fp})})
    .then(r=>r.json()).then(d=>{ applySpInfo(d); toast(msg); })
    .catch(()=> toast("Could not reach the server."));
}
function renderSpKeys(){
  const st = $("#spKeyState"), err = $("#spKeyErr"), line = $("#spState");
  const d = ST.spInfo || {};
  if(st){
    st.textContent = d.keys ? (d.keys + (d.keys === 1 ? " key" : " keys")) : "not set";
    st.classList.toggle("ok", !!d.ready);
  }
  if(err) err.textContent = (!d.ready && d.error) ? d.error : "";
  if(line){
    line.classList.toggle("bad", !d.ready && !!d.keys);
    if(!d.keys){
      line.textContent = "No key file loaded yet.";
    } else if(d.ready){
      const nm = d.usingLabel ? (d.usingLabel + " \u00b7 " + d.using) : d.using;
      line.innerHTML = "Speaking through <b>" + nm + "</b>, " + d.live +
        " of " + d.keys + " still good. Nothing else is being tested; this key " +
        "carries everything until it stops working.";
    } else {
      line.textContent = d.error || "No key in this file is working.";
    }
  }
}
function applySpInfo(d){
  if(!d) return;
  ST.spInfo = d;
  if(d.accent) ST.spAccent = d.accent;
  ST.spVoices = (d.voices || []);
  if(d.perSet) ST.spPerSet = d.perSet;
  spClampSet();
  renderSpAccents(); renderSpGrid(); renderSpKeys();
  renderSpKeyList(); renderSpDead();
  if(ST.engine === "speechify") renderVoices();
}
function loadSpeechify(){
  return api("/api/speechify/status").then(r=>r.json())
    .then(applySpInfo).catch(()=>{});
}
function setSpAccent(acc){
  if(acc === ST.spAccent && (ST.spVoices||[]).length) return;
  ST.spAccent = acc; ST.spSet = 0; renderSpAccents();
  api("/api/speechify/accent", {method:"POST",
      headers:{"Content-Type":"application/json"},
      body: JSON.stringify({accent: acc})})
    .then(r=>r.json()).then(d=>{
      applySpInfo(d);
      /* the four seats now hold different voices, so the one that was picked
         is gone: take the first of the new set */
      const list = ST.spVoices || [];
      if(ST.engine === "speechify" && list.length &&
         !list.some(v=>v.id===ST.voice)){ setVoice(list[0].id); }
      persist();
    }).catch(()=> toast("Could not reach Speechify."));
}

/* ---------- Markdown, phase 1: detect, parse once, sanitise ----------
   The reader shows formatted Markdown. It is parsed ONCE into HTML and never
   re-parsed while reading; highlighting later works by toggling classes on
   spans inside that HTML, exactly as it always has for plain text.

   Raw Markdown is never displayed, so the absence of a highlight syntax in
   Markdown does not matter. Formatting and highlight are separate layers. */

/* WHEN IS IT MARKDOWN.
   Plain text must come through completely untouched, so a single weak hint is
   never enough. A hyphen list or an emphatic *word* appears in ordinary prose
   and in pasted articles all the time.

   STRONG signals essentially never occur in prose that was not meant as
   Markdown: a # heading, a fence, a [text](url) link, a table delimiter row.
   One of those decides it.

   WEAK signals are common in plain writing on their own but rare in
   combination: bullets, > quotes, **bold**, *italic*, `code`, --- rules,
   setext underlines. TWO different weak signals decide it; one does not.

   They are grouped into FAMILIES and each family counts at most once, because
   two hints drawn from the same construct are not two hints. "The end.\n---"
   is one dash rule, and it reads as both a thematic break and a setext
   underline; counted separately it would carry a plain paragraph over the
   line on its own. */
const MD_STRONG = [
  /^ {0,3}#{1,6}[ \t]+\S/m,                       /* # heading            */
  /^ {0,3}(?:```|~~~)/m,                          /* fenced code block    */
  /!?\[[^\]\n]*\]\([^()\s]*\)/,                   /* [link](url), image   */
  /^ {0,3}\|?[ \t]*:?-{3,}:?[ \t]*(\|[ \t]*:?-+:?[ \t]*)+\|?[ \t]*$/m
];
const MD_WEAK = [
  [ /^ {0,3}[-*+][ \t]+\S/m,                        /* - bullet           */
    /^ {0,3}\d{1,9}[.)][ \t]+\S/m ],                /* 1. numbered        */
  [ /^ {0,3}>[ \t]?\S/m ],                          /* > block quote      */
  [ /(\*\*|__)(?=\S)[\s\S]+?(?<=\S)\1/ ],           /* **bold**           */
  [ /(?<![\w*])\*(?=\S)[^*\n]+?(?<=\S)\*(?![\w*])/ ],/* *italic*          */
  [ /`[^`\n]+`/ ],                                  /* `code`             */
  [ /^ {0,3}([-*_])[ \t]*(?:\1[ \t]*){2,}$/m,       /* --- rule, and the  */
    /^[^\s>#|=-][^\n]*\n {0,3}(?:={2,}|-{2,})[ \t]*$/m ] /* setext twin   */
];
function looksLikeMarkdown(text){
  if(!text || text.length < 3) return false;
  for(const re of MD_STRONG){ if(re.test(text)) return true; }
  let weak = 0;
  for(const fam of MD_WEAK){
    if(fam.some(re => re.test(text)) && ++weak >= 2) return true;
  }
  return false;
}

/* WHAT MAY SURVIVE THE PARSE.
   marked emits a small, known set of tags. Anything outside it is either
   dropped whole (it carries no reading matter) or unwrapped (it might).
   No DOMPurify: this is a fixed allowlist over one known producer, and the
   parse happens in a detached document that has no browsing context, so
   nothing in it can run or fetch while it is being cleaned. */
const MD_OK_TAGS = new Set(["p","br","hr","h1","h2","h3","h4","h5","h6",
  "strong","em","b","i","del","s","code","pre","blockquote","ul","ol","li",
  "a","img","table","thead","tbody","tfoot","tr","th","td","span","div","sup","sub"]);
/* Dropped with everything inside them. Script and style are obvious; the rest
   either execute, load, or draw something that is not text. */
const MD_KILL_TAGS = new Set(["script","style","iframe","object","embed",
  "svg","math","form","input","button","textarea","select","option","link",
  "meta","base","noscript","template","title","audio","video","source",
  "track","canvas","applet","frame","frameset","portal","dialog"]);
/* Per tag, the only attributes allowed through. Everything else goes,
   which covers every on* handler in one rule rather than by name. */
const MD_OK_ATTRS = {
  a:    new Set(["href","title"]),
  img:  new Set(["src","alt","title"]),
  ol:   new Set(["start"]),
  td:   new Set(["colspan","rowspan","align"]),
  th:   new Set(["colspan","rowspan","align"]),
  code: new Set(["class"]),
  pre:  new Set(["class"])
};
/* A URL is safe if it is plainly relative, or http/https/mailto. Anything
   whose scheme cannot be read is refused rather than guessed at. Control
   characters are stripped first: "java\tscript:" is a real evasion. */
function mdSafeUrl(u){
  if(!u) return false;
  const s = String(u).replace(/[\u0000-\u0020\u007f]/g, "").toLowerCase();
  if(/^(https?:|mailto:|#|\/|\.\/|\.\.\/)/.test(s)) return true;
  return !/^[a-z][a-z0-9+.-]*:/.test(s);   /* no scheme at all is fine */
}
/* class is allowed on code/pre only for marked's own language-xxx label. */
function mdSafeClass(v){
  return String(v).split(/\s+/).filter(c => /^language-[\w+#.-]+$/.test(c)).join(" ");
}
function mdSanitize(html){
  const doc = new DOMParser().parseFromString(
    "<body>" + String(html) + "</body>", "text/html");
  const body = doc.body;
  /* Snapshot first: the tree is about to be rewritten underneath us. */
  Array.prototype.slice.call(body.querySelectorAll("*")).forEach(el => {
    if(!el.parentNode) return;                 /* already taken with a parent */
    const tag = (el.tagName || "").toLowerCase();
    if(MD_KILL_TAGS.has(tag)){ el.remove(); return; }
    if(!MD_OK_TAGS.has(tag)){                  /* unknown: keep the words */
      const p = el.parentNode;
      while(el.firstChild) p.insertBefore(el.firstChild, el);
      el.remove(); return;
    }
    const ok = MD_OK_ATTRS[tag] || null;
    Array.prototype.slice.call(el.attributes).forEach(at => {
      const n = at.name.toLowerCase();
      if(!ok || !ok.has(n)){ el.removeAttribute(at.name); return; }
      if(n === "href" || n === "src"){
        if(!mdSafeUrl(at.value)) el.removeAttribute(at.name);
      }else if(n === "class"){
        const keep = mdSafeClass(at.value);
        if(keep) el.setAttribute("class", keep); else el.removeAttribute("class");
      }
    });
    /* A link that lost its href is still a link to nowhere; leave the text. */
    if(tag === "a" && !el.getAttribute("href")){
      const p = el.parentNode;
      while(el.firstChild) p.insertBefore(el.firstChild, el);
      el.remove();
    }
  });
  return body.innerHTML;
}
/* One call: source in, safe HTML out. Parsed ONCE, here, and never again. */
function mdRender(src){
  if(typeof marked === "undefined") return null;
  try{
    return mdSanitize(marked.parse(String(src), {gfm:true, breaks:false}));
  }catch(e){ return null; }
}

/* ---------- phase 2: one source of truth ----------
   Walk the rendered text nodes, wrap every word in a span, and build the
   string the voice receives FROM THOSE SPANS. Speech and highlight then share
   one coordinate system by construction rather than by careful agreement.

   Sentences are split on the RENDERED TEXT. The Markdown source is never
   split, never sent to a voice, and never seen by the reader.

   The DOM and the spoken string deliberately DIFFER in their whitespace: the
   page keeps whatever spacing it needs to look right, while the spoken string
   collapses runs to a single space. That is not a mismatch, because nothing
   maps by comparing text - every word span carries its own [s,e) offsets into
   the spoken string, recorded as the string is built. */
/* A block ends a line in the spoken string, and the server turns that into a
   sentence break. TD and TH are NOT here: a table reads far better as one row
   per sentence with the cells separated inside it than as one sentence per
   cell, which would make "Stage" and "Cost" two things to listen to. */
const MD_BLOCKS = new Set(["P","DIV","H1","H2","H3","H4","H5","H6","UL","OL",
  "LI","BLOCKQUOTE","PRE","HR","TABLE","THEAD","TBODY","TFOOT","TR"]);
/* Tags that hold other blocks and never hold prose of their own. Whitespace
   sitting directly inside one of these is the parser's own line breaks. */
const MD_CONTAINERS = new Set(["TABLE","THEAD","TBODY","TFOOT","TR","UL","OL",
  "DIV","BLOCKQUOTE"]);

function mdBuild(root){
  const spans = [], gaps = [];
  let out = "";
  /* A block boundary becomes a blank line, which is what the sentence
     splitter and the old cleaner both expect to see between paragraphs. */
  function gap(){
    if(!out) return;
    if(/\n\n$/.test(out)) return;
    out += /\n$/.test(out) ? "\n" : "\n\n";
  }
  /* Returns true when a space was actually added, which is how the caller
     knows whether this whitespace is worth a span of its own. */
  function space(){
    if(out && !/\s$/.test(out)){ out += " "; return true; }
    return false;
  }
  /* Whitespace INSIDE a sentence gets a span too, so the sentence highlight
     is a continuous band rather than a row of separately lit words with pale
     gaps between them. Gaps are kept apart from the word spans: the word
     spans are the contract phase 2 established and nothing else may enter
     that list. Structural whitespace BETWEEN blocks never becomes a gap,
     because the block boundary has already ended the line. */
  function gapSpan(tn, s){
    const g = tn.ownerDocument.createElement("span");
    g.className = "g";
    g.textContent = tn.nodeValue;
    gaps.push({el: g, s: s, e: out.length});
    return g;
  }
  function wrapText(tn){
    const text = tn.nodeValue;
    if(!text) return;
    const doc = tn.ownerDocument;
    if(!/\S/.test(text)){
      /* Whitespace between two BLOCK-level siblings is structural, not a word
         gap: the newlines a parser leaves between <th> cells or between <li>
         items are formatting of the HTML, not spacing of the prose. Spoken as
         a space they produce "Stage , Cost " with a gap before the comma.
         The block boundary has already done the separating. */
      const par = (tn.parentNode && tn.parentNode.tagName || "").toUpperCase();
      if(MD_CONTAINERS.has(par)) return;
      const s = out.length;
      if(space()){
        const g = gapSpan(tn, s);
        tn.parentNode.replaceChild(g, tn);
      }
      return;
    }
    const frag = doc.createDocumentFragment();
    const re = /\S+/g;
    let m, last = 0;
    function emitGap(a, b){
      const piece = doc.createTextNode(text.slice(a, b));
      const s = out.length;
      if(space()){
        const g = doc.createElement("span");
        g.className = "g"; g.textContent = text.slice(a, b);
        gaps.push({el: g, s: s, e: out.length});
        frag.appendChild(g);
      }else{
        frag.appendChild(piece);
      }
    }
    while((m = re.exec(text)) !== null){
      if(m.index > last) emitGap(last, m.index);
      const s = out.length;
      const w = doc.createElement("span");
      w.className = "w";
      w.textContent = m[0];
      frag.appendChild(w);
      out += m[0];
      spans.push({el: w, s: s, e: out.length});
      last = m.index + m[0].length;
    }
    if(last < text.length) emitGap(last, text.length);
    tn.parentNode.replaceChild(frag, tn);
  }
  function walk(node){
    /* A snapshot, because wrapText replaces the very node being visited and
       a live childNodes list would skip half the document. */
    const kids = Array.prototype.slice.call(node.childNodes);
    for(let i = 0; i < kids.length; i++){
      const c = kids[i];
      if(c.nodeType === 3){ wrapText(c); continue; }
      if(c.nodeType !== 1) continue;
      const tag = c.tagName.toUpperCase();
      if(tag === "BR"){ if(out && !/\n$/.test(out)) out += "\n"; continue; }
      /* AN IMAGE SPEAKS NOTHING, not even its alt text. Alt text has no text
         node and therefore no span, and a word with no span is a word the
         highlight cannot follow and the reader cannot see coming. Speaking it
         would break the one rule phase 2 exists to keep. The picture is on
         the screen; it does not need narrating. */
      if(tag === "IMG"){ continue; }
      /* A FENCED CODE BLOCK IS NOT READ ALOUD. Thirty lines of Python spoken
         by a voice is not reading, it is noise, and it is the single fastest
         way to make a long article unlistenable. It stays fully VISIBLE and
         is simply stepped over. Inline `code` is different and is still
         spoken, because it is usually one word inside a sentence. */
      if(tag === "PRE"){ gap(); continue; }
      /* Cells inside a row are separated rather than broken apart, so a row
         reads as one thing: "Stage, Cost". The separator is two characters
         nobody typed, so it owns no span and lights nothing, which is the
         same treatment whitespace already gets. */
      if(tag === "TD" || tag === "TH"){
        if(out && !/\n$/.test(out) && !/,\s$/.test(out)) out += ", ";
        walk(c);
        continue;
      }
      const block = MD_BLOCKS.has(tag);
      if(block) gap();
      walk(c);
      if(block) gap();
    }
  }
  walk(root);
  /* No carriage returns, ever: the server normalises \r\n to \n before it
     splits, and that would move every offset out from under the spans. */
  out = out.replace(/\r/g, "");
  return {spoken: out.trim(), spans: spans, gaps: gaps, raw: out};
}

/* Parse once, wrap once. Returns a DETACHED root whose nodes are moved into
   the page later - moved, not re-parsed, so there is exactly one parse per
   text no matter how often the view is rebuilt. */
function mdPrepare(src){
  if(!src || !looksLikeMarkdown(src)) return null;
  const html = mdRender(src);
  if(html === null) return null;
  const root = document.createElement("div");
  root.innerHTML = html;
  const built = mdBuild(root);
  if(!built.spoken.trim()) return null;
  /* mdBuild trims the ends; the spans were numbered against the untrimmed
     string, so shift them back onto the trimmed one. */
  const lead = built.raw.length - built.raw.replace(/^\s+/, "").length;
  if(lead){
    for(let i = 0; i < built.spans.length; i++){
      built.spans[i].s -= lead; built.spans[i].e -= lead;
    }
    for(let i = 0; i < built.gaps.length; i++){
      built.gaps[i].s -= lead; built.gaps[i].e -= lead;
    }
  }
  return {root: root, spoken: built.spoken, spans: built.spans,
          gaps: built.gaps};
}

/* Which word spans belong to sentence [a,b). Offsets, never text matching. */
function mdSpansIn(spans, a, b){
  const out = [];
  for(let i = 0; i < spans.length; i++){
    if(spans[i].s >= a && spans[i].e <= b) out.push(spans[i]);
  }
  return out;
}

/* ---------- phase 3: the highlight, over the formatting ----------
   Nothing here re-renders anything. The sentence being read and the word
   being spoken are both a CLASS on spans that already exist, which is exactly
   what the app has always done for plain text; all that changes is that a
   sentence is now a RANGE of spans rather than one element wrapping them. */

/* Everything currently lit, so it can be put out without searching the page.
   Holding the elements is much cheaper than a querySelectorAll across a long
   document on every sentence change. */
const MDLIT = {band: [], now: []};

/* ---------- keeping up with the voice ----------
   A long sentence can run past the bottom of the screen, and then the word
   being spoken is lit somewhere nobody can see. Following the SENTENCE is not
   enough: a sentence can be taller than the window.

   So the word itself is watched. While it sits comfortably inside the reading
   area nothing moves at all, because a page that creeps on every word is far
   worse than one that never moves. Only when the word crosses an edge does the
   view jump, and it jumps to put the START OF THE SENTENCE near the top: the
   words just spoken above, the words about to come below.

   Since every sentence now begins at the top, a word can only fall off the
   bottom inside a sentence TALLER than the screen, and then the word itself
   is what gets brought up. Working out the sentence's own box is no longer
   needed and the function that did it has gone. */
let lastAutoScroll = 0;

/* ---------- the teleprompter rule ----------
   EVERY sentence begins at the top of the screen. Not only when it has
   wandered out of view: every one, every time, unconditionally.

   The old rule only moved when a sentence had already crossed an edge, which
   meant the reading line landed wherever the previous sentence happened to
   leave it, sometimes at the top, sometimes halfway down, sometimes at the
   very bottom with nothing after it. The eye had to search for the line each
   time. A teleprompter does not make you search: the line you are on is
   always in the same place, and everything below it is what is coming.

   TOP_PAD is how far below the top edge the sentence sits. A little air, so
   the first line is not jammed against the frame.

   This is never throttled. It is the main movement of the app, and a sentence
   change is a deliberate event, not the per-word chatter that the throttle
   exists to damp. */
const TOP_PAD = 12;

/* The jump is INSTANT. A smooth scroll is a small animation, and an animation
   is a delay by another name: the line slides for a few hundred milliseconds
   while the voice is already speaking it, so the eye arrives after the ear.
   It lands at once instead, and the page is simply where it should be.

   If a pause before the jump is wanted it is a SETTING, in seconds, rather
   than something baked into an easing curve. At 0.00 there is nothing at all
   between the sentence starting and the page moving.

   A pending delayed jump is cancelled the moment another sentence begins, so
   a fast passage cannot queue a row of jumps that all land together. */
let lagTimer = null;
function cancelLag(){ if(lagTimer){ clearTimeout(lagTimer); lagTimer = null; } }

function sentenceToTop(el, scroller){
  cancelLag();
  if(!el) return;
  const go = ()=>{
    lagTimer = null;
    const sc = $(scroller || "#readerScroll"); if(!sc) return;
    const r = el.getBoundingClientRect(), pr = sc.getBoundingClientRect();
    const delta = r.top - (pr.top + TOP_PAD);
    if(Math.abs(delta) < 2) return;      /* already there, do not jitter */
    lastAutoScroll = Date.now();
    sc.scrollBy({top: delta, behavior: "auto"});
  };
  const lag = +(ST.lag || 0);
  if(lag > 0) lagTimer = setTimeout(go, lag * 1000);
  else go();
}

function keepWordVisible(el, scroller){
  if(!el || ST.mode !== "read") return;
  const sc = $(scroller || "#readerScroll"); if(!sc) return;
  const now = Date.now();
  if(now - lastAutoScroll < 250) return;   /* never fight a scroll in progress */

  const pr = sc.getBoundingClientRect();
  const wr = el.getBoundingClientRect();
  if(wr.top >= pr.top + 8 && wr.bottom <= pr.bottom - 70) return;  /* visible */

  /* With every sentence starting at the top, a word can only fall off the
     bottom inside a sentence TALLER than the screen. There is no arrangement
     that shows all of such a sentence, so the word itself is brought up. The
     sentence is deliberately not used as the anchor here: it starts above the
     top edge by definition, and going back to it would undo the reading. */
  lastAutoScroll = now;
  sc.scrollBy({top: wr.top - (pr.top + TOP_PAD), behavior: "auto"});
}

function mdUnlight(){
  for(let i = 0; i < MDLIT.band.length; i++)
    MDLIT.band[i].classList.remove("lit", "litp");
  for(let i = 0; i < MDLIT.now.length; i++)
    MDLIT.now[i].classList.remove("now");
  MDLIT.band = []; MDLIT.now = [];
}

/* The band across sentence i: its words AND the spaces between them, so the
   highlight is continuous rather than striped. */
function mdBand(i){
  const r = (ST.spans || [])[i];
  if(!r) return [];
  const out = mdSpansIn(MD.spans, r[0], r[1]).map(o => o.el);
  const g = mdSpansIn(MD.gaps || [], r[0], r[1]).map(o => o.el);
  return out.concat(g);
}

function mdHighlight(i, paused){
  mdUnlight();
  const band = mdBand(i);
  if(!band.length) return;
  const cls = paused ? "litp" : "lit";
  for(let k = 0; k < band.length; k++) band[k].classList.add(cls);
  MDLIT.band = band;
  /* Scroll to the FIRST word of the sentence. The band is not one element, so
     there is no single box to bring into view. */
  /* The band is not one element, so the first word of the sentence is what
     goes to the top. Same rule, same place on the screen. */
  sentenceToTop(band[0]);
}

/* The word timings arrive as character offsets into ST.sentences[i], which is
   the sentence STRIPPED. The spans are numbered against the whole spoken
   string. So a token at offset s inside sentence i sits at range[0] + lead + s
   in the spoken string, where lead is the whitespace strip() removed from the
   front. Getting that shift wrong moves every word by a word. */
function mdWordSpans(i){
  if(wordCache.has(i)) return wordCache.get(i);
  const toks = boundsCache.get(i);
  if(!toks || !toks.length) return [];
  const r = (ST.spans || [])[i];
  if(!r || typeof ST.spoken !== "string") return [];
  const raw = ST.spoken.slice(r[0], r[1]);
  const lead = raw.length - raw.replace(/^\s+/, "").length;
  const out = [];
  for(let k = 0; k < toks.length; k++){
    const tok = toks[k];
    const a = r[0] + lead + tok.s, b = r[0] + lead + tok.e;
    /* A token can cover MORE THAN ONE span: "<code>x</code>." is one run of
       non-space in the spoken string but two spans. They light together.

       A token can also cover NO span at all. Speechify's speech marks are its
       own chunks, not word runs: a real sentence here produced a token of
       "Two\n" and then a token of "\n" on its own. The empty one is KEPT,
       with no elements, so this array stays one for one with the server's
       timings. Dropping it would slide every later index up by one and the
       highlight would run a word ahead of the voice for the rest of the
       sentence. With it kept, the pause simply lights nothing, which is what
       is actually happening. */
    const els = [];
    for(let j = 0; j < MD.spans.length; j++){
      const sp = MD.spans[j];
      if(sp.s < b && sp.e > a) els.push(sp.el);
    }
    out.push({els: els, t: tok.t, d: (tok.d != null ? tok.d : tok.t)});
  }
  wordCache.set(i, out);
  return out;
}

function mdHighlightWordAt(i, mediaTime){
  const spans = mdWordSpans(i);
  if(!spans.length) return;
  const t = mediaTime + WORD_LEAD + curOffsetSec();
  let lo = 0, hi = spans.length - 1, k = -1;
  while(lo <= hi){
    const m = (lo + hi) >> 1;
    if(spans[m].t <= t){ k = m; lo = m + 1; } else { hi = m - 1; }
  }
  if(k === spans.length - 1 && spans[k].d != null && t > spans[k].d + 0.12) k = -1;
  if(k === CLK.lastWord) return;
  CLK.lastWord = k;
  for(let j = 0; j < MDLIT.now.length; j++) MDLIT.now[j].classList.remove("now");
  MDLIT.now = (k >= 0) ? spans[k].els.slice() : [];
  if(MDLIT.now && MDLIT.now.length) keepWordVisible(MDLIT.now[0]);
  for(let j = 0; j < MDLIT.now.length; j++) MDLIT.now[j].classList.add("now");
}

/* Tapping a word reads from that sentence, which is what tapping a sentence
   has always done in plain text. Without this a Markdown text cannot be
   started from the middle at all. */
function mdSentenceAt(el){
  const r = ST.spans || [];
  let hit = null;
  for(let j = 0; j < MD.spans.length; j++) if(MD.spans[j].el === el) hit = MD.spans[j];
  if(!hit) for(let j = 0; j < (MD.gaps||[]).length; j++)
    if(MD.gaps[j].el === el) hit = MD.gaps[j];
  if(!hit) return -1;
  for(let i = 0; i < r.length; i++)
    if(hit.s >= r[i][0] && hit.e <= r[i][1]) return i;
  return -1;
}

/* What the current text turned out to be, and the spans it was built from.
   `pending` carries the parse made before /api/prepare was called across to
   renderDoc, so the nodes are MOVED into the page rather than parsed twice. */
const MD = {on:false, root:null, spans:[], gaps:[], spoken:"",
            pending:null, mapped:false};

/* ---------- rendering the document ---------- */
function renderDoc(){
  const doc = $("#doc"); doc.innerHTML = ""; wordCache.clear();
  /* PHASE 2. The Markdown was parsed ONCE, before /api/prepare was called,
     and its words were wrapped in spans then. Those very nodes are MOVED into
     the page here - not parsed again, not re-serialised - so there is exactly
     one parse per text however often the view is rebuilt.

     Reading never re-renders. Highlighting is a class on a span.

     The plain path below is untouched: a text that is not Markdown takes the
     same road it always has, one .sent span per sentence. */
  let pre = MD.pending; MD.pending = null;
  MD.on = false; MD.root = null; MD.spans = []; MD.gaps = [];
  MD.spoken = ""; MD.mapped = false;
  try{ mdUnlight(); }catch(e){}
  /* A source editor left holding the PREVIOUS text would commit that text
     over this one the moment EDIT was left. */
  const _ta = $("#mdEdit"); if(_ta){ _ta.value = ""; _ta.classList.remove("on"); }
  doc.classList.remove("mdhidden");
  /* Opened from the Archive there is no pending parse, so build one now from
     the source the payload carried. */
  if(!pre && ST.source && looksLikeMarkdown(ST.source)) pre = mdPrepare(ST.source);
  if(pre){
    MD.on = true; MD.root = pre.root; MD.spans = pre.spans;
    MD.gaps = pre.gaps || []; MD.spoken = pre.spoken;
    /* The spans were numbered against OUR string. The sentence offsets came
       from the server, numbered against ITS string. If the two are not the
       same string the offsets mean nothing, so the text is still shown
       formatted but nothing is mapped, rather than mapped wrongly. That can
       only happen if the parser changed under a text already in the library. */
    MD.mapped = (typeof ST.spoken === "string" && ST.spoken === pre.spoken);
    while(pre.root.firstChild) doc.appendChild(pre.root.firstChild);
    doc.classList.add("md");
    prefetch(0); prefetch(1); prefetch(2);
    return;
  }
  doc.classList.remove("md");
  ST.sentences.forEach((s,i)=>{
    const span = document.createElement("span");
    span.className = "sent"; span.dataset.i = i;
    span.textContent = s + " ";
    /* Clicking a sentence reads from that sentence. Clicking the one already
       playing pauses and resumes it, so the old tap-to-pause gesture still
       works where the eye already is. A drag is a sentence step, not a click,
       so it is filtered out first. */
    /* THE ONLY GESTURE ON THE TEXT. Scroll it with a finger, tap a sentence
       to read from there. Nothing else: no swipe between sentences, no tap to
       paste, no tap to pause. Every one of those fired by accident while a
       finger was only trying to scroll, and someone who is listening should
       not have to be careful where he touches. */
    span.onclick = ()=>{ jumpTo(i, true); };
    doc.appendChild(span);
  });
  // start synthesising the opening sentences straight away
  prefetch(0); prefetch(1); prefetch(2);
}
function sentEl(i){ return $(`#doc .sent[data-i="${i}"]`); }


function ensureWordSpans(i){
  if(MD.mapped) return mdWordSpans(i);
  if(wordCache.has(i)) return wordCache.get(i);
  const el = sentEl(i); if(!el) return [];
  const tokens = boundsCache.get(i);
  if(!tokens || !tokens.length) return [];      /* timings not loaded yet */
  const text = ST.sentences[i];
  el.textContent = ""; const spans = []; let p = 0;
  tokens.forEach(tok=>{
    if(tok.s > p) el.appendChild(document.createTextNode(text.slice(p, tok.s)));
    const w = document.createElement("span");
    w.className = "w"; w.textContent = text.slice(tok.s, tok.e);
    el.appendChild(w); spans.push({el:w, t:tok.t, d:(tok.d!=null?tok.d:tok.t)}); p = tok.e;
  });
  if(p < text.length) el.appendChild(document.createTextNode(text.slice(p)));
  el.appendChild(document.createTextNode(" "));
  wordCache.set(i, spans); return spans;
}
function highlightWordAt(i, mediaTime){
  if(MD.mapped) return mdHighlightWordAt(i, mediaTime);
  const spans = wordCache.get(i) || ensureWordSpans(i);
  if(!spans || !spans.length) return;
  /* `mediaTime` is the predicted media-clock time (seconds). Add the small
     perceptual lead and the user's per-voice nudge, then binary-search for the
     last word whose start is <= t. Binary search keeps this O(log n) so even a
     very long sentence highlights with zero cost per frame. */
  const t = mediaTime + WORD_LEAD + curOffsetSec();
  let lo = 0, hi = spans.length - 1, k = -1;
  while(lo <= hi){
    const m = (lo + hi) >> 1;
    if(spans[m].t <= t){ k = m; lo = m + 1; } else { hi = m - 1; }
  }
  /* release the final word once the clip is clearly past its end, so it does
     not stay stuck lit; the sentence-level highlight remains. */
  if(k === spans.length - 1 && spans[k].d != null && t > spans[k].d + 0.12){
    k = -1;
  }
  if(k === CLK.lastWord) return;          /* nothing changed: skip DOM writes */
  CLK.lastWord = k;
  spans.forEach((o, wi)=> o.el.classList.toggle("now", wi === k));
  if(k >= 0) keepWordVisible(spans[k].el);
}
function clearWords(i){
  cancelLag();
  CLK.lastWord = -2;
  if(MD.mapped){
    for(let j = 0; j < MDLIT.now.length; j++) MDLIT.now[j].classList.remove("now");
    MDLIT.now = []; return;
  }
  const sp = wordCache.get(i); if(sp) sp.forEach(o=>o.el.classList.remove("now"));
}

/* ---------- highlight ---------- */
function highlight(i, paused){
  CLK.lastWord = -2;
  /* A Markdown text has no .sent elements: a sentence is a RANGE of word
     spans. Same idea, same classes, different container. */
  if(MD.mapped){ mdHighlight(i, paused); updateCounter(); return; }
  document.querySelectorAll("#doc .sent.active, #doc .sent.paused")
    .forEach(e=>e.classList.remove("active","paused"));
  const el = sentEl(i); if(!el) return;
  el.classList.add(paused ? "paused" : "active");
  sentenceToTop(el);
  updateCounter();
}
/* ---------- how long is left ----------
   Nothing knows the true length of a text until every clip has been made,
   and making them all up front would defeat the point of a cache that only
   builds what is needed. So this measures what it can and reasons about the
   rest: any sentence already spoken has a real duration in the bounds cache,
   and the ratio of seconds to characters from those is applied to the
   sentences not yet made. Before anything has been spoken it falls back to
   about fourteen and a half characters a second, which is close enough for a
   number that is only ever a guide.

   The two pauses and the speed are all folded in, because a two second pause
   between words on a long text is not a rounding error, it is half an hour. */
function estRate(){
  let mc = 0, ms = 0;
  (ST.sentences || []).forEach((s, i) => {
    const t = boundsCache.get(i);
    if(t && t.length){ mc += (s || "").length; ms += t[t.length - 1].d || 0; }
  });
  return (mc > 60 && ms > 0) ? (ms / mc) : (1 / 14.5);
}
function estSeconds(from){
  const S = ST.sentences || [];
  if(!S.length) return 0;
  const rate = estRate(), sp = Math.max(0.25, ST.speed || 1);
  let sec = 0, n = 0;
  for(let i = Math.max(0, from | 0); i < S.length; i++){
    const s = S[i] || "";
    sec += (s.length * rate) / sp;
    n++;
  }
  sec += Math.max(0, n - 1) * (ST.gap || 0);   /* may be negative: overlap */
  return Math.max(0, sec);
}
function fmtTime(s){
  s = Math.round(s);
  if(s < 1) return "0:00";
  const h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60), q = s % 60;
  const pad = v => String(v).padStart(2, "0");
  return h ? (h + ":" + pad(m) + ":" + pad(q)) : (m + ":" + pad(q));
}
function updateCounter(){
  const n = ST.sentences.length, el = $("#counter");
  if(el){
    el.innerHTML = (n ? (ST.idx + 1) : 0) + " / " + n +
                   "<b>" + (n ? fmtTime(estSeconds(ST.idx)) : "0:00") + "</b>";
  }
  $("#barFill").style.width = (n? ((ST.idx)/(n))*100 : 0) + "%";
}

function follow(){
  rafId = null;
  if(!ST.playing){ return; }
  const el = active();
  /* advance our predicted media clock from the element's (coarsely updating)
     currentTime, then highlight from the smooth prediction */
  /* word gap first: it may have changed the rate this clip is running at, or
     stopped it dead inside a quiet, and the clock has to be told which. */
  const wf = wordGap(WG, el, silCache.get(ST.idx), ()=>ST.playing);
  const mt = clockSample(el.currentTime || 0, ST.speed * wf, wf !== 0);
  if(ST.wordhl){ highlightWordAt(ST.idx, mt); }
  /* Hand the sentence over ourselves instead of waiting for the browser to
     fire 'ended'. That event arrives late and by an amount that varies clip
     to clip, and it was a real part of the stutter: by the time it landed,
     nothing was being asked to play. We cross a hair before the end (or, on a
     negative gap, that much earlier still) and only once the next clip is
     genuinely decoded and waiting, so the two run into each other seamlessly. */
  const dur = el.duration;
  if(!handedOff && ST.gap <= 0 && dur && isFinite(dur)){
    const ni = ST.idx + 1;
    const cross = dur + Math.min(ST.gap, -HANDOFF_LEAD);
    if(ni < ST.sentences.length && el.currentTime >= cross && nextReady(ni)){
      /* on a negative sentence pause this clip keeps sounding under the next
         one, so make sure it is running at the plain speed as it goes. */
      try{ el.playbackRate = ST.speed; }catch(e){}
      handedOff = true; startAt(ni, true); return;
    }
  }
  const frac = el.duration ? el.currentTime/el.duration : 0;
  const n = ST.sentences.length;
  $("#barFill").style.width = (n? ((ST.idx+frac)/n)*100 : 0) + "%";
  rafId = requestAnimationFrame(follow);
}

/* ---------- prefetch ----------
   The audio for a sentence is synthesised by the server on first request, so
   if we only ask for it when it is needed the player sits in silence waiting.
   v23 fetched each clip ahead of time and then threw the bytes away, trusting
   the browser cache to still have them. It usually did, but a cache lookup is
   not free and a revalidation round trip certainly is not, so every sentence
   change paid a small unpredictable tax and the reading kept catching. Now the
   fetched body is kept as a blob URL: setting src on it touches no network and
   no disk at all. Three sentences are held ready at all times, and the ones
   far behind are released so a long text does not accumulate every clip. */
const PREFETCH_AHEAD = 3;       // sentences kept fetched ahead of the one playing
const HANDOFF_LEAD = 0.04;      // cross to the next clip this early, in seconds
const warmed = new Map();       // "tid/vkey/idx" -> promise, so we ask only once
const clipUrls = new Map();     // "tid/vkey/idx" -> blob: URL of the finished mp3
function warmKey(i){ return ST.tid+"/"+ST.vkey+"/"+i; }
function clearWarm(){
  warmed.clear();
  clipUrls.forEach(u=>{ try{ URL.revokeObjectURL(u); }catch(e){} });
  clipUrls.clear();
  armed = { slot:-1, idx:-1 }; armWanted = -1;
}
function clipSrc(i){
  const k = warmKey(i);
  return clipUrls.has(k) ? clipUrls.get(k) : audioUrl(i);
}
function warmUnit(i){
  if(i<0 || i>=ST.sentences.length || !ST.tid) return Promise.resolve();
  const k = warmKey(i);
  if(warmed.has(k)) return warmed.get(k);
  const p = api(audioUrl(i))
    .then(r => r.ok ? r.blob() : null)
    .then(b => {
      if(!b) return null;
      const u = URL.createObjectURL(b);
      clipUrls.set(k, u);
      // it may have landed after we tried to arm it; arm it now that it is here
      if(armWanted === i && armed.idx !== i) armNext(ST.idx);
      return u;
    })
    .catch(()=>{ warmed.delete(k); return null; });
  warmed.set(k, p);
  return p;
}
function prefetch(i){
  if(i<0 || i>=ST.sentences.length) return;
  if(!boundsCache.has(i)){
    api(boundsUrl(i)).then(r=>r.ok?r.json():{tokens:[]})
      .then(d=>{ boundsCache.set(i,(d&&d.tokens)||[]);
                 silCache.set(i,(d&&d.sil)||[]); }).catch(()=>{});
  }
  warmUnit(i);
}
/* keep three sentences ready while the current one plays */
function prefetchAhead(i){
  for(let k=1;k<=PREFETCH_AHEAD;k++) prefetch(i+k);
  trimClips(i);
}
function trimClips(i){
  const pre = ST.tid+"/"+ST.vkey+"/";
  clipUrls.forEach((u,k)=>{
    const n = parseInt(k.slice(k.lastIndexOf("/")+1),10);
    if(!k.startsWith(pre) || n < i-3 || n > i+PREFETCH_AHEAD+2){
      try{ URL.revokeObjectURL(u); }catch(e){}
      clipUrls.delete(k); warmed.delete(k);
    }
  });
}
/* ---------- the spare element ----------
   While one sentence speaks, the next is loaded into an element that is not
   playing and left sitting at readyState 4. The handover is then a swap and a
   play() on the same tick, with nothing to fetch and nothing to decode. */
function freeSlot(){
  for(let k=1;k<players.length;k++){
    const s = (cur+k) % players.length;
    if(s !== armed.slot && players[s].paused) return s;
  }
  for(let k=1;k<players.length;k++){
    const s = (cur+k) % players.length;
    if(players[s].paused) return s;
  }
  return (cur+1) % players.length;
}
function armNext(i){
  const ni = i + 1;
  armWanted = ni;
  if(ni >= ST.sentences.length){ armed = { slot:-1, idx:-1 }; return; }
  if(armed.idx === ni && armed.slot >= 0 && armed.slot !== cur) return;
  const slot = freeSlot();
  if(slot === cur) return;
  const el = players[slot];
  try{ el.pause(); }catch(e){}
  el.onended = null; el.onerror = null;
  el.src = clipSrc(ni);
  el.playbackRate = ST.speed; el.volume = ST.volume/100;
  try{ el.load(); }catch(e){}
  armed = { slot: slot, idx: ni };
}
function nextReady(ni){
  if(armed.idx !== ni || armed.slot < 0) return false;
  return players[armed.slot].readyState >= 3;   // HAVE_FUTURE_DATA
}
function silenceOthers(){
  players.forEach((p,k)=>{ if(k!==cur){ try{ p.pause(); }catch(e){} } });
}

/* ---------- the pause between words ----------
   `runs` is the clip's silence map from the server: [[from,to],...] seconds,
   every quiet stretch that sits between two words rather than inside one. The
   server found them with the same two-band envelope the word highlight is
   built on, and pulled each one in by 18 ms at both ends, so a run's start is
   already safely inside real silence and never on the tail of an s or an f.

   Both players keep their own little state object, because online and offline
   can never be speaking at the same time but the offline one has its own
   audio element. `held` is the index of the run we have already waited in, so
   we stop once per silence rather than once per frame. */
function makeWG(){ return { hold:null, held:-1 }; }
const WG = makeWG(), OWG = makeWG();
function wgReset(w){
  if(w.hold){ clearTimeout(w.hold); w.hold = null; }
  w.held = -1;
}
function wgRunAt(runs, t){        /* binary search: zero cost per frame */
  let lo = 0, hi = runs.length - 1;
  while(lo <= hi){
    const m = (lo + hi) >> 1;
    if(t < runs[m][0]) hi = m - 1;
    else if(t > runs[m][1]) lo = m + 1;
    else return m;
  }
  return -1;
}
/* Returns 1 while the clip is running and 0 while it is stopped inside a
   silence. The caller feeds that straight to the media clock, so the word
   highlight stands still exactly as long as the voice does.

   Note what is NOT here any more: playbackRate. It is never read and never
   written on this path. The clip plays at the speed the speed control set and
   at no other speed, ever. The only thing this function can do is stop it and
   start it again, and it only ever does that inside measured silence. */
function wordGap(w, el, runs, isOn){
  return 1;                                 /* the word pause was removed */
  /* eslint-disable no-unreachable */
  if(w.hold) return 0;
  if(!ST.wgap) return 1;
  if(!runs || !runs.length) return 1;       /* nothing measured for this clip */
  const k = wgRunAt(runs, el.currentTime || 0);
  if(k < 0) return 1;                       /* we are inside a word */
  if(k === w.held) return 1;                /* already waited in this one */
  /* We are inside a between-word silence we have not stopped in yet. Stop
     here, at the start of it rather than in the middle, because the run has
     already been trimmed inward and its start is the earliest moment that is
     certainly quiet. Then start again after the wait. */
  w.held = k;
  try{ el.pause(); }catch(e){}
  w.hold = setTimeout(()=>{
    w.hold = null;
    if(isOn()){ const p = el.play(); if(p && p.catch) p.catch(()=>{}); }
  }, ST.wgap * 1000);
  return 0;
}
function loadBounds(i){
  if(boundsCache.has(i)) return Promise.resolve(boundsCache.get(i));
  return api(boundsUrl(i)).then(r=>r.ok?r.json():{tokens:[]})
    .then(d=>{ const t=(d&&d.tokens)||[]; boundsCache.set(i,t);
               silCache.set(i,(d&&d.sil)||[]); return t; })
    .catch(()=>{ boundsCache.set(i,[]); silCache.set(i,[]); return []; });
}

/* ---------- core playback ---------- */
function startAt(i, viaHandoff){
  atEnd = false;
  stopOffline();
  cancelGap(); wgReset(WG); i = clampIdx(i);
  let el;
  if(armed.idx === i && armed.slot >= 0 && armed.slot !== cur){
    cur = armed.slot; el = players[cur];   /* already loaded and waiting */
    armed = { slot:-1, idx:-1 };
  } else {
    cur = freeSlot(); el = players[cur];
    if(armed.slot === cur) armed = { slot:-1, idx:-1 };
    try{ el.pause(); }catch(e){}
    el.onended = null; el.onerror = null;
    el.src = clipSrc(i);
  }
  /* a jump or a fresh start silences everything else; a handover deliberately
     does not, because on a negative gap the previous clip is still speaking */
  if(!viaHandoff) silenceOthers();
  try{ el.currentTime = 0; }catch(e){}
  ST.idx = i; ST.playing = true; handedOff = false;
  highlight(i, false); setPlayIcon(true);
  el.playbackRate = ST.speed; el.volume = ST.volume/100;
  clockReset(0);                          /* fresh sentence: restart the clock */
  const seq = ++playSeq;
  el.onended = ()=> onEnded(i, seq);
  el.onerror = ()=> setStatus("Could not load sentence "+(i+1)+".");
  loadBounds(i).then(()=>{ if(ST.wordhl && ST.idx===i) ensureWordSpans(i); });
  prefetchAhead(i);
  armNext(i);
  const p = el.play(); if(p && p.catch) p.catch(()=>{});
  if(!rafId) rafId = requestAnimationFrame(follow);
  setStatus("");
}
/* A text that has finished is FINISHED. Pressing play on it starts the text
   again from the beginning rather than replaying the last sentence, which is
   the only reading of the button that makes sense once the end is reached.
   A FLAG rather than an inference: "on the last sentence and its audio has
   ended" is also true after a deliberate jump to the last sentence, and those
   two situations deserve different answers. */
let atEnd = false;
function onEnded(i, seq){
  if(!ST.playing) return;
  if(seq !== playSeq) return;   /* an overlapped predecessor finishing: ignore */
  if(handedOff) return;         /* follow() already crossed over */
  const ni = i + 1;
  if(ni >= ST.sentences.length){
    if(ST.loop){ startAt(0); return; }
    atEnd = true;
    ST.playing = false; setPlayIcon(false); highlight(i, true);
    setStatus("Finished."); return;
  }
  if(ST.gap > 0){
    highlight(i, true);
    gapTimer = setTimeout(()=>{ gapTimer=null; if(ST.playing) startAt(ni); },
                          ST.gap*1000);
  } else { startAt(ni); }
}
function cancelGap(){ if(gapTimer){ clearTimeout(gapTimer); gapTimer=null; } }

function resume(){
  stopOffline();
  if(atEnd){ atEnd = false; jumpTo(0, true); return; }
  const el = active();
  if(el.src && el.currentTime>0 && !el.ended){
    ST.playing = true; setPlayIcon(true); highlight(ST.idx, false);
    el.playbackRate = ST.speed; el.volume = ST.volume/100;
    clockReset(el.currentTime);           /* re-anchor where we paused */
    el.play(); if(!rafId) rafId = requestAnimationFrame(follow); setStatus("");
    prefetchAhead(ST.idx); armNext(ST.idx);
  } else { startAt(ST.idx); }
}
function pause(){
  cancelGap(); ST.playing = false; setPlayIcon(false);
  players.forEach(p=>{ try{ p.pause(); }catch(e){} });
  highlight(ST.idx, true); setStatus("Paused.");
}
function togglePlay(){ if(ST.playing) pause(); else resume(); }
function stop(){
  /* deliberately NOT clearing atEnd: stopping a text that has already
     finished leaves it finished, so play still starts it again from the top */
  cancelGap(); ST.playing = false; setPlayIcon(false);
  players.forEach(p=>{ try{ p.pause(); p.currentTime=0; }catch(e){} });
  highlight(ST.idx, true); clearWords(ST.idx);
  $("#barFill").style.width = (ST.idx/Math.max(1,ST.sentences.length))*100 + "%";
  setStatus("Stopped.");
}
function jumpTo(i, play){
  atEnd = false;
  i = clampIdx(i); ST.idx = i; cancelGap();
  handedOff = false; armed = { slot:-1, idx:-1 };
  if(play){ startAt(i); }
  else{
    players.forEach(p=>{ try{ p.pause(); }catch(e){} });
    ST.playing=false; setPlayIcon(false); highlight(i, true);
    clearWords(i); setStatus("");
  }
}
function prev(){ jumpTo(ST.idx-1, ST.playing); }
function next(){ jumpTo(ST.idx+1, ST.playing); }

/* ---------- tune ---------- */
// Tidal-style transport glyphs: filled play triangle, two rounded pause bars
const ICON_PLAY = '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M7 5.5v13a1 1 0 0 0 1.53.85l10.2-6.5a1 1 0 0 0 0-1.7L8.53 4.65A1 1 0 0 0 7 5.5z"/></svg>';
const ICON_PAUSE = '<svg viewBox="0 0 24 24" fill="currentColor"><rect x="6.4" y="4.8" width="3.9" height="14.4" rx="1.95"/><rect x="13.7" y="4.8" width="3.9" height="14.4" rx="1.95"/></svg>';
function setPlayIcon(on){ $("#playBtn").innerHTML = on ? ICON_PAUSE : ICON_PLAY;
  audioState(on); }

/* ---------- what the rest of the phone sees ----------
   Both readers funnel through setPlayIcon and offSetPlayIcon, so this is the
   one place that knows whether sound is coming out of this app, and it is
   where everything to do with the rest of the phone belongs.

   Two things happen here. The media session is kept honest, so the lock
   screen and a headphone button show and control the reader rather than
   something stale. And when playing stops, the background music can be handed
   back. See the note on /api/mediakey for why stopping the music is free and
   starting it again is not. */
let _bgWas = null;

function audioState(on){
  on = !!on;
  try{
    if("mediaSession" in navigator){
      navigator.mediaSession.playbackState = on ? "playing" : "paused";
    }
  }catch(e){}
  if(_bgWas === on) return;
  const first = (_bgWas === null);
  _bgWas = on;
  /* only on the falling edge, and never on the very first paint */
}

function mediaSetup(){
  if(!("mediaSession" in navigator)) return;
  const ms = navigator.mediaSession;
  const bind = (name, fn)=>{ try{ ms.setActionHandler(name, fn); }catch(e){} };
  /* Whichever reader is actually sounding is the one a headphone button
     drives. Falling back to which view is open would be wrong: the offline
     reader can be playing while its list is on screen. */
  const offOpen = ()=> OFF.playing ||
    (!ST.playing && !$("#offlineReaderView").classList.contains("hidden"));
  bind("play",  ()=> offOpen() ? offToggle() : togglePlay());
  bind("pause", ()=> offOpen() ? offToggle() : togglePlay());
  bind("previoustrack", ()=> offOpen() ? offPrev() : prev());
  bind("nexttrack",     ()=> offOpen() ? offNext() : next());
  bind("stop", ()=>{ try{ stop(); }catch(e){} try{ stopOffline(); }catch(e){} });
}

function mediaTitle(t, sub){
  if(!("mediaSession" in navigator)) return;
  try{
    navigator.mediaSession.metadata = new MediaMetadata({
      title: (t || "MA Reader").slice(0, 90),
      artist: sub || "MA Reader",
      album: "MA Reader"
    });
  }catch(e){}
}
function setText(sel, t){ const e=$(sel); if(e) e.textContent = t; }
function applySpeed(){
  const t = ST.speed.toFixed(2);
  { const e=$("#speedVal"); if(e) e.innerHTML = t+"&times;"; }
  setText("#spdNum", t); setText("#spdNum2", t);
  players.forEach(p=>p.playbackRate = ST.speed);
  try{ OFF.audio.playbackRate = ST.speed; OFF.audioB.playbackRate = ST.speed; }
  catch(e){}
  /* nothing to undo here in v3: the word pause never touches playbackRate,
     so this is the only place in the app that sets it. */
  try{ updateCounter(); }catch(e){}
}
function applyVolume(){
  $("#volVal").textContent = ST.volume+"%"; $("#volRange").value = ST.volume;
  players.forEach(p=>p.volume = ST.volume/100);
  try{ OFF.audio.volume = ST.volume/100; OFF.audioB.volume = ST.volume/100; }
  catch(e){}
}
function applyLag(){
  setText("#lagNum", ST.lag.toFixed(2));
}
function applyGap(){
  const t = ST.gap.toFixed(2);
  setText("#gapVal", t); setText("#gapNum", t); setText("#gapNum2", t);
  try{ updateCounter(); }catch(e){}
}
function applyWgap(){ /* the word pause was removed */ }
function applySize(){
  const fs = 13 + ST.size*2;                 // 15..41 px
  const col = 400 + ST.size*46;
  document.documentElement.style.setProperty("--read", fs+"px");
  document.documentElement.style.setProperty("--col", col+"px");
  const sv=$("#sizeVal"); if(sv) sv.textContent = fs;
  const sv2=$("#sizeVal2"); if(sv2) sv2.textContent = fs;
}
function applyFont(){
  document.documentElement.style.setProperty("--read-font", FONTS[ST.font]||FONTS.serif);
  document.querySelectorAll("#fontChips .chip").forEach(c=>
    c.classList.toggle("on", c.dataset.font===ST.font));
}
function applySpacing(){
  document.documentElement.style.setProperty("--read-lh", LH[ST.lineheight]||1.72);
  $("#lhVal").textContent = ST.lineheight;
}
function applyTheme(){
  document.body.dataset.theme = ST.theme;
  document.querySelector('meta[name=theme-color]').setAttribute("content",
    ST.theme==="day" ? "#f6f7fa" : ST.theme==="sepia" ? "#efe3cc" : "#080a10");
  document.querySelectorAll("#themeChips .chip").forEach(c=>
    c.classList.toggle("on", c.dataset.theme===ST.theme));
  if(typeof applyHiColors==="function") applyHiColors();
}
// three typed RGB colours drive the highlight: the sentence background, the
// word background, and the word's font colour. The active sentence's own text
// colour is chosen automatically (dark on a light highlight, light on a dark
// one) so the sentence always stays readable without a fourth control.
function clamp255(n){ n=parseInt(n,10); if(isNaN(n)) n=0; return Math.max(0,Math.min(255,n)); }
function rgbStr(a){ return "rgb("+a[0]+","+a[1]+","+a[2]+")"; }
function rgbaStr(a,al){ return "rgba("+a[0]+","+a[1]+","+a[2]+","+al+")"; }
function relLum(a){ return (0.299*a[0]+0.587*a[1]+0.114*a[2])/255; }
function rgbArr(k){ return k==="sent"?ST.rgbSent : k==="word"?ST.rgbWord : k==="font"?ST.rgbFont : ST.rgbText; }
function hexToRgb(h){
  h=(h||"").trim().replace("#","");
  if(h.length===3) h=h.split("").map(c=>c+c).join("");
  if(h.length!==6 || /[^0-9a-fA-F]/.test(h)) return null;
  return [parseInt(h.slice(0,2),16),parseInt(h.slice(2,4),16),parseInt(h.slice(4,6),16)];
}
// the reader text colour that the current theme would use, read live
function themeTextRgb(){
  return hexToRgb(getComputedStyle(document.body).getPropertyValue("--page-text")) || [205,208,214];
}
function syncRgbInputs(){
  const textVals = Array.isArray(ST.rgbText) ? ST.rgbText : themeTextRgb();
  [["sent",ST.rgbSent,"swSent"],["word",ST.rgbWord,"swWord"],
   ["font",ST.rgbFont,"swFont"],["text",textVals,"swText"]]
  .forEach(([k,a,sw])=>{
    document.querySelectorAll('input[data-rgb="'+k+'"]').forEach(inp=>{
      const i=+inp.dataset.i;
      if(document.activeElement!==inp) inp.value = a[i];
    });
    const el=document.getElementById(sw); if(el) el.style.background=rgbStr(a);
  });
  const ab=document.getElementById("textAuto");
  if(ab) ab.classList.toggle("on", !Array.isArray(ST.rgbText));
}
function applyHiColors(){
  const s=ST.rgbSent, w=ST.rgbWord, f=ST.rgbFont, b=document.body.style;
  // default reading text: explicit override, or leave it to the theme
  if(Array.isArray(ST.rgbText)) b.setProperty("--page-text", rgbStr(ST.rgbText));
  else b.removeProperty("--page-text");
  b.setProperty("--sent", rgbStr(s));
  b.setProperty("--sent-soft", rgbaStr(s,.34));
  b.setProperty("--sent-fg", relLum(s)>0.55 ? "#14160c" : "#f4f6ee");
  b.setProperty("--wordbg", rgbStr(w));
  b.setProperty("--wordfg", rgbStr(f));
  syncRgbInputs();
}
function applyWordHl(){
  document.body.classList.toggle("wordhl", ST.wordhl);
  $("#wordExp").classList.toggle("on", ST.wordhl);
  if(!ST.wordhl){ clearWords(ST.idx); return; }
  if(!ST.playing && ST.tid){
    loadBounds(ST.idx).then(()=>{ if(ST.wordhl)
      highlightWordAt(ST.idx, active().currentTime); });
  }
}
/* tap the number itself to come back to the resting value */
function resetTune(kind){
  if(kind==="speed"){ ST.speed = 1.0; applySpeed(); toast("Speed 1.00"); }
  else if(kind==="gap"){ ST.gap = 0.0; applyGap(); toast("Sentence pause 0.00"); }
  else if(kind==="lag"){ ST.lag = 0.0; applyLag(); toast("Jumps at once"); }

  else return;
  persist();
}
function step(kind, d){
  if(kind==="speed"){
    ST.speed = Math.max(SPEED_MIN, Math.min(SPEED_MAX,
                 Math.round((ST.speed + d*SPEED_STEP)*100)/100));
    applySpeed();
  } else if(kind==="gap"){
    ST.gap = Math.max(GAP_MIN, Math.min(GAP_MAX,
               Math.round((ST.gap + d*GAP_STEP)*100)/100));
    applyGap();
  } else if(kind==="lag"){
    ST.lag = Math.max(LAG_MIN, Math.min(LAG_MAX,
                Math.round((ST.lag + d*LAG_STEP)*100)/100));
    applyLag();
  } else if(kind==="size"){
    ST.size = Math.max(SIZE_MIN, Math.min(SIZE_MAX, ST.size + d)); applySize();
  } else if(kind==="lh"){
    ST.lineheight = Math.max(1, Math.min(5, ST.lineheight + d)); applySpacing();
  }
  persist();
}

/* ---------- modes / sheet ---------- */
function refreshToggles(){
  { const b=$("#fullPasteTog"); if(b) b.classList.toggle("on", !!ST.fullOnPaste); }
  { const b=$("#hideTabsTog"); if(b) b.classList.toggle("on", !!ST.hideTabs); }
  document.body.classList.toggle("notabs", !!ST.hideTabs);
  { const b=$("#floatTog"); if(b) b.classList.toggle("on", !!ST.floatPaste); }
  { const b=$("#floatFTog"); if(b) b.classList.toggle("on", !!ST.floatFull); }
  { const b=$("#floatSTog"); if(b) b.classList.toggle("on", !!ST.floatSwap); }
  { const b=$("#adbTog"); if(b) b.classList.toggle("on", !!ST.adbMode); }
  { const b=$("#chromeTog"); if(b) b.classList.toggle("on", ST.browser !== "auto"); }
  { const b=$("#voiceBarTog"); if(b) b.classList.toggle("on", !!ST.voiceBar); }
  document.body.classList.toggle("nobar", !ST.voiceBar);
  document.body.classList.toggle("hasfloat", !!ST.floatPaste);
  document.body.classList.toggle("hasfloatf", !!ST.floatFull);
  document.body.classList.toggle("hasfloats", !!ST.floatSwap);

  $("#autoplayTog").classList.toggle("on", ST.autoplay);
  { const r=$("#resumeTog"); if(r) r.classList.toggle("on", ST.resume); }
  $("#focusTog").classList.toggle("on", ST.focus);
  $("#readerView").classList.toggle("focus", ST.focus);
  $("#loopBtn").classList.toggle("on", ST.loop);
}
function openSheet(){
  $("#backdrop").classList.add("show"); $("#sheet").classList.add("show");
  document.body.classList.add("sheetopen");
}
/* Closing a sheet SAVES. There is no Done button any more, so every way out,
   the X, a tap outside, the back gesture, has to be a commit. Waiting for the
   250 ms timer would be a quarter second in which the phone can be put away
   and the change lost, which has happened before. */
function closeSheet(){
  $("#backdrop").classList.remove("show"); $("#sheet").classList.remove("show");
  document.body.classList.remove("sheetopen");
  try{ stopPreview(); }catch(e){}
  try{ stopCroPreview(); }catch(e){}
  try{ persistNow(); }catch(e){}
}

function setStatus(s){ $("#status").textContent = s || ""; }

/* ---------- views ---------- */
const V2_VIEWS = ["homeView","readerView","offlineView",
                 "offlineReaderView","helpView"];
function hideAllViews(){ setFullread(false);
  V2_VIEWS.forEach(id=>{ const e=$("#"+id);
  if(e) e.classList.add("hidden"); }); }
function setTab(name){ document.querySelectorAll("#tabs .tab").forEach(t=>
  t.classList.toggle("on", t.dataset.tab===name)); }
function showHome(){ hideAllViews(); $("#homeView").classList.remove("hidden");
  document.body.classList.remove("inreader");
  document.body.classList.add("onhome"); setTab("home"); loadLibrary(); }
function showReader(){ hideAllViews(); $("#readerView").classList.remove("hidden");
  document.body.classList.remove("onhome");
  document.body.classList.add("inreader"); setTab("home"); }
function showOfflineList(){ hideAllViews();
  $("#offlineView").classList.remove("hidden");
  document.body.classList.remove("inreader","onhome"); setTab("offline"); loadOffline(); }
function showOfflineReader(){ hideAllViews();
  $("#offlineReaderView").classList.remove("hidden");
  document.body.classList.remove("onhome","inreader"); setTab("offline"); }
function showHelp(){ hideAllViews(); $("#helpView").classList.remove("hidden");
  document.body.classList.remove("inreader","onhome"); setTab("help"); }
function goTab(name){
  if(name==="offline"){ showOfflineList(); }
  else if(name==="help"){ showHelp(); }
  else { showHome(); }
}

/* Done: stop everything, wipe the current reading session from memory, close
   any open settings, and drop back to the paste screen ready for fresh text.
   Settings (voice, speed, theme, fonts, etc.) are kept, only the text is reset. */
function doneReset(){
  cancelGap();
  ST.playing = false; setPlayIcon(false);
  players.forEach(p=>{ try{ p.pause(); p.currentTime=0; p.removeAttribute("src"); p.load(); }catch(e){} });
  if(rafId){ cancelAnimationFrame(rafId); rafId=null; }
  handedOff = false; clearWarm();
  boundsCache.clear(); silCache.clear(); wordCache.clear();
  ST.tid=""; ST.title=""; ST.sentences=[]; ST.idx=0;
  $("#doc").innerHTML=""; $("#readerTitle").textContent="";
  $("#barFill").style.width="0%"; updateCounter(); setStatus("");
  // also close any offline session so the X clears everything
  try{ stopOffline(); }catch(e){}
  OFF.man=null; OFF.name=""; OFF.sents=[]; OFF.idx=0; OFF.lastWord=-2;
  const od=$("#offDoc"); if(od) od.innerHTML="";
  const ot=$("#offTitle"); if(ot) ot.textContent="";
  markSession();
  closeSheet();
  $("#pasteBox").value=""; updatePasteHint();
  showHome();
  $("#pasteBox").focus();
  toast("Ready for a new text.");
}

/* ---------- open / prepare ---------- */
/* One place decides what /api/prepare is told. If the text is Markdown it is
   parsed and its words wrapped FIRST, and the string built from those spans
   travels with the request as `spoken`. The server splits THAT into sentences,
   so the voice and the highlight can never be reading two different texts.
   The parse is stashed for renderDoc, which moves the nodes into the page. */
function prepareBody(text){
  const pre = mdPrepare(text);
  MD.pending = pre;
  return JSON.stringify(pre ? {text: text, spoken: pre.spoken} : {text: text});
}
function openPayload(p, autoplay){
  stopOnline(); stopOffline();
  ST.tid = p.id; ST.title = p.title || "Untitled";
  ST.sentences = p.sentences || []; ST.idx = 0;
  /* What was pasted, markers and all. Older texts were saved already cleaned,
     so their source is plain and the detector will say so. */
  ST.source = p.source || "";
  /* The exact string the voice is given, and where each sentence sits inside
     it. Speech and highlight share these coordinates. */
  ST.spoken = (typeof p.spoken === "string") ? p.spoken : "";
  ST.spans  = Array.isArray(p.spans) ? p.spans : [];
  handedOff = false; clearWarm(); boundsCache.clear(); silCache.clear();
  $("#readerTitle").textContent = ST.title;
  renderDoc(); markSession(); updateCounter(); showReader();
  prefetchAhead(-1);
  if(autoplay){ startAt(0); }
  else{ highlight(0, true); setPlayIcon(false); ST.playing=false;
        setStatus("Press play to start."); }
}
function readPasted(){
  const text = $("#pasteBox").value;
  if(!text.trim()){ toast("Paste some text first."); return; }
  setStatus("Preparing...");
  api("/api/prepare", {method:"POST", headers:{"Content-Type":"application/json"},
       body: prepareBody(text)})
    .then(r=>r.json().then(j=>({ok:r.ok,j})))
    .then(({ok,j})=>{
      if(!ok){ toast(j.error||"Could not prepare."); return; }
      $("#pasteBox").value=""; updatePasteHint(); openPayload(j, ST.autoplay);
    }).catch(()=>toast("Server error."));
}

/* ---------- library ---------- */
let LIB_CACHE = [];
let LIB_SELECTING=false; const LIB_SEL=new Set();
function mkSelbox(sel){ const s=document.createElement("div");
  s.className="selbox"+(sel?" sel":""); s.innerHTML=sel?"&#10003;":""; return s; }
function libFiltered(){
  const q=($("#libSearch").value||"").trim().toLowerCase();
  return !q ? LIB_CACHE : LIB_CACHE.filter(m=>
    ((m.title||"")+" "+(m.summary||"")).toLowerCase().includes(q));
}
function renderLibrary(){
  const box = $("#libList"); box.innerHTML="";
  box.classList.toggle("selecting", LIB_SELECTING);
  const list = libFiltered();
  if(!LIB_CACHE.length){
    box.innerHTML = '<div class="empty">No saved texts yet. Paste something above and read it.</div>';
    libPaintBar(); return;
  }
  if(!list.length){ box.innerHTML = '<div class="empty">Nothing matches that search.</div>'; libPaintBar(); return; }
  list.forEach(m=>{
    const row = document.createElement("div"); row.className="lib-row"; row.dataset.id=m.id;
    const when = new Date((m.created||0)*1000)
      .toLocaleDateString(undefined,{day:"2-digit",month:"short"});
    const sum = m.summary ? `<div class="lsum"></div>` : "";
    row.innerHTML =
      `<div class="meta"><b></b><small>${when} &middot; ${m.units||0} sentences</small>${sum}</div>`;
    row.querySelector("b").textContent = m.title || m.id;
    if(m.summary) row.querySelector(".lsum").textContent = m.summary;
    row.insertBefore(mkSelbox(LIB_SEL.has(m.id)), row.firstChild);
    const btns = [
      mkBtn("Open","iconbtn open",()=>openText(m.id)),
      mkBtn("Export","iconbtn exp",()=>exportText(m.id))];
    if(false){
      btns.push(mkBtn("AI","iconbtn",()=>enrichText(m.id)));
    }
    btns.push(mkBtn("Delete","iconbtn del",()=>delText(m.id,m.title)));
    row.append(...btns);
    if(LIB_SELECTING) row.onclick=()=>libToggleOne(m.id);
    box.appendChild(row);
  });
  libPaintBar();
}
function libPaintBar(){
  const on=LIB_SELECTING, list=libFiltered(), selN=LIB_SEL.size;
  const t=$("#libSelToggle"); if(t){ t.textContent=on?"Cancel":"Select"; t.classList.toggle("on",on); }
  $("#libSelAll").classList.toggle("hidden",!on);
  $("#libDelSel").classList.toggle("hidden",!on);
  $("#libDelAll").classList.toggle("hidden",on);
  const cnt=$("#libSelCount"); cnt.classList.toggle("hidden",!on);
  $("#libDelSel").textContent="Delete ("+selN+")";
  const allSel=list.length && list.every(m=>LIB_SEL.has(m.id));
  $("#libSelAll").textContent=allSel?"Clear":"Select all";
  if(on) cnt.textContent=selN+" selected";
}
function libToggleOne(id){ if(LIB_SEL.has(id)) LIB_SEL.delete(id); else LIB_SEL.add(id); renderLibrary(); }
function libSelectToggle(){ LIB_SELECTING=!LIB_SELECTING; if(!LIB_SELECTING) LIB_SEL.clear(); renderLibrary(); }
function libSelectAll(){
  const list=libFiltered(); const allSel=list.length && list.every(m=>LIB_SEL.has(m.id));
  list.forEach(m=> allSel?LIB_SEL.delete(m.id):LIB_SEL.add(m.id)); renderLibrary();
}
function libDeleteSelected(){
  const ids=[...LIB_SEL]; if(!ids.length){ toast("Nothing selected."); return; }
  if(!confirm("Delete "+ids.length+" text"+(ids.length>1?"s":"")+"?")) return;
  api("/api/library/delete_bulk",{method:"POST",headers:{"Content-Type":"application/json"},
      body:JSON.stringify({ids})}).then(r=>r.json()).then(j=>{
    if(ids.includes(ST.tid)){ stop(); ST.tid=""; }
    LIB_SEL.clear(); LIB_SELECTING=false; loadLibrary();
    toast("Deleted "+(j.deleted||ids.length)+".");
  }).catch(()=>toast("Could not delete."));
}
function libDeleteAll(){
  const n=LIB_CACHE.length; if(!n){ toast("Archive is empty."); return; }
  if(!confirm("Delete ALL "+n+" saved text"+(n>1?"s":"")+"? This cannot be undone.")) return;
  api("/api/library/delete_all",{method:"POST"}).then(r=>r.json()).then(j=>{
    stop(); ST.tid=""; LIB_SEL.clear(); LIB_SELECTING=false; loadLibrary();
    toast("Deleted all "+(j.deleted||n)+".");
  }).catch(()=>toast("Could not delete."));
}
function loadLibrary(){
  LIB_SELECTING=false; LIB_SEL.clear();
  api("/api/library").then(r=>r.json()).then(list=>{
    LIB_CACHE = list||[]; renderLibrary();
  });
}
function enrichText(tid){
  toast("Summarising...");
  api("/api/library/"+tid+"/enrich",{method:"POST"})
    .then(r=>r.json().then(j=>({ok:r.ok,j})))
    .then(({ok,j})=>{
      if(!ok){ toast(j.error||"Could not summarise this."); return; }
      const m = LIB_CACHE.find(x=>x.id===tid);
      if(m){ m.title=j.title||m.title; m.summary=j.summary||""; }
      renderLibrary(); toast("Updated.");
    }).catch(()=>toast("That request failed."));
}
function mkBtn(txt,cls,fn){ const b=document.createElement("button");
  b.className=cls; b.textContent=txt; b.onclick=fn; return b; }
function openText(tid){ api("/api/library/"+tid).then(r=>r.json())
  .then(p=>openPayload(p, ST.autoplay)); }
function delText(tid,title){
  if(!confirm('Delete "'+(title||"this text")+'" ?')) return;
  api("/api/library/"+tid+"/delete",{method:"POST"}).then(()=>{
    if(tid===ST.tid){ stop(); ST.tid=""; } loadLibrary(); toast("Deleted.");
  });
}
function exportText(tid){
  const vn = (anyVoice(ST.voice)||{}).name||"";
  toast("Exporting sentence clips, text and timing in "+vn+"...");
  api("/api/export",{method:"POST",headers:{"Content-Type":"application/json"},
      body:JSON.stringify({tid, vkey:ST.vkey, meta:!!ST.aimeta})})
    .then(r=>r.json().then(j=>({ok:r.ok,j})))
    .then(({ok,j})=>{
      if(!ok){ toast(j.error||"Export failed."); return; }
      if(j.already){ toast("Already exported in "+(j.voice||vn)+"."); return; }
      toast("Saved to MA Reader Audio"+(j.timing_source==="pcm"?" (waveform timing)":""));
    }).catch(()=>toast("Export failed."));
}

function updatePasteHint(){
  { const b=$("#pasteBox");
    if(b) b.classList.toggle("port", !(b.value||"").trim()); }
  const n = $("#pasteBox").value.length;
  $("#pasteHint").textContent = n ? (n+" chars") : "";
}

/* ---------- persist settings ---------- */
/* ---------- keeping settings ----------
   The saving was debounced by a quarter second, which is right for a slider
   being dragged and wrong for everything else, because on Android a tab that
   goes to the background is FROZEN. Pending timers do not run. Switch away
   from Chrome, or lock the phone, within that quarter second and the change
   is simply gone, which is exactly what "my settings are not remembered"
   looks like from the outside.

   So: the timer still coalesces a burst of changes, but the state is also
   flushed the moment the page is hidden or closed, and that flush uses
   sendBeacon, which exists for precisely this and is delivered by the browser
   even as the page is being torn down. A normal fetch at that moment is
   allowed to be abandoned; a beacon is not.

   The settings live in one file, ~/.maread-web/web_state.json, inside Termux
   private storage. Nothing else on the phone can read or write it, and it is
   carried out and put back whenever the app is reinstalled. */
let persistT=null, persistDue=null;

/* NOTHING may be saved until the saved settings have been read back and put
   into ST. This is not a nicety, it was the bug.
   bind() makes every control live at the very top of boot, but ST is not
   filled in until five requests have come back, one of which asks Speechify
   for its catalogue and can take seconds on a poor connection. In that window
   the interface is running on FACTORY DEFAULTS, and any of the thirty four
   places that call persist() would write those defaults straight over the
   file. Change your settings, restart, touch one thing while it is still
   loading, and everything is back to how it shipped.
   So: the gate stays shut until boot has finished restoring. */
let booted = false;
function stateBody(){
  return JSON.stringify({voice:ST.voice, speed:ST.speed, volume:ST.volume,
        gap:ST.gap, lag:ST.lag, wgap:ST.wgap, loop:ST.loop, size:ST.size, autoplay:ST.autoplay,
        focus:ST.focus, theme:ST.theme, font:ST.font,
        lineheight:ST.lineheight, wordhl:ST.wordhl,
        rgbSent:ST.rgbSent, rgbWord:ST.rgbWord, rgbFont:ST.rgbFont, rgbText:ST.rgbText,
        wordoffsets:ST.wordoffsets, aimeta:ST.aimeta,
        resume:ST.resume,
        engine:ST.engine, spAccent:ST.spAccent, spVkey:ST.spVkey||"",
        spSet:ST.spSet||0,
        bothEngines:!!ST.bothEngines,
        spPicked:(Array.isArray(ST.spPicked) ? ST.spPicked : null),
        croVoice:ST.croVoice||"lesya", engVoice:ST.engVoice||"beatrice_32",
        lang:ST.lang||"eng",
        langAuto:ST.langAuto||"eng",
        fullOnPaste:!!ST.fullOnPaste,
        hideTabs:!!ST.hideTabs, mode:ST.mode||"read", pane:ST.pane||"app",
        voiceBar:!!ST.voiceBar,
        floatPaste:!!ST.floatPaste, fpX:ST.fpX, fpY:ST.fpY,
        floatFull:!!ST.floatFull, ffX:ST.ffX, ffY:ST.ffY,
        floatSwap:!!ST.floatSwap, fsX:ST.fsX, fsY:ST.fsY,
        adbMode:!!ST.adbMode,
        enabledLangs:ST.enabledLangs});
}

/* Send it now, whatever else was pending. */
function persistNow(){
  if(!booted) return Promise.resolve();
  clearTimeout(persistT); persistT = null;
  const body = stateBody();
  persistDue = null;
  return api("/api/state", {method:"POST",
      headers:{"Content-Type":"application/json"}, body: body}).catch(()=>{});
}

/* The last chance saloon: the page is going away, so use the one transport
   that is guaranteed to leave. sendBeacon takes a Blob and needs no response,
   which is why it survives an unload when a fetch does not. */
function persistBeacon(){
  if(!booted || !persistDue) return;
  const body = persistDue;
  persistDue = null;
  clearTimeout(persistT); persistT = null;
  try{
    if(navigator.sendBeacon){
      const blob = new Blob([body], {type:"application/json"});
      if(navigator.sendBeacon("/api/state", blob)) return;
    }
  }catch(e){}
  /* no beacon, or it refused: a keepalive fetch is the next best thing */
  try{
    fetch("/api/state", {method:"POST", body: body, keepalive: true,
      headers:{"Content-Type":"application/json"}}).catch(()=>{});
  }catch(e){}
}

function persist(){
  if(!booted) return;                /* see the note above: this is the bug */
  persistDue = stateBody();          /* remember it BEFORE the timer, so a
                                        freeze cannot lose what was pending */
  clearTimeout(persistT);
  persistT = setTimeout(()=>{
    persistT = null;
    const body = persistDue; persistDue = null;
    if(!body) return;
    api("/api/state",{method:"POST",headers:{"Content-Type":"application/json"},
      body: body}).catch(()=>{ persistDue = body; });
  }, 250);
}

/* Every way a phone can take the page away. visibilitychange is the reliable
   one on Android; pagehide covers the tab actually closing; blur catches the
   app switcher on some builds. All three are cheap and idempotent. */
function wirePersistFlush(){
  document.addEventListener("visibilitychange", ()=>{
    if(document.visibilityState === "hidden") persistBeacon();
  });
  window.addEventListener("pagehide", persistBeacon);
  window.addEventListener("beforeunload", persistBeacon);
  window.addEventListener("blur", persistBeacon);
}

/* ---------- wire up ---------- */
/* press and hold on a stepper: wait a moment so a plain tap stays a tap, then
   repeat, quickening after the first second */
function holdRepeat(btn, fn){
  let start=null, tick=null, n=0;
  const stop = ()=>{ clearTimeout(start); clearInterval(tick);
                     start=null; tick=null; n=0; };
  btn.addEventListener("pointerdown", ()=>{
    stop();
    start = setTimeout(()=>{
      tick = setInterval(()=>{ n++; fn(); if(n===12){ clearInterval(tick);
        tick = setInterval(fn, 45); } }, 95);
    }, 420);
  });
  ["pointerup","pointerleave","pointercancel"].forEach(ev=>
    btn.addEventListener(ev, stop));
}

function bind(){
  $("#readBtn").onclick = readPasted;
  $("#clearBtn").onclick = ()=>{ $("#pasteBox").value=""; updatePasteHint(); };
  $("#pasteBox").addEventListener("input", updatePasteHint);

  /* Pressing the time clears the session and puts it back to zero. Nothing is
     lost by it: every text that was read is already in the Archive below. */
  { const clearIt = ()=>{ doneReset(); toast("Cleared. The text is in your Archive."); };
    const a=$("#counter"), b=$("#offCounter");
    if(a) a.onclick = clearIt;
    if(b) b.onclick = clearIt;
  }

  /* The empty box IS the paste button. A tap on it, when there is nothing in
     it, takes the clipboard and starts reading, and the keyboard is kept out
     of the way because typing was plainly not the intention. Once there is
     text in the box it behaves like any other box again. */
  { const box=$("#pasteBox");
    if(box) box.addEventListener("click", (e)=>{
      if((box.value||"").trim()) return;         /* has text: leave it alone */
      e.preventDefault();
      try{ box.blur(); }catch(_){}
      pasteFromClipboard();
    });
  }

  $("#playBtn").onclick = togglePlay;
  /* the text is scrolled, not swiped */
  $("#loopBtn").onclick = ()=>{ ST.loop=!ST.loop; refreshToggles(); persist();
      toast("Loop "+(ST.loop?"on":"off")); };

  /* every stepper repeats while held down, so a long way is one press, not
     twenty, while a single tap stays a single fine nudge */
  document.querySelectorAll("[data-step]").forEach(b=>{
    const go = ()=> step(b.dataset.step, parseInt(b.dataset.d,10));
    b.onclick = go;
    holdRepeat(b, go);
  });
  /* the number between the minus and the plus is a button as well: tapping it
     puts that control back where it started, so coming home from a long hold
     is one tap rather than twenty */
  document.querySelectorAll("[data-reset]").forEach(b=>{
    b.onclick = ()=> resetTune(b.dataset.reset);
  });

  /* the two engine buttons at the top of Settings */
  document.querySelectorAll("#engTabs .engtab").forEach(b=>{
    b.onclick = ()=> setPane(b.dataset.pane);
  });
  /* The two head toggles. Bound once, outside the tab loop; they were inside
     it, which set the same handler three times and left the engine toggle
     unbound altogether. */
  { const lb = $("#langBtn");
    if(lb) lb.onclick = ()=> setLang(nextLang());
  }
  { const eb = $("#engBtn");
    if(eb) eb.onclick = ()=>{
      /* WHICH ENGINE SPEAKS, which is not the same question as which pane of
         Settings is open. Changing it leaves the pane where it was. */
      const want = (ST.engine === "speechify") ? "edge" : "speechify";
      setEngine(want, true);
      renderLangBtn();
      soundChanged(want === "speechify" ? "Speechify is speaking"
                                        : "Edge is speaking");
    };
  }
  /* the Speechify key ring. The file is handed straight to the server; the
     browser reads no key out of it and nothing is ever echoed back. */
  { const kf = $("#spKeyFile");
    if(kf) kf.onchange = e=>{
      const f = e.target.files && e.target.files[0];
      e.target.value = "";
      if(!f) return;
      const fd = new FormData(); fd.append("file", f);
      const err = $("#spKeyErr"); if(err) err.textContent = "Testing the keys\u2026";
      api("/api/speechify/keys", {method:"POST", body: fd})
        .then(r=>r.json()).then(d=>{
          if(d.error){ if(err) err.textContent = d.error; return; }
          applySpInfo(d);
          toast(d.ready ? "Speechify ready" : "Keys saved, none answered");
          if(d.ready && ST.engine !== "speechify") setEngine("speechify");
        }).catch(()=>{ if(err) err.textContent = "Could not save the keys."; });
    };
  }
  { const p = $("#spPrev"), n = $("#spNext");
    if(p) p.onclick = ()=> spGoSet(ST.spSet - 1);
    if(n) n.onclick = ()=> spGoSet(ST.spSet + 1);
  }
  { const rb = $("#spRefresh");
    if(rb) rb.onclick = ()=>{
      const err = $("#spKeyErr"); if(err) err.textContent = "Walking the ring\u2026";
      api("/api/speechify/refresh", {method:"POST"})
        .then(r=>r.json()).then(d=>{ applySpInfo(d);
          const t = d.tested || {};
          toast(d.ready ? ((t.WORKING||0) + " good, " + (t.REJECTED||0) + " dead")
                        : "No key answered"); })
        .catch(()=>{ if(err) err.textContent = "Could not reach Speechify."; });
    };
  }
  { const fb = $("#spForget");
    if(fb) fb.onclick = ()=>{
      api("/api/speechify/forget", {method:"POST"})
        .then(r=>r.json()).then(d=>{ applySpInfo(d);
          if(ST.engine === "speechify") setEngine("edge");
          toast("Speechify keys forgotten"); })
        .catch(()=>{});
    };
  }
  $("#volRange").addEventListener("input", e=>{
    ST.volume = parseInt(e.target.value,10); applyVolume(); persist();
  });

  { const b=$("#fsBtn"), o=$("#offFsBtn"), x=$("#fsOut");
    if(b) b.onclick = ()=> enterFull(false);
    if(o) o.onclick = ()=> enterFull(false);
    if(x) x.onclick = leaveFull;
  }
  { const b=$("#voiceBarTog");
    if(b) b.onclick = ()=>{
      ST.voiceBar = !ST.voiceBar;
      refreshToggles(); renderVoices(); persist();
      toast(ST.voiceBar ? "Voice buttons back on top"
                        : "Voice buttons off. Choose the voice here.");
    };
  }
  { const b=$("#chromeTog");
    if(b) b.onclick = ()=>{
      const mode = (ST.browser === "auto") ? "chrome" : "auto";
      api("/api/browser", {method:"POST",
          headers:{"Content-Type":"application/json"},
          body: JSON.stringify({mode: mode})})
        .then(r=>r.json()).then(d=>{
          ST.browser = d.mode || mode; refreshToggles();
          toast(ST.browser === "chrome" ? "Chrome from now on"
                                        : "Whatever the phone prefers");
        }).catch(()=> toast("Could not save that."));
    };
  }
  { const b=$("#adbTog");
    if(b) b.onclick = ()=>{
      ST.adbMode = !ST.adbMode;
      refreshToggles(); persistNow();
      /* persistNow, not persist: this is read by the LAUNCHER on the next
         run, out of the settings file, so it has to be on disk before the
         app is closed rather than a quarter second later. */
      toast(ST.adbMode ? "ADB comes up on the next start"
                       : "ADB will be left alone on the next start");
    };
  }
  { const b=$("#swTest");
    if(b) b.onclick = ()=>{
      api("/api/appswitch/status").then(r=>r.json()).then(d=>{
        toast(d.ready ? ("Ready, via " + d.how)
                      : (d.hint || "Not available on this phone."));
        const el=$("#floatS"); if(el) el.classList.toggle("notready", !d.ready);
      }).catch(()=> toast("Could not reach the server."));
    };
  }
  { const b=$("#floatSTog");
    if(b) b.onclick = ()=>{
      ST.floatSwap = !ST.floatSwap;
      refreshToggles(); persist();
      if(ST.floatSwap){ placeFloatS(); wireFloatS(); toast("App switcher shown"); }
      else toast("App switcher hidden");
    };
  }
  { const b=$("#floatFTog");
    if(b) b.onclick = ()=>{
      ST.floatFull = !ST.floatFull;
      refreshToggles(); persist();
      if(ST.floatFull) placeFloatF();
      toast(ST.floatFull ? "Drag the dot anywhere you like"
                         : "Full screen button hidden");
    };
  }
  { const b=$("#floatTog");
    if(b) b.onclick = ()=>{
      ST.floatPaste = !ST.floatPaste;
      refreshToggles(); persist();
      if(ST.floatPaste) placeFloat();
      toast(ST.floatPaste ? "Drag the P anywhere you like" : "Floating button hidden");
    };
  }
  { const c=$("#catchGo"), x=$("#catchCancel"), b=$("#catchBox");
    if(c) c.onclick = catcherTake;
    if(x) x.onclick = closeCatcher;
    if(b){
      /* the instant something lands, go. No second press. */
      b.addEventListener("paste", ()=> setTimeout(catcherTake, 30));
      b.addEventListener("input", ()=>{ if((b.value||"").length > 40) catcherTake(); });
    }
    const w=$("#catchWrap");
    if(w) w.addEventListener("click",(e)=>{ if(e.target===w) closeCatcher(); });
  }
  document.querySelectorAll("#modeRow .modebtn, #offModeRow .modebtn")
    .forEach(b => { b.onclick = ()=> setMode(b.dataset.mode); });
  { const b=$("#hideTabsTog");
    if(b) b.onclick = ()=>{
      ST.hideTabs = !ST.hideTabs;
      refreshToggles(); persist();
      toast(ST.hideTabs ? "Tabs hidden, the gear stays" : "Tabs back");
    };
  }
  { const b=$("#fullPasteTog");
    if(b) b.onclick = ()=>{
      ST.fullOnPaste = !ST.fullOnPaste;
      refreshToggles(); persist();
      toast(ST.fullOnPaste ? "A paste goes full screen"
                           : "A paste stays in the normal view");
    };
  }
  $("#autoplayTog").onclick = ()=>{ ST.autoplay=!ST.autoplay; refreshToggles(); persist(); };
  $("#focusTog").onclick = ()=>{ ST.focus=!ST.focus; refreshToggles(); persist(); };

  $("#backdrop").onclick = closeSheet;
  { const x=$("#sheetX"); if(x) x.onclick = closeSheet; }
  document.querySelectorAll("#themeChips .chip").forEach(c=>
    c.onclick = ()=>{ ST.theme=c.dataset.theme; applyTheme(); persist(); });
  document.querySelectorAll("#fontChips .chip").forEach(c=>
    c.onclick = ()=>{ ST.font=c.dataset.font; applyFont(); persist(); });
  $("#wordExp").onclick = ()=>{ ST.wordhl=!ST.wordhl; applyWordHl(); persist();
      toast(ST.wordhl ? "Word highlight on" : "Word highlight off"); };
  document.querySelectorAll('.rgbrow input[data-rgb]').forEach(inp=>{
    const key=inp.dataset.rgb, i=+inp.dataset.i;
    const ensure = ()=>{ if(key==="text" && !Array.isArray(ST.rgbText)) ST.rgbText = themeTextRgb().slice(); };
    inp.oninput = ()=>{
      if(inp.value==="") return;            // let the field be empty mid-typing
      ensure(); rgbArr(key)[i] = clamp255(inp.value);
      applyHiColors(); persist();
    };
    inp.onchange = ()=>{                     // on blur, normalise the field
      ensure(); const v = clamp255(inp.value); rgbArr(key)[i] = v; inp.value = v;
      applyHiColors(); persist();
    };
  });
  { const ta=$("#textAuto"); if(ta) ta.onclick = ()=>{ ST.rgbText=null; applyHiColors(); persist(); }; }
  $("#syncRange").addEventListener("input", e=>{
    ST.wordoffsets[ST.vkey] = parseInt(e.target.value,10);
    applySync(); persist();
    if(ST.wordhl && !ST.playing) highlightWordAt(ST.idx, active().currentTime);
  });

  document.addEventListener("keydown", e=>{
    if(e.target.tagName==="TEXTAREA"||e.target.tagName==="INPUT") return;
    const k = e.key.toLowerCase();
    /* P works in every view, including Home: take the clipboard, replace the
       box, start reading. Play/pause is the spacebar now that P is taken.
       Cmd-P and Ctrl-P are left alone so Print still works. */
    if(k==="p" && !e.metaKey && !e.ctrlKey && !e.altKey){
      e.preventDefault(); pasteFromClipboard(); return;
    }
    if($("#readerView").classList.contains("hidden")) return;
    if(k===" "){ e.preventDefault(); togglePlay(); }
    else if(k===","||k==="arrowleft"){ prev(); }
    else if(k==="."||k==="arrowright"){ next(); }
    else if(k==="s"){ stop(); }
    else if(k==="z"){ ST.loop=!ST.loop; refreshToggles(); persist(); }
    else if(k==="-"||k==="_"){ step("size",-1); }     // shrink text
    else if(k==="="||k==="+"){ step("size",1); }      // enlarge text
    else if(k==="["){ step("speed",-1); }
    else if(k==="]"){ step("speed",1); }
    /* these two follow the right hand stepper on the player, which is now the
       gap between words. The gap between sentences lives in Settings. */
    else if(k===";"){ step("wgap",-1); }              // word gap, into the minus
    else if(k==="'"){ step("wgap",1); }
    else if(k==="0"){ jumpTo(0, ST.playing); }        // back to the first sentence
    else if(k==="enter"){ toggleImmersive(false); }   // same as a centre double tap
    else if(k==="f"){ ST.focus=!ST.focus; refreshToggles(); persist(); }
    else if(k==="t"){ const i=(THEMES.indexOf(ST.theme)+1)%THEMES.length;
                      ST.theme=THEMES[i]; applyTheme(); persist(); }
    else if(k==="a"||k==="g"){ openSheet(); }
    else if(k>="1"&&k<="4"){ setVoice(parseInt(k,10)); }
    else if(k==="h"){ doneReset(); }
  });
}

/* ---------- boot ---------- */

/* ================= v4: exclusive playback, fullscreen, player jump ========= */
/* Only one thing may speak at a time. Starting either player silences the
   other; opening a new text stops whatever was playing before. */
function stopOnline(){
  try{ cancelGap(); }catch(e){}
  ST.playing=false; try{ setPlayIcon(false); }catch(e){}
  players.forEach(p=>{ try{ p.pause(); }catch(e){} });
  if(rafId){ cancelAnimationFrame(rafId); rafId=null; }
}
function stopOffline(){
  if(OFF.playing && ST.resume) saveOffPos();
  try{ offCancelGap(); }catch(e){}
  OFF.playing=false; try{ offSetPlayIcon(false); }catch(e){}
  try{ OFF.audio.pause(); OFF.audioB.pause(); }catch(e){}
  if(OFF.raf){ cancelAnimationFrame(OFF.raf); OFF.raf=null; }
}
function markSession(){
  const has = !!(ST.sentences && ST.sentences.length) || !!OFF.man;
  document.body.classList.toggle("hassession", has);
}
function jumpToPlayer(){
  /* whichever is playing wins; else most recently loaded */
  if(OFF.playing || (OFF.man && !ST.playing && !(ST.sentences||[]).length)){
    if(OFF.man){ showOfflineReader(); return; }
  }
  if((ST.sentences||[]).length){ showReader(); return; }
  if(OFF.man){ showOfflineReader(); return; }
  toast("Nothing is loaded yet.");
}
/* ---------- fullscreen reading ---------- */
/* ---------- read, text, edit ----------
   READ is the app as it has always been: it speaks, and the word lights up.
   TEXT strips every colour and marker so the page can simply be read with the
   eye, scrolling like any article.
   EDIT makes the text itself editable, to cut a header off or fix a mistype
   before reading it.
   Play belongs to READ alone: in the other two there is nothing to follow,
   and a voice talking over an edit is a nuisance rather than a feature. */
function setMode(m){
  if(m !== "read" && m !== "text" && m !== "edit") m = "read";
  if(m !== "read" && ST.playing){ try{ pause(); }catch(e){} }
  if(ST.mode === "edit" && m !== "edit") commitEdit();
  ST.mode = m;
  document.body.classList.toggle("mode-text", m === "text");
  document.body.classList.toggle("mode-edit", m === "edit");
  document.querySelectorAll("#modeRow .modebtn, #offModeRow .modebtn")
    .forEach(b => b.classList.toggle("on", b.dataset.mode === m));
  applyEditable();
  persist();
}
function applyEditable(){
  const on = (ST.mode === "edit");
  const box = $("#mdEdit"), doc = $("#doc");
  /* A Markdown text is edited AS MARKDOWN. Making the rendered HTML
     contentEditable would let a heading be typed into and then, on commit,
     read back as flat text with every marker already consumed - the
     formatting would quietly disappear the first time anything was fixed. */
  const mdEdit = on && MD.on;
  if(box){
    box.classList.toggle("on", mdEdit);
    if(mdEdit && box.value !== ST.source) box.value = ST.source || "";
  }
  if(doc) doc.classList.toggle("mdhidden", mdEdit);
  ["#doc", "#offDoc"].forEach(sel => {
    const el = $(sel); if(!el) return;
    try{
      /* Only ever the PLAIN document becomes editable in place. */
      el.contentEditable = (on && !(sel === "#doc" && MD.on)) ? "true" : "false";
      el.spellcheck = false;
    }catch(e){}
  });
}
/* Leaving EDIT keeps what was typed: the text is read back out of the page,
   saved as a new text, and re-split into sentences so it can be spoken. */
function commitEdit(){
  /* Markdown: what was edited is the SOURCE, so that is what is committed,
     and it goes back through the same road a paste takes - parsed, wrapped,
     re-split - so the formatting and the highlight both come back. */
  if(MD.on){
    const ta = $("#mdEdit"); if(!ta) return;
    const t = (ta.value || "").replace(/\u00a0/g, " ");
    if(!t.trim()) return;
    if(t === (ST.source || "")) return;    /* nothing was actually changed */
    const box = $("#pasteBox"); if(box) box.value = t;
    readTextNow(t);
    return;
  }
  const el = $("#doc"); if(!el) return;
  const t = (el.innerText || "").replace(/\u00a0/g, " ").trim();
  if(!t) return;
  const was = (ST.sentences || []).join(" ").trim();
  if(t === was) return;                    /* nothing was actually changed */
  const box = $("#pasteBox"); if(box) box.value = t;
  readTextNow(t);
}

function setFullread(on){
  document.body.classList.toggle("fullread", !!on);
  paintFloat();
}

/* ---------- real full screen ----------
   Hiding our own header was never going to be enough: the browser's own
   furniture is not ours to hide. The Fullscreen API is, and it must be asked
   for inside the gesture that wanted it, which is why the request goes out
   before the clipboard is read rather than after.

   It is still not bulletproof, because Chrome will put its bar back on a
   gesture it does not like. The one thing that truly cannot be undone is
   installing to the home screen: a standalone window has no browser interface
   to pin anything to. The manifest is there for that, and Settings says so. */
function fsElement(){
  return document.fullscreenElement || document.webkitFullscreenElement || null;
}
/* Installed to the home screen there is no browser tab, so there is nothing
   to hide and no reason to ask for full screen at all. That matters for one
   reason above all: asking is what makes Chrome throw up its own banner
   saying how to leave full screen, and that banner belongs to the browser,
   sits above the page, and cannot be touched or dismissed from here. No
   request, no banner. In a plain tab the request is still needed, and the
   banner comes with it whether we like it or not. */
function isStandalone(){
  try{
    if(window.navigator && window.navigator.standalone) return true;
    return window.matchMedia("(display-mode: standalone)").matches ||
           window.matchMedia("(display-mode: fullscreen)").matches ||
           window.matchMedia("(display-mode: minimal-ui)").matches;
  }catch(e){ return false; }
}
function reqFull(){
  if(isStandalone()) return true;      /* already our own window */
  const el = document.documentElement;
  const f = el.requestFullscreen || el.webkitRequestFullscreen ||
            el.webkitRequestFullScreen || el.mozRequestFullScreen ||
            el.msRequestFullscreen;
  if(!f) return false;
  try{
    const r = f.call(el, {navigationUI: "hide"});
    if(r && r.catch) r.catch(()=>{});
    return true;
  }catch(e){
    try{ const r2 = f.call(el); if(r2 && r2.catch) r2.catch(()=>{}); return true; }
    catch(_){ return false; }
  }
}
function dropFull(){
  const f = document.exitFullscreen || document.webkitExitFullscreen ||
            document.webkitCancelFullScreen || document.mozCancelFullScreen ||
            document.msExitFullscreen;
  if(!f) return;
  try{ const r = f.call(document); if(r && r.catch) r.catch(()=>{}); }catch(e){}
}

/* Full screen IS reading. Going in starts the voice, coming out stops it,
   because that is the one gesture the whole workflow turns on. */
function enterFull(play){
  reqFull();
  setFullread(true);
  if(play !== false && !ST.playing && ST.sentences && ST.sentences.length){
    try{ resume(); }catch(e){}
  }
}
function leaveFull(){
  dropFull();
  setFullread(false);
  if(ST.playing){ try{ pause(); }catch(e){} }
  if(typeof OFF === "object" && OFF && OFF.playing){
    try{ offToggle(); }catch(e){}
  }
}
/* The system can drop us out of full screen on its own: the back gesture, a
   notification, a swipe Chrome decided it liked. Treat that exactly like
   pressing the button, or the app would carry on reading into a page the
   person has already left. */
function wireFsWatch(){
  const onChange = ()=>{
    const on = !!fsElement();
    if(!on && document.body.classList.contains("fullread")){
      setFullread(false);
      if(ST.playing){ try{ pause(); }catch(e){} }
    } else if(on){
      setFullread(true);
    }
  };
  ["fullscreenchange","webkitfullscreenchange","mozfullscreenchange",
   "MSFullscreenChange"].forEach(e=> document.addEventListener(e, onChange));
}
function isFullread(){ return document.body.classList.contains("fullread"); }
/* The gesture that opens the book also closes it. A double tap in the middle
   of the page strips away every control and starts speaking; a double tap in
   the same place puts the controls back and pauses, so you always finish
   where you stopped reading. */
function inCenterZone(x, y){
  const w = window.innerWidth, h = window.innerHeight;
  return x > w*0.27 && x < w*0.73 && y > h*0.30 && y < h*0.70;
}
function toggleImmersive(isOffline){
  const on = !isFullread();
  setFullread(on);
  if(on){
    if(isOffline){ if(!OFF.playing) offPlay(); }
    else { if(!ST.playing) resume(); }
  } else {
    if(isOffline){ if(OFF.playing) offPause(); }
    else { if(ST.playing) pause(); }
  }
}
function toggleFullread(){ toggleImmersive(false); }
/* One tap router for the reading area. A tap in the centre is held back for a
   quarter of a second in case a second one follows, so the double tap never
   also jumps to whatever sentence happened to be under the finger. Taps
   outside the centre keep their normal behaviour and are not delayed at all,
   unless we are immersive, where the whole page is a play/pause button. */
function wireCenterTaps(scrollSel, isOffline){
  const sc=$(scrollSel); if(!sc) return;
  let tapT=null;
  sc.addEventListener("click", (e)=>{
    /* One finger, straight to the next article. A tap on the text asks for
       the clipboard, Android offers its Paste button, and what comes back
       replaces everything and starts speaking. Nothing else may claim a tap
       while this is on, or the gesture would mean three things at once. */
    const full = isFullread();
    const inZ  = inCenterZone(e.clientX, e.clientY);
    if(!full && !inZ) return;       /* ordinary tap: let the sentence handle it */
    e.stopPropagation(); e.preventDefault();
    if(tapT){                       /* second tap inside the window */
      clearTimeout(tapT); tapT=null;
      if(inZ){ toggleImmersive(isOffline); return; }
    }
    /* In a Markdown text there is no .sent to close on, so the sentence is
       found from the word span that was actually touched. */
    let si = -1;
    if(!isOffline && MD.mapped){
      const wsp = (e.target && e.target.closest)
                    ? e.target.closest("#doc .w, #doc .g") : null;
      if(wsp) si = mdSentenceAt(wsp);
    }else{
      const sent = (e.target && e.target.closest) ? e.target.closest(".sent") : null;
      si = sent ? parseInt(sent.dataset.i, 10) : -1;
    }
    tapT=setTimeout(()=>{
      tapT=null;
      if(full || si < 0 || isNaN(si)){
        if(isOffline){ offToggle(); } else { togglePlay(); }
        return;
      }
      if(isOffline){ offJump(si, OFF.playing); }
      else if(si === ST.idx){ togglePlay(); }
      else { jumpTo(si, true); }
    }, 260);
  }, true);
}
/* ---------- clipboard paste ---------- */
/* Quick turnaround: a new text should cost one action, not four. Paste
   REPLACES whatever was in the box (it used to append) and starts reading
   straight away, so pasting is the whole gesture. Reachable three ways: the
   Paste button, the P key from anywhere, and Read for text typed by hand. */
function readTextNow(text){
  if(!text || !text.trim()){ toast("Nothing to read."); return; }
  autoDetect(text);              /* a new text is the moment to ask */
  setStatus("Preparing...");
  api("/api/prepare", {method:"POST", headers:{"Content-Type":"application/json"},
       body: prepareBody(text)})
    .then(r=>r.json().then(j=>({ok:r.ok,j})))
    .then(({ok,j})=>{
      if(!ok){ toast(j.error||"Could not prepare."); return; }
      $("#pasteBox").value=""; updatePasteHint();
      openPayload(j, true);          /* always play: that is the point */
    }).catch(()=>toast("Server error."));
}
/* Whatever arrives, from whichever route, ends the same way: it REPLACES
   what was loaded and starts speaking from the beginning. */
function acceptPaste(t){
  if(!t || !t.trim()) return false;
  const box=$("#pasteBox");
  if(box){ box.value = t; }
  if(typeof updatePasteHint==="function") updatePasteHint();
  readTextNow(t);
  return true;
}
/* If the clipboard came back empty, or the catcher was cancelled, we are
   sitting in a full screen we asked for and never used. Come back out. */
function unwindFull(){
  if(document.body.classList.contains("fullread") &&
     !(ST.sentences && ST.sentences.length)){
    dropFull(); setFullread(false);
  }
}

/* The catcher: the path that cannot fail, because it is only a text field.
   Opened whenever the quick way is refused. */
function openCatcher(){
  const w=$("#catchWrap"), b=$("#catchBox");
  if(!w || !b) { toast("Paste into the box on the Read tab."); return; }
  b.value = "";
  w.classList.add("on");
  setTimeout(()=>{ try{ b.focus(); }catch(e){} }, 40);
}
function closeCatcher(){
  const w=$("#catchWrap"); if(w) w.classList.remove("on");
  const b=$("#catchBox"); if(b){ try{ b.blur(); }catch(e){} }
  unwindFull();
}
function catcherTake(){
  const b=$("#catchBox"); if(!b) return;
  const t=b.value;
  if(!t || !t.trim()){ toast("Nothing there yet."); return; }
  closeCatcher(); acceptPaste(t);
}

/* One press, the quick way first. If the browser will not give up the
   clipboard, fall through to the catcher instead of shrugging. */
function pasteFromClipboard(){
  if(!(navigator.clipboard && navigator.clipboard.readText)){
    openCatcher(); return;
  }
  let settled = false;
  const fallback = ()=>{ if(!settled){ settled = true; openCatcher(); } };
  try{
    navigator.clipboard.readText().then(t=>{
      if(settled) return;
      settled = true;
      if(!acceptPaste(t)) openCatcher();
    }).catch(fallback);
  }catch(e){ fallback(); return; }
  /* Some browsers neither resolve nor reject: they simply never answer,
     which is what makes a press feel like nothing happened at all. */
  setTimeout(fallback, 1200);
}

/* ---------- the floating P ---------- */
/* Both floaters share the drag, the clamp and the remembering. The only
   things that differ are which element, which two numbers it stores, and what
   a press does, so those are the only things passed in. */
function clampFloatEl(el, x, y){
  const s=(el&&el.offsetWidth)||56;
  const w=window.innerWidth, h=window.innerHeight;
  return [Math.max(4, Math.min(w-s-4, x)), Math.max(4, Math.min(h-s-4, y))];
}
function wireDrag(el, onPress, save){
  if(!el) return;
  let sx=0, sy=0, ox=0, oy=0, moved=false, id=null;
  el.addEventListener("pointerdown",(e)=>{
    id=e.pointerId; moved=false; sx=e.clientX; sy=e.clientY;
    const r=el.getBoundingClientRect(); ox=sx-r.left; oy=sy-r.top;
    try{ el.setPointerCapture(id); }catch(_){}
    el.classList.add("moving");
  });
  el.addEventListener("pointermove",(e)=>{
    if(id===null || e.pointerId!==id) return;
    if(!moved && Math.abs(e.clientX-sx)+Math.abs(e.clientY-sy) < 7) return;
    moved=true;
    const [x,y]=clampFloatEl(el, e.clientX-ox, e.clientY-oy);
    el.style.left=x+"px"; el.style.top=y+"px";
  });
  const done=(e)=>{
    if(id===null) return;
    try{ el.releasePointerCapture(id); }catch(_){}
    id=null; el.classList.remove("moving");
    if(moved){
      const r=el.getBoundingClientRect();
      save(r.left/Math.max(1,window.innerWidth),
           r.top/Math.max(1,window.innerHeight));
      persist();
    } else {
      onPress();
    }
  };
  el.addEventListener("pointerup", done);
  el.addEventListener("pointercancel", done);
}
function placeFloatF(){
  const el=$("#floatF"); if(!el) return;
  const fx=(typeof ST.ffX==="number")?ST.ffX:0.82;
  const fy=(typeof ST.ffY==="number")?ST.ffY:0.58;
  const [x,y]=clampFloatEl(el, fx*window.innerWidth, fy*window.innerHeight);
  el.style.left=x+"px"; el.style.top=y+"px";
}
/* ITS ONLY JOB. In full screen it leaves and pauses, exactly as the P does,
   so the two never disagree about what leaving means. Out of full screen it
   asks for the browser's full screen inside the gesture, which is the only
   moment the request is allowed. */
function floatFullPress(){
  if(document.body.classList.contains("fullread")){ leaveFull(); return; }
  reqFull();
  setFullread(true);
}
function wireFloatF(){
  const el=$("#floatF"); if(!el) return;
  placeFloatF();
  wireDrag(el, floatFullPress, (x,y)=>{ ST.ffX=x; ST.ffY=y; });
}
function placeFloatS(){
  const el=$("#floatS"); if(!el) return;
  const fx=(typeof ST.fsX==="number")?ST.fsX:0.82;
  const fy=(typeof ST.fsY==="number")?ST.fsY:0.44;
  const [x,y]=clampFloatEl(el, fx*window.innerWidth, fy*window.innerHeight);
  el.style.left=x+"px"; el.style.top=y+"px";
}
/* Back to the app you were in before this one. A web page cannot do this; the
   server asks the privileged shell that maread-adb sets up, exactly as the
   media keys already do. Without that shell it says so rather than doing
   nothing quietly. */
function floatSwapPress(){
  api("/api/appswitch", {method:"POST"}).then(r=>r.json()).then(d=>{
    if(!d.ok) toast(d.error || "No privileged shell. Run maread-adb in Termux.");
  }).catch(()=> toast("Could not reach the server."));
}
function wireFloatS(){
  const el=$("#floatS"); if(!el) return;
  placeFloatS();
  wireDrag(el, floatSwapPress, (x,y)=>{ ST.fsX=x; ST.fsY=y; });
  /* Ask ONCE at boot what this phone can do, so the button can say it is not
     ready before it is pressed rather than after. */
  api("/api/appswitch/status").then(r=>r.json()).then(d=>{
    el.classList.toggle("notready", !d.ready);
    el.title = d.ready ? ("Switch to the last app, via " + d.how + ". Drag to move.")
                       : (d.hint || "Not available on this phone.");
  }).catch(()=>{});
}
function clampFloat(x, y){
  const el=$("#floatP"); const s=(el&&el.offsetWidth)||56;
  const w=window.innerWidth, h=window.innerHeight;
  return [Math.max(4, Math.min(w-s-4, x)), Math.max(4, Math.min(h-s-4, y))];
}
function placeFloat(){
  const el=$("#floatP"); if(!el) return;
  const w=window.innerWidth, h=window.innerHeight;
  const fx=(typeof ST.fpX==="number")?ST.fpX:0.82, fy=(typeof ST.fpY==="number")?ST.fpY:0.72;
  const [x,y]=clampFloat(fx*w, fy*h);
  el.style.left=x+"px"; el.style.top=y+"px";
}
const FS_GLYPH = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor"' +
  ' stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
  '<path d="M8 3H5a2 2 0 0 0-2 2v3M16 3h3a2 2 0 0 1 2 2v3' +
  'M8 21H5a2 2 0 0 1-2-2v-3M16 21h3a2 2 0 0 0 2-2v-3"/></svg>';

/* One button, two faces, because it is one loop: paste, read, come back out,
   paste the next. Out of full screen it offers the clipboard. In full screen
   the clipboard is not what you want, leaving is. */
function paintFloat(){
  const el=$("#floatP"); if(!el) return;
  /* P STAYS P. It used to become the exit glyph inside full screen, which
     made two buttons that both left full screen and no way to paste a second
     article without leaving first. Leaving is the dot's one job; pasting is
     P's one job; neither borrows the other's. */
  el.innerHTML = "P";
  el.title = "Paste and read. Drag to move.";
}
function floatPress(){
  /* No early return for full screen any more: pasting a fresh article while
     already in full screen is the whole point of reading this way. */
  /* The app always opens normal. Full screen is a consequence of PASTING, not
     of launching, and only when asked for: reading a fresh article is the
     moment the furniture stops helping, and it is a moment he chose.

     When it is wanted, ask HERE, inside the gesture, before anything async.
     Requested after the clipboard resolves it would be refused, because the
     user activation is spent by then. */
  if(ST.fullOnPaste && !document.body.classList.contains("fullread")){
    reqFull();
    setFullread(true);
  }
  pasteFromClipboard();
}
function wireFloat(){
  const el=$("#floatP"); if(!el) return;
  paintFloat();
  let sx=0, sy=0, ox=0, oy=0, moved=false, id=null;
  el.addEventListener("pointerdown",(e)=>{
    id=e.pointerId; moved=false;
    sx=e.clientX; sy=e.clientY;
    const r=el.getBoundingClientRect(); ox=sx-r.left; oy=sy-r.top;
    try{ el.setPointerCapture(id); }catch(_){}
    el.classList.add("moving");
  });
  el.addEventListener("pointermove",(e)=>{
    if(id===null || e.pointerId!==id) return;
    if(!moved && Math.abs(e.clientX-sx)+Math.abs(e.clientY-sy) < 7) return;
    moved=true;
    const [x,y]=clampFloat(e.clientX-ox, e.clientY-oy);
    el.style.left=x+"px"; el.style.top=y+"px";
  });
  const done=(e)=>{
    if(id===null) return;
    try{ el.releasePointerCapture(id); }catch(_){}
    id=null; el.classList.remove("moving");
    if(moved){
      /* remember where the thumb wants it, as a fraction so it survives a
         turn of the phone */
      const r=el.getBoundingClientRect();
      ST.fpX = r.left/Math.max(1,window.innerWidth);
      ST.fpY = r.top/Math.max(1,window.innerHeight);
      persist();
    } else {
      floatPress();               /* a press, not a drag */
    }
  };
  el.addEventListener("pointerup", done);
  el.addEventListener("pointercancel", done);
  window.addEventListener("resize", ()=>{ placeFloat(); placeFloatF(); placeFloatS(); });
  placeFloat();
}

/* ================= v3 helpers ================= */
function makeOffline(){
  const text=($("#pasteBox").value||"").trim();
  if(!text){ toast("Paste some text first."); return; }
  const vn=(anyVoice(ST.voice)||{}).name||"";
  const btn=$("#saveOfflineBtn"); const old=btn.textContent;
  btn.disabled=true; btn.textContent="Working...";
  toast("Saving to Offline in "+vn+"...");
  api("/api/prepare",{method:"POST",headers:{"Content-Type":"application/json"},
      body:(function(){ const b = prepareBody(text); MD.pending = null; return b; })()})
    .then(r=>r.json())
    .then(p=> api("/api/export",{method:"POST",
        headers:{"Content-Type":"application/json"},
        body:JSON.stringify({tid:p.id, vkey:ST.vkey, meta:!!ST.aimeta})})
        .then(r=>r.json().then(j=>({ok:r.ok,j}))))
    .then(({ok,j})=>{
      btn.disabled=false; btn.textContent=old;
      if(!ok){ toast(j.error||"Could not build offline files."); return; }
      $("#pasteBox").value=""; if(typeof updatePasteHint==="function") updatePasteHint();
      if(j.already){ toast("Already in Offline ("+(j.voice||vn)+")."); }
      else { toast("Saved to Offline"+(j.timing_source==="pcm"?" (waveform timing)":"")); }
      showOfflineList();
    }).catch(()=>{ btn.disabled=false; btn.textContent=old;
      toast("Could not build offline files."); });
}

function saveOffPos(){
  if(!OFF.name) return;
  const pos=OFF.idx||0;              /* resume by sentence, not by seconds */
  api("/api/offline/pos",{method:"POST",headers:{"Content-Type":"application/json"},
     body:JSON.stringify({name:OFF.name, pos})}).catch(()=>{});
}


/* ================= v9: offline reader (one sentence at a time) ============ */
/* The offline player mirrors the online Read tab. Each sentence is its own
   small mp3 clip. To read a sentence we light up the WHOLE sentence first, then
   set the audio source to that sentence's clip and play it. When the clip ends
   we advance to the next sentence and do the same. Because every clip stands
   alone and starts at zero, there is no cross-file timing to drift and the
   highlight can never jump to the end. Word highlighting, when enabled, uses
   the clip's own word times (already relative to that clip). */
const OFF = {
  audio: new Audio(), audioB: new Audio(),
  name:"", man:null, sents:[], idx:0, playing:false,
  raf:null, lastWord:-2, spans:[], dur:0, loop:false, _lastSave:0,
  gapTimer:null, armed:-1, handedOff:false,
};
OFF.audio.preload = "auto"; OFF.audioB.preload = "auto";
/* the offline player gets the same two-element handoff as the online one, so
   a sentence never waits on a file being opened, and a negative gap can let
   two clips overlap */
function offSwap(){ const t = OFF.audio; OFF.audio = OFF.audioB; OFF.audioB = t; }
function offArmNext(){
  const ni = OFF.idx + 1;
  if(ni >= OFF.sents.length){ OFF.armed = -1; return; }
  try{ OFF.audioB.pause(); }catch(e){}
  OFF.audioB.onended = null; OFF.audioB.onerror = null;
  OFF.audioB.src = offClipUrl(ni);
  OFF.audioB.playbackRate = ST.speed; OFF.audioB.volume = ST.volume/100;
  try{ OFF.audioB.load(); }catch(e){}
  OFF.armed = ni;
}
function offNextReady(ni){
  return OFF.armed === ni && OFF.audioB.readyState >= 3;
}
let OFF_CACHE = [];

function offClipUrl(i){
  return "/api/offline/clip/"+encodeURIComponent(OFF.name)+"/"+i+".mp3";
}
function offCancelGap(){ if(OFF.gapTimer){ clearTimeout(OFF.gapTimer); OFF.gapTimer=null; } }

function fmtDur(s){ s=Math.max(0,Math.round(s||0)); const m=Math.floor(s/60);
  return m+":"+String(s%60).padStart(2,"0"); }

function loadOffline(){
  OFF_SELECTING=false; OFF_SEL.clear();
  api("/api/offline/list").then(r=>r.json()).then(list=>{
    OFF_CACHE = list||[]; renderOffline();
  }).catch(()=>{ $("#offList").innerHTML =
    '<div class="empty">Could not read the audio folder.</div>'; });
}
let OFF_SELECTING=false; const OFF_SEL=new Set();
function offFiltered(){
  const q=($("#offSearch").value||"").trim().toLowerCase();
  return !q ? OFF_CACHE : OFF_CACHE.filter(m=>
    ((m.title||"")+" "+(m.ai_title||"")+" "+(m.summary||"")).toLowerCase().includes(q));
}
function renderOffline(){
  const box = $("#offList"); box.innerHTML="";
  box.classList.toggle("selecting", OFF_SELECTING);
  const list = offFiltered();
  if(!OFF_CACHE.length){
    box.innerHTML = '<div class="empty">No exported texts yet. Open a text, then press Export to save it offline.</div>';
    offPaintBar(); return;
  }
  if(!list.length){ box.innerHTML = '<div class="empty">Nothing matches that search.</div>'; offPaintBar(); return; }
  list.forEach(m=>{
    const row = document.createElement("div");
    row.className = "off-row" + (m.ready?"":" pending"); row.dataset.name=m.name;
    const when = new Date((m.created||0)*1000)
      .toLocaleDateString(undefined,{day:"2-digit",month:"short"});
    const sum = m.summary ? `<div class="osum"></div>` : "";
    row.innerHTML = `<div class="ometa"><b></b>`+
      `<small>${when} &middot; ${m.voice||""} &middot; ${fmtDur(m.duration)} &middot; ${m.count||0} sentences</small>${sum}</div>`;
    row.querySelector("b").textContent = m.title || m.name;
    if(m.summary) row.querySelector(".osum").textContent = m.summary;
    row.insertBefore(mkSelbox(OFF_SEL.has(m.name)), row.firstChild);
    if(m.ready){
      row.append(mkBtn("Play","iconbtn open",()=>openOffline(m.name)));
    } else {
      const w=document.createElement("small"); w.style.color="var(--faint)";
      w.style.marginRight="6px";
      w.textContent = m.legacy ? "old format" : "incomplete"; row.append(w);
    }
    row.append(mkBtn("Delete","iconbtn del",()=>offDelOne(m.name,m.title)));
    if(OFF_SELECTING) row.onclick=()=>offToggleOne(m.name);
    box.appendChild(row);
  });
  offPaintBar();
}
function offPaintBar(){
  const on=OFF_SELECTING, list=offFiltered(), selN=OFF_SEL.size;
  const t=$("#offSelToggle"); if(t){ t.textContent=on?"Cancel":"Select"; t.classList.toggle("on",on); }
  $("#offSelAll").classList.toggle("hidden",!on);
  $("#offDelSel").classList.toggle("hidden",!on);
  $("#offDelAll").classList.toggle("hidden",on);
  const cnt=$("#offSelCount"); cnt.classList.toggle("hidden",!on);
  $("#offDelSel").textContent="Delete ("+selN+")";
  const allSel=list.length && list.every(m=>OFF_SEL.has(m.name));
  $("#offSelAll").textContent=allSel?"Clear":"Select all";
  if(on) cnt.textContent=selN+" selected";
}
function offToggleOne(name){ if(OFF_SEL.has(name)) OFF_SEL.delete(name); else OFF_SEL.add(name); renderOffline(); }
function offSelectToggle(){ OFF_SELECTING=!OFF_SELECTING; if(!OFF_SELECTING) OFF_SEL.clear(); renderOffline(); }
function offSelectAll(){
  const list=offFiltered(); const allSel=list.length && list.every(m=>OFF_SEL.has(m.name));
  list.forEach(m=> allSel?OFF_SEL.delete(m.name):OFF_SEL.add(m.name)); renderOffline();
}
function offDelOne(name,title){
  if(!confirm('Delete "'+(title||name)+'" ?')) return;
  api("/api/offline/delete",{method:"POST",headers:{"Content-Type":"application/json"},
      body:JSON.stringify({name})}).then(()=>{ loadOffline(); toast("Deleted."); })
      .catch(()=>toast("Could not delete."));
}
function offDeleteSelected(){
  const names=[...OFF_SEL]; if(!names.length){ toast("Nothing selected."); return; }
  if(!confirm("Delete "+names.length+" export"+(names.length>1?"s":"")+"?")) return;
  api("/api/offline/delete_bulk",{method:"POST",headers:{"Content-Type":"application/json"},
      body:JSON.stringify({names})}).then(r=>r.json()).then(j=>{
    OFF_SEL.clear(); OFF_SELECTING=false; loadOffline();
    toast("Deleted "+(j.deleted||names.length)+".");
  }).catch(()=>toast("Could not delete."));
}
function offDeleteAll(){
  const n=OFF_CACHE.length; if(!n){ toast("Nothing exported yet."); return; }
  if(!confirm("Delete ALL "+n+" export"+(n>1?"s":"")+"? This removes their clips too.")) return;
  api("/api/offline/delete_all",{method:"POST"}).then(r=>r.json()).then(j=>{
    OFF_SEL.clear(); OFF_SELECTING=false; loadOffline();
    toast("Deleted all "+(j.deleted||n)+".");
  }).catch(()=>toast("Could not delete."));
}

function openOffline(name){
  stopOnline(); stopOffline();
  setOffStatus("Loading...");
  api("/api/offline/open/"+encodeURIComponent(name))
    .then(r=>r.json().then(j=>({ok:r.ok,j})))
    .then(({ok,j})=>{
      if(!ok || !j.sentences){ toast(j.error||"Could not open that text."); return; }
      if(j.schema && j.schema.indexOf("/3")<0){
        toast("This text was exported in the old format. Export it again."); return; }
      OFF.name = name; OFF.man = j; OFF.sents = j.sentences||[];
      markSession();
      OFF.dur = j.duration || 0;
      OFF.idx = 0; OFF.lastWord = -2;
      $("#offTitle").textContent = j.title || name;
      offRenderDoc();
      OFF.audio.playbackRate = ST.speed; OFF.audio.volume = ST.volume/100;
      offSetPlayIcon(false); OFF.playing=false;
      showOfflineReader();
      const startAtIdx = (i)=>{
        OFF.idx = clampOff(i);
        offHighlightSentence(OFF.idx, true); offUpdateCounter(); offSetSeek();
        if(ST.autoplay){ offPlay(); } else { setOffStatus("Press play to start."); }
      };
      if(ST.resume){
        api("/api/offline/pos/"+encodeURIComponent(name)).then(r=>r.json())
          .then(pp=>{ let i=Math.round(pp.pos||0);
            if(i>=OFF.sents.length-0.5 || i<0) i=0; startAtIdx(i); })
          .catch(()=>startAtIdx(0));
      } else { startAtIdx(0); }
    }).catch(()=>toast("Could not open that text."));
}
function clampOff(i){ return Math.max(0, Math.min(i, OFF.sents.length-1)); }
function offSetSeek(){
  const seek=$("#offSeek"); if(!seek) return;
  const n=Math.max(1, OFF.sents.length-1);
  if(!seek.matches(":active")) seek.value=Math.round(OFF.idx/n*1000);
}

function offRenderDoc(){
  const doc = $("#offDoc"); doc.innerHTML=""; OFF.spans=[];
  OFF.sents.forEach((s,i)=>{
    const sent = document.createElement("span");
    sent.className="sent"; sent.dataset.i=i;
    const text = s.text||""; const words = s.words||[];
    const wspans=[]; let p=0;
    words.forEach(w=>{
      const a=w.s|0, b=w.e|0;
      if(a>p) sent.appendChild(document.createTextNode(text.slice(p,a)));
      const ws=document.createElement("span"); ws.className="w";
      ws.textContent=text.slice(a,b); sent.appendChild(ws);
      wspans.push({el:ws, t:w.t, d:(w.d!=null?w.d:w.t)}); p=b;
    });
    if(p<text.length) sent.appendChild(document.createTextNode(text.slice(p)));
    sent.appendChild(document.createTextNode(" "));
    sent.onclick = ()=> offJump(i, OFF.playing);
    doc.appendChild(sent);
    OFF.spans.push(wspans);
  });
}
function offSentEl(i){ return $(`#offDoc .sent[data-i="${i}"]`); }

function offHighlightSentence(i, paused){
  document.querySelectorAll("#offDoc .sent.active, #offDoc .sent.paused")
    .forEach(e=>e.classList.remove("active","paused"));
  const el=offSentEl(i); if(!el) return;
  el.classList.add(paused?"paused":"active");
  sentenceToTop(el, "#offReaderScroll");
}
function offClearWords(i){
  const sp=OFF.spans[i]; if(sp) sp.forEach(o=>o.el.classList.remove("now"));
  OFF.lastWord=-2;
}
function offHighlightWord(i, t){
  const spans=OFF.spans[i]; if(!spans||!spans.length) return;
  let lo=0, hi=spans.length-1, k=-1;
  while(lo<=hi){ const m=(lo+hi)>>1;
    if(spans[m].t<=t){ k=m; lo=m+1; } else hi=m-1; }
  if(k===spans.length-1 && spans[k].d!=null && t>spans[k].d+0.12) k=-1;
  const key=i*100000+k;
  if(key===OFF.lastWord) return; OFF.lastWord=key;
  spans.forEach((o,wi)=>o.el.classList.toggle("now", wi===k));
  if(k>=0) keepWordVisible(spans[k].el, "#offReaderScroll");
}
/* v11: the offline player gets the same drift-corrected clock as the online
   reader (its own instance, so the two never fight), plus the per-voice sync
   nudge from Settings, applied via the voice stored in the manifest. Together
   with the server-side waveform timing this is what keeps the red word glued
   to the speech. */
const OFFCLK = { pred:0, lastWall:0, lastObs:-1, ready:false };
function offClockReset(t){
  OFFCLK.pred = t||0;
  OFFCLK.lastWall = (performance.now?performance.now():Date.now());
  OFFCLK.lastObs = -1; OFFCLK.ready = true;
}
function offClockSample(observed, rate, playing){
  const now = (performance.now?performance.now():Date.now());
  if(!OFFCLK.ready){ offClockReset(observed); return OFFCLK.pred; }
  const dt = (now - OFFCLK.lastWall)/1000; OFFCLK.lastWall = now;
  if(playing) OFFCLK.pred += dt * (rate||1);
  if(observed !== OFFCLK.lastObs){
    OFFCLK.lastObs = observed;
    const err = observed - OFFCLK.pred;
    if(Math.abs(err) > 0.35) OFFCLK.pred = observed;
    else OFFCLK.pred += err * 0.5;
  }
  if(OFFCLK.pred < 0) OFFCLK.pred = 0;
  return OFFCLK.pred;
}
/* the offline map rides in the manifest, written at export time. A book
   exported before v26 has none, so word gap simply does nothing there until
   it is exported again; it never guesses. */
function offSil(i){
  const s = OFF.man && OFF.man.sentences && OFF.man.sentences[i];
  return (s && s.sil) || null;
}
function offCurOffsetSec(){
  const vk = (OFF.man && OFF.man.vkey) || ST.vkey;
  return (ST.wordoffsets[vk]||0)/1000;
}
/* word highlight loop: drives the red word inside the CURRENT clip only, using
   the smoothed clip clock. Sentence-level highlight is already lit by
   offPlaySentence, so this is purely cosmetic and never advances sentences. */
function offFollow(){
  OFF.raf=null; if(!OFF.playing) return;
  const owf = wordGap(OWG, OFF.audio, offSil(OFF.idx), ()=>OFF.playing);
  if(ST.wordhl){
    const t = offClockSample(OFF.audio.currentTime||0, ST.speed*owf, owf!==0);
    offHighlightWord(OFF.idx, t + WORD_LEAD + offCurOffsetSec());
  }
  const dur = OFF.audio.duration;
  if(!OFF.handedOff && ST.gap <= 0 && dur && isFinite(dur)){
    const ni = OFF.idx + 1;
    const cross = dur + Math.min(ST.gap, -HANDOFF_LEAD);
    if(ni < OFF.sents.length && OFF.audio.currentTime >= cross && offNextReady(ni)){
      try{ OFF.audio.playbackRate = ST.speed; }catch(e){}
      OFF.handedOff = true; offPlaySentence(ni, true); return;
    }
  }
  OFF.raf=requestAnimationFrame(offFollow);
}
function offUpdateCounter(){
  { const el=$("#offCounter"), n=OFF.sents.length;
    if(el){
      /* offline clips are already on disk but their lengths are not read
         until played, so this is the plain estimate */
      let sec=0; const sp=Math.max(0.25, ST.speed||1);
      for(let i=OFF.idx; i<n; i++) sec += ((OFF.sents[i]||"").length/14.5)/sp;
      sec += Math.max(0, n-OFF.idx-1)*(ST.gap||0);
      el.innerHTML = (n?(OFF.idx+1):0) + " / " + n +
                     "<b>" + (n? fmtTime(Math.max(0,sec)) : "0:00") + "</b>";
    } }
}
function offSetPlayIcon(on){ $("#offPlay").innerHTML = on ? ICON_PAUSE : ICON_PLAY;
  audioState(on); }
function setOffStatus(s){ $("#offStatus").textContent=s||""; }

/* Light up the whole sentence FIRST, then load and play its clip. */
function offPlaySentence(i, viaHandoff){
  OFF.atEnd = false;
  offCancelGap(); wgReset(OWG);
  OFF.idx = clampOff(i);
  offClearWords(OFF.idx);
  offHighlightSentence(OFF.idx, false);       /* highlight before any audio */
  offUpdateCounter(); offSetSeek();
  if(ST.resume) saveOffPos();
  if(OFF.armed === OFF.idx){
    offSwap();                                /* already decoded and waiting */
    OFF.audioB.onended = null;
  } else {
    try{ OFF.audio.pause(); }catch(e){}
    OFF.audio.src = offClipUrl(OFF.idx);
  }
  OFF.armed = -1; OFF.handedOff = false;
  if(!viaHandoff){ try{ OFF.audioB.pause(); }catch(e){} }
  try{ OFF.audio.currentTime = 0; }catch(e){}
  OFF.audio.playbackRate = ST.speed; OFF.audio.volume = ST.volume/100;
  OFF.audio.onerror = ()=> setOffStatus("Could not load sentence "+(OFF.idx+1)+".");
  OFF.audio.onended = offEnded;
  offClockReset(0);                              /* fresh clip: clock from zero */
  const p = OFF.audio.play(); if(p&&p.catch) p.catch(()=>{});
  offArmNext();
  if(!OFF.raf) OFF.raf=requestAnimationFrame(offFollow);
}
function offEnded(){
  if(!OFF.playing || OFF.handedOff) return;
  offClearWords(OFF.idx);
  const ni = OFF.idx + 1;
  if(ni < OFF.sents.length){
    if(ST.gap > 0){
      offHighlightSentence(OFF.idx, true);
      OFF.gapTimer = setTimeout(()=>{ OFF.gapTimer=null;
        if(OFF.playing) offPlaySentence(ni); }, ST.gap*1000);
    } else { offPlaySentence(ni); }
    return;
  }
  if(ST.loop){ offPlaySentence(0); return; }
  OFF.atEnd = true;
  OFF.playing=false; offSetPlayIcon(false);
  offHighlightSentence(OFF.idx,true); offSetSeek();
  if(ST.resume) saveOffPos(); setOffStatus("Finished.");
}
function offPlay(){
  if(!OFF.man) return;
  stopOnline();
  if(OFF.atEnd){ OFF.atEnd = false; offPlaySentence(0); return; }
  OFF.playing=true; offSetPlayIcon(true); setOffStatus("");
  /* resume the same clip if we paused mid-sentence, else start it fresh */
  if(OFF.audio.src && OFF.audio.currentTime>0 && !OFF.audio.ended){
    OFF.audio.playbackRate=ST.speed; OFF.audio.volume=ST.volume/100;
    offHighlightSentence(OFF.idx,false);
    offClockReset(OFF.audio.currentTime||0);     /* resume from where we paused */
    OFF.audio.onended = offEnded;
    const p=OFF.audio.play(); if(p&&p.catch) p.catch(()=>{});
    offArmNext();
    if(!OFF.raf) OFF.raf=requestAnimationFrame(offFollow);
  } else {
    offPlaySentence(OFF.idx);
  }
}
function offPause(){
  offCancelGap();
  OFF.playing=false; offSetPlayIcon(false);
  try{ OFF.audio.pause(); }catch(e){}
  if(ST.resume) saveOffPos();
  offHighlightSentence(OFF.idx,true); setOffStatus("Paused.");
}
function offToggle(){ if(OFF.playing) offPause(); else offPlay(); }
function offStop(){
  offCancelGap();
  OFF.playing=false; offSetPlayIcon(false);
  try{ OFF.audio.pause(); OFF.audio.removeAttribute("src"); OFF.audio.load();
       OFF.audioB.pause(); OFF.audioB.removeAttribute("src"); OFF.audioB.load();
  }catch(e){}
  OFF.armed=-1; OFF.handedOff=false;
  OFF.idx=0; offClearWords(0); offHighlightSentence(0,true);
  offSetSeek(); offUpdateCounter(); setOffStatus("Stopped.");
}
function offJump(i, play){
  offCancelGap();
  i=clampOff(i);
  offClearWords(OFF.idx); OFF.idx=i;
  OFF.armed=-1; OFF.handedOff=false;
  try{ OFF.audio.pause(); OFF.audio.removeAttribute("src"); OFF.audio.load();
       OFF.audioB.pause(); OFF.audioB.removeAttribute("src"); OFF.audioB.load();
  }catch(e){}
  offHighlightSentence(i, !play); offUpdateCounter(); offSetSeek();
  if(ST.resume) saveOffPos();
  if(play){ offPlay(); }
}
function offPrev(){ offJump(OFF.idx-1, OFF.playing); }
function offNext(){ offJump(OFF.idx+1, OFF.playing); }
function offBack(){
  if(ST.resume) saveOffPos();
  offCancelGap();
  OFF.playing=false; try{ OFF.audio.pause(); OFF.audioB.pause(); }catch(e){}
  if(OFF.raf){ cancelAnimationFrame(OFF.raf); OFF.raf=null; }
  OFF.armed=-1; OFF.handedOff=false;
  OFF.audio.removeAttribute("src"); OFF.audio.load();
  OFF.audioB.removeAttribute("src"); OFF.audioB.load();
  OFF.man=null; OFF.sents=[]; OFF.spans=[]; $("#offDoc").innerHTML="";
  markSession();
  showOfflineList();
}

function bindV2(){
  document.querySelectorAll("#tabs .tab").forEach(t=>{
    if(t.id==="playerJump"){ t.onclick=jumpToPlayer; return; }
    t.onclick=()=>goTab(t.dataset.tab); });
  $("#gearCorner").onclick=openSheet;
  $("#pasteTab").onclick=()=>{ showHome(); pasteFromClipboard(); };
  wireCenterTaps("#readerScroll", false);
  wireCenterTaps("#offReaderScroll", true);
  $("#libSearch").addEventListener("input", renderLibrary);
  $("#offSearch").addEventListener("input", renderOffline);

  $("#libSelToggle").onclick=libSelectToggle;
  $("#libSelAll").onclick=libSelectAll;
  $("#libDelSel").onclick=libDeleteSelected;
  $("#libDelAll").onclick=libDeleteAll;
  $("#offSelToggle").onclick=offSelectToggle;
  $("#offSelAll").onclick=offSelectAll;
  $("#offDelSel").onclick=offDeleteSelected;
  $("#offDelAll").onclick=offDeleteAll;

  $("#offPlay").onclick=offToggle;
  $("#saveOfflineBtn").onclick=makeOffline;
  const rt=$("#resumeTog"); if(rt) rt.onclick=()=>{ ST.resume=!ST.resume;
    refreshToggles(); persist(); };
  $("#offSeek").addEventListener("input", e=>{
    const n=Math.max(1, OFF.sents.length-1);
    const i=clampOff(Math.round((e.target.value/1000)*n));
    if(i!==OFF.idx) offJump(i, OFF.playing);
  });

  const la=$("#langAll"); if(la) la.onclick=()=>setAllLangs(true);
  const ln=$("#langNone"); if(ln) ln.onclick=()=>setAllLangs(false);
}

function boot(){
  bind();
  /* one source of truth for the version: the Help span, copied up into
     the Settings sheet so the number is never typed twice */
  const _v = $("#appVer"), _vt = $("#appVerTop");
  if(_v && _vt) _vt.textContent = _v.textContent;
  Promise.all([
    api("/api/voices").then(r=>r.json()),
    api("/api/state").then(r=>r.json()),
    api("/api/langs").then(r=>r.json()).catch(()=>({langs:[],default:["en","hr"]})),
    /* Raced against a clock. This one asks Speechify for its catalogue and
       can be slow or hang on a poor connection, and the settings behind it
       must not wait: better to start with no Speechify voices, which the
       Settings sheet can refresh, than to sit on defaults. */
    Promise.race([
      api("/api/speechify/status").then(r=>r.json()).catch(()=>null),
      new Promise(r=>setTimeout(()=>r(null), 4000))
    ]),
    api("/api/browser").then(r=>r.json()).catch(()=>({mode:"chrome"})),
  ]).then(([voices, st, lc, sp, br])=>{
    ST.browser = (br && br.mode) || "chrome";
    ST.voices = voices;
    ST.langs = (lc && lc.langs) || [];
    // validate saved languages against the catalogue, keep catalogue order.
    // an explicit empty list is honoured (zero languages); only a missing or
    // malformed value falls back to the default pair.
    if(Array.isArray(st.enabledLangs)){
      ST.enabledLangs = ST.langs.map(l=>l.key).filter(k=>st.enabledLangs.includes(k));
    } else {
      const def = (lc && lc.default) || ["en","hr"];
      ST.enabledLangs = ST.langs.map(l=>l.key).filter(k=>def.includes(k));
    }
    /* the Speechify half, before a voice is chosen, so a remembered
       Speechify voice is actually there to be found */
    ST.engine  = (st.engine === "speechify") ? "speechify" : "edge";
    ST.spAccent = (st.spAccent === "us") ? "us" : "uk";
    ST.spVkey  = st.spVkey || "";
    ST.spSet   = Math.max(0, st.spSet | 0);

    ST.bothEngines = !!st.bothEngines;
    ST.spPicked = Array.isArray(st.spPicked) ? st.spPicked.slice() : null;
    ST.croVoice = st.croVoice || "lesya";
    ST.engVoice = st.engVoice || "beatrice_32";
    ST.lang = (st.lang === "hr" || st.lang === "auto") ? st.lang : "eng";
    ST.langAuto = (st.langAuto === "hr") ? "hr" : "eng";
    ST.fullOnPaste = (st.fullOnPaste === undefined) ? true : !!st.fullOnPaste;
    ST.hideTabs = !!st.hideTabs;
    ST.pane = (st.pane === "edge" || st.pane === "speechify") ? st.pane : "app";
    /* EDIT is never restored: coming back into a text editor you did not ask
       for is a surprise, and an unsaved edit from a previous session is not
       something to pretend to remember. */
    ST.mode = (st.mode === "text") ? "text" : "read";
    ST.voiceBar = (st.voiceBar === undefined) ? true : !!st.voiceBar;
    ST.floatPaste = (st.floatPaste === undefined) ? true : !!st.floatPaste;
    ST.floatFull = (st.floatFull !== false);
    if(typeof st.ffX === "number") ST.ffX = st.ffX;
    if(typeof st.ffY === "number") ST.ffY = st.ffY;
    ST.floatSwap = (st.floatSwap !== false);
    ST.adbMode = (st.adbMode !== false);
    if(typeof st.fsX === "number") ST.fsX = st.fsX;
    if(typeof st.fsY === "number") ST.fsY = st.fsY;
    if(typeof st.fpX === "number") ST.fpX = st.fpX;
    if(typeof st.fpY === "number") ST.fpY = st.fpY;
    if(sp){ ST.spInfo = sp; ST.spVoices = sp.voices || [];
            if(sp.perSet) ST.spPerSet = sp.perSet;
            if(sp.accent) ST.spAccent = sp.accent; }
    spClampSet();
    /* Only when it has NEVER been chosen. An empty array is a choice and is
       honoured: no Speechify voices on top, and they stay off. */
    if(ST.spPicked === null && (ST.spVoices||[]).length){
      ST.spPicked = ST.spVoices.slice(0, ST.spPerSet || 4).map(v=>v.vkey);
    }
    /* a saved Speechify engine with no voices behind it (no key yet, or no
       network) quietly falls back to Edge rather than showing an empty strip */
    if(ST.engine === "speechify" && !(ST.spVoices||[]).length) ST.engine = "edge";

    let v = anyVoice(st.voice||1);
    if(ST.engine === "speechify"){
      v = (ST.spVkey && ST.spVoices.find(x=>x.vkey===ST.spVkey))
          || ST.spVoices.find(x=>x.id===(st.voice||0)) || ST.spVoices[0];
      /* open on the page the remembered voice actually lives on, or it would
         not be among the four at the top and could not be seen at all */
      if(v){
        const at = ST.spVoices.indexOf(v);
        if(at >= 0) ST.spSet = Math.floor(at / (ST.spPerSet || 4));
      }
    }
    if(!v) v = voices[0];
    ST.vkey = v.vkey; ST.voice = v.id;
    if(v.engine === "speechify") ST.spVkey = v.vkey;
    ST.speed = st.speed||1.0; ST.volume = st.volume??100;
    ST.gap = Math.max(GAP_MIN, Math.min(GAP_MAX,
               (typeof st.gap === "number") ? st.gap : 0.0));
    ST.lag = Math.max(LAG_MIN, Math.min(LAG_MAX,
               (typeof st.lag === "number") ? st.lag : 0.0));
    ST.speed = Math.max(SPEED_MIN, Math.min(SPEED_MAX, ST.speed));
    ST.loop = !!st.loop;
    ST.size = st.size||13; ST.autoplay = (st.autoplay!==false); ST.focus = !!st.focus;
    ST.theme = THEMES.includes(st.theme) ? st.theme : "night";
    ST.font = FONTS[st.font] ? st.font : "sans";
    ST.lineheight = st.lineheight || 3;
    ST.wordhl = st.wordhl!==false;
    const okRgb = (v,d)=> (Array.isArray(v)&&v.length===3) ? v.map(clamp255) : d.slice();
    ST.rgbSent = okRgb(st.rgbSent, [255,217,59]);
    ST.rgbWord = okRgb(st.rgbWord, [226,59,78]);
    ST.rgbFont = okRgb(st.rgbFont, [255,255,255]);
    ST.rgbText = (Array.isArray(st.rgbText) && st.rgbText.length===3) ? st.rgbText.map(clamp255) : null;
    ST.wordoffsets = (st.wordoffsets && typeof st.wordoffsets==="object")
        ? st.wordoffsets : {};
    // if the remembered voice belongs to a language that is not enabled,
    // fall back to the first voice of the first enabled language
    const _vis = topSp().concat(topEdge());
    if(!_vis.some(x=>x.id===ST.voice)){
      const first = _vis[0];
      if(first){ ST.voice = first.id; ST.vkey = first.vkey; }
    }
    applyEngineCards(); renderSpAccents(); renderSpGrid(); renderSpKeys();
    renderEdgeGrid(); renderSpKeyList(); renderSpDead(); loadCroVoices();
    renderGroq(); wireGroq(); renderKeyList(); wireKeys();
    mediaSetup(); wireFloat(); wireFloatF(); wireFloatS(); wireFsWatch(); wirePersistFlush();
    renderVoices(); renderLangList();
    applySpeed(); applyVolume(); applyGap(); applyLag(); applyWgap(); applySize();
    applyFont(); applySpacing(); applyTheme(); applyWordHl(); applyHiColors(); applySync();
    ST.aimeta = !!st.aimeta; ST.resume = (st.resume!==false);
    /* Everything is restored. From here it is safe to write. */
    booted = true;
    bindV2(); refreshToggles(); setMode(ST.mode); showHome();
    /* Deliberately nothing about full screen here. The app always opens in
       the normal view, whatever the setting says. Full screen belongs to the
       act of pasting, which is a gesture, which is also the only thing the
       browser will accept a full screen request from. Doing it at load would
       have been both unwanted and, in a tab, impossible. */
  }).catch(()=>{ setStatus("Could not reach the server."); });
}
boot();
</script>
</body>
</html>
HTMLEOF

# marked, vendored whole and served from disk. 43 KB, self contained, no
# build step and no CDN: the phone is often offline and this is a local
# server. If this file were missing the page would simply find no parser
# and treat every text as plain, which is what every version before did.
cat > "$APPDIR/static/marked.umd.js" << 'MARKEDEOF'
/**
 * marked v18.0.10 - a markdown parser
 * Copyright (c) 2018-2026, MarkedJS. (MIT License)
 * Copyright (c) 2011-2018, Christopher Jeffrey. (MIT License)
 * https://github.com/markedjs/marked
 */

/**
 * DO NOT EDIT THIS FILE
 * The code in this file is generated from files in ./src/
 */
(function(g,f){if(typeof exports=="object"&&typeof module<"u"){module.exports=f()}else if("function"==typeof define && define.amd){define("marked",f)}else {g["marked"]=f()}}(typeof globalThis < "u" ? globalThis : typeof self < "u" ? self : this,function(){var exports={};var __exports=exports;var module={exports};
"use strict";var j=Object.defineProperty;var we=Object.getOwnPropertyDescriptor;var ye=Object.getOwnPropertyNames;var Pe=Object.prototype.hasOwnProperty;var Se=(l,e)=>{for(var t in e)j(l,t,{get:e[t],enumerable:!0})},_e=(l,e,t,n)=>{if(e&&typeof e=="object"||typeof e=="function")for(let s of ye(e))!Pe.call(l,s)&&s!==t&&j(l,s,{get:()=>e[s],enumerable:!(n=we(e,s))||n.enumerable});return l};var $e=l=>_e(j({},"__esModule",{value:!0}),l);var Lt={};Se(Lt,{Hooks:()=>P,Lexer:()=>x,Marked:()=>D,Parser:()=>b,Renderer:()=>y,TextRenderer:()=>_,Tokenizer:()=>w,defaults:()=>R,getDefaults:()=>z,lexer:()=>$t,marked:()=>g,options:()=>Ot,parse:()=>St,parseInline:()=>Pt,parser:()=>_t,setOptions:()=>wt,use:()=>Re,walkTokens:()=>yt});module.exports=$e(Lt);function z(){return{async:!1,breaks:!1,extensions:null,gfm:!0,hooks:null,pedantic:!1,renderer:null,silent:!1,tokenizer:null,walkTokens:null}}var R=z();function F(l){R=l}var E={exec:()=>null};function A(l){let e=[];return t=>{let n=Math.max(0,Math.min(3,t-1)),s=e[n];return s||(s=l(n),e[n]=s),s}}function d(l,e=""){let t=typeof l=="string"?l:l.source,n={replace:(s,r)=>{let i=typeof r=="string"?r:r.source;return i=i.replace(m.caret,"$1"),t=t.replace(s,i),n},getRegex:()=>new RegExp(t,e)};return n}var Le=((l="")=>{try{return!!new RegExp("(?<=1)(?<!1)"+l)}catch{return!1}})(),m={codeRemoveIndent:/^(?: {1,4}| {0,3}\t)/gm,outputLinkReplace:/\\([\[\]])/g,indentCodeCompensation:/^(\s+)(?:```)/,beginningSpace:/^\s+/,endingHash:/#$/,startingSpaceChar:/^ /,endingSpaceChar:/ $/,nonSpaceChar:/[^ ]/,newLineCharGlobal:/\n/g,tabCharGlobal:/\t/g,multipleSpaceGlobal:/\s+/g,blankLine:/^[ \t]*$/,doubleBlankLine:/\n[ \t]*\n[ \t]*$/,blockquoteStart:/^ {0,3}>/,blockquoteSetextReplace:/\n {0,3}((?:=+|-+) *)(?=\n|$)/g,blockquoteSetextReplace2:/^ {0,3}>[ \t]?/gm,listReplaceNesting:/^ {1,4}(?=( {4})*[^ ])/g,listIsTask:/^\[[ xX]\] +\S/,listReplaceTask:/^\[[ xX]\] +/,listTaskCheckbox:/\[[ xX]\]/,anyLine:/\n.*\n/,hrefBrackets:/^<(.*)>$/,tableDelimiter:/[:|]/,tableAlignChars:/^\||\| *$/g,tableRowBlankLine:/\n[ \t]*$/,tableAlignRight:/^ *-+: *$/,tableAlignCenter:/^ *:-+: *$/,tableAlignLeft:/^ *:-+ *$/,startATag:/^<a /i,endATag:/^<\/a>/i,startPreScriptTag:/^<(pre|code|kbd|script)(\s|>)/i,endPreScriptTag:/^<\/(pre|code|kbd|script)(\s|>)/i,startAngleBracket:/^</,endAngleBracket:/>$/,pedanticHrefTitle:/^([^'"]*[^\s])\s+(['"])(.*)\2/,unicodeAlphaNumeric:/[\p{L}\p{N}]/u,escapeTest:/[&<>"']/,escapeReplace:/[&<>"']/g,escapeTestNoEncode:/[<>"']|&(?!(#\d{1,7}|#[Xx][a-fA-F0-9]{1,6}|\w+);)/,escapeReplaceNoEncode:/[<>"']|&(?!(#\d{1,7}|#[Xx][a-fA-F0-9]{1,6}|\w+);)/g,caret:/(^|[^\[])\^/g,percentDecode:/%25/g,findPipe:/\|/g,splitPipe:/ \|/,slashPipe:/\\\|/g,carriageReturn:/\r\n|\r/g,spaceLine:/^ +$/gm,notSpaceStart:/^\S*/,endingNewline:/\n$/,listItemRegex:l=>new RegExp(`^( {0,3}${l})((?:[	 ][^\\n]*)?(?:\\n|$))`),nextBulletRegex:A(l=>new RegExp(`^ {0,${l}}(?:[*+-]|\\d{1,9}[.)])((?:[ 	][^\\n]*)?(?:\\n|$))`)),hrRegex:A(l=>new RegExp(`^ {0,${l}}((?:- *){3,}|(?:_ *){3,}|(?:\\* *){3,})(?:\\n+|$)`)),fencesBeginRegex:A(l=>new RegExp(`^ {0,${l}}(?:\`\`\`|~~~)`)),headingBeginRegex:A(l=>new RegExp(`^ {0,${l}}#`)),htmlBeginRegex:A(l=>new RegExp(`^ {0,${l}}<(?:[a-z].*>|!--)`,"i")),blockquoteBeginRegex:A(l=>new RegExp(`^ {0,${l}}>`))},Me=/^(?:[ \t]*(?:\n|$))+/,ze=/^((?: {4}| {0,3}\t)[^\n]+(?:\n(?:[ \t]*(?:\n|$))*)?)+/,Ee=/^ {0,3}(`{3,}(?=[^`\n]*(?:\n|$))|~{3,})([^\n]*)(?:\n|$)(?:|([\s\S]*?)(?:\n|$))(?: {0,3}\1[~`]* *(?=\n|$)|$)/,v=/^ {0,3}((?:-[\t ]*){3,}|(?:_[ \t]*){3,}|(?:\*[ \t]*){3,})(?:\n+|$)/,Ce=/^ {0,3}(#{1,6})(?=\s|$)(.*)(?:\n+|$)/,K=/ {0,3}(?:[*+-]|\d{1,9}[.)])/,ae=/^(?!bull |blockCode|fences|blockquote|heading|html|table)((?:.|\n(?!\s*?\n|bull |blockCode|fences|blockquote|heading|html|table))+?)\n {0,3}(=+|-+) *(?:\n+|$)/,le=d(ae).replace(/bull/g,K).replace(/blockCode/g,/(?: {4}| {0,3}\t)/).replace(/fences/g,/ {0,3}(?:`{3,}|~{3,})/).replace(/blockquote/g,/ {0,3}>/).replace(/heading/g,/ {0,3}#{1,6}(?:\s|$)/).replace(/html/g,/ {0,3}<[^\n>]+>\n/).replace(/\|table/g,"").getRegex(),Ae=d(ae).replace(/bull/g,K).replace(/blockCode/g,/(?: {4}| {0,3}\t)/).replace(/fences/g,/ {0,3}(?:`{3,}|~{3,})/).replace(/blockquote/g,/ {0,3}>/).replace(/heading/g,/ {0,3}#{1,6}(?:\s|$)/).replace(/html/g,/ {0,3}<[^\n>]+>\n/).replace(/table/g,/ {0,3}\|?(?:[:\- ]*\|)+[\:\- ]*\n/).getRegex(),W=/^([^\n]+(?:\n(?!hr|heading|lheading|blockquote|fences|list|html|table|[ \t]+\n)[^\n]+)*)/,Ie=/^[^\n]+/,X=/(?!\s*\])(?:\\[\s\S]|[^\[\]\\])+/,Be=d(/^ {0,3}\[(label)\]: *(?:\n[ \t]*)?([^<\s][^\s]*|<.*?>)(?:(?: +(?:\n[ \t]*)?| *\n[ \t]*)(title))? *(?:\n+|$)/).replace("label",X).replace("title",/(?:"(?:\\"?|[^"\\])*"|'[^'\n]*(?:\n[^'\n]+)*\n?'|\([^()]*\))/).getRegex(),De=d(/^(bull)([ \t][^\n]*?)?(?:\n|$)/).replace(/bull/g,K).getRegex(),Q="address|article|aside|base|basefont|blockquote|body|caption|center|col|colgroup|dd|details|dialog|dir|div|dl|dt|fieldset|figcaption|figure|footer|form|frame|frameset|h[1-6]|head|header|hr|html|iframe|legend|li|link|main|menu|menuitem|meta|nav|noframes|ol|optgroup|option|p|param|search|section|summary|table|tbody|td|tfoot|th|thead|title|tr|track|ul",J=/<!--(?:-?>|[\s\S]*?(?:-->|$))/,qe=d("^ {0,3}(?:<(script|pre|style|textarea)[\\s>][\\s\\S]*?(?:</\\1>[^\\n]*\\n*|$)|comment[^\\n]*(\\n+|$)|<\\?[\\s\\S]*?(?:\\?>[^\\n]*\\n*|$)|<![A-Z][\\s\\S]*?(?:>[^\\n]*\\n*|$)|<!\\[CDATA\\[[\\s\\S]*?(?:\\]\\]>[^\\n]*\\n*|$)|</?(tag)(?: +|\\n|/?>)[\\s\\S]*?(?:(?:\\n[ 	]*)+\\n|$)|<(?!script|pre|style|textarea)([a-z][\\w-]*)(?:attribute)*? */?>(?=[ \\t]*(?:\\n|$))[\\s\\S]*?(?:(?:\\n[ 	]*)+\\n|$)|</(?!script|pre|style|textarea)[a-z][\\w-]*\\s*>(?=[ \\t]*(?:\\n|$))[\\s\\S]*?(?:(?:\\n[ 	]*)+\\n|$))","i").replace("comment",J).replace("tag",Q).replace("attribute",/ +[a-zA-Z:_][\w.:-]*(?: *= *"[^"\n]*"| *= *'[^'\n]*'| *= *[^\s"'=<>`]+)?/).getRegex(),pe=l=>d(W).replace("hr",v).replace("heading"," {0,3}#{1,6}(?:\\s|$)").replace("|lheading","").replace("|table","").replace("blockquote"," {0,3}>").replace("fences"," {0,3}(?:`{3,}(?=[^`\\n]*(?:\\n|$))|~~~)[^\\n]*(?:\\n|$)").replace("list",l).replace("html","</?(?:tag)(?: +|\\n|/?>)|<(?:script|pre|style|textarea|!--)").replace("tag",Q).getRegex(),ve=pe(/ {0,3}(?:[*+-]|1[.)])[ \t]+[^ \t\n]/),He=pe(/ {0,3}(?:[*+-]|\d{1,9}[.)])(?:[ \t]|\n|$)/),Ze=d(/^( {0,3}> ?(paragraph|[^\n]*)(?:\n|$))+/).replace("paragraph",He).getRegex(),V={blockquote:Ze,code:ze,def:Be,fences:Ee,heading:Ce,hr:v,html:qe,lheading:le,list:De,newline:Me,paragraph:ve,table:E,text:Ie},ie=d("^ *([^\\n ].*)\\n {0,3}((?:\\| *)?:?-+:? *(?:\\| *:?-+:? *)*(?:\\| *)?)(?:\\n((?:(?! *\\n|hr|heading|blockquote|code|fences|list|html).*(?:\\n|$))*)\\n*|$)").replace("hr",v).replace("heading"," {0,3}#{1,6}(?:\\s|$)").replace("blockquote"," {0,3}>").replace("code","(?: {4}| {0,3}	)[^\\n]").replace("fences"," {0,3}(?:`{3,}(?=[^`\\n]*(?:\\n|$))|~~~)[^\\n]*(?:\\n|$)").replace("list"," {0,3}(?:[*+-]|1[.)])[ \\t]").replace("html","</?(?:tag)(?: +|\\n|/?>)|<(?:script|pre|style|textarea|!--)").replace("tag",Q).getRegex(),Ge={...V,lheading:Ae,table:ie,paragraph:d(W).replace("hr",v).replace("heading"," {0,3}#{1,6}(?:\\s|$)").replace("|lheading","").replace("table",ie).replace("blockquote"," {0,3}>").replace("fences"," {0,3}(?:`{3,}(?=[^`\\n]*(?:\\n|$))|~~~)[^\\n]*(?:\\n|$)").replace("list"," {0,3}(?:[*+-]|1[.)])[ \\t]+[^ \\t\\n]").replace("html","</?(?:tag)(?: +|\\n|/?>)|<(?:script|pre|style|textarea|!--)").replace("tag",Q).getRegex()},Qe={...V,html:d(`^ *(?:comment *(?:\\n|\\s*$)|<(tag)[\\s\\S]+?</\\1> *(?:\\n{2,}|\\s*$)|<tag(?:"[^"]*"|'[^']*'|\\s[^'"/>\\s]*)*?/?> *(?:\\n{2,}|\\s*$))`).replace("comment",J).replace(/tag/g,"(?!(?:a|em|strong|small|s|cite|q|dfn|abbr|data|time|code|var|samp|kbd|sub|sup|i|b|u|mark|ruby|rt|rp|bdi|bdo|span|br|wbr|ins|del|img)\\b)\\w+(?!:|[^\\w\\s@]*@)\\b").getRegex(),def:/^ *\[([^\]]+)\]: *<?([^\s>]+)>?(?: +(["(][^\n]+[")]))? *(?:\n+|$)/,heading:/^(#{1,6})(.*)(?:\n+|$)/,fences:E,lheading:/^(.+?)\n {0,3}(=+|-+) *(?:\n+|$)/,paragraph:d(W).replace("hr",v).replace("heading",` *#{1,6} *[^
]`).replace("lheading",le).replace("|table","").replace("blockquote"," {0,3}>").replace("|fences","").replace("|list","").replace("|html","").replace("|tag","").getRegex()},Ne=/^\\([!"#$%&'()*+,\-./:;<=>?@\[\]\\^_`{|}~])/,je=/^(`+)([^`]|[^`][\s\S]*?[^`])\1(?!`)/,ue=/^( {2,}|\\)\n(?!\s*$)/,Fe=/^(`+|[^`])(?:(?= {2,}\n)|[\s\S]*?(?:(?=[\\<!\[`*_]|\b_|$)|[^ ](?= {2,}\n)))/,$=/[\p{P}\p{S}]/u,I=/[\s\p{P}\p{S}]/u,H=/[^\s\p{P}\p{S}]/u,Ue=d(/^((?![*_])punctSpace)/,"u").replace(/punctSpace/g,I).getRegex(),Ke=/[\p{Pi}\p{Ps}"']/u,ce=/(?!~)[\p{P}\p{S}]/u,We=/(?!~)[\s\p{P}\p{S}]/u,Xe=/(?:[^\s\p{P}\p{S}]|~)/u,Je=d(/link|precode-code|html/,"g").replace("link",/\[(?:[^\[\]`]|(?<a>`+)[^`]+\k<a>(?!`))*?\]\((?:\\[\s\S]|[^\\\(\)]|\((?:\\[\s\S]|[^\\\(\)])*\))*\)/).replace("precode-",Le?"(?<!`)()":"(^^|[^`])").replace("code",/(?<b>`+)[^`]+\k<b>(?!`)/).replace("html",/<(?! )[^<>]*?>/).getRegex(),he=/^(?:\*+(?:((?!\*)punct)|([^\s*]))?)|^_+(?:((?!_)punct)|([^\s_]))?/,Ve=d(he,"u").replace(/punct/g,$).getRegex(),Ye=d(he,"u").replace(/punct/g,ce).getRegex(),et=/^(?:\*+(?:((?!\*)(?!openQuote)punct)|([^\s*]))?)|^_+(?:((?!_)(?!openQuote)punct)|([^\s_]))?/,tt=d(et,"u").replace(/openQuote/g,Ke).replace(/punct/g,$).getRegex(),de="^[^_*]*?__[^_*]*?\\*[^_*]*?(?=__)|[^*]+(?=[^*])|(?!\\*)punct(\\*+)(?=[\\s]|$)|notPunctSpace(\\*+)(?!\\*)(?=punctSpace|$)|(?!\\*)punctSpace(\\*+)(?=notPunctSpace)|[\\s](\\*+)(?!\\*)(?=punct)|(?!\\*)punct(\\*+)(?!\\*)(?=punct)|notPunctSpace(\\*+)(?=notPunctSpace)",nt=d(de,"gu").replace(/notPunctSpace/g,H).replace(/punctSpace/g,I).replace(/punct/g,$).getRegex(),rt=d(de,"gu").replace(/notPunctSpace/g,Xe).replace(/punctSpace/g,We).replace(/punct/g,ce).getRegex(),st="^[^_*]*?__[^_*]*?\\*[^_*]*?(?=__)|[^*]+(?=[^*])|(?!\\*)punct(\\*+)(?=[\\s]|$)|notPunctSpace(\\*+)(?!\\*)(?=punctSpace|$)|(?!\\*)[\\s](\\*+)(?=notPunctSpace)|[\\s](\\*+)(?!\\*)(?=punct)|(?!\\*)punct(\\*+)(?!\\*)(?=punct)|(?:(?!\\*)punct|notPunctSpace)(\\*+)(?!\\*)(?=notPunctSpace)",it=d(st,"gu").replace(/notPunctSpace/g,H).replace(/punctSpace/g,I).replace(/punct/g,$).getRegex(),ot=d("^[^_*]*?\\*\\*[^_*]*?_[^_*]*?(?=\\*\\*)|[^_]+(?=[^_])|(?!_)punct(_+)(?=[\\s]|$)|notPunctSpace(_+)(?!_)(?=punctSpace|$)|(?!_)punctSpace(_+)(?=notPunctSpace)|[\\s](_+)(?!_)(?=punct)|(?!_)punct(_+)(?!_)(?=punct)","gu").replace(/notPunctSpace/g,H).replace(/punctSpace/g,I).replace(/punct/g,$).getRegex(),at="^[^_*]*?\\*\\*[^_*]*?_[^_*]*?(?=\\*\\*)|[^_]+(?=[^_])|(?!_)punct(_+)(?=[\\s]|$)|notPunctSpace(_+)(?!_)(?=punctSpace|$)|(?!_)[\\s](_+)(?=notPunctSpace)|[\\s](_+)(?!_)(?=punct)|(?!_)punct(_+)(?!_)(?=punct)|(?:(?!_)punct|notPunctSpace)(_+)(?!_)(?=notPunctSpace)",lt=d(at,"gu").replace(/notPunctSpace/g,H).replace(/punctSpace/g,I).replace(/punct/g,$).getRegex(),pt=d(/^~~?(?:((?!~)punct)|[^\s~])/,"u").replace(/punct/g,$).getRegex(),ut="^[^~]+(?=[^~])|(?!~)punct(~~?)(?=[\\s]|$)|notPunctSpace(~~?)(?!~)(?=punctSpace|$)|(?!~)punctSpace(~~?)(?=notPunctSpace)|[\\s](~~?)(?!~)(?=punct)|(?!~)punct(~~?)(?!~)(?=punct)|notPunctSpace(~~?)(?=notPunctSpace)",ct=d(ut,"gu").replace(/notPunctSpace/g,H).replace(/punctSpace/g,I).replace(/punct/g,$).getRegex(),ht=d(/\\(punct)/,"gu").replace(/punct/g,$).getRegex(),dt=d(/^<(scheme:[^\s\x00-\x1f<>]*|email)>/).replace("scheme",/[a-zA-Z][a-zA-Z0-9+.-]{1,31}/).replace("email",/[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+(@)[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+(?![-_])/).getRegex(),kt=d(J).replace("(?:-->|$)","-->").getRegex(),gt=d("^comment|^</[a-zA-Z][\\w:-]*\\s*>|^<[a-zA-Z][\\w-]*(?:attribute)*?\\s*/?>|^<\\?[\\s\\S]*?\\?>|^<![a-zA-Z]+\\s[\\s\\S]*?>|^<!\\[CDATA\\[[\\s\\S]*?\\]\\]>").replace("comment",kt).replace("attribute",/\s+[a-zA-Z:_][\w.:-]*(?:\s*=\s*"[^"]*"|\s*=\s*'[^']*'|\s*=\s*[^\s"'=<>`]+)?/).getRegex(),G=/(?:\[(?:\\[\s\S]|[^\[\]\\])*\]|\\[\s\S]|`+(?!`)[^`]*?`+(?!`)|``+(?=\])|[^\[\]\\`])*?/,ft=d(/^!?\[(label)\]\(\s*(href)(?:(?:[ \t]+(?:\n[ \t]*)?|\n[ \t]*)(title))?\s*\)/).replace("label",G).replace("href",/<(?:\\.|[^\n<>\\])+>|[^ \t\n\x00-\x1f]+|(?=\))/).replace("title",/"(?:\\"?|[^"\\])*"|'(?:\\'?|[^'\\])*'|\((?:\\\)?|[^)\\])*\)/).getRegex(),ke=d(/^!?\[(label)\]\[(ref)\]/).replace("label",G).replace("ref",X).getRegex(),ge=d(/^!?\[(ref)\](?:\[\])?/).replace("ref",X).getRegex(),mt=d("reflink|nolink(?!\\()","g").replace("reflink",ke).replace("nolink",ge).getRegex(),oe=/[hH][tT][tT][pP][sS]?|[fF][tT][pP]/,Y={_backpedal:E,anyPunctuation:ht,autolink:dt,blockSkip:Je,br:ue,code:je,del:E,delLDelim:E,delRDelim:E,emStrongLDelim:Ve,emStrongRDelimAst:nt,emStrongRDelimUnd:ot,escape:Ne,link:ft,nolink:ge,punctuation:Ue,reflink:ke,reflinkSearch:mt,tag:gt,text:Fe,url:E},xt={...Y,emStrongLDelim:tt,emStrongRDelimAst:it,emStrongRDelimUnd:lt,link:d(/^!?\[(label)\]\((.*?)\)/).replace("label",G).getRegex(),reflink:d(/^!?\[(label)\]\s*\[([^\]]*)\]/).replace("label",G).getRegex()},U={...Y,emStrongRDelimAst:rt,emStrongLDelim:Ye,delLDelim:pt,delRDelim:ct,url:d(/^((?:protocol):\/\/|www\.)(?:[a-zA-Z0-9\-]+\.?)+[^\s<]*|^email/).replace("protocol",oe).replace("email",/[A-Za-z0-9._+-]+(@)[a-zA-Z0-9-_]+(?:\.[a-zA-Z0-9-_]*[a-zA-Z0-9])+(?![-_])/).getRegex(),_backpedal:/(?:[^?!.,:;*_'"~()&]+|\([^)]*\)|&(?![a-zA-Z0-9]+;$)|[?!.,:;*_'"~)]+(?!$))+/,del:/^(~~?)(?=[^\s~])((?:\\[\s\S]|[^\\])*?(?:\\[\s\S]|[^\s~\\]))\1(?=[^~]|$)/,text:d(/^(`+|~+|[^`~])(?:(?=[`~])|(?= {2,}\n)|(?=[a-zA-Z0-9.!#$%&'*+\/=?_`{\|}~-]+@)|[\s\S]*?(?:(?=[\\<!\[`*~_]|\b_|protocol:\/\/|www\.|$)|[^ ](?= {2,}\n)|[^a-zA-Z0-9.!#$%&'*+\/=?_`{\|}~-](?=[a-zA-Z0-9.!#$%&'*+\/=?_`{\|}~-]+@)))/).replace("protocol",oe).getRegex()},bt={...U,br:d(ue).replace("{2,}","*").getRegex(),text:d(U.text).replace("\\b_","\\b_| {2,}\\n").replace(/\{2,\}/g,"*").getRegex()},Z={normal:V,gfm:Ge,pedantic:Qe},B={normal:Y,gfm:U,breaks:bt,pedantic:xt};var Rt={"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"},fe=l=>Rt[l];function O(l,e){if(e){if(m.escapeTest.test(l))return l.replace(m.escapeReplace,fe)}else if(m.escapeTestNoEncode.test(l))return l.replace(m.escapeReplaceNoEncode,fe);return l}function ee(l){try{l=encodeURI(l).replace(m.percentDecode,"%")}catch{return null}return l}function te(l,e){let t=l.replace(m.findPipe,(r,i,o)=>{let p=!1,a=i;for(;--a>=0&&o[a]==="\\";)p=!p;return p?"|":" |"}),n=t.split(m.splitPipe),s=0;if(n[0].trim()||n.shift(),n.length>0&&!n.at(-1)?.trim()&&n.pop(),e)if(n.length>e)n.splice(e);else for(;n.length<e;)n.push("");for(;s<n.length;s++)n[s]=n[s].trim().replace(m.slashPipe,"|");return n}function L(l,e,t){let n=l.length;if(n===0)return"";let s=0;for(;s<n;){let r=l.charAt(n-s-1);if(r===e&&!t)s++;else if(r!==e&&t)s++;else break}return l.slice(0,n-s)}function ne(l){let e=l.split(`
`),t=e.length-1;for(;t>=0&&m.blankLine.test(e[t]);)t--;return e.length-t<=2?l:e.slice(0,t+1).join(`
`)}function me(l,e){if(l.indexOf(e[1])===-1)return-1;let t=0;for(let n=0;n<l.length;n++)if(l[n]==="\\")n++;else if(l[n]===e[0])t++;else if(l[n]===e[1]&&(t--,t<0))return n;return t>0?-2:-1}function xe(l,e=0){let t=e,n="";for(let s of l)if(s==="	"){let r=4-t%4;n+=" ".repeat(r),t+=r}else n+=s,t++;return n}function be(l,e,t,n,s){let r=e.href,i=e.title||null,o=l[1].replace(s.other.outputLinkReplace,"$1");n.state.inLink=!0;let p={type:l[0].charAt(0)==="!"?"image":"link",raw:t,href:r,title:i,text:o,tokens:n.inlineTokens(o)};return n.state.inLink=!1,p}function Tt(l,e,t){let n=l.match(t.other.indentCodeCompensation);if(n===null)return e;let s=n[1];return e.split(`
`).map(r=>{let i=r.match(t.other.beginningSpace);if(i===null)return r;let[o]=i;return o.length>=s.length?r.slice(s.length):r}).join(`
`)}var w=class{options;rules;lexer;constructor(e){this.options=e||R}space(e){let t=this.rules.block.newline.exec(e);if(t&&t[0].length>0)return{type:"space",raw:t[0]}}code(e){let t=this.rules.block.code.exec(e);if(t){let n=this.options.pedantic?t[0]:ne(t[0]),s=n.replace(this.rules.other.codeRemoveIndent,"");return{type:"code",raw:n,codeBlockStyle:"indented",text:s}}}fences(e){let t=this.rules.block.fences.exec(e);if(t){let n=t[0],s=Tt(n,t[3]||"",this.rules);return{type:"code",raw:n,lang:t[2]?t[2].trim().replace(this.rules.inline.anyPunctuation,"$1"):t[2],text:s}}}heading(e){let t=this.rules.block.heading.exec(e);if(t){let n=t[2].trim();if(this.rules.other.endingHash.test(n)){let s=L(n,"#");(this.options.pedantic||!s||this.rules.other.endingSpaceChar.test(s))&&(n=s.trim())}return{type:"heading",raw:L(t[0],`
`),depth:t[1].length,text:n,tokens:this.lexer.inline(n)}}}hr(e){let t=this.rules.block.hr.exec(e);if(t)return{type:"hr",raw:L(t[0],`
`)}}blockquote(e){let t=this.rules.block.blockquote.exec(e);if(t){let n=L(t[0],`
`).split(`
`),s="",r="",i=[];for(;n.length>0;){let o=!1,p=[],a;for(a=0;a<n.length;a++)if(this.rules.other.blockquoteStart.test(n[a]))p.push(n[a]),o=!0;else if(!o)p.push(n[a]);else break;n=n.slice(a);let u=p.join(`
`),c=u.replace(this.rules.other.blockquoteSetextReplace,`
    $1`).replace(this.rules.other.blockquoteSetextReplace2,"");s=s?`${s}
${u}`:u,r=r?`${r}
${c}`:c;let h=this.lexer.state.top;if(this.lexer.state.top=!0,this.lexer.blockTokens(c,i,!0),this.lexer.state.top=h,n.length===0)break;let k=i.at(-1);if(k?.type==="code")break;if(k?.type==="blockquote"){let T=k,f=n.join(`
`),S=T.raw+`
`+f.replace(this.rules.other.blockquoteSetextReplace2,""),M=this.blockquote(S);i[i.length-1]=M,s=`${s}
${f}`,r=r.substring(0,r.length-T.text.length)+M.text;break}else if(k?.type==="list"){let T=k,f=T.raw+`
`+n.join(`
`),S=this.list(f);i[i.length-1]=S,s=s.substring(0,s.length-k.raw.length)+S.raw,r=r.substring(0,r.length-T.raw.length)+S.raw,n=f.substring(i.at(-1).raw.length).split(`
`);continue}}return{type:"blockquote",raw:s,tokens:i,text:r}}}list(e){let t=this.rules.block.list.exec(e);if(t){let n=t[1].trim(),s=n.length>1,r={type:"list",raw:"",ordered:s,start:s?+n.slice(0,-1):"",loose:!1,items:[]};n=s?`\\d{1,9}\\${n.slice(-1)}`:`\\${n}`,this.options.pedantic&&(n=s?n:"[*+-]");let i=this.rules.other.listItemRegex(n),o=!1;for(;e;){let a=!1,u="",c="";if(!(t=i.exec(e))||this.rules.block.hr.test(e))break;u=t[0],e=e.substring(u.length);let h=xe(t[2].split(`
`,1)[0],t[1].length),k=e.split(`
`,1)[0],T=!h.trim(),f=0;if(this.options.pedantic?(f=2,c=h.trimStart()):T?f=t[1].length+1:(f=h.search(this.rules.other.nonSpaceChar),f=f>4?1:f,c=h.slice(f),f+=t[1].length),T&&this.rules.other.blankLine.test(k)&&(u+=k+`
`,e=e.substring(k.length+1),a=!0),!a){let S=this.rules.other.nextBulletRegex(f),M=this.rules.other.hrRegex(f),re=this.rules.other.fencesBeginRegex(f),se=this.rules.other.headingBeginRegex(f),Te=this.rules.other.htmlBeginRegex(f),Oe=this.rules.other.blockquoteBeginRegex(f);for(;e;){let N=e.split(`
`,1)[0],q;if(k=N,this.options.pedantic?(k=k.replace(this.rules.other.listReplaceNesting,"  "),q=k):q=k.replace(this.rules.other.tabCharGlobal,"    "),re.test(k)||se.test(k)||Te.test(k)||Oe.test(k)||S.test(k)||M.test(k))break;if(q.search(this.rules.other.nonSpaceChar)>=f||!k.trim())c+=`
`+q.slice(f);else{if(T||h.replace(this.rules.other.tabCharGlobal,"    ").search(this.rules.other.nonSpaceChar)>=4||re.test(h)||se.test(h)||M.test(h))break;c+=`
`+k}T=!k.trim(),u+=N+`
`,e=e.substring(N.length+1),h=q.slice(f)}}r.loose||(o?r.loose=!0:this.rules.other.doubleBlankLine.test(u)&&(o=!0)),r.items.push({type:"list_item",raw:u,task:!!this.options.gfm&&this.rules.other.listIsTask.test(c),loose:!1,text:c,tokens:[]}),r.raw+=u}let p=r.items.at(-1);if(p)p.raw=p.raw.trimEnd(),p.text=p.text.trimEnd();else return;r.raw=r.raw.trimEnd();for(let a of r.items)if(this.lexer.state.top=!1,a.tokens=this.lexer.blockTokens(a.text,[]),!r.loose){let u=a.tokens.filter(h=>h.type==="space"),c=u.length>0&&u.some(h=>this.rules.other.anyLine.test(h.raw));r.loose=c}for(let a of r.items){let u=a.tokens[0];if(a.task&&(u?.type==="text"||u?.type==="paragraph")){a.text=a.text.replace(this.rules.other.listReplaceTask,""),u.raw=u.raw.replace(this.rules.other.listReplaceTask,""),u.text=u.text.replace(this.rules.other.listReplaceTask,"");for(let h=this.lexer.inlineQueue.length-1;h>=0;h--)if(this.rules.other.listIsTask.test(this.lexer.inlineQueue[h].src)){this.lexer.inlineQueue[h].src=this.lexer.inlineQueue[h].src.replace(this.rules.other.listReplaceTask,"");break}let c=this.rules.other.listTaskCheckbox.exec(a.raw);if(c){let h={type:"checkbox",raw:c[0]+" ",checked:c[0]!=="[ ]"};a.checked=h.checked,r.loose?a.tokens[0]&&["paragraph","text"].includes(a.tokens[0].type)&&"tokens"in a.tokens[0]&&a.tokens[0].tokens?(a.tokens[0].raw=h.raw+a.tokens[0].raw,a.tokens[0].text=h.raw+a.tokens[0].text,a.tokens[0].tokens.unshift(h)):a.tokens.unshift({type:"paragraph",raw:h.raw,text:h.raw,tokens:[h]}):a.tokens.unshift(h)}}else a.task&&(a.task=!1)}if(r.loose)for(let a of r.items){a.loose=!0;for(let u of a.tokens)u.type==="text"&&(u.type="paragraph")}return r}}html(e){let t=this.rules.block.html.exec(e);if(t){let n=ne(t[0]);return{type:"html",block:!0,raw:n,pre:t[1]==="pre"||t[1]==="script"||t[1]==="style",text:n}}}def(e){let t=this.rules.block.def.exec(e);if(t){let n=t[1].toLowerCase().replace(this.rules.other.multipleSpaceGlobal," "),s=t[2]?t[2].replace(this.rules.other.hrefBrackets,"$1").replace(this.rules.inline.anyPunctuation,"$1"):"",r=t[3]?t[3].substring(1,t[3].length-1).replace(this.rules.inline.anyPunctuation,"$1"):t[3];return{type:"def",tag:n,raw:L(t[0],`
`),href:s,title:r}}}table(e){let t=this.rules.block.table.exec(e);if(!t||!this.rules.other.tableDelimiter.test(t[2]))return;let n=te(t[1]),s=t[2].replace(this.rules.other.tableAlignChars,"").split("|"),r=t[3]?.trim()?t[3].replace(this.rules.other.tableRowBlankLine,"").split(`
`):[],i={type:"table",raw:L(t[0],`
`),header:[],align:[],rows:[]};if(n.length===s.length){for(let o of s)this.rules.other.tableAlignRight.test(o)?i.align.push("right"):this.rules.other.tableAlignCenter.test(o)?i.align.push("center"):this.rules.other.tableAlignLeft.test(o)?i.align.push("left"):i.align.push(null);for(let o=0;o<n.length;o++)i.header.push({text:n[o],tokens:this.lexer.inline(n[o]),header:!0,align:i.align[o]});for(let o of r)i.rows.push(te(o,i.header.length).map((p,a)=>({text:p,tokens:this.lexer.inline(p),header:!1,align:i.align[a]})));return i}}lheading(e){let t=this.rules.block.lheading.exec(e);if(t){let n=t[1].trim();return{type:"heading",raw:L(t[0],`
`),depth:t[2].charAt(0)==="="?1:2,text:n,tokens:this.lexer.inline(n)}}}paragraph(e){let t=this.rules.block.paragraph.exec(e);if(t){let n=t[1].charAt(t[1].length-1)===`
`?t[1].slice(0,-1):t[1];return{type:"paragraph",raw:t[0],text:n,tokens:this.lexer.inline(n)}}}text(e){let t=this.rules.block.text.exec(e);if(t)return{type:"text",raw:t[0],text:t[0],tokens:this.lexer.inline(t[0])}}escape(e){let t=this.rules.inline.escape.exec(e);if(t)return{type:"escape",raw:t[0],text:t[1]}}tag(e){let t=this.rules.inline.tag.exec(e);if(t)return!this.lexer.state.inLink&&this.rules.other.startATag.test(t[0])?this.lexer.state.inLink=!0:this.lexer.state.inLink&&this.rules.other.endATag.test(t[0])&&(this.lexer.state.inLink=!1),!this.lexer.state.inRawBlock&&this.rules.other.startPreScriptTag.test(t[0])?this.lexer.state.inRawBlock=!0:this.lexer.state.inRawBlock&&this.rules.other.endPreScriptTag.test(t[0])&&(this.lexer.state.inRawBlock=!1),{type:"html",raw:t[0],inLink:this.lexer.state.inLink,inRawBlock:this.lexer.state.inRawBlock,block:!1,text:t[0]}}link(e){let t=this.rules.inline.link.exec(e);if(t){let n=t[2].trim();if(!this.options.pedantic&&this.rules.other.startAngleBracket.test(n)){if(!this.rules.other.endAngleBracket.test(n))return;let i=L(n.slice(0,-1),"\\");if((n.length-i.length)%2===0)return}else{let i=me(t[2],"()");if(i===-2)return;if(i>-1){let p=(t[0].indexOf("!")===0?5:4)+t[1].length+i;t[2]=t[2].substring(0,i),t[0]=t[0].substring(0,p).trim(),t[3]=""}}let s=t[2],r="";if(this.options.pedantic){let i=this.rules.other.pedanticHrefTitle.exec(s);i&&(s=i[1],r=i[3])}else r=t[3]?t[3].slice(1,-1):"";return s=s.trim(),this.rules.other.startAngleBracket.test(s)&&(this.options.pedantic&&!this.rules.other.endAngleBracket.test(n)?s=s.slice(1):s=s.slice(1,-1)),be(t,{href:s&&s.replace(this.rules.inline.anyPunctuation,"$1"),title:r&&r.replace(this.rules.inline.anyPunctuation,"$1")},t[0],this.lexer,this.rules)}}reflink(e,t){let n;if((n=this.rules.inline.reflink.exec(e))||(n=this.rules.inline.nolink.exec(e))){let s=(n[2]||n[1]).replace(this.rules.other.multipleSpaceGlobal," "),r=t[s.toLowerCase()];if(!r){let i=n[0].charAt(0);return{type:"text",raw:i,text:i}}return be(n,r,n[0],this.lexer,this.rules)}}emStrong(e,t,n=""){let s=this.rules.inline.emStrongLDelim.exec(e);if(!s||!s[1]&&!s[2]&&!s[3]&&!s[4]||s[4]&&n.match(this.rules.other.unicodeAlphaNumeric))return;if(!(s[1]||s[3]||"")||!n||this.rules.inline.punctuation.exec(n)){let i=[...s[0]].length-1,o,p,a=i,u=0,c=s[0][0],h=n===c,k=c==="*"?this.rules.inline.emStrongRDelimAst:this.rules.inline.emStrongRDelimUnd;for(k.lastIndex=0,t=t.slice(-1*e.length+i);(s=k.exec(t))!==null;){if(o=s[1]||s[2]||s[3]||s[4]||s[5]||s[6],!o)continue;if(p=[...o].length,s[3]||s[4]){a+=p;continue}else if(s[5]||s[6]){if(i%3&&!((i+p)%3)){u+=p;continue}if(h)break}if(a-=p,a>0)continue;p=Math.min(p,p+a+u);let T=[...s[0]][0].length,f=e.slice(0,i+s.index+T+p);if(Math.min(i,p)%2){let M=f.slice(1,-1);return{type:"em",raw:f,text:M,tokens:this.lexer.inlineTokens(M)}}let S=f.slice(2,-2);return{type:"strong",raw:f,text:S,tokens:this.lexer.inlineTokens(S)}}}}codespan(e){let t=this.rules.inline.code.exec(e);if(t){let n=t[2].replace(this.rules.other.newLineCharGlobal," "),s=this.rules.other.nonSpaceChar.test(n),r=this.rules.other.startingSpaceChar.test(n)&&this.rules.other.endingSpaceChar.test(n);return s&&r&&(n=n.substring(1,n.length-1)),{type:"codespan",raw:t[0],text:n}}}br(e){let t=this.rules.inline.br.exec(e);if(t)return{type:"br",raw:t[0]}}del(e,t,n=""){let s=this.rules.inline.delLDelim.exec(e);if(!s)return;if(!(s[1]||"")||!n||this.rules.inline.punctuation.exec(n)){let i=[...s[0]].length-1,o,p,a=i,u=this.rules.inline.delRDelim;for(u.lastIndex=0,t=t.slice(-1*e.length+i);(s=u.exec(t))!==null;){if(o=s[1]||s[2]||s[3]||s[4]||s[5]||s[6],!o||(p=[...o].length,p!==i))continue;if(s[3]||s[4]){a+=p;continue}if(a-=p,a>0)continue;p=Math.min(p,p+a);let c=[...s[0]][0].length,h=e.slice(0,i+s.index+c+p),k=h.slice(i,-i);return{type:"del",raw:h,text:k,tokens:this.lexer.inlineTokens(k)}}}}autolink(e){let t=this.rules.inline.autolink.exec(e);if(t){let n,s;return t[2]==="@"?(n=t[1],s="mailto:"+n):(n=t[1],s=n),{type:"link",raw:t[0],text:n,href:s,tokens:[{type:"text",raw:n,text:n}]}}}url(e){let t;if(t=this.rules.inline.url.exec(e)){let n,s;if(t[2]==="@")n=t[0],s="mailto:"+n;else{let r;do r=t[0],t[0]=this.rules.inline._backpedal.exec(t[0])?.[0]??"";while(r!==t[0]);n=t[0],t[1]==="www."?s="http://"+t[0]:s=t[0]}return{type:"link",raw:t[0],text:n,href:s,tokens:[{type:"text",raw:n,text:n}]}}}inlineText(e){let t=this.rules.inline.text.exec(e);if(t){let n=this.lexer.state.inRawBlock;return{type:"text",raw:t[0],text:t[0],escaped:n}}}};var x=class l{tokens;options;state;inlineQueue;tokenizer;constructor(e){this.tokens=[],this.tokens.links=Object.create(null),this.options=e||R,this.options.tokenizer=this.options.tokenizer||new w,this.tokenizer=this.options.tokenizer,this.tokenizer.options=this.options,this.tokenizer.lexer=this,this.inlineQueue=[],this.state={inLink:!1,inRawBlock:!1,top:!0};let t={other:m,block:Z.normal,inline:B.normal};this.options.pedantic?(t.block=Z.pedantic,t.inline=B.pedantic):this.options.gfm&&(t.block=Z.gfm,this.options.breaks?t.inline=B.breaks:t.inline=B.gfm),this.tokenizer.rules=t}static get rules(){return{block:Z,inline:B}}static lex(e,t){return new l(t).lex(e)}static lexInline(e,t){return new l(t).inlineTokens(e)}lex(e){e=e.replace(m.carriageReturn,`
`),this.blockTokens(e,this.tokens);for(let t=0;t<this.inlineQueue.length;t++){let n=this.inlineQueue[t];this.inlineTokens(n.src,n.tokens)}return this.inlineQueue=[],this.tokens}blockTokens(e,t=[],n=!1){this.tokenizer.lexer=this,this.options.pedantic&&(e=e.replace(m.tabCharGlobal,"    ").replace(m.spaceLine,""));let s=1/0;for(;e;){if(e.length<s)s=e.length;else{this.infiniteLoopError(e.charCodeAt(0));break}let r;if(this.options.extensions?.block?.some(o=>(r=o.call({lexer:this},e,t))?(e=e.substring(r.raw.length),t.push(r),!0):!1))continue;if(r=this.tokenizer.space(e)){e=e.substring(r.raw.length);let o=t.at(-1);r.raw.length===1&&o!==void 0?o.raw+=`
`:t.push(r);continue}if(r=this.tokenizer.code(e)){e=e.substring(r.raw.length);let o=t.at(-1);o?.type==="paragraph"||o?.type==="text"?(o.raw+=(o.raw.endsWith(`
`)?"":`
`)+r.raw,o.text+=`
`+r.text,this.inlineQueue.at(-1).src=o.text):t.push(r);continue}if(r=this.tokenizer.fences(e)){e=e.substring(r.raw.length),t.push(r);continue}if(r=this.tokenizer.heading(e)){e=e.substring(r.raw.length),t.push(r);continue}if(r=this.tokenizer.hr(e)){e=e.substring(r.raw.length),t.push(r);continue}if(r=this.tokenizer.blockquote(e)){e=e.substring(r.raw.length),t.push(r);continue}if(r=this.tokenizer.list(e)){e=e.substring(r.raw.length),t.push(r);continue}if(r=this.tokenizer.html(e)){e=e.substring(r.raw.length),t.push(r);continue}if(r=this.tokenizer.def(e)){e=e.substring(r.raw.length);let o=t.at(-1);o?.type==="paragraph"||o?.type==="text"?(o.raw+=(o.raw.endsWith(`
`)?"":`
`)+r.raw,o.text+=`
`+r.raw,this.inlineQueue.at(-1).src=o.text):this.tokens.links[r.tag]||(this.tokens.links[r.tag]={href:r.href,title:r.title},t.push(r));continue}if(r=this.tokenizer.table(e)){e=e.substring(r.raw.length),t.push(r);continue}if(r=this.tokenizer.lheading(e)){e=e.substring(r.raw.length),t.push(r);continue}let i=e;if(this.options.extensions?.startBlock){let o=1/0,p=e.slice(1),a;this.options.extensions.startBlock.forEach(u=>{a=u.call({lexer:this},p),typeof a=="number"&&a>=0&&(o=Math.min(o,a))}),o<1/0&&o>=0&&(i=e.substring(0,o+1))}if(this.state.top&&(r=this.tokenizer.paragraph(i))){let o=t.at(-1);n&&o?.type==="paragraph"?(o.raw+=(o.raw.endsWith(`
`)?"":`
`)+r.raw,o.text+=`
`+r.text,this.inlineQueue.pop(),this.inlineQueue.at(-1).src=o.text):t.push(r),n=i.length!==e.length,e=e.substring(r.raw.length);continue}if(r=this.tokenizer.text(e)){e=e.substring(r.raw.length);let o=t.at(-1);o?.type==="text"?(o.raw+=(o.raw.endsWith(`
`)?"":`
`)+r.raw,o.text+=`
`+r.text,this.inlineQueue.pop(),this.inlineQueue.at(-1).src=o.text):t.push(r);continue}if(e){this.infiniteLoopError(e.charCodeAt(0));break}}return this.state.top=!0,t}inline(e,t=[]){return this.inlineQueue.push({src:e,tokens:t}),t}inlineTokens(e,t=[]){this.tokenizer.lexer=this;let n=e;if(this.tokens.links){let o=Object.keys(this.tokens.links);o.length>0&&(n=n.replace(this.tokenizer.rules.inline.reflinkSearch,p=>o.includes(p.slice(p.lastIndexOf("[")+1,-1))?"["+"a".repeat(p.length-2)+"]":p))}n=n.replace(this.tokenizer.rules.inline.anyPunctuation,o=>"+".repeat(o.length)),n=n.replace(this.tokenizer.rules.inline.blockSkip,(o,p,a)=>{let u=a?a.length:0;return o.slice(0,u)+"["+"a".repeat(o.length-u-2)+"]"}),n=this.options.hooks?.emStrongMask?.call({lexer:this},n)??n;let s=!1,r="",i=1/0;for(;e;){if(e.length<i)i=e.length;else{this.infiniteLoopError(e.charCodeAt(0));break}s||(r=""),s=!1;let o;if(this.options.extensions?.inline?.some(a=>(o=a.call({lexer:this},e,t))?(e=e.substring(o.raw.length),t.push(o),!0):!1))continue;if(o=this.tokenizer.escape(e)){e=e.substring(o.raw.length),t.push(o);continue}if(o=this.tokenizer.tag(e)){e=e.substring(o.raw.length),t.push(o);continue}if(o=this.tokenizer.link(e)){e=e.substring(o.raw.length),t.push(o);continue}if(o=this.tokenizer.reflink(e,this.tokens.links)){e=e.substring(o.raw.length);let a=t.at(-1);o.type==="text"&&a?.type==="text"?(a.raw+=o.raw,a.text+=o.text):t.push(o);continue}if(o=this.tokenizer.emStrong(e,n,r)){e=e.substring(o.raw.length),t.push(o);continue}if(o=this.tokenizer.codespan(e)){e=e.substring(o.raw.length),t.push(o);continue}if(o=this.tokenizer.br(e)){e=e.substring(o.raw.length),t.push(o);continue}if(o=this.tokenizer.del(e,n,r)){e=e.substring(o.raw.length),t.push(o);continue}if(o=this.tokenizer.autolink(e)){e=e.substring(o.raw.length),t.push(o);continue}if(!this.state.inLink&&(o=this.tokenizer.url(e))){e=e.substring(o.raw.length),t.push(o);continue}let p=e;if(this.options.extensions?.startInline){let a=1/0,u=e.slice(1),c;this.options.extensions.startInline.forEach(h=>{c=h.call({lexer:this},u),typeof c=="number"&&c>=0&&(a=Math.min(a,c))}),a<1/0&&a>=0&&(p=e.substring(0,a+1))}if(o=this.tokenizer.inlineText(p)){e=e.substring(o.raw.length),o.raw.slice(-1)!=="_"&&(r=o.raw.slice(-1)),s=!0;let a=t.at(-1);a?.type==="text"?(a.raw+=o.raw,a.text+=o.text):t.push(o);continue}if(e){this.infiniteLoopError(e.charCodeAt(0));break}}return t}infiniteLoopError(e){let t="Infinite loop on byte: "+e;if(this.options.silent)console.error(t);else throw new Error(t)}};var y=class{options;parser;constructor(e){this.options=e||R}space(e){return""}code({text:e,lang:t,escaped:n}){let s=(t||"").match(m.notSpaceStart)?.[0],r=e.replace(m.endingNewline,"")+`
`;return s?'<pre><code class="language-'+O(s)+'">'+(n?r:O(r,!0))+`</code></pre>
`:"<pre><code>"+(n?r:O(r,!0))+`</code></pre>
`}blockquote({tokens:e}){return`<blockquote>
${this.parser.parse(e)}</blockquote>
`}html({text:e}){return e}def(e){return""}heading({tokens:e,depth:t}){return`<h${t}>${this.parser.parseInline(e)}</h${t}>
`}hr(e){return`<hr>
`}list(e){let t=e.ordered,n=e.start,s="";for(let o=0;o<e.items.length;o++){let p=e.items[o];s+=this.listitem(p)}let r=t?"ol":"ul",i=t&&n!==1?' start="'+n+'"':"";return"<"+r+i+`>
`+s+"</"+r+`>
`}listitem(e){return`<li>${this.parser.parse(e.tokens)}</li>
`}checkbox({checked:e}){return"<input "+(e?'checked="" ':"")+'disabled="" type="checkbox"> '}paragraph({tokens:e}){return`<p>${this.parser.parseInline(e)}</p>
`}table(e){let t="",n="";for(let r=0;r<e.header.length;r++)n+=this.tablecell(e.header[r]);t+=this.tablerow({text:n});let s="";for(let r=0;r<e.rows.length;r++){let i=e.rows[r];n="";for(let o=0;o<i.length;o++)n+=this.tablecell(i[o]);s+=this.tablerow({text:n})}return s&&(s=`<tbody>${s}</tbody>`),`<table>
<thead>
`+t+`</thead>
`+s+`</table>
`}tablerow({text:e}){return`<tr>
${e}</tr>
`}tablecell(e){let t=this.parser.parseInline(e.tokens),n=e.header?"th":"td";return(e.align?`<${n} align="${e.align}">`:`<${n}>`)+t+`</${n}>
`}strong({tokens:e}){return`<strong>${this.parser.parseInline(e)}</strong>`}em({tokens:e}){return`<em>${this.parser.parseInline(e)}</em>`}codespan({text:e}){return`<code>${O(e,!0)}</code>`}br(e){return"<br>"}del({tokens:e}){return`<del>${this.parser.parseInline(e)}</del>`}link({href:e,title:t,tokens:n}){let s=this.parser.parseInline(n),r=ee(e);if(r===null)return s;e=r;let i='<a href="'+e+'"';return t&&(i+=' title="'+O(t)+'"'),i+=">"+s+"</a>",i}image({href:e,title:t,text:n,tokens:s}){s&&(n=this.parser.parseInline(s,this.parser.textRenderer));let r=ee(e);if(r===null)return O(n);e=r;let i=`<img src="${e}" alt="${O(n)}"`;return t&&(i+=` title="${O(t)}"`),i+=">",i}text(e){return"tokens"in e&&e.tokens?this.parser.parseInline(e.tokens):"escaped"in e&&e.escaped?e.text:O(e.text)}};var _=class{strong({text:e}){return e}em({text:e}){return e}codespan({text:e}){return e}del({text:e}){return e}html({text:e}){return e}text({text:e}){return e}link({text:e}){return""+e}image({text:e}){return""+e}br(){return""}checkbox({raw:e}){return e}};var b=class l{options;renderer;textRenderer;constructor(e){this.options=e||R,this.options.renderer=this.options.renderer||new y,this.renderer=this.options.renderer,this.renderer.options=this.options,this.renderer.parser=this,this.textRenderer=new _}static parse(e,t){return new l(t).parse(e)}static parseInline(e,t){return new l(t).parseInline(e)}parse(e){this.renderer.parser=this;let t="";for(let n=0;n<e.length;n++){let s=e[n];if(this.options.extensions?.renderers?.[s.type]){let i=s,o=this.options.extensions.renderers[i.type].call({parser:this},i);if(o!==!1||!["space","hr","heading","code","table","blockquote","list","checkbox","html","def","paragraph","text"].includes(i.type)){t+=o||"";continue}}let r=s;switch(r.type){case"space":{t+=this.renderer.space(r);break}case"hr":{t+=this.renderer.hr(r);break}case"heading":{t+=this.renderer.heading(r);break}case"code":{t+=this.renderer.code(r);break}case"table":{t+=this.renderer.table(r);break}case"blockquote":{t+=this.renderer.blockquote(r);break}case"list":{t+=this.renderer.list(r);break}case"checkbox":{t+=this.renderer.checkbox(r);break}case"html":{t+=this.renderer.html(r);break}case"def":{t+=this.renderer.def(r);break}case"paragraph":{t+=this.renderer.paragraph(r);break}case"text":{t+=this.renderer.text(r);break}default:{let i='Token with "'+r.type+'" type was not found.';if(this.options.silent)return console.error(i),"";throw new Error(i)}}}return t}parseInline(e,t=this.renderer){this.renderer.parser=this;let n="";for(let s=0;s<e.length;s++){let r=e[s];if(this.options.extensions?.renderers?.[r.type]){let o=this.options.extensions.renderers[r.type].call({parser:this},r);if(o!==!1||!["escape","html","link","image","checkbox","strong","em","codespan","br","del","text"].includes(r.type)){n+=o||"";continue}}let i=r;switch(i.type){case"escape":{n+=t.text(i);break}case"html":{n+=t.html(i);break}case"link":{n+=t.link(i);break}case"image":{n+=t.image(i);break}case"checkbox":{n+=t.checkbox(i);break}case"strong":{n+=t.strong(i);break}case"em":{n+=t.em(i);break}case"codespan":{n+=t.codespan(i);break}case"br":{n+=t.br(i);break}case"del":{n+=t.del(i);break}case"text":{n+=t.text(i);break}default:{let o='Token with "'+i.type+'" type was not found.';if(this.options.silent)return console.error(o),"";throw new Error(o)}}}return n}};var P=class{options;block;constructor(e){this.options=e||R}static passThroughHooks=new Set(["preprocess","postprocess","processAllTokens","emStrongMask"]);static passThroughHooksRespectAsync=new Set(["preprocess","postprocess","processAllTokens"]);preprocess(e){return e}postprocess(e){return e}processAllTokens(e){return e}emStrongMask(e){return e}provideLexer(e=this.block){return e?x.lex:x.lexInline}provideParser(e=this.block){return e?b.parse:b.parseInline}};var D=class{defaults=z();options=this.setOptions;parse=this.parseMarkdown(!0);parseInline=this.parseMarkdown(!1);Parser=b;Renderer=y;TextRenderer=_;Lexer=x;Tokenizer=w;Hooks=P;constructor(...e){this.use(...e)}walkTokens(e,t){let n=[];for(let s of e)switch(n=n.concat(t.call(this,s)),s.type){case"table":{let r=s;for(let i of r.header)n=n.concat(this.walkTokens(i.tokens,t));for(let i of r.rows)for(let o of i)n=n.concat(this.walkTokens(o.tokens,t));break}case"list":{let r=s;n=n.concat(this.walkTokens(r.items,t));break}default:{let r=s;this.defaults.extensions?.childTokens?.[r.type]?this.defaults.extensions.childTokens[r.type].forEach(i=>{let o=r[i].flat(1/0);n=n.concat(this.walkTokens(o,t))}):r.tokens&&(n=n.concat(this.walkTokens(r.tokens,t)))}}return n}use(...e){let t=this.defaults.extensions||{renderers:{},childTokens:{}};return e.forEach(n=>{let s={...n};if(s.async=this.defaults.async||s.async||!1,n.extensions&&(n.extensions.forEach(r=>{if(!r.name)throw new Error("extension name required");if("renderer"in r){let i=t.renderers[r.name];i?t.renderers[r.name]=function(...o){let p=r.renderer.apply(this,o);return p===!1&&(p=i.apply(this,o)),p}:t.renderers[r.name]=r.renderer}if("tokenizer"in r){if(!r.level||r.level!=="block"&&r.level!=="inline")throw new Error("extension level must be 'block' or 'inline'");let i=t[r.level];i?i.unshift(r.tokenizer):t[r.level]=[r.tokenizer],r.start&&(r.level==="block"?t.startBlock?t.startBlock.push(r.start):t.startBlock=[r.start]:r.level==="inline"&&(t.startInline?t.startInline.push(r.start):t.startInline=[r.start]))}"childTokens"in r&&r.childTokens&&(t.childTokens[r.name]=r.childTokens)}),s.extensions=t),n.renderer){let r=this.defaults.renderer||new y(this.defaults);for(let i in n.renderer){if(!(i in r))throw new Error(`renderer '${i}' does not exist`);if(["options","parser"].includes(i))continue;let o=i,p=n.renderer[o],a=r[o];r[o]=(...u)=>{let c=p.apply(r,u);return c===!1&&(c=a.apply(r,u)),c||""}}s.renderer=r}if(n.tokenizer){let r=this.defaults.tokenizer||new w(this.defaults);for(let i in n.tokenizer){if(!(i in r))throw new Error(`tokenizer '${i}' does not exist`);if(["options","rules","lexer"].includes(i))continue;let o=i,p=n.tokenizer[o],a=r[o];r[o]=(...u)=>{let c=p.apply(r,u);return c===!1&&(c=a.apply(r,u)),c}}s.tokenizer=r}if(n.hooks){let r=this.defaults.hooks||new P;for(let i in n.hooks){if(!(i in r))throw new Error(`hook '${i}' does not exist`);if(["options","block"].includes(i))continue;let o=i,p=n.hooks[o],a=r[o];P.passThroughHooks.has(i)?r[o]=u=>{if(this.defaults.async&&P.passThroughHooksRespectAsync.has(i))return(async()=>{let h=await p.call(r,u);return a.call(r,h)})();let c=p.call(r,u);return a.call(r,c)}:r[o]=(...u)=>{if(this.defaults.async)return(async()=>{let h=await p.apply(r,u);return h===!1&&(h=await a.apply(r,u)),h})();let c=p.apply(r,u);return c===!1&&(c=a.apply(r,u)),c}}s.hooks=r}if(n.walkTokens){let r=this.defaults.walkTokens,i=n.walkTokens;s.walkTokens=function(o){let p=[];return p.push(i.call(this,o)),r&&(p=p.concat(r.call(this,o))),p}}this.defaults={...this.defaults,...s}}),this}setOptions(e){return this.defaults={...this.defaults,...e},this}lexer(e,t){return x.lex(e,t??this.defaults)}parser(e,t){return b.parse(e,t??this.defaults)}parseMarkdown(e){return(n,s)=>{let r={...s},i={...this.defaults,...r},o=this.onError(!!i.silent,!!i.async);if(this.defaults.async===!0&&r.async===!1)return o(new Error("marked(): The async option was set to true by an extension. Remove async: false from the parse options object to return a Promise."));if(typeof n>"u"||n===null)return o(new Error("marked(): input parameter is undefined or null"));if(typeof n!="string")return o(new Error("marked(): input parameter is of type "+Object.prototype.toString.call(n)+", string expected"));if(i.hooks&&(i.hooks.options=i,i.hooks.block=e),i.async)return(async()=>{let p=i.hooks?await i.hooks.preprocess(n):n,u=await(i.hooks?await i.hooks.provideLexer(e):e?x.lex:x.lexInline)(p,i),c=i.hooks?await i.hooks.processAllTokens(u):u;i.walkTokens&&await Promise.all(this.walkTokens(c,i.walkTokens));let k=await(i.hooks?await i.hooks.provideParser(e):e?b.parse:b.parseInline)(c,i);return i.hooks?await i.hooks.postprocess(k):k})().catch(o);try{i.hooks&&(n=i.hooks.preprocess(n));let a=(i.hooks?i.hooks.provideLexer(e):e?x.lex:x.lexInline)(n,i);i.hooks&&(a=i.hooks.processAllTokens(a)),i.walkTokens&&this.walkTokens(a,i.walkTokens);let c=(i.hooks?i.hooks.provideParser(e):e?b.parse:b.parseInline)(a,i);return i.hooks&&(c=i.hooks.postprocess(c)),c}catch(p){return o(p)}}}onError(e,t){return n=>{if(n.message+=`
Please report this to https://github.com/markedjs/marked.`,e){let s="<p>An error occurred:</p><pre>"+O(n.message+"",!0)+"</pre>";return t?Promise.resolve(s):s}if(t)return Promise.reject(n);throw n}}};var C=new D;function g(l,e){return C.parse(l,e)}g.options=g.setOptions=function(l){return C.setOptions(l),g.defaults=C.defaults,F(g.defaults),g};g.getDefaults=z;g.defaults=R;function Re(...l){return C.use(...l),g.defaults=C.defaults,F(g.defaults),g}g.use=Re;g.walkTokens=function(l,e){return C.walkTokens(l,e)};g.parseInline=C.parseInline;g.Parser=b;g.parser=b.parse;g.Renderer=y;g.TextRenderer=_;g.Lexer=x;g.lexer=x.lex;g.Tokenizer=w;g.Hooks=P;g.parse=g;var Ot=g.options,wt=g.setOptions,yt=g.walkTokens,Pt=g.parseInline,St=g,_t=b.parse,$t=x.lex;

if(__exports != exports)module.exports = exports;return module.exports}));
//# sourceMappingURL=marked.umd.js.map
MARKEDEOF
printf '    %s\xe2\x9c\x93%s %sindex.html%s\n' "$GREEN" "$OFF" "$DIM" "$OFF"
prog 78 "the page furniture"

prog 90 "the commands"

# ------------------------------------------- replacing a running command ----
# maread-update is a shell script that runs THIS installer, so while this is
# writing, the old updater is still alive and bash is still reading it. A
# plain "cat >" truncates the file the running shell is reading from, and it
# then carries on at the old byte offset into whatever is there now, which is
# either nothing or the middle of a different line. Small files survive by
# luck, because bash had already buffered the whole thing. Luck is not a
# mechanism.
#
# So every command is written beside its own name and renamed over the top.
# A rename swaps the directory entry; the running shell keeps its open file
# and reads it to the end undisturbed. Nothing half written is ever reachable
# under the real name either, because the real name only appears when the file
# behind it is complete.
put_cmd() {   # $1 = final path
  chmod +x "$1.new" 2>/dev/null || true
  mv -f "$1.new" "$1"
}

cat > "$BIN/maread.new" << 'LAUNCHEOF'
#!/usr/bin/env bash
# MA Reader Web (Fire | the Word). Serves on 0.0.0.0 so any device on your
# Wi-Fi can open it. Ctrl-C stops it.
APPDIR="$HOME/.maread-web"
PORT="${MAREAD_WEB_PORT:-8081}"
HOST="${MAREAD_WEB_HOST:-0.0.0.0}"
PORTFILE="$APPDIR/port.txt"
caffeinate -dimsu -w $$ >/dev/null 2>&1 &
CAFF=$!

# ---------------------------------------------------------- which browser --
# Android's default browser is whatever the phone decided, and this app is
# built and tested against Chrome. So Chrome is asked for by name, and the
# phone's own default is the fallback rather than the rule. One line in
# browser.txt overrides it, and Settings writes that line, so the choice can
# be made from inside the app without touching the terminal.
# $'...' so the escapes become real bytes; a plain single quoted string
# would print the characters \033[38;5;245m at you instead of colouring.
# The same palette maread-update wears, because this is one app and it
# should look like one. Gold for a key, dim for a label, white for a value.
# No red anywhere: red means something is wrong, and nothing here is wrong.
DIMC=$'\033[38;5;245m'; KEYC=$'\033[1;38;5;222m'; OFFC=$'\033[0m'
WHTC=$'\033[38;5;252m'; GRNC=$'\033[38;5;114m'
ruleC(){ printf '   %s%s%s\n' "$DIMC" "------------------------------------------" "$OFFC"; }
BROWSERFILE="$APPDIR/browser.txt"
read_pref(){
  [ -f "$BROWSERFILE" ] || { echo chrome; return; }
  case "$(tr -d ' \r\n' < "$BROWSERFILE" | tr A-Z a-z)" in
    auto) echo auto ;;
    *)    echo chrome ;;
  esac
}

# On a Mac the browser is opened by NAME, and `open` reports a missing
# application with a non-zero exit, so its result can simply be believed.
# No package list, no reading the output for the word Error.
open_chrome(){ open -a "Google Chrome" "$1" >/dev/null 2>&1; }
open_default(){ open "$1" >/dev/null 2>&1; }

open_url(){   # $1 url, $2 chrome|auto
  if [ "$2" = "chrome" ]; then
    open_chrome "$1" && return 0
    printf '   %sChrome not found, using the phone default%s\n' "$DIMC" "$OFFC"
  fi
  open_default "$1"
}


lan_ip(){
  # ipconfig is the macOS way; ip route is Linux only. en0 is Wi-Fi on every
  # Mac made this decade.
  for i in en0 en1 en2; do
    a="$(ipconfig getifaddr "$i" 2>/dev/null)"
    [ -n "$a" ] && { echo "$a"; return 0; }
  done
  return 0
}

show_head(){   # $1 = the port actually in use
  IP="$(lan_ip)"
  echo ""
  printf '   %sMA READER%s  %sserver%s\n' "$KEYC" "$OFFC" "$DIMC" "$OFFC"
  ruleC
  printf '    %s%-14s%s %s%s%s\n' "$DIMC" "on this phone" "$OFFC" \
    "$WHTC" "http://127.0.0.1:$1" "$OFFC"
  if [ -n "$IP" ]; then
    printf '    %s%-14s%s %s%s%s\n' "$DIMC" "on Wi-Fi" "$OFFC" \
      "$WHTC" "http://$IP:$1" "$OFFC"
  fi
  printf '    %s%-14s%s %s%s%s\n' "$DIMC" "library" "$OFFC" \
    "$WHTC" "~/.maread" "$OFFC"
  ruleC
  printf '    %s[O]%s %sopen in Chrome%s\n' "$KEYC" "$OFFC" "$DIMC" "$OFFC"
  printf '    %s[A]%s %sopen in the default browser%s\n' "$KEYC" "$OFFC" "$DIMC" "$OFFC"
  printf '    %s[Q]%s %sstop%s\n' "$KEYC" "$OFFC" "$DIMC" "$OFFC"
  ruleC
  echo ""
}

# The server takes the first free port at or above the base one and writes the
# winner to a portfile, so wait for that rather than guessing; otherwise a
# second copy of the app would open the browser on the first copy's page.
# ---------------------------------------------------- the shell, if wanted --
# One command. maread brings the privileged shell up by itself, so there is
# nothing else to remember and nothing else to type.
#
# It is read from the SETTINGS FILE, which is the same file the sheet writes,
# so the switch in Settings decides what the NEXT run does. A launcher cannot
# ask the running app, and should not: the app may not be running yet.
#
# Nothing here ever blocks or prompts. If Shizuku is there it already works
# and there is nothing to do. If adb is there it is nudged into connecting,
# quietly, with one line of report either way. Any failure is reported and
# the app starts anyway, because reading is the point and switching apps is a
# convenience on top of it.
adb_wanted() {
  python - "$APPDIR/web_state.json" <<'PYADB' 2>/dev/null || echo 1
import json, sys
try:
    with open(sys.argv[1], encoding="utf-8") as f:
        print(0 if json.load(f).get("adbMode", True) else 1)
except Exception:
    print(0)          # no settings yet: on, which is the shipped default
PYADB
}

adb_bring_up() {
  # Nothing to bring up on a Mac. Cmd+Tab is already there; it only needs
  # Accessibility permission, which is asked for once and then remembered,
  # and which no script may grant itself.
  [ "$(adb_wanted)" = "0" ] || return 0
  if osascript -e 'tell application "System Events" to get name' >/dev/null 2>&1; then
    printf '   %sapp switching is ready%s\n' "$DIMC" "$OFFC"
  else
    printf '   %sapp switching needs Accessibility for this terminal%s\n' "$DIMC" "$OFFC"
    printf '   %srun maread-adb to open the right pane%s\n' "$DIMC" "$OFFC"
  fi
}

adb_bring_up

rm -f "$PORTFILE"
(
  n=0
  while [ "$n" -lt 40 ]; do
    if [ -s "$PORTFILE" ]; then
      open_url "http://localhost:$(cat "$PORTFILE")" "$(read_pref)"
      exit 0
    fi
    sleep 0.25; n=$((n+1))
  done
  open_url "http://localhost:$PORT" "$(read_pref)"
) &

# The VENV python, never the system one: the system Python has no Flask and
# on recent macOS may not be allowed to get it.
PYRUN="$APPDIR/venv/bin/python"
[ -x "$PYRUN" ] || PYRUN="$(command -v python3 2>/dev/null || command -v python 2>/dev/null || echo python3)"
MAREAD_WEB_HOST="$HOST" MAREAD_WEB_PORT="$PORT" "$PYRUN" "$APPDIR/server.py" &
SRV=$!
# The launcher reads single keys too, so it carries the same guarantee. Its
# cleanup now puts the terminal back before anything else, because a person
# whose terminal has gone deaf cannot even see whether the server stopped.
TTY_SAVED=""
[ -t 0 ] && TTY_SAVED="$(stty -g 2>/dev/null || true)"
tty_restore() {
  [ -n "$TTY_SAVED" ] && stty "$TTY_SAVED" 2>/dev/null || true
  [ -t 0 ] && stty echo 2>/dev/null || true
}
cleanup(){ tty_restore; kill "$SRV" 2>/dev/null; kill "$CAFF" 2>/dev/null; }
trap 'cleanup' EXIT
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM
trap 'cleanup; exit 129' HUP

# ------------------------------------------------------------- hotkeys -----
# While it runs, one key reopens the page. Useful when the browser was closed,
# or when a page has gone stale and you want a second opinion from the other
# browser without stopping the server.
url_port(){
  if [ -s "$PORTFILE" ]; then cat "$PORTFILE"; else echo "$PORT"; fi
}
url_now(){ echo "http://localhost:$(url_port)"; }
if [ -t 0 ]; then
  # wait for the real port before drawing, so the address shown is the one
  # that is actually being served
  n=0
  while [ "$n" -lt 40 ] && [ ! -s "$PORTFILE" ]; do sleep 0.1; n=$((n+1)); done
  show_head "$(url_port)"
  while kill -0 "$SRV" 2>/dev/null; do
    if IFS= read -rsn1 -t 1 K 2>/dev/null; then
      case "$K" in
        o|O) printf '   %sopening in Chrome%s\n' "$DIMC" "$OFFC"
             open_url "$(url_now)" chrome ;;
        a|A) printf '   %sopening in the default browser%s\n' "$DIMC" "$OFFC"
             open_default "$(url_now)" ;;
        q|Q) break ;;
      esac
    fi
  done
  cleanup
  ST=0
else
  wait "$SRV"; ST=$?
  kill "$CAFF" 2>/dev/null || true
fi
exit $ST
LAUNCHEOF
put_cmd "$BIN/maread"

# ------------------------------------------------------------ put keys back --
if [ -n "$STASH" ] && [ -d "$STASH" ]; then
  BACK=0
  for f in $KEEP; do
    if [ -f "$STASH/$f" ]; then
      cp -p "$STASH/$f" "$APPDIR/$f" 2>/dev/null && BACK=$((BACK+1))
    fi
  done
  chmod 600 "$APPDIR/speechify_api.txt" 2>/dev/null || true
  rm -rf "$STASH"
  [ "$BACK" -gt 0 ] && printf '   %s%s file(s) put back: you do not have to enter a key again%s\n' \
    "$GREEN" "$BACK" "$OFF"
fi

# leave behind the one word update command, so this is the last time anyone
# has to remember a URL
cat > "$BIN/maread-update.new" << 'UPDEOF'
#!/usr/bin/env bash
# Update MA Reader. Nothing is installed until it is asked for.
A=$'\033[38;5;214m'; G=$'\033[38;5;114m'; R=$'\033[38;5;203m'
D=$'\033[38;5;245m'; K=$'\033[1;38;5;222m'; W=$'\033[38;5;252m'; O=$'\033[0m'
RAW="https://raw.githubusercontent.com/markoboskoauroville/MA_READER_TERMUX_MACOS/main"
FILE="3sh_i_ma_reader_v3_macos.sh"
APPDIR="$HOME/.maread-web"

rule(){ printf '   %s%s%s\n' "$D" "------------------------------------------" "$O"; }

# ---------------------------------------------------- the echo guarantee ----
# READING ONE KEY MEANS TURNING ECHO OFF. If the script then dies between
# turning it off and turning it back on, the terminal is left deaf: the person
# types and nothing appears. Ctrl+C during a menu does exactly that, and so
# does closing the app, and the damage outlives the script.
#
# So the terminal's state is saved ONCE, before anything touches it, and a
# trap puts it back on EVERY way out: normal exit, Ctrl+C, TERM, HUP. The trap
# is armed BEFORE the first stty, because a trap armed afterwards is a trap
# with a hole in it exactly where the bug lives.
TTY_SAVED=""
[ -t 0 ] && TTY_SAVED="$(stty -g 2>/dev/null || true)"
tty_restore() {
  [ -n "$TTY_SAVED" ] && stty "$TTY_SAVED" 2>/dev/null || true
  # a second belt: sane puts echo back even if the saved string is unusable
  [ -t 0 ] && stty echo 2>/dev/null || true
}
trap 'tty_restore' EXIT
trap 'tty_restore; exit 130' INT
trap 'tty_restore; exit 143' TERM
trap 'tty_restore; exit 129' HUP

getkey() {
  if [ -t 0 ]; then
    old="$(stty -g 2>/dev/null)"
    # see the note in the installer: -icanon -echo, never full raw, so that
    # Ctrl+C remains a signal and the trap can put the terminal back
    stty -icanon -echo min 1 time 0 2>/dev/null
    k="$(dd bs=1 count=1 2>/dev/null)"; stty "$old" 2>/dev/null
    printf '%s' "$k"
  else
    IFS= read -r k || k=""; printf '%s' "$k"
  fi
}

bar(){   # $1 percent, $2 label
  [ -t 1 ] || return 0
  w=22; f=$(( $1 * w / 100 )); b=""; i=0
  while [ "$i" -lt "$w" ]; do
    if [ "$i" -lt "$f" ]; then b="$b#"; else b="$b."; fi; i=$((i+1))
  done
  printf '\r   %s[%s]%s %3d%%  %s%-22s%s' "$A" "$b" "$O" "$1" "$D" "$2" "$O"
  [ "$1" -ge 100 ] && printf '\n'
  return 0
}

have_ver(){
  [ -f "$APPDIR/static/index.html" ] || { echo "none"; return; }
  v="$(grep -o 'appVer">v[0-9.]*' "$APPDIR/static/index.html" 2>/dev/null | head -1 | sed 's/.*>v//')"
  [ -n "$v" ] && echo "v$v" || echo "unknown"
}

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# ---------------------------------------------------------------- fetch ----
# Downloaded first so the version can be named before anything is asked. The
# file lands in a temporary folder and touches nothing until you say so.
printf '\n   %sMA READER%s  %supdate%s\n' "$K" "$O" "$D" "$O"
rule
TOTAL="$(curl -sIL --connect-timeout 20 "$RAW/$FILE" 2>/dev/null \
         | tr -d '\r' | awk 'tolower($1)=="content-length:"{n=$2} END{print n}')"
case "$TOTAL" in ''|*[!0-9]*) TOTAL=0 ;; esac

curl -fsSL --retry 3 --connect-timeout 20 -o "$TMP/$FILE" "$RAW/$FILE" &
CURL=$!
while kill -0 "$CURL" 2>/dev/null; do
  if [ "$TOTAL" -gt 0 ] && [ -f "$TMP/$FILE" ]; then
    NOW="$(wc -c < "$TMP/$FILE" 2>/dev/null || echo 0)"
    P=$(( NOW * 100 / TOTAL )); [ "$P" -gt 99 ] && P=99
    bar "$P" "downloading"
  else
    bar 0 "downloading"
  fi
  sleep 0.2
done
wait "$CURL"; RC=$?
if [ "$RC" != "0" ] || [ ! -s "$TMP/$FILE" ]; then
  printf '\r   %scould not reach GitHub. Nothing was changed.%s\n\n' "$R" "$O"; exit 1
fi
bar 100 "downloaded"

SIZE="$(wc -c < "$TMP/$FILE")"
if [ "$SIZE" -lt 100000 ] || ! head -1 "$TMP/$FILE" | grep -q '^#!' \
   || ! bash -n "$TMP/$FILE" 2>/dev/null; then
  printf '   %sthat download looks wrong (%s bytes). Nothing was changed.%s\n\n' "$R" "$SIZE" "$O"
  exit 1
fi

NEW="v$(grep -m1 'edition: v' "$TMP/$FILE" | sed 's/.*edition: v//')"
OLD="$(have_ver)"

echo ""
printf '    %sinstalled%s   %s%s%s\n' "$D" "$O" "$W" "$OLD" "$O"
printf '    %savailable%s   %s%s%s   %s(%s bytes)%s\n' "$D" "$O" "$K" "$NEW" "$O" "$D" "$SIZE" "$O"
if [ "$OLD" = "$NEW" ]; then
  printf '    %syou already have this one%s\n' "$D" "$O"
fi
rule
printf '    %s[U]%s %supdate, keep my settings%s\n' "$K" "$O" "$D" "$O"
printf '    %s[W]%s %supdate, wipe my settings%s   %s(keys are kept)%s\n' "$K" "$O" "$D" "$O" "$D" "$O"
printf '    %s[D]%s %supdate and fetch dependencies too%s\n' "$K" "$O" "$D" "$O"
printf '    %s[Q]%s %squit, change nothing%s\n' "$K" "$O" "$D" "$O"
rule
printf '\n   %s>%s ' "$A" "$O"
KEYP="$(getkey)"; echo ""

case "$KEYP" in
  u|U) ARGS="--offline" ;;
  w|W) ARGS="--offline --wipe" ;;
  d|D) ARGS="--online" ;;
  *)   printf '\n   %snothing was changed.%s\n\n' "$D" "$O"; exit 0 ;;
esac

echo ""
bash "$TMP/$FILE" $ARGS
UPDEOF
put_cmd "$BIN/maread-update"

# ---------------------------------------------------------- maread-adb -----
# Opens a privileged shell for the media commands. Menu driven, one keypress,
# no switches to remember.
cat > "$BIN/maread-adb.new" << 'ADBEOF'
#!/usr/bin/env bash
# MA READER, macOS: app switching.
# Nothing to pair and nothing to install. macOS already has Cmd+Tab; it only
# needs permission to press it for you.
A=$'\033[38;5;214m'; G=$'\033[38;5;114m'; R=$'\033[38;5;203m'
D=$'\033[38;5;245m'; K=$'\033[1;38;5;222m'; O=$'\033[0m'
say(){ printf '%s%s%s\n' "$1" "$2" "$O"; }
echo ""
say "$K" "  MA READER, app switching on macOS"
printf '   %s%s%s\n' "$D" "----------------------------------------" "$O"
if osascript -e 'tell application "System Events" to get name' >/dev/null 2>&1; then
  say "$G" "  Ready. The arrows button in the reader presses Cmd+Tab."
else
  say "$A" "  Your terminal needs Accessibility permission."
  say "$D" "  System Settings, Privacy and Security, Accessibility,"
  say "$D" "  then switch on the terminal you run maread from."
  say "$D" "  Opening that pane now."
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility" \
    >/dev/null 2>&1 || true
fi
echo ""
ADBEOF
put_cmd "$BIN/maread-adb"

prog 100 "done"
echo ""
case ":$PATH:" in
  *":$BIN:"*) ;;
  *) printf '\n   %s~/.local/bin is not on your PATH. Add this line to ~/.zshrc:%s\n' "$AMBER" "$OFF"
     printf '   %sexport PATH="$HOME/.local/bin:$PATH"%s\n' "$KEY" "$OFF" ;;
esac
printf '\n   %sinstalled%s   type %smaread%s to run it\n' "$B$GREEN" "$OFF" "$KEY" "$OFF"
printf '   %snext time, one word updates everything:%s %smaread-update%s\n' \
  "$DIM" "$OFF" "$KEY" "$OFF"
printf '   %sto let it start your music again:%s %smaread-adb%s\n' \
  "$DIM" "$OFF" "$KEY" "$OFF"
printf '   %sif the page still looks old, pull down to reload the browser tab%s\n' "$DIM" "$OFF"
echo "  serves on port 8081 upward, the first free one, across your Wi-Fi"
echo ""
echo " Read tab:    paste text, pick a voice, it speaks and highlights each word."
echo " Engines:     Settings opens on two buttons, Edge and Speechify, and the"
echo "              cards below follow whichever you pick."
echo "              Edge      free, no key, English and Croatian."
echo "              Speechify keyed, English only, UK or US, four voices."
echo " Languages:   Edge has a checkbox list of its 13 language groups. Tick the"
echo "              ones you want and they appear at the top of the reader."
echo " Speechify:   load a key file in Settings, one key per line with a name"
echo "              above each. Keys are tried only by being used; a rejected"
echo "              one is marked dead there and never tried again."
echo " Timing:      Edge is measured off the real audio waveform, DaVinci style."
echo "              Speechify brings its own word times and needs no measuring."
echo " Export:      writes one mp3 per sentence + txt + json into MA Reader Audio."
echo " Offline tab: reads one sentence at a time, highlights it, then plays it."
echo " Quick read:  copy text, tap Paste; it replaces the box and starts"
echo "              reading. Tap a sentence to read from it, swipe to step."
echo " Player:      three controls. The two pauses sit together on the LEFT,"
echo "              words then sentences; play is in the middle; speed is on"
echo "              the RIGHT. Tap any number to send it back to rest."
echo " Word pause:  a real pause. The clip stops inside the quiet the voice"
echo "              already leaves between two words, waits, and starts again."
echo "              Nothing is re-recorded, resampled or sped up. 0 to 2 s."
echo " Sentences:   the pause between sentences goes down to minus one second,"
echo "              where the next sentence overlaps the one still finishing."
echo " Swipe:       drag right for the next sentence, left to go back."
echo "              Settings has Reverse swipe if you want it the other way."
echo " Immersive:   double tap the middle of the page to strip the controls"
echo "              away and start reading; double tap again to stop."
echo " Terminal:    q quits, o opens the page again, b goes to background."
echo " Help tab:    explains the folders, created automatically."
echo ""
echo " Exports land in ~/Downloads."
echo " Optional: 'brew install ffmpeg' gives exact clip lengths (a frame parser"
echo " is used otherwise)."
printf '\n   %sTo remove it later, run this same file and press %su%s%s, or %sU%s %sto take\n' \
  "$DIM" "$B$GLOW" "$OFF" "$DIM" "$B$RED" "$OFF" "$DIM"
printf '   the library with it. There is no second script to lose.%s\n\n' "$OFF"
