//
//  GLESUtils.h
//  iOpenGLDemo
//
//  Created by Ethan Guo on 17/2/15.
//  Copyright © 2017年 com.bjdv. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES2/gl.h>

@interface GLESUtils : NSObject

// Create a shader object, load the shader source string, and compile the shader.
+ (GLuint)loadShader:(GLenum)type withString:(NSString *)shadereString;
+ (GLuint)loadShader:(GLenum)type withFilePath:(NSString *)filePath;

@end
