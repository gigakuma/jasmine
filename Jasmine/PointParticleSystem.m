//
//  PointParticleSystem.m
//  Jasmine
//
//  Created by Qiang Li on 12-10-10.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "PointParticleSystem.h"
#import "util/random.h"
#import "GLProgram.h"
#import "DrawWorld.h"

typedef struct _PointParticleProperty
{
    GLKVector4 color;
    GLKVector3 position;
    GLKVector3 velocity;
} PointParticleProperty;

typedef struct _PointParticleVertex
{
    GLKVector3 position;
    GLKVector4 color;
} PointParticleVertex;

@implementation PointParticleSystem
{
    PointParticleVertex *_vertices;
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}

+ (size_t)propertySize
{
    return sizeof(PointParticleProperty);
}

- (void)initializeParticle:(Particle *)particle
{
    PointParticleProperty *property = particle->property;
    property->position = [self.emitter emitPosition];
    property->color = self.color;
    float theta = RANDOM_0_1 * (float)M_PI;
    float phi = RANDOM_0_1 * (float)M_PI * 2;
    float sint = sinf(theta);
    float cost = cosf(theta);
    float sinp = sinf(phi);
    float cosp = cosf(phi);
    float speed = (RANDOM_MINUS1_1 * self.speedVariety + 1) * self.speed;
    property->velocity = GLKVector3Make(speed * sint * cosp, speed * sint * sinp, speed * cost);
}

- (void)updateParticle:(Particle *)particle withInterval:(NSTimeInterval)dt
{
    PointParticleProperty *property = particle->property;
    property->color.a = particle->life / particle->maxLife;
    property->position = GLKVector3Add(property->position, GLKVector3MultiplyScalar(property->velocity, dt));
}

- (void)initializeDrawBuffer
{
    _vertices = (PointParticleVertex *)malloc(sizeof(PointParticleVertex) * self.maxCount);
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(PointParticleVertex) * self.maxCount, _vertices, GL_DYNAMIC_DRAW);
    
    GLProgram *prog = PROGRAM_FIND(@"primitive3d");
    GLuint a_position = PROGRAM_ATTRIBUTE(prog, @"position");
    GLuint a_color = PROGRAM_ATTRIBUTE(prog, @"color");
    
    glEnableVertexAttribArray(a_position);
    glVertexAttribPointer(a_position, 3, GL_FLOAT, GL_FALSE, sizeof(PointParticleVertex), (void *)NULL + 0);
    
    glEnableVertexAttribArray(a_color);
    glVertexAttribPointer(a_color, 4, GL_FLOAT, GL_FALSE, sizeof(PointParticleVertex), (void *)NULL + 16);
    
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)updateDrawBuffer:(Particle *)particle withIndex:(NSUInteger)index
{
    PointParticleProperty *property = particle->property;
    _vertices[index].color = property->color;
    //GLKVector3 offset = GLKVector3Make(RANDOM_0_1 * 2.f, RANDOM_0_1 * 5.f, RANDOM_0_1 * 5.f);
    _vertices[index].position = property->position;
}

- (void)draw
{
    PROGRAM_USE(@"primitive3d");
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(PointParticleVertex) * self.count, _vertices);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    GLKMatrix4 matrix = GLKMatrix4Multiply(self.world.projection.matrix, self.world.camera.matrix);
    matrix = GLKMatrix4Multiply(matrix, self.modelToWorldTransformCache);
    glUniformMatrix4fv(PROGRAM_IN_USE_UNIFORM(@"matrix"), 1, 0, matrix.m);
    
    glBindVertexArrayOES(_vertexArray);
    
    glEnable(GL_BLEND);
    glDepthMask(GL_FALSE);
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glDrawArrays(GL_POINTS, 0, self.count);
    glDepthMask(GL_TRUE);
    glDisable(GL_BLEND);
    
    glBindVertexArrayOES(0);
}

@end
