//
//  Timeline.h
//  Jasmine
//
//  Created by Qiang Li on 12-9-17.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Action;

@interface Timeline : NSObject

+ (Timeline*)sharedTimeline;
+ (Timeline*)backgroundTimeline;

@property (nonatomic) float timeScaleFactor;

- (void)updateWithInterval:(NSTimeInterval)time;

@end

//////// Action ////////

typedef enum : int
{
    ActionStateReady,   // has not commit to timeline
    ActionStatePlaying, // committed to timeline
    ActionStatePaused,  // stay in timeline, but paused
} ActionState;

// Interpolator
typedef double (^ActionInterpolator)(double);

extern ActionInterpolator ActionInterpolatorLinear;
extern ActionInterpolator ActionInterpolatorLinearReverse;

@interface Action : NSObject

@property (nonatomic, assign, readonly) ActionState state;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL autoReplay;
@property (nonatomic, copy) ActionInterpolator interpolator;

// Handlers
@property (nonatomic, copy) void(^update)(double progress);
@property (nonatomic, copy) void(^finish)(id action, BOOL finished);

// Constructors
- (id)initWithDuration:(NSTimeInterval)duration;
- (id)initWithDuration:(NSTimeInterval)duration update:(void(^)(double progress))update;
- (id)initWithDuration:(NSTimeInterval)duration update:(void(^)(double progress))update finish:(void(^)(id action, BOOL finished))finish;

// Animation
- (void)play;
//- (void)playInTimeline:(Timeline*)timeline;
- (void)pause;
- (void)stop;

@end

@interface Action (FactoryMethods)
+ (Action*)timerWithInterval:(NSTimeInterval)interval repeat:(int)repeat delegate:(void (^)(int n))delegate;
+ (Action*)constantlyUpdateActionWithDelegate:(void (^)(NSTimeInterval time))delegate;
@end
