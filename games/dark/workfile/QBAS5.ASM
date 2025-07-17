GAMESTART
	CALL	CLEARGAMEWIN

	LD	B,30
DRGUI1	PUSH	BC
	LD	C,B
	LD	B,#12
	LD	HL,GUIFR2
	CALL	DRAWSPR_REAL
	POP	BC
	DJNZ	DRGUI1
	LD	A,-1
	LD	(SPRDIR),A
	LD	BC,#120B
	LD	HL,GUIFR1
	CALL	DRAWSPR_REAL
	LD	BC,#121E
	LD	HL,GUIFR1
	CALL	DRAWSPR_REAL
	XOR	A
	LD	(SPRDIR),A
	LD	BC,#1213
	LD	HL,GUIFR1
	CALL	DRAWSPR_REAL
	LD	BC,#120C
	LD	HL,GUIFR3
	CALL	DRAWSPR_REAL
	LD	BC,#1200
	LD	HL,GUIFR1
	CALL	DRAWSPR_REAL
	LD	BC,#1315
	LD	HL,L_B177	; default compass
	CALL	DRAWSPR_REAL

	DI
	LD	HL,PROGBEGIN-1
	LD	SP,HL

GAME_REPEAT
	LD	HL,#0000	; set weapon type
	LD	(L_FAB1),HL	; and bullets

STLVSET	LD	A,STLEVEL
	LD	(LEVEL),A

NEXTLEV	CALL	INITSET
	CALL	READYGO

	LD	A,(L_FAB5)
	CP	#01		; dead? (level failed)
	JR	Z,LEVFAIL

	LD	A,2		; (поскольку на нулевом не мрём,
	LD	(LEVFAIL+1),A 	; можно впервые установить здесь)
	LD	A,(LEVEL)
	INC	A
	LD	(LEVEL),A
	CP	10
	JR	Z,GAMEEND
	JR	NEXTLEV

GAMEEND	CALL	THAW
	CALL	WORLD_NEW
	JP	GAME_REPEAT

NEXTLE1	LD	DE,TXAGAIN
	CALL	PRINT
	CALL	FXGAMEOVER
	LD	HL,#0000	; set weapon type and bullets
	LD	(L_FAB1),HL	; (обнуляем для второй попытки)
	JR	NEXTLEV

LEVFAIL	LD	A,2		; (var)
	DEC	A
	LD	(LEVFAIL+1),A
	AND	A
	JR	NZ,NEXTLE1	; first try = same level again
	LD	A,(LEVEL)
	CP	2
	JR	C,NEXTLE1	; Level < 2 = same level again
	DEC	A
	LD	(LEVEL),A
	LD	B,4
	CALL	FXGOB
	LD	DE,TXBACK
	CALL	PRINT

	LD	B,44
PIKPIK3	PUSH	BC
	SLA	B
	SLA	B
	LD	A,255
	SUB	B
	LD	C,A
	LD	B,22
	CALL	FXBEEP
	POP	BC
	DJNZ	PIKPIK3

	CALL	FIREPRESSLOOP
	LD	A,2
	LD	(LEVFAIL+1),A
	JR	NEXTLEV

READYGO	LD	(V_EXMAP),DE

	CALL	CREATEMAP
	LD	A,(LEVEL)
	AND	A
	CALL	NZ,THAW
	CALL	CLEARGAMEWIN

	LD	A,(L_FAB5)
	CP	#01		; dead? (level failed)
	JR	Z,DONTSHOWLEVELCOMPLETE
	LD	A,(LEVEL)
	CP	2
	JR	C,DONTSHOWLEVELCOMPLETE
	LD	DE,TX6498	; congratulations
	CALL	PRINT
	LD	DE,TX64AA	; level complete
	CALL	PRINT
	CALL	FIREPRESSLOOP

DONTSHOWLEVELCOMPLETE
	CALL	WORLD
	CALL	SETSCREEN_VIRTUAL
	LD	HL,#0000
	LD	(L_FAB5),HL	; clear main game state

	LD	A,44		; время до исчезновения
	LD	(L_FAB8),A	; первой надписи (долго)

	LD	A,(LEVEL)
	CP	4
	CALL	Z,PRKILL

	LD	A,(LEVEL)
	CP	9
	CALL	Z,PREGGS

	CALL	DRAW_COMPASS
	JP	L_7530		; go to main loop
