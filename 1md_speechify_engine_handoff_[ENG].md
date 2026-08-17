# Speechify Engine, Handoff

Revised 17.8.2026. Section 5 changed: the picker no longer holds four voices,
it PAGES the whole catalogue four at a time. Everything else stands.

How to build a Speechify TTS engine with a lazy self healing key ring.
Everything here was verified against the live API on 12.8.2026 with 21 real
keys, not read from documentation. Where a fact cost a bug, the bug is written
down beside it.

Copy this whole document into any project that needs Speechify, and copy the
code blocks as they are. They are engine agnostic apart from the two hooks
marked YOUR APP.

---

## 1. What the API actually is

Base URL

    https://api.sws.speechify.com

Auth, on every request

    Authorization: Bearer sk_...

Two endpoints are enough for a reader or a player.

    GET  /v1/voices          the catalogue
    POST /v1/audio/speech    one synthesis, returns audio AND word timings

### Verdicts, the only status mapping you need

    2xx        WORKING     use it
    401, 403   REJECTED    the key is dead, condemn it, never try it again
    429        LIMITED     the key is VALID but throttled, rest it, do not kill it
    other      OTHER       unclear, move on
    exception  OFFLINE     the network failed, NOT the key, never blame the key

The 401 body looks like this, and is identical for a corrupted key, an empty
key and a nonsense key, so do not try to tell them apart

    {"error":{"code":"unauthorized","message":"Unauthorized"},"request_id":"..."}

---

## 2. TRAP ONE, the catalogue is paginated

This is the single most expensive thing to get wrong.

    GET /v1/voices

returns **50 voices by default**, and the response carries

    {"voices":[...], "next_cursor":"...", "has_more":true}

Fifty voices sorted alphabetically is **all A names**. Filter that page for
en-GB and you get exactly ONE voice, Alec, male. You will conclude the account
is a limited tier and build a fallback for a problem that does not exist.

The real catalogue is **962 voices**, of which **33 are en-GB** and **84 are
en-US**. Every key sees all of them, free tier or not. There is no tier
difference at all.

Walk the cursor. `limit` caps at 200, other page size parameters are ignored.

    def fetch_all_voices(call):
        out, cursor = [], None
        for _ in range(12):                       # 962 / 200 = 5, 12 is slack
            q = "?limit=200" + ("&cursor=" + quote(cursor) if cursor else "")
            d, err = call("/v1/voices" + q, timeout=30)
            if d is None:
                return (out, "") if out else (None, err)
            out.extend(d.get("voices") or [])
            cursor = d.get("next_cursor")
            if not d.get("has_more") or not cursor:
                break
        return out, ""

Parameters that do NOT work: `page_size`, `per_page`, `page`. Only `limit` and
`cursor`.

### The voice record

    {
      "id": "beatrice_32...",          use this as voice_id
      "display_name": "Beatrice",
      "gender": "female",              "female" | "male"
      "locale": "en-GB",
      "type": "shared",
      "models": [{"name":"simba-english","languages":[{"locale":"en-GB"}]}],
      "tags": ["gender:female","timbre:warm","age:young-adult", ...],
      "avatar_image": "...", "preview_audio": "..."
    }

Locale can appear at top level AND nested inside models, so read both. The
one word character Speechify prints next to a name lives in the tags as
`timbre:warm`, not as a bare tag.

    def tone(v):
        for t in v.get("tags") or []:
            if str(t).startswith("timbre:"):
                return str(t).split(":", 1)[1].replace("-", " ").capitalize()
        return ""

---

## 3. Synthesis, and free word timings

    POST /v1/audio/speech
    {
      "input": "The river remembers every stone it has ever touched.",
      "voice_id": "beatrice",
      "audio_format": "mp3",
      "model": "simba-english"
    }

Models seen in the wild: `simba-english`, `simba-3.0`, `simba-3.2`,
`simba-multilingual`.

**TRAP FIVE, do not follow the docs' model advice blindly.** The documentation
tells new integrations to use `simba-3.2`, and it is right *if* you only ever
use the eight curated voices whose ids end `_32` (beatrice_32, dominic_32,
edmund_32, geffen_32, harper_32, hugh_32, imogen_32, wyatt_32). The moment you
page through the whole catalogue, most voices are not in that set, and
`simba-3.2` answers **HTTP 400** for them. Measured 12.8.2026:

    Beatrice (beatrice_32)   simba-english  ok      simba-3.2  ok
    Harper   (harper)        simba-english  ok      simba-3.2  HTTP 400

So **`simba-english` is the correct default** for any app that offers the full
catalogue. Both models return identical speech marks, and simba-3.2 is only
marginally smaller, so there is nothing lost by it.

