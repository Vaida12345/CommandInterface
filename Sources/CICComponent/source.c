//
//  source.c
//
//
//  Created by Vaida on 6/6/23.
//

#include <stdio.h>
#include <termios.h>
#include <unistd.h>


int
get_pos(int *y, int *x) {
    
    char buf[30]={0};
    int ret, i, pow;
    char ch;
    
    *y = 0; *x = 0;
    
    write(1, "\033[6n", 4);
    
    for( i = 0, ch = 0; ch != 'R'; i++ )
    {
        ret = (int)read(0, &ch, 1);
        if ( !ret ) {
            fprintf(stderr, "getpos: error reading response!\n");
            return 1;
        }
        buf[i] = ch;
    }
    
    if (i < 2) {
        fprintf(stderr, "i < 2\n");
        return(1);
    }
    
    for( i -= 2, pow = 1; buf[i] != ';'; i--, pow *= 10)
        *x = *x + ( buf[i] - '0' ) * pow;
    
    for( i-- , pow = 1; buf[i] != '['; i--, pow *= 10)
        *y = *y + ( buf[i] - '0' ) * pow;
    
    return 0;
}
