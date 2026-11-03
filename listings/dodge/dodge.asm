; =============================================================
; DODGE - dodge the falling rocks
; C64 Coding - c64n.blogspot.com
;
; 6502 assembly for 64tass:
;   64tass -C -a -i dodge.asm -o dodge.prg            (RUN it)
;   64tass -C -a -i -D LOADER=1 dodge.asm -o dodge-c000.prg
;                                    (the code at 49152, for the
;                                     BASIC loader: SYS 49152)
; =============================================================

        .weak                   ; -D LOADER=1 overrides this
LOADER  = 0                     ; 0: normal .prg, 1: code at $c000
        .endweak

; ---- addresses ----------------------------------------------
screen  = $0400                 ; screen memory, 40 x 25
colour  = $d800                 ; colour memory
sprptr  = $07f8                 ; sprite 0 pointer
sprite  = $0340                 ; sprite 0 shape: 832 = block 13
raster  = $d012                 ; current raster line (low 8 bits)
border  = $d020
backgr  = $d021
sid     = $d400                 ; first SID register
joy2    = $dc00                 ; joystick port 2, bits are 0 when pressed
keyheld = $cb                   ; key held down, 64 = none
keybuf  = $c6                   ; number of keys in the keyboard buffer
chrout  = $ffd2                 ; KERNAL: print a character
plot    = $fff0                 ; KERNAL: move the cursor (carry clear)

src     = $fb                   ; zero page pointers for scrolling
dst     = $fd

rock    = 81                    ; screen code of a rock: a ball
k_z     = 12                    ; keyboard matrix codes
k_x     = 23
k_space = 60
k_q     = 62

; ---- start ---------------------------------------------------
.if LOADER != 0
        * = $c000               ; typed in with the BASIC loader
.else
        * = $0801               ; a BASIC line: 10 SYS 2061
        .word basend, 10
        .null $9e, format("%d", start)
basend  .word 0
.endif

start   jsr setup
title   jsr showtitle
        jsr waitstart           ; carry set: Q was pressed
        bcs quit
        jsr newgame

; ---- the game loop: once per frame ----------------------------
loop    jsr waitframe           ; 50 times a second (PAL)
        jsr move                ; joystick or Z/X
        lda $d01f               ; sprite-background collision
        and #1                  ; did sprite 0 touch a rock?
        bne crash
        dec timer               ; time to scroll?
        bne loop
        lda delay
        sta timer
        jsr scroll              ; everything moves down one row
        jsr addrocks            ; new rocks on the top row
        jsr addscore            ; one point per row
        jmp loop

crash   jsr gameover
        jmp title

quit    lda #0
        sta $d015               ; sprite off
        sta sid+24              ; sound off
        sta keybuf              ; forget the keys pressed in the game
        lda #14
        sta border              ; the usual colours
        sta $0286               ; light blue text
        lda #6
        sta backgr
        lda #147                ; clear the screen
        jmp chrout              ; ...and its RTS goes back to BASIC

; ---- setup: once -----------------------------------------------
setup   lda #0
        sta border
        sta backgr
        sta $d017               ; sprite 0: normal size,
        sta $d01d
        sta $d01c               ; one colour,
        sta $d01b               ; in front of the text
        sta hi
        sta hi+1
        ldx #62                 ; empty the sprite block...
-       sta sprite,x
        dex
        bpl -
        ldx #shipend-ship-1     ; ...and copy the ship into it
-       lda ship,x
        sta sprite,x
        dex
        bpl -
        lda #sprite/64
        sta sprptr
        lda #7                  ; yellow ship
        sta $d027
        lda #218                ; near the bottom of the screen
        sta $d001
        ldx #24                 ; silence the SID
        lda #0
-       sta sid,x
        dex
        bpl -
        lda #$ff                ; voice 3: noise at top speed,
        sta sid+14              ; a source of random numbers
        sta sid+15
        lda #$80
        sta sid+18
        lda #$8f                ; volume 15, voice 3 not heard
        sta sid+24
        rts

