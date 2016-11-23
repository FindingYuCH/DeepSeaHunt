//
//  Mogo_ad.h
//  richGame
//
//  Created by akn on 12-11-13.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AdMoGoDelegateProtocol.h"
#import "AdMoGoView.h"
#import "AdMoGoWebBrowserControllerUserDelegate.h"
@interface Mogo_ad : NSObject<AdMoGoDelegate,AdMoGoWebBrowserControllerUserDelegate>{
    AdMoGoView *adView;
    UIViewController *_viewController;
    float ox;
    float wx;
    float oy;
    float wy;
    
}
@property (nonatomic, retain) AdMoGoView *adView;
@property (nonatomic, copy)UIViewController *viewController;

-(void)hideAd;
-(void)showAd;
-(void)hideAd_0;
-(void)showAd_0;
@end
