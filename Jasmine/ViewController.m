//
//  ViewController.m
//  Jasmine
//
//  Created by Qiang Li on 12-9-12.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "ViewController.h"
#import "Director.h"
#import "GLProgram.h"
#import "GLStateCache.h"
#import "DrawWorld.h"
#import "TestRect.h"
#import "Timeline.h"
#import "DotsWorld.h"
#import "GLMatrixStack.h"

@interface ViewController ()
{
    Director *_director;
    BOOL pause;
}

@end

@implementation ViewController
@synthesize fpsLabel;

- (void)loadShaders
{
    {
        ProgramInfo info;
        PROGRAM_INFO_BASIC(info, "primitive2d", "Primitive2d.vsh", "Primitive2d.fsh");
        PROGRAM_INFO_ATTRIBUTES(info, "position", "color");
        PROGRAM_INFO_UNIFORMS(info, "matrix");
        PROGRAM_CREATE(info);
    }
    {
        ProgramInfo info;
        PROGRAM_INFO_BASIC(info, "primitive3d", "Primitive3d.vsh", "Primitive3d.fsh");
        PROGRAM_INFO_ATTRIBUTES(info, "position", "color");
        PROGRAM_INFO_UNIFORMS(info, "matrix");
        PROGRAM_CREATE(info);
    }
    {
        ProgramInfo info;
        PROGRAM_INFO_BASIC(info, "textured2d", "Textured2d.vsh", "Textured2d.fsh");
        PROGRAM_INFO_ATTRIBUTES(info, "position", "color", "texcoord");
        PROGRAM_INFO_UNIFORMS(info, "matrix", "texture");
        PROGRAM_CREATE(info);
    }
    {
        ProgramInfo info;
        PROGRAM_INFO_BASIC(info, "textured3d", "Textured3d.vsh", "Textured3d.fsh");
        PROGRAM_INFO_ATTRIBUTES(info, "position", "color", "texcoord");
        PROGRAM_INFO_UNIFORMS(info, "matrix", "texture");
        PROGRAM_CREATE(info);
    }
    {
        ProgramInfo info;
        PROGRAM_INFO_BASIC(info, "volumelight", "VolumeLight.vsh", "VolumeLight.fsh");
        PROGRAM_INFO_ATTRIBUTES(info, "position", "texcoord");
        PROGRAM_INFO_UNIFORMS(info, "exposure", "decay", "density", "weight", "lightPositionOnScreen", "texture", "matrix");
        PROGRAM_CREATE(info);
    }
    
}

- (void)unloadShaders
{
    PROGRAM_DELETE(@"primitive2d");
    PROGRAM_DELETE(@"primitive3d");
    PROGRAM_DELETE(@"textured2d");
    PROGRAM_DELETE(@"textured3d");
    PROGRAM_DELETE(@"volumelight");
}

