//
//  ViewController.h
//  ultracamera
//
//  Created by sunpeijia on 14-2-2.
//  Copyright (c) 2014年 sunpeijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>{
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *videoLayer;
    AVCaptureDeviceInput *input;
    //AVCaptureStillImageOutput *output;
    AVCaptureDevice *device;
    UIImage *catchimg;
    UIImageView *bottomimgview;
    
    UIButton *takephotobtn;
}


@end