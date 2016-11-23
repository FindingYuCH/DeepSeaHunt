//  File: AdMoGoAdapterMobiSage.m
//  Project: AdsMOGO iOS SDK
//  Version: 1.1.9
//  Copyright 2011 AdsMogo.com. All rights reserved.


#import "AdMoGoAdapterMobiSage.h"
//#import "AdMoGoView.h"
#import "AdMoGoAdNetworkRegistry.h"
#import "AdMoGoAdNetworkConfig.h"
#import "AdMoGoAdNetworkAdapter+Helpers.h"
#import "AdMoGoConfigDataCenter.h"
#import "AdMoGoConfigData.h"
#import "AdMoGoDeviceInfoHelper.h"

@implementation AdMoGoAdapterMobiSage
+ (NSDictionary *)networkType {
    return [self makeNetWorkType:AdMoGoAdNetworkTypeMobiSage IsSDK:YES isApi:NO isBanner:YES isFullScreen:NO];
}

+ (void)load {
	[[AdMoGoAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {
    
    isStop = NO;
   
    [adMoGoCore adDidStartRequestAd];
    AdMoGoConfigDataCenter *configDataCenter = [AdMoGoConfigDataCenter singleton];
    
    AdMoGoConfigData *configData = [configDataCenter.config_dict objectForKey:adMoGoCore.config_key];
    
	[adMoGoCore adapter:self didGetAd:@"mobisage"];

//    AdViewType type = adMoGoView.adType;
    AdViewType type =[configData.ad_type intValue];
    
    CGSize size =CGSizeMake(0, 0);
    NSUInteger adIndex = 0;
    switch (type) {
        case AdViewTypeNormalBanner:
        case AdViewTypeiPadNormalBanner:
            adIndex = Ad_320X50;
            size = CGSizeMake(320, 50);
            break;
        case AdViewTypeRectangle:
            adIndex = Ad_300X250;
            size = CGSizeMake(300, 250);
            break;
        case AdViewTypeMediumBanner:
            adIndex = Ad_468X60;
            size = CGSizeMake(468, 60);
            break;
        case AdViewTypeLargeBanner:
            adIndex = Ad_728X90;
            size = CGSizeMake(728, 90);
            break;
        default:
            break;
    }
    
    timer = [[NSTimer scheduledTimerWithTimeInterval:AdapterTimeOut12 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];
    
    
//    adView = [[MobiSageAdBanner alloc] initWithAdSize:adIndex PublisherID:[self.ration objectForKey:@"key"]];
    adView = [[MobiSageAdBanner alloc] initWithAdSize:adIndex  PublisherID:[self.ration objectForKey:@"key"] withDelegate:self];
    [adView setInterval:Ad_NO_Refresh];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [view addSubview:adView];
    self.adNetworkView = view;
    [view release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    
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
                                             selector:@selector(adError:)
                                                 name:MobiSageAction_Error
                                               object:nil];
    


    [adView release];
}

- (void)stopBeingDelegate {
    MobiSageAdBanner *_adView = (MobiSageAdBanner *)[[self.adNetworkView subviews] lastObject];
	if (_adView != nil) {
        _adView.delegate = nil;
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
 //  return [adMoGoDelegate viewControllerForPresentingModalView];
 //  return [[[UIApplication sharedApplication] delegate] ;
    return  [adMoGoDelegate viewControllerForPresentingModalView];
    
     
}

- (void)adStartShow:(NSNotification *)notification {
    
    if (isStop) {
        return;
    }
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
    [adMoGoCore adapter:self didReceiveAdView:self.adNetworkView];
}

- (void)adPauseShow:(NSNotification *)notification {
    
}

- (void)adError:(NSNotification *)notification{
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
@end
