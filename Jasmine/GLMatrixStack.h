//
//  GLMatrixStack.h
//  Jasmine
//
//  Created by Qiang Li on 12-10-2.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKMath.h>



void GLMatrixStackInitialize();
void GLMatrixStackFinalize();

void GLMatrixStackPush();
void GLMatrixStackPop();
void GLMatrixStackLoad(GLKMatrix4 matrix);
void GLMatrixStackMultiple(GLKMatrix4 matrix);

GLKMatrix4 GLMatrixStackGetTop();