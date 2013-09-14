//
//  GLConfig.m
//  Jasmine
//
//  Created by Qiang Li on 12-9-14.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "GLConfig.h"

GLConfigInfo _configInfo;
BOOL initialized = NO;

GLConfigInfo GetGLConfigInfo() {
    if (!initialized) {
        glGetIntegerv(GL_MAX_TEXTURE_SIZE, &_configInfo.maxTextureSize);
		glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &_configInfo.maxTextureUnits);
        
        // iOS 4 at least
        glGetIntegerv(GL_MAX_SAMPLES_APPLE, &_configInfo.maxSamplesAllowed);
        
        char *glExtensions = (char *)glGetString(GL_EXTENSIONS);
        NSString *extensionsString = [NSString stringWithCString:glExtensions encoding: NSASCIIStringEncoding];
        
        NSArray *extensionsNames = [extensionsString componentsSeparatedByString:@" "];
        
        _configInfo.supportsPVRTC = [extensionsNames containsObject:@"GL_IMG_texture_compression_pvrtc"];
        _configInfo.supportsNPOT = TEXTURE_ENABLE_NPOT;
        
        
        BOOL bgra8a = [extensionsNames containsObject:@"GL_IMG_texture_format_BGRA8888"];
		BOOL bgra8b = [extensionsNames containsObject:@"GL_APPLE_texture_format_BGRA8888"];
		_configInfo.supportsBGRA8888 = bgra8a | bgra8b;
        
        _configInfo.supportsShareableVAO = [extensionsNames containsObject:@"GL_APPLE_vertex_array_object"];
		_configInfo.supportsDiscardFramebuffer = [extensionsNames containsObject:@"GL_EXT_discard_framebuffer"];
        initialized = YES;
    }
    return _configInfo;
}

