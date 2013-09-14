//
//  GLRenderer.h
//  Jasmine
//
//  Created by Qiang Li on 12-9-13.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "GLConfig.h"

@interface GLRenderer : NSObject

@property (nonatomic, readonly) GLint width;
@property (nonatomic, readonly) GLint height;

@property (nonatomic) EAGLContext *context;

@property (nonatomic) GLRenderColorFormat colorFormat;
@property (nonatomic) GLRenderDepthFormat depthFormat;
@property (nonatomic) GLRenderStencilFormat stencilFormat;
@property (nonatomic) GLRenderMultisampleMode multisample;

@property (readonly, nonatomic) GLuint defaultFramebuffer;

- (id)initWithShareGroup:(EAGLSharegroup *)sharegroup;

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;

- (void)swapBuffers;

@end
