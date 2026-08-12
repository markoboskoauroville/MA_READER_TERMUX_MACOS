#!/data/data/com.termux/files/usr/bin/bash
###############################################################################
# MA Reader - one command update, straight from GitHub.
#
# Run this file once and it leaves behind a command called `maread-update`.
# After that, updating is one word: maread-update
#
#   bash update.sh          install the maread-update command
#   maread-update           fetch the newest installer and run it
#   maread-update --online  same, but fetch python/flask/edge-tts too
#
# Nothing here needs a GitHub login. The repository is public, so the
# download is anonymous and no token is ever stored on the phone.
###############################################################################
set -e
RAW="https://raw.githubusercontent.com/markoboskoauroville/ma-reader-thermux/main"
FILE="3sh_i_ma_reader_v3_termux.sh"
BIN="${PREFIX:-/usr/local}/bin"
CMD="$BIN/maread-update"

mkdir -p "$BIN"
cat > "$CMD" <<'INNER'
#!/data/data/com.termux/files/usr/bin/bash
# Fetch the current MA Reader installer from GitHub and run it.
set -e
RAW="https://raw.githubusercontent.com/markoboskoauroville/ma-reader-thermux/main"
FILE="3sh_i_ma_reader_v3_termux.sh"
MODE="--offline"
for a in "$@"; do case "$a" in --online) MODE="--online";; --remove|-u) MODE="--uninstall";; esac; done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
printf '\033[38;2;250;204;96m  fetching the newest MA Reader\033[0m\n'

if ! curl -fsSL --retry 3 --connect-timeout 20 -o "$TMP/$FILE" "$RAW/$FILE"; then
  printf '\033[38;2;248;113;113m  could not reach GitHub. Check the network and try again.\033[0m\n'
  printf '  nothing was changed.\n'
  exit 1
fi

# Refuse to run a truncated or wrong-shaped download. A half-fetched
# installer is worse than no installer at all.
SIZE=$(wc -c < "$TMP/$FILE")
if [ "$SIZE" -lt 100000 ] || ! head -1 "$TMP/$FILE" | grep -q '^#!'; then
  printf '\033[38;2;248;113;113m  the download looks wrong (%s bytes). Nothing was changed.\033[0m\n' "$SIZE"
  exit 1
fi
if ! bash -n "$TMP/$FILE" 2>/dev/null; then
  printf '\033[38;2;248;113;113m  the downloaded file did not parse. Nothing was changed.\033[0m\n'
  exit 1
fi

VER=$(grep -m1 'edition: v' "$TMP/$FILE" | sed 's/.*edition: //')
printf '  got %s bytes, %s\n\n' "$SIZE" "${VER:-unknown edition}"
bash "$TMP/$FILE" "$MODE"
INNER

chmod +x "$CMD"
printf '\n\033[38;2;110;231;183m  installed\033[0m   type \033[1;38;2;253;232;178mmaread-update\033[0m whenever you want the newest version\n'
printf '  it fetches from github.com/markoboskoauroville/ma-reader-thermux\n'
printf '  and needs no login, because the repository is public.\n\n'
printf '  maread-update            update the app\n'
printf '  maread-update --online   update, and refresh python/flask/edge-tts\n'
printf '  maread-update --remove   take the app off, keep the library\n\n'
