//
//  GLProgram.m
//  Jasmine
//
//  Created by Qiang Li on 13-3-22.
//  Copyright (c) 2013 Qiang Li. All rights reserved.
//

#import "GLProgram.h"
#import "GLDebug.h"
#import "util/uthash.h"

typedef struct
{
    const char *key;
    GLuint value;
    UT_hash_handle hh;
} Attribute;

typedef struct
{
    const char *key;
    GLint value;
    UT_hash_handle hh;
} Uniform;

NSMutableDictionary *_programs;
GLProgram *_currentProgram;

@interface GLProgram ()

+ (BOOL)compileShader:(GLuint *)shader type:(GLenum)type source:(const GLchar *)source;
+ (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
+ (BOOL)linkProgram:(GLuint)prog;

- (id)initWithInfo:(ProgramInfo)info;

@end

@implementation GLProgram
{
    Attribute *_attributes;
    Uniform *_uniforms;
    NSString *_name;
    GLuint _glID;
}

@synthesize glID = _glID;
@synthesize name = _name;

+ (void)initialize
{
    [super initialize];
    _programs = [[NSMutableDictionary alloc] initWithCapacity:8];
}

+ (void)createProgramWithInfo:(ProgramInfo)info
{
    GLProgram *program = [[GLProgram alloc]initWithInfo:info];
    if (program != nil) {
        [_programs setObject:program forKey:program.name];
    }
}

+ (void)deleteProgramWithName:(NSString *)name
{
    GLProgram *program = [_programs objectForKey:name];
    [program destory];
    [_programs removeObjectForKey:name];
}

+ (void)useProgramWithName:(NSString *)name
{
    GLProgram *program = [_programs objectForKey:name];
    if (_currentProgram == program)
        return;
    _currentProgram = program;
    if (program != nil) {
        glUseProgram(program.glID);
    } else {
        glUseProgram(0);
    }
}

+ (GLProgram *)programWithName:(NSString *)name
{
    GLProgram *program = [_programs objectForKey:name];
    return program;
}

+ (GLProgram *)currentProgram
{
    return _currentProgram;
}

- (id)initWithInfo:(ProgramInfo)info
{
    self = [super init];
    if (self) {
        _attributes = NULL;
        _uniforms = NULL;
        
        _glID = glCreateProgram();
        
        GLuint vert_glID = 0, frag_glID = 0;
        NSString *vsh = [[NSString alloc] initWithUTF8String:info.vertex_shader];
        NSString *vpath = [[NSBundle mainBundle] pathForResource:vsh ofType:@""];
        if (![GLProgram compileShader:&vert_glID type:GL_VERTEX_SHADER file:vpath]) {
            NSLog(@"Failed to load vertex shader");
            if (vert_glID)
                glDeleteShader(vert_glID);
            glDeleteProgram(_glID);
            return nil;
        }
        NSString *fsh = [[NSString alloc] initWithUTF8String:info.fragment_shader];
        NSString *fpath = [[NSBundle mainBundle] pathForResource:fsh ofType:@""];
        if (![GLProgram compileShader:&frag_glID type:GL_FRAGMENT_SHADER file:fpath]) {
            NSLog(@"Failed to load fragment shader");
            if (vert_glID)
                glDeleteShader(vert_glID);
            if (frag_glID)
                glDeleteShader(frag_glID);
            glDeleteProgram(_glID);
            return nil;
        }
        
        // Attach vertex shader to program.
        glAttachShader(_glID, vert_glID);
        // Attach fragment shader to program.
        glAttachShader(_glID, frag_glID);
        
        // Bind attribute locations.
        // This needs to be done prior to linking.
        for (uint i = 0; i < info.attribute_size; i++) {
            glBindAttribLocation(_glID, i, info.attribute_names[i]);
            Attribute *attribute = (Attribute *)malloc(sizeof(Attribute));
            size_t len = strlen(info.attribute_names[i]);
            char *key = (char *)malloc((len + 1) * sizeof(char));
            memcpy(key, info.attribute_names[i], len + 1);
            attribute->key = key;
            attribute->value = i;
            HASH_ADD_KEYPTR(hh, _attributes, key, len, attribute);
        }
        
        if (![GLProgram linkProgram:_glID]) {
            NSLog(@"Failed to link program: %d", _glID);
            
            if (_glID) {
                glDeleteProgram(_glID);
                _glID = 0;
            }
            return nil;
        }
        
        if (vert_glID) {
            glDetachShader(_glID, vert_glID);
        }
        if (frag_glID) {
            glDetachShader(_glID, frag_glID);
        }
        
        // Get uniform locations.
        for (uint i = 0; i < info.uniform_size; i++) {
            Uniform *uniform = (Uniform *)malloc(sizeof(Uniform));
            size_t len = strlen(info.uniform_names[i]);
            char *key = (char *)malloc((len + 1) * sizeof(char));
            memcpy(key, info.uniform_names[i], len + 1);
            uniform->key = key;
            uniform->value = glGetUniformLocation(_glID, info.uniform_names[i]);
            HASH_ADD_KEYPTR(hh, _uniforms, key, len, uniform);
        }
        
        if (vert_glID)
            glDeleteShader(vert_glID);
        if (frag_glID)
            glDeleteShader(frag_glID);
        
        _name = [[NSString alloc]initWithUTF8String:info.name];
        return self;
    }
    return nil;
}

- (GLint)uniformForName:(NSString *)name
{
    const char *key = [name UTF8String];
    Uniform *uniform;
    HASH_FIND(hh, _uniforms, key, strlen(key), uniform);
    return uniform->value;
}

- (GLuint)attributeForName:(NSString *)name
{
    const char *key = [name UTF8String];
    Attribute *attribute;
    HASH_FIND(hh, _attributes, key, strlen(key), attribute);
    return attribute->value;
}

- (void)destory
{
    {
        Attribute *el, *tmp;
        HASH_ITER(hh, _attributes, el, tmp) {
            HASH_DELETE(hh, _attributes, el);
            free((char *)el->key);
            free(el);
        }
        _attributes = NULL;
    }
    
    {
        Uniform *el, *tmp;
        HASH_ITER(hh, _uniforms, el, tmp) {
            HASH_DELETE(hh, _uniforms, el);
            free((char *)el->key);
            free(el);
        }
        _uniforms = NULL;
    }
    
    if (_glID) {
        glDeleteProgram(_glID);
        _glID = 0;
    }
}

- (void)dealloc
{
    if (_glID) {
        [self destory];
    }
}

+ (BOOL)compileShader:(GLuint *)shader type:(GLenum)type source:(const GLchar *)source
{
    GLint status;
    if (!source) {
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if DEBUG_FLAG
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        *shader = 0;
        return NO;
    }
    
    return YES;
}

+ (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    const GLchar *source;
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    return [GLProgram compileShader:shader type:type source:source];
}

+ (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if DEBUG_FLAG
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