- (void)configurateView:(GLView *)view andDirector:(Director *)director
{
    view.colorFormat = kGLRenderColorRGBA8888;
    view.depthFormat = kGLRenderDepth24;
    view.stencilFormat = kGLRenderStencilNone;
    view.multisample = kGLRenderMultisampleNone;
    director.preferredFramePerSecond = 60;
    _director = director;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pause = NO;
    
//    DrawWorld *world = [[DrawWorld alloc] init];
//    
//    float width = view.width;
//    float height = view.height;
//    world.projection.matrix = GLKMatrix4MakeFrustum(-width/2, width/2, +height/2, -height/2, 1, 100);
//    world.camera.eye = GLKVector3Make(0.f, 0.f, 0.f);
//    world.camera.center = GLKVector3Make(0.f, 0.f, -2);
//    world.camera.up = GLKVector3Make(0.f, 1.f, 0.f);
    

//    TestRect *rect = [[TestRect alloc] init];
//    rect.color1 = GLKVector4Make(0.23, 0.48, 0.87, 1);
//    rect.color2 = GLKVector4Make(0.52, 0.16, 0.38, 1);
//    [dotsWorld addChild:rect];
    
    
    //////// demo action ////////
    
//    Action *action = [[Action alloc] initWithDuration:5.0f];
//    
//    action.update = ^(double progress) {
//        // rotate the rect
//        rect.rotateZ = progress * M_PI * 2;
//    };
//    
//    action.autoReplay = YES;
//    [action play];
    
//    Action *animation1 = [rect animationWithKeyAndFloatValues:
//                          @{
//                          @"rotateZ" : @(M_PI * 2.0f),
//                          @"scaleX" : @(0.0f),
//                          @"scaleY" : @(0.0f),
//                          @"translateY" : @(-200.0f)
//                          } duration:5.0f];
//    animation1.autoReplay = YES;
//    [animation1 play];
    
    //////// demo timer ////////
    
//    Action *timer = [Action timerWithInterval:1.0f repeat:3 delegate:^(int n) {
//        NSLog(@"timer tick: %d", n);
//    }];
//    [timer play];
    
    
    //////// update ////////
//    Action *update = [Action constantlyUpdateActionWithDelegate:^(NSTimeInterval time) {
//
//    }];
//    [update play];
    
    __block float fps = 60;
    Action *update = [Action constantlyUpdateActionWithDelegate:^(NSTimeInterval time) {
        //NSLog(@"%f", time);
        fps = 0.2 * fps + 0.8 * [Director sharedDirector].framePerSecond;
        fpsLabel.text = [NSString stringWithFormat:@"%.2f", fps];
    }];
    [update play];
 
//    [self initBox2d];
}

- (void)startPlay
{
    GLView *view = (GLView *)self.view;
    DrawScene *scene = [[DrawScene alloc] init];
    DotsWorld *dotsWorld = [[DotsWorld alloc] initWithWidth:view.width / [[UIScreen mainScreen] scale] height:view.height / [[UIScreen mainScreen] scale]];
    [scene addWorld:dotsWorld];
    // opengl screen coordinate:
    // (-1,  1)  ^  ( 1,  1)
    //         --+->
    // (-1, -1)  |  ( 1, -1)
    //WORLD TO SCREEN
    GLKVector4 point = GLKVector4Make(10, 10, 0, 1);
    GLKMatrix4 lookAndPerspect = GLKMatrix4Multiply(dotsWorld.projection.matrix, dotsWorld.camera.matrix);
    point = GLKMatrix4MultiplyVector4(lookAndPerspect, point);
    NSLog(@"%.2f, %.2f",
          (point.x / point.w * view.width + view.width) / 2,
          ((1 - point.y / point.w) * view.height) / 2);
    NSLog(@"%.2f, %.2f, %.2f", point.x/point.w, point.y/point.w, point.z/point.w);
    //WORLD TO SCREEN
    
    //SCREEN TO WORLD
    GLKVector2 sp = GLKVector2Make(240, 160);
    GLKVector4 normal = GLKVector4Make((2 * sp.x / view.width - 1),
                                       (2 * (view.height - sp.y) / view.height - 1),
                                       -1, 1);
    GLKMatrix4 inversedMatrix = GLKMatrix4Invert(lookAndPerspect, NULL);
    GLKVector4 nearPoint = GLKMatrix4MultiplyVector4(inversedMatrix, normal);
    nearPoint = GLKVector4Make(nearPoint.v[0] / nearPoint.v[3],
                               nearPoint.v[1] / nearPoint.v[3],
                               nearPoint.v[2] / nearPoint.v[3], 1);
    normal.z = 1.0;
    GLKVector4 farPoint = GLKMatrix4MultiplyVector4(inversedMatrix, normal);
    farPoint = GLKVector4Make(farPoint.v[0] / farPoint.v[3],
                              farPoint.v[1] / farPoint.v[3],
                              farPoint.v[2] / farPoint.v[3], 1);
    NSLog(@"near:%.2f, %.2f, %.2f", nearPoint.x, nearPoint.y, nearPoint.z);
    NSLog(@"far :%.2f, %.2f, %.2f", farPoint.x, farPoint.y, farPoint.z);
    //SCREEN TO WORLD
    
    _director.scene = scene;
//    GLKVector3 unit = GLKVector3Make(1, 0, 0);
//    
//    unit = GLKMatrix4MultiplyAndProjectVector3(GLKMatrix4Invert(dotsWorld.camera.matrix, NULL), unit);
//    GLKVector3 diff = GLKVector3Subtract(dotsWorld.camera.center, dotsWorld.camera.eye);
//    GLKVector3 axis = GLKVector3CrossProduct(diff, unit);
//    NSLog(@"%f, %f, %f", unit.x, unit.y, unit.z);
}

