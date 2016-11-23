//
//  Mogo_ad.m
//  richGame
//
//  Created by akn on 12-11-13.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "Mogo_ad.h"
#import "UGameScene.h"



@interface Mogo_ad ()

@end

@implementation Mogo_ad
@synthesize adView;
@synthesize viewController=_viewController;
-(Mogo_ad *)init
{
	if( (self=[super init])) {
        _viewController = [[UIViewController alloc]init];
        _viewController.view.frame = [[CCDirector sharedDirector] view].frame;
        
        //    typedef enum {
        //        AdViewTypeUnknown = 0,          //error
        //        AdViewTypeNormalBanner = 1,     //e.g. 320 * 50 ; 320 * 48  iphone banner
        //        AdViewTypeLargeBanner = 2,      //e.g. 728 * 90 ; 768 * 110 ipad only
        //        AdViewTypeMediumBanner = 3,     //e.g. 468 * 60 ; 508 * 80  ipad only
        //        AdViewTypeRectangle = 4,        //e.g. 300 * 250; 320 * 270 ipad only
        //        AdViewTypeSky = 5,              //Don't support
        //        AdViewTypeFullScreen = 6,       //iphone full screen ad
        //        AdViewTypeVideo = 7,            //Don't support
        //        AdViewTypeiPadNormalBanner = 8, //ipad use iphone banner
        //    } AdViewType;
        CGRect isAd;
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            adView = [[AdMoGoView alloc] initWithAppKey:@"0591286c6b7c45d5bd5c99e204cef3dd"
                                                 adType:AdViewTypeMediumBanner
                                            expressMode:NO
                                     adMoGoViewDelegate:self];
            isAd = CGRectMake(350, 30, 580, 100);
            ox = 0.0;
            wx = 1024;
            oy = 35.0;
            wy = -768.0;
          
        }
        else
        {
            adView = [[AdMoGoView alloc] initWithAppKey:@"70de136a92584ddb97bc9a5bfa1c8c90"
                                                 adType:AdViewTypeNormalBanner
                                            expressMode:NO
                                     adMoGoViewDelegate:self];
            isAd = CGRectMake(50, 3, 320, 50);
            ox = 26.0;
            wx = 480;
            oy = 3.0;
            wy = -320.0;
        }
        
        adView.adWebBrowswerDelegate = self;
        adView.frame = isAd;
//        adView.frame=CGRectZero;
        [_viewController.view addSubview:adView];
        [adView release];

	}
	return self;
}

-(void)hideAd_0
{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	CGRect frame = _viewController.view.frame;
	frame.origin.x = -wx;
	_viewController.view.frame = frame;
	[UIView commitAnimations];
}
-(void)showAd_0
{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	CGRect frame = _viewController.view.frame;
	frame.origin.x = 0.0;
	_viewController.view.frame = frame;
	[UIView commitAnimations];
}

-(void)hideAd
{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	CGRect frame = _viewController.view.frame;
	frame.origin.y = wy;
	_viewController.view.frame = frame;
	[UIView commitAnimations];
}
-(void)showAd
{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	CGRect frame = _viewController.view.frame;
	frame.origin.y = 0.0;
	_viewController.view.frame = frame;
	[UIView commitAnimations];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//  Return YES for supported orientations
//  return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationLandscapeLeft;
}

- (BOOL)shouldAutorotate{
    return NO;
}

/*
 返回广告rootViewController
 */
- (UIViewController *)viewControllerForPresentingModalView{
    return [CCDirector sharedDirector];
}

/**
 * 广告开始请求回调
 */
- (void)adMoGoDidStartAd:(AdMoGoView *)adMoGoView{
   // NSLog(@"广告开始请求回调");
}
/**
 * 广告接收成功回调
 */
- (void)adMoGoDidReceiveAd:(AdMoGoView *)adMoGoView{
//    NSLog(@"广告接收成功回调");
    if (!isPad) {
        if ([UGameScene sharedScene].adState!=kADStateForRun) {
            [UGameScene sharedScene].adState=kADStateForRun;
            
            if ([UGameScene sharedScene].gameState==kGameStateForGameing) {
                [[UGameScene sharedScene] scheduleOnce:@selector(ADControl) delay:kTimeWarttingAD];
            }
        }
    }
}
/**
 * 广告接收失败回调
 */
- (void)adMoGoDidFailToReceiveAd:(AdMoGoView *)adMoGoView didFailWithError:(NSError *)error{
//   NSLog(@"广告接收失败回调");
    if (!isPad) {
        [UGameScene sharedScene].adState=kADStateForNotGet;
        [self hideAd];
        [[UGameScene sharedScene] showHeadAndLevel];
    }
}
/**
 * 点击广告回调
 */
- (void)adMoGoClickAd:(AdMoGoView *)adMoGoView{
    //NSLog(@"点击广告回调");
}
/**
 *You can get notified when the user delete the ad
 广告关闭回调
 */
- (void)adMoGoDeleteAd:(AdMoGoView *)adMoGoView{
//    NSLog(@"广告关闭回调");
////  [UGameScene shardScene].adState=kADStateForBeClose;
//    [[UGameScene shardScene] showHeadAndLevel];
//    [[UGameScene shardScene] gameCloseADAlert];
//    [[UGameScene shardScene] scheduleOnce:@selector(ADControl) delay:kTimeWarttingAD];
}

#pragma mark -
#pragma mark AdMoGoWebBrowserControllerUserDelegate delegate

/*
 浏览器将要展示
 */
- (void)webBrowserWillAppear{
   // NSLog(@"浏览器将要展示");
}

/*
 浏览器已经展示
 */
- (void)webBrowserDidAppear{
   // NSLog(@"浏览器已经展示");
}

/*
 浏览器将要关闭
 */
- (void)webBrowserWillClosed{
   // NSLog(@"浏览器将要关闭");
}

/*
 浏览器已经关闭
 */
- (void)webBrowserDidClosed{
   // NSLog(@"浏览器已经关闭");
}
- (void)webBrowserShare:(NSString *)url
{
    //NSLog(@"浏览器分享url浏览器打开url");
    
}
- (void)dealloc
{
    adView.delegate = nil;
    adView.adWebBrowswerDelegate = nil;
    
    [super dealloc];
}
@end
