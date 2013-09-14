//
//  GLRenderer.m
//  Jasmine
//
//  Created by Qiang Li on 12-9-13.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "GLRenderer.h"
#import "GLConfig.h"

static __inline__ GLenum colorFormatConvert(GLRenderColorFormat format);
static __inline__ GLenum depthFormatConvert(GLRenderDepthFormat format);
static __inline__ GLenum stencilFormatConvert(GLRenderStencilFormat format);

static __inline__ GLenum colorFormatConvert(GLRenderColorFormat format)
{
    switch (format) {
        case kGLRenderColorRGBA8888:
            return GL_RGBA8_OES;
            break;
        case kGLRenderColorRGB565:
            return GL_RGB565;
            break;
        default:
            break;
    }
    return GL_RGBA8_OES;
}

static __inline__ GLenum depthFormatConvert(GLRenderDepthFormat format)
{
    switch (format) {
        case kGLRenderDepthNone:
            return 0;
            break;
        case kGLRenderDepth16:
            return GL_DEPTH_COMPONENT16;
            break;
        case kGLRenderDepth24:
            return GL_DEPTH_COMPONENT24_OES;
            break;
        default:
            break;
    }
    return 0;
}
static __inline__ GLenum stencilFormatConvert(GLRenderStencilFormat format)
{
    switch (format) {
        case kGLRenderStencilNone:
            return 0;
            break;
        case kGLRenderStencil8:
            return GL_STENCIL_INDEX8;
            break;
        default:
            break;
    }
    return 0;
}
static __inline__ GLuint multipleSampleN(GLRenderMultisampleMode type);

@interface GLRenderer ()
{
    GLRenderColorFormat _colorFormat;
    GLRenderDepthFormat _depthFormat;
    GLRenderStencilFormat _stencilFormat;
    GLRenderMultisampleMode _multisample;
    
    GLuint _defaultFramebuffer;
	GLuint _colorBuffer;
	GLuint _depthBuffer;
    GLuint _stencilBuffer;
    
	GLuint _msaaFramebuffer;
	GLuint _msaaColorbuffer;
    
	EAGLContext *_context;
    
    GLint _width;
    GLint _height;
    
    BOOL _discardFramebufferSupported;
}

@end

@implementation GLRenderer

@synthesize width = _width;
@synthesize height = _height;
@synthesize context = _context;

@synthesize colorFormat = _colorFormat;
@synthesize depthFormat = _depthFormat;
@synthesize stencilFormat = _stencilFormat;
@synthesize multisample = _multisample;

@synthesize defaultFramebuffer = _defaultFramebuffer;

- (id)initWithShareGroup:(EAGLSharegroup *)sharegroup
{
    self = [super init];
    if (self) {
        if(!sharegroup)
			_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		else
			_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:sharegroup];
        
        if (!_context || ![EAGLContext setCurrentContext:_context]) {
            return nil;
        }
        
        _colorFormat = 0, _depthFormat = 0, _stencilFormat = 0, _multisample = 0;
        _width = 0, _height = 0;
        
        // main framebuffer
        glGenFramebuffers(1, &_defaultFramebuffer);
        glGenRenderbuffers(1, &_colorBuffer);
        
        // bind renderbuffer to framebuffer
        glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _colorBuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBuffer);
        
        _depthBuffer = 0, _stencilBuffer = 0, _msaaFramebuffer = 0, _msaaColorbuffer = 0;
        _discardFramebufferSupported = GLCONFIG_INFO.supportsDiscardFramebuffer;
    }
    return self;
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBuffer);
    
	if(![_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer])
		NSLog(@"failed to call context");
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
    
    glViewport(0, 0, _width, _height);
    
    GLenum colorf = colorFormatConvert(_colorFormat);
    GLenum depthf = depthFormatConvert(_depthFormat);
    GLenum stencilf = stencilFormatConvert(_stencilFormat);
    
    if (_multisample)
	{
        if (!_msaaFramebuffer) {
            glGenFramebuffers(1, &_msaaFramebuffer);
            glGenRenderbuffers(1, &_msaaColorbuffer);
            glBindFramebuffer(GL_FRAMEBUFFER, _msaaFramebuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, _msaaColorbuffer);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _msaaColorbuffer);
        }
        
		glBindFramebuffer(GL_FRAMEBUFFER, _msaaFramebuffer);
#if DEBUG_FLAG
		NSAssert(_msaaFramebuffer, @"Can't create MSAA color buffer");
