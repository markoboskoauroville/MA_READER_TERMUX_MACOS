#!/usr/bin/env bash
# MA READER, macOS: find every trace of an old install and remove it.
#
# It LOOKS first and shows you the list. Nothing is removed until you press y.
# Your texts and your keys are shown separately and you are asked about them
# on their own, because those are yours and the code is not.
#
#   bash macos_wipe.sh

A=$'\033[38;5;214m'; G=$'\033[38;5;114m'; R=$'\033[38;5;203m'
D=$'\033[38;5;245m'; K=$'\033[1;38;5;222m'; W=$'\033[38;5;252m'; O=$'\033[0m'
say(){ printf '%s%s%s\n' "$1" "$2" "$O"; }
rule(){ printf '   %s%s%s\n' "$D" "----------------------------------------" "$O"; }

# ---------------------------------------------------- the echo guarantee ----
# Saved once, before anything touches the terminal, and put back on EVERY way
# out. Never `stty raw`: raw turns signals off, so Ctrl+C stops being a signal
# and the trap never fires, and the terminal is left deaf.
TTY_SAVED=""
[ -t 0 ] && TTY_SAVED="$(stty -g 2>/dev/null || true)"
tty_restore(){
  [ -n "$TTY_SAVED" ] && stty "$TTY_SAVED" 2>/dev/null || true
  [ -t 0 ] && stty echo 2>/dev/null || true
}
trap 'tty_restore' EXIT
trap 'tty_restore; exit 130' INT
trap 'tty_restore; exit 143' TERM
trap 'tty_restore; exit 129' HUP

getkey(){
  if [ -t 0 ]; then
    old="$(stty -g 2>/dev/null)"
    stty -icanon -echo min 1 time 0 2>/dev/null
    k="$(dd bs=1 count=1 2>/dev/null)"
    stty "$old" 2>/dev/null
    printf '%s' "$k"
  else
    # NOT `|| k=""`: a pipe with no trailing newline makes read return
    # non-zero AFTER filling k, and clearing it there throws the answer away
    IFS= read -r k || true
    printf '%s' "$k"
  fi
}

# ------------------------------------------------------------- discovery ----
# NOT a fixed list. Old installs of this app have gone by several names over
# the years and guessing is how traces get left behind, so the disk is asked.
CODE=""      # the app, its commands, its launchd jobs
MINE=""      # texts, settings, keys: yours, asked about separately
RUNNING=""

