#include <stdio.h>


extern int purintf(const char * string, ...);

int main(void)
{
    const char * line = "printing number...";
    for (int i = 0; i < 100; i++)
    {
        purintf("%% i = %x %o %b %c %d", i, i, i, i, i);
        printf("\n");
    }
}
