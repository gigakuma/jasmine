//
//  VolumeTest.m
//  Jasmine
//
//  Created by Qiang Li on 13-3-6.
//  Copyright (c) 2013 Qiang Li. All rights reserved.
//

#import "VolumeTest.h"
#import "Director.h"
#import "GLProgram.h"
#import "GWorld.h"
#import "GLTexture2D.h"
#import "GLStateCache.h"

typedef struct _vector
{
    GLKVector2 position;
    GLKVector2 texcoord;
} Vector;

typedef struct _quad
{
    Vector lt, lb, rt, rb;
} Quad;

@implementation VolumeTest
{
    Quad _quad;
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    GLTexture2D *texture;
}

- (id)init
{
    self = [super init];
    if (self) {
        _quad.lt.position = GLKVector2Make(-64.f, 64.f);
        _quad.lb.position = GLKVector2Make(-64.f, -64.f);
        _quad.rt.position = GLKVector2Make(64.f, 64.f);
        _quad.rb.position = GLKVector2Make(64.f, -64.f);
        
        glGenVertexArraysOES(1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);
        
        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(Quad), &_quad, GL_DYNAMIC_DRAW);
        
        GLProgram *prog = PROGRAM_FIND(@"volumelight");
        GLuint a_position = PROGRAM_ATTRIBUTE(prog, @"position");
        GLint a_texcoord = PROGRAM_ATTRIBUTE(prog, @"texcoord");
        
        glEnableVertexAttribArray(a_position);
        glVertexAttribPointer(a_position, 2, GL_FLOAT, GL_FALSE, sizeof(Vector), (void *)NULL + 0);
        
        glEnableVertexAttribArray(a_texcoord);
        glVertexAttribPointer(a_texcoord, 2, GL_FLOAT, GL_FALSE, sizeof(Vector), (void *)NULL + offsetof(Vector, texcoord));
        
        glBindVertexArrayOES(0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
//        texture = [GLTexture2D textureWithFileName:@"textest.png"];
        texture = [GLTexture2D textureWithString:@"abce" fontName:@"Marker Felt" fontSize:100.f constrain:CGSizeMake(512, 512) margin:TextMarginMake(0, 0, 0, 0) alignment:UITextAlignmentLeft lineBreakMode:NSLineBreakByWordWrapping];
        _quad.lt.texcoord = GLKVector2Make(0.f, 0.f);
        _quad.lb.texcoord = GLKVector2Make(0.f, 1.f);
        _quad.rt.texcoord = GLKVector2Make(1.f, 0.f);
        _quad.rb.texcoord = GLKVector2Make(1.f, 1.f);
    }
    return self;
}

- (void)renderWithModelView:(GLKMatrix4)modelView inWorld:(GWorld *)world
{
//    GLuint fbo = [Director sharedDirector].view.renderer.defaultFramebuffer;
//    glBindFramebuffer(GL_FRAMEBUFFER, fbo);
    
    PROGRAM_USE(@"volumelight");
//    GLCacheUseProgram(VOLUMELIGHT_ID);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_DST_ALPHA);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(Quad), &_quad);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    GLKMatrix4 matrix = GLKMatrix4Multiply(world.projection.matrix, modelView);
    
    glUniformMatrix4fv(PROGRAM_IN_USE_UNIFORM(@"matrix"), 1, GL_FALSE, matrix.m);
    
    GLCacheActiveTexture(GL_TEXTURE0);
    GLCacheBindTexture2D(texture);
    glUniform1i(PROGRAM_IN_USE_UNIFORM(@"texture"), 0);
    
    glUniform1f(PROGRAM_IN_USE_UNIFORM(@"exposure"), 0.25f);
    glUniform1f(PROGRAM_IN_USE_UNIFORM(@"decay"), 0.97f);
    glUniform1f(PROGRAM_IN_USE_UNIFORM(@"density"), 0.97f);
    glUniform1f(PROGRAM_IN_USE_UNIFORM(@"weight"), 0.5f);
    glUniform2f(PROGRAM_IN_USE_UNIFORM(@"lightPositionOnScreen"), 0.5f, 0.5f);
    
    glBindVertexArrayOES(_vertexArray);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindVertexArrayOES(0);
    
    glDisable(GL_BLEND);
}


@end
