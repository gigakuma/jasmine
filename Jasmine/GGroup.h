//
//  GGroup.h
//  Jasmine
//
//  Created by Qiang on 3/9/14.
//  Copyright (c) 2014 Alven.Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKMath.h>
#import "GObject.h"
#import "GTransfromable.h"

@interface GGroup : NSObject <GTransformable>

@property (readonly, nonatomic) NSSet *members;

- (void)addMember:(id<GTransformable>)member;
- (void)removeMember:(id<GTransformable>)member;
- (void)removeAllMembers;

@end
