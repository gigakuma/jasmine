//
//  GLView.h
//  Jasmine
//
//  Created by Qiang Li on 12-9-13.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLRenderer.h"
#import "GLConfig.h"

@interface GLView : UIView

@property (nonatomic, readonly) NSInteger width;
@property (nonatomic, readonly) NSInteger height;

@property (nonatomic) GLRenderColorFormat colorFormat;
@property (nonatomic) GLRenderDepthFormat depthFormat;
@property (nonatomic) GLRenderStencilFormat stencilFormat;
@property (nonatomic) GLRenderMultisampleMode multisample;

@property (nonatomic) EAGLContext *context;
@property (nonatomic) GLRenderer *renderer;

@property (nonatomic) BOOL preserveBackbuffer;

- (void)renderBegin;
- (void)renderEnd;

@end
