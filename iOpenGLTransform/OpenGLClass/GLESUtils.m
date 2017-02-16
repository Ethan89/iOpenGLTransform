//
//  GLESUtils.m
//  iOpenGLDemo
//
//  Created by Ethan Guo on 17/2/15.
//  Copyright © 2017年 com.bjdv. All rights reserved.
//

#import "GLESUtils.h"

@implementation GLESUtils

+ (GLuint)loadShader:(GLenum)type withFilePath:(NSString *)filePath {
    NSError *error = nil;
    NSString *shaderString = [NSString stringWithContentsOfFile:filePath
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
    if (!shaderString) {
        NSLog(@"Error: loading shader file: %@, %@", filePath, error.localizedDescription);
        return 0;
    }
    
    return [self loadShader:type withString:shaderString];
}

+ (GLuint)loadShader:(GLenum)type withString:(NSString *)shadereString {
    // 创建shader对象
    GLuint shader = glCreateShader(type);
    if (shader == 0) {
        NSLog(@"Error: failed to create shader.");
        return 0;
    }
    
    // 加载shader源码
    const char *shaderStringUTF8 = [shadereString UTF8String];
    glShaderSource(shader, 1, &shaderStringUTF8, NULL);
    
    // 编译shader
    glCompileShader(shader);
    
    // 检查编译状态
    GLint complied = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &complied);
    
    if (!complied) {
        GLint infoLen = 0;
        glGetShaderiv(shader, GL_COMPILE_STATUS, &infoLen);
        
        if (infoLen > 1) {
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
            NSLog(@"Error compiling shader:\n%s\n", infoLog);
            free(infoLog);
        }
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

@end