Response

    {
      "audio_data": "<base64 mp3>",
      "audio_format": "mp3",
      "billable_characters_count": 51,
      "speech_marks": { ... }
    }

### TRAP TWO, in a good way: the speech marks are exact

    {
      "type": "sentence", "start": 0, "end": 51,
      "start_time": 0, "end_time": 4210,
      "value": "The river remembers...",
      "chunks": [
        {"type":"word","value":"The","start":0,"end":3,
         "start_time":0,"end_time":371},
        {"type":"word","value":"river","start":4,"end":9,
         "start_time":371,"end_time":840},
        ...
      ]
    }

`start` and `end` are **character offsets into the exact string you sent**.
Verified character for character:

    all(TEXT[c["start"]:c["end"]] == c["value"] for c in chunks)   ->  True

Times are **milliseconds**, divide by 1000.

This matters enormously. Microsoft edge-tts reports word times its own engine
invented, which drift, so an edge based reader has to decode the finished mp3
and re-pin every word to the waveform. **On Speechify you do none of that.**
Take the marks as given. Do not "improve" them.

Flatten defensively anyway, because a nested chunk tree may be one level or
two, and key names differ between SDKs (`start_time` vs `startTime`).

    def to_tokens(text, marks):
        flat = []
        def walk(n):
            if not isinstance(n, dict): return
            kids = n.get("chunks") or n.get("nestedChunks") or []
            if kids:
                for c in kids: walk(c)
            elif "start_time" in n or "startTime" in n:
                flat.append(n)
        (walk(marks) if isinstance(marks, dict)
         else [walk(m) for m in (marks or [])])

        n, out = len(text), []
        for m in flat:
            s = max(0, min(n, int(m.get("start", 0))))
            e = max(s, min(n, int(m.get("end", s))))
            if e <= s: continue
            t = float(m.get("start_time", m.get("startTime", 0))) / 1000.0
            d = float(m.get("end_time",   m.get("endTime",   0))) / 1000.0
            out.append({"s": s, "e": e, "t": round(t,3), "d": round(d,3)})
        out.sort(key=lambda w: (w["t"], w["s"]))
        prev = -1.0                                  # strictly increasing
        for w in out:
            if w["t"] <= prev: w["t"] = round(prev + 0.01, 3)
            prev = w["t"]
        for i, w in enumerate(out):                  # hold until the next
            nxt = out[i+1]["t"] if i+1 < len(out) else w["d"]
            if w["d"] <= w["t"] or w["d"] > nxt: w["d"] = nxt
            if w["d"] <= w["t"]: w["d"] = round(w["t"] + 0.05, 3)
        return out

If marks ever come back empty, fall back to whatever the app already does for
engines without timings. Do not fail the sentence.

---

## 4. The key ring, the part worth copying

### The idea

The obvious ring tests every key at startup and picks a winner. With twenty
keys that is twenty round trips to learn something you could have learned by
simply trying. It is also wrong twice over: it spends requests on keys you may
never use, and it re-learns the same dead keys after every restart.

This ring **never tests speculatively**.

1. Take the first key not already known to be dead. Use it. No network.
2. Keep using it until a real request returns 401 or 403.
3. Only then, condemn that key, permanently, to a list on disk.
4. Roll forward to the next key and **retry the same request**, so the user
   never sees a failure.
5. 429 is not death. Rest that key a few minutes and move on.
6. A network error is never the key's fault.

> A dead key costs exactly one wasted request in its whole life.
> A healthy ring costs none at all.

### The key file, and TRAP THREE

Real key files are working documents. They have a heading at the top and a
nickname above each key saying whose it is, because they are shared between
people. A loader that splits on whitespace will try to authenticate with the
word "gym".

**Filter by shape. Treat everything else as a label.**

    SP_KEY_RE = re.compile(r"^sk_[A-Za-z0-9_\-]{20,}$")

    def load_keys(path):
        """Keys in file order, each with the label written above it."""
        out, seen, label = [], set(), ""
        for line in open(path, encoding="utf-8").read().splitlines():
            s = line.strip()
            if not s: continue
            if SP_KEY_RE.match(s):
                if s not in seen:
                    seen.add(s)
                    out.append({"key": s, "label": label or "unnamed"})
                label = ""
            elif s != "[DELETED]":
                label = s[:40]
        return out

File order is try order. Labels are what you show the user, so they see
"cafeteria" rather than a meaningless mask.

Note the shape filter is used ONLY to identify keys inside a mixed file. Never
reject a key the user explicitly hands you because it does not match a
prefix; providers rebrand key formats without notice.

### The dead list, and how to store it safely

Never store the key. Store a fingerprint.

    def fingerprint(key):
        return hashlib.sha256(key.encode("utf-8")).hexdigest()[:16]

    def mask(key):
        return key[:6] + "\u2026" + key[-4:]      # sk_cdt…1bf2

