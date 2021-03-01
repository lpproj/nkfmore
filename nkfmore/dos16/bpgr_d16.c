/*
bitpager - a minimal text pager module
by lpproj (https://github.com/lpproj)

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

*/

#include <ctype.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <dos.h>

#define BUILD_BITPAGER
#include "bitpager.h"

typedef unsigned char U8;
typedef unsigned short U16;
typedef unsigned long U32;
typedef void far *VFP;
typedef U8 far *U8FP;
typedef U16 far *U16FP;

static union REGS r;
static struct SREGS sr;

static int rows, columns;
static int prevX, prevY;
static int key_abort = 0;
static int line_count;
static int char_count;

static U16 conseg;
static U8FP conbuf;

typedef int (*func_i_pipi)(int *, int *);
typedef int (*func_i_i)(int);
typedef int (*func_i_void)(void);

static func_i_pipi  pf_getxy;
static func_i_i     pf_putchar;

static func_i_void  pf_kbd_flush;
static func_i_i     pf_kbd_get;
static func_i_i     pf_put_prompt;

enum {
    PGR_UNKNOWN = -1,
    PGR_UNSPECIFIED = 0,
    PGR_IBMPC,
    PGR_NEC98,
    PGR_FMR
};
static int pgr_machine = PGR_UNSPECIFIED;
static int pgr_getmachinetype(void);

static int pgr_putchar_dos(int c);

static int init_nec98(void);
static int pgr_getxy_nec98(int *p_x, int *p_y);
static int kbd_flush_nec98(void);
static int kbd_get_nec98(int do_peekonly);
static int put_prompt_nec98(int do_erase);

static int init_ibmpc(void);
static int pgr_getxy_ibmpc(int *p_x, int *p_y);
static int kbd_flush_ibmpc(void);
static int kbd_get_ibmpc(int do_peekonly);
static int put_prompt_ibmpc(int do_erase);

/*------------------------------------------------------------
    common interface funcs
  ------------------------------------------------------------*/

const char *pgr_platform(void)
{
    return "NEC98/IBMPC";
}


int pgr_isterm(void)
{
    /* check if stdout is connected to "CON" */
    r.x.ax = 0x4400;
    r.x.bx = 1;
    r.x.dx = 0; /* to be safe */
    intdos(&r, &r);
    return (!r.x.cflag && (r.x.dx & 0x93)==0x93) ? 0 : -1;
}

int pgr_termsize(int *p_columns, int *p_rows)
{
    if (p_columns) *p_columns = columns;
    if (p_rows) *p_rows = rows;
    return 0;
}


static int pgr_getmachinetype(void)
{
    if (*(unsigned short far *)MK_FP(0xffffU, 3) == 0xfd80U) return PGR_NEC98;
    r.x.ax = 0x0fff;
    int86(0x10, &r, &r);
    return r.h.ah == 0x0f ? PGR_NEC98 : PGR_IBMPC;
}

int pgr_initpager(void)
{
    int rc = -1;

    pgr_machine = pgr_getmachinetype();
    switch(pgr_machine) {
        case PGR_NEC98:
            pf_kbd_flush = kbd_flush_nec98;
            pf_kbd_get = kbd_get_nec98;
            pf_put_prompt = put_prompt_nec98;
            pf_getxy = pgr_getxy_nec98;
            pf_putchar = pgr_putchar_dos;
            rc = init_nec98();
            break;
        case PGR_IBMPC:
            pf_kbd_flush = kbd_flush_ibmpc;
            pf_kbd_get = kbd_get_ibmpc;
            pf_put_prompt = put_prompt_ibmpc;
            pf_getxy = pgr_getxy_ibmpc;
            pf_putchar = pgr_putchar_dos;
            rc = init_ibmpc();
            break;
        default:
            break;
    }
    if (rc >= 0) {
        pf_getxy(&prevX, &prevY);
        key_abort = 0;
        line_count = 0;
        rc = 0;
    }
    return rc;
}

int pgr_getxy(int *x, int *y)
{
    if (!pf_getxy) return -1;
    return pf_getxy(x, y);
}

int pgr_putchar(int c)
{
    if (!pf_putchar) return -1;
    return pf_putchar(c);
}

int pgr_isaborted(void)
{
    return key_abort;
}

/*------------------------------------------------------------
    helper funcs
  ------------------------------------------------------------*/

static int kbd_peek(void)
{
    if (!pf_kbd_get) return -1;
    return pf_kbd_get(1);
}

static int kbd_get(void)
{
    if (!pf_kbd_get) return -1;
    return pf_kbd_get(0);
}

static int kbd_flush(void)
{
    if (!pf_kbd_flush) return -1;
    return pf_kbd_flush();
}

static int put_prompt(void)
{
    if (!pf_put_prompt) return -1;
    return pf_put_prompt(0);
}

static int erase_prompt(void)
{
    if (!pf_put_prompt) return -1;
    return pf_put_prompt(1);
}


/*------------------------------------------------------------
    helper funcs (DOS specific)
  ------------------------------------------------------------*/

static void dos_putc(int c)
{
    r.h.al = 0xffU & c;
    int86(0x29, &r, &r);
}

static void dos_puts(const char *s)
{
    while(*s) dos_putc(*s++);
}

static int dos_yield(void)
{
    int86x(0x28, &r, &r, &sr);
    return 0;
}

