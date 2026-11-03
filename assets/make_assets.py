"""Generate the C64N brand assets (avatar, social preview, README banner).

Pure Python + Pillow. The 5x7 pixel font below is drawn for this project.
Run:  python assets/make_assets.py
"""
from pathlib import Path
from PIL import Image, ImageDraw

OUT = Path(__file__).resolve().parent

# C64-style palette (same values as the Blogger theme)
BORDER = (0x70, 0x6D, 0xEB)
SCREEN = (0x2E, 0x2C, 0x9B)
TEXT = (0xA7, 0xA4, 0xFF)
WHITE = (0xFF, 0xFF, 0xFF)
YELLOW = (0xED, 0xF1, 0x71)
GREEN = (0xA9, 0xFF, 0x9F)
CYAN = (0x75, 0xCE, 0xC8)
PINK = (0xC4, 0x6C, 0x71)
RASTER = [YELLOW, GREEN, CYAN, WHITE, CYAN, GREEN, YELLOW]  # one colour per glyph row

F = {
    'A': ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
    'B': ["11110", "10001", "10001", "11110", "10001", "10001", "11110"],
    'C': ["01110", "10001", "10000", "10000", "10000", "10001", "01110"],
    'D': ["11110", "10001", "10001", "10001", "10001", "10001", "11110"],
    'E': ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
    'F': ["11111", "10000", "10000", "11110", "10000", "10000", "10000"],
    'G': ["01110", "10001", "10000", "10111", "10001", "10001", "01111"],
    'H': ["10001", "10001", "10001", "11111", "10001", "10001", "10001"],
    'I': ["01110", "00100", "00100", "00100", "00100", "00100", "01110"],
    'J': ["00111", "00010", "00010", "00010", "00010", "10010", "01100"],
    'K': ["10001", "10010", "10100", "11000", "10100", "10010", "10001"],
    'L': ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
    'M': ["10001", "11011", "10101", "10101", "10001", "10001", "10001"],
    'N': ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
    'O': ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
    'P': ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
    'Q': ["01110", "10001", "10001", "10001", "10101", "10010", "01101"],
    'R': ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
    'S': ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
    'T': ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
    'U': ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
    'V': ["10001", "10001", "10001", "10001", "10001", "01010", "00100"],
    'W': ["10001", "10001", "10001", "10101", "10101", "10101", "01010"],
    'X': ["10001", "10001", "01010", "00100", "01010", "10001", "10001"],
    'Y': ["10001", "10001", "01010", "00100", "00100", "00100", "00100"],
    'Z': ["11111", "00001", "00010", "00100", "01000", "10000", "11111"],
    '0': ["01110", "10001", "10011", "10101", "11001", "10001", "01110"],
    '1': ["00100", "01100", "00100", "00100", "00100", "00100", "01110"],
    '2': ["01110", "10001", "00001", "00010", "00100", "01000", "11111"],
    '3': ["11110", "00001", "00001", "01110", "00001", "00001", "11110"],
    '4': ["00010", "00110", "01010", "10010", "11111", "00010", "00010"],
    '5': ["11111", "10000", "11110", "00001", "00001", "10001", "01110"],
    '6': ["00110", "01000", "10000", "11110", "10001", "10001", "01110"],
    '7': ["11111", "00001", "00010", "00100", "01000", "01000", "01000"],
    '8': ["01110", "10001", "10001", "01110", "10001", "10001", "01110"],
    '9': ["01110", "10001", "10001", "01111", "00001", "00010", "01100"],
    '.': ["00000", "00000", "00000", "00000", "00000", "01100", "01100"],
    ',': ["00000", "00000", "00000", "00000", "01100", "00100", "01000"],
    '"': ["01010", "01010", "00000", "00000", "00000", "00000", "00000"],
    '$': ["00100", "01111", "10100", "01110", "00101", "11110", "00100"],
    '-': ["00000", "00000", "00000", "11111", "00000", "00000", "00000"],
    '*': ["00000", "10101", "01110", "11111", "01110", "10101", "00000"],
    ':': ["00000", "01100", "01100", "00000", "01100", "01100", "00000"],
    '/': ["00001", "00010", "00010", "00100", "01000", "01000", "10000"],
    '#': ["01010", "11111", "01010", "01010", "01010", "11111", "01010"],
    ' ': ["00000"] * 7,
    '_': ["11111"] * 7,  # block cursor
}
CW, CH = 8, 8  # character cell, like the C64 (5x7 glyph inside an 8x8 cell)


