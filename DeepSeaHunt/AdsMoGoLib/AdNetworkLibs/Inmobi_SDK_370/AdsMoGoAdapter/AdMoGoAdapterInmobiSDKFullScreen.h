//
//  AdMoGoAdapterInmobiSDKFullScreen.h
//  TestMOGOSDKAPP
//
//  Created by Daxiong on 12-11-21.
//
//

#import "AdMoGoAdNetworkAdapter.h"
#import "AdMoGoAdNetworkAdapter+Helpers.h"
#import "IMAdInterstitial.h"
#import "IMAdInterstitialDelegate.h"
#import "IMAdRequest.h"
#import "IMAdError.h"

@interface AdMoGoAdapterInmobiSDKFullScreen : AdMoGoAdNetworkAdapter<IMAdInterstitialDelegate>{
    NSTimer *timer;
    BOOL isStop;
    IMAdInterstitial *interstitialAd;
}

@end
