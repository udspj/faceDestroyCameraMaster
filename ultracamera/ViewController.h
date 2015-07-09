//
//  ViewController.h
//  ultracamera
//
//  Created by sunpeijia on 14-2-2.
//  Copyright (c) 2014年 sunpeijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "linesView.h"

@interface ViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    //摄像头
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *videoLayer;
    AVCaptureDeviceInput *input;
    //AVCaptureStillImageOutput *output;
    AVCaptureDevice *device;
    
    UIImage *catchimg;//摄像头抓取的原始图像
    
    linesView *glwrappingview;//gl变形图像view
    
    UIImageView *kuangview;//蓝框
    UIImageView *handview;//手
    UIButton *takephotobtn;//拍照button
    UIButton *savephotobtn;//保存照片button
    UIButton *sendweibobtn;//发微博button
    UIImageView *getimgview;//捕获图像
    
    UIImageView *cameracatchview;//摄像头拍照后截屏
    
    UIImageView *animatedimgview;//光线动画
    //动画计时
    NSTimer *timer;
    int timesecond;
}


@end