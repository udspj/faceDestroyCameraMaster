//
//  ViewController.m
//  ultracamera
//
//  Created by sunpeijia on 14-2-2.
//  Copyright (c) 2014年 sunpeijia. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

@implementation ViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCamera];
    [self setupUI];
}

-(void)setupUI
{
    // 摄像头停止后截图
    cameracatchview = [[UIImageView alloc] initWithFrame:CGRectMake(0, -54, self.view.frame.size.width, 1280*self.view.frame.size.width/720)];
    [self.view addSubview:cameracatchview];
    
    // opengl view
    glwrappingview = [[linesView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-140)/2, 100+14, 140, 140)];
    [self.view addSubview:glwrappingview];
    
    // 拍照定位用蓝框
    UIImage *kuangimg = [UIImage imageNamed:@"kuang.png"];
    kuangview = [[UIImageView alloc] initWithImage:kuangimg];
    kuangview.frame = CGRectMake((self.view.frame.size.width-kuangview.frame.size.width/2)/2, 100, kuangview.frame.size.width/2, kuangview.frame.size.height/2);
    [self.view addSubview:kuangview];
    
    // 光线动画
    NSArray *animationFrames = [NSArray arrayWithObjects:
                                [UIImage imageNamed:@"anime1.png"],
                                [UIImage imageNamed:@"anime2.png"],
                                nil];
    //    animatedImageView = [[UIImageView alloc] init];
    //    animatedImageView.animationImages = animationFrames;
    //    [animatedImageView startAnimating];
    UIImage *animatedImage = [UIImage animatedImageWithImages:animationFrames duration:0.3f];
    animatedimgview = [[UIImageView alloc] initWithImage:animatedImage];
    animatedimgview.frame = CGRectMake(0, 50, animatedImage.size.width/2, animatedImage.size.height/2);
    [self.view addSubview:animatedimgview];
    animatedimgview.hidden = YES;
    
    // 手
    UIImage *handimg = [UIImage imageNamed:@"shou.png"];
    handview = [[UIImageView alloc] initWithImage:handimg];
    handview.frame = CGRectMake(0, self.view.frame.size.height-handimg.size.height/2, handview.frame.size.width/2, handview.frame.size.height/2);
    [self.view addSubview:handview];
    
    // 黑色底条
    UIImage *imgbottom = [UIImage imageNamed:@"black.png"];
    UIImageView *bottomview = [[UIImageView alloc] initWithImage:imgbottom];
    bottomview.frame = CGRectMake(0, self.view.frame.size.height-imgbottom.size.height/2, imgbottom.size.width/2, imgbottom.size.height/2);
    [self.view addSubview:bottomview];
    
    // 拍照button
    UIImage *imgpai = [UIImage imageNamed:@"paishe.png"];
    takephotobtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [takephotobtn setFrame:CGRectMake((self.view.frame.size.width - imgpai.size.width/2) / 2, bottomview.frame.origin.y + 4, imgpai.size.width/2, imgpai.size.height/2)];
    [takephotobtn setBackgroundImage:imgpai forState:UIControlStateNormal];
    [self.view addSubview:takephotobtn];
    [takephotobtn addTarget:self action:@selector(showStopImage) forControlEvents:UIControlEventTouchUpInside];
    
    // 保存button
    UIImage *imgsave = [UIImage imageNamed:@"baocun.png"];
    savephotobtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [savephotobtn setFrame:CGRectMake(60, bottomview.frame.origin.y + 4, imgsave.size.width/2, imgsave.size.height/2)];
    [savephotobtn setBackgroundImage:imgsave forState:UIControlStateNormal];
    [self.view addSubview:savephotobtn];
    [savephotobtn addTarget:self action:@selector(savePhotoInAlbum) forControlEvents:UIControlEventTouchUpInside];
    savephotobtn.hidden = YES;
    
    // 发微博button
    UIImage *imgweibo = [UIImage imageNamed:@"zhuanfa.png"];
    sendweibobtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendweibobtn setFrame:CGRectMake(self.view.frame.size.width - 50 - imgweibo.size.width/2, bottomview.frame.origin.y + 4, imgweibo.size.width/2, imgweibo.size.height/2)];
    [sendweibobtn setBackgroundImage:imgweibo forState:UIControlStateNormal];
    [self.view addSubview:sendweibobtn];
    [sendweibobtn addTarget:self action:@selector(gotoSendWeibo) forControlEvents:UIControlEventTouchUpInside];
    sendweibobtn.hidden = YES;
    
    // “捕获”链条图片
    UIImage *getimg = [UIImage imageNamed:@"buhuochenggong.png"];
    getimgview = [[UIImageView alloc] initWithImage:getimg];
    getimgview.frame = CGRectMake(0, self.view.frame.size.height - 160, self.view.frame.size.width, getimg.size.height/2);
    [self.view addSubview:getimgview];
    getimgview.hidden = YES;
}

-(void)setupCamera
{
    // 初始化摄像头和输入
    session = [[AVCaptureSession alloc] init];
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (input) {
        [session addInput:input];
    }
    
    // 设置摄像头输出
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
	//captureOutput.alwaysDiscardsLateVideoFrames = YES;
	dispatch_queue_t queue = dispatch_queue_create("cameraQueue", NULL);
	[captureOutput setSampleBufferDelegate:self queue:queue];
	//dispatch_release(queue);
	// Set the video output to store frame in BGRA (It is supposed to be faster)
	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
	[captureOutput setVideoSettings:videoSettings];
    [session addOutput:captureOutput];
    
    // 摄像view层
    videoLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:session];
    videoLayer.frame = CGRectMake(0, -54, self.view.frame.size.width, self.view.frame.size.height);
    videoLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:videoLayer];
    
    [session startRunning];
}

