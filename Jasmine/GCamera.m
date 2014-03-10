//
//  Camera.m
//  Jasmine
//
//  Created by Qiang Li on 12-9-18.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "GCamera.h"

@interface GCamera ()
{
//    GLKVector3 _eye;
//    GLKVector3 _center;
//    GLKVector3 _up;
    GLKMatrix4 _matrix;
    BOOL _dirty;
}

@end

@implementation GCamera

@synthesize center = _center;
@synthesize eye = _eye;
@synthesize up = _up;
@synthesize matrix = _matrix;

- (id)init
{
    self = [super init];
    if (self) {
        _dirty = NO;
        _eye = GLKVector3Make(0.f, 0.f, 1.f);
        _center = GLKVector3Make(0.f, 0.f, 0.f);
        _up = GLKVector3Make(0.f, 1.f, 0.f);
        _matrix = GLKMatrix4Identity;
    }
    return self;
}

- (void)setEye:(GLKVector3)eye
{
    if (GLKVector3AllEqualToVector3(_eye, eye))
        return;
    _eye = eye;
    _dirty = YES;
}

- (void)setCenter:(GLKVector3)center
{
    if (GLKVector3AllEqualToVector3(_center, center))
        return;
    _center = center;
    _dirty = YES;
}

- (void)setUp:(GLKVector3)up
{
    if (GLKVector3AllEqualToVector3(_up, up))
        return;
    _up = up;
    _dirty = YES;
}

- (GLKMatrix4)matrix
{
    if (_dirty) {
        _matrix = GLKMatrix4MakeLookAt(_eye.x, _eye.y, _eye.z,
                                       _center.x, _center.y, _center.z,
                                       _up.x, _up.y, _up.z);
        _dirty = NO;
    }
    return _matrix;
}

- (void)setEyeX:(float)eyeX
{
    _eye.x = eyeX;
    _dirty = YES;
}

- (void)setEyeY:(float)eyeY
{
    _eye.y = eyeY;
    _dirty = YES;
}

- (void)setEyeZ:(float)eyeZ
{
    _eye.z = eyeZ;
    _dirty = YES;
}

- (void)setCenterX:(float)centerX
{
    if (centerX == _center.x)
        return;
    _center.x = centerX;
    _dirty = YES;
}

- (void)setCenterY:(float)centerY
{
    if (centerY == _center.y)
        return;
    _center.y = centerY;
    _dirty = YES;
}

- (void)setCenterZ:(float)centerZ
{
    if (centerZ == _center.z)
        return;
    _center.z = centerZ;
    _dirty = YES;
}

- (void)setUpX:(float)upX
{
    if (upX == _up.x)
        return;
    _up.x = upX;
    _dirty = YES;
}

- (void)setUpY:(float)upY
{
    if (upY == _up.y)
        return;
    _up.y = upY;
    _dirty = YES;
}

- (void)setUpZ:(float)upZ
{
    if (upZ == _up.z)
        return;
    _up.z = upZ;
    _dirty = YES;
}

- (float)eyeX
{
    return _eye.x;
}

- (float)eyeY
{
    return _eye.y;
}

- (float)eyeZ
{
    return _eye.z;
}

- (float)centerX
{
    return _center.x;
}

- (float)centerY
{
    return _center.y;
}

- (float)centerZ
{
    return _center.z;
}

- (float)upX
{
    return _up.x;
}

- (float)upY
{
    return _up.y;
}

- (float)upZ
{
    return _up.z;
}

- (void)setWithCamera:(GCamera *)camera
{
    _eye = camera.eye;
    _up = camera.up;
    _center = camera.center;
    _dirty = YES;
}

