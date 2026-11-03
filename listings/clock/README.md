# CLOCK

A digital clock for the Commodore 64: big digits made of reverse-video blocks, a colon that blinks every second, and an alarm that beeps and flashes until you press a key. The time itself comes from `TI$`, the clock the C64 keeps by itself.

| | |
|---|---|
| Category | Utilities |
| Language | Commodore BASIC V2 |
| Length | 66 lines, 12 blocks (2,807 bytes) |
| Keys | Numbers and RETURN to set it; <kbd>Y</kbd>/<kbd>N</kbd> for the alarm; any key stops the alarm; <kbd>Q</kbd> quits |
| Special keys | None |
| Article | [CLOCK: A Digital Clock with Big Digits and an Alarm](https://c64n.blogspot.com/2026/11/digital-clock.html) |

## Files

- [`CLOCK.bas`](CLOCK.bas) – the listing, with a remark on most lines. Type every letter without SHIFT; the remarks after `:rem` can be left out.
- [`CLOCK.prg`](CLOCK.prg) – ready to run: drag it onto a VICE window.

## How it is built

| Lines | Block |
|---|---|
| 100–190 | Setup: colours, control codes, the SID, the digit positions |
| 200–320 | Ask for the time and the alarm, then set `TI$` |
| 400–450 | Draw the clock screen |
| 500–610 | Main loop: wait for a new second, redraw only the digits that changed, blink, check the alarm |
| 620–660 | Subroutines: ring the alarm, stop it |
| 700–790 | Subroutine, run once: build the ten 3×5 digits as strings |
| 800–810 | Subroutine: a number as two digits (`RIGHT$(STR$(V+100),2)`) |
| 900–920 | Quit: sound off, colours back |
