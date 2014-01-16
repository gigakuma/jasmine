//
//  ParticleEmitter.m
//  Jasmine
//
//  Created by Qiang Li on 12-10-9.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "ParticleEmitter.h"
#import "util/random.h"

@interface ParticleEmitter ()
{
    GLKVector3 _position;
}

@end

@implementation ParticleEmitter

@synthesize position = _position;

- (id)init
{
    self = [super init];
    if (self) {
        _position = GLKVector3Make(0, 0, 0);
    }
    return self;
}

- (GLKVector3)emitPosition
{
    return self.position;
}

@end

@interface PointEmitter ()
{
@private
    GLKVector3 _lastPosition;
}

@end

@implementation PointEmitter

@synthesize emitOnTrack;

- (id)init
{
    self = [super init];
    if (self) {
        emitOnTrack = YES;
        _lastPosition = GLKVector3Make(0, 0, 0);
    }
    return self;
}

- (void)setPosition:(GLKVector3)position
{
    _lastPosition = self.position;
    [super setPosition:position];
}

- (GLKVector3)emitPosition
{
    if (!emitOnTrack)
        return self.position;
    else {
        GLKVector3 offset = GLKVector3Subtract(self.position, _lastPosition);
        offset = GLKVector3MultiplyScalar(offset, RANDOM_0_1);
        return GLKVector3Subtract(self.position, offset);
    }
}

@end

@interface BoxEmitter ()
{
@private
    GLKMatrix3 _rotationMatrix;
    BOOL _dirty;
}

@end

@implementation BoxEmitter

- (id)init
{
    self = [super init];
    if (self) {
        _dirty = NO;
        _rotation = GLKVector3Make(0, 0, 0);
        _size = GLKVector3Make(0, 0, 0);
        _rotationMatrix = GLKMatrix3Identity;
    }
    return self;
}

- (void)setRotation:(GLKVector3)rotation
{
    if (GLKVector3AllEqualToVector3(_rotation, rotation))
        return;
    _rotation = rotation;
    _dirty = YES;
}

- (GLKVector3)emitPosition
{
    float w = RANDOM_MINUS1_1 * _size.x / 2;
    float h = RANDOM_MINUS1_1 * _size.y / 2;
    float d = RANDOM_MINUS1_1 * _size.z / 2;
    GLKVector3 point = GLKVector3Make(w, h, d);
    if (_dirty) {
        _rotationMatrix = GLKMatrix3Identity;
        _rotationMatrix = GLKMatrix3RotateX(_rotationMatrix, _rotation.x);
        _rotationMatrix = GLKMatrix3RotateY(_rotationMatrix, _rotation.y);
        _rotationMatrix = GLKMatrix3RotateZ(_rotationMatrix, _rotation.z);
    }
    point = GLKMatrix3MultiplyVector3(_rotationMatrix, point);
    return GLKVector3Add(self.position, point);
}

@end

@interface SphereEmitter ()
{
@private
    GLKMatrix3 _rotationMatrix;
    BOOL _dirty;
}

@end

@implementation SphereEmitter

- (id)init
{
    self = [super init];
    if (self) {
        _dirty = NO;
        _rotation = GLKVector3Make(0, 0, 0);
        _size = GLKVector3Make(0, 0, 0);
        _rotationMatrix = GLKMatrix3Identity;
    }
    return self;
}

- (void)setRotation:(GLKVector3)rotation
{
    if (GLKVector3AllEqualToVector3(_rotation, rotation))
        return;
    _rotation = rotation;
    _dirty = YES;
}

- (GLKVector3)emitPosition
{
    float theta = acosf(2 * RANDOM_0_1 - 1);
    float phi = RANDOM_0_1 * (float)M_PI * 2;
    float r = RANDOM_0_1;
    float a = r * _size.x / 2;
    float b = r * _size.y / 2;
    float c = r * _size.z / 2;
    float sin_theta = sinf(theta);
    float cos_theta = cosf(theta);
    float sin_phi = sinf(phi);
    float cos_phi = cosf(phi);
    GLKVector3 point = GLKVector3Make(a * sin_theta * cos_phi,
                                      b * sin_theta * sin_phi,
                                      c * cos_theta);
    if (_dirty) {
        _rotationMatrix = GLKMatrix3Identity;
        _rotationMatrix = GLKMatrix3RotateX(_rotationMatrix, _rotation.x);
        _rotationMatrix = GLKMatrix3RotateY(_rotationMatrix, _rotation.y);
        _rotationMatrix = GLKMatrix3RotateZ(_rotationMatrix, _rotation.z);
    }
    point = GLKMatrix3MultiplyVector3(_rotationMatrix, point);
    return GLKVector3Add(self.position, point);
}

@end