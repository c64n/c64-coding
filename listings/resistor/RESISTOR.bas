10 rem resistor - colour code to value and back
20 rem c64 coding - c64n.blogspot.com
30 rem
100 rem ---- setup ----
110 poke 53280,0:poke 53281,11:rem black border, dark grey screen
120 rv$=chr$(18):ro$=chr$(146):lf$=chr$(157):h$=chr$(19):bk$=rv$+" "+ro$
130 dn$="":for i=1 to 24:dn$=dn$+chr$(17):next:rem 24 cursor downs
140 dim n$(13),c(13),t(13),k$(15),b(4),xb(4),l$(4)
150 for i=0 to 13:read n$(i),c(i),t(i):next:rem name, c64 colour, tolerance
160 for i=0 to 15:read k:k$(i)=chr$(k):next:rem print codes of the colours
165 for j=1 to 4:read xb(j),l$(j):next:rem column and name of each band
170 data black,0,0,brown,9,1,red,2,2,orange,8,0,yellow,7,0
175 data green,5,0,blue,6,0,violet,4,0,grey,12,0,white,1,0
180 data gold,7,5,silver,15,10,none,14,20,-,14,0
185 data 144,5,28,159,156,30,31,158,129,149,150,151,152,153,154,155
188 data 12,"first digit",15,"second digit",18,"multiplier",25,"tolerance"
190 sp$="":for i=1 to 38:sp$=sp$+" ":next:rem spaces to clear a line
195 bd$=left$(sp$,20):ld$="":for i=1 to 7:ld$=ld$+chr$(192):next:rem body, lead
200 rem ---- menu ----
210 gosub 500
220 print h$;left$(dn$,22);tab(1);chr$(158);"1 colours to value";
225 print "  2 value to colours"
230 print tab(1);chr$(152);"q quit";
240 get k$:if k$="1" then 300
250 if k$="2" then 400
260 if k$="q" then 900
270 goto 240
300 rem ---- colours to value ----
310 gosub 500
320 j=1:ok$="123456789":p$="first digit: press 1-9":gosub 560
330 j=2:ok$="0123456789":p$="second digit: press 0-9":gosub 560
340 j=3:ok$="0123456789gs":p$="multiplier: press 0-9, g or s":gosub 560
350 gosub 590:rem the tolerance band
360 gosub 760:gosub 780:p$="":goto 380
380 rem ---- message p$, then wait for a key ----
382 print h$;left$(dn$,21);tab(1);chr$(150);p$;left$(sp$,38-len(p$))
384 print tab(1);chr$(5);"press a key for the menu";left$(sp$,14)
386 get k$:if k$="" then 386
388 goto 200
400 rem ---- value to colours ----
410 gosub 500:p$="value in ohm, like 470, 4.7k or 2.2m:"
415 print h$;left$(dn$,21);tab(1);chr$(5);p$:print tab(1);:gosub 870
420 v=val(s$):u$=right$(s$,1):if u$="k" then v=v*1e3
425 if u$="m" then v=v*1e6
430 if u$="g" then v=v*1e9
435 r=v:m=0:if v<=0 then m=-9:goto 450:rem nothing to work with
440 if r>=99.5 then r=r/10:m=m+1:goto 440:rem two digits and a power of 10
445 if r<9.95 then r=r*10:m=m-1:goto 445
450 if m<-2 or m>9 then p$="out of range: 0.1 ohm to 99g ohm":goto 380
455 d=int(r+.5):b(1)=int(d/10):b(2)=d-10*b(1):b(3)=m
460 if m=-1 then b(3)=10:rem gold multiplies by 0.1
465 if m=-2 then b(3)=11:rem silver by 0.01
470 for j=1 to 3:x=xb(j):cl=c(b(j)):gosub 680:next:gosub 650
475 gosub 760:w$="":if abs(r-v)>v/1e6 then w$="rounded to two digits"
480 gosub 590:gosub 780:p$=w$:goto 380
500 rem ---- a new screen: title, plain resistor, colour keys ----
505 print chr$(147);chr$(5);tab(10);"resistor colour code"
510 for j=1 to 4:b(j)=13:next:gosub 600:gosub 650:rem no bands yet
520 for i=0 to 12:print h$;left$(dn$,17+int(i/4));tab(1+(i-int(i/4)*4)*10);
525 y$=chr$(48+i):if i>9 then y$=mid$("gsn",i-9,1):rem the key to press
530 print chr$(5);y$;" ";k$(c(i));rv$;"  ";ro$;chr$(5);n$(i):next:return
560 rem ---- band j: show p$, wait for a key in ok$, draw the band ----
565 print h$;left$(dn$,22);tab(1);chr$(5);p$;left$(sp$,38-len(p$))
575 gosub 700:b(j)=v:x=xb(j):cl=c(v):gosub 680:gosub 650:return
590 j=4:ok$="12gsn":p$="tolerance: 1=1% 2=2% g=5% s=10% n=20%":goto 560
600 rem ---- draw the resistor: leads, body, bands b(1)-b(4) ----
610 print h$;left$(dn$,5);tab(3);chr$(152);ld$;tab(30);ld$
620 for y=4 to 6:print h$;left$(dn$,y);tab(10);k$(14);rv$;bd$;ro$:next
630 for j=1 to 4:x=xb(j):cl=c(b(j)):gosub 680:next:return
650 rem ---- the four bands in words ----
655 for j=1 to 4:print h$;left$(dn$,8+j);tab(4);chr$(5);l$(j);tab(18);
660 print k$(c(b(j)));rv$;"  ";ro$;" ";chr$(5);n$(b(j));"       ":next:return
680 rem ---- one band in colour cl at column x ----
690 for y=4 to 6:print h$;left$(dn$,y);tab(x);k$(cl);rv$;"  ";ro$:next:return
700 rem ---- wait for a key in ok$; v = its colour number ----
710 get k$:if k$="" then 710
720 w=0:for i=1 to len(ok$):if mid$(ok$,i,1)=k$ then w=1
725 next:if w=0 then 710:rem not one of the keys asked for
730 v=asc(k$)-48:if k$="g" then v=10
735 if k$="s" then v=11
740 if k$="n" then v=12
745 return
760 rem ---- r = the value of bands 1-3 ----
762 p=1:if b(3)=10 then p=.1
764 if b(3)=11 then p=.01
766 if b(3)>0 and b(3)<10 then for i=1 to b(3):p=p*10:next
768 r=(10*b(1)+b(2))*p:return
780 rem ---- show the value and the range the tolerance allows ----
782 t=t(b(4)):q=r:gosub 800:print h$;left$(dn$,14);tab(4);chr$(5);"value: ";
784 print chr$(158);v$;" +/-";mid$(str$(t),2);"%       "
786 r=q*(1-t/100):gosub 800:a$=v$:r=q*(1+t/100):gosub 800
788 print tab(4);chr$(5);"range: ";chr$(153);a$;" - ";v$;"    ":r=q:return
800 rem ---- v$ = r as text: 4700 -> "4.7k ohm" ----
805 u$="":if r>=1e9 then r=r/1e9:u$="g":goto 820
810 if r>=1e6 then r=r/1e6:u$="m":goto 820
815 if r>=1e3 then r=r/1e3:u$="k"
820 f=100:if r<1 then f=1000:rem two decimals, three below 1 ohm
822 r=int(r*f+.5)/f:v$=mid$(str$(r),2):if left$(v$,1)="." then v$="0"+v$
825 v$=v$+u$+" ohm":return
870 rem ---- read a value: digits, point, k/m/g, del and return ----
872 s$="":print bk$;lf$;:rem our own cursor
874 get k$:if k$="" then 874
876 if k$=chr$(13) and s$<>"" then print " ":return
878 if k$<>chr$(20) or s$="" then 882
880 s$=left$(s$,len(s$)-1):print " ";lf$;lf$;bk$;lf$;:goto 874
882 if len(s$)=8 then 874:rem eight characters at most
884 w=(k$>="0" and k$<="9") or k$="."
886 if k$="k" or k$="m" or k$="g" then w=-1
888 if w then s$=s$+k$:print k$;bk$;lf$;
890 goto 874
900 rem ---- quit ----
910 poke 53280,14:poke 53281,6:print chr$(147);chr$(154);"bye!":end
