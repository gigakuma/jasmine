//
//  GTransfromable.h
//  Jasmine
//
//  Created by Qiang on 3/9/14.
//  Copyright (c) 2014 Alven.Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GTransformable <NSObject>

- (void)transformWithMatrix:(GLKMatrix4)matrix;

@end
