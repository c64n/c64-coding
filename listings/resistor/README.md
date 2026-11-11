# RESISTOR

The resistor colour code, both ways: press the colours of the four bands and get the value with the range its tolerance allows, or type a value like `4.7k` and get the colours. The resistor is drawn on the screen and each band is painted as you go.

| | |
|---|---|
| Category | Utilities |
| Language | Commodore BASIC V2 |
| Length | 112 lines, 20 blocks (4,831 bytes) |
| Keys | <kbd>1</kbd>/<kbd>2</kbd> on the menu; digits and <kbd>G</kbd>, <kbd>S</kbd>, <kbd>N</kbd> for colours; INST/DEL and RETURN for a value; <kbd>Q</kbd> quits |
| Special keys | None |
| Article | [RESISTOR: The Colour Code, Both Ways](https://c64n.blogspot.com/2026/11/resistor-colour-code.html) |

## Files

- [`RESISTOR.bas`](RESISTOR.bas) – the listing, with a remark on most lines. Type every letter without SHIFT; the remarks after `:rem` can be left out.
- [`RESISTOR.prg`](RESISTOR.prg) – ready to run: drag it onto a VICE window.

## How it is built

| Lines | Block |
|---|---|
| 100–195 | Setup: one table of 14 colours (name, C64 colour, tolerance) and the 16 colour codes |
| 200–270 | Menu |
| 300–360 | Colours to value |
| 400–480 | Value to colours: two digits and a power of ten, gold and silver for 0.1 and 0.01 |
| 500–690 | Drawing: the screen, the resistor, one band, the bands in words |
| 700–745 | Wait for one of the allowed keys |
| 760–825 | The value of the bands, the tolerance range, numbers as `4.7K OHM` |
| 870–890 | Read a value with `GET`: digits, point, K/M/G, DEL, RETURN |
| 900–910 | Quit |

## Tested

| Input | Result |
|---|---|
| red violet orange gold | 27K OHM ±5%, 25.65K – 28.35K |
| brown black black silver | 10 OHM ±10%, 9 – 11 |
| brown black, silver multiplier, brown | 0.1 OHM ±1%, 0.099 – 0.101 |
| `4.7k` | yellow violet red |
| `4750` | 4.8K, "rounded to two digits" |
| `0.47` | yellow violet silver |
| `99g` | white white white |
| `100g`, `0.05`, `k` | out of range |
