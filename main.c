#include <stdio.h>


extern int purintf(const char * string, ...) __attribute__ ((format(printf, 1, 2)));

int main(void)
{


    float i = 16;

    purintf("%d %s %x %b%%%c", -1, "LOVE", 0xedaeda, '!', 'd');
}

