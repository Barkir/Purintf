#include <stdio.h>


extern int purintf(const char * string, ...) __attribute__ ((format(printf, 1, 2)));

int main(void)
{
    char * string = "1234567890";

    float i = 16;

    purintf("%d %s %x", -1, "love", 0xEDA);
}