; ---- title screen ----------------------------------------------
showtitle
        lda #0
        sta $d015               ; hide the ship
        lda #147
        jsr chrout
        lda #<titletxt
        ldy #>titletxt
        jsr texts
        ldx #19                 ; the high score
        ldy #19
        clc
        jsr plot
        lda hi+1
        jsr putbcd
        lda hi
        jmp putbcd

; wait for fire or space (carry clear) or Q (carry set)
waitstart
-       lda joy2                ; first wait until everything is let go
        and #$10
        beq -
        lda keyheld
        cmp #64
        bne -
-       lda keyheld
        cmp #k_q
        beq wsquit
        cmp #k_space
        beq wsgo
        lda joy2
        and #$10                ; fire button
        bne -
wsgo    clc
        rts
wsquit  sec
        rts

; ---- new game ----------------------------------------------------
newgame lda #147
        jsr chrout
        ldx #0                  ; colour memory: light grey rocks
        lda #15
-       sta colour,x
        sta colour+$100,x
        sta colour+$200,x
        sta colour+$2e8,x
        inx
        bne -
        lda #<gametxt
        ldy #>gametxt
        jsr texts
        ldx #0                  ; high score on the top line
        ldy #33
        clc
        jsr plot
        lda hi+1
        jsr putbcd
        lda hi
        jsr putbcd
        lda #0
        sta score
        sta score+1
        sta rows
        jsr showscore
        lda #74                 ; the ship in the middle
        sta px
        jsr placeship
        lda #6                  ; 6 frames per row to start with
        sta delay
        sta timer
        lda #48                 ; chance of a rock, out of 256
        sta density
        lda #1
        sta $d015               ; ship on
        jsr waitframe
        lda $d01f               ; reading it clears old collisions
        rts

; ---- wait for the next frame ---------------------------------------
waitframe
-       lda raster              ; still on line 251 from last time?
        cmp #251
        beq -
-       lda raster              ; wait for line 251, below the text
        cmp #251
        bne -
        rts

; ---- move the ship -------------------------------------------------
move    lda joy2
        and #4                  ; joystick left
        beq left
        lda keyheld
        cmp #k_z
        beq left
        lda joy2
        and #8                  ; joystick right
        beq right
        lda keyheld
        cmp #k_x
        beq right
        rts
left    lda px
        beq placeship           ; already at the left edge
        dec px
        jmp placeship
right   lda px
        cmp #148                ; right edge
        bcs placeship
        inc px

; sprite x = 24 + 2 * px: nine bits, the ninth in $d010
placeship
        lda #0
        sta msb
        lda px
        asl a                   ; carry = bit 8 of px * 2
        rol msb
        clc
        adc #24
        sta $d000
        lda msb
        adc #0
        sta $d010
        rts

; ---- scroll rows 1-23 down to rows 2-24 ----------------------------
scroll  lda #<(screen+23*40)    ; src: row 23
        sta src
        lda #>(screen+23*40)
        sta src+1
        ldx #23                 ; 23 rows to copy, bottom first
sc_row  lda src                 ; dst = src + 40, the row below
        clc
        adc #40
        sta dst
        lda src+1
        adc #0
        sta dst+1
        ldy #39
-       lda (src),y
        sta (dst),y
        dey
        bpl -
        lda src                 ; src one row up
        sec
        sbc #40
        sta src
        bcs +
        dec src+1
+       dex
        bne sc_row
        ldy #39                 ; empty the top row of the play area
        lda #32
-       sta screen+40,y
        dey
        bpl -
        rts

; ---- new rocks: three tries per row --------------------------------
addrocks
        ldx #3
-       lda sid+27              ; a random number from voice 3
        cmp density
        bcs +                   ; no rock this time
        lda sid+27
        and #63                 ; a column 0-63...
        cmp #40                 ; ...and only 0-39 count
        bcs +
        tay
        lda #rock
        sta screen+40,y
+       dex
        bne -
        rts