A dead list entry

    {"a1b2c3d4e5f6a7b8": {"mask":"sk_cdt…1bf2", "label":"burned-account",
                          "reason":"rejected (HTTP 401)", "at":1786525062}}

That file can be read by anyone and gives up nothing. The mask shows 10 of 46
characters, and 3 of those are the constant `sk_` prefix.

### The ring itself

    _key = None                      # the key in hand
    _limited = {}                    # key -> unix time it may be tried again
    LIMITED_REST = 300

    def live_keys():
        dead, now = fail_load(), time.time()
        return [e for e in load_keys(KEY_FILE)
                if fingerprint(e["key"]) not in dead
                and _limited.get(e["key"], 0) <= now]

    def current(advance=False):
        """The key to speak through. No network, no speculative testing."""
        global _key
        live = live_keys()
        if not live:
            _key = None
            return None, ""
        if advance and _key:
            i = next((i for i, e in enumerate(live) if e["key"] == _key), -1)
            _key = live[i+1]["key"] if 0 <= i < len(live)-1 else live[0]["key"]
        elif not _key or not any(e["key"] == _key for e in live):
            _key = live[0]["key"]
        return _key, next(e["label"] for e in live if e["key"] == _key)

    def condemn(key, label, reason):
        d = fail_load()
        d[fingerprint(key)] = {"mask": mask(key), "label": label,
                               "reason": reason, "at": int(time.time())}
        fail_save(d)

    def call(path, payload=None, timeout=60):
        """One request, carried by the ring. This is the whole mechanism."""
        tries = max(1, len(live_keys()))
        last = "no key"
        for attempt in range(tries):
            key, label = current(advance=(attempt > 0))
            if not key:
                return None, "no working key"
            try:
                data = json.dumps(payload).encode() if payload is not None else None
                req = urllib.request.Request(API + path, data=data)
                req.add_header("Authorization", "Bearer " + key)
                if data is not None:
                    req.add_header("Content-Type", "application/json")
                body = urllib.request.urlopen(req, timeout=timeout).read()
                return json.loads(body.decode("utf-8", "replace")), ""
            except urllib.error.HTTPError as e:
                if e.code in (401, 403):
                    condemn(key, label, "rejected (HTTP %d)" % e.code)
                    last = "a key was rejected and marked dead"
                    continue                      # SAME request, next key
                if e.code == 429:
                    _limited[key] = time.time() + LIMITED_REST
                    last = "rate limited"
                    continue
                return None, "HTTP %d" % e.code
            except Exception as e:
                return None, "unreachable: %s" % str(e)[:80]
        return None, last

Every other function goes through `call`. Synthesis, catalogue, everything.
That is why a key dying mid session is invisible: the sentence is simply
spoken by the next key.

### What the user must be able to do

Show the dead list in settings, named and dated, with two actions.

    Retry    clear the mark, in case the account was only suspended
    Remove   strike the key out of the file for good

Remove should rewrite the key's line as `[DELETED]` rather than deleting the
line, so the label above it still lines up with nothing.

Offer one **explicit** test-all button. That is the only place in the whole
system that is allowed to spend a request per key.

---

## 5. Picking the voices, automatically

Constraints that came from the app, and are worth keeping:

* Room for **four** voice buttons at the top of a phone screen, no more.
* They arrive in **pairs**, one female one male, like the Edge language rows.
* But four is a WINDOW, not the whole list. There are 33 en-GB and 82 en-US
  voices and no way to tell from a name whether you will like one, so the
  picker pages through the whole catalogue four at a time, with arrows, a
  "n / total" count and a row of numbered buttons so any page is one tap away.
  `pick()` therefore returns EVERY voice for the accent, ordered, zipped
  female male female male so any four consecutive entries are two of each.
  Slice it in the front end. Order: Speechify's own curated set first, then
  the four it calls popular, then the rest by name.
* **English only.** Speechify has no Croatian and no other Slavic voice. This
  was checked against the catalogue, not assumed. Do not offer a language
  picker; offer two accent buttons, UK and US.

Preferred names, chosen from the real catalogue, all confirmed present:

    uk:  F  Beatrice, Imogen        M  Edmund, Hugh
    us:  F  Geffen,   Emily         M  Dominic, Carter

