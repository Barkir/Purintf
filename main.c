#include <stdio.h>


extern int purintf(const char * string, ...) __attribute__ ((format(printf, 1, 2))); // 20 standard for %b

int main(void)
{
    const char * line = "printing number...";
    for (int i = 0; i < 100; i++)
    {
        purintf("%% i = %x %o %b %c %d\n", i, i, i, i, i);
        printf("\n");
    }
}

