//
//  DrawWorld.h
//  Jasmine
//
//  Created by Qiang Li on 12-9-18.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrawGroup.h"
#import "Camera.h"
#import "Projection.h"

@interface DrawWorld : DrawGroup

@property (nonatomic, readonly) Camera *camera;
@property (nonatomic, readonly) Projection *projection;

@end
