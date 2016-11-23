//
//  AdMoGoAdapterMobiSageFullAd.m
//  TestMOGOSDKAPP
//
//  Created by MOGO on 12-8-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AdMoGoAdapterMobiSageFullAd.h"
#import "AdMoGoAdapterMobiSage.h"
#import "AdMoGoAdNetworkRegistry.h"
#import "AdMoGoAdNetworkConfig.h"
#import "AdMoGoAdNetworkAdapter+Helpers.h"
#import "AdMoGoConfigDataCenter.h"
#import "AdMoGoConfigData.h"
#import "AdMoGoDeviceInfoHelper.h"

@implementation AdMoGoAdapterMobiSageFullAd

+ (NSDictionary *)networkType {
	return [self makeNetWorkType:AdMoGoAdNetworkTypeMobiSage IsSDK:YES isApi:NO isBanner:NO isFullScreen:YES];
}

+ (void)load {
	[[AdMoGoAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {
    
    isStop = NO;
    isError = NO;
    [adMoGoCore adDidStartRequestAd];
    AdMoGoConfigDataCenter *configDataCenter = [AdMoGoConfigDataCenter singleton];
    
    AdMoGoConfigData *configData = [configDataCenter.config_dict objectForKey:adMoGoCore.config_key];
    
	[adMoGoCore adapter:self didGetAd:@"mobisage"];
    
    AdViewType type =[configData.ad_type intValue];
    
    CGSize size =CGSizeMake(0, 0);
    NSUInteger adIndex = 0;
    switch (type) {
        case AdViewTypeFullScreen:
            adIndex = Poster_320X460;
            size = CGSizeMake(320.0, 460.0);
            break;
        case AdViewTypeiPadFullScreen:
            adIndex = Poster_768X768;
            size = CGSizeMake(768.0, 768.0);
            break;
        default:
            [adMoGoCore adapter:self didFailAd:nil];
            break;
    }
    
    timer = [[NSTimer scheduledTimerWithTimeInterval:AdapterTimeOut30 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];
   
    MobiSageAdPoster *adView = [[MobiSageAdPoster alloc] initWithAdSize:adIndex PublisherID:[self.ration objectForKey:@"key"] withDelegate:self];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [view addSubview:adView];
    self.adNetworkView = view;
    [view release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adStartShow:) 
                                                 name:MobiSageAdView_Start_Show_AD 
                                               object:adView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adPauseShow:) 
                                                 name:MobiSageAdView_Pause_Show_AD
                                               object:adView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adPop:) 
                                                 name:MobiSageAdView_Pop_AD_Window
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adHide:)
                                                 name:MobiSageAdView_Hide_AD_Window
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adClick:)
                                                 name:MobiSageAdView_Click_AD
                                               object:nil];
    

    
    [adView startRequestAD];
    [adView release];
}

- (void)stopBeingDelegate {
    MobiSageAdPoster *_adView = (MobiSageAdPoster *)[[self.adNetworkView subviews] objectAtIndex:0];
	if (_adView != nil) {
        [_adView setDelegate:nil];
        [_adView removeFromSuperview];
        self.adNetworkView = nil;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)stopAd{
    [self stopBeingDelegate];
    isStop = YES;
    [self stopTimer];
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
}

- (void)dealloc {
    isStop = YES;
    
	[super dealloc];
}

- (UIViewController *)viewControllerToPresent{
    return [adMoGoDelegate viewControllerForPresentingModalView];
}

- (void)adStartShow:(NSNotification *)notification {
    
    if (isStop || isError) {
        return;
    }
    
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
    [adMoGoCore adapter:self didReceiveAdView:self.adNetworkView];
    MobisageFullScreenAdViewController *mobisageviewController = [[MobisageFullScreenAdViewController alloc] init];
    mobisageviewController.delegate = self;
    [mobisageviewController.view addSubview:self.adNetworkView];
    UIViewController *rootviewController = [adMoGoDelegate viewControllerForPresentingModalView];
    [rootviewController presentModalViewController:mobisageviewController  animated:YES];
}



- (void)adPauseShow:(NSNotification *)notification {
    
}

- (void)adPop:(NSNotification *)notification {
    if (isStop) {
        return;
    }
    [adMoGoCore stopTimer];
    [self helperNotifyDelegateOfFullScreenModal];
}

- (void)adHide:(NSNotification *)notification {
    if (isStop) {
        return;
    }
    [adMoGoCore fireTimer];
    [self helperNotifyDelegateOfFullScreenModalDismissal];
}

- (void)adClick:(NSNotification *)notification {
    if (isStop) {
        return;
    }
    [adMoGoCore specialSendRecordNum];
}



- (void)loadAdTimeOut:(NSTimer*)theTimer {
    
    if (isStop) {
        return;
    }
    
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
    [adMoGoCore adapter:self didFailAd:nil];
}

- (void)fullScreenDismiss{
    [self helperNotifyDelegateOfFullScreenAdModalDismissal];
}
@end