def text_cells(s):
    """Yield (col, row, colour-row-index) for every lit pixel of s, in cell units of 1px."""
    for i, ch in enumerate(s.upper()):
        g = F.get(ch, F[' '])
        for y, row in enumerate(g):
            for x, bit in enumerate(row):
                if bit == '1':
                    yield i * CW + x + 1, y, y


def draw_text(d, s, x0, y0, px, colour, shadow=None):
    for x, y, ry in text_cells(s):
        c = colour[ry] if isinstance(colour, list) else colour
        if shadow:
            d.rectangle([x0 + (x + 1) * px, y0 + (y + 1) * px, x0 + (x + 2) * px - 1, y0 + (y + 2) * px - 1], fill=shadow)
        d.rectangle([x0 + x * px, y0 + y * px, x0 + (x + 1) * px - 1, y0 + (y + 1) * px - 1], fill=c)


def width(s, px):
    return len(s) * CW * px


def scanlines(img, alpha=26):
    over = Image.new('RGBA', img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(over)
    for y in range(2, img.size[1], 3):
        d.line([(0, y), (img.size[0], y)], fill=(0, 0, 0, alpha))
    return Image.alpha_composite(img.convert('RGBA'), over).convert('RGB')


def avatar(size=512):
    img = Image.new('RGB', (size, size), BORDER)
    d = ImageDraw.Draw(img)
    m = 40
    d.rectangle([m, m, size - m - 1, size - m - 1], fill=SCREEN)
    px = 14
    s = 'C64N'
    draw_text(d, s, (size - width(s, px)) // 2, 150, px, RASTER, shadow=(0x16, 0x15, 0x55))
    px2 = 6
    draw_text(d, 'READY.', m + 30, 330, px2, TEXT)
    draw_text(d, '_', m + 30, 330 + CH * px2 + 6, px2, TEXT)
    return scanlines(img)


def social(w=1280, h=640):
    img = Image.new('RGB', (w, h), BORDER)
    d = ImageDraw.Draw(img)
    m = 48
    d.rectangle([m, m, w - m - 1, h - m - 1], fill=SCREEN)
    x = m + 56
    px = 4
    px = 3
    draw_text(d, '    **** C64N TYPE-IN LISTINGS ****', x, m + 44, px, TEXT)
    draw_text(d, ' 64K RAM SYSTEM  38911 BASIC BYTES FREE', x, m + 44 + 14 * px, px, TEXT)
    draw_text(d, 'READY.', x, m + 44 + 28 * px, px, TEXT)
    big = 11
    draw_text(d, 'C64 CODING', x, 300, big, RASTER, shadow=(0x16, 0x15, 0x55))
    draw_text(d, 'ORIGINAL BASIC TYPE-IN LISTINGS', x, 420, 4, YELLOW)
    draw_text(d, 'C64N.BLOGSPOT.COM  GITHUB.COM/C64N', x, 470, 4, CYAN)
    draw_text(d, '_', x, 520, 4, TEXT)
    return scanlines(img)


def banner_svg(w_cells=48, h_cells=15):
    """README banner as crisp SVG rects (scales to any width)."""
    px = 2
    W, H = w_cells * CW * px, h_cells * CH * px
    rects = []

    LH = 22  # line pitch in px for the small boot text

    def put(s, cx, y0, colour, scale=1):
        for x, y, ry in text_cells(s):
            c = colour[ry] if isinstance(colour, list) else colour
            rects.append((cx * CW * px + x * px * scale, y0 + y * px * scale, px * scale, px * scale, c))

    put('    **** C64N TYPE-IN LISTINGS ****', 2, 18, TEXT)
    put(' 64K RAM SYSTEM  38911 BASIC BYTES FREE', 2, 18 + LH, TEXT)
    put('READY.', 2, 18 + 2 * LH, TEXT)
    put('LOAD"C64 CODING",8,1', 2, 18 + 3 * LH, TEXT)
    for (sx, sy), col in [((4, 4), (0x16, 0x15, 0x55)), ((0, 0), RASTER)]:
        for x, y, ry in text_cells('C64 CODING'):
            c = col[ry] if isinstance(col, list) else col
            s = 4
            rects.append((2 * CW * px + x * px * s + sx, 18 + 5 * LH + y * px * s + sy, px * s, px * s, c))
    put('READY.', 2, 18 + 5 * LH + 7 * px * 4 + 26, TEXT)
    put('_', 2, 18 + 6 * LH + 7 * px * 4 + 26, TEXT)

    def hx(c):
        return '#%02x%02x%02x' % c
    body = ''.join(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{hx(c)}"/>' for x, y, w, h, c in rects)
    b = 24
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W + 2 * b} {H + 2 * b}" width="{W + 2 * b}" height="{H + 2 * b}" '
            f'shape-rendering="crispEdges" role="img" aria-label="C64 Coding: original BASIC type-in listings for the Commodore 64">'
            f'<rect width="100%" height="100%" fill="{hx(BORDER)}"/>'
            f'<g transform="translate({b},{b})"><rect width="{W}" height="{H}" fill="{hx(SCREEN)}"/>{body}</g></svg>')


def youtube_banner(w=2560, h=1440):
    """YouTube channel art: everything important stays inside the 1546x423 centre safe area."""
    img = Image.new('RGB', (w, h), BORDER)
    d = ImageDraw.Draw(img)
    sx, sy, sw, sh = (w - 1546) // 2, (h - 423) // 2, 1546, 423
    m = 150
    d.rectangle([m, m, w - m - 1, h - m - 1], fill=SCREEN)
    px = 4
    boot = ['    **** C64N TYPE-IN LISTINGS ****', ' 64K RAM SYSTEM  38911 BASIC BYTES FREE', 'READY.']
    for i, t in enumerate(boot):
        draw_text(d, t, m + 120, m + 110 + i * 14 * px, px, TEXT)
    big = 16
    title = 'C64 CODING'
    draw_text(d, title, (w - width(title, big)) // 2, sy + 40, big, RASTER, shadow=(0x16, 0x15, 0x55))
    sub = 'ORIGINAL BASIC TYPE-IN LISTINGS'
    draw_text(d, sub, (w - width(sub, 5)) // 2, sy + 40 + 8 * big + 40, 5, YELLOW)
    url = 'C64N.BLOGSPOT.COM'
    draw_text(d, url, (w - width(url, 5)) // 2, sy + 40 + 8 * big + 40 + 70, 5, CYAN)
    draw_text(d, 'RUN', m + 120, h - m - 200, px, TEXT)
    draw_text(d, '_', m + 120, h - m - 200 + 14 * px, px, TEXT)
    return scanlines(img)


def kofi_cover(w=1500, h=500):
    """Ko-fi cover: everything in the middle band, since Ko-fi crops top and bottom."""
    img = Image.new('RGB', (w, h), BORDER)
    d = ImageDraw.Draw(img)
    mx = 60
    d.rectangle([mx, 0, w - mx - 1, h - 1], fill=SCREEN)
    big = 13
    t = 'C64 CODING'
    draw_text(d, t, (w - width(t, big)) // 2, 120, big, RASTER, shadow=(0x16, 0x15, 0x55))
    sub = 'ORIGINAL BASIC TYPE-IN LISTINGS'
    draw_text(d, sub, (w - width(sub, 5)) // 2, 120 + 8 * big + 36, 5, YELLOW)
    url = 'C64N.BLOGSPOT.COM'
    draw_text(d, url, (w - width(url, 5)) // 2, 120 + 8 * big + 36 + 56, 5, CYAN)
    return scanlines(img)


if __name__ == '__main__':
    avatar().save(OUT / 'avatar.png', optimize=True)
    social().save(OUT / 'social-preview.png', optimize=True)
    (OUT / 'banner.svg').write_text(banner_svg(), encoding='utf-8')
    youtube_banner().save(OUT / 'youtube-banner.png', optimize=True)
    avatar(800).save(OUT / 'youtube-avatar.png', optimize=True)
    kofi_cover().save(OUT / 'kofi-cover.png', optimize=True)
    print('written:', ', '.join(p.name for p in sorted(OUT.glob('*')) if p.suffix in ('.png', '.svg')))
