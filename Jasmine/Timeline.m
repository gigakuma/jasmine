//
//  Timeline.m
//  Jasmine
//
//  Created by Qiang Li on 12-9-17.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "Timeline.h"
#import <sys/sysctl.h>


static Timeline *singleton = nil;
static Timeline *singleton_background = nil;

ActionInterpolator ActionInterpolatorLinear = ^(double k) {
    return k;
};

ActionInterpolator ActionInterpolatorLinearReverse = ^(double k) {
    return 1.0 - k;
};

@interface Action ()
@property (nonatomic, weak) Timeline *timeline;
- (void)resetAction;
- (void)setState:(ActionState)state;
- (void)updateWithInterval:(NSTimeInterval)time;
- (void)fireFinishHandlerWithFinished:(BOOL)finished;
@end

@interface Timeline ()
{
    @private
    NSMutableArray *_actions;
}
- (void)commitAction:(Action*)action;
- (void)cancelAction:(Action*)action;
- (void)updateActions:(NSArray*)actions interval:(NSTimeInterval)time;
@end

@implementation Timeline

+ (Timeline*)sharedTimeline
{
    if (singleton == nil) {
        singleton = [[Timeline alloc] init];
    }
    return singleton;
}

+ (Timeline*)backgroundTimeline
{
    if (singleton_background == nil) {
        
        // determine the number of CPU cores
        size_t len;
        unsigned int ncpu;
        len = sizeof(ncpu);
        sysctlbyname("hw.ncpu", &ncpu ,&len, NULL, 0);
//        NSLog(@"%@", @(ncpu));
        
        if (NO) {
            // use backgorund timeline
            singleton_background = [[Timeline alloc] init];
            
            void (^task0)(NSTimeInterval) = ^(NSTimeInterval dt) { // TODO: deploy task
                // drive timeline
                [singleton_background updateWithInterval:dt];
            };
            
            void (^task1)(NSTimeInterval) = ^(NSTimeInterval dt) {
            };
            
            void (^task2)(NSTimeInterval) = ^(NSTimeInterval dt) {
            };
            
            void (^task3)(NSTimeInterval) = ^(NSTimeInterval dt) {
            };
            
            // start a loop in a new thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                static const NSTimeInterval MAX_FPS = 45.0;
                static const NSTimeInterval MIN_INTERTVAL = 1.0 / MAX_FPS;
                NSDate *prev_time = [NSDate date];
                NSDate *cur_time = nil;
                
                while (YES) {
                    @autoreleasepool {
                        
                        // determine time interval
                        cur_time = [NSDate date];
                        NSTimeInterval dt = [cur_time timeIntervalSinceDate:prev_time];
                        
                        if (dt >= MIN_INTERTVAL) {
                            
                            // update
                            dispatch_apply(4, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(size_t task_index) {
                                switch (task_index) {
                                    case 0: task0(dt); break;
                                    case 1: task1(dt); break;
                                    case 2: task2(dt); break;
                                    case 3: task3(dt); break;
                                }
                            });
                            
                            prev_time = cur_time;
                            
                        } else {
                            // wait
                            [NSThread sleepForTimeInterval:MIN_INTERTVAL - dt];
                        }
                        
                    }
                }
                
            });

        } else {
            singleton_background = [self sharedTimeline];
        }
    }
    return singleton_background;
}

- (id)init
{
    self = [super init];
    if (self) {
        _timeScaleFactor = 1.0f;
        _actions = [NSMutableArray new];
    }
    return self;
}

- (void)commitAction:(Action*)action
{
    if (action.state == ActionStateReady) {
        [_actions addObject:action];
    } else {
        NSAssert(NO, @"action is already playing");
    }
}

- (void)cancelAction:(Action*)action
{
    [action resetAction];
    [_actions removeObject:action];
    [action fireFinishHandlerWithFinished:NO];
}

- (void)updateActions:(NSArray*)actions interval:(NSTimeInterval)time
{
    for (int i = 0; i < actions.count; i++) {
        Action *action = [actions objectAtIndex:i];
        [action updateWithInterval:time];
        if (action.state == ActionStateReady) {
            [action resetAction];
            [_actions removeObjectAtIndex:i];
            [action fireFinishHandlerWithFinished:YES];
            i--;
        }
    }
}

