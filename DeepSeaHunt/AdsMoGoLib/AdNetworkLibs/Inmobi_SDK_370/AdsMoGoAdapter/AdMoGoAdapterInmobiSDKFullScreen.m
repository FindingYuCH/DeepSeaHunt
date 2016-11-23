//
//  AdMoGoAdapterInmobiSDKFullScreen.m
//  TestMOGOSDKAPP
//
//  Created by Daxiong on 12-11-21.
//
//

#import "AdMoGoAdapterInmobiSDKFullScreen.h"
#import "AdMoGoAdNetworkRegistry.h"
#import "AdMoGoConfigDataCenter.h"

@implementation AdMoGoAdapterInmobiSDKFullScreen

+ (NSDictionary *)networkType {
	return [self makeNetWorkType:AdMoGoAdNetworkTypeInMobi IsSDK:YES isApi:NO isBanner:NO isFullScreen:YES];
}

+ (void)load {
	[[AdMoGoAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {
    isStop = NO;
    [adMoGoCore adDidStartRequestAd];
    /*
     获取广告类型
     */
    AdMoGoConfigDataCenter *configDataCenter = [AdMoGoConfigDataCenter singleton];
    
    AdMoGoConfigData *configData = [configDataCenter.config_dict objectForKey:adMoGoCore.config_key];
    
    AdViewType type =[configData.ad_type intValue];

	if (type == AdViewTypeFullScreen||
        type == AdViewTypeiPadFullScreen) {
        interstitialAd = [[IMAdInterstitial alloc] init];
        interstitialAd.delegate = self;
        interstitialAd.imAppId = [self.ration objectForKey:@"key"];
        IMAdRequest *request = [IMAdRequest request];
        [interstitialAd loadRequest:request];
        timer = [[NSTimer scheduledTimerWithTimeInterval:AdapterTimeOut60 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];
    }else{
        [adMoGoCore adapter:self didFailAd:nil];
    }
}

-(void)stopAd{
    [self stopBeingDelegate];
    isStop = YES;
}

-(void)stopBeingDelegate{
    
    if(interstitialAd){
        interstitialAd.delegate = nil;
        [interstitialAd release],interstitialAd = nil;
    }
}

-(void)dealloc{
    
    if(interstitialAd){
        interstitialAd.delegate = nil;
        [interstitialAd release],interstitialAd = nil;
    }
    
    [super dealloc];
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
}

/*2013*/
- (void)loadAdTimeOut:(NSTimer*)theTimer {
    if (isStop) {
        return;
    }
    [self stopTimer];
    [self stopBeingDelegate];
    [adMoGoCore adapter:self didFailAd:nil];
}
#pragma mark -
#pragma mark Inmobi delegate
/**
 * Callback sent when the interstitial is successfully loaded and is ready to
 * be displayed. You may want to show it at the next transition point in your
 * application such as when transitioning between view controllers.
 *
 * @param ad The IMAdInterstitial instance that successfully loaded an ad.
 */
- (void)interstitialDidFinishRequest:(IMAdInterstitial *)ad{
    
    if(isStop){
        return;
    }
    [self stopTimer];
    UIViewController *viewController = [self.adMoGoDelegate viewControllerForPresentingModalView];
    if(!viewController){
        [self stopBeingDelegate];
        [adMoGoCore adapter:self didFailAd:nil];
        return;
    }else{
        [adMoGoCore adapter:self didReceiveAdView:nil];
    }
    [interstitialAd presentFromRootViewController:viewController animated:YES];
}

/**
 * Callback sent when an interstitial ad request completed without an
 * interstitial to show. This is common as interstitials are shown sparingly
 * to users.
 *
 * @param ad The IMAdInterstitial instance that failed to load an ad.
 * @param error The error that occurred during loading.
 */
- (void)interstitial:(IMAdInterstitial *)ad
didFailToReceiveAdWithError:(IMAdError *)error{
    
    if(isStop){
        return;
    }
    [self stopTimer];
    [self stopBeingDelegate];
    [adMoGoCore adapter:self didFailAd:error];

}

/**
 * Callback Sent when an interstitial ad fails to present a full screen to the
 * user. This will generally occur if an interstitial is not in the
 * kIMAdInterstitialStateReady state. See IMAdInterstitial.h for list of states.
 *
 * @note An interstitial ad can be shown only once. After dismissal, you must
 *         call loadRequest: again and wait for this ad request to succeed.
 * @param ad The IMAdInterstitial instance that failed to present the
 *           interstitial screen.
 * @param error The error that occurred during loading.
 */
- (void)interstitial:(IMAdInterstitial *)ad
didFailToPresentScreenWithError:(IMAdError *)error{
    
    if(isStop){
        return;
    }
    [self stopTimer];
    [self stopBeingDelegate];
    [adMoGoCore adapter:self didFailAd:error];
}

/**
 * Callback sent just before presenting an interstitial. After this method
 * finishes, the interstitial will animate on to the screen. Use this
 * opportunity to stop animations and save the state of your application in
 * case the user leaves while the interstitial is on screen (e.g. to visit the
 * App Store from a link on the interstitial).
 *
 * @param ad The IMAdInterstitial instance that will present an interstitial
 *           to the user.
 */
- (void)interstitialWillPresentScreen:(IMAdInterstitial *)ad{
    if(isStop){
        return;
    }
    
    [self helperNotifyDelegateOfFullScreenAdModal];
}



/**
 * Callback sent before the interstitial is to be animated off the screen.
 * @param ad The IMAdInterstitial instance that will dismiss the interstitial
 *           screen.
 */
- (void)interstitialWillDismissScreen:(IMAdInterstitial *)ad{
    NSLog(@"%s",__FUNCTION__);
}

/**
 * Callback sent just after dismissing an interstitial and it has animated off
 * the screen.
 *
 * @param ad The IMAdInterstitial instance that dismissed the interstitial
 *           screen.
 */
- (void)interstitialDidDismissScreen:(IMAdInterstitial *)ad{
    if(isStop){
        return;
    }
    [self helperNotifyDelegateOfFullScreenAdModalDismissal];
}

/**
 * Callback sent just before the application goes into the background because
 * the user clicked on a link in the ad that will launch another application
 * (such as the App Store). The normal UIApplicationDelegate methods like
 * applicationDidEnterBackground: will immediately be called after this.
 *
 * @param ad The IMAdInterstitial instance that is launching another application.
 */
- (void)interstitialWillLeaveApplication:(IMAdInterstitial *)ad{
    NSLog(@"%s",__FUNCTION__);
}
@end
