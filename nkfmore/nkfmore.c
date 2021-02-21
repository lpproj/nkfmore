/* nkfmore: a minimal pager mode add-on for nkf2 */

#include <limits.h>     /* INT_MAX */
#include <stdio.h>      /* putchar */

#define NKFMORE_REVISION "rev-20210220"

static int fallback_putchar(int c)
{
    return putchar(c);
}
int nkfmore_putchar(int c);

#if (INT_MAX) <= 0x1fffffL
# define INT_IS_SHORT   1
#endif

#ifdef putchar
# undef putchar
#endif
#define putchar(c)  nkfmore_putchar(c)
#define main(c,v) nkf_original_main(c,v)
#include "nkf.c"
#undef main
#undef putchar

#include "bitpager.h"

int pager_mode = 0;
int help_nkfmore = 0;

static void nkfmore_usage(void)
{
    usage();
    if (help_nkfmore) {
        fprintf(HELP_OUTPUT, "NKFMORE " NKFMORE_REVISION " (built at " __DATE__ ")\n");
        fprintf(HELP_OUTPUT, " --more                 Simple pager mode\n");
    }
}

int nkfmore_putchar(int c)
{
    if (pager_mode) {
        int rc = pgr_putchar(c & 0xff);
        if (pgr_isaborted()) {
            fallback_putchar(13);
            fallback_putchar(10);
            exit(EXIT_SUCCESS);
        }
        return rc;
    }
    return fallback_putchar(c);
}

int
main(int argc, char **argv)
{
    int i;

    for(i=1; i<argc; ++i) {
        char *s = argv[i];
        if (strcmp(s, "--more")==0 || strcmp(s, "--pager")==0) {
            int j;
            pager_mode = 1;
            for(j=i; j<argc; ++j) {
                argv[j] = argv[j+1];
            }
            --argc;
            if (i>=argc) break;
            s = argv[i];
        }
        if ((s[0] == '-' || s[0] == '/') && s[1] == '?') {
            s = argv[i] = "--help";
        }
        if (strcmp(s, "--help")==0) help_nkfmore = 1;
    }
    if (pager_mode) {
        if (pgr_initpager() < 0 || pgr_isterm() < 0) {
            pager_mode = 0;
        }
    }
    if (help_nkfmore) {
        nkfmore_usage();
        exit(EXIT_SUCCESS);
    }
    return nkf_original_main(argc, argv);
}

