//
//  GLTexture2D.m
//  Jasmine
//
//  Created by Qiang Li on 12-9-12.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//



#import "GLTexture2D.h"
#import "GLConfig.h"
#import "GLStateCache.h"
#import "GLDebug.h"

static __inline__ unsigned long nextPowerOfTow(unsigned long x);
static __inline__ unsigned long nextPowerOfTow(unsigned long x)
{
    x = x - 1;
    x = x | (x >> 1);
    x = x | (x >> 2);
    x = x | (x >> 4);
    x = x | (x >> 8);
    x = x | (x >>16);
    return x + 1;
    //    unsigned long a;
    //    if (x == 0)
    //        return x;
    //    a = 1;
    //    while (a < x) {
    //        a <<= 1;
    //    }
    //    return a;
}

@interface GLTexture2D ()
{
    BOOL _useMipmap;
}

@end

@implementation GLTexture2D

- (id)initWithData:(const void *)data pixelFormat:(Texture2DPixelFormat)format pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSize:(CGSize)size
{
    self = [super init];
    if (self) {
        
        if (format == kTexture2DPixelFormat_RGBA8888 ||
            (nextPowerOfTow(width) == width && nextPowerOfTow(height) == height))
			glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
		else
			glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        
        glGenTextures(1, &_glID);
        glBindTexture(GL_TEXTURE_2D, _glID);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        switch (format) {
            case kTexture2DPixelFormat_RGBA8888:
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
                break;
            case kTexture2DPixelFormat_RGB888:
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, (GLsizei)width, (GLsizei)height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
                break;
            case kTexture2DPixelFormat_RGBA4444:
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, data);
                break;
            case kTexture2DPixelFormat_RGBA5551:
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data);
                break;
            case kTexture2DPixelFormat_RGB565:
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, (GLsizei)width, (GLsizei)height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
                break;
            case kTexture2DPixelFormat_L8:
                glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, (GLsizei)width, (GLsizei)height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data);
                break;
            case kTexture2DPixelFormat_LA88:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, (GLsizei)width, (GLsizei)height, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, data);
				break;
			case kTexture2DPixelFormat_A8:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, (GLsizei)width, (GLsizei)height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
				break;
            case kTexture2DPixelFormat_RGB_PVRTC2:
                glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG, (GLsizei)width, (GLsizei)height, 0, (GLsizei)(width * height) / 4, data);
                break;
            case kTexture2DPixelFormat_RGB_PVRTC4:
                glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, (GLsizei)width, (GLsizei)height, 0, (GLsizei)(width * height) / 2, data);
                break;
            case kTexture2DPixelFormat_RGBA_PVRTC2:
                glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG, (GLsizei)width, (GLsizei)height, 0, (GLsizei)(width * height) / 4, data);
                break;
            case kTexture2DPixelFormat_RGBA_PVRTC4:
                glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG, (GLsizei)width, (GLsizei)height, 0, (GLsizei)(width * height) / 2, data);
                break;
            default:
                break;
        }
        glBindTexture(GL_TEXTURE_2D, 0);
        
        _contentSize = size;
        _pixelWidth = width;
        _pixelHeight = height;
        _maxS = size.width / (float)width;
        _maxT = size.height / (float)height;
        
//        _hasPremultipliedAlpha = NO;
        
    }
    return self;
}

- (void)setAntiAlias:(BOOL)antiAlias
{
    if (antiAlias == _antiAlias)
        return;
    _antiAlias = antiAlias;
    GLCacheBindTexture2D(self);
    if (antiAlias) {
        if(!_useMipmap)
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        else
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    } else {
        if(!_useMipmap)
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        else
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    }
}

- (void)setMinFilter:(GLuint)minf magFilter:(GLuint)magf wrapS:(GLuint)ws wrapT:(GLuint)wt
{
    GLCacheBindTexture2D(self);
    if (minf)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minf);
    if (magf)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magf);
    if (ws)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, ws);
    if (wt)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wt);
}

