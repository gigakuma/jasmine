//
//  DrawContainer.h
//  Jasmine
//
//  Created by Gong Zhang on 12-10-10.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "DrawModel.h"

@interface DrawGroup : DrawModel

@property (nonatomic, readonly) NSArray *children;

- (void)addChild:(DrawModel*)model;
- (void)insertChild:(DrawModel*)model atIndex:(int)index;
- (void)removeChild:(DrawModel*)model;
- (void)removeChildAtIndex:(int)index;
- (void)removeAllChildren;

@end
