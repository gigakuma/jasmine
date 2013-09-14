//
//  Label.h
//  Jasmine
//
//  Created by Qiang Li on 12-10-23.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrawModel.h"

@interface Label : DrawModel
{
@protected
    BOOL _textDirty;
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) float fontSize;

@property (nonatomic, assign) CGSize constrains;
@property (nonatomic, assign) UITextAlignment alignment;

@property (nonatomic, readonly) CGSize size;

- (void)layout;

@end
