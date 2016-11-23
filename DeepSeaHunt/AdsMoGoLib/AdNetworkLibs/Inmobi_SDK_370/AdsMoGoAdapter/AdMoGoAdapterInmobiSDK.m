//
//  AdMoGoAdapterInmobiSDK.m
//  TestMOGOSDKAPP
//
//  Created by MOGO on 12-9-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AdMoGoAdapterInmobiSDK.h"
#import "AdMoGoAdNetworkRegistry.h"
#import "AdMoGoView.h"
#import "AdMoGoAdNetworkConfig.h" 
#import "AdMoGoAdNetworkAdapter+Helpers.h"
#import "AdMoGoConfigDataCenter.h"
#import "AdMoGoConfigData.h"
#import "AdMoGoDeviceInfoHelper.h"


@implementation AdMoGoAdapterInmobiSDK

+ (NSDictionary *)networkType {
	return [self makeNetWorkType:AdMoGoAdNetworkTypeInMobi IsSDK:YES isApi:NO isBanner:YES isFullScreen:NO];
}

+ (void)load {
	[[AdMoGoAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {
    isStop = false;
    [adMoGoCore adDidStartRequestAd];
    [adMoGoCore adapter:self didGetAd:@"inmobisdk"];
    /*
     获取广告类型
     原来代码：AdViewType type = adMoGoView.adType;
     */
    AdMoGoConfigDataCenter *configDataCenter = [AdMoGoConfigDataCenter singleton];
    AdMoGoConfigData *configData = [configDataCenter.config_dict objectForKey:adMoGoCore.config_key];
    AdViewType type = [configData.ad_type intValue];
    rect = CGRectZero;
    int sizetype;
    switch (type) {
        case AdViewTypeiPadNormalBanner: 
        case AdViewTypeNormalBanner:
            adView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 48)];
            sizetype = IM_UNIT_320x48;
            rect = CGRectMake(0, 0, 320, 48);
            break;
        case AdViewTypeRectangle:
            adView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
            sizetype = IM_UNIT_300x250;
            rect = CGRectMake(0, 0, 300, 250);
            break;
        case AdViewTypeMediumBanner:
            adView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 468, 60)];
            sizetype = IM_UNIT_468x60;
            rect = CGRectMake(0, 0, 468, 60);
            break;
        case AdViewTypeLargeBanner:
            adView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 728, 90)];
            sizetype = IM_UNIT_728x90;
            rect = CGRectMake(0, 0, 728, 90);
            break;
        default:
            [adMoGoCore adapter:self didFailAd:nil];
            return;
            break;
    }
    self.adNetworkView = adView;
    /*2013*/
    [adView release];
    
    timer = [[NSTimer scheduledTimerWithTimeInterval:AdapterTimeOut15 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];

    inmobiAdView = [[IMAdView alloc] initWithFrame:rect imAppId:[self.ration objectForKey:@"key"] imAdSize:sizetype rootViewController:[adMoGoDelegate viewControllerForPresentingModalView]];
    
    inmobiAdView.refreshInterval = REFRESH_INTERVAL_OFF;
    inmobiAdView.delegate = self;
    request = [IMAdRequest request];

    [inmobiAdView loadIMAdRequest:request];

     /*2013*/
    [self.adNetworkView addSubview:inmobiAdView];
    
    /*2013*/
    [inmobiAdView release];
}


- (void)stopAd{
    [self stopBeingDelegate];
    isStop = YES;
    [self stopTimer];
}

- (void)stopBeingDelegate {
    /*2013*/
    UIView *_View = self.adNetworkView;
    if (_View) {
        IMAdView *_inmobiView = (IMAdView *)[[_View subviews] lastObject];
        if (_inmobiView) {
            _inmobiView.delegate = nil;
            [_inmobiView removeFromSuperview];
            _inmobiView = nil;
        }
    }
}

- (void)dealloc{
    [super dealloc];
}

#pragma mark InMobiAdDelegate methods

- (void)adViewDidFinishRequest:(IMAdView *)view {
    if (isStop) {
        return;
    }
    [self stopTimer];
    [adMoGoCore adapter:self didReceiveAdView:self.adNetworkView];
}

- (void)adView:(IMAdView *)view didFailRequestWithError:(IMAdError *)error {
    if (isStop) {
        return;
    }
    NSLog(@"inMobi error-->%@",error);
    [self stopTimer];
    [adMoGoCore adapter:self didFailAd:error];
    view.delegate = nil;
}

- (void)adViewDidDismissScreen:(IMAdView *)adView {
    NSLog(@"adViewDidDismissScreen");
    [adMoGoCore fireTimer];
}

- (void)adViewWillDismissScreen:(IMAdView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

- (void)adViewWillPresentScreen:(IMAdView *)adView {
    NSLog(@"adViewWillPresentScreen");
    [adMoGoCore stopTimer];
    
}

- (void)adViewWillLeaveApplication:(IMAdView *)adView {
    NSLog(@"adViewWillLeaveApplication");
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
}

- (void)loadAdTimeOut:(NSTimer*)theTimer {
    
    if (isStop) {
        return;
    }
    [self stopTimer];
    /*2013*/
    if (inmobiAdView) {
        inmobiAdView.delegate = nil;
    }
    [adMoGoCore adapter:self didFailAd:nil];
}
@end
