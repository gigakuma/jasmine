//
//  TestRect.m
//  Jasmine
//
//  Created by Qiang Li on 12-9-18.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "TestRect.h"
#import "GLTexture2D.h"
#import "util/random.h"
#import "GLProgram.h"
#import "DrawWorld.h"
#import "GLStateCache.h"

typedef struct _primitiveVector
{
    GLKVector2 position;
    GLKVector2 texcoord;
    GLKVector4 color;
} PrimitiveVector;

typedef struct _primitiveQuad
{
    PrimitiveVector lt, lb, rt, rb;
} PrimitiveQuad;

@interface TestRect ()
{
    PrimitiveQuad _quad;
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    float _angle;
}

@end

@implementation TestRect

GLTexture2D* sharedTexture = nil;

- (id)init
{
    self = [super init];
    if (self) {
        _quad.lt.position = GLKVector2Make(-100.f, -100.f);
        _quad.lb.position = GLKVector2Make(-100.f, 100.f);
        _quad.rt.position = GLKVector2Make(100.f, -100.f);
        _quad.rb.position = GLKVector2Make(100.f, 100.f);
        
        _quad.lt.texcoord = GLKVector2Make(0.f, 0.f);
        _quad.lb.texcoord = GLKVector2Make(0.f, 1.f);
        _quad.rt.texcoord = GLKVector2Make(1.f, 0.f);
        _quad.rb.texcoord = GLKVector2Make(1.f, 1.f);
        
        
        _quad.lt.color = GLKVector4Make(1, 1, 1, 1);
        _quad.lb.color = GLKVector4Make(1, 1, 1, 1);
        _quad.rt.color = GLKVector4Make(1, 1, 1, 1);
        _quad.rb.color = GLKVector4Make(1, 1, 1, 1);
        
        glGenVertexArraysOES(1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);
        
        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(PrimitiveQuad), &_quad, GL_DYNAMIC_DRAW);
        
        GLProgram *prog = PROGRAM_FIND(@"textured2d");
        GLuint a_position = PROGRAM_ATTRIBUTE(prog, @"position");
        GLuint a_texcoord = PROGRAM_ATTRIBUTE(prog, @"texcoord");
        GLuint a_color = PROGRAM_ATTRIBUTE(prog, @"color");
        
        glEnableVertexAttribArray(a_position);
        glVertexAttribPointer(a_position, 2, GL_FLOAT, GL_FALSE, sizeof(PrimitiveVector), (void *)NULL + 0);
        
        glEnableVertexAttribArray(a_texcoord);
        glVertexAttribPointer(a_texcoord, 2, GL_FLOAT, GL_FALSE, sizeof(PrimitiveVector), (void *)NULL + 8);
        
        glEnableVertexAttribArray(a_color);
        glVertexAttribPointer(a_color, 4, GL_FLOAT, GL_FALSE, sizeof(PrimitiveVector), (void *)NULL + 16);
        
        glBindVertexArrayOES(0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        if (sharedTexture == nil) {
            sharedTexture = [GLTexture2D textureWithFileName:@"light.png"];
            [sharedTexture generateMipmap];
        }
    }
    return self;
}

- (void)draw
{
    float alpha = RANDOM_0_1*0.7f+0.3f;
    _quad.lt.color.a = alpha;
    _quad.lb.color.a = alpha;
    _quad.rt.color.a = alpha;
    _quad.rb.color.a = alpha;
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(PrimitiveQuad), &_quad);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    Camera *camera = self.world.camera;
    
    PROGRAM_USE(@"textured2d");
    GLKMatrix4 matrixToCamera = GLKMatrix4Multiply(camera.matrix, self.modelToWorldTransformCache);
    GLKVector3 posWorld = GLKMatrix4MultiplyAndProjectVector3(matrixToCamera, GLKVector3Make(0, 0, 0));
    GLKVector3 xVector = GLKVector3Make(1, 0, 0);
    GLKVector3 yVector = GLKVector3Make(0, 1, 0);
    GLKVector3 zVector = GLKVector3Make(0, 0, 1);
    GLKMatrix4 transform;
    transform.m00 = xVector.x;
    transform.m01 = xVector.y;
    transform.m02 = xVector.z;
    transform.m03 = 0;
    transform.m10 = yVector.x;
    transform.m11 = yVector.y;
    transform.m12 = yVector.z;
    transform.m13 = 0;
    transform.m20 = zVector.x;
    transform.m21 = zVector.y;
    transform.m22 = zVector.z;
    transform.m23 = 0;
    transform.m30 = posWorld.x;
    transform.m31 = posWorld.y;
    transform.m32 = posWorld.z;
    transform.m33 = 1;
    transform = GLKMatrix4Scale(transform, self.scaleX, self.scaleY, self.scaleZ);
    GLKMatrix4 matrix = GLKMatrix4Multiply(self.world.projection.matrix, transform);
    //_quad.lt.position =
    GLCacheActiveTexture(GL_TEXTURE0);
    GLCacheBindTexture2D(sharedTexture);
    GLint u_matrix = PROGRAM_IN_USE_UNIFORM(@"matrix");
    GLint u_texture = PROGRAM_IN_USE_UNIFORM(@"texture");
    glDepthMask(GL_FALSE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glUniformMatrix4fv(u_matrix, 1, GL_FALSE, matrix.m);
    glUniform1i(u_texture, 0);
    glBindVertexArrayOES(_vertexArray);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindVertexArrayOES(0);
    glDisable(GL_BLEND);
    glDepthMask(GL_TRUE);
}

// TODO: remove this code
- (void)updateWithInterval:(NSTimeInterval)time
{
    //_angle += time;
//    self.modelView = GLKMatrix4RotateZ(GLKMatrix4Identity, _angle);
}

@end
