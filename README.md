# MA Reader Termux — Edge / Speechify

A browser reader for Termux that speaks any text aloud and lights up each word
as it is spoken. One file installs the whole thing.

### Install once

```bash
pkg install curl
curl -fsSL -O https://raw.githubusercontent.com/markoboskoauroville/ma-reader-thermux/main/update.sh
bash update.sh
```

That leaves behind one command. From then on, updating is one word:

```bash
maread-update            # fetch the newest version and install it
maread-update --online   # also refresh python / flask / edge-tts
maread-update --remove   # take the app off, keep the library
mareadweb                # run it
```

Installing is a **wipe, not an overwrite**. Any server still running is
stopped first, because a live Flask keeps serving the old page out of memory
and makes an update look like it did nothing. Then your keys and settings are
carried out, the whole app folder is deleted, a fresh one is written, and the
keys are put back. You never type a key twice. The library at `~/.maread`,
where your texts and clips live, is never touched.

No GitHub login is needed for any of this — the repository is public, so the
download is anonymous and no token is ever stored on the phone. The updater
refuses to install a truncated or wrong-shaped download, so a dropped
connection leaves the working copy alone.

Nothing new is required beyond what v26 already needed — Python, Flask,
edge-tts, ffmpeg. The entire Speechify side is standard library.

## v3

**Three controls on the player.** The two pauses sit together on the left,
because they are the same idea at two scales. Play is in the middle. Speed is
alone on the right. The right-hand stepper used to say WORDS and did not really
work; it says SPEED now, and the sentence pause has come out of Settings onto
the bar where it belongs.

**The pause between words is an actual pause.** The old one changed playback
rate to race through the quiet the voice leaves between words, and every rate
change was audible — clicks on the joins, chirping consonants, and on several
Android webviews the audio muted outright below about a quarter speed. Rate is
no longer touched anywhere on that path. The server measures once per clip
exactly where each between-word silence falls, trimmed inward 18 ms at both
ends so its edges are certainly quiet, and the player stops the mp3 inside one,
waits, and starts it again. A pause inside silence cannot be heard. It runs
0.00–2.00 s and no lower, because lengthening a silence is free while
shortening one would mean cutting audio.

**Two engines**, chosen by two buttons at the top of Settings; the cards below
follow whichever is picked.

| | Edge | Speechify |
|---|---|---|
| cost | free, keyless | keyed |
| languages | 13, two voices each | English only (UK / US) |
| word timing | engine guesses, so every clip is decoded and re-pinned to the waveform | speech marks land exactly on the source characters — used as given |

Speechify has no Croatian or other Slavic voice, so that engine offers the two
English accents and nothing else. Picking one fills the four seats at the top
of the reader, two female and two male, in pairs. Four is the whole picker.

The catalogue is fetched by walking the pagination cursor to the end rather
than reading the first page — `/v1/voices` defaults to fifty, and fifty
alphabetically is all A-names, which is one British voice out of the
thirty-three that are really there.

## The key ring

One file, one key per line, with a name above each saying whose it is. Anything
that is not `sk_` followed by a long tail is read as a label, so a heading or a
note is never mistaken for a credential.

**Nothing is tested in advance.** The obvious ring tests every key at startup
and picks a winner, which with twenty keys spends twenty round trips to learn
what it could have learned by trying. This one takes the first key not already
known to be dead and uses it. Only when a real request returns 401/403 is that
key condemned — written to a dead list on disk, permanently — and only then
does the ring roll forward and repeat the sentence that failed.

> A dead key costs one wasted request in its whole life. A healthy ring costs
> none at all.

The dead list survives restarts, so a revoked key is never paid for twice.
Settings shows it, named and dated, with two ways out: **Retry**, which clears
the mark in case an account was only suspended, and **Remove**, which strikes
the key out of the file for good.

429 is not condemnation — a throttled key is valid, so it is stood down for a
few minutes rather than discarded, and a key is never blamed for the network
being down.

### On secrets

Keys are never printed, never logged, and never returned to the browser. Only
the first six and last four characters are ever shown. The dead list stores a
SHA-256 fingerprint instead of the key, so that file can be read by anyone and
gives up nothing. The key file itself is written `0600` inside the app folder
and never leaves the device. `.gitignore` keeps all of it out of this repo.

## Library

Texts and their per-sentence clips live in `~/.maread`, shared with the
terminal MA Reader. Clips are immutable and cached per voice, so changing a
pause or the speed never costs a synthesis.

## Reusing the Speechify engine elsewhere

The key ring, the pagination fix, the voice picker and the speech-mark handling
are written up as a portable handoff, so any other project can be told to build
the same engine:

[`1md_speechify_engine_handoff_[ENG].md`](1md_speechify_engine_handoff_%5BENG%5D.md)

Everything in it was verified against the live API rather than read from
documentation, and each trap that cost a bug is recorded beside the fact.
