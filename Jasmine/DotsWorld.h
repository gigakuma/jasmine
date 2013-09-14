//
//  DotsWorld.h
//  Jasmine
//
//  Created by Gong Zhang on 12-9-28.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "DrawWorld.h"
#import "TestRect.h"

@class Dot;

@interface DotsWorld : DrawWorld

@property (assign, nonatomic, readonly) float width, height;
@property (strong, nonatomic, readonly) NSArray *dots;
@property (strong, nonatomic, readonly) Dot *mainDot;

- (id)initWithWidth:(float)width height:(float)height;

@end

@interface Dot : TestRect

@property (assign, nonatomic) GLKVector3 velocity, accelerate;

@end
