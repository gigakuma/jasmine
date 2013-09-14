//
//  Texture2DGroup.h
//  Jasmine
//
//  Created by Qiang Li on 12-10-9.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKMath.h>
#import "GLTexture2D.h"

@interface TexCoordQuad : NSObject

@property (nonatomic) GLKVector2 lt, lb, rt, rb;

@end


@interface Texture2DAtlas : NSObject

@property (readonly, nonatomic) GLTexture2D *texture;

- (id)initWithTexture2D:(GLTexture2D *)texture;

- (void)appendTexCoordQuad:(TexCoordQuad *)quad;
- (TexCoordQuad *)texCoordQuadAt:(NSUInteger)index;

- (void)setName:(NSString *)name ofIndex:(NSUInteger)index;
- (TexCoordQuad *)texCoordQuadWithName:(NSString *)name;

@end
