#!/data/data/com.termux/files/usr/bin/bash
# MA READER probe. Answers one question: what does this phone already have,
# and what is the shortest road from here to switching apps from the reader?
#
# It CHANGES NOTHING. Every command below reads; none installs, connects,
# pairs or writes anywhere except the log file.
#
#   bash probe.sh
#
# then attach ~/storage/downloads/probe_log.txt (or the path it prints).

OUT="$HOME/storage/downloads/probe_log.txt"
[ -d "$HOME/storage/downloads" ] || OUT="$HOME/probe_log.txt"
: > "$OUT"

say() { printf '%s\n' "$*" >> "$OUT"; }
hdr() { say ""; say "=== $* ==="; }
run() {   # run <label> <command...>   never fails the script
  local label="$1"; shift
  local o
  o="$("$@" 2>&1 </dev/null | head -20)"
  if [ -n "$o" ]; then
    say "$label:"
    printf '%s\n' "$o" | sed 's/^/    /' >> "$OUT"
  else
    say "$label: (no output)"
  fi
}
have() { command -v "$1" >/dev/null 2>&1 && echo yes || echo no; }

say "MA READER probe"
say "generated: $(date 2>/dev/null)"

hdr "the phone"
say "android    : $(getprop ro.build.version.release 2>/dev/null)"
say "sdk        : $(getprop ro.build.version.sdk 2>/dev/null)"
say "model      : $(getprop ro.product.model 2>/dev/null)"
say "manufacturer: $(getprop ro.product.manufacturer 2>/dev/null)"

hdr "what is on PATH"
for c in rish adb python python3 sh su pm am input unzip curl termux-setup-storage; do
  printf '%-22s %s\n' "$c" "$(have "$c")" >> "$OUT"
done
say "PATH       : $PATH"

hdr "rish, the Shizuku bridge"
say "rish on PATH        : $(have rish)"
for p in "$HOME/.local/bin/rish" "$HOME/rish" "$PREFIX/bin/rish" "$HOME/bin/rish"; do
  [ -e "$p" ] && say "found file          : $p  ($(stat -c '%A %s bytes' "$p" 2>/dev/null))"
done
for p in "$HOME/.local/bin/rish_shizuku.dex" "$HOME/rish_shizuku.dex" "$PREFIX/bin/rish_shizuku.dex"; do
  [ -e "$p" ] && say "found dex           : $p  ($(stat -c '%s bytes' "$p" 2>/dev/null))"
done
if command -v rish >/dev/null 2>&1; then
  run "rish -c 'echo PROBE_OK'" rish -c 'echo PROBE_OK'
  run "rish -c 'id'" rish -c 'id'
else
  say "rish is not on PATH, so nothing to try"
fi

hdr "is Shizuku installed and running"
say "package present     : $(pm list packages 2>/dev/null | grep -c moe.shizuku.privileged.api)"
run "pm path shizuku" sh -c "pm path moe.shizuku.privileged.api 2>&1"
run "shizuku process" sh -c "ps -A 2>/dev/null | grep -i shizuku | head -5"
run "shizuku service" sh -c "dumpsys -l 2>/dev/null | grep -i shizuku | head -5"

hdr "adb, the other road"
say "adb on PATH         : $(have adb)"
if command -v adb >/dev/null 2>&1; then
  run "adb version" adb version
  run "adb devices" adb devices
  run "adb shell true" adb shell true
  run "adb mdns services" adb mdns services
fi
say "wireless debugging  : $(settings get global adb_wifi_enabled 2>/dev/null)"
say "usb debugging       : $(settings get global adb_enabled 2>/dev/null)"

hdr "can a plain shell already do it (root, or a permissive rom)"
run "input keyevent (dry: id only)" sh -c "id"
run "su -c id" sh -c "su -c id 2>&1 | head -3"

hdr "MA Reader itself"
say "app folder          : $([ -d "$HOME/.maread-web" ] && echo yes || echo no)"
say "version             : $(grep -o 'appVer\">v[0-9.]*' "$HOME/.maread-web/static/index.html" 2>/dev/null | head -1 | sed 's/.*>//')"
say "commands            : $(ls "$PREFIX/bin" 2>/dev/null | grep -c '^maread\|^mareadweb')"
for f in mareadweb maread-update maread-adb; do
  [ -e "$PREFIX/bin/$f" ] && say "  $f present"
done
if [ -f "$HOME/.maread-web/web_state.json" ]; then
  say "adbMode setting     : $(python3 -c "
import json,sys
try:
    print(json.load(open('$HOME/.maread-web/web_state.json')).get('adbMode','(absent)'))
except Exception as e:
    print('unreadable:', e)
" 2>/dev/null)"
else
  say "settings file       : none yet"
fi

hdr "the apk, in case rish must be extracted"
APKP="$(pm path moe.shizuku.privileged.api 2>/dev/null | head -1 | sed 's/^package://')"
say "apk path            : ${APKP:-not found}"
if [ -n "$APKP" ] && command -v unzip >/dev/null 2>&1; then
  run "rish files inside the apk" sh -c "unzip -l '$APKP' 2>/dev/null | grep -i rish"
else
  say "cannot look inside: unzip=$(have unzip)"
fi

hdr "storage"
say "downloads folder    : $([ -d "$HOME/storage/downloads" ] && echo yes || echo 'no, run termux-setup-storage')"
say "writable home       : $([ -w "$HOME" ] && echo yes || echo no)"

say ""
say "=== end of probe ==="
say "nothing was installed, connected, paired or changed."

echo ""
echo "  written to: $OUT"
echo "  attach that file in the chat."
echo ""
