//
//  QuadParticleSystem.h
//  Jasmine
//
//  Created by Qiang Li on 12-10-10.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParticleSystem.h"
#import "GLTexture2D.h"

@interface QuadParticleSystem : ParticleSystem

@property (nonatomic) float speed;
@property (nonatomic) float speedVariety;

@property (nonatomic) GLTexture2D *spirit;

@end