//- (void)initBox2d
//{
//    // Define the gravity vector.
//	b2Vec2 gravity(0.0f, -10.0f);
//    
//	// Construct a world object, which will hold and simulate the rigid bodies.
//    b2World *world_ptr = new b2World(gravity);
//	b2World &world = *world_ptr;
//    
//	// Define the ground body.
//	b2BodyDef groundBodyDef;
//	groundBodyDef.position.Set(0.0f, -1.0f);
//    
//	// Call the body factory which allocates memory for the ground body
//	// from a pool and creates the ground box shape (also from a pool).
//	// The body is also added to the world.
//	b2Body* groundBody = world.CreateBody(&groundBodyDef);
//    
//	// Define the ground box shape.
//	b2PolygonShape groundBox;
//    
//	// The extents are the half-widths of the box.
//	groundBox.SetAsBox(50.0f, 10.0f);
//    
//	// Add the ground fixture to the ground body.
//	groundBody->CreateFixture(&groundBox, 0.0f);
//    
//	// Define the dynamic body. We set its position and call the body factory.
//	b2BodyDef bodyDef;
//	bodyDef.type = b2_dynamicBody;
//	bodyDef.position.Set(0.0f, 4.0f);
//	b2Body* body = world.CreateBody(&bodyDef);
//    
//	// Define another box shape for our dynamic body.
//	b2PolygonShape dynamicBox;
//	dynamicBox.SetAsBox(1.0f, 1.0f);
//    
//	// Define the dynamic body fixture.
//	b2FixtureDef fixtureDef;
//	fixtureDef.shape = &dynamicBox;
//    
//	// Set the box density to be non-zero, so it will be dynamic.
//	fixtureDef.density = 1.0f;
//    
//	// Override the default friction.
//	fixtureDef.friction = 0.3f;
//    
//	// Add the shape to the body.
//	body->CreateFixture(&fixtureDef);
//    
//	// Prepare for simulation. Typically we use a time step of 1/60 of a
//	// second (60Hz) and 10 iterations. This provides a high quality simulation
//	// in most game scenarios.
//	int32 velocityIterations = 6;
//	int32 positionIterations = 2;
//    
//    Action *b2Update = [Action constantlyUpdateActionWithDelegate:^(NSTimeInterval time) {
//    
//        // Instruct the world to perform a single step of simulation.
//		// It is generally best to keep the time step and iterations fixed.
//		world_ptr->Step(time, velocityIterations, positionIterations);
//    
//		// Now print the position and angle of the body.
//		b2Vec2 position = body->GetPosition();
//		float32 angle = body->GetAngle();
//    
//		printf("Box -> %4.2f %4.2f %4.2f\n", position.x, position.y, angle);
//    
//    }];
//    [b2Update play];
//
//}

- (void)viewDidUnload
{
    [self setFpsLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    if (!pause) {
//        Timeline *timeline = [Timeline sharedTimeline];
//        [_director pause];
//        NSLog(@"pause at:%f", [_director timeElasped]);
//    } else {
//        [_director resume];
//        NSLog(@"resume at:%f", [_director timeElasped]);
//    }
//    pause = !pause;
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self.view];
    lastPos = loc;
}

CGPoint lastPos = CGPointMake(0, 0);
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    DotsWorld *dotWorld = (DotsWorld*) _director.scene.worlds[0];
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self.view];
    
    dotWorld.rotateZ += 0.01f * (loc.x - lastPos.x);
    dotWorld.rotateX += 0.01f * (-loc.y + lastPos.y);
    lastPos = loc;
}

@end