- (void)generateMipmap
{
//    if (!_useMipmap) {
    glGenerateMipmap(_glID);
    _useMipmap = YES;
//    }
}

- (void)destory
{
    if (_glID) {
        glDeleteTextures(1, &_glID);
        _glID = 0;
    }
}

- (void)dealloc
{
    [self destory];
}

@end

@implementation GLTexture2D (Image)

+ (GLTexture2D *)textureWithImage:(CGImageRef)image
{
    return [[GLTexture2D alloc] initWithImage:image];
}

+ (GLTexture2D *)textureWithFilePath:(NSString *)filePath
{
    return [[GLTexture2D alloc] initWithFilePath:filePath];
}

+ (GLTexture2D *)textureWithFileName:(NSString *)fileName
{
    return [[GLTexture2D alloc] initWithFileName:fileName];
}

- (id)initWithImage:(CGImageRef)image
{
    self = [self initWithCGImage:image orientation:UIImageOrientationUp pixelFormat:kTexture2DPixelFormat_RGBA8888];
    return self;
}

- (id)initWithFilePath:(NSString *)filePath
{
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
    CGImageRef cgImage = image.CGImage;
    if (!cgImage) {
        DEBUG_LOG(@"Failed to load image [path] %@", filePath);
        return nil;
    }

    self = [self initWithCGImage:cgImage orientation:UIImageOrientationUp pixelFormat:kTexture2DPixelFormat_RGBA8888];
    return self;
}

- (id)initWithFileName:(NSString *)fileName
{
    UIImage *image = [UIImage imageNamed:fileName];
    CGImageRef cgImage = image.CGImage;
    if (!cgImage) {
        DEBUG_LOG(@"Failed to load image [name] %@", fileName);
        return nil;
    }

    self = [self initWithCGImage:cgImage orientation:UIImageOrientationUp pixelFormat:kTexture2DPixelFormat_RGBA8888];
    return self;
}

