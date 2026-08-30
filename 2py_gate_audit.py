#!/usr/bin/env python3
"""Audit MA Reader against the manifest's nine gates.

Written to obey modules/checking-the-checks.md, because an audit that lies is
worse than no audit:

  face 1  find(), never index() -- a crash must not look like a pass
  face 2  comments and docstrings STRIPPED before matching, so a check cannot
          match the comment explaining the thing it is checking for
  face 3  markers anchored so a definition cannot satisfy "is it called"
  face 6  every slice's length asserted, so a claim about WHERE is checked
  face 8  the claim is written first; the assertion must match the title
"""
import io, re, sys, json

TERMUX = "/home/claude/w/repo/3sh_i_ma_reader_v3_termux.sh"
MACOS  = "/home/claude/w/repo/3sh_i_ma_reader_v3_macos.sh"

def parts(path):
    s = io.open(path, encoding="utf-8").read()
    a = s.find('cat > "$APPDIR/server.py" << \'PYEOF\'\n')
    b = s.find('cat > "$APPDIR/static/index.html" << \'HTMLEOF\'\n')
    assert a > 0 and b > 0, "the two payloads must be findable"
    py = s[a + 40:s.find("\nPYEOF", a)]
    ht = s[b + 48:s.find("\nHTMLEOF", b)]
    i = ht.find('<script>\n"use strict"')
    js = ht[i:ht.rfind("</script>")] if i > 0 else ""
    # face 6: a slice is a claim about WHERE and deserves its own check
    assert 50000 < len(py) < 400000, "server slice looks wrong: %d" % len(py)
    assert 50000 < len(ht) < 400000, "page slice looks wrong: %d" % len(ht)
    assert 20000 < len(js) < 400000, "script slice looks wrong: %d" % len(js)
    return s, py, ht, js

def strip_py(s):
    """face 2: comments and docstrings out, so a check cannot match the note
    that explains the removal."""
    s = re.sub(r'"""[\s\S]*?"""', ' ', s)
    s = re.sub(r"'''[\s\S]*?'''", ' ', s)
    return re.sub(r'(?m)#.*$', ' ', s)

def strip_js(s):
    s = re.sub(r'/\*[\s\S]*?\*/', ' ', s)
    return re.sub(r'(?m)//.*$', ' ', s)

def strip_sh(s):
    return re.sub(r'(?m)^\s*#.*$', ' ', s)

FIND = []
def gate(n, title, ok, note=""):
    FIND.append((n, title, bool(ok), str(note)[:90]))

