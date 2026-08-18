#!/usr/bin/env python3
"""Bump the visible version of MA Reader. Run before every push.

    python3 bump.py            3.4  ->  3.5
    python3 bump.py 4.0        set it outright

The FILENAME never changes. It names the line, 3, and maread-update fetches
it by that name; renaming it on every build would break the one command Baba
actually types. The visible version carries the build after the dot, so a
small change is still a change he can see and name.
"""
import io, re, sys, os

F = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                 "3sh_i_ma_reader_v3_termux.sh")
s = io.open(F, encoding="utf-8").read()

cur = re.search(r"edition: v([0-9]+(?:\.[0-9]+)?)", s)
if not cur:
    sys.exit("could not find the edition line")
old = cur.group(1)

if len(sys.argv) > 1:
    new = sys.argv[1]
else:
    parts = old.split(".")
    new = "%s.%d" % (parts[0], (int(parts[1]) if len(parts) > 1 else 0) + 1)

pats = [
    (r"edition: v" + re.escape(old), "edition: v" + new),
    (r"R E A D E R%s  %sv" + re.escape(old) + r"%s",
     "R E A D E R%s  %sv" + new + "%s"),
    (r'<span id="appVer">v' + re.escape(old),
     '<span id="appVer">v' + new),
]
hits = 0
for pat, rep in pats:
    s, n = re.subn(pat, rep.replace("\\", "\\\\"), s)
    hits += n
    if not n:
        print("  !! nothing matched:", pat[:50])
io.open(F, "w", encoding="utf-8").write(s)
print("v%s -> v%s   (%d places)" % (old, new, hits))
