//
//  Projection.m
//  Jasmine
//
//  Created by Qiang Li on 12-9-18.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "GProjection.h"

@interface GProjection ()
{
    GLKMatrix4 _matrix;
}

@end

@implementation GProjection

@synthesize matrix = _matrix;

- (void)setWithProjection:(GProjection *)projection
{
    _matrix = projection.matrix;
}

- (void)makeOrthoWithWidth:(float)width height:(float)height
{
    _matrix = GLKMatrix4MakeOrtho(0, width, height, 0, -1024, 1024);
}

- (void)makePerspectiveWithWidth:(float)width height:(float)height fovyRadians:(float)fovy
{
    _matrix = GLKMatrix4MakePerspective(fovy, width / height, 0.01, 1500);
}

- (void)makePerspectiveWithWidth:(float)width height:(float)height fovyRadians:(float)fovy nearZ:(float)near farZ:(float)far
{
    _matrix = GLKMatrix4MakePerspective(fovy, width / height, near, far);
}

@end
