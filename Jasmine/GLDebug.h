//
//  GLDebug.h
//  Jasmine
//
//  Created by Qiang Li on 13-3-8.
//  Copyright (c) 2013 Qiang Li. All rights reserved.
//
#include "GLConfig.h"

#if DEBUG_FLAG
#define DEBUG_LOG(s, ...) NSLog(@"%@",[NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define DEBUG_LOG(s, ...)
#endif
