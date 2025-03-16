#include <stdio.h>


extern int purintf(const char * string, ...);

int main(void)
{
    purintf("helloo %c %c", 'a', 'b');
}
