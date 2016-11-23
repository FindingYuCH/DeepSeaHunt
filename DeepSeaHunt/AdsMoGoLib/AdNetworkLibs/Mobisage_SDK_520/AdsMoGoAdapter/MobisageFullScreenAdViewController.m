//
//  MobisageFullScreenAdViewController.m
//  TestMOGOSDKAPP
//
//  Created by MOGO on 12-9-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MobisageFullScreenAdViewController.h"

@interface MobisageFullScreenAdViewController ()

@end

@implementation MobisageFullScreenAdViewController
@synthesize delegate;
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
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:closeButton];
    
    [closeButton setBackgroundImage:[UIImage imageNamed:@"adsmogo_adclose.png"] forState:UIControlStateNormal];
    [closeButton setFrame:CGRectMake(self.view.frame.size.width-50.0, 10.0, 40.0, 40.0)];
    
    
    [closeButton addTarget:self action:@selector(closeButtonFunction) forControlEvents:UIControlEventTouchUpInside];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)closeButtonFunction{
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if ([delegate respondsToSelector:
         @selector(fullScreenDismiss)]){
        [delegate fullScreenDismiss];
    }
}

@end
