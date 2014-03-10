//
//  GElement.h
//  Jasmine
//
//  Created by Qiang on 3/9/14.
//  Copyright (c) 2014 Alven.Li. All rights reserved.
//
/*
 GObject is atomic object in graphic rendering framework, which supports simple transformations, 
 i.e. translation, ratation and scale. Hierarchy in rendering, which is tree-form, is represented
 by the property "parent". There is no child of a GObject. The one containing children is GNode.
 */

#import <Foundation/Foundation.h>
#import <GLKit/GLKMath.h>
#import "GLMatrixStack.h"
#import "GTransfromable.h"
#import "Timeline.h"

@class GWorld;

@interface GObject : NSObject <GTransformable>

@property (assign, nonatomic) GObject *parent;

@property (assign, nonatomic) BOOL visible;

@property (assign, nonatomic) GLKMatrix4 modelView;
@property (assign, nonatomic) GLKVector3 translate;
@property (assign, nonatomic) GLKVector3 center;
@property (assign, nonatomic) GLKVector3 rotate;
@property (assign, nonatomic) GLKVector3 scale;

- (void)renderWithModelView:(GLKMatrix4)modelView inWorld:(GWorld*)world;
- (void)visitInWorld:(GWorld*)world;

- (void)applyTransform;

@end

//// Helper Methods ////

@interface GObject (TransformHelperProperties)

@property (assign, nonatomic) float translateX, translateY, translateZ;
@property (assign, nonatomic) float centerX, centerY, centerZ;
@property (assign, nonatomic) float rotateX, rotateY, rotateZ;
@property (assign, nonatomic) float scaleX, scaleY, scaleZ;

@end

@interface GObject (WorldSpace)

@property (readonly, nonatomic) GLKVector3 worldSpacePosition;
@property (readonly, nonatomic) GLKMatrix4 modelToWorldTransform;
@property (readonly, nonatomic) GLKMatrix4 worldToModelTransform;

- (GLKVector3)pointInModelToWorld:(GLKVector3)point;
- (GLKVector3)pointInWorldToModel:(GLKVector3)point;

@end

@interface GObject (TransformAnimationMethods)

- (Action*)animationWithKeyAndFloatValues:(NSDictionary*)dict duration:(NSTimeInterval)duration;

@end
