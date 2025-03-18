#include <stdio.h>


extern int purintf(const char * string, ...) __attribute__ ((format(printf, 1, 2)));

int main(void)
{
    char * string = "1234567890";

    int i = 2;
    for (int i = 0; i < 100; i++)
    {
        purintf("%d %s %x %d%%%c%b\n", -1, "love", 3802, 100, 33, 126);
    }
}

