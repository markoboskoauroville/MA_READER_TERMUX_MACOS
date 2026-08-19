#!/usr/bin/env python3
"""LABORATORY: does the Whisper method actually beat what we had?

The only honest way to answer this is to test against audio whose word times
are EXACTLY known. Speechify returns speech marks with its audio, so its own
rendition is the only ground truth available. Edge's marks cannot be checked
this way, because Speechify's marks describe Speechify's rendition and not
Edge's; a different voice says the same sentence differently.

So Speechify audio is the test subject. Its marks are the truth. Every
candidate method is then given nothing but the mp3 and the words, exactly as
it would be in the app, and asked where the words fall.

Candidates:
    proportional   divide the clip by word length          (layer 3)
    pcm2           the app's DSP refinement of a flat guess (what we had)
    whisper        groq word timestamps                     (layer 2)

Measured: absolute error of each word's START against the truth.
"""
import os, sys, json, base64, statistics, urllib.request, time

HOME = "/tmp/lab/home"
os.environ["HOME"] = HOME
sys.path.insert(0, "/home/claude/w")
import importlib.util as u
spec = u.spec_from_file_location("sc", "/home/claude/w/server_check.py")
M = u.module_from_spec(spec); spec.loader.exec_module(M)

SENTENCES = [
    "Wait, what? No, absolutely not; that is not what I said, and you know it.",
    "The quick brown fox jumps over the lazy dog beside the river bank.",
    "In 1947 about 3500 people arrived, roughly 12 percent of the total.",
    "She opened the window, listened for a moment, and then closed it again.",
    "Reading aloud is easy; timing the highlight to the voice is the hard part.",
    "He said the elements of water, earth, fire and air were all present.",
]


def speechify(text, voice="beatrice_32"):
    """Audio plus EXACT word marks. The ground truth."""
    body, err = M.sp_call("/v1/audio/speech", payload={
        "input": text, "voice_id": voice, "audio_format": "mp3",
        "model": "simba-english"}, timeout=120)
    if not body:
        return None, None, err
    audio = base64.b64decode(body.get("audio_data") or "")
    marks = body.get("speech_marks") or {}
    return audio, marks, ""


def truth_words(marks):
    """Flatten Speechify's mark tree into [(word, start_seconds)]."""
    out = []

    def walk(node):
        if isinstance(node, dict):
            if node.get("type") == "word" and node.get("start_time") is not None:
                out.append((str(node.get("value", "")),
                            float(node["start_time"]) / 1000.0))
            for ch in (node.get("chunks") or []):
                walk(ch)
        elif isinstance(node, list):
            for ch in node:
                walk(ch)
    walk(marks)
    return out


def method_proportional(words, total):
    n = sum(max(1, len(w)) for w in words)
    out, t = [], 0.0
    for w in words:
        d = max(1, len(w)) / n * total
        out.append(t); t += d
    return out


def method_pcm2(mp3, text, total):
    """What the app did before: a flat alignment refined against the waveform."""
    toks = M.align_tokens(text, [], total)
    ref, dur, changed = M.refine_tokens(mp3, toks)
    if changed:
        toks = ref
    return [t.get("t", 0.0) for t in toks]


def method_whisper(mp3, words, total):
    heard = M.wt_fetch(mp3, language="en")
    if not heard:
        return None, "no answer"
    t = M.wt_times(heard, words, total)
    if not t:
        return None, "no mapping"
    if not M.wt_sane(heard, words, t, total):
        return None, "refused by the gate"
    return [a for a, _ in t], ""


def errs(got, truth):
    return [abs(g - t) for g, t in zip(got, truth)]


def report(name, e):
    if not e:
        print("  %-14s no result" % name); return None
    s = sorted(e)
    p90 = s[min(len(s) - 1, int(len(s) * 0.9))]
    print("  %-14s mean %5.0f ms   median %5.0f ms   p90 %5.0f ms   "
          "within 50ms %3.0f%%   within 100ms %3.0f%%"
          % (name, 1000 * statistics.fmean(e), 1000 * statistics.median(e),
             1000 * p90,
             100 * sum(1 for x in e if x <= 0.05) / len(e),
             100 * sum(1 for x in e if x <= 0.10) / len(e)))
    return statistics.fmean(e)


def main():
    allerr = {"proportional": [], "pcm2": [], "whisper": []}
    nwords = 0
    refused = 0
    for si, text in enumerate(SENTENCES):
        audio, marks, err = speechify(text)
        if not audio:
            print("  sentence %d: Speechify failed (%s)" % (si, err)); continue
        mp3 = "/tmp/lab/s%d.mp3" % si
        open(mp3, "wb").write(audio)
        tw = truth_words(marks)
        if len(tw) < 4:
            print("  sentence %d: only %d marks, skipped" % (si, len(tw))); continue
        words = [w for w, _ in tw]
        truth = [t for _, t in tw]
        total = M.mp3_duration(mp3) if hasattr(M, "mp3_duration") else truth[-1] + 0.6

        p = method_proportional(words, total)
        d = method_pcm2(mp3, text, total)
        w, werr = method_whisper(mp3, words, total)

        n = min(len(truth), len(p), len(d))
        allerr["proportional"] += errs(p[:n], truth[:n])
        allerr["pcm2"] += errs(d[:n], truth[:n])
        if w and len(w) >= n:
            allerr["whisper"] += errs(w[:n], truth[:n])
        else:
            refused += 1
        nwords += n
        print("  sentence %d: %2d words, %.2fs%s"
              % (si, n, total, ("   whisper: " + werr) if werr else ""))
    print()
    print("  GROUND TRUTH: Speechify speech marks, %d words over %d sentences"
          % (nwords, len(SENTENCES)))
    print()
    best = {}
    for k in ("proportional", "pcm2", "whisper"):
        m = report(k, allerr[k])
        if m is not None:
            best[k] = m
    if refused:
        print("\n  whisper refused by the gate on %d sentence(s)" % refused)
    if best:
        win = min(best, key=best.get)
        print("\n  BEST: %s" % win)
    json.dump({k: v for k, v in allerr.items()},
              open("/tmp/lab/errors.json", "w"))


if __name__ == "__main__":
    main()
