//
//  OpenGLView.m
//  iOpenGLDemo
//
//  Created by Ethan Guo on 17/2/14.
//  Copyright © 2017年 com.bjdv. All rights reserved.
//

#import "OpenGLView.h"
#import "GLESUtils.h"

@interface OpenGLView ()

- (void)setupLayer;
- (void)setupProgram;

@end

@implementation OpenGLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)layoutSubviews {
    [self setupLayer];
    [self setupContext];
    
    [self destoryRenderAndFrameBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    
    [self setupProgram];
    
    [self render];
}

- (void)setupLayer {
    self.eaglLayer = (CAEAGLLayer *)self.layer;
    // CALayer 默认是全透明的，必须设为不透明，才能让其可见
    self.eaglLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    self.eaglLayer.drawableProperties = @{
                                          kEAGLDrawablePropertyRetainedBacking: [NSNumber numberWithBool:NO],
                                          kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
                                          };
}

- (void)setupProgram {
    /*
     * load shader
     */
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader"
                                                                ofType:@"glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader"
                                                                   ofType:@"glsl"];
    
    GLuint vertexShader = [GLESUtils loadShader:GL_VERTEX_SHADER withFilePath:vertexShaderPath];
    GLuint fragmentShader = [GLESUtils loadShader:GL_FRAGMENT_SHADER withFilePath:fragmentShaderPath];
    
    // create program, attach shaderes
    self.programHandle = glCreateProgram();
    if (!self.programHandle) {
        NSLog(@"Failed to create program");
        return;
    }
    
    glAttachShader(self.programHandle, vertexShader);
    glAttachShader(self.programHandle, fragmentShader);
    
    // link program
    glLinkProgram(self.programHandle);
    
    // check link status
    GLint linked;
    glGetProgramiv(self.programHandle, GL_LINK_STATUS, &linked);
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv(self.programHandle, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1) {
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(self.programHandle, infoLen, NULL, infoLog);
            NSLog(@"Error linking program:\n%s\n", infoLog);
            free(infoLog);
        }
        
        glDeleteProgram(self.programHandle);
        self.programHandle = 0;
        return;
    }
    
    glUseProgram(self.programHandle);
    
    // get attribute slot from program
    self.positionSlot = glGetAttribLocation(self.programHandle, "vPosition");
}

- (void)setupContext {
    // 指定OpenGL渲染的API版本
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    self.context = [[EAGLContext alloc] initWithAPI:api];
    
    if (!self.context) {
        NSLog(@"Failed to init OpenGLES 2.0 context");
        return;
    }
    
    if (![EAGLContext setCurrentContext:self.context]) {
        NSLog(@"Failed to set current OpenGL context");
        return;
    }
}

- (void)setupRenderBuffer {
    /*
     * glGenRenderbuffers 的原型为：
     * void glGenRenderbuffers (GLsizei n, GLuint* renderbuffers)
     * 它是为 renderbuffer 申请一个 id（或曰名字）。
     * 参数 n 表示申请生成 renderbuffer 的个数，
     * 而 renderbuffers 返回分配给 renderbuffer 的 id，
     * 注意：返回的 id 不会为0，id 0 是OpenGL ES 保留的，我们也不能使用 id 为0的 renderbuffer。
     */
    glGenRenderbuffers(1, &self->_colorRenderBuffer);
    /*
     * glBindRenderbuffer 的原型为：
     * void glBindRenderbuffer (GLenum target, GLuint renderbuffer)
     * 这个函数将指定 id 的 renderbuffer 设置为当前 renderbuffer。
     * 参数 target 必须为 GL_RENDERBUFFER，参数 renderbuffer 是就是使用 glGenRenderbuffers 生成的 id。
     * 当指定 id 的 renderbuffer 第一次被设置为当前 renderbuffer 时，会初始化该 renderbuffer 对象，其初始值为：
     * width 和 height：像素单位的宽和高，默认值为0；
     * internal format：内部格式，三大 buffer 格式之一 -- color，depth or stencil；
     * Color bit-depth：仅当内部格式为 color 时，设置颜色的 bit-depth，默认值为0；
     * Depth bit-depth：仅当内部格式为 depth时，默认值为0；
     * Stencil bit-depth: 仅当内部格式为 stencil，默认值为0；
     */
    glBindRenderbuffer(GL_RENDERBUFFER, self.colorRenderBuffer);
    // 为color renderbuffer分配存储空间
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eaglLayer];
}