- (id)initWithCGImage:(CGImageRef)image orientation:(UIImageOrientation)orientation pixelFormat:(Texture2DPixelFormat)pixelFormat
{
	NSUInteger				width,
                            height,
                            i;
	CGContextRef			context = nil;
	void*					data = nil;
	CGColorSpaceRef			colorSpace;
	void*					tempData;
	unsigned char*			inPixel8;
	unsigned int*			inPixel32;
	unsigned char*			outPixel8;
	unsigned short*			outPixel16;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGAffineTransform		transform;
	CGSize					imageSize;
    
    BOOL                    isPOT;
    
    isPOT = !GLCONFIG_INFO.supportsNPOT;
    
	if (image == NULL) {
		return nil;
	}
    
	if (pixelFormat == kTexture2DPixelFormat_Automatic) {
		info = CGImageGetAlphaInfo(image);
		hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
		if (CGImageGetColorSpace(image)) {
			if (CGColorSpaceGetModel(CGImageGetColorSpace(image)) == kCGColorSpaceModelMonochrome) {
				if (hasAlpha) {
					pixelFormat = kTexture2DPixelFormat_LA88;
#if DEBUG_FLAG
					if ((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 16))
                        DEBUG_LOG(@"Unoptimal image pixel format for image");
#endif
				}
				else {
					pixelFormat = kTexture2DPixelFormat_L8;
#if DEBUG_FLAG
					if((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 8))
                        DEBUG_LOG(@"Unoptimal image pixel format for image");
#endif
				}
			}
			else {
				if ((CGImageGetBitsPerPixel(image) == 16) && !hasAlpha)
                    pixelFormat = kTexture2DPixelFormat_RGBA5551;
				else {
					if (hasAlpha)
                        pixelFormat = kTexture2DPixelFormat_RGBA8888;
					else {
						pixelFormat = kTexture2DPixelFormat_RGB565;
#if DEBUG_FLAG
						if ((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 24))
                            DEBUG_LOG(@"Unoptimal image pixel format for image");
#endif
					}
				}
			}
		}
		else { //NOTE: No colorspace means a mask image
			pixelFormat = kTexture2DPixelFormat_A8;
#if DEBUG_FLAG
			if ((CGImageGetBitsPerComponent(image) != 8) && (CGImageGetBitsPerPixel(image) != 8))
                DEBUG_LOG(@"Unoptimal image pixel format for image");
#endif
		}
	}
    
	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	switch (orientation) {
            
		case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
		case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
		case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
		case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
		case UIImageOrientationLeftMirrored: //EXIF = 5
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
		case UIImageOrientationLeft: //EXIF = 6
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
		case UIImageOrientationRightMirrored: //EXIF = 7
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
		case UIImageOrientationRight: //EXIF = 8
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
		default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
	}
	if ((orientation == UIImageOrientationLeftMirrored) || (orientation == UIImageOrientationLeft) || (orientation == UIImageOrientationRightMirrored) || (orientation == UIImageOrientationRight))
        imageSize = CGSizeMake(imageSize.height, imageSize.width);
    
	width = imageSize.width;
    height = imageSize.height;
    
    if (isPOT) {
        width = nextPowerOfTow(width);
        height = nextPowerOfTow(height);
//        if (sizeToFit) {
//            width /= 2;
//            height /= 2;
//        }
    }
    NSUInteger maxSize = GLCONFIG_INFO.maxTextureSize;
    if ((width > maxSize) || (height > maxSize)) {
        DEBUG_LOG(@"Image at %ix%i pixels is too big to fit in texture", width, height);
        if (!isPOT) {
            float scale;
            if (width > height) {
                scale = (float) width / maxSize;
                height = width * height / maxSize;
                width = maxSize;
            } else {
                scale = (float) height / maxSize;
                width = width * height / maxSize;
                height = maxSize;
            }
            imageSize.width = width;
            imageSize.height = height;
            transform = CGAffineTransformScale(transform, scale, scale);
        } else {
            while ((width > maxSize) || (height > maxSize)) {
                width /= 2;
                height /= 2;
                transform = CGAffineTransformScale(transform, 0.5, 0.5);
                imageSize.width *= 0.5;
                imageSize.height *= 0.5;
            }
        }
    }
    
	switch (pixelFormat) {
            
		case kTexture2DPixelFormat_RGBA8888:
		case kTexture2DPixelFormat_RGBA4444:
            colorSpace = CGColorSpaceCreateDeviceRGB();
            data = malloc(height * width * 4);
            context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
            CGColorSpaceRelease(colorSpace);
            break;
            
		case kTexture2DPixelFormat_RGBA5551:
            colorSpace = CGColorSpaceCreateDeviceRGB();
            data = malloc(height * width * 2);
            context = CGBitmapContextCreate(data, width, height, 5, 2 * width, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder16Little);
            CGColorSpaceRelease(colorSpace);
            break;
            
		case kTexture2DPixelFormat_RGB888:
		case kTexture2DPixelFormat_RGB565:
            colorSpace = CGColorSpaceCreateDeviceRGB();
            data = malloc(height * width * 4);
            context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
            CGColorSpaceRelease(colorSpace);
            break;
            
		case kTexture2DPixelFormat_L8:
            colorSpace = CGColorSpaceCreateDeviceGray();
            data = malloc(height * width);
            context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
            CGColorSpaceRelease(colorSpace);
            break;
            
		case kTexture2DPixelFormat_A8:
            data = malloc(height * width);
            context = CGBitmapContextCreate(data, width, height, 8, width, NULL, kCGImageAlphaOnly);
            break;
            
		case kTexture2DPixelFormat_LA88:
            colorSpace = CGColorSpaceCreateDeviceRGB();
            data = malloc(height * width * 4);
            context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
            CGColorSpaceRelease(colorSpace);
            break;
            
		default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
            
	}
	if (context == NULL) {
		DEBUG_LOG(@"Failed creating CGBitmapContext");
		free(data);
		return nil;
	}
    
//	if (!isPOT && sizeToFit)
//        CGContextScaleCTM(context, (CGFloat)width / imageSize.width, (CGFloat)height / imageSize.height);
//	else {
    CGContextClearRect(context, CGRectMake(0, 0, width, height));
    CGContextTranslateCTM(context, 0, height - imageSize.height);
//	}
	if (!CGAffineTransformIsIdentity(transform))
        CGContextConcatCTM(context, transform);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    
	//Convert "-RRRRRGGGGGBBBBB" to "RRRRRGGGGGBBBBBA"
	if (pixelFormat == kTexture2DPixelFormat_RGBA5551) {
		outPixel16 = (unsigned short*)data;
		for(i = 0; i < width * height; ++i, ++outPixel16)
            *outPixel16 = *outPixel16 << 1 | 0x0001;
		DEBUG_LOG(@"Falling off fast-path converting pixel data from ARGB1555 to RGBA5551");
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRRRRRGGGGGGGGBBBBBBBB"
	else if (pixelFormat == kTexture2DPixelFormat_RGB888) {
		tempData = malloc(height * width * 3);
		inPixel8 = (unsigned char*)data;
		outPixel8 = (unsigned char*)tempData;
		for(i = 0; i < width * height; ++i) {
			*outPixel8++ = *inPixel8++;
			*outPixel8++ = *inPixel8++;
			*outPixel8++ = *inPixel8++;
			inPixel8++;
		}
		free(data);
		data = tempData;
		DEBUG_LOG(@"Falling off fast-path converting pixel data from RGBA8888 to RGB888");
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
	else if (pixelFormat == kTexture2DPixelFormat_RGB565) {
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
            *outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		free(data);
		data = tempData;
		DEBUG_LOG(@"Falling off fast-path converting pixel data from RGBA8888 to RGB565");
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGBBBBAAAA"
	else if (pixelFormat == kTexture2DPixelFormat_RGBA4444) {
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
            *outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | ((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) | ((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | ((((*inPixel32 >> 24) & 0xFF) >> 4) << 0);
		free(data);
		data = tempData;
		DEBUG_LOG(@"Falling off fast-path converting pixel data from RGBA8888 to RGBA4444");
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "LLLLLLLLAAAAAAAA"
	else if (pixelFormat == kTexture2DPixelFormat_LA88) {
		tempData = malloc(height * width * 2);
		inPixel8 = (unsigned char*)data;
		outPixel8 = (unsigned char*)tempData;
		for(i = 0; i < width * height; ++i) {
            float l = 0.2126f * inPixel8[0] + 0.7152f * inPixel8[1] + 0.0722f * inPixel8[2];
            inPixel8 += 3;
            *outPixel8++ = (unsigned char) l;
//			*outPixel8++ = *inPixel8++;
//			inPixel8 += 2;
			*outPixel8++ = *inPixel8++;
		}
		free(data);
		data = tempData;
		DEBUG_LOG(@"Falling off fast-path converting pixel data from RGBA8888 to LA88");
	}
    
    self = [self initWithData:data pixelFormat:pixelFormat pixelsWide:width pixelsHigh:height contentSize:imageSize];
    
	CGContextRelease(context);
	free(data);
    
	return self;
}

@end

@implementation GLTexture2D (Text)

- (id)initWithString:(NSString *)string font:(UIFont *)font dimensions:(CGSize)dimensions margin:(TextMargin)margin alignment:(UITextAlignment)alignment lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    NSUInteger				width,
    height;
	CGContextRef			context;
	void*					data;
	CGColorSpaceRef			colorSpace;
    BOOL                    isPOT;
    
    if (font == nil) {
		DEBUG_LOG(@"Invalid font");
		return nil;
	}
    
    width = dimensions.width + margin.left + margin.right;
    height = dimensions.height + margin.top + margin.bottom;
    
    isPOT = !GLCONFIG_INFO.supportsNPOT;
    if (isPOT) {
        width = nextPowerOfTow(width);
        height = nextPowerOfTow(height);
    }
    
    colorSpace = CGColorSpaceCreateDeviceGray();
#if TEXT_PIXEL_FORMAT_LA88
    data = calloc(height, width * 2);
#else
    data = calloc(height, width);
#endif
    context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	if (context == NULL) {
		DEBUG_LOG(@"Failed creating CGBitmapContext", NULL);
		free(data);
		return nil;
	}
	
	CGContextSetGrayFillColor(context, 1.0, 1.0);
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
	UIGraphicsPushContext(context);
    [string drawInRect:CGRectMake(margin.left, margin.top, dimensions.width, dimensions.height) withFont:font lineBreakMode:lineBreakMode alignment:alignment];
	UIGraphicsPopContext();
    
    // LA88
#if TEXT_PIXEL_FORMAT_LA88
    NSUInteger textureSize = width * height;
    unsigned short *la88_data = (unsigned short*)data;
    unsigned char  *l8_data = (unsigned char*)data;
    for (int i = textureSize - 1; i >= 0; i--) //Convert A8 to LA88
        la88_data[i] = (l8_data[i] << 8) | 0xff;
#endif
    
    Texture2DPixelFormat pixelFormat;
#if TEXT_PIXEL_FORMAT_LA88
    pixelFormat = kTexture2DPixelFormat_LA88;
#else
    pixelFormat = kTexture2DPixelFormat_L8;
#endif

    self = [self initWithData:data pixelFormat:pixelFormat pixelsWide:width pixelsHigh:height contentSize:dimensions];
	
	CGContextRelease(context);
	free(data);
	
	return self;
}

- (id)initWithString:(NSString *)string font:(UIFont *)font constrain:(CGSize)constrain margin:(TextMargin)margin alignment:(UITextAlignment)alignment lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    if (font == nil) {
		DEBUG_LOG(@"Invalid font");
		return nil;
	}
    
    CGSize dimensions = [string sizeWithFont:font
                           constrainedToSize:constrain
                               lineBreakMode:lineBreakMode];
    if (dimensions.width == 0 || dimensions.height == 0) {
        DEBUG_LOG(@"Constrain is too small");
        return nil;
    }
    
    self = [self initWithString:string font:font dimensions:dimensions margin:margin alignment:alignment lineBreakMode:lineBreakMode];
    return self;
}

- (id)initWithString:(NSString *)string fontName:(NSString *)fontName fontSize:(float)fontSize constrain:(CGSize)constrain margin:(TextMargin)margin alignment:(UITextAlignment)alignment lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
	if (!font) {
		NSLog(@"Invalid font name: %@", fontName);
		return nil;
	}
    
    self = [self initWithString:string font:font constrain:constrain margin:margin alignment:alignment lineBreakMode:lineBreakMode];
    return self;
}

+ (GLTexture2D *)textureWithString:(NSString *)string fontName:(NSString *)fontName fontSize:(float)fontSize constrain:(CGSize)constrain margin:(TextMargin)margin alignment:(UITextAlignment)alignment lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    return [[GLTexture2D alloc] initWithString:string fontName:fontName fontSize:fontSize constrain:constrain margin:margin alignment:alignment lineBreakMode:lineBreakMode];
}

@end

@implementation GLTexture2D (Framebuffer)

- (id)initWithTarget:(GLenum)target level:(GLint)level format:(GLenum)format width:(GLsizei)width height:(GLsizei)height type:(GLenum)type pixels:(GLvoid *)pixels
{
    self = [super init];
    if (self) {
        glGenTextures(1, &_glID);
        glBindTexture(GL_TEXTURE_2D, _glID);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(target, level, format, width, height, 0, format, type, pixels);
        glBindTexture(GL_TEXTURE_2D, 0);
        
        _contentSize = CGSizeMake(width, height);
        _pixelWidth = width;
        _pixelHeight = height;
        _maxS = _contentSize.width / (float)width;
        _maxT = _contentSize.height / (float)height;
    }
    return self;
}

@end