add_code(){ [ -e "$1" ] && CODE="$CODE
$1"; }
add_mine(){ [ -e "$1" ] && MINE="$MINE
$1"; }

look(){
  # reset first: look() is called twice, before and after, and appending to a
  # list that was never cleared reports every item twice
  CODE=""; MINE=""; RUNNING=""
  # the app folder, under every name it has used
  for d in "$HOME/.maread-web" "$HOME/.ma-reader-web" "$HOME/.mareader" \
           "$HOME/.ma_reader_web" "$HOME/Library/Application Support/MA Reader"; do
    [ -d "$d" ] || continue
    for keep in web_state.json web_state.json.bak speechify_api.txt \
                groq_api.txt gemini_key.txt browser.txt adb_port.txt; do
      add_mine "$d/$keep"
    done
    add_code "$d"
  done

  # the library of texts and the exports, which are his
  add_mine "$HOME/.maread"
  add_mine "$HOME/Documents/MA Reader"

  # commands, wherever a Mac might have put them
  for b in "$HOME/.local/bin" /usr/local/bin /opt/homebrew/bin "$HOME/bin"; do
    [ -d "$b" ] || continue
    for c in mareadweb maread maread-update maread-adb ma-reader-web mareader \
             read-web readweb; do
      add_code "$b/$c"
    done
  done

  # launchd jobs: the thing that made it come back at every login
  for d in "$HOME/Library/LaunchAgents" /Library/LaunchAgents; do
    [ -d "$d" ] || continue
    while IFS= read -r p; do
      [ -n "$p" ] && add_code "$p"
    done <<EOF
$(ls "$d" 2>/dev/null | grep -i 'maread\|ma-reader\|mareader' | sed "s|^|$d/|")
EOF
  done

  # NOT a bare server.py: that matches any python on the machine, and any
  # shell whose command line happens to mention it. Only our own names.
  # exclude THIS script and its parent: their command lines contain the very
  # word being searched for, so a loose pgrep always finds itself
  RUNNING="$(pgrep -fl 'maread-web|ma-reader|mareader|mareadweb' 2>/dev/null \
             | grep -v "^$$ " | grep -v "^$PPID " | grep -v 'macos_wipe' | head -8)"
}

show(){
  echo ""
  say "$K" "  MA READER, macOS: what is on this Mac"
  rule
  if [ -n "$CODE" ]; then
    say "$W" "  the app itself, to be removed:"
    printf '%s\n' "$CODE" | grep -v '^$' | sed "s|^|    |"
  else
    say "$G" "  no old install found. Nothing to remove."
  fi
  if [ -n "$MINE" ]; then
    echo ""
    say "$W" "  yours, kept unless you say otherwise:"
    printf '%s\n' "$MINE" | grep -v '^$' | sed "s|^|    |"
  fi
  if [ -n "$RUNNING" ]; then
    echo ""
    say "$A" "  still running:"
    printf '%s\n' "$RUNNING" | sed "s|^|    |"
  fi
  rule
}

stop_running(){
  # launchd first, or it restarts whatever we kill
  for p in $(printf '%s\n' "$CODE" | grep -i '\.plist$'); do
    launchctl unload "$p" >/dev/null 2>&1 || true
    launchctl bootout "gui/$(id -u)" "$p" >/dev/null 2>&1 || true
  done
  pkill -f 'maread|ma-reader' >/dev/null 2>&1 || true
  sleep 1
}

remove_code(){
  stop_running
  n=0
  for p in $(printf '%s\n' "$CODE" | grep -v '^$'); do
    if [ -d "$p" ]; then
      # keep the files that are his, even inside the app folder
      for keep in web_state.json web_state.json.bak speechify_api.txt \
                  groq_api.txt browser.txt adb_port.txt; do
        [ -f "$p/$keep" ] && cp -p "$p/$keep" "$HOME/.maread-kept-$keep" 2>/dev/null
      done
      rm -rf "$p" && n=$((n+1))
    else
      rm -f "$p" && n=$((n+1))
    fi
  done
  say "$G" "  removed $n item(s)."
  if ls "$HOME"/.maread-kept-* >/dev/null 2>&1; then
    say "$D" "  your keys and settings were copied to:"
    ls "$HOME"/.maread-kept-* 2>/dev/null | sed 's|^|    |'
  fi
}

look
show
[ -z "$CODE" ] && { echo ""; exit 0; }

echo ""
printf '    %s[y]%s %sremove the app, keep my texts and keys%s\n' "$K" "$O" "$D" "$O"
printf '    %s[a]%s %sremove EVERYTHING, texts and keys as well%s\n' "$K" "$O" "$D" "$O"
printf '    %s[q]%s %squit, change nothing%s\n' "$K" "$O" "$D" "$O"
echo ""
printf '   %s>%s ' "$A" "$O"
k="$(getkey)"; echo ""
case "$k" in
  y|Y) echo ""; remove_code ;;
  a|A)
    echo ""
    say "$R" "  this also deletes your saved texts, settings and API keys."
    printf '   %stype the word yes to confirm:%s ' "$D" "$O"
    IFS= read -r confirm
    if [ "$confirm" = "yes" ]; then
      CODE="$CODE
$MINE"
      remove_code
      rm -f "$HOME"/.maread-kept-* 2>/dev/null
      say "$G" "  everything is gone."
    else
      say "$D" "  not confirmed. Nothing was changed."
    fi ;;
  *) say "$D" "  nothing was changed." ;;
esac

echo ""
look
if [ -z "$CODE" ]; then
  say "$G" "  clean. Nothing of the old install is left."
else
  say "$A" "  still there:"
  printf '%s\n' "$CODE" | grep -v '^$' | sed 's|^|    |'
fi
echo ""
