#include <stdio.h>


extern int purintf(const char * string, ...) __attribute__ ((format(printf, 1, 2))); // 20 standard for %b

int main(void)
{
    purintf("11111 %s", "hello world");
}

