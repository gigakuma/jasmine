//
//  TestBeam.m
//  Jasmine
//
//  Created by Qiang Li on 13-6-15.
//  Copyright (c) 2013 Qiang Li. All rights reserved.
//

#import "TestBeam.h"
#import "GLProgram.h"
#import "DrawWorld.h"

typedef struct _primitiveVector
{
    GLKVector3 position;
    GLKVector2 texcoord;
    GLKVector4 color;
} PrimitiveVector;

typedef struct _primitiveQuad
{
    PrimitiveVector lt, lb, rt, rb;
} PrimitiveQuad;

@implementation TestBeam
{
    PrimitiveQuad _quad;
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}

@synthesize width = _width;
@synthesize end = _end;

GLTexture2D *sharedTexture2;

- (id)init
{
    self = [super init];
    if (self) {
        _width = 10.0f;
        _end = GLKVector3Make(0, 150.f, 0);
        
        _quad.lt.texcoord = GLKVector2Make(0.f, 0.f);
        _quad.lb.texcoord = GLKVector2Make(0.f, 1.f);
        _quad.rt.texcoord = GLKVector2Make(1.f, 0.f);
        _quad.rb.texcoord = GLKVector2Make(1.f, 1.f);
        
        _quad.lt.color = GLKVector4Make(1, 0, 0, 0.f);
        _quad.lb.color = GLKVector4Make(0.5, 1, 0, 1.f);
        _quad.rt.color = GLKVector4Make(0, 1, 1, 0.f);
        _quad.rb.color = GLKVector4Make(1, 0, 0.5f, 1.f);
        
        glGenVertexArraysOES(1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);
        
        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(PrimitiveQuad), &_quad, GL_DYNAMIC_DRAW);
        
        GLProgram *prog = PROGRAM_FIND(@"textured3d");
        GLuint a_position = PROGRAM_ATTRIBUTE(prog, @"position");
        GLuint a_texcoord = PROGRAM_ATTRIBUTE(prog, @"texcoord");
        GLuint a_color = PROGRAM_ATTRIBUTE(prog, @"color");
        
        glEnableVertexAttribArray(a_position);
        glVertexAttribPointer(a_position, 3, GL_FLOAT, GL_FALSE, sizeof(PrimitiveVector), (void *)NULL + 0);
        
        glEnableVertexAttribArray(a_texcoord);
        glVertexAttribPointer(a_texcoord, 2, GL_FLOAT, GL_FALSE, sizeof(PrimitiveVector), (void *)NULL + 16);
        
        glEnableVertexAttribArray(a_color);
        glVertexAttribPointer(a_color, 4, GL_FLOAT, GL_FALSE, sizeof(PrimitiveVector), (void *)NULL + 32);
        
        glBindVertexArrayOES(0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        if (sharedTexture2 == nil) {
            sharedTexture2 = [GLTexture2D textureWithFileName:@"beam.png"];
            [sharedTexture2 generateMipmap];
        }
    }
    return self;
}

- (void)draw
{
    PROGRAM_USE(@"textured3d");
    
    Camera *camera = self.world.camera;
    GLKMatrix4 matrixToCamera = GLKMatrix4Multiply(camera.matrix, self.modelToWorldTransformCache);
    GLKVector3 start_world = GLKMatrix4MultiplyAndProjectVector3(matrixToCamera, GLKVector3Make(0, 0, 0));
    GLKVector3 end_world = GLKMatrix4MultiplyAndProjectVector3(matrixToCamera, _end);
    GLKVector3 vector = GLKVector3Subtract(end_world, start_world);
    GLKVector3 direct = GLKVector3CrossProduct(vector, GLKVector3Make(0, 0, 1));
    if (direct.x != 0 || direct.y != 0 || direct.z != 0)
        direct = GLKVector3Normalize(direct);
    GLKVector3 direct_scale = GLKVector3MultiplyScalar(direct, _width);
    _quad.lb.position = GLKVector3Add(start_world, direct_scale);
    _quad.lt.position = GLKVector3Add(end_world, direct_scale);
    _quad.rb.position = GLKVector3Subtract(start_world, direct_scale);
    _quad.rt.position = GLKVector3Subtract(end_world, direct_scale);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(PrimitiveQuad), &_quad);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    GLCacheActiveTexture(GL_TEXTURE0);
    GLCacheBindTexture2D(sharedTexture2);
    GLint u_matrix = PROGRAM_IN_USE_UNIFORM(@"matrix");
    GLint u_texture = PROGRAM_IN_USE_UNIFORM(@"texture");
    glDepthMask(GL_FALSE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glUniformMatrix4fv(u_matrix, 1, GL_FALSE, self.world.projection.matrix.m);
    glUniform1i(u_texture, 0);
    glBindVertexArrayOES(_vertexArray);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glBindVertexArrayOES(0);
    glDisable(GL_BLEND);
    glDepthMask(GL_TRUE);
}

@end
