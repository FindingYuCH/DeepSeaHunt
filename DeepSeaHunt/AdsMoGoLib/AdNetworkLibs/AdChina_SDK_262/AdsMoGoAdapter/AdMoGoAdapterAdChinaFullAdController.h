//
//  File: AdMoGoAdapterAdChinaFullAdController.h
//  Project: AdsMOGO iOS SDK
//  Version: 1.1.9
//
//  Copyright 2011 AdsMogo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdChinaFullScreenViewDelegateProtocol.h"
@class AdMoGoAdapterAdChinaFullAd;

@interface AdMoGoAdapterAdChinaFullAdController : UIViewController <AdChinaFullScreenViewDelegate>{
    AdMoGoAdapterAdChinaFullAd *adchina_;
}
-(id)initWithAdChina:(AdMoGoAdapterAdChinaFullAd *)adchina;
@end