static int pgr_putchar_dos(int c)
{
    static int prev_c = -1;
    int line_upd = 0;
    int x, y;
    pgr_getxy(&prevX, &prevY);
    if (c == 0x0a && prev_c != 0x0d) dos_putc(0x0d);
    dos_putc(c);
    pgr_getxy(&x, &y);

    if (c == 0x0a) line_upd = 1;
    else if (y > prevY) line_upd = y - prevY;
    else if (y == rows - 1) {
        if (x >= columns || (x < prevX && c != 0x7 && c != 0x9 && c != 0x0d /* c > 0x20 */)) line_upd = 1;
    }
    if (line_upd > 0) {
        line_count += line_upd;
        if (rows >= 2 && line_count >= rows - 1) {
            line_count = 0;
            if (put_prompt() >= 0) {
                int k;
                kbd_flush();
                while((k = kbd_peek()) == -1) { dos_yield(); }
                k = kbd_get();
                if (k == 0x1b || k == 'Q' || k == 'q') key_abort = 1;
                erase_prompt();
            }
        }
    }
    prev_c = c;
    return c;
}


/*------------------------------------------------------------
    machine specific funcs
    NEC98
  ------------------------------------------------------------*/

static int put_prompt_nec98(int do_erase)
{
    const char prmmsg[] = " -つづく- "     ;
    const char clrmsg[] = "          " "\r";
    dos_putc('\r');
    if (do_erase) { dos_puts(clrmsg); }
    else {
        dos_puts("\x1b[7m");
        dos_puts(prmmsg);
        dos_puts("\x1b[m");
    }
    return 0;
}

static int kbd_get_nec98(int do_peekonly)
{
    r.h.ah = do_peekonly ? 1 : 0;
    r.h.bh = 0;
    int86(0x18, &r, &r);
    if (do_peekonly && !r.h.bh) return -1;
    if (r.x.ax != 0xffff) r.h.ah = 0;
    return r.x.ax;
}

static int kbd_flush_nec98(void)
{
    while(kbd_get_nec98(1) != -1)
        kbd_get_nec98(0);
    return 0;
}

static int init_nec98(void)
{
    conseg = *(U16FP)MK_FP(0x60, 0x32);
    if (!conseg) conseg = 0xa000U;  /* EPSON MS-DOS 4.01 */
    conbuf = MK_FP(conseg, 0);
    rows = 1 + *(U8FP)MK_FP(0x60, 0x112);
    columns = (*(U8FP)0x053cUL & 2) ? 40 : 80;  /* todo: 90cols BIOS */
    return 0;
}

static int pgr_getxy_nec98(int *p_x, int *p_y)
{
    if (p_x) *p_x = *(U8FP)MK_FP(0x60U, 0x11cU);
    if (p_y) *p_y = *(U8FP)MK_FP(0x60U, 0x110U);
    return 0;
}


/*------------------------------------------------------------
    machine specific funcs
    IBMPC (DOS/V)
  ------------------------------------------------------------*/

static int put_prompt_ibmpc(int do_erase)
{
   const char prmmsg[] = " -more- "     ;
   const char clrmsg[] = "        " "\r";
    dos_putc('\r');
    if (do_erase) { dos_puts(clrmsg); }
    else { dos_puts(prmmsg); }
    return 0;
}


static int kbd_get_ibmpc(int do_peekonly)
{
    int rc;
    if (do_peekonly) {
        _asm {
            mov ah, 1
            int 16h
            mov ah, 0
            jnz kbd_gi1
            mov ax, 0ffffh
         kbd_gi1:
            mov [rc], ax
        }
    }
    else {
        _asm {
            mov ah, 0
            int 16h
            mov ah, 0
            mov [rc], ax
        }
    }
    return rc;
}

static int kbd_flush_ibmpc(void)
{
    while(kbd_get_ibmpc(1) != -1)
        kbd_get_ibmpc(0);
    return 0;
}

static int init_ibmpc(void)
{
    /* query topview (or DOS/V) APA buffer address */
    r.h.ah = 0xfe;
    sr.es = (*(U8FP)MK_FP(0x40U, 0x49U) == 7) ? 0xb000 : 0xb800;
    r.x.di = *(U16FP)MK_FP(0x40U, 0x4eU);
    int86x(0x10, &r, &r, &sr);
    conseg = sr.es;
    conbuf = MK_FP(sr.es, r.x.di);

    columns = *(U16FP)MK_FP(0x40U, 0x4aU);
    rows = *(U8FP)MK_FP(0x40U, 0x84U);
    if (rows == 0 || rows == 0xff) rows = 25;   /* workaround for old CGA/MDA */
    else ++rows;    /* EGA or later */
    return 0;
}

static int pgr_getxy_ibmpc(int *p_x, int *p_y)
{
    U8FP cpos = MK_FP(0x40U, 0x50U + (*(U8FP)MK_FP(0x40, 0x62) << 1));
    if (p_x) *p_x = *cpos;
    if (p_y) *p_y = cpos[1];
    return 0;
}




#ifdef TEST

int main(int argc, char **argv)
{
    int rc;
    FILE *fi;
    rc = pgr_initpager();
    if (pgr_isterm() < 0) {
        fprintf(stderr, "do not redirect stdout\n");
        return 1;
    }
    if (rc < 0) {
        fprintf(stderr, "initpager failed.\n");
        return 1;
    }
    if (argc <= 1) {
        printf("usage: prog file\n");
        return 0;
    }
    fi = fopen(argv[1], "r");
    if (!fi) {
        fprintf(stderr, "can't open '%s'\n", argv[1]);
        return 1;
    }
    while(1) {
        int c = fgetc(fi);
        if (c == EOF) break;
        pgr_putchar(c);
    }
    fclose(fi);

    return 0;
}
#endif

