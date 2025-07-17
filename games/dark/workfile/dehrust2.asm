DEHRUST2:
;---		ld	a, (hl)
;===		inc	hl
;---		cp	68h
;---		ret	nz
;---		ld	a, (hl)
;===		inc	hl
;---		cp	72h
;---		ret	nz
;---		ld	a, (hl)
;===		inc	hl
;---		cp	32h
;---		ret	nz
;---		ld	a, (hl)
;===		inc	hl
		rla
		ex	af, af'
		push	de
		ld	c, (hl)
		inc	hl
		ld	b, (hl)
		inc	hl
		dec	bc
		ex	de, hl
		add	hl, bc
		ex	de, hl
		ld	c, (hl)
		inc	hl
		ld	b, (hl)
		add	hl, bc
		sbc	hl, de
		add	hl, de
		jr	c, loc_9DB3
		ld	d, h
		ld	e, l
loc_9DB3:
		push	bc
		lddr
		pop	bc
		ex	de, hl
		ex	af, af'
		jr	nc, loc_9DC0
		pop	de
		inc	hl
		ldir
		ret
; ---------------------------------------------------------------------------
loc_9DC0:
		ld	de, 7
		add	hl, de
		push	hl
		exx
		pop	hl
		pop	de
		ld	a, 3
loc_9DCA:
		dec	hl
		ld	b, (hl)
		dec	hl
		ld	c, (hl)
		push	bc
		dec	a
		jr	nz, loc_9DCA
		ld	b, a
		exx
		ld	de, 1003h
		ld	c, 80h
loc_9DD9:
		ld	a, (hl)
		inc	hl
		exx
		ld	(de), a
		inc	de
loc_9DDE:
		exx
loc_9DDF:
		sla	c
		jr	nz, loc_9DE7
		ld	c, (hl)
		inc	hl
		rl	c
loc_9DE7:
		jr	c, loc_9DD9
		ld	b, 1
loc_9DEB:
		ld	a, 40h
loc_9DED:
		sla	c
		jr	nz, loc_9DF5
		ld	c, (hl)
		inc	hl
		rl	c
loc_9DF5:
		rla
		jr	nc, loc_9DED
		cp	e
		jr	c, loc_9E00
		add	a, b
		ld	b, a
		xor	d
		jr	nz, loc_9DEB
loc_9E00:
		add	a, b
		cp	4
		jr	z, loc_9E52
		adc	a, 0FFh
loc_9E07:
		cp	2
loc_9E09:
		exx
		ld	c, a
		ld	h, 0FFh
		exx
		jr	c, loc_9E6C
		jr	z, loc_9E3B
		sla	c
		jr	nz, loc_9E1A
		ld	c, (hl)
		inc	hl
		rl	c
loc_9E1A:
		jr	c, loc_9E3B
		ld	a, 7Fh
		ld	b, e
		djnz	loc_9E6E
loc_9E21:
		djnz	loc_9E44
		ld	b, a
		sbc	a, a
loc_9E25:
		sla	c
		jr	nz, loc_9E2D
		ld	c, (hl)
		inc	hl
		rl	c
loc_9E2D:
		rla
		dec	a
		inc	b
		jr	nz, loc_9E25
		cp	0E1h
		jr	nz, loc_9E38
		ld	a, (hl)
		inc	hl
loc_9E38:
		exx
		ld	h, a
		exx
loc_9E3B:
		ld	a, (hl)
		inc	hl
loc_9E3D:
		exx
		ld	l, a
		add	hl, de
		ldir
		jr	loc_9DDE
; ---------------------------------------------------------------------------
loc_9E44:
		add	a, 6
		rla
		ld	b, a
loc_9E48:
		ld	a, (hl)
		inc	hl
		exx
		ld	(de), a
		inc	de
		exx
		djnz	loc_9E48
		jr	loc_9DDF
; ---------------------------------------------------------------------------
loc_9E52:
		sla	c
		jr	nz, loc_9E5A
		ld	c, (hl)
		inc	hl
		rl	c
loc_9E5A:
		ld	a, d
		jr	nc, loc_9E6E
		ld	a, (hl)
		inc	hl
		cp	d
		jr	nc, loc_9E07
		or	a
		jr	z, loc_9E7D
		exx
		ld	b, a
		exx
		ld	a, (hl)
		inc	hl
		jr	loc_9E09
; ---------------------------------------------------------------------------
loc_9E6C:
		ld	a, 3Fh
loc_9E6E:
		sla	c
		jr	nz, loc_9E76
		ld	c, (hl)
		inc	hl
		rl	c
loc_9E76:
		rla
		jr	nc, loc_9E6E
		djnz	loc_9E21
		jr	loc_9E3D
; ---------------------------------------------------------------------------
loc_9E7D:
		ld	hl, 2758h
		exx
		ld	b, 3
		ex	de, hl
loc_9E84:
		pop	de
		ld	(hl), e
		inc	hl
		ld	(hl), d
		inc	hl
		djnz	loc_9E84
		ret