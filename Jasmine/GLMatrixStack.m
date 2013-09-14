//
//  GLMatrixStack.m
//  Jasmine
//
//  Created by Qiang Li on 12-10-2.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "GLMatrixStack.h"

static GLKMatrixStackRef _matrixStack = nil;

void GLMatrixStackInitialize()
{
    if (!_matrixStack) {
        _matrixStack = GLKMatrixStackCreate(NULL);
    }
}

void GLMatrixStackFinalize()
{
    if (_matrixStack) {
        CFRelease(_matrixStack);
        _matrixStack = nil;
    }
}

void GLMatrixStackPush()
{
    GLKMatrixStackPush(_matrixStack);
}

void GLMatrixStackPop()
{
    GLKMatrixStackPop(_matrixStack);
}

void GLMatrixStackLoad(GLKMatrix4 matrix)
{
    GLKMatrixStackLoadMatrix4(_matrixStack, matrix);
}

void GLMatrixStackMultiple(GLKMatrix4 matrix)
{
    GLKMatrixStackMultiplyMatrix4(_matrixStack, matrix);
}

GLKMatrix4 GLMatrixStackGetTop()
{
    return GLKMatrixStackGetMatrix4(_matrixStack);
}