CLS
	ld hl,#4000
	ld de,#4001
	ld bc,#17ff
	ld (hl),l
	xor a
	out (#fe),a
	ldir
	inc hl
	inc de
	ld (hl),#07
	ld bc,#2ff
	ldir
	ret

; CLS	LD	A,#07		; CLEAR SCREEN
; 	LD	(#5C8D),A
; 	LD	A,#00
; 	CALL	#229B		; 8859, border
; 	JP	#0D6B		; 3435, CLS

PRKILL	LD	DE,TXKILL	; 'kill all enemies'
	JP	PRINT		; (print on level 4)

PREGGS	LD	DE,TXEGGS	; 'destroy all eggs'
	CALL	PRINT		; (print on level 9)
	LD	BC,#041F
	LD	HL,SPR_EGG
	CALL	DRAWSPR_REAL
PRINTEGGCOUNT
	LD	A,3
	LD	(#5800+32*6+31),A
	LD	A,(V_EGCNT)
	LD	BC,#061E
	JP	PRINTNUM

;==================================================
; INITIAL SETTINGS
;==================================================

INITSET	CALL	EMPTY_MAP1
	CALL	GREEN_TREES

	LD	HL,#0305
	CALL	SET_COLORS_FOR_WALLS

	CALL	CLEARKEY1	; очищаем изображения
	CALL	CLEARKEY2	; ключей
	CALL	CLEARKEY3
	CALL	CLEARKEY4	; и яиц

	LD	HL,#EF04

	LD	(L_FAA3),HL
	LD	A,#0D
	LD	(L_FAA2),A

	LD	HL,#5050	; set health
	LD	(L_FAAF),HL	; and armors
	LD	A,#FA
	LD	(#5C37),A
	LD	HL,#0000	; обнуляем
	LD	(L_FAA9),HL	; позицию монстра
	LD	(L_FAAB),HL	; обнуляем ключи (и байт счетчика)
	LD	(L_FAB7),HL	; 'hand' and text-time
	LD	(ISKRA+1),HL

	LD	HL,#D500	; set dragon pos (FAAE=#D5)
	LD	(L_FAAD),HL	; and monster's life (FAAD=0!)
	LD	HL,#EFAA	; позиция летающей смерти
	LD	(L_FABD),HL	; (was #E5AA for level1)

	XOR	A		; и для взрыва, и для монстров
	LD	(EXPDATA),A	; обнуляем взрыв
	LD	(V_JTCNT),A	; count of Goats
	LD	(DRWSHOO+1),A
	LD	B,GOATCNT*6
	LD	HL,GOATDATA	; обнуляем данные козлов
CLRGOATS	LD	(HL),A
	INC	HL
	DJNZ	CLRGOATS

	LD	A,#C9
	LD	(GOATMUS),A	; выключить козло-музыку
	LD	(L_6FFA),A	; выключить обработку оружия

	CALL	L_7133
	CALL	PRNTBUL		; print bullets
	LD	DE,TXT_HEALTH
	CALL	PRINT
	LD	DE,TXT_ARMORS
	CALL	PRINT

	LD	DE,#031E	; 'exit' badge in map
	LD	HL,MAP1		; and map for level 1

	LD	A,(LEVEL)
	AND	A
	JR	Z,INIT_LEVEL0
	DEC	A
	JR	Z,INIT_LEVEL1
	DEC	A
	JR	Z,INIT_LEVEL2
	DEC	A
	JR	Z,INIT_LEVEL3
	DEC	A
	JR	Z,INIT_LEVEL4
	DEC	A
	JR	Z,INIT_LEVEL5
	DEC	A
	JP	Z,INIT_LEVEL6
	DEC	A
	JP	Z,INIT_LEVEL7
	DEC	A
	JP	Z,INIT_LEVEL8
;==	DEC	A
;==	JR	Z,INIT_LEVEL9
;==	RET

INIT_LEVEL9
	LD	HL,#E530
	LD	(L_FAA3),HL	; start position
	LD	DE,#FEFE	; out of screen
	LD	HL,MAP4		; map same as level 4
	RET

INIT_LEVEL0
	LD	A,44
	LD	(L_FAAE),A	; dragon pos
	LD	HL,#EF5A
	LD	(L_FAA3),HL	; start position
	LD	DE,#0211
	LD	HL,MAP0
	RET

INIT_LEVEL1
	PUSH	DE
	LD	DE,#EA28
	CALL	SETGOAT0
	LD	DE,#E404
	LD	(L_FAA3),DE	; start position
	POP	DE
	RET

INIT_LEVEL2
	LD	HL,GOATINI3
	CALL	SETGOATS
	LD	DE,#011E
	LD	HL,MAP2
	RET

INIT_LEVEL3
	LD	HL,#0341
	CALL	SET_COLORS_FOR_WALLS
	LD	DE,#001E
	LD	HL,MAP3
	RET

INIT_LEVEL4
	LD	HL,GOATINI4
	CALL	SETGOATS
	LD	HL,#0604
	CALL	SET_COLORS_FOR_WALLS
	LD	DE,#FEFE	; out of screen
	LD	HL,MAP4
	RET

INIT_LEVEL5
	LD	HL,GOATINI5
	CALL	SETGOATS
	LD	HL,#0703
	CALL	SET_COLORS_FOR_WALLS
	LD	DE,#011E
	LD	HL,MAP5
	RET

INIT_LEVEL6
	LD	BC,#3F04	; count and offset
	LD	D,#A5		; object: stone
	LD	HL,L_UMAP+256*0+4
	CALL	RIAD
	LD	HL,L_UMAP+256*29+4
	CALL	RIAD
	LD	DE,#0006	; 'exit' badge
	LD	HL,MAP6
	RET

INIT_LEVEL7
	LD	HL,#4202
	CALL	SET_COLORS_FOR_WALLS
	LD	DE,#031E	; 'exit' badge
	LD	HL,MAP3		; map same as level 3
	RET

INIT_LEVEL8
	LD	DE,#EF28
	CALL	SETGOAT0
	LD	(IX+4-6),#7F	; almost-immortal GOAT
	LD	HL,#0403
	CALL	SET_COLORS_FOR_WALLS
	LD	DE,#F40B
	LD	(L_FAA3),DE	; start position
	LD	DE,#001E	; 'exit' badge in map
	LD	HL,MAP1		; map same as level 1
	RET

SETGOAT0	LD	IX,GOATDATA
SETGOAT	XOR	A
	CP	(IX+1)		; this Goat is empty? (y=0)
	JR	Z,SETJU1
	CALL	ENMDIST		; player<->enemy distance
	CP	36		; not so far?
	RET	C		; don't change this Goat!
	PUSH	HL
	LD	L,(IX)
	LD	H,(IX+1)
	LD	(HL),0		; clear current in-map Goat
	POP	HL
SETJU1	LD	A,(DE)
	AND	A		; check the map byte
	RET	NZ		; (p.s. doesn't work at init)
	LD	(IX),E
	LD	(IX+1),D
	PUSH	DE
	LD	DE,#2201
	LD	(IX+2),E
	LD	(IX+3),D
	LD	DE,#0003
	LD	(IX+4),E
	LD	(IX+5),D
	LD	DE,6
	ADD	IX,DE
	PUSH	HL
	LD	HL,V_JTCNT
	INC	(HL)		; inc Goats count
	POP	HL
	POP	DE
	RET

SETGOATS	LD	B,(HL)
	INC	HL
	LD	IX,GOATDATA
SETJTS1	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	CALL	SETGOAT
	DJNZ	SETJTS1
	RET

GOATINI3	DEFB	6
	DEFW	#ED28, #F02A, #ED2C, #F02E
	DEFW	#E830, #F530

GOATINI4	DEFB	10
	DEFW	#ED2B, #EDDE, #E670, #F446, #E438
	DEFW	#E7BC, #E4A0, #F8C9, #EDEE, #F285

GOATINI5	DEFB	7
	DEFW	#ED28, #F02A, #ED2C, #F02E
	DEFW	#ED40, #F040, #F942

CLEARKEY4
	LD	HL,#5800+32*4+31
	CALL	CLRKEY0
	LD	(#5800+32*6+30),A
	RET
CLEARKEY3
	LD	HL,#5800+32*8+31
	JR	CLRKEY0
CLEARKEY2
	LD	HL,#5800+32*15+31
	JR	CLRKEY0
CLEARKEY1
	LD	HL,#5800+32*12+31
CLRKEY0	XOR	A
	LD	DE,32
	LD	(HL),A
	ADD	HL,DE
	LD	(HL),A
	ADD	HL,DE
	LD	(HL),A
	RET

L_6D6D	LD	HL,#97FF+KK
	LD	B,#0D
L_6D72	LD	D,B
	PUSH	BC
	LD	C,#01
L_6D76	PUSH	DE
	PUSH	HL
	CALL	L_6D96
	POP	HL
	DEC	HL
	POP	DE
	INC	C
	LD	A,C
	CP	#1E
	JR	C,L_6D76
	POP	BC
	DJNZ	L_6D72
	RET

L_6D96	LD	A,(HL)
	AND	A
	RET	Z
	CP	#65
	JP	Z,L_79C5	;фиолетовая стена
	CP	#66
	JP	Z,L_771B	;белая стена
	CP	#64
	JP	Z,OGRADA	;ограда (моста)
	CP	#67
	JP	Z,L_7EX1	;закрытая дверь (1)
	CP	#68
	JP	Z,L_7EX2	;закрытая дверь (2)
	CP	#6A
	JP	Z,L_7E1F	;закрытая дверь (3)
	CP	#A0
	JP	Z,L_7BC1	;дерево
	CP	#92
	JP	Z,L_7C18	; AMMO BOX
	CP	#93
	JP	Z,L_7C1X	; ARMORS BOX
	CP	#9E
	JP	Z,L_7D4D	;сердце
	CP	#9C
	JP	Z,L_7DD6	;ключ (1)
	CP	#9D
	JP	Z,L_7DDX	;ключ (2)
	CP	#9B
	JP	Z,L_7ECC	;QUAKE sign (рука, ладонь)
	CP	#A2
	JP	Z,L_7E40	;падающие капли
	CP	#A3
	JP	Z,L_7453	;муха
	CP	#A4
	JP	Z,L_73CD	;летающая смерть (вывод и влияние на игрока)
	CP	#A1
	JP	Z,L_7CCF	;труп монстра
	CP	#A5
	JP	Z,STONE		;камень
	CP	#DF
	JP	Z,EGG
	CP	#D0
	JP	Z,L_7A35	;монстр Бык
	RET	NC		;дальше - монстры Goats
	CP	#C0
	JP	NC,DRAWGOAT	;#C0..#CF
	RET

VROT	AND	A
	JR	Z,L_6EE5
	DEC	A
	JP	Z,L_6F6A
	DEC	A
	JP	Z,L_6F7E
	JP	L_6F96

L_6E4A	LD	HL,(L_FAA3)	;player's pos
	CALL	L_6EF6		;table select according angle
	LD	IX,L_6C90	;ray-width table
	LD	IY,#9687+KK	;pointer to calculated data
	LD	B,#DD		;table length=221
L_6E64	PUSH	BC
	LD	A,(L_FAA2)	;player's rotation
	DEC	A
	SRL	A
	SRL	A
	CALL	VROT

	LD	B,(IX)		; width of ray
RAYPROJ	LD	A,1		; (var) byte of map
	LD	(IY),A		; always set 1st byte
	CP	#82
	JR	C,L_6ECE
	XOR	A		; disable multiplication
	LD	(RAYPROJ+1),A
L_6ECE	INC	IY
	DJNZ	RAYPROJ
	INC	IX
	POP	BC
	DJNZ	L_6E64

	CALL	WALL_CAP_HOLES
	JP	L_6D6D

L_6EF6	LD	A,(L_FAA2)	;raycasting table select
	DEC	A		;according angle
	AND	3
	AND	A		; cp 0
	JR	NZ,L_6F00
	LD	DE,L_65A8
L_6F00	DEC	A		; cp 1
	JR	NZ,L_6F07
	LD	DE,L_691C
L_6F07	DEC	A		; cp 2
	JR	NZ,L_6F0E
	LD	DE,L_6762
L_6F0E	DEC	A		; cp 3
	RET	NZ
	LD	DE,L_6AD6
	RET

RPSET0	INC	DE
	XOR	A
	LD	(RAYPROJ+1),A
	POP	HL
	POP	AF
	RET

EGGFND	LD	(EGGADDR+1),HL
	RET

L_6EE5	PUSH	AF
	PUSH	HL
	LD	A,(DE)
	ADD	A,L
	LD	L,A
	INC	DE
	LD	A,(DE)
	ADD	A,H
	CP	L_UMAP/256	; in map?
	JR	C,RPSET0	; not in map
	CP	L_UMAP/256+30
	JR	NC,RPSET0	; not in map
	LD	H,A
	INC	DE
	LD	A,(HL)
	CP	#DF
	CALL	Z,EGGFND
	LD	(RAYPROJ+1),A
	POP	HL
	POP	AF
	RET

L_6F6A	PUSH	AF
	PUSH	HL
	LD	A,(DE)
	INC	DE
	LD	C,A
	LD	A,H
	LD	H,C
	SUB	H
	CP	L_UMAP/256	; in map?
	JR	C,RPSET0	; not in map
	CP	L_UMAP/256+30
	JR	NC,RPSET0	; not in map
	LD	H,A
	LD	A,(DE)
	ADD	A,L
	LD	L,A
	INC	DE
	LD	A,(HL)
	CP	#DF
	CALL	Z,EGGFND
	LD	(RAYPROJ+1),A
	POP	HL
	POP	AF
	RET

L_6F7E	PUSH	AF
	PUSH	HL
	LD	A,(DE)
	LD	C,A
	LD	A,L
	LD	L,C
	SUB	L
	LD	L,A
	INC	DE
	LD	A,(DE)
	LD	C,A
	LD	A,H
	LD	H,C
	SUB	H
	CP	L_UMAP/256	; in map?
	JR	C,RPSET0	; not in map
	CP	L_UMAP/256+30
	JR	NC,RPSET0	; not in map
	LD	H,A
	INC	DE
	LD	A,(HL)
	CP	#DF
	CALL	Z,EGGFND
	LD	(RAYPROJ+1),A
	POP	HL
	POP	AF
	RET

L_6F96	PUSH	AF
	PUSH	HL
	LD	A,(DE)
	INC	DE
	ADD	A,H
	CP	L_UMAP/256	; in map?
	JR	C,RPSET0	; not in map
	CP	L_UMAP/256+30
	JR	NC,RPSET0	; not in map
	LD	H,A
	LD	A,(DE)
	LD	C,A
	LD	A,L
	LD	L,C
	SUB	L
	LD	L,A
	INC	DE
	LD	A,(HL)
	CP	#DF
	CALL	Z,EGGFND
	LD	(RAYPROJ+1),A
	POP	HL
	POP	AF
	RET

ISWALL	CP	#63		; <#63? (wall etc)
	JR	C,NOWALL1	; yes, enable moving
	CP	#70		; <#70?
	JR	C,ISWALL1	; yes, don't move
	CP	#A0		; tree?
	JR	Z,ISWALL1	; yes, don't move
	CP	#D0		; monster?
	JR	Z,ISWALL1	; yes, don't move
	CP	#D0
	JR	NC,NOWALL1	; >(=)#D0, not GOAT-mon
	CP	#C0		; #C0..#CF?
	JR	NC,ISWALL1	; yes, don't move
NOWALL1	XOR	$FF		; reset Z flag
	RET
ISWALL1	XOR	A		; set Z flag
	RET

SSTEP	LD	A,(L_FAA5)
	BIT	0,A
	CALL	Z,SOUND_STEP	; звук шагов
	RET

L_6FAA	LD	HL,(L_FAA3)
	DEC	H
	LD	A,H
	CP	L_UMAP/256	; map limit: top
	RET	C
	LD	A,(HL)
	CALL	ISWALL
	RET	Z		; don't move
	LD	HL,(L_FAA3)
	DEC	H
	LD	(L_FAA3),HL
	JR	SSTEP

L_6FC0	LD	HL,(L_FAA3)
	DEC	L
;---	LD	A,L
;---	INC	A		; map limit: left
;---	RET	Z
	LD	A,(HL)
	CALL	ISWALL
	RET	Z		; don't move
	LD	HL,(L_FAA3)
	DEC	L
	LD	(L_FAA3),HL
	JR	SSTEP

L_6FD6	LD	HL,(L_FAA3)
	INC	L
;---	LD	A,L
;---	CP	255		; map limit: right
;---	RET	Z
	LD	A,(HL)
	CALL	ISWALL
	RET	Z		; don't move
	LD	HL,(L_FAA3)
	INC	L
	LD	(L_FAA3),HL
	JR	SSTEP

L_6FEC	LD	HL,(L_FAA3)
	INC	H
	LD	A,H
	CP	L_UMAP/256+30	; map limit: top
	RET	NC
	LD	A,(HL)
	CALL	ISWALL
	RET	Z		; don't move
	LD	(L_FAA3),HL
	JR	SSTEP

L_7053	LD	A,(L_FAA2)
	CP	#01
	JP	Z,L_6FEC
	CP	#02
	JP	Z,L_6FEC
	CP	#10
	JP	Z,L_6FEC
	CP	#04
	JP	Z,L_6FD6
	CP	#05
	JP	Z,L_6FD6
	CP	#06
	JP	Z,L_6FD6
	CP	#08
	JP	Z,L_6FAA
	CP	#09
	JP	Z,L_6FAA
	CP	#0A
	JP	Z,L_6FAA
	CP	#03
	JR	NZ,L_708D
	CALL	L_6FD6
	JP	L_6FEC

L_708D	CP	#07
L_708F	JR	NZ,L_7097
	CALL	L_6FD6
	JP	L_6FAA

L_7097	CP	#0B
	JR	NZ,L_70A1
	CALL	L_6FAA
	JP	L_6FC0

L_70A1	CP	#0F
	JR	NZ,L_70AB
	CALL	L_6FC0
	JP	L_6FEC
L_70AB	JP	L_6FC0

;==================================================
; PRINT BULLETS COUNT / ZERO CHECK / GUN CHANGE
;==================================================

L_70AE	LD	A,(L_FAB1)
	DEC	A
	LD	(L_FAB1),A
	JR	NZ,NOTZBUL
	LD	(L_FAB2),A	; set weapon, A=0 already
NOTZBUL	LD	BC,#151B
	JP	PRINTNUM
	
PRNTBUL	LD	A,(L_FAB1)
	JR	NOTZBUL

;==================================================
; байт перед игроком
;==================================================

L_70F0	LD	HL,#9687+KK
L_70F3	LD	A,(HL)
	CP	#82
	RET	NC
	INC	HL
	LD	A,L
	CP	#A1
	RET	Z
	JR	L_70F3
	RET

;==================================================
; поиск предметов вблизи и их удаление
;==================================================

L_710B	LD	HL,(L_FAA3)
	DEC	H
	DEC	H
	DEC	H
	DEC	L
	DEC	L
	DEC	L
	LD	B,#07
L_7116	PUSH	BC
	LD	B,#07
L_7119	LD	A,H
	CP	L_UMAP/256	; in map?
	JR	C,NOTOBJ	; not in map
	CP	L_UMAP/256+30
	JR	NC,NOTOBJ	; not in map
	LD	A,(HL)
	CP	#82
	JR	C,NOTOBJ
	CP	#9F
	JR	NC,NOTOBJ
DELOBJ	LD	(HL),0
NOTOBJ	INC	L
	DJNZ	L_7119
	LD	A,L
	SUB	7
	LD	L,A
	INC	H
	POP	BC
	DJNZ	L_7116
	RET

;==================================================
; PRINT HEALTH and ARMORS
;==================================================

L_7133	LD	A,(L_FAAF)
	LD	BC,#1308
	CALL	PRINTNUM
	LD	A,(L_FAB0)
	IF LANGUAG=0
	LD	BC,#1508
	ENDIF
	IF LANGUAG=1
	LD	BC,#1509
	ENDIF
	JP	PRINTNUM

;==================================================
; Check weapon-to-monsters hit
;==================================================

L_717C	LD	B,#0D		; distance of hit (full)...was #0B
L_717E	LD	D,#00		; just marker
	LD	HL,#9687+KK+10	; calculated ray-data
L_7183	PUSH	BC
	LD	B,#08
	LD	E,0		; solid wall counter
L_7186	LD	A,(HL)
	CP	#C0		; monsters? (was #D0)
	JR	C,L_718D	; no, skip
	CP	#D0		; it's GOAT or other monster?
	JR	NC,NOTGOAT	; not GOAT (почему-то при стрельбе на старте....)
	CALL	CALCGOAT		; calculate addr of GOAT data === see below ===
	LD	A,(IX+4)	; GOAT's life
	SET	7,A		; set 'hit GOAT' marker
	LD	(IX+4),A				; === origin of BUG ===
	JR	WASMONSTERHIT
NOTGOAT	CP	#DF		; egg?
	JR	NZ,NOTEGG
	LD	D,#02		; set 'hit egg' marker
	JR	WASMONSTERHIT
NOTEGG	LD	D,#01		; set 'hit monster' marker
WASMONSTERHIT
	EXA
	LD	A,#C9		; and don't dec player's
	LD	(DECHEAL),A	; life right now!
	EXA
L_718D	CP	#64		; check the wall
	JR	C,NTRUWAL
	CP	#82
	JR	NC,NTRUWAL
	INC	E		; solid wall counter
NTRUWAL	INC	HL
	DJNZ	L_7186
	POP	BC
	LD	A,E		; solid wall on the way?
	CP	6
	RET	NC		; yes, stop the bullet
	PUSH	DE
	LD	DE,#0015
	ADD	HL,DE
	POP	DE
	DJNZ	L_7183
	RET

L_71A6	CALL	L_717C
L_71A9	LD	A,D		; read marker
	CP	#02		; hit egg?
	JR	Z,HITEGG
	CP	#01		; hit monster?
	RET	NZ
	LD	A,(L_FAAD)	; жизнь монстра
	AND	A
	RET	Z		; монстра не существует
	LD	A,2
	LD	(MONCOLR+1),A
	LD	A,(L_FAAD)
	DEC	A		; убавление жизни монстра
	LD	(L_FAAD),A
	AND	A
	RET	NZ
	LD	HL,(L_FAA9)	; смерть монстра
	LD	(HL),#A1	; нарисовать на этом месте труп
	LD	HL,#0000
	LD	(L_FAA9),HL
	XOR	A
	LD	(MONCOLR+1),A
	JP	EXPLNEW

HITEGG	XOR	A
EGGADDR	LD	(0),A		; (var addr)
	CALL	EXPLNEW
	LD	HL,V_EGCNT
	DEC	(HL)
	PUSH	AF		; store flag!
	CALL	PRINTEGGCOUNT
	POP	AF		; restore flag
	RET	NZ
	LD	A,11		; level slow-exit marker
	LD	(L_FAB5),A
	RET

NOFIRE	LD	(V_FRCNT),A	; A=0 here
	RET

L_6FFA	RET			; (smc) nop/ret
	XOR	A
	LD	(DRWSHOO+1),A
	LD	A,(L_FAA1)	; fire pressed?
	AND	A
	JR	Z,NOFIRE

	LD	A,(V_FRCNT)
	XOR	1		; will be 1 at first time
	LD	(V_FRCNT),A	; and if 0, then
	RET	Z		; don't shoot right now

	LD	A,(L_FAB2)	; type of weapon
	AND	A		; axe?
	JR	Z,IS_AXE

	LD	A,1
	LD	(DRWSHOO+1),A
	CALL	L_71A6		; check for monster's health dec
	CALL	L_70AE		; print/check bullets count

SHOOTFX	LD	DE,#0200	; shoot sound fx
NOISEFX	LD	B,#00
	LD	HL,#0000
L_7046	LD	A,(HL)
	AND	#10
	OR	B
	OUT	(#FE),A
	INC	HL
	DEC	DE
	LD	A,D
	OR	E
	JR	NZ,L_7046
	RET

IS_AXE	LD	A,1
	LD	(DRWSHOO+1),A

	LD	B,#04		; hit distance
	CALL	L_717E
	JP	L_71A9		; check for monster's health dec

DRWWEAP	LD	A,(L_FAB2)	; type of weapon
	AND	A		; axe?
	JR	Z,DRWAXE

	LD	A,(DRWSHOO+1)	; shoot?
	AND	A
	JR	NZ,DRGSHOO
L_7013	LD	HL,L_AD24	; else drawing
	LD	BC,#0A0F	; gun without fire
	JP	L_9BX0

DRGSHOO	LD	HL,L_AD24
	LD	BC,#0B10
	CALL	L_9BX0
	LD	HL,L_B23F
	LD	BC,#090F
	JP	L_9BX0

DRWAXE	LD	BC,#0C0F
DRWSHOO	LD	A,1		; (var)
	AND	A
	JR	Z,DRWAXE1
	LD	BC,#090E
DRWAXE1	LD	HL,SPR_TRIDENT
	JP	L_9BX0

BOOMBC	LD	HL,L_C54A
	PUSH	DE
	CALL	L_9BX0
	CALL	FXBEEP3	; SOUND FX
	POP	DE
	RET

;==================================================
; DEC HEALTH
;==================================================

DECHEAL	RET		; smc nop/ret
	PUSH	BC
	CALL	DECHEA1
	CALL	L_7133
	XOR	A
	LD	(REDFILL),A
	POP	BC
	RET

REDFILL	RET		; smc nop/ret
	LD	A,#C9
	LD	(REDFILL),A
	LD	A,(L_FAAF)
	AND	A
	JR	Z,REDINK
	LD	A,#15	; red paper color
DOFIL	JP	ATRFILL
REDINK	LD	A,2	; red ink color
	JR	DOFIL

DECHEA1	CALL	FXBEEP2
	LD	A,(L_FAAF)	; жизнь игрока

	DEC	A

;---	AND	A
;---	JR	NZ,L_723D
;---	LD	A,#01

	CP	#FA
	JR	C,L_723D
	XOR	A
L_723D	LD	(L_FAAF),A
	LD	A,(L_FAB0)	; доспехи
	DEC	A
	DEC	A
	DEC	A
	CP	#FA
	JR	C,L_724B
	XOR	A
L_724B	LD	(L_FAB0),A
	AND	A
	RET	NZ
	LD	A,(L_FAAF)
	DEC	A
	DEC	A
	DEC	A
	CP	#FA
	JR	C,L_725C
	XOR	A
L_725C	LD	(L_FAAF),A
	RET

L_7270	LD	HL,(L_FAA3)	; проверка на наличие
	DEC	H		; монстра поблизости, с
	DEC	H		; любой стороны от игрока
	DEC	L		; (оригинальная версия)
	DEC	L
	LD	B,#05
L_727B	PUSH	BC
	LD	B,#05
L_727E
	LD	A,H
	CP	L_UMAP/256	; in map?
	JR	C,L_7285	; not in map
	CP	L_UMAP/256+30
	JR	NC,L_7285	; not in map

	LD	A,(HL)
	CP	#C0		; monster? (was #D0)
	JR	C,L_7285
	POP	BC		; yes, monster found!
	RET
L_7285	INC	L
	DJNZ	L_727E
	LD	A,L
	SUB	5
	LD	L,A
	INC	H
	POP	BC
	DJNZ	L_727B
	XOR	A		; (!) чтобы позицию
	RET			; не принять за врага

CHECKDEATH
	LD	A,(L_FAAF)
	AND	A
	RET	NZ
	IF DEATH=0
	RET
	ENDIF
cheath	LD	DE,TX6466	; player's death
	CALL	PRINT
	LD	A,#01		; player's death marker
	LD	(L_FAB5),A	; set main game state
	RET

FXGAMEOVER
	LD	B,12
FXGOB	PUSH	BC
	CALL	L_72C4
	POP	BC
	DJNZ	FXGOB
	RET

L_72C4	LD	HL,#2000
	LD	A,(L_FABC)
	LD	C,A
	LD	A,(L_FABB)
	LD	D,A
	LD	A,#17
L_72D1	LD	B,D
L_72D2	DJNZ	L_72D2
	LD	A,(HL)
	AND	#10
	OUT	(#FE),A
	INC	HL
	DEC	C
	JR	NZ,L_72D1
	LD	A,(L_FAB6)
	LD	HL,L_FABB
	ADD	A,(HL)
	LD	(HL),A
	RET
;
L_72E8	LD	HL,(L_FAA3)
	LD	A,(HL)
	CP	#62
	RET	NZ
	LD	A,#02		; level complete marker
	LD	(L_FAB5),A
	RET

;==================================================
; SHOW MAP (L_7350)
;==================================================

MFW	EQU	#64		; first visible block

L_72F5	LD	B,#08
L_72F7	PUSH	BC
	LD	B,#20
L_72FA	PUSH	BC
	LD	C,#00
	LD	A,(HL)
	CP	MFW
	JR	C,L_7304
	SET	7,C
L_7304	INC	HL
	LD	A,(HL)
	CP	MFW
	JR	C,L_730C
	SET	6,C
L_730C	INC	HL
	LD	A,(HL)
	CP	MFW
	JR	C,L_7314
	SET	5,C
L_7314	INC	HL
	LD	A,(HL)
	CP	MFW
	JR	C,L_731C
	SET	4,C
L_731C	INC	HL
	LD	A,(HL)
	CP	MFW
	JR	C,L_7324
	SET	3,C
L_7324	INC	HL
	LD	A,(HL)
	CP	MFW
	JR	C,L_732C
	SET	2,C
L_732C	INC	HL
	LD	A,(HL)
	CP	MFW
	JR	C,L_7334
	SET	1,C
L_7334	INC	HL
	LD	A,(HL)
	CP	MFW
	JR	C,L_733C
	SET	0,C
L_733C	INC	HL
	LD	A,C
	LD	(DE),A
	INC	DE
	POP	BC
	DJNZ	L_72FA
	PUSH	HL
	LD	HL,#00E0
	ADD	HL,DE
	EX	DE,HL
	POP	HL
	POP	BC
	DJNZ	L_72F7
	RET

L_7350	XOR	A
	LD	BC,#0080
	CALL	SATRS58
	LD	DE,TXCLEAR+3
	LD	BC,#0300
	CALL	PRINT
	CALL	FXCLICK

	LD	HL,L_UMAP
	LD	DE,#4000
	CALL	L_72F5
	LD	DE,#4020
	CALL	L_72F5
	LD	DE,#4040
	CALL	L_72F5
	LD	DE,#4060
	LD	B,6
	CALL	L_72F7
	LD	A,6
	LD	BC,#0080
	CALL	SATRS58
	LD	BC,(V_EXMAP)
	LD	HL,MAPEXITMARK
	CALL	DRAWSPR_REAL

SWMAP2	CALL	KBDJOY	; ждем отпускания
	BIT	5,A	; клавиши карты
	JR	NZ,SWMAP2

SWMAP1	CALL	OVERATR
	EI
	HALT
	HALT
	HALT
	LD	BC,(L_FAA3)
	ld a,#ff
	sub b
	add #90
	ld b,a
	CALL	point
	CALL	KBDJOY
	BIT	5,A
	JR	NZ,MAPOFF
	JR	SWMAP1
point
	display $
	call #22aa
	ld b,a
	inc b
	ld a,#01
.l1
	rrca
	djnz .l1
	xor (hl)
	ld (hl),a
	ret
MAPOFF	CALL	KBDJOY	; ждем отпускания
	BIT	5,A	; клавиши карты
	JR	NZ,MAPOFF

	XOR	A
	LD	BC,#0080
	CALL	SATRS58
	JP	CLEARLINE

OVERATR	LD	DE,ATTR1
	LD	BC,4		;выводим управляющие коды для новых
	JP	8252        	;временных атрибутов

ATTR1	DEFB	21,1		; OVER1
	DEFB	16,6		; INK

L_73CD	LD	A,D		;летающая смерть (вывод и влияние на игрока) 
	LD	B,#06
	CP	#07
	JR	C,L_73DB
	LD	HL,L_D50E
	JP	L_9BX0

L_73DB	CP	#03
	JR	C,L_73E4
	LD	HL,L_D50E+11*11+1
	JR	L_73E7

L_73E4	LD	HL,L_D50E+122+22*11+1
L_73E7	CALL	L_9BX0
	JP	DECHEAL

L_73F1	LD	HL,(L_FABD)	;движение летающей смерти
	LD	A,(HL)
	CP	#A4
	JR	NZ,L_73FB
	LD	(HL),0
L_73FB	LD	A,(L_FABD)
	DEC	A
	LD	(L_FABD),A
	LD	HL,(L_FABD)
	XOR	A
	CP	(HL)
	RET	NZ
	LD	(HL),#A4
	RET

L_740D	LD	A,D
	LD	B,#08
	CP	#07
	JR	C,L_741D
	LD	HL,L_9D93
	JP	L_9BX0
L_741D	CP	#04
	JR	C,L_742A
	LD	HL,L_9DAB
	JP	L_9BX0
L_742A	LD	HL,L_9E31
	JP	L_9BX0

L_7432	LD	A,D
	LD	B,#08
	CP	#07
	JR	C,L_7440
	LD	HL,L_9D9F
	JP	L_9BX0

L_7440	CP	#04
	JR	C,L_744B
	LD	HL,L_9DEE
	JP	L_9BX0
L_744B	LD	HL,L_9E95
	JP	L_9BX0

L_7453	LD	A,(L_FAAB)	; муха
	AND	A
	CALL	Z,L_740D
	LD	A,(L_FAAB)
	CP	1
	CALL	Z,L_7432
	CALL	L_70F0		; она перед нами?
	CP	#A3
	RET	NZ
	JP	DECHEAL

;==================================================
; MAIN GAME LOOP
;==================================================

L_7530	XOR	A		; enable dec health
	LD	(DECHEAL),A
	LD	(DOORVIS+1),A

	CALL	KBDJOY
	CALL	L_7FB0		; kbdjoy -> game's key
	CALL	VCLEAR		; clear VSCR

	LD	A,(L_FA9F)	; ctrl: left-right
	CP	#02		; left?
	CALL	Z,L_775E
	LD	A,(L_FA9F)	; ctrl: left-right
	CP	#01		; right?
	CALL	Z,L_776C
	LD	A,(L_FAA0)	; ctrl: forward-back
	CP	#01		; forward?
	CALL	Z,L_7795
	LD	A,(L_FAA0)	; ctrl: forward-back
	CP	#02		; back?
	CALL	Z,L_7053

	CALL	BACKGROUND
	CALL	L_7AA2		; движение монстров
	CALL	L_777A

	CALL	L_6FFA		; weapon processing
	XOR	A		; (кроме первого раза)
	LD	(L_6FFA),A	; а теперь включить его

	CALL	CHECKDEATH
	LD	A,(L_FA9F)	; ctrl left/right
	AND	A
	CALL	NZ,DRAW_COMPASS
	CALL	LOOPS

	CALL	EXPLODE
	CALL	OPEN_DOORS

	PUSH	IY
	CALL	L_6E4A		; рассчет рейкастинга, затем вывод
	POP	IY

	CALL	L_7C86
	CALL	L_7AD2		; некоторые события, объекты
	CALL	ISKRA

	CALL	L_7D41		; player's dec life by monster
	CALL	DRWWEAP		; weapon drawing

	CALL	REDFILL

	LD	A,(L_FAB5)	; main state byte
	AND	A
	JR	Z,NOEXIT
	CP	3		; if 1..2 then
	RET	C		; exit main loop
	DEC	A		; else dec state byte
	LD	(L_FAB5),A	; (slow-exit)
NOEXIT
	CALL	PUTVRT
	CALL	EXPLODE

	LD	A,(P1CTRL)
	BIT	5,A
	CALL	NZ,L_7350	; show map

	LD	A,(L_FAB8)	; time to line clear
	DEC	A
	LD	(L_FAB8),A
	AND	A
	CALL	Z,CLEARLINE

	CALL	GOATMUS6
	JP	L_7530

;==================================================

EXPLODE	LD	IX,EXPDATA
	LD	A,(IX)
	AND	A
	RET	Z
	DEC	A
	LD	(IX),A
	LD	E,(IX+1)
	INC	E
	LD	(IX+1),E

	CALL	SETSCREEN_REAL

	LD	B,5
EXPLOD1	PUSH	BC
	INC	IX
	INC	IX
	LD	A,(IX)
	ADD	A,B
	SUB	3
	LD	(IX),A
	LD	C,A
	LD	A,(IX+1)
	ADD	A,E
	LD	(IX+1),A
	LD	B,A

	LD	A,B
	CP	19
	JR	NC,EXPLOD2
	LD	A,C
	CP	29
	JR	NC,EXPLOD2

	LD	HL,SPR_BOOM2
	PUSH	DE
	CALL	DRAWSPR
	POP	DE
EXPLOD2	POP	BC
	DJNZ	EXPLOD1

	CALL	SETSCREEN_VIRTUAL

EXPLODE_SOUND
	LD	DE,#00AA
	CALL	NOISEFX
	LD	A,(EXPDATA+1)
	ADD	A,8
	ADD	A,A
	ADD	A,A
	LD	C,A
	LD	A,110
	SUB	C
	SRL	A
	SRL	A
	SRL	A
	INC	A
	LD	B,A
	JP	FXBEEP

EXPDATA	DEFB	0,-4
	DEFW	#0C0F
	DEFW	#0C0F
	DEFW	#0C0F
	DEFW	#0C0F
	DEFW	#0C0F

EXPLNEW	LD	HL,#FC16	; 22, -4
	LD	(EXPDATA),HL
	LD	DE,#0C0F
	LD	B,5
	LD	HL,EXPDATA+2
EXPNEW1	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	DJNZ	EXPNEW1
	RET

;==================================================

BACKGROUND
	LD	HL,SPR_BKG1
	LD	BC,#000F
	CALL 	DRAWSPR

	LD	HL,VATTR+32*8+1
	LD	DE,VATTR+32*8+2
	LD	BC,28
	LD	(HL),1
	LDIR
	LD	HL,VSCR+2048+1
	LD	DE,VSCR+2048+2
	CALL	HRZNT0
	LD	(HL),170
	CALL	HRZNT
	CALL	HRZNT0
	LD	(HL),%01000100
	CALL	HRZNT
	CALL	HRZNT0
	CALL	HRZNT0
	LD	(HL),%00010000
	CALL	HRZNT
	CALL	HRZNT0

	LD	B,4		; moon Y for level 5
	LD	A,(LEVEL)
	CP	5
	JR	Z,MOON
	CP	6
	RET	NZ

MOON_AND_HOUSE
	LD	B,#06
	LD	A,(L_FAA2)
	DEC	A
	AND	3
	ADD	A,A
	LD	C,A
	LD	HL,SPR_HOUSE
	CALL	DRAWSPR
	LD	A,8
	ADD	A,C
	LD	C,A
	CALL	DRAWSPR
	LD	A,8
	ADD	A,C
	LD	C,A
	CALL	DRAWSPR
	LD	A,8
	ADD	A,C
	LD	C,A
	CALL	DRAWSPR

	LD	B,2
MOON	LD	A,(L_FAA2)
	DEC	A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,200
	LD	C,A
	LD	A,-1
	LD	(SPRDIR),A
	LD	HL,SPR_MOON
	CALL	DRAWSPR
	XOR	A
	LD	(SPRDIR),A
	DEC	C
	LD	HL,SPR_MOON+6*11+1
	CALL	DRAWSPR
	LD	HL,SPR_MOON
	JP	DRAWSPR

HRZNT0	LD	(HL),0
HRZNT	LD	BC,28
	LDIR
	LD	BC,-28+256
	ADD	HL,BC
	LD	D,H
	LD	E,L
	INC	DE
	RET

;==================================================
; DRAWING WALLS
;==================================================

SET_COLORS_FOR_WALLS
	LD	(V_WLCLR),HL
	LD	A,H
	LD	(L_9FF4+3),A
	LD	(L_9FF4+6),A
	LD	(L_9FF4+9),A
	LD	(L_9FF4+12),A
	LD	(L_9FF4+15),A
	LD	(L_A02C+3),A
	LD	(L_A02C+6),A
	LD	(L_A02C+9),A
	LD	(L_A02C+12),A
	LD	(L_A02C+15),A
	LD	(L_A064+3),A
	LD	(L_A064+6),A
	LD	(L_A064+9),A
	LD	(L_A086+3),A
	LD	(L_A086+6),A
	LD	(L_A086+9),A
	LD	A,L
WAL1CLR	LD	(L_9CDF+3),A
	LD	(L_9CDF+6),A
	LD	(L_9CDF+9),A
	LD	(L_9CDF+12),A
	LD	(L_9CDF+15),A
	LD	(L_9D17+3),A
	LD	(L_9D17+6),A
	LD	(L_9D17+9),A
	LD	(L_9D17+12),A
	LD	(L_9D17+15),A
	LD	(L_9D4F+3),A
	LD	(L_9D4F+6),A
	LD	(L_9D4F+9),A
	LD	(L_9D71+3),A
	LD	(L_9D71+6),A
	LD	(L_9D71+9),A
	RET

L_79A0	LD	B,#07
	LD	HL,L_9FF4
	JP	L_9BX0
L_79AA	LD	B,#07
	LD	HL,L_A02C
	JP	L_9BX0
L_79B3	LD	B,#08
	LD	HL,L_A064
	JP	L_9BX0
L_79BC	LD	B,#08
	LD	HL,L_A086
	JP	L_9BX0

L_79C5	LD	A,(V_WLCLR+1)	; фиолетовая стена
	LD	(WALCLR+1),A
	LD	A,D
	CP	#0D
	JR	Z,L_79BC
	CP	#0C
	JR	Z,L_79B3
	CP	#0B
	JR	Z,L_79AA
	CP	#0A
	JR	Z,L_79A0
	LD	HL,WALPAT2
	LD	(CALWAL1+1),HL
	LD	(CALWAL2+1),HL
	JR	L_771X

L_771B	LD	HL,WALPAT
	LD	(CALWAL1+1),HL
	LD	(CALWAL2+1),HL
	LD	A,(V_WLCLR)
	LD	(WALCLR+1),A
	LD	A,D		; белая стена
	CP	#0D
	JR	Z,L_7712
	CP	#0C
	JR	Z,L_7709
	CP	#0B
	JR	Z,L_7700
	CP	#0A
	JR	Z,L_76F6
L_771X	CP	#09
	JR	Z,L_76D6
	CP	#08
	JR	Z,L_76B8
	CP	#07
	JR	Z,L_7699
	CP	#06
	JR	Z,L_767A
	CP	#05
	JR	Z,L_7650
	CP	#04
	JR	Z,L_7624
	CP	#03
	JR	Z,L_75FA
	CP	#02
	JR	Z,L_75CF
	CP	#01
	JR	Z,L_75B0
	RET

L_75B0	JP	FULL_WALL	; самая ближняя стена
L_75CF	LD	A,#02-2		; стена на дистанции 2
	LD	B,#0F+2-#02-4
	JR	WALL_B
L_75FA	LD	A,#03-2		; стена на дистанции 3
	LD	B,#0E+2-#03-4
	JR	WALL_B
L_7624	LD	A,#04-2		; стена на дистанции 4
	LD	B,#0D+2-#04-4
	JR	WALL_B
L_7650	LD	A,#04-2		; стена на дистанции 5
	LD	B,#0D+2-#04-4
	JR	WALL
L_767A	LD	A,#05-2		; стена на дистанции 6
	LD	B,#0C+2-#05-4
	JR	WALL_B
L_7699	LD	A,#05-2		; стена на дистанции 7
	LD	B,#0C+2-#05-4
	JR	WALL
L_76B8	LD	A,#06-2		; стена на дистанции 8
	LD	B,#0B+2-#06-4
	JR	WALL_B
L_76D6	LD	A,#06-2		; стена на дистанции 9
	LD	B,#0B+2-#06-4
	JR	WALL
L_76F6	LD	B,#07		; стена на дистанции 10
	LD	HL,L_9CDF
	JP	L_9BX0
L_7700	LD	B,#07		; стена на дистанции 11
	LD	HL,L_9D17
	JP	L_9BX0
L_7709	LD	B,#08		; стена на дистанции 12
	LD	HL,L_9D4F
	JP	L_9BX0
L_7712	LD	B,#08		; стена на дистанции 13
	LD	HL,L_9D71
	JP	L_9BX0

WALL_B	LD	DE,WALEL1+32
	JR	WALL+3
WALL	LD	DE,WALEL1
	PUSH	BC
	PUSH	BC
	PUSH	BC

	PUSH	DE
	CALL	#0E9E		;3742
	POP	DE
	LD	A,VSCROFF
	ADD	A,H
	LD	H,A
	LD	A,L
	ADD	A,C
	LD	L,A
	POP	BC		; restore height
	PUSH	HL		; store screen address

	LD	A,(L_FAA3)
	LD	C,A
	LD	A,(L_FAA4)
	XOR	C
	BIT	0,A
	JR	NZ,PRWALL1
	PUSH	HL
	LD	HL,64
	ADD	HL,DE		; DE:=DE+64
	EX	DE,HL
	POP	HL
PRWALL1	DUP 2
	DUP 7
	LD	A,(DE)
	LD	(HL),A
	INC	E
	INC	H
	EDUP
	LD	A,(DE)
	LD	(HL),A
	INC	E
	CALL	INC_Y
	EDUP

	PUSH	DE
CALWAL1	CALL	WALPAT
	POP	DE

	DUP 2
	DUP 7
	LD	A,(DE)
	LD	(HL),A
	INC	E
	INC	H
	EDUP
	LD	A,(DE)
	LD	(HL),A
	INC	E
	CALL	INC_Y
	EDUP

WALATTR	POP	HL		; restore screen addr
	LD	A,H
	AND	#18
	SRA	A
	SRA	A
	SRA	A
	ADD	A,VATRHI
	LD	H,A
WALCLR	LD	A,2		; color of the wall
	POP	BC		; restore height
	INC	B
	INC	B
	INC	B
	INC	B
	LD	DE,32
PRWALLA	LD	(HL),A
	ADD	HL,DE
	DJNZ	PRWALLA
	POP	BC
	RET

FULL_WALL
	PUSH	BC
	LD	B,12		; for attr section
	PUSH	BC		; for attr section
	LD	HL,VSCR
	LD	L,C
	PUSH	HL		; store screen address

	LD	B,16
CALWAL2	CALL	WALPAT
	JR	WALATTR

	;--------------

WALPAT
	LD	D,170		; set pattern
	LD	E,85
PRWALL2	LD	(HL),D
	INC	H
	LD	(HL),E
	INC	H
	LD	(HL),D
	INC	H
	LD	(HL),E
	INC	H
	LD	(HL),D
	INC	H
	LD	(HL),E
	INC	H
	LD	(HL),D
	INC	H
	LD	(HL),E
	CALL	INC_Y
	DJNZ	PRWALL2
	RET

WALPAT3	LD	DE,WALEL2+48	; set pattern addr
	LD	A,2
	JR	PRWALL7

WALPAT2	LD	DE,WALEL2	; set pattern addr
	LD	A,6
PRWALL7	PUSH	DE		; store pattern addr
	LD	C,A		; store pattern hght
PRWALL3	EXA
	LD	A,(DE)
	LD	(HL),A
	INC	E
	INC	H
	LD	A,(DE)
	LD	(HL),A
	INC	E
	INC	H
	LD	A,(DE)
	LD	(HL),A
	INC	E
	INC	H
	LD	A,(DE)
	LD	(HL),A
	INC	E
	INC	H
	LD	A,(DE)
	LD	(HL),A
	INC	E
	INC	H
	LD	A,(DE)
	LD	(HL),A
	INC	E
	INC	H
	LD	A,(DE)
	LD	(HL),A
	INC	E
	INC	H
	LD	A,(DE)
	LD	(HL),A
	INC	E
	EXA
	DEC	A
	JR	NZ,PRWALL4
	LD	A,C
	POP	DE		; restore pattern addr
	PUSH	DE		; store again
PRWALL4	PUSH	AF
	CALL	INC_Y
	POP	AF
	DJNZ	PRWALL3
	POP	DE		; finalize stack
	RET


;==================================================


L_775E	LD	A,(L_FAA2)	; player rotate left
	INC	A
	CP	#11
	JR	NZ,L_7768
	LD	A,#01
L_7768	LD	(L_FAA2),A
	;------------------
	; dragon change pos
	LD	A,(L_FAAE)
	CP	200
	RET	NC
	INC	A
	INC	A
	LD	(L_FAAE),A
	RET

L_776C	LD	A,(L_FAA2)	; player rotate right
	DEC	A
	CP	#00
	JR	NZ,L_7776
	LD	A,#10
L_7776	LD	(L_FAA2),A
	;------------------
	; dragon change pos
	LD	A,(L_FAAE)
	DEC	A
	LD	(L_FAAE),A
	RET

L_777A	LD	A,(L_FAA7)
	INC	A
	CP	#04
	JR	C,L_7784
	LD	A,#01
L_7784	LD	(L_FAA7),A
	LD	A,(L_FAA8)
	INC	A
	CP	#05
	JR	C,L_7791
	LD	A,#01
L_7791	LD	(L_FAA8),A
	RET

;==================================================
; Move Player Forward
;==================================================
L_7795	LD	A,(L_FAA6)
	INC	A
	CP	#02
	JR	NZ,L_779E
	XOR	A
L_779E	LD	(L_FAA6),A
	LD	A,(L_FAA2)	; player's rot angle
	CP	#05
	JP	Z,L_6FC0
	CP	#09
	JP	Z,L_6FEC
	CP	#0D
	JP	Z,L_6FD6
	CP	#03
	JR	NZ,L_77BE
	CALL	L_6FAA
	JP	L_6FC0

L_77BE	CP	#07
	JR	NZ,L_77C8
	CALL	L_6FC0
	JP	L_6FEC

L_77C8	CP	#0B
	JR	NZ,L_77D2
	CALL	L_6FEC
	JP	L_6FD6

L_77D2	CP	#0F
	JR	NZ,L_77DC
	CALL	L_6FD6
	JP	L_6FAA

L_77DC	CP	#01
	JP	Z,L_6FAA
	CP	#02
	JR	NZ,L_77F0
	LD	A,(L_FAA7)
	CP	#01
	CALL	Z,L_6FC0
	JP	L_6FAA
;
L_77F0	CP	#04
	JR	NZ,L_77FF
	LD	A,(L_FAA7)
	CP	#01
	CALL	Z,L_6FAA
	JP	L_6FC0
;
L_77FF	CP	#06
	JR	NZ,L_780E
	LD	A,(L_FAA7)
	CP	#01
	CALL	Z,L_6FEC
	JP	L_6FC0
;
L_780E	CP	#08
	JR	NZ,L_781D
	LD	A,(L_FAA7)
	CP	#01
	CALL	Z,L_6FC0
	JP	L_6FEC
;
L_781D	CP	#0A
	JR	NZ,L_782C
	LD	A,(L_FAA7)
	CP	#01
	CALL	Z,L_6FD6
	JP	L_6FEC
;
L_782C	CP	#0C
	JR	NZ,L_783B
	LD	A,(L_FAA7)
	CP	#01
	CALL	Z,L_6FEC
	JP	L_6FD6
;
L_783B	CP	#0E
	JR	NZ,L_784A
	LD	A,(L_FAA7)
	CP	#01
	CALL	Z,L_6FAA
	JP	L_6FD6
;
L_784A	CP	#10
	RET	NZ
	LD	A,(L_FAA7)
	CP	#01
	CALL	Z,L_6FD6
	JP	L_6FAA

L_7A35				; отрисовка монстра
MONCOLR	LD	A,4		; (var)
	LD	(SPRCOLR),A
	CALL	DRAWMONSTER
	LD	A,(MONCOLR+1)
	AND	A
	LD	A,0		; (don't use xor a here!)
	LD	(SPRCOLR),A
	LD	(MONCOLR+1),A
	RET	Z

	PUSH	BC
	INC	B
	INC	B
	CALL	BOOMBC
	POP	BC
	RET

DRAWMONSTER
	LD	A,D		;==== MONSTER ====
	CP	#0A
	JP	Z,L_7A8F
	CP	#09
	JP	Z,L_7A8F
	CP	#08
	JP	Z,L_7A8F
	CP	#07
	JP	Z,L_7A7C
	CP	#06
	JP	Z,L_7A7C
	CP	#05
	JP	Z,L_7A7C
	LD	B,#05
	CP	#04
	JR	Z,L_7A69
	CP	#03
	JR	Z,L_7A69
	LD	B,#06
	CP	#02
	JR	Z,L_7A69
	CP	#01
	JR	Z,L_7A69
	RET

L_7A69	CALL	SPR_MIRROR_TOGGLE
	LD	HL,L_A616
	PUSH	BC
	CALL	L_9BX0
	POP	BC
	XOR	A
	LD	(SPRDIR),A
	RET

L_7A7C	CALL	SPR_MIRROR_TOGGLE
	LD	HL,L_A2A4
	LD	B,#06
	PUSH	BC
	CALL	L_9BX0
	POP	BC
	XOR	A
	LD	(SPRDIR),A
	RET

L_7A8F	CALL	SPR_MIRROR_TOGGLE
	LD	HL,L_A0A8
	LD	B,#07
	PUSH	BC
	CALL	L_9BX0
	POP	BC
	XOR	A
	LD	(SPRDIR),A
	RET

ANGLE_DIFF
	; A=0..15, E=0..3
	CP	15
	JR	Z,PLANG1
	CP	3
	JR	C,PLANG1	; 15,0,1,2
	CP	7
	JR	C,PLANG2	; 3,4,5,6
	CP	11
	JR	C,PLANG3	; 7,8,9,10
	; 11,12,13,14
	LD	A,E
	DEC	A
	AND	3
	RET
PLANG1	LD	A,E
	DEC	A
	DEC	A
	AND	3
	RET
PLANG2	LD	A,E
	INC	A
	AND	3
	RET
PLANG3	LD	A,E
	AND	3
	RET

ABS	AND	A
	RET	P
	NEG
	RET

ENMDIST	; in IX = enemy structure
	LD	A,(L_FAA3)
	SUB	(IX+0)
	CALL	ABS
	LD	C,A
	LD	A,(L_FAA3+1)
	SUB	(IX+1)
	CALL	ABS
	ADD	A,C
	RET

SPR_MIRROR_TOGGLE
	LD	A,(L_FAAB)
	AND	A
	JR	Z,MIRTGL
	LD	A,-1
MIRTGL	LD	(SPRDIR),A
	RET

GOATMUS6	LD	B,6
GOATMUS	RET			;(smc) nop/ret
	LD	A,(JMUSDAT)	; music pos
	LD	HL,JMUSDAT+1	; begin of music data
	LD	D,0
	LD	E,A
	ADD	HL,DE
	LD	C,(HL)
	CALL	FXBEEP		; B must be defined!
GOATMUNX	LD	A,(JMUSDAT)	; music pos
	INC	A
	CP	16
	JR	C,GOATMUS1
	LD	A,#C9
	LD	(GOATMUS),A
	XOR	A
GOATMUS1	LD	(JMUSDAT),A
	RET

JMUSDAT	DEFB	0, 77,44,55,44,33,33,33,1, 77,44,55,44,88,88,88,1

CALCGOAT	SUB	#C0
	LD	E,A
	ADD	A,A		;*2
	ADD	A,E		;*3
	ADD	A,A		;*6
	LD	IX,GOATDATA
	LD	D,0
	LD	E,A
	ADD	IX,DE
	RET

GOATDEAD	LD	L,(IX)
	LD	H,(IX+1)
	LD	(HL),0		; clear in-map byte
	LD	(IX),0		; clear pos = delete GOAT
	LD	(IX+1),0
	CALL	EXPLNEW
	LD	HL,V_JTCNT
	DEC	(HL)		; козлы кончились?
	RET	NZ		; еще нет
	LD	A,(LEVEL)	; а если кончились
	CP	4		; и уровень 4-й
	RET	NZ
	LD	A,11		; level slow-exit marker
	LD	(L_FAB5),A
	RET

DRAWGOAT	PUSH	DE
	CALL	CALCGOAT

	LD	A,(IX+4)
	BIT	7,A		; check 'hit GOAT' marker
	RES	7,A		; clear marker
	LD	(IX+4),A
	JR	Z,NOHITJU
	LD	A,2
	LD	(SPRCOLR),A
	DEC	(IX+4)
	CALL	Z,GOATDEAD

NOHITJU	LD	A,(IX+4)
	CP	5
	JR	C,NORMGOAT
	LD	A,7+64		; immortal GOAT
	LD	(SPRCOLR),A
	
NORMGOAT	LD	A,(IX+2)	; GOAT-mon's rot.angle
	LD	E,A
	LD	A,(L_FAA2)	; player's rotation angle
	DEC	A
	CALL	ANGLE_DIFF
	POP	DE
	AND	A
	JR	Z,GOAT_FRONT
	DEC	A		; cp 1
	JR	Z,GOAT_RIGHT
	DEC	A		; cp 2
	JR	Z,GOAT_BACK

GOAT_LEFT
	LD	A,-1
	LD	(SPRDIR),A
GOAT_RIGHT
	LD	IX,GOATSPRS+16
	LD	A,(L_FAAB)
	AND	A
	JR	NZ,GOAT_FR0
	LD	IX,GOATSPRS+24
GOAT_FR0	LD	A,D
	CP	#0D
	JR	NC,GOAT_FR2	; т.к. вдалеке всегда лицом/задом
	CP	NEARESTGOAT
	JR	NC,GOAT_FR1
	JR	GOAT_FR2		; т.к. вблизи всегда лицом
GOAT_BACK
	LD	IX,GOATSPRS+8
	JR	GOAT_FR2
GOAT_FRONT
	LD	IX,GOATSPRS
GOAT_FR2	CALL	SPR_MIRROR_TOGGLE
GOAT_FR1	LD	B,9
	LD	L,(IX)
	INC	IX
	LD	H,(IX)
	INC	IX
	LD	A,D
	CP	#0C
	JP	NC,DRGOAT
	LD	B,9
	LD	L,(IX)
	INC	IX
	LD	H,(IX)
	INC	IX
	LD	A,D
	CP	#09
	JP	NC,DRGOAT
	LD	B,9		; was 8...
	LD	L,(IX)
	INC	IX
	LD	H,(IX)
	INC	IX
	CP	NEARESTGOAT
	JP	NC,DRGOAT
	LD	A,21		; was 20...
	SUB	D
	SRL	A
	LD	B,A
	LD	L,(IX)
	INC	IX
	LD	H,(IX)
DRGOAT	DEC	B		; slightly ^^^...
	CALL	L_9BX0
	XOR	A
	LD	(SPRDIR),A
	LD	(GOATMUS),A
	LD	A,(SPRCOLR)
	CP	2		; GOAT in blood?
	JR	Z,GOATBOOM
	AND	A
	RET	Z

FLAMGOAT	XOR	A
	LD	(SPRCOLR),A
	LD	A,(L_FAAB)	; counter 0/1
	NEG
	LD	(SPRDIR),A
	PUSH	BC
	PUSH	DE
	INC	B
	INC	B
	LD	A,(L_FAA5)	; counter 0..3
	AND	A
	CALL	Z,NEWISKR
	LD	HL,SPR_FLAME
	CALL	L_9BX0
	XOR	A
	LD	(SPRDIR),A
	POP	DE
	POP	BC
	RET

GOATBOOM	XOR	A
	LD	(SPRCOLR),A
	PUSH	BC
	INC	B
	INC	B
	INC	B
	CALL	BOOMBC
	POP	BC
	RET

GOATDATA	DEFW	#EA28, #2201, #0000
	DEFW	#EA2A, #2201, #0000
	DEFW	#EA2C, #2201, #0000
	DEFW	#EA2E, #2201, #0000
	DEFW	#E828, #2201, #0000
	DEFW	#E82A, #2201, #0000
	DEFW	#E82C, #2201, #0000
	DEFW	#E82E, #2201, #0000
	DEFW	#0000, #0000, #0000
	DEFW	#0000, #0000, #0000

GOATSPRS	DEFW	SPR_GOAT0, SPR_GOAT1, SPR_GOAT2, SPR_GOAT3	; front
	DEFW	SPR_GOAT0+8*11+1, SPR_GOAT1+27*11+3, SPR_GOAT2+55*11+3, SPR_GOAT3	; back
	DEFW	SPR_GOAT0, SPR_GOAT1+12*11+1, SPR_GOAT2+22*11+1, SPR_GOAT3	; LR phase 1
	DEFW	SPR_GOAT0, SPR_GOAT1+20*11+2, SPR_GOAT2+39*11+2, SPR_GOAT3	; LR phase 2

NEARESTGOAT EQU	5

GOATCNT	EQU	10

GOATWALK	LD	IX,GOATDATA
	LD	B,GOATCNT	; count of GOAT-monsters
GOATWLUP	LD	HL,(IX)		; (FAKE!)--------------
	LD	A,H
	AND	A		; zero pos = no monster
	JR	NZ,JTEXIST

	CALL	EMPTYJ2
	JR	EMPTYJ1

JTEXIST	LD	(HL),0		; clear GOAT at current pos
	LD	A,(IX+4)	; GOAT life / hit marker
	RES	7,A		; clear hit marker
	LD	(IX+4),A

	CALL	ENMDIST		; player<->enemy distance
	CP	3		; very close?
	JR	C,GOATMOV	; enemy don't moves

	LD	D,H		; store
	LD	E,L		; current pos
	DEC	(IX+3)		; time to change dir
	JR	Z,GOATROT

	LD	A,(IX+2)	; current rot.angle
	AND	A
	JR	Z,GOATDIR0
	DEC	A
	JR	Z,GOATDIR1
	DEC	A
	JR	Z,GOATDIR2

GOATDIR3	INC	L
	INC	L
	LD	A,(HL)
	AND	A
	JR	NZ,GOATROT
	DEC	L
	LD	A,(HL)
	AND	A
	JR	NZ,GOATROT
	JR	GOATMOV
GOATDIR0	DEC	H
	DEC	H

	LD	A,H
	CP	L_UMAP/256	; in map?
	JR	C,GOATROT	; not in map

	LD	A,(HL)
	AND	A
	JR	NZ,GOATROT
	INC	H
	LD	A,(HL)
	AND	A
	JR	NZ,GOATROT
	JR	GOATMOV
GOATDIR1	DEC	L
	DEC	L
	LD	A,(HL)
	AND	A
	JR	NZ,GOATROT
	INC	L
	LD	A,(HL)
	AND	A
	JR	NZ,GOATROT
	JR	GOATMOV
GOATDIR2	INC	H
	INC	H

	LD	A,H
	CP	L_UMAP/256+30
	JR	NC,GOATROT	; not in map

	LD	A,(HL)
	AND	A
	JR	NZ,GOATROT
	DEC	H
	LD	A,(HL)
	AND	A
	JR	NZ,GOATROT
	JR	GOATMOV

GOATROT	LD	H,D		; restore pos
	LD	L,E		; (don't move)
	LD	A,R		; random byte
	AND	%00000011	; 0..3
	LD	(IX+2),A
	LD	A,(IX+3)
	ADD	A,6
	LD	(IX+3),A	; inc time to change dir
GOATMOV	LD	A,#C0+GOATCNT	; GOAT-monsters idxs
	SUB	B
	LD	(HL),A
	LD	(IX),HL
EMPTYJ1	LD	DE,6
	ADD	IX,DE
;===	DJNZ	GOATWLUP
	DEC	B
	JP	NZ,GOATWLUP
	RET

EMPTYJ2	LD	A,(L_FAA5)
	AND	A		; просто делаем
	RET	NZ		; это чуть реже

	LD	A,(LEVEL)
	CP	4		; на 4-м уровне
	RET	Z		; новые не появляются

	CALL	RND_8
	LD	L,A
	CALL	RND_8
	CP	L_UMAP/256
	RET	C
	CP	L_UMAP/256+30
	RET	NC
	LD	H,A

	LD	A,(HL)
	AND	A
	RET	NZ
	LD	(IX),L
	LD	(IX+1),H
	CALL	ENMDIST		; player<->enemy distance
	CP	40		; довольно близко? (чтобы не
	JR	C,CANCELNEWGOAT	; появлялись в одной комнате)
	LD	(IX+2),#01
	LD	(IX+3),#22
	LD	(IX+4),#03	; GOAT's life
	LD	A,(LEVEL)
	CP	7		; ранее 7-го уровня появляются
	RET	C		; только обычные козлы
	CALL	RND_8
	CP	190
	RET	C
	LD	(IX+4),#7F	; almost-immortal GOAT
	RET

CANCELNEWGOAT
	LD	(IX),0
	LD	(IX+1),0
	RET

;==================================================

RND_8	LD	A,53
	ADD	A,A
	JR	NC,$+5
	LD	C,51
	XOR	C
	LD	C,A
	LD	A,R
	XOR	C 
	LD	(RND_8+1),A
	RET

;==================================================

ISKRA	LD	BC,#0000	; (var)
	LD	A,B
	CP	200
	RET	NC
	DEC	B
	DEC	B
	LD	(ISKRA+1),BC
	LD	HL,SPR_FLAME+7*11+1
	JP	L_9BX0

NEWISKR	LD	(ISKRA+1),BC
	RET

;==================================================
; ENEMIES ON LEVELS
;==================================================

L_7AA2	LD	A,(LEVEL)	; enemy list on levels
	AND	A
	JR	Z,LEV0_ENEMIES
	DEC	A
	JR	Z,LEV1_ENEMIES
	DEC	A
	JR	Z,LEV2_ENEMIES

	CP	3		; (!)
	JR	Z,LEV5_ENEMIES

	; default

LEV1_ENEMIES
	CALL	L_7AF0		; движение монстра-быка
	CALL	GOATWALK	; движение монстра-козла
LEV0_ENEMIES
	JP	L_7C49		; дракон на заднем плане

LEV5_ENEMIES
	CALL	WAVMOV
LEV2_ENEMIES
	CALL	L_73F1		; летающая смерть
	JR	LEV1_ENEMIES

;==================================================

L_7AD2	CALL	L_7D64
	CALL	L_7D98
	CALL	L_7F30
	JP	L_72E8

L_7AF0	LD	IX,L_FAA9	; Bull xy
	LD	A,(IX)
	AND	A		; Bull exists?
	RET	Z
	CALL	ENMDIST		; player<->enemy distance
	CP	3		; very close?
	RET	C		; enemy don't moves

	LD	A,(L_FAA9)	; движение монстра-быка
	LD	B,A
	DEC	B
	LD	A,(L_FAA3)
	CP	B
	JR	NC,L_7B0D
	LD	HL,(L_FAA9)
	DEC	L
	LD	A,(HL)		; проверка препятствия на пути
	CP	#11
	JR	NC,L_7B0D
	LD	(HL),#D0
	INC	L
	LD	(HL),#00
	DEC	L
	LD	(L_FAA9),HL
L_7B0D
	LD	A,(L_FAA9)
	LD	B,A
	INC	B
	LD	A,(L_FAA3)
	CP	B
	JR	C,L_7BA1
	LD	HL,(L_FAA9)
	INC	L
	LD	A,(HL)
	CP	#11
	JR	NC,L_7BA1
	LD	(HL),#D0
	DEC	L
	LD	(HL),#00
	INC	L
	LD	(L_FAA9),HL
L_7BA1
	LD	A,(L_FAA9+1)
	LD	B,A
	INC	B
	LD	A,(L_FAA4)
	CP	B
	JR	C,L_7BBE
	LD	HL,(L_FAA9)
	INC	H
	LD	A,(HL)
	CP	#11
	JR	NC,L_7BBE
	LD	(HL),#D0
	DEC	H
	LD	(HL),#00
	INC	H
	LD	(L_FAA9),HL
L_7BBE
	LD	A,(L_FAA9+1)
	LD	B,A
	DEC	B
	LD	A,(L_FAA4)
	CP	B
	JR	NC,L_7D40
	LD	HL,(L_FAA9)
	DEC	H
	LD	A,(HL)
	CP	#11
	JR	NC,L_7D40
	LD	(HL),#D0
	INC	H
	LD	(HL),#00
	DEC	H
	LD	(L_FAA9),HL

L_7D40	; монстр должен держаться на расстоянии от
	; правой стены - иначе тонет при отрисовке
	LD	HL,(L_FAA9)
	INC	H
	LD	A,(HL)
	AND	A
	JR	Z,MONWL1
	DEC	H
	DEC	H
	LD	A,(HL)
	AND	A
	JR	NZ,MONWL1
	LD	(HL),#D0
	LD	(L_FAA9),HL
	INC	H
	LD	(HL),0
MONWL1	LD	HL,(L_FAA9)
	DEC	L
	LD	A,(HL)
	AND	A
	RET	Z
	INC	L
	INC	L
	LD	A,(HL)
	AND	A
	RET	NZ
	LD	(HL),#D0
	LD	(L_FAA9),HL
	DEC	L
	LD	(HL),0
	RET

DRAW_COMPASS
	LD	A,(L_FAA2)	; compass
	LD	BC,#1315
	LD	HL,L_AF83
	CP	#01
	JR	NZ,L_7B20
	LD	HL,L_AF1F
L_7B20	CP	#05
	JR	NZ,L_7B27
	LD	HL,L_AFE7
L_7B27	CP	#09
	JR	NZ,L_7B2E
	LD	HL,L_B0AF
L_7B2E	CP	#0D
	JR	NZ,L_7B35
	LD	HL,L_B177
L_7B35	CP	#06
	JR	NZ,L_7B3C
	LD	HL,L_B04B
L_7B3C	CP	#07
	JR	NZ,L_7B43
	LD	HL,L_B04B
L_7B43	CP	#08
	JR	NZ,L_7B4A
	LD	HL,L_B04B
L_7B4A	CP	#0A
	JR	NZ,L_7B51
	LD	HL,L_B113
L_7B51	CP	#0B
	JR	NZ,L_7B58
	LD	HL,L_B113
L_7B58	CP	#0C
	JR	NZ,L_7B5F
	LD	HL,L_B113
L_7B5F	CP	#0E
	JR	C,L_7B66
	LD	HL,L_B1DB
L_7B66	JP	DRAWSPR_REAL

LOOPS	LD	A,(L_FAA5)	; loop 0..3
	INC	A
	AND	%00000011
	LD	(L_FAA5),A

	LD	A,(L_FAAB)	; loop 0..1
	XOR	1
	LD	(L_FAAB),A
	RET


L_7BC1	LD	A,D		;==== TREE ====
	CP	#0B
	JR	C,L_7BCF
	LD	B,#07
	LD	HL,L_B5FE
	JP	L_9BX0
;
L_7BCF	CP	#09
	JR	C,L_7BDC
	LD	B,#06
	LD	HL,L_B641
	PUSH	BC
	DEC	C
	JP	L_9BXX

L_7BDC	CP	#07
	JR	C,L_7BE9
	LD	B,#05
	LD	HL,L_B6C6
	PUSH	BC
	DEC	C
	JP	L_9BXX

L_7BE9	CP	#05
	JR	C,L_7BF6
	LD	B,#02
	LD	HL,L_B7F0
	PUSH	BC
	DEC	C
	DEC	C
	JP	L_9BXX
;
L_7BF6	DB	#00
	CP	#03
	JR	C,L_7C04
	LD	B,#01
	LD	HL,L_BA38
	PUSH	BC
	DEC	C
	DEC	C
	DEC	C
	JP	L_9BXX
;
L_7C04	LD	B,#01
	LD	HL,L_BDE0
	PUSH	BC
	DEC	C
	DEC	C
	DEC	C
	CALL	L_9BX0
	POP	BC
	LD	B,#08
	LD	HL,L_C05F
	PUSH	BC
	DEC	C
	DEC	C
	DEC	C
	JP	L_9BXX

OGRADA	LD	A,28		;=== OGRADA ===
	SUB	D
	SRL	A
	LD	B,A
	LD	A,D
	CP	#04
	JR	C,OGRADA4
	CP	#07
	JR	C,OGRADA3
	CP	#0A
	JR	C,OGRADA2
	LD	B,9
	LD	HL,SPR_OGRADA
	JP	L_9BX0
OGRADA2	LD	HL,SPR_OGRADA+11*2+1
	JP	L_9BX0
OGRADA3	LD	HL,SPR_OGRADA+11*5+2
	CALL	L_9BX0
	JR	OGWATER
OGRADA4
;	LD	HL,SPR_OGRADA+11*9+3
;	CALL	L_9BX0

	LD	DE,64
	LD	A,B
	CP	13
	JR	NZ,OGR4_1
	LD	DE,96
OGR4_1	PUSH	DE
	LD	H,VATTR/256+1
	LD	L,C
	ADD	HL,DE
	LD	A,5
	LD	DE,32
	LD	(HL),A
	ADD	HL,DE
	LD	(HL),A
	ADD	HL,DE
	LD	(HL),A
	ADD	HL,DE
	LD	(HL),A
	ADD	HL,DE
	LD	(HL),A
	LD	H,(VSCR+2048)/256
	LD	L,C
	POP	DE
	ADD	HL,DE
	LD	(HL),#00
	INC	H
	LD	(HL),#18
	INC	H
	LD	(HL),#3C
	INC	H
	LD	(HL),#56
	INC	H
	LD	(HL),#AB
	INC	H
	LD	(HL),#56
	INC	H
	LD	(HL),#00
	INC	H
	LD	(HL),#26
	CALL	INC_Y
	LD	DE,#4A16
	CALL	OGR4_2
	CALL	INC_Y
	CALL	OGR4_2
	CALL	INC_Y
	LD	DE,#4A04
	CALL	OGR4_2
	CALL	INC_Y
	LD	DE,#4204
	CALL	OGR4_2

OGWATER	LD	H,VATTR/256+1
	LD	L,C
	LD	A,1
	CP	(HL)
	RET	NZ
	LD	(HL),13
	LD	B,9		; Y for water sprites
	LD	DE,64
	ADD	HL,DE		; 2 strings below horizon
	XOR	A
	CP	(HL)
	JR	NZ,OGWAT1
	CALL	DRAW_WATER
	JR	OGWAVE
OGWAT1	LD	DE,-32
	ADD	HL,DE		; 1 string below horizon
	XOR	A
	CP	(HL)
	JR	NZ,OGWAVE
	CALL	DRAW_WATER1
OGWAVE	LD	A,R
	BIT	3,A
	RET	NZ
	LD	H,(VSCR+2048)/256
	LD	L,C
BKGA	LD	A,%01010000
	LD	(HL),A
	INC	H
BKGB	LD	A,170
	LD	(HL),A
	INC	H
	INC	H
BKGC	LD	A,%01000100
	LD	(HL),A
	INC	H
	INC	H
	INC	H
BKGD	LD	A,%00010000
	LD	(HL),A
	RET

;===	DEFB	#FF,#FF,#F5,#EF,#55,#AA,#10,#45
;===	DEFB	#10,#AA,#00,#45,#08,#00,#22,#00

OGR4_2	LD	(HL),D
	INC	H
	LD	(HL),E
	INC	H
	LD	(HL),D
	INC	H
	LD	(HL),E
	INC	H
	LD	(HL),D
	INC	H
	LD	(HL),E
	INC	H
	LD	(HL),D
	INC	H
	LD	(HL),E
	RET

DRAW_WATER1
	LD	(HL),1
	LD	H,(VSCR+2048)/256
	JR	DRAW_WT
DRAW_WATER
	LD	(HL),1
	LD	DE,32
	SBC	HL,DE
	LD	(HL),1
	SBC	HL,DE
	LD	H,(VSCR+2048)/256
	ADD	HL,DE
	CALL	DRAW_WT
	CALL	INC_Y
	LD	(HL),#10
	INC	H
	LD	(HL),#AA
	INC	H
	LD	(HL),#00
	INC	H
	LD	(HL),#45
	INC	H
	LD	(HL),#08
	INC	H
	LD	(HL),#00
	INC	H
	LD	(HL),#22
	INC	H
	LD	(HL),#00
	RET
DRAW_WT	LD	(HL),#FF
	INC	H
	LD	(HL),#FF
	INC	H
	LD	(HL),#F5
	INC	H
	LD	(HL),#EF
	INC	H
	LD	(HL),#55
	INC	H
	LD	(HL),#AA
	INC	H
	LD	(HL),#12
	INC	H
	LD	(HL),#45
	RET

WAVMOV	LD	A,(BKGA+1)
	RRCA
	LD	(BKGA+1),A
	LD	A,(BKGB+1)
	RRCA
	LD	(BKGB+1),A
	LD	A,(BKGC+1)
	RRCA
	LD	(BKGC+1),A
	LD	A,(BKGD+1)
	RRCA
	RRCA
	LD	(BKGD+1),A
	RET

L_7C1X	LD	A,6+64		;==== BOX ====
	LD	(SPRCOLR),A
	CALL	L_7C18
	XOR	A
	LD	(SPRCOLR),A
	RET

L_7C18	LD	A,D
	CP	#0B
	JR	C,L_7C26
	LD	B,#0A
	LD	HL,L_C218
	JP	L_9BX0
;
L_7C26	CP	#09
	JR	C,L_7C33
	LD	B,#0A
	LD	HL,L_C218+11*4+1
	JP	L_9BX0
;
L_7C33	CP	#06
	JR	C,L_7C40
	LD	B,#0B
	LD	HL,L_C218+11*4+11*9+2
	JP	L_9BX0
;
L_7C40	LD	A,16
	SUB	D
	LD	B,A
	LD	HL,L_C218+11*4+11*9+11*12+3
	JP	L_9BX0

L_7C49	LD	A,(LEVEL)
	CP	6
	RET	NC		; no dragons after level 5
	CP	4		; no dragons on level 4
	RET	Z		; (чтобы не смущал текст 'убей всех')

	LD	A,(L_FAA8)	;====DRAGON====
	LD	HL,L_C745+11*13+1
	CP	#01
	JR	NZ,L_7C56
	LD	HL,L_C745
L_7C56	CP	#03
	JR	NZ,L_7C5D
	LD	HL,L_C745+11*23+2
L_7C5D	LD	B,#03
	LD	A,(L_FAAE)
	DEC	A
	LD	(L_FAAE),A
	LD	C,A
	JP	L_9BX0

L_7C86	CALL	L_70F0
	CP	#92
	RET	NZ
	CALL	L_6440

	CALL	CLEARLINE
	LD	DE,TX63CC
	CALL	PRINT
	LD	DE,TX644E
	CALL	PRINT

	LD	A,1
	LD	(L_FAB2),A	; set gun
	LD	A,(L_FAB1)
	ADD	A,50		; add bullets
	CP	100
	JR	C,L_7CC9
	LD	A,99
L_7CC9	LD	(L_FAB1),A
	CALL	PRNTBUL		; print bullets
	JP	L_710B		; del object

EGG	LD	A,#0D
	SUB	D
	SRL	A
	ADD	A,7
	LD	B,A
	LD	HL,SPR_EGG
	LD	A,D
	CP	#0A
	JR	C,EGG2
EGGS	JP	DRAWSPR

EGG2	CP	#08
	JR	C,EGG3
	LD	HL,SPR_EGG+11+1
	JR	EGGS
EGG3	LD	HL,SPR_EGG+11*4+2
	JR	EGGS

STONE	LD	A,#0D
	SUB	D
	SRL	A
	ADD	A,8
	LD	B,A
	LD	HL,SPR_STONE
	LD	A,D
	CP	#0A
	JR	C,STONE2
STONES	JP	DRAWSPR
STONE2	CP	#08
	JR	C,STONE3
	LD	HL,SPR_STONE+11+1
	JR	STONES
STONE3	CP	#05
	JR	C,STONE4
	LD	HL,SPR_STONE+11*3+2
	JR	STONES
STONE4	LD	HL,SPR_STONE+11*3+11*5+3
	JR	STONES

L_7CCF	LD	A,D		; труп монстра
	CP	#0A
	JR	C,L_7CDX
	LD	B,#0A
	LD	HL,L_CD36
	PUSH	BC
	DEC	C
	JP	L_9BXX

L_7CDX	CP	#07
	JR	C,L_7CDD
	LD	B,#0A
	LD	HL,L_CD37
	PUSH	BC
	DEC	C
	DEC	C
	JP	L_9BXX

L_7CDD	CP	#04
	JR	C,L_7CEA
	LD	B,A
	LD	A,#0B
	SUB	B
	ADD	A,5
	LD	B,A

	LD	HL,L_CDDD
	PUSH	BC
	DEC	C
	DEC	C
	DEC	C
	JP	L_9BXX
;
L_7CEA	LD	B,A
	LD	A,#0C
	SUB	B
	ADD	A,2
	LD	B,A
	LD	HL,L_CEFC
	PUSH	BC
	DEC	C
	DEC	C
	DEC	C
	DEC	C
	JP	L_9BXX

L_7D41	CALL	L_7270		; some monster nearby?
	CP	#C0
	RET	C
	CP	#D1
	RET	NC		; no monsters nearby
	CP	#D0
	JR	NC,NRBNGOAT	; GOAT or not?
	XOR	A
	LD	(GOATMUS),A
NRBNGOAT	JP	DECHEAL		; player's life dec by monster

L_7D4D	LD	B,D
	SRL	B
	LD	A,#0F
	SUB	B
	LD	B,A

	LD	A,D
	CP	8
	JR	C,HEARTH1

HEARTH2	INC	B
	LD	HL,L_D1CC+178
	LD	A,(L_FAAB)
	AND	A
	JR	NZ,HEART2P
	LD	HL,L_D1CC+178+45
HEART2P	JP	L_9BX0

HEARTH1	LD	HL,L_D1CC
	LD	A,(L_FAAB)
	AND	A
	JR	NZ,L_7D60
	LD	HL,L_D1CC+100
L_7D60	JP	L_9BX0

L_7D64	CALL	L_70F0		; перед игроком - сердце?
	CP	#9E
	RET	NZ

	CALL	CLEARLINE
	LD	DE,TX63CC
	CALL	PRINT
	LD	DE,TFHEALZ
	CALL	PRINT

	CALL	L_710B
	LD	B,50
	LD	A,(L_FAAF)
	ADD	A,B
	CP	100
	JR	C,NOTMAX1
	LD	A,99
NOTMAX1	LD	(L_FAAF),A
	CALL	L_7133
	JP	L_6440

;==================================================
; MONSTER APPROACHING
;==================================================

L_7D98	LD	HL,(L_FAA3)	; player pos
	LD	A,(HL)		; map's byte
	AND	A
	RET	Z
	CP	3
	JR	Z,APRGOATS
	CP	1		; 1,2 - id запуска монстра
	JR	Z,APRMON1
	CP	2
	RET	NZ

	LD	A,-15
	LD	(MON_LR+1),A
	INC	A
	JR	APRMOXX
APRMON1	LD	A,15
	LD	(MON_LR+1),A
	DEC	A
APRMOXX	LD	(MON_TD+1),A
	LD	A,#07		; set the lifes
	LD	(L_FAAD),A	; of current monster
	CALL	APRMON
	LD	(L_FAA9),HL
	CALL	CLEARLINE
	XOR	A
	LD	(MONCOLR+1),A
	LD	DE,TX647B	; 'monster approaching'
	JP	PRINT

APRGOATS	LD	A,15		; козлы появляются
	LD	(MON_LR+1),A	; всегда только справа
	CALL	APRMON
	EX	DE,HL		; pos -> DE
	DEC	D
	CALL	SETGOAT0
	INC	E
	INC	E
	INC	E
	CALL	SETGOAT
	INC	D
	INC	D
	INC	E
	CALL	SETGOAT
	DEC	E
	DEC	E
	DEC	E
	JP	SETGOAT

APRMON	;--установка позиции монстра
	;--и удаление линии появления монстра--
	PUSH	HL
	LD	A,(HL)
	INC	L
	CP	(HL)
	JR	Z,MDEL_H
	DEC	L
	DEC	L
	CP	(HL)
	JR	Z,MDEL_H
	INC	L
	INC	H
	CP	(HL)
	JR	Z,MDEL_V
	DEC	H
	DEC	H
	CP	(HL)
	JR	Z,MDEL_V
	POP	HL		; выход на крайний случай
	LD	HL,#0000
	RET

MDEL_V	DEC	H
	CP	(HL)
	JR	NZ,MDEL_V1
	JR	MDEL_V
MDEL_V1	INC	H
	CP	(HL)
	JR	NZ,MDEL_V2
	LD	(HL),0
	JR	MDEL_V1
MDEL_V2	POP	HL
	LD	A,L
MON_LR	ADD	A,15
	LD	L,A
	JR	SETMONTOEMPTY

MDEL_H	DEC	L
	CP	(HL)
	JR	NZ,MDEL_H1
	JR	MDEL_H
MDEL_H1	INC	L
	CP	(HL)
	JR	NZ,MDEL_H2
	LD	(HL),0
	JR	MDEL_H1
MDEL_H2	POP	HL
	LD	A,H
MON_TD	ADD	A,14
	LD	H,A

SETMONTOEMPTY
	XOR	A
SMTE1	CP	(HL)
	RET	Z
	DEC	L	; проверяем свободную
	JR	SMTE1	; позицию всегда левее

;==================================================

L_7DDX	LD	A,7+64
	LD	(SPRCOLR),A
	CALL	L_7DD6
	XOR	A
	LD	(SPRCOLR),A
	RET

L_7DD6	LD	A,D		; объект ключ
	CP	#0A
	RET	NC
	LD	B,A
	SRL	A
	LD	A,#12
	SUB	B
	LD	B,A
	LD	HL,L_D289
	XOR	A
	CALL	L_9BX0

	CALL	L_70F0		; что перед игроком?
	CP	#9D		; ключ 2?
	JR	Z,GETKEY2
	CP	#9C		; ключ 1?
	RET	NZ

	LD	BC,#0C1F
	LD	HL,L_D289
	CALL	DRAWSPR_REAL

	LD	A,(L_KEYS)	; взяли ключ 1
	SET	0,A
GETKEYA	LD	(L_KEYS),A
	PUSH	BC
	CALL	L_6440
	CALL	CLEARLINE
	LD	DE,TX63CC
	CALL	PRINT
	LD	DE,TX63E2
	CALL	PRINT
	CALL	L_710B
	POP	BC
	RET

GETKEY2	LD	BC,#0F1F
	LD	HL,L_D289
	LD	A,7+64
	LD	(SPRCOLR),A
	CALL	DRAWSPR_REAL
	XOR	A
	LD	(SPRCOLR),A

	LD	A,(L_KEYS)	; взяли ключ 2
	SET	1,A
	JR	GETKEYA

;==================================================

OPEN_DOORS
	LD	A,(L_KEYS)
	AND	A
	RET	Z
	BIT	3,A
	JR	NZ,OPEN_DOOR1
	BIT	4,A
	JR	NZ,OPEN_DOOR2
	BIT	5,A
	JR	NZ,OPEN_DOOR3
	RET

OPEN_DOOR1
	CALL	CLEARKEY1
	LD	D,%11110110
	LD	E,#67
	JR	OPDOORS
OPEN_DOOR2
	CALL	CLEARKEY2
	LD	D,%11101101
	LD	E,#68
	JR	OPDOORS
OPEN_DOOR3
	CALL	CLEARKEY3
	LD	D,%11011011
	LD	E,#6A
OPDOORS	PUSH	BC
	LD	HL,L_UMAP
	LD	BC,#1E00
OPDOOR2	LD	A,(HL)
	CP	E
	JR	Z,OPDOOR1
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,OPDOOR2
	POP	BC
	LD	A,(L_KEYS)
	AND	D
	LD	(L_KEYS),A
	RET

OPDOOR1	LD	BC,#2626
	CALL	FXBEEP
	POP	BC
	LD	(HL),0
	INC	HL
	LD	A,(HL)
	CP	E
	JR	NZ,OPDOORH
	LD	(HL),0
	RET
OPDOORH	DEC	HL
	INC	H
	LD	A,(HL)
	CP	E
	RET	NZ
	LD	(HL),0
	RET

DOOR_OPEN_BEGIN
	SUB	#66		; #67,68,70 --> 1,2,4
	LD	E,A		; store
DOORVIS	LD	A,1		; (var)
	INC	A
	LD	(DOORVIS+1),A
	CP	16
	RET	C
	LD	A,(L_KEYS)
	LD	B,A		; store
	AND	E		; door same as key
	AND	A		; key=0?
	RET	Z
	BIT	0,A
	JR	NZ,OBEDUR1
	BIT	1,A
	JR	NZ,OBEDUR2
	BIT	2,A
	JR	NZ,OBEDUR3
	RET
OBEDUR1	LD	A,B
	SET	3,A
	JR	OBEDURS
OBEDUR2	LD	A,B
	SET	4,A
	JR	OBEDURS
OBEDUR3	LD	A,B
	SET	5,A
OBEDURS	LD	(L_KEYS),A
	RET

L_7EX1	CALL	DOOR_OPEN_BEGIN
	LD	A,5		; color of door 1
	JR	L_7EX
L_7EX2	CALL	DOOR_OPEN_BEGIN
	LD	A,7+64		; color of door 2
	JR	L_7EX

L_7E1F	CALL	DOOR_OPEN_BEGIN

	LD	A,64+6		; ==== двери ====
L_7EX	LD	(WALCLR+1),A
	CALL	WAL1CLR		; temp color for 'white' wall sprites

	LD	B,#08
	LD	A,D
	CP	13
	JR	Z,DOORD13
	CP	12
	JR	Z,DOORD12
	CP	11
	JR	Z,DOORD11

	LD	HL,WALPAT3
	LD	(CALWAL1+1),HL
	LD	(CALWAL2+1),HL

	LD	A,13
	SUB	D
	SRL	A
	INC	A
	LD	B,A
	LD	A,D
	CP	6
	JR	NC,DDOOR1
	LD	A,6
	SUB	D
	ADD	A,B
	LD	B,A
DDOOR1	LD	A,D
	SRL	A
	CALL	WALL
WAL1RES	LD	A,(V_WLCLR)	; restore color
	JP	WAL1CLR		; of 'white' wall

DOORD11	LD	B,#07		; на дистанции 11
	LD	HL,L_9D17
	CALL	L_9BX0
	JR	WAL1RES
DOORD12	LD	HL,L_9D4F
	CALL	L_9BX0
	JR	WAL1RES
DOORD13	LD	HL,L_9D71
	CALL	L_9BX0
	JR	WAL1RES

L_7E40	LD	A,D		;==== капли ====
	CP	#07
	JR	C,L_7E66
	LD	HL,L_D187
	LD	A,(L_FAA8)
	CP	#01
	JR	NZ,L_7E51
	LD	B,#08
L_7E51	CP	#02
	JR	NZ,L_7E57
	LD	B,#0A
L_7E57	CP	#03
	JR	NZ,L_7E5D
	LD	B,#0C
L_7E5D	CP	#04
	JP	Z,L_7EAC
	JP	L_9BX0

L_7E66	CP	#03
	JR	C,L_7E8B
	LD	HL,L_D193
	LD	A,(L_FAA8)
	CP	#01
	JR	NZ,L_7E76
	LD	B,#05
L_7E76	CP	#02
	JR	NZ,L_7E7C
	LD	B,#09
L_7E7C	CP	#03
	JR	NZ,L_7E82
	LD	B,#0E
L_7E82	CP	#04
	JP	Z,L_7EAC
	JP	L_9BX0

L_7E8B	LD	HL,L_D1AA
	LD	A,(L_FAA8)
	CP	#01
	JR	NZ,L_7E97
	LD	B,#03
L_7E97	CP	#02
	JR	NZ,L_7E9D
	LD	B,#09
L_7E9D	CP	#03
	JR	NZ,L_7EA3
	LD	B,#0F
L_7EA3	CP	#04
	JP	Z,L_7EAC
	JP	L_9BX0
;
L_7EAC	LD	B,#1E
	CALL	L_6442
	CALL	L_70F0
	CP	#A2
	RET	NZ
	JP	DECHEAL

L_7ECC	LD	A,D		; ===== HAND ON THE WALL (QUAKE sign, рука, ладонь) ====
	LD	B,#0A
	CP	11
	JR	C,L_7EDX
	LD	HL,L_D35X
	CALL	L_9BX0
	JR	L_7EF0

L_7EDX	CP	#08
	JR	C,L_7EDC
	LD	HL,L_D35C
	CALL	L_9BX0
	JR	L_7EF0

L_7EDC	CP	#05
	JR	C,L_7EE9
	LD	HL,L_D389
	CALL	L_9BX0
	JR	L_7EF0

L_7EE9	LD	HL,L_D3ED
	CALL	L_9BX0
L_7EF0	CALL	L_70F0		; что перед игроком?
	CP	#9B		; этот самый символ с рукой?
	RET	NZ
	CALL	L_6440		; 'get' sound fx
	CALL	L_710B		; delete object

	LD	A,(L_FAB7)	; количество собранных символов
	INC	A
	LD	(L_FAB7),A
	CP	1
	JR	Z,DRWSGN1

	LD	BC,#0B1F
	CALL	DRWSGN

	LD	A,(L_KEYS)	; взяли ключ 3 (=две руки)
	SET	2,A
	LD	(L_KEYS),A
	RET

DRWSGN1	LD	BC,#091F
DRWSGN	LD	HL,L_D35X
	JP	DRAWSPR_REAL

L_7F30	CALL	L_70F0		; FOUND ARMORS
	CP	#93
	RET	NZ
	LD	B,50
	LD	A,(L_FAB0)
	ADD	A,B
	CP	100
	JR	C,NOTMAX2
	LD	A,99
NOTMAX2	LD	(L_FAB0),A
	CP	#C9
	JR	C,L_7F48
	LD	A,#C8
	LD	(L_FAB0),A
L_7F48	CALL	CLEARLINE
	LD	DE,TX63D9
	CALL	PRINT
	LD	DE,TX63CC
	CALL	PRINT
	CALL	L_710B
	CALL	L_6440
	JP	L_7133

L_7FB0	LD	C,A
	LD	HL,#0000
	LD	(L_FA9F),HL
	LD	(L_FAA0),HL	; (it's for FAA1)

	BIT	0,C
	JR	Z,NOTB0
	LD	A,1
	LD	(L_FA9F),A
NOTB0	BIT	1,C
	JR	Z,NOTB1
	LD	A,2
	LD	(L_FA9F),A
NOTB1	BIT	2,C
	JR	Z,NOTB2
	LD	A,2
	LD	(L_FAA0),A
NOTB2	BIT	3,C
	JR	Z,NOTB3
	LD	A,1
	LD	(L_FAA0),A
NOTB3	BIT	4,C
	JR	Z,NOTB4
	LD	A,1
	LD	(L_FAA1),A
NOTB4
	RET

;==================================================
; DRAW SPRITES
;==================================================

L_9BXX	CALL	L_9BX0	; only for JPs!
	POP	BC	; no CALLs!
	RET

L_9BX0	DEC	B
	DEC	B	; and next DRAWSPR

	INCLUDE "Qsprt.txt"

DRAWSPR_REAL
	PUSH	HL
	CALL	SETSCREEN_REAL
	POP	HL
	XOR	A
	CALL	DRAWSPR
	JP	SETSCREEN_VIRTUAL

;==================================================

ATRFILL
;--	LD	HL,VATTR
;--	LD	DE,VATTR+1
;--	LD	(HL),A
;--	LD	BC,#0200
;--	LDIR

	LD	C,A		; store fill color
	LD	A,(VATTR)
	AND	%111000
	CP	16		; already red-filled
	RET	Z
	LD	A,C		; restore
	AND	%111000		; modify to hidden attr
	LD	B,A
	SRL	A
	SRL	A
	SRL	A
	OR	B
	LD	B,A		; store hidden attr
	LD	HL,VATTR
	LD	DE,32*16-2
ATRFL2	LD	(HL),B
ATRFL1	INC	HL
	DEC	DE
	LD	A,D
	OR	E
	RET	Z
	XOR	A		; current attr
	CP	(HL)		; is hidden?
	JR	Z,ATRFL2	; don't change
	LD	(HL),C
	JR	ATRFL1

CLEARLINE
	LD	DE,TXCLEAR
CLRLN1	CALL	PRINT
	LD	A,7
	LD	(#5800),A
	LD	HL,#5800
	LD	DE,#5801
	LD	BC,31
	LDIR
	LD	A,12
	LD	(L_FAB8),A	; время до исчезновения надписи
	RET

;-----------------------------------------------

	INCLUDE "Qvscr.txt"

;-----------------------------------------------
; Byte in range [00..99] to ASCII (2-char)
; Input: A = number to convert (if>99, then 99)
; Output: 2-digits ASCII string at (DE)
;-----------------------------------------------
B99TODECSTR
	CP	100
	JR	C,B99_OK
	LD	A,99
B99_OK	LD	L,A
	LD	H,0
	LD	DE,NUMSTR+3
	PUSH	DE
	CALL	B99DECS
	POP	DE
	RET
;-----------------------------------------------
; Shared part of num to string conversion procedures
;-----------------------------------------------

WRDDECS	LD	BC,-10000
	CALL	WRDDEC1
	LD	BC,-1000
	CALL	WRDDEC1
BYTDECS	LD	BC,-100
	CALL	WRDDEC1
B99DECS	LD	BC,-10
	CALL	WRDDEC1
	LD	C,B
WRDDEC1	LD	A,'0'-1
WRDDEC2	INC	A
	ADD	HL,BC
	JR	C,WRDDEC2
	SBC	HL,BC
	LD	(DE),A
	INC	DE
	RET

PRINTNUM
	PUSH	BC
	CALL	B99TODECSTR
	POP	BC
	JP	PRINT

CLEARGAMEWIN
	CALL	CLEARLINE
	LD	HL,VSCR
	LD	DE,VSCR+1
	LD	(HL),0
	LD	BC,2048*2-1
	LDIR
	LD	HL,VATTR
	LD	DE,VATTR+1
	LD	(HL),7
	LD	BC,16*32-1
	LDIR
	JP	PUTVRT

;-----------------------------------------------

CHANGESPRITECOLOR
	LD	B,(HL)
CHSPC1	INC	HL
	INC	HL
	INC	HL
	LD	A,(HL)
	CP	D
	JR	NZ,CHSPC2
	LD	(HL),E
CHSPC2	DJNZ	CHSPC1
	RET

;-----------------------------------------------
; Unpacking and creating maps
;-----------------------------------------------

GREEN_TREES
	LD	DE,#0604
	CALL	RED_TREES1
	LD	DE,#0207
	JR	RED_TREES1
RED_TREES
	LD	DE,#0406
	CALL	RED_TREES1
	LD	DE,#0702
RED_TREES1
	LD	HL,L_B5FE
	CALL	CHANGESPRITECOLOR
	LD	HL,L_B641
	CALL	CHANGESPRITECOLOR
	LD	HL,L_B6C6
	CALL	CHANGESPRITECOLOR
	LD	HL,L_B7F0
	CALL	CHANGESPRITECOLOR
	LD	HL,L_BA38
	CALL	CHANGESPRITECOLOR
	LD	HL,L_BDE0
	CALL	CHANGESPRITECOLOR
	LD	HL,L_C05F
	JP	CHANGESPRITECOLOR

EMPTY_MAP1
	LD	HL,L_UMAP
	LD	DE,L_UMAP+1
	LD	BC,30*256-1
	LD	(HL),0
	LDIR
	RET

RIAD	PUSH	BC
RIAD1	LD	(HL),D
	LD	A,C
	ADD	A,L
	LD	L,A
	DJNZ	RIAD1
	POP	BC
	RET

BOXIXI	LD	(IX+0),D
	LD	(IX+1),D
	LD	(IX+2),E
	LD	(IX+3),E
	LD	(IX+4),D
	LD	(IX+5),D
	INC	IXH
	RET

BOXIT1_01
	LD	BC,#0110
BOXIT1	PUSH	BC
BOXI1A	LD	DE,#6666
	CALL	BOXIXI
	CALL	BOXIXI
	LD	DE,#650A
	CALL	BOXIXI
	CALL	BOXIXI
	LD	DE,#6666
	CALL	BOXIXI
	CALL	BOXIXI
 .6	DEC	IXH
	LD	A,C
	ADD	A,IXL
	LD	IXL,A
	DJNZ	BOXI1A
	POP	BC
	RET

EXMAPL5	LD	IX,L_UMAP+256*7+14
	LD	BC,#0310
	CALL	BOXIT1
	LD	IX,L_UMAP+256*17+14
	LD	BC,#0310
	CALL	BOXIT1
	LD	IX,L_UMAP+256*7+78
	LD	BC,#0210
	CALL	BOXIT1
	LD	IX,L_UMAP+256*7+174
	LD	BC,#0210
	CALL	BOXIT1
	LD	IX,L_UMAP+256*17+78
	LD	BC,#0810
	CALL	BOXIT1
	LD	IX,L_UMAP+256*5+233
	CALL	BOXIT1_01
	LD	IX,L_UMAP+256*19+233
	JP	BOXIT1_01

EXMAPL8	CALL	RED_TREES
	JR	EXMAP71

EXMAPL7	LD	HL,L_UMAP
EXMAP72	LD	A,(HL)
	CP	#A0		; tree?
	JR	NZ,NOTTREE
	LD	(HL),0		; delete trees in hell
NOTTREE	INC	HL
	LD	A,H
	CP	L_UMAP/256+31
	JR	NZ,EXMAP72

EXMAP71	LD	DE,L_UMAP
	LD	HL,L_UMAP+256*29
	LD	B,15
EXMAP92	PUSH	BC
	LD	B,0	; 256
EXMAP91	LD	C,(HL)
	LD	A,(DE)
	LD	(HL),A
	LD	A,C
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	EXMAP91
	LD	BC,-512
	ADD	HL,BC
	POP	BC
	DJNZ	EXMAP92
	RET

REDOORA	CALL	REDOORB
	LD	A,(LEVEL)	; фиксированные дорисовки
	CP	2		; некоторых уровней
	JR	Z,EXMAPL2
	SUB	5		; cp 5
	JR	Z,EXMAPL5
	DEC	A		; cp 6
	JP	Z,EXMAPL6
	DEC	A		; cp 7
	JR	Z,EXMAPL7
	DEC	A		; cp 8
	JR	Z,EXMAPL8
	DEC	A		; cp 9
	JR	Z,EXMAPL9
	RET

EXMAPL2	LD	D,#A0		; object
	LD	BC,#0B04	; count and offset
	LD	HL,L_UMAP+256*10+5
	CALL	RIAD
	LD	HL,L_UMAP+256*19+5
	CALL	RIAD
	LD	B,14
	LD	HL,L_UMAP+256*18+179
	CALL	RIAD
	LD	B,9		; count
	LD	HL,L_UMAP+256*10+69
	CALL	RIAD
	LD	HL,L_UMAP+256*19+69
	CALL	RIAD
	LD	HL,L_UMAP+256*10+139
	CALL	RIAD
	LD	B,6
	LD	HL,L_UMAP+256*19+110
	CALL	RIAD

	LD	HL,L_UMAP+183
	CALL	HOUSEDN
	LD	HL,L_UMAP+194
	CALL	HOUSEDN
	LD	HL,L_UMAP+205
	CALL	HOUSEDN
	LD	HL,L_UMAP+216
	JP	HOUSEDN

EXMAPL9	LD	IX,L_UMAP+256*7+117
	LD	BC,#0210
	CALL	BOXIT1
	LD	IX,L_UMAP+256*18+117
	LD	BC,#0210
	CALL	BOXIT1
	XOR	A
	LD	(L_UMAP+124+256*6),A
	LD	(L_UMAP+130+256*6),A
	LD	(L_UMAP+124+256*24),A
	LD	(L_UMAP+130+256*24),A
	;-----SET EGGS-----
	LD	A,#DF
	LD	(L_UMAP+6+256*14),A
	LD	(L_UMAP+40+256*12),A
	LD	(L_UMAP+72+256*22),A
;====	LD	(L_UMAP+82+256*21),A === путается с предыдущим
	LD	(L_UMAP+216+256*14),A
	LD	(L_UMAP+186+256*8),A
	LD	(L_UMAP+194+256*24),A
	LD	A,6
	LD	(V_EGCNT),A
	;------------------
	JP	EXMAPL7

EXMAPL6	LD	BC,#0608	; count and offset
	LD	D,#A0		; object
	LD	HL,L_UMAP+256*2+107
	CALL	RIAD

	LD	IX,HTAB_DN
	LD	B,5
EXMAP61	LD	H,(IX+1)
	LD	L,(IX)
	CALL	HOUSEDN
	DJNZ	EXMAP61
	LD	B,6
EXMAP62	LD	H,(IX+1)
	LD	L,(IX)
	CALL	HOUSEUP
	DJNZ	EXMAP62
	RET

HTAB_DN	DEFW	L_UMAP+256*0+15
	DEFW	L_UMAP+256*6+89
	DEFW	L_UMAP+256*16+177
	DEFW	L_UMAP+256*16+197
	DEFW	L_UMAP+256*0+197

	DEFW	L_UMAP+256*16+15
	DEFW	L_UMAP+256*16+26
	DEFW	L_UMAP+256*6+72
	DEFW	L_UMAP+256*16+160
	DEFW	L_UMAP+256*16+208
	DEFW	L_UMAP+256*16+219

/*
	LD	HL,L_UMAP+256*0+15
	CALL	HOUSEDN
	LD	HL,L_UMAP+256*6+89
	CALL	HOUSEDN
	LD	HL,L_UMAP+256*16+177
	CALL	HOUSEDN
	LD	HL,L_UMAP+256*16+197
	CALL	HOUSEDN
	LD	HL,L_UMAP+256*0+197
	CALL	HOUSEDN

	LD	HL,L_UMAP+256*16+15
	CALL	HOUSEUP
	LD	HL,L_UMAP+256*16+26
	CALL	HOUSEUP
	LD	HL,L_UMAP+256*6+72
	CALL	HOUSEUP
	LD	HL,L_UMAP+256*16+160
	CALL	HOUSEUP
	LD	HL,L_UMAP+256*16+208
	CALL	HOUSEUP
	LD	HL,L_UMAP+256*16+219
	JP	HOUSEUP
*/

HOUSEUP	LD	DE,-256*9+5
	JR	HOUSES
HOUSEDN	LD	DE,-256*2+5
HOUSES
	PUSH	BC		; (v2)
	PUSH	DE
	CALL	HOUSE13
	CALL	HOUSEV5
	CALL	HOUSE13
	POP	DE
	ADD	HL,DE
	LD	B,3
	XOR	A
	CALL	HOUSEW		; (v2)
	INC	IX		; (v2) for outer proc
	INC	IX		; (v2)
	POP	BC		; (v2)
	RET			; (v2)
;===	JR	HOUSEW		;--v1

HOUSEV5	LD	A,#65
	LD	B,5
HOUSEV	LD	(HL),A
	INC	L
	LD	(HL),A
	LD	DE,10
	ADD	HL,DE
	LD	(HL),A
	INC	L
	LD	(HL),A
	LD	DE,244
	ADD	HL,DE
	DJNZ	HOUSEV
	RET
HOUSE13	LD	A,#66
	LD	B,13
HOUSEW	PUSH	BC
HOUSER	LD	(HL),A
	INC	L
	DJNZ	HOUSER
	INC	H
	POP	BC
HOUSEL	DEC	L
	LD	(HL),A
	DJNZ	HOUSEL
	INC	H
	RET

REDOORB	LD	IX,L_UMAP+30*256-1
	LD	DE,30*256
REDUR	LD	A,(IX)
	CP	10
	JR	Z,REDUR10
	JR	C,REDUR1
	CP	98		; level end mark
	JR	Z,REDUR1
	CP	#67		; door 1
	JR	Z,REDUR1
	CP	#68		; door 2
	JR	Z,REDUR1
	CP	#6A		; door 3
	JR	NZ,REDUR0
REDUR1	CP	(IX+1)		; если справа или слева
	JR	Z,REDUR0	; тот же номер,
	CP	(IX-1)		; значит элемент
	JR	Z,REDUR0	; горизонтальный
REDUR10	LD	C,A		; store byte
	PUSH	IX
	POP	HL
REDUR2	INC	H		; next map line
	XOR	A
	CP	(HL)		; place is empty?
	JR	NZ,REDURX
	LD	(HL),C
DRSINGL	JR	REDUR2
REDURX	LD	A,C		; одинарная черта готова
	CP	100		; а если двойная (дверь)?
	JR	C,REDUR0
	DEC	H
	PUSH	HL
	POP	IX
REDURD	CP	(IX)
	JR	NZ,REDURZ
	LD	(IX+1),A	; расширяем
	DEC	IXH
	JR	REDURD
REDURZ	INC	IXH		; возвращаемся на исходную
REDUR0	DEC	IX
	DEC	DE
	LD	A,D
	OR	E
	JR	NZ,REDUR
	RET

CREATEMAP
;===	PUSH	HL
;===	CALL	EMPTY_MAP1	; делаем это перед init
;===	POP	HL

CMAPVS	LD	A,(HL)
	INC	HL
CMAPVS1	LD	C,(HL)
	INC	HL
	INC	C		; cp c,255
	JR	Z,CMAPHS
	INC	C		; cp c,254
	JR	Z,CMAPVS
	DEC	C
	DEC	C
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	CALL	CMWALV
	JR	CMAPVS1

CMAPHS	LD	A,(HL)
	INC	HL
CMAPHS1	LD	C,(HL)
	INC	HL
	INC	C		; cp c,255
	JR	Z,CMAPSS
	INC	C		; cp c,254
	JR	Z,CMAPHS
	DEC	C
	DEC	C
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	CALL	CMWALH
	JR	CMAPHS1

CMAPSS	LD	A,(HL)
	INC	HL
	INC	A		; cp 255
	JP	Z,REDOORA
	DEC	A
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(DE),A
	JR	CMAPSS

CMWALV	PUSH	HL
	EX	DE,HL
	LD	B,C
MAPWV1	LD	(HL),A
	INC	L
	LD	(HL),A
	DEC	L
	INC	H
	DJNZ	MAPWV1
	POP	HL
	RET

CMWALH
XLDIR	PUSH	HL
	EX	DE,HL
	LD	B,0
	DEC	BC
	CALL	XLDIR1
	INC	H
	CALL	XLDIR1
	POP	HL
	RET
XLDIR1	PUSH	BC
	PUSH	HL
	LD	(HL),A
	LD	D,H
	LD	E,L
	INC	DE
	LDIR
	POP	HL
	POP	BC
	RET


;-----------------------------------------------
; SOUND	FX
;-----------------------------------------------

L_6440	LD	B,#C5
L_6442	XOR	A
L_6443	XOR	#10
	OUT	(#FE),A
	PUSH	BC
L_6448	DJNZ	L_6448
	POP	BC
	DJNZ	L_6443
	RET

FXCLICK	LD	BC,#4422
	CALL	FXBEEP
	LD	BC,#4433
	JR	FXBEEP

FXBEEP3	LD	C,4
	LD	B,80
	JR	FXBEEP
FXBEEP2	LD	C,250	; попадание в игрока: частота
	LD	B,6	; длительность
FXBEEP	LD	A,16
FXBEEPA	OUT	(254),A
	PUSH	BC
	LD	B,C
	DJNZ	$
	LD	B,C
	DJNZ	$
	POP	BC
	XOR	16
 	DJNZ	FXBEEPA
	RET

SOUND_STEP
	CALL	SOUND_TICK
SOUND_TICK
	PUSH	AF
	LD	A,16
	OUT	(254),A
  .16	NOP
	XOR	16
	OUT	(254),A
	POP	AF
	RET

;-----------------------------------------------

WALL_CAP_HOLES
	LD	IX,#9687+KK+29*2	;was*5; then *4
	LD	B,10			;was 3; then  8
WLCPH5	PUSH	BC
	LD	B,27
WLCPH1

;---	LD	A,(IX+1)	так всё равно
;---	AND	A		остаются дырки
;---	JR	NZ,WLCPH3

	LD	A,(IX)
	CP	#65
	JR	Z,WLCPH2
	CP	#66
	JR	Z,WLCPH2
	CP	#67
	JR	Z,WLCPH2
	CP	#68
	JR	Z,WLCPH2
	CP	#6A
	JR	NZ,WLCPH3
WLCPH2	CP	(IX+2)
	JR	Z,WLCPH4
	CP	(IX+2+29)
	JR	Z,WLCPH4
	CP	(IX+2-29)
	JR	Z,WLCPH4
	CP	(IX+2+29*2)
	JR	Z,WLCPH6
	CP	(IX+2-29*2)
	JR	NZ,WLCPH3
	LD	(IX+1-29),A
	JR	WLCPH3
WLCPH6	LD	(IX+1+29),A
	JR	WLCPH3
WLCPH4	LD	(IX+1),A
WLCPH3	INC	IX
	DJNZ	WLCPH1
	POP	BC
	INC	IX
	INC	IX
	DJNZ	WLCPH5

	LD	HL,#9687+KK	; clear invisible
	LD	DE,29		; wall sectors
	LD	B,29		; (z-buffering)
WFND0	PUSH	BC
	PUSH	HL
	LD	B,12
WFND1	LD	A,(HL)
	CP	#64
	JR	Z,WFND3
	CP	#65
	JR	Z,WFND2
	CP	#66
	JR	Z,WFND2
	ADD	HL,DE
	DJNZ	WFND1
WFND9	POP	HL
	INC	L
	POP	BC
	DJNZ	WFND0
	RET

WFND2	ADD	HL,DE
	LD	(HL),0
	DJNZ	WFND2
	JR	WFND9

WFND3	ADD	HL,DE
	CP	(HL)		; удаляем дубли в
	JR	NZ,WFND3A	; z-буфере только для
	LD	(HL),0		; указанного символа
WFND3A	DJNZ	WFND3
	JR	WFND9

SCR_ATTR_SET1
	LD	BC,767-32*8
SATRS58	LD	HL,#5800
SATRSET	LD	D,H
	LD	E,L
	INC	DE
	LD	(HL),A      
	LDIR
	RET

THAW	LD	B,8		;экран очищается за 8 циклов
	LD	DE,0		;адрес начала кодов ПЗУ
THAW1	LD	HL,VSCR		;адрес начала экранной области
	PUSH	DE
THAW2	LD	A,(DE)		;берем «случайный» байт из ПЗУ
	AND	(HL)		;объединяем с байтом из видеобуфера
	LD	(HL),A		;помещаем обратно в видеобуфер
	INC	HL		;переходим к следующим адресам
	INC	DE
	LD	A,H		;проверяем, нужно ли повторять цикл
	CP	VSCRHI+#10	;если прошли еще не весь видеобуфер
	JR	NZ,THAW2	; то повторяем
	PUSH	BC
	CALL	PUTVRT
	POP	BC
	POP	DE
	LD	HL,100
	ADD	HL,DE		;увеличиваем адрес в ПЗУ на 100
	EX	DE,HL		;меняем HL на DE
	DJNZ	THAW1		;повторяем цикл
	RET

INC_Y	INC	H
	LD	A,H
	AND	7
	RET	NZ
	LD	A,L
	ADD	A,32
	LD	L,A
	RET	C
	LD	A,H
	SUB	8
	LD	H,A
	RET


;-----------------------------------------------

;CLEARMAPSYM			; использовалось для
;	PUSH	BC		; удаления дверей
;	LD	HL,L_UMAP
;	LD	BC,#1E00
;L_7F20	LD	A,(HL)
;	CP	E
;	JR	NZ,L_7F28
;	LD	(HL),0
;L_7F28	INC	HL
;	DEC	BC
;	LD	A,B
;	OR	C
;	JR	NZ,L_7F20
;	POP	BC
;	RET

;-----------------------------------------------
; VAR
;-----------------------------------------------

V_EXMAP	DEFW	#031E	;позиция надписи "exit" на карте (но не самого выхода!)
V_WLCLR	DEFW	#0405
LEVEL	DEFB	0
V_FRCNT	DEFB	0	;счетчик 0/1 при выстреле
V_JTCNT	DEFB	0	;счетчик убитых (точнее, оставшихся) козлов
V_EGCNT	DEFB	0	;счетчик яиц

L_FA9F	DB	#00	;(var): чтение с клавиатуры - влево-вправо
L_FAA0	DB	#00	;(var): чтение с клавиатуры - вперед(1)-назад(2)
L_FAA1	DB	#00	;(var): чтение с клавиатуры - огонь(1)

L_FAA2	DB	#0D	;(var): player rotation angle
L_FAA3	DB	#EB	;(var): player XY
L_FAA4	DB	#ED	;(var): player XY
L_FAA5	DB	#00	;счетчик 0..3 (раньше здесь была другая переменная)
L_FAA6	DB	#00	;
L_FAA7	DB	#02	;
L_FAA8	DB	#04	;счетчик для дракона
L_FAA9	DEFW	#0000	;monster XY
L_FAAB	DB	#00	;байт счетчика 0/1
L_KEYS	DB	#00	;ключи
L_FAAD	DB	#00	;жизни монстра
L_FAAE	DB	#66	;позиция дракона
L_FAAF	DB	#05	;жизнь игрока
L_FAB0	DB	#00	;доспехи (щиты)
L_FAB1	DB	#2F	;bullets
L_FAB2	DB	#00	;тип оружия (0=трезубец)
L_FAB3	DB	#00	;(unused)
L_FAB4	DB	#00	;(unused)
L_FAB5	DB	#00	;основное состояние игры; >=1 - выход из цикла
L_FAB6	DB	#03	;
L_FAB7	DB	#02	; QUAKE sign count
L_FAB8	DB	#00	;время до исчезновения надписи
L_FAB9	DB	#00	;
	DB	#00	;
L_FABB	DB	#00	;
L_FABC	DB	#00	;
L_FABD	DEFW	#0000	;позиция летающей смерти

NUMSTR	DEFB	0,0,0,0,0,0	; 5 chars + #0

;-------------------------------------------------

	IF DEBUG=1
PRINTNUM00
	PUSH	AF
	PUSH	BC		; for test purpose
	LD	BC,00		; not present in
	CALL	PRINTNUM	; normal build
	POP	BC
	POP	AF
	RET
	ENDIF
