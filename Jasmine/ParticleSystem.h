//
//  ParticleSystem.h
//  Jasmine
//
//  Created by Qiang Li on 12-10-3.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "GObject.h"
#import "ParticleEmitter.h"
#import "Timeline.h"

@class ParticleSystem;

typedef struct _Particle {
    float life;
    float maxLife;
    void *property;
} Particle;

@interface ParticleSystem : GObject
{
@protected
    Particle *_particles;
    void *_properties;
}

@property (readonly, nonatomic) NSUInteger maxCount;
@property (readonly, nonatomic) NSUInteger count;
@property (nonatomic) ParticleEmitter *emitter;
@property (assign, nonatomic) float emitPerSecond;
@property (assign, nonatomic) BOOL forceEmitWhenFull;
@property (assign, nonatomic) BOOL autoEmit;

@property (assign, nonatomic) float maxLife;
@property (assign, nonatomic) float maxLifeVariety;

@property (readonly, nonatomic) BOOL isFull;

- (id)initWithMaxCount:(NSUInteger)count;
- (id)initWithMaxCount:(NSUInteger)count withEmitter:(ParticleEmitter *)emitter;

+ (size_t)propertySize;

- (void)emit;
- (void)forceEmit;

// to be overrided
- (void)initializeParticle:(Particle *)particle;
// to be overrided
- (void)updateParticle:(Particle *)particle withInterval:(NSTimeInterval)dt;
// to be overrided
- (void)initializeDrawBuffer;
// to be overrided
- (void)updateDrawBuffer:(Particle *)particle withIndex:(NSUInteger)index;

@end
