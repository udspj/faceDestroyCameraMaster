//
//  gltools.m
//  gl
//
//  Created by admin on 13-7-25.
//
//

#import "gltools.h"
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@implementation gltools

+(GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    NSString *shaderpath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError *error;
    NSString *shaderstr = [NSString stringWithContentsOfFile:shaderpath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderstr) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    GLuint shaderHandle = glCreateShader(shaderType);
    
    const char *shaderstringutf8 = [shaderstr UTF8String];
    int shaderstrleng = [shaderstr length];
    glShaderSource(shaderHandle, 1, &shaderstringutf8, &shaderstrleng);
    
    glCompileShader(shaderHandle);
    
    GLint compilesuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compilesuccess);
    if (compilesuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"safdsafsd:%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
}

+(GLuint)setupTexture:(UIImage *)sourceimg{
    CGImageRef image = sourceimg.CGImage;
    if (!image) {
        NSLog(@"Failed to load image");
        exit(1);
    }
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    GLubyte *imagedata = (GLubyte *)calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef imagecontext = CGBitmapContextCreate(imagedata, width, height, 8, width*4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(imagecontext, CGRectMake(0, 0, width, height), image);
    CGContextRelease(imagecontext);
    
    GLuint texturename;
    glGenTextures(1, &texturename);
    glBindTexture(GL_TEXTURE_2D, texturename);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imagedata);
    
    free(imagedata);
    return texturename;
}

@end
