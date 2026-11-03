"""YouTube thumbnail: a VICE frame on the left, the program name in the site's pixel font on the right.
Usage: python make_thumbnail.py FRAME.png NAME "LINE 1" "LINE 2" OUT.png
"""
import sys
from PIL import Image, ImageDraw
from make_assets import BORDER, SCREEN, TEXT, YELLOW, CYAN, RASTER, draw_text, width, scanlines

def thumbnail(frame, name, l1, l2, out, w=1280, h=720):
    img = Image.new('RGB', (w, h), BORDER)
    d = ImageDraw.Draw(img)
    m = 28
    d.rectangle([m, m, w - m - 1, h - m - 1], fill=SCREEN)
    shot = Image.open(frame).convert('RGB')
    sh = h - 2 * m - 40
    sw = round(shot.width * sh / shot.height)
    # a long name needs a wider right column: make the screenshot smaller
    need = width(name, 7) + 70
    most = w - 2 * m - 20 - 44 - need
    if sw > most:
        sw = most
        sh = round(shot.height * sw / shot.width)
    shot = shot.resize((sw, sh), Image.LANCZOS)
    top = m + 20 + (h - 2 * m - 40 - sh) // 2
    img.paste(shot, (m + 20, top))
    d.rectangle([m + 20 - 4, top - 4, m + 20 + sw + 3, top + sh + 3], outline=(0, 0, 0), width=4)
    x = m + 20 + sw + 44
    room = w - m - 24 - x
    big = 16
    while width(name, big) > room and big > 6:
        big -= 1
    draw_text(d, name, x, 150, big, RASTER, shadow=(0x16, 0x15, 0x55))
    px = 4
    for s in (l1, l2):
        while width(s, px) > room and px > 2:
            px -= 1
    draw_text(d, l1, x, 150 + 8 * big + 50, px, YELLOW)
    draw_text(d, l2, x, 150 + 8 * big + 50 + 12 * px, px, YELLOW)
    fp = 5
    while width('C64 CODING', fp) > room and fp > 2:
        fp -= 1
    draw_text(d, 'C64 CODING', x, h - m - 120, fp, CYAN)
    draw_text(d, 'READY.', x, h - m - 70, 3, TEXT)
    scanlines(img).save(out)

if __name__ == '__main__':
    thumbnail(*sys.argv[1:6])
