//
//  Texture2DGroup.m
//  Jasmine
//
//  Created by Qiang Li on 12-10-9.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "Texture2DAtlas.h"

@implementation TexCoordQuad

@synthesize lt, lb, rt, rb;

@end

@interface Texture2DAtlas ()
{
    NSMutableArray *_quads;
    NSMutableDictionary *_names;
}

@end

@implementation Texture2DAtlas

- (id)initWithTexture2D:(GLTexture2D *)texture
{
    self = [super init];
    if (self) {
        _quads = [NSMutableArray new];
        _names = nil;
        _texture = texture;
    }
    return self;
}

- (void)appendTexCoordQuad:(TexCoordQuad *)quad
{
    [_quads addObject:quad];
}

- (TexCoordQuad *)texCoordQuadAt:(NSUInteger)index
{
    return [_quads objectAtIndex:index];
}

- (void)setName:(NSString *)name ofIndex:(NSUInteger)index
{
    if (!_names)
        _names = [NSMutableDictionary new];
    [_names setValue:@(index) forKey:name];
}

- (TexCoordQuad *)texCoordQuadWithName:(NSString *)name
{
    if (!_names)
        return nil;
    NSNumber *number = [_names valueForKey:name];
    return [_quads objectAtIndex:[number unsignedIntegerValue]];
}

@end
