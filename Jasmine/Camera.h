//
//  Camera.h
//  Jasmine
//
//  Created by Qiang Li on 12-9-18.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKMath.h>

@interface Camera : NSObject

@property (nonatomic, readonly) GLKMatrix4 matrix;
//@property (nonatomic, setter = setEye:) GLKVector3 eye;
//@property (nonatomic, setter = setCenter:) GLKVector3 center;
//@property (nonatomic, setter = setUp:) GLKVector3 up;
@property (nonatomic, assign) GLKVector3 eye;
@property (nonatomic, assign) GLKVector3 center;
@property (nonatomic, assign) GLKVector3 up;

// helper
@property (nonatomic, assign) float eyeX;
@property (nonatomic, assign) float eyeY;
@property (nonatomic, assign) float eyeZ;

@property (nonatomic, assign) float centerX;
@property (nonatomic, assign) float centerY;
@property (nonatomic, assign) float centerZ;

@property (nonatomic, assign) float upX;
@property (nonatomic, assign) float upY;
@property (nonatomic, assign) float upZ;

- (void)zoomInWithDistance:(float)distance;
- (void)zoomOutWithDistance:(float)distance;

- (void)setWithCamera:(Camera*)camera;

- (void)test:(float)value;

@end
