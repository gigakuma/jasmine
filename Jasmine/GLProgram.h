//
//  GLProgram.h
//  Jasmine
//
//  Created by Qiang Li on 13-3-22.
//  Copyright (c) 2013 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NUM_STR_ARGS(...) (sizeof((const char*[]){__VA_ARGS__})/sizeof(const char *))

#define PROGRAM_INFO_BASIC(info, progname, vertex, fragment)    \
do {                                                            \
    info.name = (progname);                                     \
    info.vertex_shader = (vertex);                              \
    info.fragment_shader = (fragment);                          \
} while(0)

#define PROGRAM_INFO_ATTRIBUTES(info, ...)                      \
do {                                                            \
    const char *_a[] = {__VA_ARGS__};                           \
    uint _a_size = NUM_STR_ARGS(__VA_ARGS__);                   \
    info.attribute_names = _a;                                  \
    info.attribute_size = _a_size;                              \
} while(0)

#define PROGRAM_INFO_UNIFORMS(info, ...)                        \
do {                                                            \
    const char *_u[] = {__VA_ARGS__};                           \
    uint u_size = NUM_STR_ARGS(__VA_ARGS__);                    \
    info.uniform_names = _u;                                    \
    info.uniform_size = u_size;                                 \
} while(0)

#define PROGRAM_CREATE(info) [GLProgram createProgramWithInfo:(info)]
#define PROGRAM_DELETE(progname) [GLProgram deleteProgramWithName:(progname)]

#define PROGRAM_USE(progname) [GLProgram useProgramWithName:(progname)]

#define PROGRAM_FIND(progname) [GLProgram programWithName:(progname)]
#define PROGRAM_IN_USE() [GLProgram currentProgram]

#define PROGRAM_IN_USE_ATTRIBUTE(name) [[GLProgram currentProgram] attributeForName:(name)]
#define PROGRAM_IN_USE_UNIFORM(name) [[GLProgram currentProgram] uniformForName:(name)]

#define PROGRAM_ATTRIBUTE(prog, name) [(prog) attributeForName:(name)]
#define PROGRAM_UNIFORM(prog, name) [(prog) uniformForName:(name)]

typedef struct
{
    const char *name;
    uint attribute_size;
    uint uniform_size;
    const char **attribute_names;
    const char **uniform_names;
    const char *vertex_shader;
    const char *fragment_shader;
} ProgramInfo;

@interface GLProgram : NSObject

@property (nonatomic, readonly) GLuint glID;
@property (nonatomic, readonly) NSString *name;

+ (GLProgram *)programWithName:(NSString *)name;
+ (GLProgram *)currentProgram;

+ (void)createProgramWithInfo:(ProgramInfo)info;
+ (void)deleteProgramWithName:(NSString *)name;
+ (void)useProgramWithName:(NSString *)name;

//+ (GLuint)attributeForName:(NSString *)name;
//+ (GLint)uniformForName:(NSString *)name;

- (GLuint)attributeForName:(NSString *)name;
- (GLint)uniformForName:(NSString *)name;

- (void)destory;

@end
