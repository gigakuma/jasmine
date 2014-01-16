//
//  GLTexture2D.h
//  Jasmine
//
//  Created by Qiang Li on 12-9-12.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    kTexture2DPixelFormat_Automatic,
    kTexture2DPixelFormat_RGBA8888,
    kTexture2DPixelFormat_RGBA4444,
    kTexture2DPixelFormat_RGBA5551,
    kTexture2DPixelFormat_RGB888,
    kTexture2DPixelFormat_RGB565,
    kTexture2DPixelFormat_L8,
    kTexture2DPixelFormat_A8,
	kTexture2DPixelFormat_LA88,
    kTexture2DPixelFormat_RGB_PVRTC2,
    kTexture2DPixelFormat_RGB_PVRTC4,
    kTexture2DPixelFormat_RGBA_PVRTC2,
    kTexture2DPixelFormat_RGBA_PVRTC4
} Texture2DPixelFormat;

@interface GLTexture2D : NSObject

@property (readonly, nonatomic) GLuint glID;
// width of texture
@property (readonly, nonatomic) NSUInteger pixelWidth;
// height of texture
@property (readonly, nonatomic) NSUInteger pixelHeight;
// width of image, may smaller than texture width
@property (readonly, nonatomic) CGSize contentSize;

@property (readonly, nonatomic) float maxS;
@property (readonly, nonatomic) float maxT;

//@property (readonly, nonatomic) BOOL hasPremultipliedAlpha;

@property (nonatomic) BOOL antiAlias;

- (id)initWithData:(const void *)data
       pixelFormat:(Texture2DPixelFormat)format
        pixelsWide:(NSUInteger)width
        pixelsHigh:(NSUInteger)height
       contentSize:(CGSize)size;

- (void)refreshWithData:(const void *)data
            pixelFormat:(Texture2DPixelFormat)format
           contentWidth:(NSUInteger)width
          contentHeight:(NSUInteger)height
                offsetX:(NSInteger)x
                offsetY:(NSInteger)y;

- (void)destory;

- (void)generateMipmap;
- (void)setMinFilter:(GLuint)minf magFilter:(GLuint)magf wrapS:(GLuint)ws wrapT:(GLuint)wt;

@end

@interface GLTexture2D (Image)
- (id)initWithCGImage:(CGImageRef)image
          orientation:(UIImageOrientation)orientation
          pixelFormat:(Texture2DPixelFormat)pixelFormat;

- (id)initWithImage:(CGImageRef)image;
+ (GLTexture2D *)textureWithImage:(CGImageRef)image;

- (id)initWithFilePath:(NSString *)filePath;
+ (GLTexture2D *)textureWithFilePath:(NSString *)filePath;

- (id)initWithFileName:(NSString *)fileName;
+ (GLTexture2D *)textureWithFileName:(NSString *)fileName;

@end

typedef struct _TextMargin
{
    CGFloat left, top, right, bottom;
} TextMargin;

static inline TextMargin TextMarginMake(CGFloat left, CGFloat top, CGFloat right, CGFloat bottom);
static inline TextMargin TextMarginMake(CGFloat left, CGFloat top, CGFloat right, CGFloat bottom)
{
    TextMargin margin;
    margin.left = left;
    margin.right = right;
    margin.top = top;
    margin.bottom = bottom;
    return margin;
}

@interface GLTexture2D (Text)

- (id)initWithString:(NSString *)string
                font:(UIFont *)font
          dimensions:(CGSize)dimensions
              margin:(TextMargin)margin
           alignment:(UITextAlignment)alignment
       lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (id)initWithString:(NSString *)string
                font:(UIFont *)font
           constrain:(CGSize)constrain
              margin:(TextMargin)margin
           alignment:(UITextAlignment)alignment
       lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (id)initWithString:(NSString *)string
            fontName:(NSString *)fontName
            fontSize:(float)fontSize
           constrain:(CGSize)constrain
              margin:(TextMargin)margin
           alignment:(UITextAlignment)alignment
       lineBreakMode:(NSLineBreakMode)lineBreakMode;

+ (GLTexture2D *)textureWithString:(NSString *)string
                          fontName:(NSString *)fontName
                          fontSize:(float)fontSize
                         constrain:(CGSize)constrain
                            margin:(TextMargin)margin
                         alignment:(UITextAlignment)alignment
                     lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end

@interface GLTexture2D (Framebuffer)
// a initailation wrapped glTexImage2D
// 2 parameters of glTexTmage2D, "internalFormat" and "border" are discarded, for the internalFormat
// must be same as format, and the value of border must be 0.
- (id)initWithTarget:(GLenum)target level:(GLint)level format:(GLenum)format width:(GLsizei)width height:(GLsizei)height type:(GLenum)type pixels:(GLvoid*)pixels;

@end