//
//  GLStateCache.m
//  Jasmine
//
//  Created by Qiang Li on 12-9-13.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "GLStateCache.h"
#import "GLConfig.h"
#import "Director.h"

static GLuint *_textureSlots;
static uint _currentActiveTextureSlot = 0;

void GLCacheInitialize()
{
    uint count = GLCONFIG_INFO.maxTextureUnits;
    _textureSlots = (GLuint *)malloc(count * sizeof(GLuint));
    for (int i = 0; i < count; i++) {
        _textureSlots[i] = 0;
    }
}

void GLCacheFinalize()
{
    free(_textureSlots);
}

void GLCacheActiveTexture(GLenum index)
{
    if (index - GL_TEXTURE0 >= GLCONFIG_INFO.maxTextureUnits) {
        return;
    }
    if (_currentActiveTextureSlot == index - GL_TEXTURE0)
        return;
    _currentActiveTextureSlot = index - GL_TEXTURE0;
    glActiveTexture(index);
}

void GLCacheBindTexture2D(GLTexture2D *texture)
{
    GLuint glID = 0;
    if (texture != nil)
        glID = texture.glID;
    if (_textureSlots[_currentActiveTextureSlot] == glID)
        return;
    _textureSlots[_currentActiveTextureSlot] = glID;
    glBindTexture(GL_TEXTURE_2D, glID);
}

GLuint GLGetDefaultFramebuffer()
{
    return [Director sharedDirector].view.renderer.defaultFramebuffer;
}