"""Turn a machine-code .prg into a BASIC loader of DATA lines, 12 bytes and a checksum per line.

    python make_loader.py dodge-c000.prg DODGE.bas
"""
import sys

src, out = sys.argv[1], sys.argv[2]
data = open(src, 'rb').read()
start = data[0] | data[1] << 8
code = list(data[2:])
code += [0] * (-len(code) % 12)          # fill the last line

lines = [
    '10 rem dodge - loader for the machine code',
    '20 rem c64 coding - c64n.blogspot.com',
    '30 rem',
    f'100 a={start}:l=1000:rem start address, first data line',
    '110 print chr$(147);"poking the code..."',
    '120 read b:if b<0 then 200:rem -1 marks the end',
    '130 c=b:poke a,b:a=a+1:rem twelve numbers per line...',
    '140 for i=2 to 12:read b:poke a,b:a=a+1:c=c+b:next',
    '150 read s:if s<>c then print "?checksum error in line";l:end',
    '160 l=l+10:goto 120:rem ...and their sum',
    f'200 print "ok. sys {start} to play":sys {start}',
]
n = 1000
for i in range(0, len(code), 12):
    row = code[i:i + 12]
    lines.append(f'{n} data ' + ','.join(map(str, row)) + f',{sum(row)}')
    n += 10
lines.append(f'{n} data -1')
open(out, 'w').write('\n'.join(lines) + '\n')
print(f'{len(data) - 2} bytes, {len(code) // 12} data lines, last line {n}')
