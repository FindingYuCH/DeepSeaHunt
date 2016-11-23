//
//  MobisageFullScreenAdViewController.h
//  TestMOGOSDKAPP
//
//  Created by MOGO on 12-9-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MobisageFullScreenAdViewControllerDelegate<NSObject>
- (void)fullScreenDismiss;
@end

@interface MobisageFullScreenAdViewController : UIViewController
@property(nonatomic,assign) id<MobisageFullScreenAdViewControllerDelegate> delegate;
@end


