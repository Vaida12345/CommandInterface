//
//  headers.h
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//

#ifndef _Headers_h
#define _Headers_h

#include <sys/ioctl.h>
#include <unistd.h>

struct winsize __getTerminalSize(void);

#endif
