10 rem zaria - three dice for the c64
20 rem c64 coding - c64n.blogspot.com
30 rem
100 r=rnd(-ti):poke 53280,5:poke 53281,0:print chr$(147);chr$(5)
110 s=54272:for i=0 to 24:poke s+i,0:next
120 poke s+24,15:poke s+5,9:poke s+6,0
130 rv$=chr$(18):ro$=chr$(146):pp$=chr$(113)
140 dn$="":for i=1 to 24:dn$=dn$+chr$(17):next
150 dim f$(6),d$(6):for i=1 to 6:read f$(i):next
160 data "000010000","100000001","100010001"
170 data "101000101","101010101","101101101"
180 gosub 600
200 rem title and prompt
210 print chr$(158);tab(15);"z a r i a":print
220 print chr$(5);tab(9);"three dice for the c64"
230 r=8:th=0
240 print chr$(19);left$(dn$,21);tab(5);chr$(153);
250 print "press a key to roll, q to quit"
300 rem wait for a key
310 get k$:if k$="" then 310
320 if k$="q" then 900
330 rem tumble: eight quick throws, slowing down
340 for t=1 to 8
350 d1=int(rnd(1)*6)+1:d2=int(rnd(1)*6)+1:d3=int(rnd(1)*6)+1
360 v=d1:c=8:gosub 500:v=d2:c=17:gosub 500:v=d3:c=26:gosub 500
370 poke s+4,128:poke s+1,10+t*4:poke s+4,129
380 for w=1 to t*25:next
390 next t
400 rem result
410 th=th+1:sm=d1+d2+d3:m$=""
420 if d1=d2 or d2=d3 or d1=d3 then m$="double!"
430 if d1=d2 and d2=d3 then m$="triple!"
440 print chr$(19);left$(dn$,15);tab(8);chr$(5);"total";sm;
450 print "   ";chr$(158);m$;"        "
460 print chr$(19);left$(dn$,17);tab(8);chr$(152);"throw";th
470 goto 310
500 rem draw die v with its left edge at column c, top at row r
510 print chr$(19);left$(dn$,r);tab(c);d$(v):return
600 rem build each face as one string: 5 rows of 5 cells
610 nl$=chr$(17):for i=1 to 5:nl$=nl$+chr$(157):next
620 for v=1 to 6:b$=chr$(5)+rv$+"     "+nl$
630 for y=1 to 3:b$=b$+" "
640 for x=1 to 3:if mid$(f$(v),y*3-3+x,1)="1" then b$=b$+pp$:goto 660
650 b$=b$+" "
660 next x:b$=b$+" "+nl$:next y
670 d$(v)=b$+"     "+ro$:next v:return
900 rem quit: sound off, colours back
910 poke s+24,0:poke 53280,14:poke 53281,6
920 print chr$(147);chr$(154);"thanks for rolling!":end
