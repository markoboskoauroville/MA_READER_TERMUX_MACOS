#!/data/data/com.termux/files/usr/bin/bash
###############################################################################
# MA Reader - first time setup, and the update itself, in one run.
#
#   bash update.sh
#
# It fetches the current version from GitHub and installs it right now, and it
# leaves behind a command called `maread-update` so that every future update is
# one word. The earlier version of this file only left the command behind and
# did not update anything, which looked exactly like nothing happening.
#
# No GitHub login is needed. The repository is public, the download is
# anonymous, and no token is ever stored on the phone.
###############################################################################
set -e
RAW="https://raw.githubusercontent.com/markoboskoauroville/ma-reader-thermux/main"
FILE="3sh_i_ma_reader_v3_termux.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

printf '\033[38;5;214m\n  fetching the newest MA Reader\033[0m\n'
if ! curl -fsSL --retry 3 --connect-timeout 20 -o "$TMP/$FILE" "$RAW/$FILE"; then
  printf '\033[38;5;203m  could not reach GitHub. Check the network and try again.\033[0m\n'
  printf '  nothing was changed.\n'
  exit 1
fi

SIZE=$(wc -c < "$TMP/$FILE")
if [ "$SIZE" -lt 100000 ] || ! head -1 "$TMP/$FILE" | grep -q '^#!'; then
  printf '\033[38;5;203m  the download looks wrong (%s bytes). Nothing was changed.\033[0m\n' "$SIZE"
  exit 1
fi
if ! bash -n "$TMP/$FILE" 2>/dev/null; then
  printf '\033[38;5;203m  the downloaded file did not parse. Nothing was changed.\033[0m\n'
  exit 1
fi

printf '  got %s bytes, %s\n' "$SIZE" "$(grep -m1 'edition: v' "$TMP/$FILE" | sed 's/.*edition: //')"

# The installer stops any running server, keeps the keys, wipes the old app
# folder and writes a fresh one. It also leaves the maread-update command
# behind, so nothing further is needed here.
bash "$TMP/$FILE" --offline
