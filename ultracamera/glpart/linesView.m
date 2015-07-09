//
//  exglview.m
//  gl
//
//  Created by admin on 13-7-25.
//
//

#import "linesView.h"
#import "gltools.h"

@implementation linesView

typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2];
}Vertex;

Vertex Vertices[1000];

GLubyte Indices[1000];


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}
-(void)runWarpingImage:(UIImage *)image{
    row = 10;
    cols = 10;
    
    gllayer = (CAEAGLLayer*) self.layer;
    gllayer.opaque = YES;
    
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    glcontext = [[EAGLContext alloc] initWithAPI:api];
    [EAGLContext setCurrentContext:glcontext];
    
    [self setupBuffers];
    [self setupShaders];
    
    [self setupVecIdx];
    [self setupVBOs];
    
    woodtexture = [gltools setupTexture:image];
    
    [self setupDisplayLink];//[self render];
}


-(void)setupBuffers{
    glGenRenderbuffers(1, &renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
    [glcontext renderbufferStorage:GL_RENDERBUFFER fromDrawable:gllayer];
    
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,GL_RENDERBUFFER, renderbuffer);
}
-(void)setupShaders{
    GLuint vertexShader = [gltools compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [gltools compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    GLuint programeHandle = glCreateProgram();
    glAttachShader(programeHandle, vertexShader);
    glAttachShader(programeHandle, fragmentShader);
    glLinkProgram(programeHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programeHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programeHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"aaaa:%@", messageString);
        exit(1);
    }
    
    glUseProgram(programeHandle);
    
    positionslot = glGetAttribLocation(programeHandle, "Position");
    colorslot = glGetAttribLocation(programeHandle, "SourceColor");
    glEnableVertexAttribArray(positionslot);
    glEnableVertexAttribArray(colorslot);
    
    texcordslot = glGetAttribLocation(programeHandle, "TexCoordIn");
    glEnableVertexAttribArray(texcordslot);
    texuniform = glGetUniformLocation(programeHandle, "Texture");
}
-(void)setupVecIdx{
    indicesnum = 0;
    allnum = 0;
    
    for (float i=0; i<row; i++) {
        for (float j=0; j<cols; j++) {
            Vertices[allnum].TexCoord[0] = j/(cols-1);
            Vertices[allnum].TexCoord[1] = i/(row-1);
            //NSLog(@"suoyin:%.1f,%.1f",j/(cols-1),i/(row-1));
            
            if(i==0 || j==0 || i==row-1 || j==cols-1){
                random0 = 0;
                random1 = 0;
            }else{
                randint = arc4random()%20-10;
                randfloat = (float)randint;
                random1 = randfloat/100.0f;
            }
            Vertices[allnum].Position[0] = j/(cols-1)*2-1 + random0;
            Vertices[allnum].Position[1] = i/(row-1)*2-1 + random1;
            Vertices[allnum].Position[2] = 0;
            
            if (i<row-1 && j<cols-1) {
                Indices[indicesnum] = i*cols+j;
                Indices[indicesnum+1] = i*cols+j+1;
                Indices[indicesnum+2] = (i+1)*cols+j;
                Indices[indicesnum+3] = i*cols+j+1;
                Indices[indicesnum+4] = (i+1)*cols+j+1;
                Indices[indicesnum+5] = (i+1)*cols+j;
                //NSLog(@"1:%.1f,%.1f,%.1f",i*cols+j,i*cols+j+1,(i+1)*cols+j);
                //NSLog(@"2:%.1f,%.1f,%.1f",i*cols+j+1,(i+1)*cols+j+1,(i+1)*cols+j);
            }
            Vertices[allnum].Color[0] = 1;
            Vertices[allnum].Color[1] = 1;
            Vertices[allnum].Color[2] = 1;
            Vertices[allnum].Color[3] = 1;
            
            indicesnum += 6;
            allnum += 1;
        }
    }
}
-(void)setupVBOs{
    GLuint vertexbuffer;
    glGenBuffers(1, &vertexbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexbuffer;
    glGenBuffers(1, &indexbuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexbuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
}

-(void)render//:(CADisplayLink*)displayLink
{
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glVertexAttribPointer(positionslot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(colorslot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(float)*3));
    
    glVertexAttribPointer(texcordslot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) *7));
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, woodtexture);
    glUniform1i(texuniform, 0);
    
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),GL_UNSIGNED_BYTE, 0);
    
    self.glimage = [self glToUIImage];
    
    [glcontext presentRenderbuffer:GL_RENDERBUFFER];
}
- (void)setupDisplayLink
{
    [self render];
//    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
//    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}


-(UIImage *) glToUIImage {
    int imgwidth = 140;
    int imgheight = 140;
    NSInteger myDataLength = imgwidth * imgheight * 4;
    
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    glReadPixels(0, 0, imgwidth, imgheight, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    // gl renders "upside down" so swap top to bottom into new array.
    // there's gotta be a better way, but this works.
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    for(int y = 0; y <imgheight; y++)
    {
        for(int x = 0; x <imgwidth * 4; x++)
        {
            buffer2[(imgheight - 1 - y) * imgwidth * 4 + x] = buffer[y * 4 * imgwidth + x];
        }
    }
    
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * imgwidth;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(imgwidth, imgheight, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // then make the uiimage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    return myImage;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
