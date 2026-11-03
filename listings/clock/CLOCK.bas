10 rem clock - big digits and an alarm
20 rem c64 coding - c64n.blogspot.com
30 rem
100 rem ---- setup ----
110 poke 53280,0:poke 53281,0:rem black border, black screen
120 rv$=chr$(18):ro$=chr$(146):bk$=rv$+" "+ro$:rem rvs on/off, a block
130 dn$="":for i=1 to 24:dn$=dn$+chr$(17):next:rem 24 cursor downs
140 nl$=chr$(17)+chr$(157)+chr$(157)+chr$(157):rem down, 3 lefts
150 sd=54272:for i=0 to 24:poke sd+i,0:next:rem silence the sid
160 poke sd+24,15:poke sd+1,40:poke sd+5,9:rem volume, pitch, decay
170 dim g$(9),x(6):for i=1 to 6:read x(i):next:rem digit columns
180 r=8:gosub 700:rem top row of the digits; build them
190 data 6,10,16,20,26,30
200 rem ---- ask for the time ----
210 print chr$(147);chr$(158);tab(14);"c l o c k":print:print chr$(5)
220 input "  hours   (0-23)";h:if h<0 or h>23 or h<>int(h) then 220
230 input "  minutes (0-59)";m:if m<0 or m>59 or m<>int(m) then 230
240 input "  seconds (0-59)";s:if s<0 or s>59 or s<>int(s) then 240
250 al$="":print:print "  set an alarm (y/n)?"
260 get k$:if k$="" then 260
270 if k$<>"y" then 310
280 input "  alarm hours   (0-23)";a:if a<0 or a>23 or a<>int(a) then 280
290 v=a:gosub 800:al$=v$:rem alarm hours, two digits
300 input "  alarm minutes (0-59)";a:if a<0 or a>59 or a<>int(a) then 300
305 v=a:gosub 800:a$=al$+":"+v$:al$=al$+v$:rem al$="hhmm"
310 v=h:gosub 800:t$=v$:v=m:gosub 800:t$=t$+v$
320 v=s:gosub 800:ti$=t$+v$:rem set the clock: ti$="hhmmss"
400 rem ---- the clock screen ----
410 print chr$(147);chr$(158);tab(14);"c l o c k"
420 if al$="" then 440
430 print chr$(19);left$(dn$,16);tab(14);chr$(158);"alarm ";a$
440 print chr$(19);left$(dn$,20);tab(15);chr$(152);"q to quit"
450 o$="------":ra=0:rem no digits on screen yet, alarm not ringing
500 rem ---- main loop ----
510 get k$:if k$="q" then 900
520 if k$<>"" and ra then ra=0:gosub 650:rem any key stops the alarm
530 t$=ti$:if t$=o$ then 510:rem wait for the next second
540 for i=1 to 6:d$=mid$(t$,i,1):rem draw only the digits that changed
550 if d$<>mid$(o$,i,1) then print chr$(19);left$(dn$,r);tab(x(i));g$(val(d$))
560 next i:o$=t$
570 c$=" ":if (val(right$(t$,1)) and 1)=0 then c$=bk$:rem blink
580 for y=r+1 to r+3 step 2:print chr$(19);left$(dn$,y);tab(14);c$;tab(24);c$
585 next y
590 if al$<>"" and left$(t$,4)=al$ then al$="":ra=1:rem alarm time!
600 if ra then gosub 620
610 goto 510
620 rem ---- ring: a beep and a flashing message ----
630 poke sd+4,16:poke sd+4,17:rem gate off and on: a new beep
640 print chr$(19);left$(dn$,16);tab(13);chr$(28);c$;" wake up! ";c$:return
650 rem ---- alarm off: silence and clear the message ----
660 poke sd+4,16:print chr$(19);left$(dn$,16);tab(13);"            ":return
700 rem ---- build g$(0)-g$(9): 5 rows of 3 cells ----
710 for d=0 to 9:read p$:b$=chr$(159):rem cyan
720 for y=0 to 4:for x=1 to 3:if mid$(p$,y*3+x,1)="1" then b$=b$+bk$:goto 740
730 b$=b$+" "
740 next x:b$=b$+nl$:next y
750 g$(d)=b$:next d:return
760 data "111101101101111","010110010010111","111001111100111"
770 data "111001111001111","101101111001001","111100111001111"
780 data "111100111101111","111001001001001","111101111101111"
790 data "111101111001111"
800 rem ---- v$ = v as two digits: 7 -> "07" ----
810 v$=right$(str$(v+100),2):return
900 rem ---- quit ----
910 poke sd+24,0:poke 53280,14:poke 53281,6:rem sound off, colours back
920 print chr$(147);chr$(154);"bye!":end
