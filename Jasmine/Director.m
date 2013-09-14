//
//  Director.m
//  Jasmine
//
//  Created by Qiang Li on 12-9-17.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "Director.h"
#import "GLStateCache.h"
#import "Timeline.h"

#define DEFAULT_FRAME_PER_SECOND 60

static Director *singleton = nil;

@interface Director ()
{
	CADisplayLink *_displayLink;
	CFTimeInterval _lastDisplayTime;
    
    NSTimeInterval _timeElapsed;
    NSTimeInterval _lastTimeElapsed;
    NSTimeInterval _timeInterval;
    
    NSUInteger _preferredFramePerSecond;
    NSUInteger _framesDisplayed;
    
    GLView *_view;
    BOOL _running;
    BOOL _paused;
    
    BOOL _restartTimeCounter;
}

@end

@implementation Director

@synthesize timeElasped = _timeElapsed;
@synthesize timeInterval = _timeInterval;
@synthesize view = _view;
@synthesize framesDisplayed = _framesDisplayed;

+ (Director*)sharedDirector
{
    if (singleton == nil) {
        singleton = [[Director alloc] init];
    }
    return singleton;
}

- (id)init
{
    self = [super init];
    if (self) {
        _running = NO;
        _paused = NO;
        _restartTimeCounter = NO;
        
        _preferredFramePerSecond = DEFAULT_FRAME_PER_SECOND;
        _framesDisplayed = 0;
    }
    return self;
}

- (void)start
{
    if (_running)
        return;
    int frameInterval = 60 / _preferredFramePerSecond;
    frameInterval = MAX(frameInterval, 1);
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(mainLoop:)];
	[_displayLink setFrameInterval:frameInterval];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    _running = YES;
    
    _restartTimeCounter = YES;
    _timeElapsed = _lastTimeElapsed = 0.f;
}

- (void)stop
{
    if (!_running)
        return;
    [_displayLink invalidate];
	_displayLink = nil;
    _running = NO;
}

- (void)pause
{
    if (_paused)
        return;
    _paused = YES;
    _displayLink.paused = YES;
}

- (void)resume
{
    if (!_paused)
        return;
    _paused = NO;
    _displayLink.paused = NO;
    
    _restartTimeCounter = YES;
}

- (void)setPreferredFramePerSecond:(NSUInteger)performdFramePerSecond
{
    if (performdFramePerSecond == 0)
        _preferredFramePerSecond = 1;
    _preferredFramePerSecond = performdFramePerSecond;
    int frameInterval = 60 / _preferredFramePerSecond;
    frameInterval = MAX(frameInterval, 1);
    if (_displayLink != nil)
        [_displayLink setFrameInterval:frameInterval];
}

- (NSUInteger)preferredFramePerSecond
{
    return _preferredFramePerSecond;
}

- (float)framePerSecond
{
    return (1 / _timeInterval);
}

- (void)timeCalculate
{
    if (_restartTimeCounter) {
        // resume or start
        _lastDisplayTime = _displayLink.timestamp;
        _restartTimeCounter = NO;
    }
    _timeElapsed += _displayLink.timestamp - _lastDisplayTime;
    _lastDisplayTime = _displayLink.timestamp;
    
    _timeInterval = _timeElapsed - _lastTimeElapsed;
    _timeInterval = MAX(0, _timeInterval);
    
    _lastTimeElapsed = _timeElapsed;
    
#if DEBUG_FLAG
	// If we are debugging our code, prevent big delta time
	if(_timeInterval > 1.f / _preferredFramePerSecond)
        _timeInterval = 1.f / _preferredFramePerSecond;
#endif
}

- (void)mainLoop:(CADisplayLink *)sender
{
    ++_framesDisplayed;
    [self timeCalculate];
    [[Timeline sharedTimeline] updateWithInterval:_timeInterval];
    [_scene visit];
    
    [_view renderBegin];
    [_scene draw];
    [_view renderEnd];
}

@end
