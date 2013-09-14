//
//  DotsWorld.m
//  Jasmine
//
//  Created by Gong Zhang on 12-9-28.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "DotsWorld.h"
#import "Timeline.h"
#import "util/random.h"
#import "PointParticleSystem.h"
#import "VolumeTest.h"
#import "TestBeam.h"

@implementation DotsWorld
{
    @private
    NSMutableArray *_dots;
    NSMutableArray *_dotsCache;
    PointParticleSystem *_particleSystem;
    TestRect *_rect;
    VolumeTest *_volume;
    TestBeam *_beam;
//    TestBeam *_beam2;
}

@synthesize dots = _dots;

- (id)initWithWidth:(float)width height:(float)height
{
    self = [super init];
    if (self) {
        _width = width;
        _height = height;
        self.projection.matrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0f), width/height, 1, 1500);
//        self.projection.matrix = GLKMatrix4MakeOrtho(0, width, 0, height, -1024, 1024);
        self.camera.eye = GLKVector3Make(0.f, 0.f, height / 2);
        self.camera.center = GLKVector3Make(0.f, 0.f, 0);
        self.camera.up = GLKVector3Make(0.f, 1.f, -1.f);
        
        _volume = [[VolumeTest alloc] init];
        [self addChild:_volume];
        _volume.visible = NO;
        _rect = [[TestRect alloc] init];
        _rect.color1 = _rect.color2 = GLKVector4Make(0.3f, 0.f, 0.f, 0.3f);
        _rect.color3 = _rect.color4 = GLKVector4Make(0.4f, 0.f, 0.f, 0.4f);
        [self addChild:_rect];
        _beam = [[TestBeam alloc] init];
        [self addChild:_beam];

        SphereEmitter *emitter = [SphereEmitter new];
        emitter.size = GLKVector3Make(150.f, 150.f, 150.f);
        _particleSystem = [[PointParticleSystem alloc] initWithMaxCount:10000 withEmitter:emitter];
        _particleSystem.speed = 0;
        _particleSystem.speedVariety = 1;
        _particleSystem.color = GLKVector4Make(0.9f, 0.7f, 0.2f, 1);
        _particleSystem.autoEmit = YES;
        _particleSystem.emitPerSecond = 1000;
        _particleSystem.maxLife = 1.5f;
        _particleSystem.maxLifeVariety = 0;
        _particleSystem.forceEmitWhenFull = YES;
        [self addChild:_particleSystem];
        
        _dots = [NSMutableArray new];
        _dotsCache = [NSMutableArray new];
//        _mainDot = [Dot new];
//        _mainDot.scaleX = 1;
//        _mainDot.scaleY = 1;
//        _mainDot.rotateX = 0.3f;
//        _mainDot.color1 = _mainDot.color2 = _mainDot.color3 = _mainDot.color4 = GLKVector4Make(1, 0, 0, 1);
//        [self addChild:_mainDot];
        
        
        Action *physics = [Action constantlyUpdateActionWithDelegate:^(NSTimeInterval time) {
            [self updateDotsWithTimeInterval:time];
        }];
        [physics play];
        
        [[Action constantlyUpdateActionWithDelegate:^(NSTimeInterval time) {
            for (int i = 0; i < _dots.count; i++) {
                Dot *dot = [_dots objectAtIndex:i];
                if (dot.translateY < -500.f) {
                    [_dots removeObjectAtIndex:i];
                    [self removeChild:dot];
                    i--;
                    [_dotsCache addObject:dot];
                }
            }
//            BoxEmitter *emitter = (id) _particleSystem.emitter;
//            emitter.rotation = GLKVector3Make(0, 0.3f, 0);
//            _particleSystem.modelView = GLKMatrix4RotateY(_particleSystem.modelView, 0.01);
//            _rect.rotateY += 0.01f;
            
        }] play];
        
        [[Action timerWithInterval:0.02 repeat:-1 delegate:^(int n) {
            [self generateRandomDots:1];
        }] play];
        
    }
    return self;
}

- (Dot*)dot
{
    if (_dotsCache.count > 0) {
        Dot *dot = [_dotsCache lastObject];
        [_dotsCache removeLastObject];
        dot.velocity = GLKVector3Make(0, 0, 0);
        dot.translate = GLKVector3Make(0, 0, 0);
        return dot;
    } else {
        return [Dot new];
    }
}

- (void)generateRandomDots:(int)count
{
    for (int i = 0; i < count; i++) {
        Dot *dot = [self dot];
        dot.translateX = RANDOM_MINUS1_1 * 600.f;
        dot.translateY = 500.f;
        dot.translateZ = RANDOM_MINUS1_1 * 600.f;
        dot.velocity = GLKVector3Make(RANDOM_MINUS1_1 * 5, -100 + (RANDOM_MINUS1_1 + 1.0f) * 10, 0);
        [_dots addObject:dot];
        [self addChild:dot];
    }
}
float temptest = 0;
- (void)updateDotsWithTimeInterval:(NSTimeInterval)dt
{
    for (int i = 0; i < _dots.count; i++) {
        Dot *dot = [_dots objectAtIndex:i];
        
        // determine gravity
        GLKVector3 dv = GLKVector3Subtract(self.mainDot.translate, dot.translate);
        float len = GLKVector3Length(dv);
        if (len < 1) len = 1;
        len = 1 / len;
        float gravity = 5000.0f * len * len;
        
        // newton force
        dot.accelerate = GLKVector3MultiplyScalar(dv, gravity);
        dot.velocity = GLKVector3Add(dot.velocity, GLKVector3MultiplyScalar(dot.accelerate, dt));
        dot.translate = GLKVector3Add(dot.translate, GLKVector3MultiplyScalar(dot.velocity, dt));
        float color = 1.f - (dot.translateZ + 500.f) / 1000.f;
        dot.color1 = dot.color2 = dot.color3 = dot.color4 = GLKVector4Make(color, color, color, 1);
    }
     
    //_rect.modelView = GLKMatrix4MakeTranslation(0, -100, 0);
//    self.camera.centerX = 10 * sin(temptest);
//    self.camera.eyeX = self.camera.centerX;
//    self.camera.upX = 1 * sin(temptest);
//    [self.camera test:sinf(temptest)];
    temptest += 0.1f;
}

- (void)draw
{
}

@end

@implementation Dot

- (id)init
{
    self = [super init];
    if (self) {
        self.scaleX = 0.3f;
        self.scaleY = 0.3f;
        _velocity = GLKVector3Make(0, 0, 0);
        _accelerate = GLKVector3Make(0, 0, 0);
        self.color1 = self.color2 = self.color3 = self.color4 = GLKVector4Make(1, 1, 1, 1);
    }
    return self;
}

@end
