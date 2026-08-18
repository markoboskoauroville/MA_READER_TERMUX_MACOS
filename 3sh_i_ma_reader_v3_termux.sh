#!/data/data/com.termux/files/usr/bin/bash
###############################################################################
# MA READER TERMUX  (Edge / Speechify)  -  installer for Termux   edition: v3.10
#
# repo: ma-reader-thermux
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
# Optional Google Gemini key (added in Settings from a plain .txt file) can name
# and summarise texts for the archive. Only Gemini errors are ever shown.
#
# Install:  bash 3sh_i_ma_reader_v3_termux.sh        Run:  mareadweb
#           then open  http://localhost:8081  in any browser on the phone.
###############################################################################
set -e

APPDIR="$HOME/.maread-web"
LIBDIR="$HOME/.maread"
BIN="$PREFIX/bin"
CMD="$BIN/mareadweb"

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
  printf '   %sR E A D E R%s  %sv3.10%s\n' "$KEY" "$OFF" "$VIOLET" "$OFF"
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
  command -v termux-wake-unlock >/dev/null 2>&1 && termux-wake-unlock >/dev/null 2>&1 || true

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
PYBIN="$(command -v python 2>/dev/null || command -v python3 2>/dev/null)"
PYRUN="$PYBIN"

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
    dep_row "ffmpeg" "no" "pkg install ffmpeg"
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
dep_pymod() { "$PYBIN" -c "import $1" >/dev/null 2>&1; }
PYBIN="$(command -v python3 || command -v python || echo python)"

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
getkey() {
  if [ -t 0 ]; then
    old="$(stty -g 2>/dev/null)"
    stty raw -echo 2>/dev/null
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
  pkg install -y python ffmpeg curl >/dev/null 2>&1 || true
  "$PYBIN" -m pip install --upgrade flask edge_tts >/dev/null 2>&1 || true
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
KEEP="gemini_key.txt gemini_state.json speechify_api.txt speechify_failed.json speechify_usage.json web_state.json web_state.json.bak browser.txt"

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
  command -v termux-wake-unlock >/dev/null 2>&1 && termux-wake-unlock >/dev/null 2>&1 || true
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
for _c in mareadweb maread-update maread-adb; do
  rm -f "$BIN/$_c.new" 2>/dev/null || true
done
prog 20 "making room"
mkdir -p "$APPDIR/static"
SETUP_LOG="$APPDIR/install.log"; : > "$SETUP_LOG"

# a plain gold M on near black, so the home screen entry is not a blank square
cat > "$APPDIR/static/icon.svg" << 'ICONEOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 192">
  <rect width="192" height="192" rx="42" fill="#080a10"/>
  <text x="96" y="132" font-family="Georgia,serif" font-size="112"
        font-weight="700" fill="#fadf9c" text-anchor="middle">M</text>
</svg>
ICONEOF

if [ "$MODE" = "online" ]; then
  printf '   %sfetching python, ffmpeg, flask and edge-tts%s\n' "$AMBER" "$OFF"
  ( pkg update -y || true ) >>"$SETUP_LOG" 2>&1 || true
  pkg install -y python ffmpeg >>"$SETUP_LOG" 2>&1 || true
  pip install --no-cache-dir --upgrade flask edge-tts >>"$SETUP_LOG" 2>&1 || true
  # numpy only makes the waveform measurement faster; the engine has a pure
  # Python path that produces bit-identical times without it, so a failed
  # build here is harmless.
  pip install --no-cache-dir numpy >>"$SETUP_LOG" 2>&1 || true
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
import os, re, json, time, shutil, threading, asyncio, base64, hashlib
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
GEMINI_KEY_FILE = os.path.join(WEB_DIR, "gemini_key.txt")
GEMINI_STATE_FILE = os.path.join(WEB_DIR, "gemini_state.json")
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

def split_sentences(text):
    spans, start = [], 0
    for m in _SENT_RE.finditer(text):
        spans.append((start, m.start())); start = m.end()
    if start < len(text):
        spans.append((start, len(text)))
    return [(a, b) for a, b in spans if text[a:b].strip()]

def split_units(text, cap=UNIT_CAP):
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    units = []
    for a, b in split_sentences(text):
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

def lib_save(text):
    title = next((ln.strip()[:48] for ln in text.splitlines() if ln.strip()),
                 "Untitled")
    tid = _slug(title)
    d = os.path.join(LIB_DIR, tid)
    os.makedirs(d, exist_ok=True)
    open(os.path.join(d, "text.txt"), "w", encoding="utf-8").write(text)
    meta = {"title": title, "created": int(time.time()),
            "chars": len(text), "units": len(split_units(text))}
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

def unit_paths(tid, vkey, idx):
    ad = os.path.join(LIB_DIR, tid, "audio", vkey)
    os.makedirs(ad, exist_ok=True)
    base = os.path.join(ad, "s%04d" % idx)
    return base + ".mp3", base + ".tok.json"

def text_payload(tid):
    """Everything the front end needs to render and play a text."""
    text = clean_text(lib_text(tid))
    units = split_units(text)
    title = ""
    try:
        title = json.load(open(os.path.join(LIB_DIR, tid, "meta.json"),
                               encoding="utf-8")).get("title", "")[:64]
    except Exception:
        title = (text.strip().splitlines() or ["Untitled"])[0][:64]
    sentences = [text[a:b].strip() for a, b in units]
    return {"id": tid, "title": title, "sentences": sentences,
            "count": len(sentences)}


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
    # v11: listen to the finished clip and pin every word to the real
    # waveform. v23 measures it in two bands and backtracks each onset, so the
    # tag is "pcm2" and older "pcm" clips get re-measured once on first touch.
    engine = "edge2"
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

def synth_file(text, voice, out_mp3):
    """Speak a whole text into ONE mp3 (used by export)."""
    try:
        import edge_tts
    except Exception:
        return "edge-tts not installed"

    async def go():
        com = _communicate(edge_tts, text, voice)
        with open(out_mp3 + ".part", "wb") as f:
            async for ch in com.stream():
                if ch["type"] == "audio":
                    f.write(ch["data"])
    loop = asyncio.new_event_loop()
    try:
        loop.run_until_complete(go())
    except Exception as e:
        try:
            os.remove(out_mp3 + ".part")
        except Exception:
            pass
        return "export failed: %s" % e
    finally:
        loop.close()
    try:
        if not os.path.getsize(out_mp3 + ".part"):
            os.remove(out_mp3 + ".part"); return "no audio produced"
    except Exception:
        return "no audio produced"
    os.replace(out_mp3 + ".part", out_mp3)
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
    payload = {"input": text, "voice_id": voice_id,
               "audio_format": "mp3", "model": SP_MODEL}
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
_DEFAULT_STATE = {"voice": 1, "speed": 1.0, "volume": 100, "gap": 0.0,
                  "wgap": 0.0,
                  "engine": "edge", "spAccent": "uk", "spVkey": "",
                  "spSet": 0, "bgResume": False, "bothEngines": False,
                  "tapPaste": True, "floatPaste": True, "voiceBar": True,
                  "spPicked": None, "fullOnPaste": False, "hideTabs": True, "pane": "app",
                  "mode": "read",
                  "fpX": 0.82, "fpY": 0.72,
                  "loop": False, "autoplay": False, "size": 13, "focus": False,
                  "theme": "night", "font": "sans", "lineheight": 3,
                  "wordhl": True, "wordoffsets": {}, "swipeRev": False,
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
    st["swipeRev"] = bool(st.get("swipeRev"))
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
# an offline library scanner, a Gemini key store, and a cost-aware model
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

# ---------- Gemini key store + cost-aware model router ----------------------
# Cheapest first. -latest aliases follow Google's newest tier so the ladder
# keeps working as models come and go. The router only climbs when a cheaper
# model fails validation, so easy jobs never touch a pricier model.
GEMINI_MODELS = ["gemini-2.5-flash-lite", "gemini-flash-lite-latest",
                 "gemini-flash-latest", "gemini-2.5-flash"]
GEMINI_ENDPOINT = ("https://generativelanguage.googleapis.com/v1beta/"
                   "models/%s:generateContent")

# Public list prices, USD per 1,000,000 tokens (input, output). The -latest
# aliases are priced by the tier they point at today. Every figure is an
# ESTIMATE from token counts, not a real balance; Gemini has no public endpoint
# that reports remaining credit for a developer key.
GEMINI_PRICES = {
    "gemini-2.5-flash-lite": (0.10, 0.40),
    "gemini-flash-lite-latest": (0.25, 1.50),
    "gemini-flash-latest": (0.50, 3.00),
    "gemini-2.5-flash": (0.30, 2.50),
}
def _price_for(model):
    if model in GEMINI_PRICES:
        return GEMINI_PRICES[model]
    if "flash-lite" in (model or ""):
        return GEMINI_PRICES["gemini-flash-lite-latest"]
    if "flash" in (model or ""):
        return GEMINI_PRICES["gemini-flash-latest"]
    return (0.50, 3.00)

def _blank_usage():
    return {"calls": 0, "in": 0, "out": 0, "cost": 0.0, "by_model": {}}

def _gem_add_usage(model, meta):
    """Fold one call's usageMetadata into the running local tally."""
    if not meta:
        return
    pin = int(meta.get("promptTokenCount", 0) or 0)
    pout = int(meta.get("candidatesTokenCount", 0) or 0)
    if not pout:
        pout = max(0, int(meta.get("totalTokenCount", 0) or 0) - pin)
    ci, co = _price_for(model)
    cost = pin / 1e6 * ci + pout / 1e6 * co
    st = _gem_state()
    u = st.get("usage") or _blank_usage()
    u["calls"] = u.get("calls", 0) + 1
    u["in"] = u.get("in", 0) + pin
    u["out"] = u.get("out", 0) + pout
    u["cost"] = round(u.get("cost", 0.0) + cost, 6)
    e = u.setdefault("by_model", {}).setdefault(
        model, {"calls": 0, "in": 0, "out": 0, "cost": 0.0})
    e["calls"] += 1; e["in"] += pin; e["out"] += pout
    e["cost"] = round(e["cost"] + cost, 6)
    _gem_set(usage=u)

def reset_gemini_usage():
    _gem_set(usage=_blank_usage())

def gemini_key():
    try:
        for ln in open(GEMINI_KEY_FILE, encoding="utf-8"):
            ln = ln.strip()
            if ln:
                return ln
    except Exception:
        pass
    return ""

def gemini_have_key():
    return bool(gemini_key())

def _gem_state():
    try:
        return json.load(open(GEMINI_STATE_FILE, encoding="utf-8"))
    except Exception:
        return {"last_error": "", "last_model": ""}

def _gem_set(**kw):
    st = _gem_state(); st.update(kw)
    try:
        os.makedirs(WEB_DIR, exist_ok=True)
        json.dump(st, open(GEMINI_STATE_FILE, "w", encoding="utf-8"))
    except Exception:
        pass
    return st

def save_gemini_key(raw):
    """Store the first non-empty line of whatever the user picked. We never echo
    it back; only the working file keeps it."""
    key = ""
    for ln in (raw or "").splitlines():
        ln = ln.strip()
        if ln:
            key = ln
            break
    key = key.strip().strip('"').strip("'")
    if not key:
        return False, "That file had no key on its first line."
    try:
        os.makedirs(WEB_DIR, exist_ok=True)
        with open(GEMINI_KEY_FILE, "w", encoding="utf-8") as f:
            f.write(key + "\n")
        try:
            os.chmod(GEMINI_KEY_FILE, 0o600)
        except Exception:
            pass
    except Exception as e:
        return False, "Could not save the key: %s" % e
    _gem_set(last_error="")
    return True, ""

def gemini_error_message(status, body):
    """Turn a raw Gemini failure into one plain sentence the user can act on."""
    b = (body or "").lower()
    if status == 400 and ("api_key_invalid" in b or "api key not valid" in b):
        return "Gemini key looks invalid. Pick the right .txt key file again."
    if status == 400:
        return "Gemini rejected the request (400). The key or request was malformed."
    if status in (401, 403) or "permission_denied" in b or "expired" in b:
        return ("Gemini key was refused (expired, revoked, or billing not "
                "enabled for this model).")
    if status == 429 or "resource_exhausted" in b or "quota" in b:
        return "Gemini quota or rate limit hit. Wait a bit or check your plan."
    if status == 404:
        return "Gemini model not found (it may have been retired)."
    if status and status >= 500:
        return "Gemini server error. Try again shortly."
    return "Gemini request failed (%s)." % (status or "network")

# statuses that no other model will fix: stop climbing and surface them.
_GEM_HARD = {400, 401, 403, 429}

def gemini_generate(prompt, validate=None, models=None, temperature=0.0,
                    max_out=2048, extra_parts=None):
    """Call the cheapest model that returns a valid answer. `validate` gets the
    raw text and returns a parsed payload (truthy) on success or None to climb.
    Returns (payload_or_text, model_used, error_message)."""
    key = gemini_key()
    if not key:
        return None, "", "No Gemini key saved yet."
    last_err = "No model produced a usable answer."
    for model in (models or GEMINI_MODELS):
        url = (GEMINI_ENDPOINT % model) + "?key=" + urllib.parse.quote(key)
        parts = [{"text": prompt}] + list(extra_parts or [])
        payload = {
            "contents": [{"parts": parts}],
            "generationConfig": {"temperature": temperature,
                                 "maxOutputTokens": max_out,
                                 "responseMimeType": "application/json"},
        }
        req = urllib.request.Request(
            url, data=json.dumps(payload).encode("utf-8"),
            headers={"Content-Type": "application/json"}, method="POST")
        try:
            with urllib.request.urlopen(req, timeout=45) as r:
                raw = r.read().decode("utf-8", "replace")
            obj = json.loads(raw)
            _gem_add_usage(model, obj.get("usageMetadata"))
            text = ""
            for cand in obj.get("candidates", []):
                for part in cand.get("content", {}).get("parts", []):
                    text += part.get("text", "")
            text = text.strip()
            if validate is None:
                _gem_set(last_error="", last_model=model)
                return text, model, ""
            parsed = validate(text)
            if parsed is not None:
                _gem_set(last_error="", last_model=model)
                return parsed, model, ""
            last_err = "Model %s answered but the result did not check out." % model
            continue                          # climb to a stronger model
        except urllib.error.HTTPError as e:
            body = ""
            try:
                body = e.read().decode("utf-8", "replace")
            except Exception:
                pass
            msg = gemini_error_message(e.code, body)
            if e.code in _GEM_HARD:
                _gem_set(last_error=msg, last_model=model)
                return None, model, msg          # no point climbing
            last_err = msg                       # 404/5xx: try next model
            continue
        except Exception as e:
            last_err = gemini_error_message(0, str(e))
            continue
    _gem_set(last_error=last_err)
    return None, "", last_err

def _extract_json(text):
    """Best-effort: find the first JSON object/array in a model reply."""
    text = (text or "").strip()
    if text.startswith("```"):
        text = re.sub(r"^```[a-zA-Z]*", "", text).strip().rstrip("`").strip()
    try:
        return json.loads(text)
    except Exception:
        pass
    for op, cl in (("{", "}"), ("[", "]")):
        a = text.find(op); b = text.rfind(cl)
        if a >= 0 and b > a:
            try:
                return json.loads(text[a:b+1])
            except Exception:
                pass
    return None

# ---------- Gemini: title + one-line summary (one cheap call) ---------------
def gemini_title_summary(text):
    """Returns {ai_title, summary}. This never replaces the app's own title
    (the first lines of the text); it is an extra label for easy browsing."""
    snippet = text.strip()
    if len(snippet) > 6000:
        snippet = snippet[:6000]
    prompt = (
        "You label reading material. Read the text and return JSON only, exactly "
        '{"ai_title": "...", "summary": "..."} . ai_title is at most 8 words, no '
        "quotes. summary is ONE sentence, at most 24 words, plain and concrete. "
        "Text follows:\n\n" + snippet)

    def val(t):
        o = _extract_json(t)
        if isinstance(o, dict) and o.get("ai_title") and o.get("summary"):
            return {"ai_title": str(o["ai_title"])[:80].strip(),
                    "summary": str(o["summary"])[:200].strip()}
        return None
    obj, model, err = gemini_generate(prompt, validate=val, max_out=256)
    return obj, err

# ---------- one-file karaoke export: mp3 + txt + json trio ------------------
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
    if use_ai_meta and gemini_have_key():
        obj, merr = gemini_title_summary("\n".join(sentences))
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
#             `rish` shell runs anything at shell privilege. Best route: it
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
MK_DISPATCH = {"play": "play", "pause": "pause", "toggle": "play-pause",
               "next": "next", "previous": "previous", "stop": "stop"}
MK_KEYCODE = {"play": "126", "pause": "127", "toggle": "85",
              "next": "87", "previous": "88", "stop": "86"}
_mk_route = None                 # the one that worked, remembered for the session


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


def _mk_routes(action):
    d = MK_DISPATCH.get(action, "play")
    k = MK_KEYCODE.get(action, "126")
    return [
        ("shizuku",  ["rish", "-c", "cmd media_session dispatch %s" % d]),
        ("adb",      ["adb", "shell", "cmd", "media_session", "dispatch", d]),
        ("adb-old",  ["adb", "shell", "media", "dispatch", d]),
        ("shell",    ["cmd", "media_session", "dispatch", d]),
        ("shizuku-key", ["rish", "-c", "input keyevent %s" % k]),
        ("adb-key",  ["adb", "shell", "input", "keyevent", k]),
        ("input",    ["input", "keyevent", k]),
    ]


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


@app.route("/api/mediakey", methods=["POST"])
def api_mediakey():
    """Send one media command to whatever else is playing.

    Half of this was always free: the moment this app speaks, Android hands it
    the audio focus and the other player stops, no fade. This route is the
    other half, starting it again, which needs a privileged shell."""
    global _mk_route
    data = request.get_json(force=True, silent=True) or {}
    action = str(data.get("key", "play"))
    if action not in MK_DISPATCH:
        action = "play"
    routes = _mk_routes(action)

    # the remembered winner first, so the steady state is one process, not seven
    if _mk_route:
        for name, argv in routes:
            if name == _mk_route:
                ok, _ = _mk_try(name, argv)
                if ok:
                    return jsonify({"ok": True, "route": name})
                _mk_route = None           # it stopped working, walk again
                break

    tried = []
    for name, argv in routes:
        ok, why = _mk_try(name, argv)
        tried.append("%s: %s" % (name, "ok" if ok else (why or "refused")))
        if ok:
            _mk_route = name
            return jsonify({"ok": True, "route": name, "tried": tried})
    return jsonify({"ok": False, "tried": tried,
                    "error": "No privileged route. Run maread-adb in Termux to "
                             "set one up, then try again."})


@app.route("/api/mediastatus")
def api_mediastatus():
    """What is available on this phone, without sending anything."""
    out = {"route": _mk_route, "have": {}}
    for exe in ("rish", "adb"):
        out["have"][exe] = bool(shutil.which(exe))
    if out["have"].get("adb"):
        try:
            p = subprocess.run(["adb", "devices"], capture_output=True, timeout=8)
            body = (p.stdout or b"").decode("utf-8", "replace")
            out["adbDevices"] = [l.split()[0] for l in body.splitlines()[1:]
                                 if l.strip() and "device" in l]
        except Exception:
            out["adbDevices"] = []
    return jsonify(out)


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

@app.route("/api/state", methods=["GET", "POST"])
def api_state():
    if request.method == "POST":
        return jsonify(save_state(request.get_json(force=True, silent=True) or {}))
    return jsonify(load_state())

@app.route("/api/prepare", methods=["POST"])
def api_prepare():
    data = request.get_json(force=True, silent=True) or {}
    raw = data.get("text", "")
    text = clean_text(raw)
    if not text.strip():
        return jsonify({"error": "Paste some text first."}), 400
    tid = lib_save(text)
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

# ---------- Gemini key + status ----------
@app.route("/api/gemini/status")
def api_gemini_status():
    st = _gem_state()
    u = st.get("usage") or _blank_usage()
    return jsonify({"configured": gemini_have_key(),
                    "last_error": st.get("last_error", ""),
                    "last_model": st.get("last_model", ""),
                    "models": GEMINI_MODELS,
                    "usage": u,
                    "usage_note": ("Estimated from token counts. Gemini has no "
                                   "public endpoint for remaining credit, so "
                                   "this is a local running total, not a bill.")})

@app.route("/api/gemini/usage/reset", methods=["POST"])
def api_gemini_usage_reset():
    reset_gemini_usage()
    return jsonify({"ok": True})

@app.route("/api/gemini/key", methods=["POST"])
def api_gemini_key():
    raw = ""
    if request.files:
        f = next(iter(request.files.values()))
        raw = f.read().decode("utf-8", "replace")
    else:
        data = request.get_json(force=True, silent=True) or {}
        raw = data.get("key", "")
    ok, err = save_gemini_key(raw)
    if not ok:
        return jsonify({"error": err}), 400
    return jsonify({"configured": True})

@app.route("/api/gemini/forget", methods=["POST"])
def api_gemini_forget():
    try:
        os.remove(GEMINI_KEY_FILE)
    except Exception:
        pass
    _gem_set(last_error="")
    return jsonify({"configured": False})

# ---------- optional: title + one-line summary for an archived text ----------
@app.route("/api/library/<tid>/enrich", methods=["POST"])
def api_library_enrich(tid):
    if not os.path.isdir(os.path.join(LIB_DIR, tid)):
        abort(404)
    if not gemini_have_key():
        return jsonify({"error": "No Gemini key saved yet."}), 400
    obj, err = gemini_title_summary(clean_text(lib_text(tid)))
    if not obj:
        return jsonify({"error": err or "Gemini could not summarise this."}), 400
    mf = os.path.join(LIB_DIR, tid, "meta.json")
    try:
        meta = json.load(open(mf, encoding="utf-8"))
    except Exception:
        meta = {}
    meta["ai_title"] = obj["ai_title"]
    meta["summary"] = obj["summary"]
    try:
        json.dump(meta, open(mf, "w", encoding="utf-8"), ensure_ascii=False)
    except Exception:
        pass
    return jsonify({"title": meta.get("title", ""),
                    "ai_title": meta["ai_title"], "summary": meta["summary"]})

def _bg_wake_lock():
    # when running detached in the background, hold our own wake lock so the
    # server keeps serving after the foreground launcher releases its lock.
    try:
        subprocess.Popen(["termux-wake-lock"],
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
    for cmd in ("termux-open-url", "xdg-open", "open"):
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
  max-width:var(--col); margin:0 auto}
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

/* ---------- v2: tabs, offline reader, help, gemini ---------- */
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
.engtabs{display:flex; gap:8px; margin:2px 0 14px}
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
body.mode-text .doc, body.mode-text #offDoc{color:#fff}
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
body.fullread:not(.hasfloat) > .fsout{display:flex !important}
/* while the text is a paste target, say so with the cursor and kill the
   text selection that a tap would otherwise start */
body.tappaste .doc, body.tappaste #offDoc{cursor:copy;
  -webkit-user-select:none; user-select:none}
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
      <p class="sub">MA Reader <span id="appVer">v3.10 &middot; Edge / Speechify</span></p>
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
        <code>termux-setup-storage</code> once so the app can reach Downloads.</p>

      <h3>Fastest way to read something</h3>
      <p>Copy any text, come back to this page and tap <b>Paste</b>. The
        clipboard replaces whatever was here and starts reading immediately.
        Tap any sentence to read from there, tap the sentence that is playing
        to pause it, and swipe sideways across the text to step a sentence.</p>

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
      <p>Drag sideways across the text to move a sentence. Dragging to the
        right brings the next sentence in from the right, the way a hand turns
        a page, and dragging left goes back. If the opposite feels right to
        you, turn on <b>Reverse swipe</b> in Settings and it swaps.</p>

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

      <h3>Gemini (optional)</h3>
      <p>If you add a Google Gemini API key, the app can name and one line
        summarise your texts so the archive is easy to skim. Word timing does
        not use Gemini at all: it is measured locally from the audio itself.
        To add the key, open Settings and choose a plain <code>.txt</code> file
        that contains only the key on its first line. The key is kept in the
        app folder and never shown again. You are only told if Gemini reports a
        problem, such as an expired key or a used up quota.</p>
      <p>The app always starts with the cheapest Gemini model and only steps up
        to a stronger one when a cheaper answer does not check out, so it spends
        as little as possible. Timing help uses the speech engine's own word
        marks as the truth and asks Gemini only to line the words up to them, it
        never invents times.</p>

      <div style="margin-top:18px" class="keybox">
        <div class="keyhead">Gemini key
          <span class="keystate" id="helpKeyState">not set</span></div>
        <label class="keybtn">Choose .txt key file
          <input type="file" id="helpKeyFile" accept=".txt,text/plain" hidden></label>
        <button class="keybtn ghost" id="helpKeyForget">Forget key</button>
        <div class="keyerr" id="helpKeyErr"></div>
      </div>
    </div>
  </section>
</main>

<!-- reading settings sheet -->
<div class="backdrop" id="backdrop"></div>
<div class="sheet" id="sheet">
  <div class="sheet-head">
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

    <div class="accrow" id="spAccents"></div>

    <div class="setbar">
      <button class="setarrow" id="spPrev" title="Previous four">&#8592;</button>
      <span class="setcount" id="spCount"></span>
      <button class="setarrow" id="spNext" title="Next four">&#8594;</button>
    </div>
    <div class="spgrid" id="spVoiceGrid"></div>
    <div class="setlegend">
      <span><i style="border-color:var(--femme)"></i>female</span>
      <span><i style="border-color:var(--homme)"></i>male</span>
    </div>
    <div class="setnums" id="spNums"></div>

    <div class="wsub">Keys</div>
    <div class="keybox">
      <div class="keyhead">Key ring
        <span class="keystate" id="spKeyState">not set</span></div>
      <label class="keybtn">Choose .txt key file
        <input type="file" id="spKeyFile" accept=".txt,text/plain" hidden></label>
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
      <button class="chip" id="swipeTog">Reverse swipe</button>
      <button class="chip" id="floatTog">Floating paste button</button>
      <button class="chip" id="tapPasteTog">Tap text to paste</button>
      <button class="chip" id="bgResumeTog">Resume my music</button>
      <button class="chip" id="bgTestBtn">Test it</button>
    </div>
    <div class="langhint"><b>Floating paste button.</b> Drag it anywhere. Press: paste, full screen, read. In full screen it is the way out.</div>
    <div class="langhint"><b>Resume my music.</b> Asks your player to start again when you pause. Needs maread-adb.</div>
    <div class="langhint">Swap the direction a swipe moves.</div>
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

  <div class="group g-adv" data-eng="app">
    <h3>Advanced</h3>
    <div class="chips">
      <button class="chip" id="chromeTog">Open in Chrome</button>
    </div>
    <div class="langhint">Ask for Chrome by name instead of the phone default.</div>
    <div class="wsub">Gemini key (optional)</div>
    <div class="keybox">
      <div class="keyhead">API key
        <span class="keystate" id="keyState">not set</span></div>
      <label class="keybtn">Choose .txt key file
        <input type="file" id="keyFile" accept=".txt,text/plain" hidden></label>
      <button class="keybtn ghost" id="keyForget">Forget</button>
      <div class="keyerr" id="keyErr"></div>
    </div>
    <div class="wsub">Word timing</div>
    <div class="timing-help">Timing is measured from the audio itself: after a
      sentence is spoken, the app listens to the finished clip, finds where
      speech really starts, ends, and rises after each pause, and pins every
      word to that waveform. It is automatic, free, and works offline. If the
      red word still feels early or late on a particular voice, nudge it with
      the Sync slider in the player settings.</div>
    <div class="chips" style="margin-top:12px">
      <button class="chip" id="aiMetaTog">AI title &amp; summary</button>
    </div>
    <div class="gem-usage" id="gemUsage">No Gemini usage yet.</div>
    <button class="gem-reset" id="gemReset">Reset usage counter</button>
    <small class="sheet-note">Used only when you export or summarise. The key
      stays in the app folder and only errors are shown.</small>
  </div>
</div>

<button class="floatp" id="floatP" title="Paste and read. Drag to move.">P</button>

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
  voices: [], voice: 1, vkey: "ukF",
  langs: [], enabledLangs: ["en","hr"],
  /* v3: two engines. Edge is the free Microsoft one this app started on;
     Speechify is keyed, English only, and brings its own word timings. */
  engine: "edge", spAccent: "uk", spVkey: "", spVoices: [], spInfo: {},
  spSet: 0, spPerSet: 4, bothEngines: false, tapPaste: true,
  floatPaste: true, fpX: 0.82, fpY: 0.72, browser: "chrome",
  /* null means never chosen, so the first four can be offered. An empty
     ARRAY means chosen to be none, and must be left alone. Treating those
     two as the same value is what made unticked voices come back on every
     restart: the seed could not tell a decision from a blank. */
  /* Baba's own starting point, so a fresh install is not a chore. */
  voiceBar: true, spPicked: null, fullOnPaste: false, hideTabs: true,
  pane: "app",
  mode: "read",
  tid: "", title: "", sentences: [],
  idx: 0, playing: false,
  speed: 1.0, volume: 100, gap: 0.0, wgap: 0.0, loop: false,
  size: 4, autoplay: false, focus: false,
  theme: "night", font: "serif", lineheight: 3, wordhl: true,
  rgbSent: [255,217,59], rgbWord: [226,59,78], rgbFont: [255,255,255],
  rgbText: null,
  wordoffsets: {}, aimeta:false, resume:true, swipeRev:false,
  gemini:{configured:false,last_error:""},
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
function audioUrl(i){ return `/api/audio/${ST.tid}/${ST.vkey}/${i}.mp3`; }
function boundsUrl(i){ return `/api/bounds/${ST.tid}/${ST.vkey}/${i}`; }
function clampIdx(i){ return Math.max(0, Math.min(i, ST.sentences.length-1)); }
function active(){ return players[cur]; }

/* ---------- voices ----------
   Two engines, one strip. Edge fills it from whichever languages are ticked
   in Settings and scrolls if there are many; Speechify fills it with exactly
   four, two female and two male, because that is all the room there is. */
function enabledSet(){ return new Set(ST.enabledLangs||[]); }
function edgeVoices(){
  const on = enabledSet();
  return ST.voices.filter(v => on.has(v.lang));
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
function topSp(){ return spPickedVoices(); }
function shownVoices(){
  return ST.engine === "speechify" ? topSp() : topEdge();
}
/* the whole list, for looking a voice up by id even when it is not on screen */
function spAll(){ return ST.spVoices || []; }
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
  b.className = "voice " + sexClass(v) + (v.id===ST.voice ? " on":"");
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
  if(shown.length && !shown.some(v=>v.id===ST.voice)){
    setVoice(shown[0].id);
  } else {
    renderVoices();
  }
  renderLangList();
  persist();
}
function setVoice(id){
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
  const pane = ST.pane || ST.engine || "edge";
  document.querySelectorAll("#engTabs .engtab").forEach(b=>
    b.classList.toggle("on", b.dataset.pane === pane));
  document.querySelectorAll("#sheet .group[data-eng]").forEach(g=>{
    g.style.display = (g.dataset.eng === pane) ? "" : "none";
  });
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
function renderSpAccents(){
  const wrap = $("#spAccents"); if(!wrap) return;
  wrap.innerHTML = "";
  ((ST.spInfo && ST.spInfo.accents) || []).forEach(a=>{
    const b = document.createElement("button");
    b.className = "accbtn" + (a.key === ST.spAccent ? " on" : "");
    b.textContent = a.label;
    b.onclick = ()=> setSpAccent(a.key);
    wrap.appendChild(b);
  });
}
function renderSpGrid(){
  const wrap = $("#spVoiceGrid"); if(!wrap) return;
  wrap.innerHTML = "";
  const list = spWindow();
  if(!list.length){
    const d = document.createElement("div");
    d.className = "spstate";
    d.textContent = "No voices yet. Load a key file below.";
    wrap.appendChild(d);
    renderSpPager(); return;
  }
  list.forEach(v=>{
    const row = document.createElement("div");
    row.className = "spcell " + sexClass(v) + (v.id === ST.voice ? " on" : "");

    const box = document.createElement("button");
    box.className = "spbox" + (isPicked(v.vkey) ? " ticked" : "");
    box.innerHTML = isPicked(v.vkey) ? "&#10003;" : "";
    box.title = "Show this voice at the top";
    box.onclick = (e)=>{
      e.stopPropagation();
      togglePick(v.vkey);
      renderSpGrid(); renderVoices(); persist();
    };
    row.appendChild(box);

    const nm = document.createElement("button");
    nm.className = "spname";
    nm.innerHTML = `<b>${v.name}</b><small>${voiceSub(v)}</small>`;
    nm.onclick = ()=>{ if(ST.engine !== "speechify") setEngine("speechify", true);
                       setVoice(v.id); renderSpGrid(); previewVoice(v); };
    row.appendChild(nm);
    wrap.appendChild(row);
  });
  renderSpPager();
}

/* Paging. Two arrows and a count, then a row of numbers so any page is one
   tap away rather than forty. With 84 American voices that is 21 pages, and
   walking to page 19 with an arrow would be absurd. */
function renderSpPager(){
  const cnt = $("#spCount"), prev = $("#spPrev"), next = $("#spNext"),
        nums = $("#spNums");
  const total = spSets(), cur = spClampSet(), have = spAll().length;
  if(cnt){
    cnt.innerHTML = have
      ? `<b>${cur + 1} / ${total}</b> &middot; ${have} voices`
      : "";
  }
  if(prev) prev.disabled = (cur <= 0);
  if(next) next.disabled = (cur >= total - 1);
  if(nums){
    nums.innerHTML = "";
    if(have){
      for(let i = 0; i < total; i++){
        const b = document.createElement("button");
        b.className = "setnum" + (i === cur ? " on" : "");
        b.textContent = String(i + 1);
        b.onclick = ()=> spGoSet(i);
        nums.appendChild(b);
      }
    }
  }
}
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

/* ---------- rendering the document ---------- */
function renderDoc(){
  const doc = $("#doc"); doc.innerHTML = ""; wordCache.clear();
  ST.sentences.forEach((s,i)=>{
    const span = document.createElement("span");
    span.className = "sent"; span.dataset.i = i;
    span.textContent = s + " ";
    /* Clicking a sentence reads from that sentence. Clicking the one already
       playing pauses and resumes it, so the old tap-to-pause gesture still
       works where the eye already is. A drag is a sentence step, not a click,
       so it is filtered out first. */
    span.onclick = ()=>{
      if(swipedJustNow()) return;
      if(ST.tapPaste) return;        /* the text is a paste target now */
      if(i === ST.idx) togglePlay(); else jumpTo(i, true);
    };
    doc.appendChild(span);
  });
  // start synthesising the opening sentences straight away
  prefetch(0); prefetch(1); prefetch(2);
}
function sentEl(i){ return $(`#doc .sent[data-i="${i}"]`); }

/* ---------- swipe between sentences ----------
   Touch events work fine in the browser, so a horizontal drag across the text
   moves a sentence: left for the next, right for the previous. A swipe must be
   clearly sideways (and not a scroll) before it counts, and it suppresses the
   tap that would otherwise pause. */
let swTouch = null, swMouse = null, swipeStamp = 0;
function swipedJustNow(){ return (Date.now() - swipeStamp) < 400; }
function bindSwipe(el, onPrev, onNext){
  if(!el) return;
  el.addEventListener("touchstart", e=>{
    if(e.touches.length !== 1){ swTouch = null; return; }
    const t = e.touches[0];
    swTouch = {x:t.clientX, y:t.clientY, t:Date.now()};
  }, {passive:true});
  el.addEventListener("touchend", e=>{
    if(!swTouch) return;
    const t = e.changedTouches[0];
    const dx = t.clientX - swTouch.x, dy = t.clientY - swTouch.y;
    const dt = Date.now() - swTouch.t;
    swTouch = null;
    // sideways, far enough, and not a slow scroll
    if(Math.abs(dx) < 55 || Math.abs(dx) < Math.abs(dy)*1.6 || dt > 800) return;
    swipeStamp = Date.now();
    swipeGo(dx, onPrev, onNext);
  }, {passive:true});
  /* Same gesture with a mouse. Without this there is no way to reach the
     previous sentence on a desktop except the keyboard, because a trackpad
     two-finger swipe arrives as a wheel event, not a touch. */
  el.addEventListener("mousedown", e=>{
    if(e.button !== 0){ swMouse = null; return; }
    swMouse = {x:e.clientX, y:e.clientY, t:Date.now()};
  });
  el.addEventListener("mouseup", e=>{
    if(!swMouse) return;
    const dx = e.clientX - swMouse.x, dy = e.clientY - swMouse.y;
    const dt = Date.now() - swMouse.t;
    swMouse = null;
    if(Math.abs(dx) < 55 || Math.abs(dx) < Math.abs(dy)*1.6 || dt > 800) return;
    swipeStamp = Date.now();
    swipeGo(dx, onPrev, onNext);
  });
}
/* Which way is forward. Dragging RIGHT now brings the next sentence in from
   the right, the way a hand turns a page; dragging left goes back. That is
   the opposite of every version up to v24, so the old direction is still
   there as Reverse swipe in Settings. */
function swipeGo(dx, onPrev, onNext){
  const forward = ST.swipeRev ? (dx < 0) : (dx > 0);
  if(forward) onNext(); else onPrev();
}

function ensureWordSpans(i){
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
}
function clearWords(i){
  CLK.lastWord = -2;
  const sp = wordCache.get(i); if(sp) sp.forEach(o=>o.el.classList.remove("now"));
}

/* ---------- highlight ---------- */
function highlight(i, paused){
  CLK.lastWord = -2;
  document.querySelectorAll("#doc .sent.active, #doc .sent.paused")
    .forEach(e=>e.classList.remove("active","paused"));
  const el = sentEl(i); if(!el) return;
  el.classList.add(paused ? "paused" : "active");
  const sc = $("#readerScroll");
  const r = el.getBoundingClientRect(), pr = sc.getBoundingClientRect();
  if(r.top < pr.top+40 || r.bottom > pr.bottom-90){
    el.scrollIntoView({block:"center", behavior:"smooth"});
  }
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
function onEnded(i, seq){
  if(!ST.playing) return;
  if(seq !== playSeq) return;   /* an overlapped predecessor finishing: ignore */
  if(handedOff) return;         /* follow() already crossed over */
  const ni = i + 1;
  if(ni >= ST.sentences.length){
    if(ST.loop){ startAt(0); return; }
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
  cancelGap(); ST.playing = false; setPlayIcon(false);
  players.forEach(p=>{ try{ p.pause(); p.currentTime=0; }catch(e){} });
  highlight(ST.idx, true); clearWords(ST.idx);
  $("#barFill").style.width = (ST.idx/Math.max(1,ST.sentences.length))*100 + "%";
  setStatus("Stopped.");
}
function jumpTo(i, play){
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
let _bgWas = null, _bgDead = false;

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
  if(!on && !first && ST.bgResume && !_bgDead) mediaKey("play");
}

function mediaKey(k, quiet){
  return api("/api/mediakey", {method:"POST",
      headers:{"Content-Type":"application/json"},
      body: JSON.stringify({key: k || "play"})})
    .then(r=>r.json()).then(d=>{
      if(!d.ok){
        /* Ask once. If Android refuses, it will refuse every time, and a
           toast on every pause would be its own kind of torture. */
        _bgDead = true;
        if(ST.bgResume){ ST.bgResume = false; refreshToggles(); persist(); }
        if(!quiet) toast("Android refused the media key. Turned off.");
      } else if(!quiet){
        toast("Sent.");
      }
      return d;
    }).catch(()=>({ok:false, error:"could not reach the server"}));
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
  { const b=$("#tapPasteTog"); if(b) b.classList.toggle("on", !!ST.tapPaste); }
  { const b=$("#floatTog"); if(b) b.classList.toggle("on", !!ST.floatPaste); }
  { const b=$("#chromeTog"); if(b) b.classList.toggle("on", ST.browser !== "auto"); }
  { const b=$("#voiceBarTog"); if(b) b.classList.toggle("on", !!ST.voiceBar); }
  document.body.classList.toggle("nobar", !ST.voiceBar);
  document.body.classList.toggle("tappaste", !!ST.tapPaste);
  document.body.classList.toggle("hasfloat", !!ST.floatPaste);
  { const b=$("#bgResumeTog"); if(b) b.classList.toggle("on", !!ST.bgResume); }
  $("#autoplayTog").classList.toggle("on", ST.autoplay);
  { const r=$("#resumeTog"); if(r) r.classList.toggle("on", ST.resume); }
  $("#focusTog").classList.toggle("on", ST.focus);
  $("#readerView").classList.toggle("focus", ST.focus);
  $("#loopBtn").classList.toggle("on", ST.loop);
  { const sw=$("#swipeTog"); if(sw) sw.classList.toggle("on", ST.swipeRev); }
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
  document.body.classList.remove("inreader","onhome"); setTab("help"); refreshGemini(); }
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
function openPayload(p, autoplay){
  stopOnline(); stopOffline();
  ST.tid = p.id; ST.title = p.title || "Untitled";
  ST.sentences = p.sentences || []; ST.idx = 0;
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
       body: JSON.stringify({text})})
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
    if(ST.gemini && ST.gemini.configured){
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
  toast("Asking Gemini for a title and summary...");
  api("/api/library/"+tid+"/enrich",{method:"POST"})
    .then(r=>r.json().then(j=>({ok:r.ok,j})))
    .then(({ok,j})=>{
      if(!ok){ toast(j.error||"Gemini could not summarise this."); refreshGemini(); return; }
      const m = LIB_CACHE.find(x=>x.id===tid);
      if(m){ m.title=j.title||m.title; m.summary=j.summary||""; }
      renderLibrary(); toast("Updated.");
    }).catch(()=>toast("Gemini request failed."));
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
      if(!ok){ toast(j.error||"Export failed."); refreshGemini(); return; }
      if(j.already){ toast("Already exported in "+(j.voice||vn)+"."); return; }
      toast("Saved to MA Reader Audio"+(j.timing_source==="pcm"?" (waveform timing)":""));
      refreshGemini();
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
        gap:ST.gap, wgap:ST.wgap, loop:ST.loop, size:ST.size, autoplay:ST.autoplay,
        focus:ST.focus, theme:ST.theme, font:ST.font,
        lineheight:ST.lineheight, wordhl:ST.wordhl,
        rgbSent:ST.rgbSent, rgbWord:ST.rgbWord, rgbFont:ST.rgbFont, rgbText:ST.rgbText,
        wordoffsets:ST.wordoffsets, aimeta:ST.aimeta,
        resume:ST.resume, swipeRev:ST.swipeRev,
        engine:ST.engine, spAccent:ST.spAccent, spVkey:ST.spVkey||"",
        spSet:ST.spSet||0, bgResume:!!ST.bgResume,
        bothEngines:!!ST.bothEngines, tapPaste:!!ST.tapPaste,
        spPicked:(Array.isArray(ST.spPicked) ? ST.spPicked : null),
        fullOnPaste:!!ST.fullOnPaste,
        hideTabs:!!ST.hideTabs, mode:ST.mode||"read", pane:ST.pane||"app",
        voiceBar:!!ST.voiceBar,
        floatPaste:!!ST.floatPaste, fpX:ST.fpX, fpY:ST.fpY,
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
  bindSwipe($("#doc"), prev, next);
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
  { const b=$("#tapPasteTog");
    if(b) b.onclick = ()=>{
      ST.tapPaste = !ST.tapPaste;
      refreshToggles(); persist();
      toast(ST.tapPaste ? "Tap the text to paste the next one"
                        : "Tap a sentence to read from it");
    };
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
  { const b=$("#bgResumeTog");
    if(b) b.onclick = ()=>{
      ST.bgResume = !ST.bgResume;
      if(ST.bgResume) _bgDead = false;      /* a fresh chance after a refusal */
      refreshToggles(); persist();
      toast(ST.bgResume ? "Your music will be asked to resume" : "Left alone");
    };
  }
  { const b=$("#bgTestBtn");
    if(b) b.onclick = ()=>{
      toast("Asking Android\u2026");
      mediaKey("play", true).then(d=>{
        if(d.ok) toast("Working, via " + (d.route || "a shell") + ".");
        else toast("No route yet. Run maread-adb in Termux.");
      });
    };
  }
  $("#autoplayTog").onclick = ()=>{ ST.autoplay=!ST.autoplay; refreshToggles(); persist(); };
  { const sw=$("#swipeTog"); if(sw) sw.onclick = ()=>{ ST.swipeRev=!ST.swipeRev;
      refreshToggles(); persist();
      toast(ST.swipeRev ? "Swipe left for the next sentence"
                        : "Swipe right for the next sentence"); }; }
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
  ["#doc", "#offDoc"].forEach(sel => {
    const el = $(sel); if(!el) return;
    try{
      el.contentEditable = on ? "true" : "false";
      el.spellcheck = false;
    }catch(e){}
  });
}
/* Leaving EDIT keeps what was typed: the text is read back out of the page,
   saved as a new text, and re-split into sentences so it can be spoken. */
function commitEdit(){
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
    if(swipedJustNow()) return;
    /* One finger, straight to the next article. A tap on the text asks for
       the clipboard, Android offers its Paste button, and what comes back
       replaces everything and starts speaking. Nothing else may claim a tap
       while this is on, or the gesture would mean three things at once. */
    if(ST.tapPaste){
      e.stopPropagation(); e.preventDefault();
      /* same rule as the floating P, so the two never disagree */
      if(ST.fullOnPaste && !document.body.classList.contains("fullread")){
        reqFull(); setFullread(true);
      }
      pasteFromClipboard();
      return;
    }
    const full = isFullread();
    const inZ  = inCenterZone(e.clientX, e.clientY);
    if(!full && !inZ) return;       /* ordinary tap: let the sentence handle it */
    e.stopPropagation(); e.preventDefault();
    if(tapT){                       /* second tap inside the window */
      clearTimeout(tapT); tapT=null;
      if(inZ){ toggleImmersive(isOffline); return; }
    }
    const sent = (e.target && e.target.closest) ? e.target.closest(".sent") : null;
    const si = sent ? parseInt(sent.dataset.i, 10) : -1;
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
  setStatus("Preparing...");
  api("/api/prepare", {method:"POST", headers:{"Content-Type":"application/json"},
       body: JSON.stringify({text})})
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
  const full = document.body.classList.contains("fullread");
  el.innerHTML = full ? FS_GLYPH : "P";
  el.title = full ? "Leave full screen and pause"
                  : "Paste, read, and go full screen. Drag to move.";
}
function floatPress(){
  if(document.body.classList.contains("fullread")){ leaveFull(); return; }
  /* The app always opens normal. Full screen is a consequence of PASTING, not
     of launching, and only when asked for: reading a fresh article is the
     moment the furniture stops helping, and it is a moment he chose.

     When it is wanted, ask HERE, inside the gesture, before anything async.
     Requested after the clipboard resolves it would be refused, because the
     user activation is spent by then. */
  if(ST.fullOnPaste){
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
  window.addEventListener("resize", placeFloat);
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
      body:JSON.stringify({text})})
    .then(r=>r.json())
    .then(p=> api("/api/export",{method:"POST",
        headers:{"Content-Type":"application/json"},
        body:JSON.stringify({tid:p.id, vkey:ST.vkey, meta:!!ST.aimeta})})
        .then(r=>r.json().then(j=>({ok:r.ok,j}))))
    .then(({ok,j})=>{
      btn.disabled=false; btn.textContent=old;
      if(!ok){ toast(j.error||"Could not build offline files."); refreshGemini(); return; }
      $("#pasteBox").value=""; if(typeof updatePasteHint==="function") updatePasteHint();
      if(j.already){ toast("Already in Offline ("+(j.voice||vn)+")."); }
      else { toast("Saved to Offline"+(j.timing_source==="pcm"?" (waveform timing)":"")); }
      refreshGemini(); showOfflineList();
    }).catch(()=>{ btn.disabled=false; btn.textContent=old;
      toast("Could not build offline files."); });
}

function saveOffPos(){
  if(!OFF.name) return;
  const pos=OFF.idx||0;              /* resume by sentence, not by seconds */
  api("/api/offline/pos",{method:"POST",headers:{"Content-Type":"application/json"},
     body:JSON.stringify({name:OFF.name, pos})}).catch(()=>{});
}

function paintUsage(){
  const box=$("#gemUsage"); if(!box) return;
  const g=ST.gemini||{}; const u=g.usage||{};
  if(!g.configured && !(u.calls>0)){ box.textContent="Add a key to use Gemini. No usage yet."; return; }
  const cost=(u.cost||0), calls=(u.calls||0), inp=(u.in||0), out=(u.out||0);
  let html="<b>Estimated spend:</b> $"+cost.toFixed(4)+" &middot; "+calls+" calls<br>"+
    "tokens in "+inp.toLocaleString()+" &middot; out "+out.toLocaleString();
  if(g.usage_note) html+="<div class='note'>"+g.usage_note+"</div>";
  box.innerHTML=html;
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
  const sc=$("#offReaderScroll");
  const r=el.getBoundingClientRect(), pr=sc.getBoundingClientRect();
  if(r.top<pr.top+40 || r.bottom>pr.bottom-90)
    el.scrollIntoView({block:"center", behavior:"smooth"});
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
  OFF.playing=false; offSetPlayIcon(false);
  offHighlightSentence(OFF.idx,true); offSetSeek();
  if(ST.resume) saveOffPos(); setOffStatus("Finished.");
}
function offPlay(){
  if(!OFF.man) return;
  stopOnline();
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

/* ---------- gemini status + key upload ---------- */
function refreshGemini(){
  return api("/api/gemini/status").then(r=>r.json()).then(g=>{
    ST.gemini=g; paintGemini(); return g;
  }).catch(()=>{});
}
function paintGemini(){
  const g=ST.gemini||{configured:false,last_error:""};
  [["#keyState","#keyErr"],["#helpKeyState","#helpKeyErr"]].forEach(([sSel,eSel])=>{
    const s=$(sSel), e=$(eSel);
    if(s){ s.textContent = g.configured? "saved":"not set";
      s.classList.toggle("ok", !!g.configured); }
    if(e){ e.textContent = g.last_error||""; }
  });
  const mt=$("#aiMetaTog");
  if(mt) mt.classList.toggle("on", !!ST.aimeta);
  paintUsage();
}
function uploadKey(file){
  if(!file) return;
  const fd=new FormData(); fd.append("key", file, file.name||"key.txt");
  api("/api/gemini/key",{method:"POST", body:fd})
    .then(r=>r.json().then(j=>({ok:r.ok,j})))
    .then(({ok,j})=>{
      if(!ok){ toast(j.error||"Could not save the key."); }
      else toast("Gemini key saved.");
      refreshGemini().then(()=>{ if(!$("#homeView").classList.contains("hidden")) renderLibrary(); });
    }).catch(()=>toast("Could not save the key."));
}
function forgetKey(){
  api("/api/gemini/forget",{method:"POST"}).then(()=>{ toast("Key forgotten.");
    refreshGemini().then(()=>{ if(!$("#homeView").classList.contains("hidden")) renderLibrary(); }); });
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
  const gr=$("#gemReset"); if(gr) gr.onclick=()=>{
    api("/api/gemini/usage/reset",{method:"POST"}).then(()=>{ toast("Usage counter reset."); refreshGemini(); }); };
  $("#offSeek").addEventListener("input", e=>{
    const n=Math.max(1, OFF.sents.length-1);
    const i=clampOff(Math.round((e.target.value/1000)*n));
    if(i!==OFF.idx) offJump(i, OFF.playing);
  });

  const kf=$("#keyFile"); if(kf) kf.addEventListener("change",
    e=>{ uploadKey(e.target.files[0]); e.target.value=""; });
  const hkf=$("#helpKeyFile"); if(hkf) hkf.addEventListener("change",
    e=>{ uploadKey(e.target.files[0]); e.target.value=""; });
  const kfo=$("#keyForget"); if(kfo) kfo.onclick=forgetKey;
  const hkfo=$("#helpKeyForget"); if(hkfo) hkfo.onclick=forgetKey;
  const mt=$("#aiMetaTog"); if(mt) mt.onclick=()=>{ ST.aimeta=!ST.aimeta;
    paintGemini(); persist(); };
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
    ST.bgResume = !!st.bgResume;
    ST.bothEngines = !!st.bothEngines;
    ST.spPicked = Array.isArray(st.spPicked) ? st.spPicked.slice() : null;
    ST.fullOnPaste = (st.fullOnPaste === undefined) ? true : !!st.fullOnPaste;
    ST.hideTabs = !!st.hideTabs;
    ST.pane = (st.pane === "edge" || st.pane === "speechify") ? st.pane : "app";
    /* EDIT is never restored: coming back into a text editor you did not ask
       for is a surprise, and an unsaved edit from a previous session is not
       something to pretend to remember. */
    ST.mode = (st.mode === "text") ? "text" : "read";
    ST.voiceBar = (st.voiceBar === undefined) ? true : !!st.voiceBar;
    ST.tapPaste = (st.tapPaste === undefined) ? true : !!st.tapPaste;
    ST.floatPaste = (st.floatPaste === undefined) ? true : !!st.floatPaste;
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
    renderEdgeGrid(); renderSpKeyList(); renderSpDead();
    mediaSetup(); wireFloat(); wireFsWatch(); wirePersistFlush();
    renderVoices(); renderLangList();
    applySpeed(); applyVolume(); applyGap(); applyWgap(); applySize();
    applyFont(); applySpacing(); applyTheme(); applyWordHl(); applyHiColors(); applySync();
    ST.aimeta = !!st.aimeta; ST.resume = (st.resume!==false);
    ST.swipeRev = !!st.swipeRev;
    ST.gemini = {configured:false, last_error:""};
    /* Everything is restored. From here it is safe to write. */
    booted = true;
    bindV2(); refreshToggles(); setMode(ST.mode); showHome();
    /* Deliberately nothing about full screen here. The app always opens in
       the normal view, whatever the setting says. Full screen belongs to the
       act of pasting, which is a gesture, which is also the only thing the
       browser will accept a full screen request from. Doing it at load would
       have been both unwanted and, in a tab, impossible. */
    refreshGemini();
  }).catch(()=>{ setStatus("Could not reach the server."); });
}
boot();
</script>
</body>
</html>
HTMLEOF
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

cat > "$BIN/mareadweb.new" << 'LAUNCHEOF'
#!/data/data/com.termux/files/usr/bin/bash
# MA Reader Web (Fire | the Word). Serves on 0.0.0.0 so any device on your
# Wi-Fi can open it. Ctrl-C stops it.
APPDIR="$HOME/.maread-web"
PORT="${MAREAD_WEB_PORT:-8081}"
HOST="${MAREAD_WEB_HOST:-0.0.0.0}"
PORTFILE="$APPDIR/port.txt"
termux-wake-lock 2>/dev/null || true

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

# Every Chrome that exists, in the order worth trying. -p filters by package
# rather than naming an activity, because the activity name has changed
# between Chrome versions and the package name never has.
CHROME_PKGS="com.android.chrome com.chrome.beta com.chrome.dev com.chrome.canary"

open_chrome(){
  command -v am >/dev/null 2>&1 || return 1
  for PKG in $CHROME_PKGS; do
    OUT="$(am start -a android.intent.action.VIEW -d "$1" -p "$PKG" 2>&1)" || continue
    # am prints its failures and still exits zero, so read what it said
    case "$OUT" in
      *Error*|*error*|*Exception*|*"not found"*|*"does not exist"*) continue ;;
    esac
    return 0
  done
  return 1
}

open_default(){ termux-open-url "$1" >/dev/null 2>&1 || return 1; return 0; }

open_url(){   # $1 url, $2 chrome|auto
  if [ "$2" = "chrome" ]; then
    open_chrome "$1" && return 0
    printf '   %sChrome not found, using the phone default%s\n' "$DIMC" "$OFFC"
  fi
  open_default "$1"
}


lan_ip(){
  ip route get 1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}' \
    || true
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

MAREAD_WEB_HOST="$HOST" MAREAD_WEB_PORT="$PORT" python "$APPDIR/server.py" &
SRV=$!
cleanup(){ kill "$SRV" 2>/dev/null; termux-wake-unlock 2>/dev/null; }
trap 'cleanup; exit 0' INT TERM

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
  termux-wake-unlock 2>/dev/null || true
fi
exit $ST
LAUNCHEOF
put_cmd "$BIN/mareadweb"

# ------------------------------------------------------------ put keys back --
if [ -n "$STASH" ] && [ -d "$STASH" ]; then
  BACK=0
  for f in $KEEP; do
    if [ -f "$STASH/$f" ]; then
      cp -p "$STASH/$f" "$APPDIR/$f" 2>/dev/null && BACK=$((BACK+1))
    fi
  done
  chmod 600 "$APPDIR/speechify_api.txt" 2>/dev/null || true
  chmod 600 "$APPDIR/gemini_key.txt" 2>/dev/null || true
  rm -rf "$STASH"
  [ "$BACK" -gt 0 ] && printf '   %s%s file(s) put back: you do not have to enter a key again%s\n' \
    "$GREEN" "$BACK" "$OFF"
fi

# leave behind the one word update command, so this is the last time anyone
# has to remember a URL
cat > "$BIN/maread-update.new" << 'UPDEOF'
#!/data/data/com.termux/files/usr/bin/bash
# Update MA Reader. Nothing is installed until it is asked for.
A=$'\033[38;5;214m'; G=$'\033[38;5;114m'; R=$'\033[38;5;203m'
D=$'\033[38;5;245m'; K=$'\033[1;38;5;222m'; W=$'\033[38;5;252m'; O=$'\033[0m'
RAW="https://raw.githubusercontent.com/markoboskoauroville/ma-reader-thermux/main"
FILE="3sh_i_ma_reader_v3_termux.sh"
APPDIR="$HOME/.maread-web"

rule(){ printf '   %s%s%s\n' "$D" "------------------------------------------" "$O"; }

getkey() {
  if [ -t 0 ]; then
    old="$(stty -g 2>/dev/null)"; stty raw -echo 2>/dev/null
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
#!/data/data/com.termux/files/usr/bin/bash
# Give MA Reader a way to press play on your music again.
A='\033[38;5;214m'; G='\033[38;5;114m'; R='\033[38;5;203m'; D='\033[38;5;245m'; O='\033[0m'
say(){ printf "$1%s$O\n" "$2"; }

test_media(){
  if command -v rish >/dev/null 2>&1 && \
     rish -c 'cmd media_session dispatch play' >/dev/null 2>&1; then
    say "$G" "  Shizuku works. Nothing else to do."; return 0; fi
  if command -v adb >/dev/null 2>&1 && \
     adb shell cmd media_session dispatch play >/dev/null 2>&1; then
    say "$G" "  ADB works. Nothing else to do."; return 0; fi
  return 1
}

do_connect(){
  command -v adb >/dev/null 2>&1 || { say "$A" "  installing android-tools"; pkg install -y android-tools >/dev/null 2>&1; }
  say "$A" "  looking for Wireless debugging on this phone"
  PORT="$(adb mdns services 2>/dev/null | grep _adb-tls-connect | head -1 | sed -E 's/.*:([0-9]+).*/\1/')"
  if [ -z "$PORT" ]; then
    echo ""
    say "$D" "  I could not find it by myself. Open:"
    say "$D" "    Settings, Developer options, Wireless debugging"
    say "$D" "  and leave it ON. It shows 'IP address & Port'."
    printf "  Type just the port number: "; read -r PORT
  fi
  [ -z "$PORT" ] && { say "$R" "  no port, nothing done"; return 1; }
  say "$A" "  connecting to 127.0.0.1:$PORT"
  adb connect "127.0.0.1:$PORT" || true
  sleep 1
  if test_media; then return 0; fi
  say "$R" "  connected but the media command was refused."
  say "$D" "  If this phone has never been paired, choose P below first."
  return 1
}

do_pair(){
  command -v adb >/dev/null 2>&1 || pkg install -y android-tools >/dev/null 2>&1
  echo ""
  say "$D" "  On the phone open:"
  say "$D" "    Settings, Developer options, Wireless debugging,"
  say "$D" "    then 'Pair device with pairing code'."
  say "$D" "  Keep that window open. Use split screen if you can, because"
  say "$D" "  Android throws the pairing away when the dialog closes."
  echo ""
  printf "  Pairing PORT (the one in the pairing window): "; read -r PP
  printf "  Six digit CODE: "; read -r CODE
  [ -z "$PP" ] || [ -z "$CODE" ] && { say "$R" "  nothing entered"; return 1; }
  adb pair "127.0.0.1:$PP" "$CODE" && say "$G" "  paired" || { say "$R" "  pairing failed"; return 1; }
  do_connect
}

do_status(){
  echo ""
  command -v rish >/dev/null 2>&1 && say "$G" "  rish  present (Shizuku)" || say "$D" "  rish  not installed"
  command -v adb  >/dev/null 2>&1 && say "$G" "  adb   present" || say "$D" "  adb   not installed"
  command -v adb  >/dev/null 2>&1 && { echo ""; adb devices | sed 's/^/    /'; }
  echo ""
  if test_media; then :; else say "$R" "  no privileged route right now"; fi
}

while :; do
  echo ""
  say "$A" "  MA READER, media control setup"
  echo ""
  say "$D" "  Android only lets a shell press play on another app. Two ways in,"
  say "$D" "  both from Developer options, both needed once per reboot."
  echo ""
  echo "    [C] connect and test   (Wireless debugging is ON)"
  echo "    [P] pair first         (never paired on this phone)"
  echo "    [S] what do I have"
  echo "    [Q] quit"
  echo ""
  printf "  choose: "; read -r K
  case "$K" in
    c|C) do_connect ;;
    p|P) do_pair ;;
    s|S) do_status ;;
    q|Q|"") echo ""; break ;;
    *) say "$R" "  C, P, S or Q" ;;
  esac
done
ADBEOF
put_cmd "$BIN/maread-adb"

prog 100 "done"
echo ""
printf '\n   %sinstalled%s   type %smareadweb%s to run it\n' "$B$GREEN" "$OFF" "$KEY" "$OFF"
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
echo " Help tab:    explains the folders (auto created) and the Gemini key."
echo ""
echo " For Export to reach Downloads, run 'termux-setup-storage' once."
echo " Optional: 'pkg install ffmpeg' gives exact clip lengths (a frame parser"
echo " is used otherwise)."
printf '\n   %sTo remove it later, run this same file and press %su%s%s, or %sU%s %sto take\n' \
  "$DIM" "$B$GLOW" "$OFF" "$DIM" "$B$RED" "$OFF" "$DIM"
printf '   the library with it. There is no second script to lose.%s\n\n' "$OFF"
