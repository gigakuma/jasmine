//
//  DrawWorld.m
//  Jasmine
//
//  Created by Qiang Li on 12-9-18.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "DrawWorld.h"

@interface DrawWorld ()
{
    Camera *_camera;
    Projection *_projection;
}

@end

@implementation DrawWorld

@synthesize camera = _camera;
@synthesize projection = _projection;

- (id)init
{
    self = [super init];
    if (self) {
        _camera = [[Camera alloc] init];
        _projection = [[Projection alloc] init];
        self.world = self;
        self.parent = nil;
    }
    return self;
}

- (void)visit
{
    if (!self.visible)
        return;
    
//    GLMatrixProjectionLoad(_projection.matrix);
//    GLMatrixCameraLoad(_camera.matrix);
    GLMatrixStackLoad(GLKMatrix4Identity);
    GLMatrixStackMultiple(self.modelView);
    _modelToWorldTransformCache = GLMatrixStackGetTop();
//    [self draw];
    for (DrawModel *model in self.children) {
        [model visit];
    }
    
}

@end
