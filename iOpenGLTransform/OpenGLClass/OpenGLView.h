//
//  OpenGLView.h
//  iOpenGLDemo
//
//  Created by Ethan Guo on 17/2/14.
//  Copyright © 2017年 com.bjdv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface OpenGLView : UIView

@property (strong, nonatomic) CAEAGLLayer *eaglLayer;
@property (strong, nonatomic) EAGLContext *context;

@property (nonatomic) GLuint colorRenderBuffer;
@property (nonatomic) GLuint frameBuffer;
@property (nonatomic) GLuint programHandle;
@property (nonatomic) GLuint positionSlot;
@property (nonatomic) GLuint modelViewSlot;
@property (nonatomic) GLuint projectionSlot;

@property (assign, nonatomic) float xPos;
@property (assign, nonatomic) float yPos;
@property (assign, nonatomic) float zPos;
@property (assign, nonatomic) float rotateX;
@property (assign, nonatomic) float scaleZ;

- (void)resetTransform;

@end
