//
//  Projection.h
//  Jasmine
//
//  Created by Qiang Li on 12-9-18.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKMath.h>

@interface GProjection : NSObject

@property (nonatomic) GLKMatrix4 matrix;

- (void)setWithProjection:(GProjection*)projection;

- (void)makeOrthoWithWidth:(float)width
                    height:(float)height;

- (void)makePerspectiveWithWidth:(float)width
                          height:(float)height
                     fovyRadians:(float)fovy;

- (void)makePerspectiveWithWidth:(float)width
                          height:(float)height
                     fovyRadians:(float)fovy
                           nearZ:(float)near
                            farZ:(float)far;

@end