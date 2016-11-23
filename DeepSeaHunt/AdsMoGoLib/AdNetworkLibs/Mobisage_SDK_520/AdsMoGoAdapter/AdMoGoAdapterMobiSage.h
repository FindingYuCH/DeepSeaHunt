//
//  File: AdMoGoAdapterMobiSage.h
//  Project: AdsMOGO iOS SDK
//  Version: 1.1.9
//
//  Copyright 2011 AdsMogo.com. All rights reserved.
//

#import "AdMoGoAdNetworkAdapter.h"
#import "MobiSageSDK.h"

@interface AdMoGoAdapterMobiSage : AdMoGoAdNetworkAdapter<MobiSageAdViewDelegate> {
	NSTimer *timer;
    BOOL isStop;
    MobiSageAdBanner *adView;
   
}
+ (NSDictionary *)networkType;

- (void)adStartShow:(id)sender;
- (void)adPauseShow:(id)sender;
- (void)adPop:(id)sender;
- (void)adHide:(id)sender;

- (void)loadAdTimeOut:(NSTimer*)theTimer;
@end
