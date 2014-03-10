//
//  JMDebug.h
//  Jasmine
//
//  Created by Qiang on 3/9/14.
//  Copyright (c) 2014 Alven.Li. All rights reserved.
//

#import <Foundation/Foundation.h>

#if DEBUG_FLAG
#define DEBUG_LOG(s, ...) NSLog(@"%@",[NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define DEBUG_LOG(s, ...)
#endif

#if DEBUG_FLAG
#define JASSERT()
#else
#endif