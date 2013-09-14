//
//  GLViewController.h
//  Jasmine
//
//  Created by Qiang Li on 12-10-2.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLView.h"
#import "Director.h"

@interface GLViewController : UIViewController

- (void)loadShaders;
- (void)unloadShaders;
- (void)configurateView:(GLView *)view andDirector:(Director *)director;
- (void)startPlay;

@end
