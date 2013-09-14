//
//  ModelUnit.h
//  Jasmine
//
//  Created by Qiang Li on 12-9-18.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKMath.h>
#import "GLStateCache.h"
#import "GLMatrixStack.h"
#import "Timeline.h"

@class DrawGroup;
@class DrawWorld;

@interface DrawModel : NSObject
{
@protected
    GLKMatrix4 _modelToWorldTransformCache;
}

@property (assign, nonatomic) DrawWorld *world;
@property (assign, nonatomic) DrawGroup *parent;
@property (assign, nonatomic) BOOL visible;
@property (assign, nonatomic) BOOL opaque;

@property (assign, nonatomic) GLKMatrix4 modelView;
@property (assign, nonatomic) GLKVector3 translate;
@property (assign, nonatomic) GLKVector3 center;
@property (assign, nonatomic) GLKVector3 rotate;
@property (assign, nonatomic) GLKVector3 scale;

- (void)draw;
- (void)visit;
- (void)transformWithMatrix:(GLKMatrix4)matrix;
- (void)applyTransform;

@end

//// Helper Methods ////

@interface DrawModel (TransformHelperProperties)

@property (assign, nonatomic) float translateX, translateY, translateZ;
@property (assign, nonatomic) float centerX, centerY, centerZ;
@property (assign, nonatomic) float rotateX, rotateY, rotateZ;
@property (assign, nonatomic) float scaleX, scaleY, scaleZ;

@end

@interface DrawModel (TransformAnimationMethods)

- (Action*)animationWithKeyAndFloatValues:(NSDictionary*)dict duration:(NSTimeInterval)duration;

@end

@interface DrawModel (WorldSpace)

@property (readonly, nonatomic) GLKVector3 worldSpacePosition;
@property (readonly, nonatomic) GLKMatrix4 modelToWorldTransform;
@property (readonly, nonatomic) GLKMatrix4 worldToModelTransform;
@property (readonly, nonatomic) GLKMatrix4 modelToWorldTransformCache;

- (GLKVector3)modelPointToWorld:(GLKVector3)point;
- (GLKVector3)worldPointToModel:(GLKVector3)point;

@end
