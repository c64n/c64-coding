10 rem quadratic - solves a*x^2+b*x+c=0
20 rem c64 coding - c64n.blogspot.com
30 rem
100 poke 53280,6:poke 53281,1
110 def fn r(x)=int(x*1e4+.5)/1e4
120 print chr$(147);chr$(144)
130 print tab(10);"quadratic equations"
140 print tab(10);"==================="
150 print:print tab(5);"solves a*x^2 + b*x + c = 0"
160 print
170 input "  a";a
180 input "  b";b
190 input "  c";c
200 rem build the equation as text
210 e$="":v=a:t$="x^2":gosub 800
220 v=b:t$="x":gosub 800
230 v=c:t$="":gosub 800
240 if e$="" then e$="0"
250 print:print "  equation: ";e$;" = 0"
260 print
270 if a=0 then 400
280 d=b*b-4*a*c
290 print "  discriminant d =";fn r(d)
300 print
310 if d>0 then gosub 500
320 if d=0 then gosub 600
330 if d<0 then gosub 700
340 goto 450
400 rem a=0: not a quadratic
410 if b<>0 then print "  linear: x =";fn r(-c/b):goto 450
420 if c=0 then print "  every x is a solution.":goto 450
430 print "  no solution."
450 print:print "  another one (y/n)?"
460 get k$:if k$="" then 460
470 if k$="y" then 120
480 end
500 rem two real roots
510 q=sqr(d):x1=(-b+q)/(2*a):x2=(-b-q)/(2*a)
520 print "  two real roots:"
530 print "  x1 =";fn r(x1):print "  x2 =";fn r(x2)
540 x=x1:gosub 900
550 return
600 rem one double root
610 x1=-b/(2*a)
620 print "  one double root:":print "  x =";fn r(x1)
630 x=x1:gosub 900
640 return
700 rem two complex roots
710 re=-b/(2*a):im=abs(sqr(-d)/(2*a))
720 print "  two complex roots:"
730 i$=mid$(str$(fn r(im)),2)+"i"
740 print "  x1 =";fn r(re);"+ ";i$:print "  x2 =";fn r(re);"- ";i$
750 return
800 rem add the term v*t$ to e$
810 if v=0 then return
820 n$=mid$(str$(abs(v)),2)
830 if abs(v)=1 and t$<>"" then n$=""
840 s$=" + ":if v<0 then s$=" - "
850 if e$="" then s$="":if v<0 then s$="-"
860 e$=e$+s$+n$+t$
870 return
900 rem check: put x back into the equation
910 print "  check: a*x^2+b*x+c =";fn r(a*x*x+b*x+c)
920 return
