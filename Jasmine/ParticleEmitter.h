//
//  ParticleEmitter.h
//  Jasmine
//
//  Created by Qiang Li on 12-10-9.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKMath.h>

@interface ParticleEmitter : NSObject

@property (nonatomic) GLKVector3 position;

- (GLKVector3)emitPosition;

@end

@interface PointEmitter : ParticleEmitter

@property (nonatomic) BOOL emitOnTrack;

@end

@interface BoxEmitter : ParticleEmitter

@property (nonatomic) GLKVector3 size;
@property (nonatomic) GLKVector3 rotation;

@end

@interface SphereEmitter : ParticleEmitter

@property (nonatomic) GLKVector3 size;
@property (nonatomic) GLKVector3 rotation;

@end