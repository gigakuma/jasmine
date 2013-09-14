//
//  PointParticleSystem.h
//  Jasmine
//
//  Created by Qiang Li on 12-10-10.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParticleSystem.h"

@interface PointParticleSystem : ParticleSystem

@property (nonatomic) float speed;
@property (nonatomic) float speedVariety;

@property (nonatomic) GLKVector4 color;
@property (nonatomic) float colorVariety;

@end