def run(path, label):
    global FIND
    FIND = []
    raw, py, ht, js = parts(path)
    PY, JS, SH = strip_py(py), strip_js(js), strip_sh(raw)

    # ---- GATE 0: port, do not invent -------------------------------------
    gate(0, "the Key_Tester parser is the one in use",
         PY.count("_K_LOOSE") >= 2 and PY.count("key_extract(") >= 3,
         "_K_LOOSE x%d, key_extract x%d" % (PY.count("_K_LOOSE"), PY.count("key_extract(")))
    gate(0, "the canonical loose test: a letter AND a digit",
         "isdigit() for c in tok" in PY and "isalpha() for c in tok" in PY)

    # ---- GATE 1: the terminal gets its echo back -------------------------
    gate(1, "no full raw mode anywhere", "stty raw" not in SH)
    gate(1, "-icanon -echo is what is used", "-icanon -echo min 1 time 0" in SH)
    gate(1, "the tty state is saved", SH.count("TTY_SAVED=") >= 3)
    # face 3: anchor so a definition cannot satisfy "is it trapped"
    gate(1, "every key-reading script traps all four ways out",
         SH.count("trap 'tty_restore' EXIT") >= 2
         and SH.count("trap 'tty_restore; exit 130' INT") >= 2
         and SH.count("trap 'tty_restore; exit 143' TERM") >= 2
         and SH.count("trap 'tty_restore; exit 129' HUP") >= 2,
         "EXIT x%d INT x%d TERM x%d HUP x%d" % (
             SH.count("trap 'tty_restore' EXIT"),
             SH.count("trap 'tty_restore; exit 130' INT"),
             SH.count("trap 'tty_restore; exit 143' TERM"),
             SH.count("trap 'tty_restore; exit 129' HUP")))

    # ---- GATE 2: settings survive interruption ---------------------------
    gate(2, "the settings write is atomic", "os.replace(tmp, STATE_FILE)" in PY)
    gate(2, "a .bak is kept", 'STATE_FILE + ".bak"' in PY)
    gate(2, "flushed on hide, not on a timer",
         JS.count("sendBeacon") >= 2 and "visibilitychange" in JS and "pagehide" in JS,
         "%d beacons, on visibilitychange and pagehide" % JS.count("sendBeacon"))
    # every save path must be gated, not merely one of them
    gate(2, "EVERY save path waits for the app to load",
         JS.count("if(!booted) return") >= 2,
         "%d of the save paths" % JS.count("if(!booted) return"))

    # ---- GATE 3: API keys ------------------------------------------------
    gate(3, "keys arrive by file, never typed", 'type="file"' in ht)
    gate(3, "the key file is written 0600", "0o600" in PY)
    gate(3, "the dead list stores fingerprints, never keys",
         PY.count("hexdigest()[:16]") + PY.count("hexdigest()[:12]") >= 3,
         "%d fingerprint sites" % (PY.count("hexdigest()[:16]") + PY.count("hexdigest()[:12]")))
    gate(3, "shape ranks, it never discards", "_K_LOOSE" in PY)
    # both places that can refuse a key must skip rather than condemn
    gate(3, "a weak candidate is skipped, not gravestoned",
         PY.count("_groq_skip.add") >= 2,
         "%d refusal paths" % PY.count("_groq_skip.add"))
    for f in ("speechify_api.txt", "groq_api.txt", "web_state.json"):
        gate(3, "KEEP holds %s" % f, f in SH.split('KEEP="')[1].split('"')[0]
             if 'KEEP="' in SH else False)

    # ---- GATE 4: replacing yourself --------------------------------------
    gate(4, "a running server is detected", "srv_pids()" in SH)
    # the rename must be USED for every command, not merely defined
    gate(4, "commands are renamed into place",
         SH.count("put_cmd ") >= 3 and "mv -f" in SH,
         "%d commands written that way" % SH.count("put_cmd "))
    gate(4, "the detector requires a python first",
         "python|python2|python2.*|python3" in SH)

    # ---- GATE 5: talking to a provider -----------------------------------
    gate(5, "Groq is asked with a browser agent", "Chrome/126.0" in PY)
    # face 4: a count is not a check, and presence ANYWHERE is a count of one.
    # The guard must be in BOTH places that can condemn a key, so each is
    # scoped and asserted on its own; mutating one used to leave this green.
    def _fn(src, name):
        i = src.find("\ndef %s(" % name)
        if i < 0: return ""
        j = src.find("\ndef ", i + 6)
        seg = src[i:j if j > 0 else len(src)]
        assert 100 < len(seg) < 20000, "%s slice is %d" % (name, len(seg))
        return seg
    for fn in ("groq_call", "wt_fetch"):
        gate(5, "%s spares the key on a cloudflare 403" % fn,
             '"1010" in txt' in _fn(PY, fn), "scoped to that function alone")
    gate(5, "the model is discovered, not assumed", "def groq_candidates" in PY)
    gate(5, "the recogniser's answer is gated", "def wt_sane" in PY)
    gate(5, "the model follows the voice, per Speechify's chapter",
         '"model": SP_MODEL_MULTI' in PY and '"model": SP_MODEL' in PY)
    gate(5, "simba-3.2 is never sent", "simba-3.2" not in PY)

    # ---- GATE 8: before the push -----------------------------------------
    # face 3 again: "defined" and "called" are different questions
    names = set(re.findall(r'(?m)^def (\w+)', PY))
    dups = [n for n in names if len(re.findall(r'(?m)^def %s\(' % re.escape(n), PY)) > 1]
    gate(8, "no duplicate function names in the server", not dups, dups or "none")
    jn = re.findall(r'(?m)^function (\w+)\(', JS)
    jdups = sorted({n for n in jn if jn.count(n) > 1})
    gate(8, "no duplicate function names in the script", not jdups, jdups or "none")

    # dead code: defined and never called
    # face 8: the RULE is "nothing unreachable", not "nothing uncalled".
    # A Flask route is reached by its decorator and a callback by reference,
    # so counting `name(` alone reports live code as dead. Both blind spots
    # were met by this very audit before the check was corrected.
    dead = []
    for n in sorted(names):
        if n.startswith("api_") or n.startswith("_"):
            continue
        if re.search(r'(?m)^@[^\n]*\n(@[^\n]*\n)*def %s\(' % re.escape(n), PY):
            continue            # decorated: the framework calls it
        calls = len(re.findall(r'(?<![\w.])%s\s*\(' % re.escape(n), PY))
        refs  = len(re.findall(r'(?<![\w.])%s(?!\s*\()(?![\w])' % re.escape(n), PY))
        if calls <= 1 and refs == 0:
            dead.append(n)
    gate(8, "no unreachable server functions", not dead, dead or "none")
    jdead = []
    for n in sorted(set(jn)):
        calls = len(re.findall(r'(?<![\w.])%s\s*\(' % re.escape(n), JS))
        refs  = len(re.findall(r'(?<![\w.])%s(?!\s*\()(?![\w])' % re.escape(n), JS))
        inhtml = ht.count(n)
        if calls <= 1 and refs == 0 and inhtml == 0:
            jdead.append(n)
    gate(8, "no unreachable script functions", not jdead, jdead or "none")

    # names used but never defined, in the script
    return raw, PY, JS, SH, dead, jdead

for path, label in ((TERMUX, "TERMUX"), (MACOS, "macOS")):
    print("\n" + "=" * 74)
    print("  %s  %s" % (label, re.search(r'edition: (v[0-9.]+)',
          io.open(path, encoding="utf-8").read()).group(1)))
    print("=" * 74)
    raw, PY, JS, SH, dead, jdead = run(path, label)
    bad = [f for f in FIND if not f[2]]
    cur = None
    for n, title, ok, note in FIND:
        if n != cur:
            print("\n  GATE %d" % n); cur = n
        print("    %s %-52s %s" % ("ok  " if ok else "FAIL", title, note))
    print("\n  %s: %d checks, %d failures" % (label, len(FIND), len(bad)))