#endif
		glBindRenderbuffer(GL_RENDERBUFFER, _msaaColorbuffer);
		glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, colorf , _width, _height);
		
		GLenum error;
		if ((error = glCheckFramebufferStatus(GL_FRAMEBUFFER)) != GL_FRAMEBUFFER_COMPLETE)
		{
			NSLog(@"Failed to make complete framebuffer object 0x%X", error);
			return NO;
		}
	} else {
        if (_msaaFramebuffer) {
            glDeleteFramebuffers(1, &_msaaFramebuffer);
            _msaaFramebuffer = 0;
        }
        if (_msaaColorbuffer) {
            glDeleteRenderbuffers(1, &_msaaColorbuffer);
        }
        glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    }
    
    if (_depthFormat)
	{
		if(!_depthBuffer) {
			glGenRenderbuffers(1, &_depthBuffer);
			NSAssert(_depthBuffer, @"Can't create depth buffer");
		}
        
		glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
        
		if(_multisample) {
			glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, depthf, _width, _height);
            glBindRenderbuffer(GL_RENDERBUFFER, _msaaColorbuffer);
		} else {
			glRenderbufferStorage(GL_RENDERBUFFER, depthf, _width, _height);
            glBindRenderbuffer(GL_RENDERBUFFER, _colorBuffer);
        }
            
	} else {
        if (_depthBuffer) {
            glDeleteRenderbuffers(1, &_depthBuffer);
            _depthBuffer = 0;
        }
    }
    
    if (_stencilFormat)
	{
		if(!_stencilBuffer) {
			glGenRenderbuffers(1, &_stencilBuffer);
			NSAssert(_stencilBuffer, @"Can't create stencil buffer");
		}
        
		glBindRenderbuffer(GL_RENDERBUFFER, _stencilBuffer);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _stencilBuffer);
        
		if(_multisample) {
			glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, stencilf, _width, _height);
            glBindRenderbuffer(GL_RENDERBUFFER, _msaaColorbuffer);
		} else {
			glRenderbufferStorage(GL_RENDERBUFFER, stencilf, _width, _height);
            glBindRenderbuffer(GL_RENDERBUFFER, _colorBuffer);
        }
		
	} else {
        if (_stencilBuffer) {
            glDeleteRenderbuffers(1, &_stencilBuffer);
            _stencilBuffer = 0;
        }
    }
    
    GLenum error;
	if( (error = glCheckFramebufferStatus(GL_FRAMEBUFFER)) != GL_FRAMEBUFFER_COMPLETE)
	{
		NSLog(@"Failed to make complete framebuffer object 0x%X", error);
		return NO;
	}
    
	return YES;

}

- (void)dealloc
{
    // Tear down GL
    if (_defaultFramebuffer) {
        glDeleteFramebuffers(1, &_defaultFramebuffer);
        _defaultFramebuffer = 0;
    }
    
    if (_colorBuffer) {
        glDeleteRenderbuffers(1, &_colorBuffer);
        _colorBuffer = 0;
    }
    
	if(_depthBuffer) {
		glDeleteRenderbuffers(1, &_depthBuffer);
		_depthBuffer = 0;
	}
	
	if (_stencilBuffer) {
		glDeleteRenderbuffers(1, &_stencilBuffer);
		_stencilBuffer = 0;
	}
    
    if (_msaaFramebuffer) {
		glDeleteRenderbuffers(1, &_msaaFramebuffer);
		_msaaFramebuffer = 0;
	}
	
	if (_msaaColorbuffer) {
		glDeleteRenderbuffers(1, &_msaaColorbuffer);
		_msaaColorbuffer = 0;
	}
    
    // Tear down context
    if ([EAGLContext currentContext] == _context)
        [EAGLContext setCurrentContext:nil];
    
    _context = nil;
}

- (void)swapBuffers
{
    if (_multisample != kGLRenderMultisampleNone)
	{
		/* Resolve from msaaFramebuffer to resolveFramebuffer */
		glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, _msaaFramebuffer);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, _defaultFramebuffer);
		glResolveMultisampleFramebufferAPPLE();
	}
    
    if (_discardFramebufferSupported) {
        if (_multisample) {
			if (_depthFormat && _stencilFormat) {
				GLenum attachments[] = {GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT, GL_STENCIL_ATTACHMENT};
				glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 3, attachments);
			} else if (!_depthFormat && !_stencilFormat) {
                GLenum attachments[] = {GL_COLOR_ATTACHMENT0};
				glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 1, attachments);
            } else if (_depthFormat && !_stencilFormat) {
                GLenum attachments[] = {GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT};
                glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, attachments);
            } else if (!_depthFormat && _stencilFormat) {
                GLenum attachments[] = {GL_COLOR_ATTACHMENT0, GL_STENCIL_ATTACHMENT};
                glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, attachments);
            }
            
			glBindRenderbuffer(GL_RENDERBUFFER, _colorBuffer);
		} else {
            if (_depthBuffer && _stencilFormat) {
                GLenum attachments[] = {GL_DEPTH_ATTACHMENT, GL_STENCIL_ATTACHMENT};
                glDiscardFramebufferEXT(GL_FRAMEBUFFER, 2, attachments);
            } else if (_depthBuffer && !_stencilFormat) {
                GLenum attachments[] = {GL_DEPTH_ATTACHMENT};
                glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, attachments);
            } else if (!_depthFormat && _stencilFormat) {
                    GLenum attachments[] = {GL_STENCIL_ATTACHMENT};
                    glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, attachments);
            }
        }
    }
    
    if(![_context presentRenderbuffer:GL_RENDERBUFFER])
		NSLog(@"cocos2d: Failed to swap renderbuffer in %s\n", __FUNCTION__);
    
	// We can safely re-bind the framebuffer here, since this will be the
	// 1st instruction of the new main loop
	if(_multisample)
		glBindFramebuffer(GL_FRAMEBUFFER, _msaaFramebuffer);
}

@end