- (void)rotateXAroundCenterWithRadians:(float)radians
{
    if (radians == 0)
        return;
    float sign = radians >= 0 ? 1 : -1;
    GLKVector3 eye = self.eye;
    GLKVector3 center = self.center;
    GLKVector3 up = self.up;
    GLKVector3 direct = GLKVector3Make(radians, 0, 0);
    direct = GLKMatrix4MultiplyAndProjectVector3(GLKMatrix4Invert(_matrix, NULL), direct);
    GLKVector3 diff = GLKVector3Subtract(center, eye);
    GLKVector3 axis = GLKVector3CrossProduct(diff, direct);
    GLKMatrix4 matrix = GLKMatrix4MakeTranslation(-center.x, -center.y, -center.z);
    matrix = GLKMatrix4Rotate(matrix, sign * radians, axis.x, axis.y, axis.z);
    matrix = GLKMatrix4Translate(matrix, center.x, center.y, center.z);
    
    self.eye = GLKMatrix4MultiplyAndProjectVector3(matrix, eye);
    self.up = GLKMatrix4MultiplyAndProjectVector3(matrix, up);
}

- (void)rotateYAroundCenterWithRadians:(float)radians
{
    if (radians == 0)
        return;
    float sign = radians >= 0 ? 1 : -1;
    GLKVector3 eye = self.eye;
    GLKVector3 center = self.center;
    GLKVector3 up = self.up;
    GLKVector3 direct = GLKVector3Make(0, radians, 0);
    direct = GLKMatrix4MultiplyAndProjectVector3(GLKMatrix4Invert(_matrix, NULL), direct);
    GLKVector3 diff = GLKVector3Subtract(center, eye);
    GLKVector3 axis = GLKVector3CrossProduct(diff, direct);
    GLKMatrix4 matrix = GLKMatrix4MakeTranslation(-center.x, -center.y, -center.z);
    matrix = GLKMatrix4Rotate(matrix, sign * radians, axis.x, axis.y, axis.z);
    matrix = GLKMatrix4Translate(matrix, center.x, center.y, center.z);
    
    self.eye = GLKMatrix4MultiplyAndProjectVector3(matrix, eye);
    self.up = GLKMatrix4MultiplyAndProjectVector3(matrix, up);
}

- (void)rorateXYAroundCenterWithX:(float)x Y:(float)y
{
    if (x == 0 && y == 0)
        return;
    float sa = sinf(x / 2);
    float sb = sinf(y / 2);
    float radians = 2 * asinf(sqrtf(sa * sa + sb * sb));
    float sign = radians >= 0 ? 1 : -1;
    GLKVector3 eye = self.eye;
    GLKVector3 center = self.center;
    GLKVector3 up = self.up;
    GLKVector3 direct = GLKVector3Make(x, y, 0);
    direct = GLKMatrix4MultiplyAndProjectVector3(GLKMatrix4Invert(_matrix, NULL), direct);
    GLKVector3 diff = GLKVector3Subtract(center, eye);
    GLKVector3 axis = GLKVector3CrossProduct(diff, direct);
    GLKMatrix4 matrix = GLKMatrix4MakeTranslation(-center.x, -center.y, -center.z);
    matrix = GLKMatrix4Rotate(matrix, sign * radians, axis.x, axis.y, axis.z);
    matrix = GLKMatrix4Translate(matrix, center.x, center.y, center.z);
    
    self.eye = GLKMatrix4MultiplyAndProjectVector3(matrix, eye);
    self.up = GLKMatrix4MultiplyAndProjectVector3(matrix, up);
}

- (void)rotateWithVector:(GLKVector3)rotate
{
    GLKMatrix4 matrix = GLKMatrix4Translate(GLKMatrix4Identity, self.center.x, self.center.y, self.center.z);
    matrix = GLKMatrix4RotateX(matrix, rotate.x);
    matrix = GLKMatrix4RotateY(matrix, rotate.y);
    matrix = GLKMatrix4RotateZ(matrix, rotate.z);
    matrix = GLKMatrix4Translate(matrix, -_center.x, -_center.y, -_center.z);
    
    self.eye = GLKMatrix4MultiplyAndProjectVector3(matrix, self.eye);
    self.up = GLKMatrix4MultiplyAndProjectVector3(matrix, self.up);
}

@end