- (void)updateWithInterval:(NSTimeInterval)time
{
    time *= _timeScaleFactor;
    [self updateActions:_actions interval:time];
}

@end


@implementation Action

- (id)initWithDuration:(NSTimeInterval)duration
{
    self = [super init];
    if (self) {
        self.duration = duration;
        self.interpolator = ActionInterpolatorLinear;
        self.autoReplay = NO;
        [self resetAction];
    }
    return self;
}

- (id)initWithDuration:(NSTimeInterval)duration update:(void(^)(double progress))update
{
    self = [super init];
    if (self) {
        self.duration = duration;
        self.interpolator = ActionInterpolatorLinear;
        self.autoReplay = NO;
        self.update = update;
        [self resetAction];
    }
    return self;
}

- (id)initWithDuration:(NSTimeInterval)duration update:(void(^)(double progress))update finish:(void(^)(id action, BOOL finished))finish
{
    self = [super init];
    if (self) {
        self.duration = duration;
        self.interpolator = ActionInterpolatorLinear;
        self.autoReplay = NO;
        self.update = update;
        self.finish = finish;
        [self resetAction];
    }
    return self;
}

- (void)resetAction
{
    _state = ActionStateReady;
    _currentTime = 0.0;
    self.timeline = nil;
}

- (void)setState:(ActionState)state
{
    _state = state;
}

- (void)play
{
    if (_state != ActionStatePaused) {
        [self playInTimeline:[Timeline sharedTimeline]];
    } else {
        _state = ActionStatePlaying;
    }
}

- (void)playInTimeline:(Timeline*)timeline
{
    [timeline commitAction:self];
    _state = ActionStatePlaying;
    self.timeline = timeline;
}

- (void)pause
{
    if (_state == ActionStatePlaying) {
        _state = ActionStatePaused;
    } else {
        NSAssert(NO, @"action is not playing");
    }
}

- (void)stop
{
    if (_state != ActionStateReady) {
        [self.timeline cancelAction:self];
    } else {
        NSAssert(NO, @"action is not playing");
    }
}

- (void)fireFinishHandlerWithFinished:(BOOL)finished
{
    if (self.finish != nil) {
        self.finish(self, finished);
    }
}

- (void)updateWithInterval:(NSTimeInterval)time
{
    if (time == 0.0) return; // important for timer
    switch (_state) {
        case ActionStatePlaying:
            _currentTime += time;
            if (_currentTime >= _duration) {
                if (_autoReplay) {
                    _currentTime = 0.0;
                    if (self.update != nil) self.update(_interpolator(_currentTime / _duration));
                } else {
                    if (self.update != nil) self.update(_interpolator(1.0));
                    _state = ActionStateReady;
                }
            } else {
                if (self.update != nil) self.update(_interpolator(_currentTime / _duration));
            }
            break;
            
        case ActionStatePaused:
            break;
            
        case ActionStateReady:
            NSAssert(NO, @"cannot update an action before committing it to timeline");
            break;
    }
}

@end

@implementation Action (FactoryMethods)

+ (Action*)timerWithInterval:(NSTimeInterval)interval repeat:(int)repeat delegate:(void (^)(int n))delegate
{
    __block int count = 0;
    Action *timer = [[Action alloc] initWithDuration:interval];
    __weak Action *_timer = timer;
    timer.autoReplay = YES;
    timer.update = ^(double p) {
        if (p == 0.0) {
            count++;
            if (count <= repeat || repeat == -1) { // "-1" means forever
                delegate(count);
                if (count == repeat) {
                    [((Action *) _timer) setState:ActionStateReady]; // tell the timeline: this action should be removed
                    count = 0;
                }
            }
        }
    };
    return timer;
}

+ (Action*)constantlyUpdateActionWithDelegate:(void (^)(NSTimeInterval time))delegate
{
    __block double last_progress = 0.0;
    Action *action = [[Action alloc] initWithDuration:1.0];
    action.autoReplay = YES;
    action.update = ^(double p) {
        if (p == 0.0) {
            last_progress = 0.0;
        } else {
            delegate(p - last_progress);
            last_progress = p;
        }
    };
    return action;
}

@end
