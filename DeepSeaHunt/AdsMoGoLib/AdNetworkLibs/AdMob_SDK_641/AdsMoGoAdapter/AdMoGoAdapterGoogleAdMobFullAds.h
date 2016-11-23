//
//  AdMoGoAdapterGoogleAdMobFullAds.h
//  TestMOGOSDKAPP
//
//  Created by 孟令之 on 12-12-3.
//
//

#import "AdMoGoAdNetworkAdapter.h"
#import "GADInterstitial.h"
#import "GADInterstitialDelegate.h"

@interface AdMoGoAdapterGoogleAdMobFullAds : AdMoGoAdNetworkAdapter<GADInterstitialDelegate>{
    GADInterstitial *interstitial;
    BOOL isStop;
    NSTimer *timer;
}
+ (NSDictionary *)networkType;

@end
