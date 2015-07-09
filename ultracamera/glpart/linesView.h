//
//  linesView.h
//  gl
//
//  Created by admin on 13-8-13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>

@interface linesView : UIView{
    CAEAGLLayer *gllayer;
    EAGLContext *glcontext;
    
    float row;
    float cols;
    GLint indicesnum;
    GLint allnum;
    
    GLuint renderbuffer;
    GLuint framebuffer;
    GLuint depthrenderbuffer;
    
    GLuint positionslot;
    GLuint colorslot;
    
    //float currentRotation;
    GLuint projectionUniform;
    GLuint modelviewUniform;
    
    GLuint woodtexture;
    GLuint texcordslot;
    GLuint texuniform;
    
    int randint;
    float randfloat;
    float random0;
    float random1;
}

@property(nonatomic,retain) UIImage *glimage;

-(void)runWarpingImage:(UIImage *)image;

@end
