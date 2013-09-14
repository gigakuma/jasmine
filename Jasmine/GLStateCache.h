//
//  GLStateCache.h
//  Jasmine
//
//  Created by Qiang Li on 12-9-13.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLTexture2D.h"

void GLCacheInitialize();
void GLCacheFinalize();

void GLCacheActiveTexture(GLenum index);
void GLCacheBindTexture2D(GLTexture2D *texture);

GLuint GLGetDefaultFramebuffer();