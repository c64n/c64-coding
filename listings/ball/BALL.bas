10 rem ball - a bouncing ball with sound
20 rem c64 coding - c64n.blogspot.com
30 rem
100 r=rnd(-ti):sc=1024:cm=55296:sd=54272
110 poke 53280,6:poke 53281,1:print chr$(147);chr$(144);
120 for i=0 to 24:poke sd+i,0:next:poke sd+24,15:poke sd+5,9
130 x=int(rnd(1)*38)+1:y=int(rnd(1)*22)+2
140 dx=1:dy=1:co=0:b=0:dl=20:q=0:if rnd(1)<.5 then dx=-1
150 print chr$(19);"bounces: 0";tab(22);"+/- speed  q quit";
200 rem main loop: draw the new ball, then erase the old one
210 p=sc+40*y+x:poke p,81:poke cm+40*y+x,co
220 if q>0 then poke q,32
230 q=p
240 get k$:if k$="q" then 900
250 if k$="+" and dl>0 then dl=dl-5
260 if k$="-" then dl=dl+5
270 for w=1 to dl:next
280 h=0:if x+dx<0 or x+dx>39 then dx=-dx:h=1
290 if y+dy<1 or y+dy>24 then dy=-dy:h=2
300 if h then gosub 500
310 x=x+dx:y=y+dy:goto 210
500 rem bounce: new colour, a note, the counter
510 b=b+1:co=co+1:if co=16 then co=0
520 if co=1 then co=2
530 poke sd+4,0:poke sd+1,10*h+5:poke sd+4,17
540 print chr$(19);chr$(144);"bounces:";b;
550 return
900 rem quit: sound off, colours back
910 poke sd+24,0:poke 53280,14:poke 53281,6
920 print chr$(147);chr$(154);"bye!":end
