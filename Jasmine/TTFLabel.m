//
//  TTFLabel.m
//  Jasmine
//
//  Created by Qiang Li on 12-10-25.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "TTFLabel.h"
#import "GLTexture2D.h"

typedef struct _TTFLabelVertex
{
    GLKVector3 position;
    GLKVector4 color;
    GLKVector2 texcoord;
} TTFLabelVertex;

typedef struct _TTFLabelQuad
{
    TTFLabelVertex lt, lb, rt, rb;
} TTFLabelQuad;

@implementation TTFLabel
{
@private
    GLTexture2D *_texture;
    TTFLabelQuad _quad;
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}

- (id)init
{
    self = [super init];
    if (self) {
        _texture = nil;
    }
    return self;
}

- (void)setLineBreakMode:(UILineBreakMode)lineBreakMode
{
    _lineBreakMode = lineBreakMode;
    _textDirty = YES;
}

- (void)layout
{
    if (_textDirty) {
        if (_texture != nil) {
            [_texture destory];
            _texture = nil;
        }
        if (![self.text isEqual:@""] || self.fontSize != 0)
            ;
//        _texture = [[GLTexture2D alloc] initWithString:self.text fontName:self.fontName fontSize:self.fontSize constrains:self.constrains alignment:self.alignment lineBreakMode:self.lineBreakMode];
    }
}

@end
