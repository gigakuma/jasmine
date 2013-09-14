//
//  TTFLabel.h
//  Jasmine
//
//  Created by Qiang Li on 12-10-25.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "Label.h"

@interface TTFLabel : Label

@property (nonatomic) NSString *fontName;

@property (nonatomic, readwrite) UILineBreakMode lineBreakMode;

@end