- (void)setupFrameBuffer {
    /* glGenFramebuffers方法与glGenRenderbuffers方法相同 */
    glGenFramebuffers(1, &self->_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, self.frameBuffer);
    /*
     * glFramebufferRenderbuffer的函数原型为：
     * void glFramebufferRenderbuffer (GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer)
     * 该函数是将相关 buffer（三大buffer之一）attach到framebuffer上（如果 renderbuffer不为 0，
     * 知道前面为什么说glGenRenderbuffers 返回的id 不会为 0 吧）或从 framebuffer上detach
     * （如果 renderbuffer为 0）。参数 attachment 是指定 renderbuffer 被装配到那个装配点上，
     * 其值是GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT, GL_STENCIL_ATTACHMENT中的一个，
     * 分别对应 color，depth和 stencil三大buffer。
     */
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.colorRenderBuffer);
}

- (void)destoryRenderAndFrameBuffer {
    glDeleteFramebuffers(1, &self->_frameBuffer);
    self.frameBuffer = 0;
    glDeleteRenderbuffers(1, &self->_colorRenderBuffer);
    self.colorRenderBuffer = 0;
}

- (void)drawPyramid {
    // 四棱锥的四个顶点坐标
    GLfloat vertices[] = {
        0.5f, 0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        -0.5f, 0.5f, 0.0f,
        0.0f, 0.0f, -0.707f,
    };
    
    GLubyte indices[] = {
        0, 1, 1, 2, 2, 3, 3, 0,
        4, 0, 4, 1, 4, 2, 4, 3
    };
    
    glVertexAttribPointer(self.positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices );
    glEnableVertexAttribArray(self.positionSlot);
    
    // Draw lines
    //
    
    /*
     * glDrawElements 函数的原型为：
     * void glDrawElements(GLenum mode, GLsizei count, GLenum type, const GLvoid *indices);
     * 第一个参数 mode 为描绘图元的模式，其有效值为：GL_POINTS, GL_LINES, GL_LINE_STRIP,  GL_LINE_LOOP,  GL_TRIANGLES,  GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN。这些模式具体含义下面有介绍。
     * 第二个参数 count 为顶点索引的个数也就是，type 是指顶点索引的数据类型，因为索引始终是正值，索引这里必须是无符号型的非浮点类型，
     * 因此只能是 GL_UNSIGNED_BYTE, GL_UNSIGNED_SHORT, GL_UNSIGNED_INT 之一，为了减少内存的消耗，尽量使用最小规格的类型如 GL_UNSIGNED_BYTE。
     * 第三个参数 indices 是存放顶点索引的数组。（indices 是 index 的复数形式，3D 里面很多单词的复数都挺特别的。）
     */
    glDrawElements(GL_LINES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
}

- (void)drawTriangle {
    GLfloat vertices[] = {
        0.0f,  0.5f,  0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f,
    };
    
    /*
     * load the vertext data
     * glVertexAttribPointer将三角形顶点数据装载到OpenGL ES中并与vPosition并联起来
     */
    glVertexAttribPointer(self.positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(self.positionSlot);
    
    // drae triangle
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)render {
    /*
     * glClearColor用来设置清屏颜色，默认为黑色
     */
    glClearColor(0, 1.0, 0, 1.0);
    
    /*
     * glClear(GLbitfieldmask)用来指定要用清屏颜色来清除由mask指定的buffer
     * mask 可以是 GL_COLOR_BUFFER_BIT，GL_DEPTH_BUFFER_BIT和GL_STENCIL_BUFFER_BIT的自由组合。
     */
    glClear(GL_COLOR_BUFFER_BIT);
   
    /*
     * 设置 viewport
     * glViewport  表示渲染 surface 将在屏幕上的哪个区域呈现出来，
     */
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    [self drawPyramid];

    
    /*
     * (BOOL)presentRenderbuffer:(NSUInteger)target 是将指定 renderbuffer 呈现在屏幕上，
     * 在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，
     * 必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
     * 在前面设置 drawable 属性时，我们设置 kEAGLDrawablePropertyRetainedBacking 为FALSE，
     * 表示不想保持呈现的内容，因此在下一次呈现时，应用程序必须完全重绘一次。
     * 将该设置为 TRUE 对性能和资源影像较大，因此只有当renderbuffer需要保持其内容不变时，
     * 我们才设置 kEAGLDrawablePropertyRetainedBacking  为 TRUE。
     */
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
