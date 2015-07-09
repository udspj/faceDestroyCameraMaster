//
//  glViewController.m
//  gl
//
//  Created by admin on 12-10-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "glViewController.h"

@implementation glViewController

@synthesize exview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *btn = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 100, 30)];
    btn.text = @"sadfasdfsdaf";
    [self.view addSubview:btn];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];    
    exview = [[linesView alloc] initWithFrame:CGRectMake(100, 100, 160, 160)];
    //glview = [[exglview alloc] initWithFrame:screenBounds];
    [self.view addSubview:exview];
}
-(void)btnPressed:(id)sender{
    //[exview movemove];
}


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
