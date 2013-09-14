//
//  GLConfig.h
//  Jasmine
//
//  Created by Qiang Li on 12-9-14.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef DEBUG_FLAG
#define DEBUG_FLAG 0
#endif

#define GLCONFIG_INFO (GetGLConfigInfo())

#ifndef TEXT_PIXEL_FORMAT_LA88
#define TEXT_PIXEL_FORMAT_LA88 1
#endif

#ifndef TEXTURE_ENABLE_NPOT
#define TEXTURE_ENABLE_NPOT YES
#endif

/*
 Enums for color buffer formats.
 */
typedef enum
{
	kGLRenderColorRGBA8888 = 0,
	kGLRenderColorRGB565,
} GLRenderColorFormat;

/*
 Enums for depth buffer formats.
 */
typedef enum
{
	kGLRenderDepthNone = 0,
	kGLRenderDepth16,
	kGLRenderDepth24,
} GLRenderDepthFormat;

/*
 Enums for stencil buffer formats.
 */
typedef enum
{
	kGLRenderStencilNone = 0,
	kGLRenderStencil8,
} GLRenderStencilFormat;

/*
 Enums for MSAA.
 */
typedef enum
{
	kGLRenderMultisampleNone = 0,
	kGLRenderMultisample4X,
} GLRenderMultisampleMode;

typedef struct _GLConfigInfo {
    GLint maxTextureSize;
	BOOL supportsPVRTC;
	BOOL supportsNPOT;
	BOOL supportsBGRA8888;
	BOOL supportsDiscardFramebuffer;
	BOOL supportsShareableVAO;
	GLint maxSamplesAllowed;
	GLint maxTextureUnits;
} GLConfigInfo;

GLConfigInfo GetGLConfigInfo();

