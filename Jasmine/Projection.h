//
//  Projection.h
//  Jasmine
//
//  Created by Qiang Li on 12-9-18.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKMath.h>

typedef enum
{
    PROJECTION_2D,
    PROJECTION_3D
} ProjectionType;

@interface Projection : NSObject

@property (nonatomic) GLKMatrix4 matrix;

- (void)setWithProjection:(Projection*)projection;

+ (GLKMatrix4)defaultProjectionWithType:(ProjectionType)type withWidth:(float)width withHeight:(float)height;

@end
