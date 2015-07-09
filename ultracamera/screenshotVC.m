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

-(void)setupUI{
    bottomimgview = [[UIImageView alloc] init];
    [self.view addSubview:bottomimgview];
    
//    UIImage *kuangimg = [UIImage imageNamed:@"kuang.png"];
//    UIImageView *kuangview = [[UIImageView alloc] initWithImage:kuangimg];
//    kuangview.frame = CGRectMake((self.view.frame.size.width-kuangview.frame.size.width/2)/2, 100, kuangview.frame.size.width/2, kuangview.frame.size.height/2);
//    [self.view addSubview:kuangview];
//    
//    UIImage *handimg = [UIImage imageNamed:@"shou.png"];
//    UIImageView *handview = [[UIImageView alloc] initWithImage:handimg];
//    handview.frame = CGRectMake(0, self.view.frame.size.height-handimg.size.height/2, handview.frame.size.width/2, handview.frame.size.height/2);
//    [self.view addSubview:handview];
    
    takephotobtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [takephotobtn setFrame:CGRectMake(50, 420, 100, 50)];
    [takephotobtn setTitle:@"catch" forState:UIControlStateNormal];
    [self.view addSubview:takephotobtn];
    [takephotobtn addTarget:self action:@selector(showStopImage) forControlEvents:UIControlEventTouchUpInside];
}
-(void)setupCamera{
    session = [[AVCaptureSession alloc] init];
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (input) {
        [session addInput:input];
    }
    
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
    
    videoLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:session];
    videoLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    videoLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:videoLayer];
    
    [session startRunning];
}

-(void)showStopImage{
    [session stopRunning];
    [videoLayer removeFromSuperlayer];
    
    NSLog(@"%f  %f",catchimg.size.width,catchimg.size.height);// 1280.000000  720.000000
    
//    UIGraphicsBeginImageContext(catchimg.size);
//    [catchimg drawInRect:CGRectMake(0, 0, catchimg.size.width, catchimg.size.height)];
//    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    UIImageWriteToSavedPhotosAlbum(resultingImage, Nil, Nil, Nil);

    UIImage *testimg = [UIImage imageWithCGImage:catchimg.CGImage];
    bottomimgview.frame = CGRectMake(0, 0, testimg.size.width, testimg.size.height);
    testimg = [self scaleAndRotateImage:testimg];
    bottomimgview.image = [UIImage imageWithCGImage:testimg.CGImage];
    
//    CGImageRef corp = CGImageCreateWithImageInRect(testimg.CGImage, CGRectMake(0, 0, 160, 160));
//    UIImage *imgicon = [UIImage imageWithCGImage:corp];
//    UIImageView *imgiconview = [[UIImageView alloc] initWithFrame:CGRectMake(100, 300, 160, 160)];
//    imgiconview.image = imgicon;
//    [self.view addSubview:imgiconview];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
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

-(void)savePhotoInAlbum{
    
//    UIGraphicsBeginImageContext(catchimg.size);
//    [catchimg drawInRect:CGRectMake(0, 0, catchimg.size.width, catchimg.size.height)];
//    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    UIImageWriteToSavedPhotosAlbum(resultingImage, Nil, Nil, Nil);
}

-(void)gotoSendWeibo{
    
}

-(UIImage *)scaleAndRotateImage:(UIImage *)image{
    int width = image.size.width;
    int height = image.size.height;
    CGSize size = CGSizeMake(width, height);
    
    CGRect imageRect;
    
        imageRect = CGRectMake(0, 0, height, width);
    
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
//    CGContextTranslateCTM(context, 0, height);
//    CGContextScaleCTM(context, 0.5, -1.0);
//
//
//        CGContextRotateCTM(context, - M_PI / 2);
//        CGContextTranslateCTM(context, -height, -width+self.view.frame.size.width);

    
    CGContextDrawImage(context, imageRect, image.CGImage);
    CGContextRestoreGState(context);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return (img);
}





- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
