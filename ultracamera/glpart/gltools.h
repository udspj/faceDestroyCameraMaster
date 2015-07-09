//
//  gltools.h
//  gl
//
//  Created by admin on 13-7-25.
//
//

#import <Foundation/Foundation.h>

@interface gltools : NSObject

+(GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType;

+(GLuint)setupTexture:(UIImage *)sourceimg;

@end
