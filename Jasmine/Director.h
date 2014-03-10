//
//  Director.h
//  Jasmine
//
//  Created by Qiang Li on 12-9-17.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "GLView.h"
#import "GScreen.h"

@interface Director : NSObject

+ (Director*)sharedDirector;

@property (nonatomic) NSUInteger preferredFramePerSecond;
@property (nonatomic, readonly) NSTimeInterval timeElasped;
@property (nonatomic, readonly) NSTimeInterval timeInterval;
@property (nonatomic, readonly) NSUInteger framesDisplayed;
@property (nonatomic, readonly) float framePerSecond;

@property (nonatomic) GScreen *screen;

@property (nonatomic) GLView *view;

- (void)start;
- (void)stop;
- (void)pause;
- (void)resume;

@end
