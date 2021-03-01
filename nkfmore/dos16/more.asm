%if 0
;===============================================================
more.asm - simple launcher for nkfmore

to build:
    nasm -f bin -o more.com more.asm

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
;===============================================================
%endif

	BITS	16
	CPU	8086

PATHSTR_MAX	equ	260
PARAMSTR_MAX	equ	130
MISCBUF_MAX	equ	256
STACK_SIZE	equ	256

;%define DOS2_ARGV0
;%define ZEROFILL_BSS

%ifndef ZEROFILL_BSS
pathstr		equ	bss_data_top
paramstr	equ	(pathstr + PATHSTR_MAX)
miscbuf		equ	(paramstr + PARAMSTR_MAX)
stack_top	equ	(miscbuf + MISCBUF_MAX)
stack_bottom	equ	(stack_top + STACK_SIZE)
%endif

segment _TEXT


%ifdef TINY
	ORG	100h
%else
  %ifidn __OUTPUT_FORMAT__, bin
	%define TINY
	ORG	100h
  %endif
%endif

entry:
	cld
	push	cs
	pop	ds
; init stack and resize memory block of current process (COM/EXE)
	mov	ah, 51h
	int	21h		; get psp segment -> bx
	mov	es, bx
	mov	dx, cs
%ifdef DOS2_ARGV0
	; DOS 2.x: fetch the pathname from garbage buffer used by the command.com
	; (see SFX_.ASM in LHA's source archive)
	mov	ax, [es: 0002h]
	sub	ax, 38h
	mov	[dos2cmd_seg], ax
%endif
	xchg	bx, dx		; bx = CS, dx = PSP
	sub	bx, dx
	mov	ax, stack_bottom + 15
	and	ax, 0fff0h
	cmp	ax, sp
	ja	.err_fatal
	cli
	mov	cx, cs
	mov	ss, cx
	mov	sp, ax
	sti
	mov	cl, 4
	shr	ax, cl
	add	bx, ax
	mov	ah, 4ah
	int	21h

; setup execblk & copy cmdline
	push	es
	push	ds
	pop	es
	mov	si, strMore
	mov	di, paramstr
	mov	[exec_blk_cmd], di
	mov	cx, strMore.strend - strMore
	rep movsb
	pop	es
	mov	si, di
	mov	[exec_blk_cmd + 2], ds
	mov	[exec_blk_fcb1 + 2], es
	mov	[exec_blk_fcb2 + 2], es
	mov	di, 80h
	mov	cl, [es: di]		; (assume ch = 0)
	jcxz	.cmd_brk
.cmd_lp:
	inc	di
	mov	al, [es: di]
	mov	[si], al
	inc	si
	loop	.cmd_lp
.cmd_brk:
	mov	byte [si], ch		; (assume ch = 0)
; get argv0
%ifdef DOS2_ARGV0
	mov	ax, 3000h
	int	21h
	cmp	al, 2
	jb	.err_fatal
	ja	.argv0_0
	les	di, [dos2cmd]
	cmp	byte [es: di], 20h
	jb	.err_fatal
	jmp	short .argv0_copy
%endif
.argv0_0:
	mov	cx, -1
	mov	ax, [es: 002ch]
	test	ax, ax
	jz	.err_fatal
	mov	es, ax
	xor	di, di
	mov	al, 0
.argv0_lp:
	repne scasb
	jcxz	.err_fatal
	cmp	al, [es: di]
	je	.argv0_1
	jmp	short .argv0_lp
.err_fatal:
	mov	si, errFatal
	call	putsn
	mov	ax, 4cffh
	int	21h
;
.argv0_1:
	scasb			; inc di (cmp al, [es: di++])
	mov	ax, 1
	scasw			; cmp ax, [es: di]; di+=2
	jne	.err_fatal
; copy argv0
.argv0_copy:
	mov	si, pathstr
	push	si
.a0_lp:
	mov	al, [es: di]
	mov	[si], al
	inc	si
	inc	di
	cmp	al, 0
	jne	.a0_lp
	pop	si
;
	call	setup_dbcs

	push	ds
	pop	es
	call	skip_path_dssi_to_di
	mov	si, strNkf
	mov	cx, strNkf.strend - strNkf
	rep movsb

%ifdef DEBUG
	mov	si, pathstr
	call	putsn
	mov	si, paramstr
	call	putsn
%endif

	mov	dx, pathstr
	mov	bx, exec_blk
	mov	ax, 4b00h
	int	21h
	jc	.errexit
	mov	ah, 4dh
	int	21h
	mov	ah, 4ch
	int	21h

.errexit:
	mov	si, errNoNkf
	call	puts
	mov	si, pathstr
	call	putsn
	mov	ah, 4ch
	int	21h


putc:
	push	bx
	push	cx
	push	dx
	push	ds
	push	ax
	mov	dx, sp
	mov	cx, 1
	mov	bx, 2		; stderr
	mov	ah, 40h
	int	21h
	pop	ax
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	ret

putsn:
	call	puts
putn:
	push	ax
	mov	al, 13
	call	putc
	mov	al, 10
	call	putc
	pop	ax
	ret

puts:
	push	ax
	push	si
.lp:
	lodsb
	cmp	al, 0
	je	.brk
	call	putc
	jmp	short .lp
.brk:
	pop	si
	pop	ax
	ret


skip_path_dssi_to_di:
	push	si
	mov	di, si
.lp:
	lodsb
	cmp	al, 0
	je	.brk
	cmp	al, ':'
	je	.mark
	cmp	al, '/'
	je	.mark
	cmp	al, '\'
	jne	.next
.mark:
	mov	di, si
.next:
	call	isdblead
	jne	.lp
	cmp	byte [si], 20h		; avoid overrun
	jb	.lp
	inc	si
	jmp	short .lp
.brk:
	pop	si
	ret


isdblead:
	push	ax
	push	bx
	push	si
	push	ds
	lds	si, [dbcs_vect]
	mov	bl, al
	mov	bh, 0ffh
.lp:
	lodsw
	cmp	al, 0
	je	.sbcs
	cmp	bl, al
	jb	.lp
	cmp	bl, ah
	ja	.lp
	inc	bh
.sbcs:
	test	bh, bh		; ZF=1 DBC lead, ZF=0 SBCS
	pop	ds
	pop	si
	pop	bx
	pop	ax
	ret

setup_dbcs:
	push	bx
	push	dx
	push	si
	push	ds
	mov	ax, 3800h	; get country info
	xor	bx, bx
	mov	dx, miscbuf
	int	21h
	mov	si, dbcs_stub_jp
	test	bx, bx
	jz	.l1
	mov	ax, bx
.l1:
	cmp	ax, 81		; current country == JAPAN?
	je	.l2
	mov	si, dbcs_stub_sbcs
.l2:
	mov	ax, 6300h	; Get DBCS vector (DOS 4+)
	int	21h
	mov	ax, [si]
	cmp	al, ah
	jbe	.l3
	add	si, 2	; fix wrong pointer: workaround for some DOS clones
	mov	ax, [si]
.l3:
	mov	bx, ds
	pop	ds
	mov	[dbcs_vect], si
	mov	[dbcs_vect + 2], bx
	pop	si
	pop	dx
	pop	bx
	test	ax, ax
	ret


;---------------------------------------------------------------
data_top:

%ifdef DOS2_ARGV0
dos2cmd		dw	0009h
dos2cmd_seg	dw	0
%endif

exec_blk:
exec_blk_env	dw	0
exec_blk_cmd	dd	0
exec_blk_fcb1	dd	5ch
exec_blk_fcb2	dd	6ch

dbcs_vect	dd	0

dbcs_stub_jp:
	db	81h, 9fh, 0e0h, 0fch
dbcs_stub_sbcs:
	db	0, 0

strNkf:
	db	'NKF.EXE', 0
.strend:
strMore:
	db	' --more '
.strend:

errNoNkf:
	db	"FATAL: can't launch ", 0
errFatal:
	db	"FATAL: can't get the progname", 0
;
bss_data_top:

%ifdef ZEROFILL_BSS
pathstr:
	resb	PATHSTR_MAX
paramstr:
	resb	PARAMSTR_MAX
miscbuf:
	resb	MISCBUF_MAX
stack_top:
	resw	STACK_SIZE
stack_bottom:
%endif

