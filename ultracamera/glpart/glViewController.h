//
//  glViewController.h
//  gl
//
//  Created by admin on 12-10-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "linesView.h"
//#import "exglview.h"

@interface glViewController : UIViewController{
    linesView *exview;
    //exglview *glview;
}

@property(nonatomic,retain)linesView *exview;

@end
