//
//  ModelUnit.m
//  Jasmine
//
//  Created by Qiang Li on 12-9-18.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "DrawModel.h"

@implementation DrawModel
{
    @private
    BOOL _modelViewDirty;
}
@synthesize world = _world;
@synthesize parent = _parent;
@synthesize translate = _translate;
@synthesize center = _center;
@synthesize rotate = _rotate;
@synthesize scale = _scale;

- (id)init
{
    self = [super init];
    if (self) {
        _visible = YES;
        _modelView = GLKMatrix4Identity;
        _modelViewDirty = NO;
        _translate = GLKVector3Make(0, 0, 0);
        _center = GLKVector3Make(0, 0, 0);
        _rotate = GLKVector3Make(0, 0, 0);
        _scale = GLKVector3Make(1, 1, 1);
    }
    return self;
}

// override
- (void)draw
{
}

- (void)visit
{
    if (!_visible)
		return;
    
    GLMatrixStackPush();
    GLMatrixStackMultiple(self.modelView);
    _modelToWorldTransformCache = GLMatrixStackGetTop();

    GLMatrixStackPop();
}

- (void)transformWithMatrix:(GLKMatrix4)matrix
{
    self.modelView = GLKMatrix4Multiply(self.modelView, matrix);
}

- (GLKMatrix4)modelView
{
    [self applyTransform];
    return _modelView;
}

- (void)applyTransform
{
    if (_modelViewDirty) {
        GLKMatrix4 matrix = GLKMatrix4MakeTranslation(_translate.x, _translate.y, _translate.z);
        matrix = GLKMatrix4Translate(matrix, _center.x, _center.y, _center.z);
        matrix = GLKMatrix4RotateX(matrix, _rotate.x);
        matrix = GLKMatrix4RotateY(matrix, _rotate.y);
        matrix = GLKMatrix4RotateZ(matrix, _rotate.z);
        matrix = GLKMatrix4Scale(matrix, _scale.x, _scale.y, _scale.z);
        matrix = GLKMatrix4Translate(matrix, -_center.x, -_center.y, -_center.z);
        _modelView = matrix;
        _modelViewDirty = NO;
    }
}

- (GLKVector3)translate
{
    return _translate;
}

- (void)setTranslate:(GLKVector3)translate
{
    if (!GLKVector3AllEqualToVector3(_translate, translate)) {
        _translate = translate;
        _modelViewDirty = YES;
    }
}

- (GLKVector3)center
{
    return _center;
}

- (void)setCenter:(GLKVector3)center
{
    if (!GLKVector3AllEqualToVector3(_center, center)) {
        _center = center;
        _modelViewDirty = YES;
    }
}

- (GLKVector3)rotate
{
    return _rotate;
}

- (void)setRotate:(GLKVector3)rotate
{
    if (!GLKVector3AllEqualToVector3(_rotate, rotate)) {
        _rotate = rotate;
        _modelViewDirty = YES;
    }
}

- (GLKVector3)scale
{
    return _scale;
}

- (void)setScale:(GLKVector3)scale
{
    if (!GLKVector3AllEqualToVector3(_scale, scale)) {
        _scale = scale;
        _modelViewDirty = YES;
    }
}

@end

@implementation DrawModel (TransformHelperProperties)

- (float)translateX
{
    return self.translate.x;
}

- (void)setTranslateX:(float)x
{
    GLKVector3 vec = self.translate;
    vec.x = x;
    self.translate = vec;
}

- (float)translateY
{
    return self.translate.y;
}

- (void)setTranslateY:(float)y
{
    GLKVector3 vec = self.translate;
    vec.y = y;
    self.translate = vec;
}

- (float)translateZ
{
    return self.translate.z;
}

- (void)setTranslateZ:(float)z
{
    GLKVector3 vec = self.translate;
    vec.z = z;
    self.translate = vec;
}

- (float)centerX
{
    return self.center.x;
}

- (void)setCenterX:(float)x
{
    GLKVector3 vec = self.center;
    vec.x = x;
    self.center = vec;
}

- (float)centerY
{
    return self.center.y;
}

- (void)setCenterY:(float)y
{
    GLKVector3 vec = self.center;
    vec.y = y;
    self.center = vec;
}

- (float)centerZ
{
    return self.center.z;
}

- (void)setCenterZ:(float)z
{
    GLKVector3 vec = self.center;
    vec.z = z;
    self.center = vec;
}

- (float)rotateX
{
    return self.rotate.x;
}

- (void)setRotateX:(float)x
{
    GLKVector3 vec = self.rotate;
    vec.x = x;
    self.rotate = vec;
}

- (float)rotateY
{
    return self.rotate.y;
}

- (void)setRotateY:(float)y
{
    GLKVector3 vec = self.rotate;
    vec.y = y;
    self.rotate = vec;
}

- (float)rotateZ
{
    return self.rotate.z;
}

- (void)setRotateZ:(float)z
{
    GLKVector3 vec = self.rotate;
    vec.z = z;
    self.rotate = vec;
}

- (float)scaleX
{
    return self.scale.x;
}

- (void)setScaleX:(float)x
{
    GLKVector3 vec = self.scale;
    vec.x = x;
    self.scale = vec;
}

- (float)scaleY
{
    return self.scale.y;
}

- (void)setScaleY:(float)y
{
    GLKVector3 vec = self.scale;
    vec.y = y;
    self.scale = vec;
}

- (float)scaleZ
{
    return self.scale.z;
}

- (void)setScaleZ:(float)z
{
    GLKVector3 vec = self.scale;
    vec.z = z;
    self.scale = vec;
}

@end

@implementation DrawModel (TransformAnimationMethods)

- (Action*)animationWithKeyAndFloatValues:(NSDictionary*)dict duration:(NSTimeInterval)duration
{
    __weak DrawModel *model = self;
    
    // capture start values
    NSMutableDictionary *startValues = [NSMutableDictionary new];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [startValues setObject:[model valueForKey:key] forKey:key];
    }];
    
    Action *action = [[Action alloc] initWithDuration:duration];
    action.update = ^(double p) {
        [startValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            float startValue = [obj floatValue];
            float endValue = [[dict objectForKey:key] floatValue];
            [model setValue:@(startValue + ((float) p) * (endValue - startValue)) forKey:key];
        }];
    };
    return action;
}

@end

@implementation DrawModel (WorldSpace)

- (GLKVector3)worldSpacePosition
{
    return [self modelPointToWorld:_center];
}

- (GLKMatrix4)modelToWorldTransform
{
    GLKMatrix4 matrix = self.modelView;
    for (DrawModel *p = (DrawModel*)self.parent; p != nil; p = (DrawModel*)p.parent) {
        matrix = GLKMatrix4Multiply(p.modelView, matrix);
    }
    return matrix;
}

- (GLKMatrix4)modelToWorldTransformCache
{
    return _modelToWorldTransformCache;
}

- (GLKMatrix4)worldToModelTransform
{
    return GLKMatrix4Invert(self.modelToWorldTransform, NULL);
}

- (GLKVector3)modelPointToWorld:(GLKVector3)point
{
    return GLKMatrix4MultiplyAndProjectVector3(self.modelToWorldTransform, point);
}

- (GLKVector3)worldPointToModel:(GLKVector3)point
{
    return GLKMatrix4MultiplyAndProjectVector3(self.worldToModelTransform, point);
}

@end
