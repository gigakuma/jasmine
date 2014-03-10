//
//  GScreen.h
//  Jasmine
//
//  Created by Qiang on 3/9/14.
//  Copyright (c) 2014 Alven.Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWorld.h"

@interface GScreen : NSObject

@property (readonly, nonatomic) NSArray *worlds;

- (void)render;

- (void)addWorld:(GWorld*)world;
- (void)insertWorld:(GWorld*)world atIndex:(NSUInteger)index;
- (void)removeWorld:(GWorld*)world;
- (void)removeWorldAtIndex:(NSUInteger)index;
- (void)removeAllWorlds;

@end
