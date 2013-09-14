//
//  GLViewController.m
//  Jasmine
//
//  Created by Qiang Li on 12-10-2.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "GLViewController.h"
#import "GLMatrixStack.h"
#import "GLStateCache.h"
#import "Director.h"

@interface GLViewController ()

@end

@implementation GLViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    GLCacheInitialize();
    GLMatrixStackInitialize();
    [self loadShaders];
    
    [self configurateView:(GLView *)self.view andDirector:[Director sharedDirector]];
    Director *director = [Director sharedDirector];
    director.view = (GLView *)self.view;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    GLCacheFinalize();
    GLMatrixStackFinalize();
    [self unloadShaders];
    
    Director *director = [Director sharedDirector];
    director.view = nil;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [[Director sharedDirector] start];
    [self startPlay];
}

// to be overrided
- (void)loadShaders
{
}

// to be overrided
- (void)unloadShaders
{
}

// to be overrided
- (void)configurateView:(GLView *)view andDirector:(Director *)director
{
}

// to be overrided
- (void)startPlay
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