The picker prefers those names and falls back to alphabetical order, so an
account that cannot see one of them still fills all four seats out of the 33
en-GB or 84 en-US voices available.

    PER_SEX = 2

    def pick(voices, accent):
        loc = "en-GB" if accent == "uk" else "en-US"
        pool, seen = {"F": [], "M": []}, set()
        for v in voices:
            sex = "F" if str(v.get("gender","")).lower().startswith("f") else \
                  "M" if str(v.get("gender","")).lower().startswith("m") else ""
            if sex not in pool: continue
            if not any(l == loc or l.startswith(loc) for l in locales(v)): continue
            name = v.get("display_name") or v.get("id")
            if not v.get("id") or name.lower() in seen: continue
            seen.add(name.lower())                 # TRAP FOUR, see below
            pool[sex].append({"id": v["id"], "name": name, "sex": sex,
                              "tone": tone(v), "accent": accent})
        picked = {}
        for sex in ("F", "M"):
            want = [n.lower() for n in PREFER[accent][sex]]
            pool[sex].sort(key=lambda x: (want.index(x["name"].lower())
                                          if x["name"].lower() in want else 99,
                                          x["name"].lower()))
            picked[sex] = pool[sex][:PER_SEX]
        out = []
        for i in range(PER_SEX):                   # F, M, F, M = two pairs
            for sex in ("F", "M"):
                if i < len(picked[sex]): out.append(picked[sex][i])
        return out

**TRAP FOUR: the catalogue repeats display names.** There are two voices called
Dominic in en-US. Dedupe by lowercased name or the picker shows the same name
twice and the user cannot tell them apart.

Fetch once, pick for BOTH accents from that one fetch, and cache the result to
disk. Then switching accent costs no network at all, and the picker still
draws when there is no network.

### Caching the catalogue

    {"byAccent": {"uk": [...4 voices...], "us": [...4 voices...]},
     "at": 1786525062}

Give each chosen voice a stable on disk key, because clips cache per voice.

    def vkey(voice_id):
        return "sp_" + re.sub(r"[^A-Za-z0-9]", "", str(voice_id))[:40]

---

## 6. Security rules, non negotiable

1. Never print, log, echo or commit a key. Ever.
2. Never send a key back to the browser. The front end gets masks only.
3. The key file lives in the app folder, written `0600`, and never leaves the
   device.
4. The dead list stores fingerprints, never keys.
5. `.gitignore` must contain the key file name before the first commit.
6. When an installer wipes and reinstalls, **carry the key file out and put it
   back**. Making someone re-enter keys is how you teach them not to update.

---

## 7. YOUR APP, the two hooks

Everything above is portable. Only two things touch your app.

**Hook one, where audio and timings go.** In MA Reader each sentence becomes
its own immutable cached mp3 plus a JSON of tokens, so changing speed or a
pause never costs a synthesis. Adapt to whatever your cache looks like.

    def synth(text, voice_id, mp3_path, json_path):
        body, err = call("/v1/audio/speech", payload={
            "input": text, "voice_id": voice_id,
            "audio_format": "mp3", "model": "simba-english"})
        if body is None:
            return err
        audio = base64.b64decode(body.get("audio_data") or "")
        if not audio:
            return "no audio"
        open(mp3_path + ".part", "wb").write(audio)
        os.replace(mp3_path + ".part", mp3_path)
        tokens = to_tokens(text, body.get("speech_marks") or {})
        json.dump({"tokens": tokens, "engine": "speechify",
                   "total": max([t["d"] for t in tokens] or [0])},
                  open(json_path, "w", encoding="utf-8"), ensure_ascii=False)
        return ""

**Hook two, the settings surface.** Whatever your app's settings look like, it
needs: an accent switch, the four voices, a file picker for the key file, a
"test all keys" button, and the dead list with Retry and Remove.

---

## 8. Checklist for the next build

    [ ] catalogue walks next_cursor, not just page one
    [ ] key file parsed by shape, labels kept and shown
    [ ] no speculative testing at startup
    [ ] 401/403 condemns permanently, retries the same request on the next key
    [ ] 429 rests the key, never condemns
    [ ] network failure never blames the key
    [ ] dead list persists across restarts, stores fingerprints
    [ ] dead list visible in settings with Retry and Remove
    [ ] speech marks used as given, no waveform re-pinning
    [ ] display names deduped before filling the four seats
    [ ] keys survive an install or update
    [ ] key file 0600, in .gitignore, never printed
    [ ] model is simba-english, NOT simba-3.2, if the full catalogue is offered

---

## 9. Where this came from

Built and verified in the MA Reader Termux project, 12.8.2026.

    https://github.com/markoboskoauroville/ma-reader-thermux

Tested live with 21 keys: all 21 authenticated, pagination confirmed
50 -> 962, synthesis and speech mark alignment confirmed character exact,
mid session revocation confirmed to roll forward and still deliver the
sentence, quarantine confirmed to persist across restart, and exhaustion
confirmed to surface a clean error rather than crash.

Re-verified 12.8.2026 against the same account: 21 of 21 keys still working,
catalogue now 963 voices (33 en-GB, 82 en-US), which is a reminder that the
catalogue MOVES and must never be hard coded. Model behaviour measured, see
TRAP FIVE.
