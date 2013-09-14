//
//  Projection.m
//  Jasmine
//
//  Created by Qiang Li on 12-9-18.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "Projection.h"

@interface Projection ()
{
    GLKMatrix4 _matrix;
}

@end

@implementation Projection

@synthesize matrix = _matrix;

- (void)setWithProjection:(Projection *)projection
{
    _matrix = projection.matrix;
}

+ (GLKMatrix4)defaultProjectionWithType:(ProjectionType)type withWidth:(float)width withHeight:(float)height
{
    switch (type) {
        case PROJECTION_2D:
            return GLKMatrix4MakeOrtho(0, width, height, 0, -1024, 1024);
            break;
        case PROJECTION_3D:
            return GLKMatrix4MakePerspective(M_PI / 3, width / height, 0.01, 1500);
        default:
            break;
    }
}

@end
