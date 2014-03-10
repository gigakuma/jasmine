//
//  GElement.h
//  Jasmine
//
//  Created by Qiang on 3/9/14.
//  Copyright (c) 2014 Alven.Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GObject.h"

@interface GNode : GObject

@property (readonly, nonatomic) NSArray *children;

- (GNode*)childAtIndex:(NSUInteger)index;
- (void)addChild:(GNode*)node;
- (void)insertChild:(GNode*)node atIndex:(NSUInteger)index;
- (void)removeChild:(GNode*)node;
- (void)removeChildAtIndex:(NSUInteger)index;
- (void)removeAllChildren;

@end