; ---- score: one point per row, faster every 32 rows ----------------
addscore
        sed                     ; decimal mode: 0099 + 1 = 0100
        clc
        lda score
        adc #1
        sta score
        lda score+1
        adc #0
        sta score+1
        cld
        jsr showscore
        inc rows
        lda rows
        and #31
        bne asdone
        lda density             ; more rocks...
        cmp #160
        bcs +
        adc #16
        sta density
+       lda delay               ; ...and faster, down to 2 frames a row
        cmp #2
        beq asdone
        dec delay
asdone  rts

showscore
        ldx #0
        ldy #7
        clc
        jsr plot
        lda #5                  ; white
        jsr chrout
        lda score+1
        jsr putbcd
        lda score
        ; fall through

; print a byte of BCD as two digits
putbcd  pha
        lsr a
        lsr a
        lsr a
        lsr a
        ora #$30                ; "0" + high digit
        jsr chrout
        pla
        and #$0f
        ora #$30                ; "0" + low digit
        jmp chrout

; ---- game over ------------------------------------------------------
gameover
        lda #$0a                ; voice 1: a burst of noise
        sta sid+5               ; attack 0, decay 10
        lda #0
        sta sid+6
        lda #8
        sta sid+1
        lda #$81                ; noise, gate on
        sta sid+4
        ldx #25                 ; flash the border for half a second
-       stx border
        jsr waitframe
        dex
        bne -
        stx border              ; x = 0: black again
        lda #$80                ; gate off
        sta sid+4
        lda score+1             ; a new high score?
        cmp hi+1
        bcc gonohi
        bne gohi
        lda score
        cmp hi
        bcc gonohi
gohi    lda score
        sta hi
        lda score+1
        sta hi+1
gonohi  lda #<overtxt
        ldy #>overtxt
        jsr texts
        ldx #100                ; two seconds
-       jsr waitframe
        dex
        bne -
        rts

; ---- print a table of texts: row, column, text, 0 ... $ff ----------
texts   sta src
        sty src+1
        ldy #0
tx_next lda (src),y             ; row
        bmi tx_done             ; $ff ends the table
        tax
        iny
        lda (src),y             ; column
        iny
        sty tmp
        tay
        clc
        jsr plot
        ldy tmp
-       lda (src),y             ; the text, up to a 0
        beq +
        jsr chrout
        iny
        bne -
+       iny
        bne tx_next
tx_done rts

; ---- texts: colour code first; lower case here, capitals on screen (-a) ----
titletxt
        .byte 5, 15, 158
        .text "d o d g e", 0
        .byte 8, 8, 5
        .text "dodge the falling rocks", 0
        .byte 11, 5, 155
        .text "joystick in port 2 or z and x", 0
        .byte 14, 9, 153
        .text "fire or space to start", 0
        .byte 16, 15, 153
        .text "q to quit", 0
        .byte 19, 16, 5
        .text "hi", 0
        .byte $ff
gametxt .byte 0, 1, 5
        .text "score", 0
        .byte 0, 30, 5
        .text "hi", 0
        .byte $ff
overtxt .byte 12, 15, 150
        .text "game over", 0
        .byte $ff

; ---- the ship: 24 x 21 pixels, 3 bytes a row ------------------------
ship    .byte $00,$18,$00, $00,$3c,$00, $00,$3c,$00, $00,$7e,$00
        .byte $00,$7e,$00, $00,$ff,$00, $01,$ff,$80, $03,$ff,$c0
        .byte $07,$db,$e0, $0f,$99,$f0, $1f,$18,$f8, $3c,$00,$3c
        .byte $30,$00,$0c       ; 13 rows; the other 8 stay empty
shipend

; ---- variables: after the code, not part of the file -----------------
        .virtual *
px      .byte ?                 ; ship position, 0-148
msb     .byte ?
timer   .byte ?                 ; frames until the next row
delay   .byte ?                 ; frames per row
density .byte ?                 ; chance of a rock
rows    .byte ?                 ; rows survived, for the speed-up
tmp     .byte ?
score   .word ?                 ; BCD, 0000-9999
hi      .word ?
        .endv
