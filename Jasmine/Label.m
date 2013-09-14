//
//  Label.m
//  Jasmine
//
//  Created by Qiang Li on 12-10-23.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "Label.h"

@implementation Label

- (id)init
{
    self = [super init];
    if (self) {
        _textDirty = NO;
        _fontSize = 0;
        _constrains = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        _size = CGSizeMake(0, 0);
        _alignment = UITextAlignmentLeft;
        _text = @"";
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _text = text;
    _textDirty = YES;
}

- (void)setFontSize:(float)fontSize
{
    _fontSize = fontSize;
    _textDirty = YES;
}

- (void)setAlignment:(UITextAlignment)alignment
{
    _alignment = alignment;
    _textDirty = YES;
}

- (void)setConstrains:(CGSize)constrains
{
    _constrains = constrains;
    _textDirty = YES;
}

- (void)layout
{
}

@end
