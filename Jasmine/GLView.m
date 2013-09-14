//
//  GLView.m
//  Jasmine
//
//  Created by Qiang Li on 12-9-13.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "GLView.h"

@interface GLView ()
{
    GLRenderer *_renderer;
    NSInteger _width;
    NSInteger _height;
	BOOL _preserveBackbuffer;
    BOOL _enableRetinaDisplay;
}

- (void)setupLayer;
- (void)reconfigRenderer;
- (void)enableRetinaDisplay;

@end

@implementation GLView

@synthesize width = _width;
@synthesize height = _height;
@synthesize renderer = _renderer;

- (GLRenderColorFormat)colorFormat
{
    return _renderer.colorFormat;
}

- (void)setColorFormat:(GLRenderColorFormat)colorFormat
{
    _renderer.colorFormat = colorFormat;
    [self setupLayer];
}

- (GLRenderDepthFormat)depthFormat
{
    return _renderer.depthFormat;
}

- (void)setDepthFormat:(GLRenderDepthFormat)depthFormat
{
    _renderer.depthFormat = depthFormat;
}

- (GLRenderStencilFormat)stencilFormat
{
    return _renderer.stencilFormat;
}

- (void)setStencilFormat:(GLRenderStencilFormat)stencilFormat
{
    _renderer.stencilFormat = stencilFormat;
}

- (GLRenderMultisampleMode)multisample
{
    return _renderer.multisample;
}

- (void)setMultisample:(GLRenderMultisampleMode)multisample
{
    _renderer.multisample = multisample;
}

- (EAGLContext *)context
{
    return _renderer.context;
}

- (void)setContext:(EAGLContext *)context
{
    _renderer.context = context;
}

- (void)setPreserveBackbuffer:(BOOL)preserveBackbuffer
{
    _preserveBackbuffer = preserveBackbuffer;
    [self setupLayer];
}

- (void)enableRetinaDisplay
{
    if ([self respondsToSelector:@selector(setContentScaleFactor:)]) {
        [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    } else {
        NSLog(@"retina is not supported.");
    }
}

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _renderer = [[GLRenderer alloc] initWithShareGroup:nil];
        _preserveBackbuffer = NO;
        _enableRetinaDisplay = NO;
        [self enableRetinaDisplay];
        [self setupLayer];
        _width = self.layer.bounds.size.width * [UIScreen mainScreen].scale;
        _height = self.layer.bounds.size.height * [UIScreen mainScreen].scale;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _renderer = [[GLRenderer alloc] initWithShareGroup:nil];
        _preserveBackbuffer = NO;
        _enableRetinaDisplay = NO;
        [self enableRetinaDisplay];
		[self setupLayer];
        _width = self.layer.bounds.size.width * [UIScreen mainScreen].scale;
        _height = self.layer.bounds.size.height * [UIScreen mainScreen].scale;
    }
    return self;
}

- (void)setupLayer
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
	eaglLayer.opaque = YES;
    NSString *pixelFormat = self.colorFormat == kGLRenderColorRGBA8888 ? kEAGLColorFormatRGBA8 : kEAGLColorFormatRGB565;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:_preserveBackbuffer],
                                    kEAGLDrawablePropertyRetainedBacking,
									pixelFormat,
                                    kEAGLDrawablePropertyColorFormat, nil];
}

- (void)reconfigRenderer
{
    [_renderer resizeFromLayer:(CAEAGLLayer *)self.layer];
    _width = _renderer.width;
    _height = _renderer.height;
}

- (void)renderBegin
{
    [EAGLContext setCurrentContext:self.context];
    glViewport(0, 0, _width, _height);
}

- (void)renderEnd
{
    [_renderer swapBuffers];
}

- (void)layoutSubviews
{
    [self reconfigRenderer];
    NSLog(@"size:%d, %d", _width, _height);
}

@end