#pragma 按下拍摄，停止图像，截图，变形，同时播放光线

-(void)showStopImage
{
    [session stopRunning];
    [videoLayer removeFromSuperlayer];
    
    cameracatchview.image = catchimg;
    
    NSLog(@"%f  %f",catchimg.size.width,catchimg.size.height);// 1280.000000  720.000000
    CGFloat glscalefix = 256.0/140.0;
    
    // 缩放调整原始图像
    catchimg = [self scaleAndRotateImage:catchimg];
    
    // 抓取调整后图像中要变形的部分
    CGFloat posx = (self.view.frame.size.width-140)/2*glscalefix;
    posx = (CGFloat)(int)posx;
    CGFloat posy = 100+12+(1138-960)/2*glscalefix+34;
    posy = (CGFloat)(int)posy;
    NSLog(@"pos %f  %f",posx,posy);
    
    CGImageRef corp = CGImageCreateWithImageInRect(catchimg.CGImage, CGRectMake(posx, posy, 256, 256));
    UIImage *imgicon = [UIImage imageWithCGImage:corp];
    
    // 图像变形
    [glwrappingview runWarpingImage:[self mirrorYImage:imgicon]];
    
    // 隐藏拍照按钮
    takephotobtn.hidden = YES;
    
    // 播放光线动画，并计时播放2秒
    animatedimgview.hidden = NO;
    timesecond = 2;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showSaveAndWeibo) userInfo:nil repeats:YES];
}

#pragma 光线播放完，显示“保存”和“发微博”按钮、“捕获外星人”
-(void)showSaveAndWeibo
{
    timesecond--;
    if (timesecond == 0)
    {
        animatedimgview.hidden = YES;
        handview.hidden = YES;
        kuangview.hidden = YES;
        savephotobtn.hidden = NO;
        sendweibobtn.hidden = NO;
        getimgview.hidden = NO;
    }
}

#pragma mark - camera delegate

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imgbuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imgbuffer, 0);
    uint8_t *baseaddress = (uint8_t *)CVPixelBufferGetBaseAddress(imgbuffer);
    
    CGContextRef context = CGBitmapContextCreate(baseaddress,
                                                 CVPixelBufferGetWidth(imgbuffer),
                                                 CVPixelBufferGetHeight(imgbuffer),
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(imgbuffer),
                                                 CGColorSpaceCreateDeviceRGB(),
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef imgref = CGBitmapContextCreateImage(context);
    catchimg = [UIImage imageWithCGImage:imgref scale:1.0 orientation:UIImageOrientationRight];
    
    CGContextRelease(context);
    CGImageRelease(imgref);
    
    CVPixelBufferUnlockBaseAddress(imgbuffer, 0);
}

-(void)savePhotoInAlbum
{
    CGSize size= CGSizeMake(self.view.frame.size.width,self.view.frame.size.height);
    UIGraphicsBeginImageContext(size);
    
    // Draw 原始底图
    [cameracatchview.image drawInRect:CGRectMake(0, -54, self.view.frame.size.width, 1280*self.view.frame.size.width/720)];
    // Draw “捕获外星人”
    [getimgview.image drawInRect:CGRectMake(0, self.view.frame.size.height - 160, self.view.frame.size.width, getimgview.frame.size.height)];
    // Draw opengl变形部分
    [glwrappingview.glimage drawInRect:CGRectMake((self.view.frame.size.width-140)/2, 100+14, 140, 140)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(resultingImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error
contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                       message:@"保存照片失败，请重试"
                                                      delegate:nil
                                             cancelButtonTitle:@"ok"
                                             otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                       message:@"照片已保存到相册"
                                                      delegate:nil
                                             cancelButtonTitle:@"ok"
                                             otherButtonTitles:nil];
        [alert show];
    }
}

-(void)savePhotoComplete:(UIImage *)image{
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@""
                                                  message:@"照片已保存到相册"
                                                 delegate:nil
                                        cancelButtonTitle:@"ok"
                                        otherButtonTitles:nil];
    [alert show];
}

-(void)gotoSendWeibo
{
    
}

-(UIImage *)scaleAndRotateImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //镜像翻转回来，图像是right方向
    CGContextRotateCTM(context, M_PI); //先旋转180度，是按照原先顺时针方向旋转的。这个时候会发现位置偏移了
    CGContextScaleCTM(context, -1, 1); //再水平旋转一下
    CGContextTranslateCTM(context,0, -image.size.height);//再把偏移掉的位置调整回来
    //把right方向的图改成正确的竖向
    CGContextTranslateCTM(context,0, image.size.height-self.view.frame.size.height);
    CGContextRotateCTM(context, -M_PI/2);
    CGContextTranslateCTM(context,-self.view.frame.size.height, 0);
    //把宽1280高720的图缩放成640*1138，但由于opengl规定尺寸256
    CGFloat glscalefix = 256.0/140.0;
    NSLog(@"glscalefix  %f %f",glscalefix, 1138/2/image.size.width*glscalefix);
    CGContextScaleCTM(context, 1138/2/image.size.width*glscalefix, self.view.frame.size.width/image.size.height*glscalefix);
    
    CGContextDrawImage(context,CGRectMake(0, 0, image.size.width, image.size.height) , [image CGImage]);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

-(UIImage *)mirrorYImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextRotateCTM(context, 0);
    
    CGContextDrawImage(context,CGRectMake(0, 0, image.size.width, image.size.height) , [image CGImage]);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}


#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
