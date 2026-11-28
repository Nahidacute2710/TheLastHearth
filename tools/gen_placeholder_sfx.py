"""Generates the placeholder sound effects for The Last Hearth (VS-A).

Usage (from the repo root):  python tools/gen_placeholder_sfx.py
Writes 16-bit mono WAV files to the-last-hearth/assets/audio/sfx/sfx_<id>_placeholder.wav.
Only the Python standard library is used. Output is deterministic (fixed random seed).
These are placeholders: replace them with licensed sounds by pointing data/audio/sfx_library.tres
at the new files (no code change needed).
"""
import math
import os
import random
import struct
import wave

RATE = 22050
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "the-last-hearth", "assets", "audio", "sfx")


def envelope(t, length, attack=0.005, release=None):
    release = release if release is not None else length * 0.6
    if t < attack:
        return t / attack
    if t > length - release:
        return max(0.0, (length - t) / release)
    return 1.0


def render(length, sample):
    return [sample(i / RATE) for i in range(int(length * RATE))]


def noise(rng):
    return rng.uniform(-1.0, 1.0)


def lowpass(samples, amount):
    out, last = [], 0.0
    for s in samples:
        last += amount * (s - last)
        out.append(last)
    return out


def swing(rng):
    length = 0.14
    raw = render(length, lambda t: noise(rng))
    # Sweeping low-pass: the whoosh gets brighter, then fades.
    out, last = [], 0.0
    for i, s in enumerate(raw):
        t = i / RATE
        amount = 0.05 + 0.5 * (t / length)
        last += amount * (s - last)
        out.append(last * envelope(t, length, 0.02, 0.08) * 0.9)
    return out


def hit(rng):
    length = 0.11
    return [
        (0.8 * math.sin(2 * math.pi * (140 - 500 * t) * t) + 0.5 * noise(rng) * math.exp(-t * 60))
        * envelope(t, length, 0.002, 0.08) * 0.8
        for t in (i / RATE for i in range(int(length * RATE)))
    ]


def enemy_windup(rng):
    # Low, growling square wave rising in pitch with a fast tremolo: nothing else sounds like it.
    length = 0.5
    out, phase = [], 0.0
    for i in range(int(length * RATE)):
        t = i / RATE
        freq = 70 + 160 * (t / length) ** 1.5
        phase += freq / RATE
        square = 1.0 if (phase % 1.0) < 0.5 else -1.0
        tremolo = 0.6 + 0.4 * math.sin(2 * math.pi * 18 * t)
        out.append(square * tremolo * envelope(t, length, 0.03, 0.06) * 0.45)
    return lowpass(out, 0.35)


def dodge(rng):
    length = 0.16
    raw = render(length, lambda t: noise(rng))
    out, last = [], 0.0
    for i, s in enumerate(raw):
        t = i / RATE
        amount = 0.45 - 0.4 * (t / length)
        last += amount * (s - last)
        out.append(last * envelope(t, length, 0.01, 0.1) * 0.7)
    return out


def tone(freq, t, kind="sine"):
    if kind == "square":
        return 1.0 if math.sin(2 * math.pi * freq * t) >= 0 else -1.0
    return math.sin(2 * math.pi * freq * t)


def notes(seq, kind="sine", volume=0.5, decay=8.0):
    out = []
    for freq, length in seq:
        for i in range(int(length * RATE)):
            t = i / RATE
            out.append(tone(freq, t, kind) * math.exp(-t * decay) * envelope(t, length, 0.003, 0.02) * volume)
    return out


def pickup(rng):
    return notes([(660, 0.06), (990, 0.08)], kind="square", volume=0.25, decay=12.0)


def cook_done(rng):
    return notes([(523, 0.14), (659, 0.14), (784, 0.3)], volume=0.55, decay=5.0)


def coin(rng):
    return notes([(1319, 0.06), (1760, 0.16)], kind="square", volume=0.22, decay=10.0)


def ui_click(rng):
    length = 0.03
    return [tone(1800, t) * math.exp(-t * 200) * 0.4 for t in (i / RATE for i in range(int(length * RATE)))]


SOUNDS = {
    "swing": swing,
    "hit": hit,
    "enemy_windup": enemy_windup,
    "dodge": dodge,
    "pickup": pickup,
    "cook_done": cook_done,
    "coin": coin,
    "ui_click": ui_click,
}


def write(path, samples):
    with wave.open(path, "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(RATE)
        out.writeframes(b"".join(struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32767)) for s in samples))


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for sound_id, make in SOUNDS.items():
        path = os.path.join(OUT_DIR, "sfx_%s_placeholder.wav" % sound_id)
        write(path, make(random.Random(sound_id)))
        print("wrote", os.path.normpath(path))


if __name__ == "__main__":
    main()
