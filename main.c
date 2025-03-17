#include <stdio.h>


extern int purintf(const char * string, ...);

int main(void)
{
    purintf("helloo %c %c %c", 'a', 'b', '3');
}
