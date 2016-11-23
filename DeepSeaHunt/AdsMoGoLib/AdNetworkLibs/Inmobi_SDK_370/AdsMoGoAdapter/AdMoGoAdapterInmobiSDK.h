//
//  AdMoGoAdapterInmobiSDK.h
//  TestMOGOSDKAPP
//
//  Created by MOGO on 12-9-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AdMoGoAdNetworkAdapter.h"
#import "IMAdView.h"
#import "IMAdDelegate.h"
#import "IMAdRequest.h"
#import "IMAdError.h"

@interface AdMoGoAdapterInmobiSDK : AdMoGoAdNetworkAdapter<IMAdDelegate>
{
    UIView *adView;
    CGRect rect;
    BOOL isStop;
    IMAdView *inmobiAdView;
    IMAdRequest *request;
    NSTimer *timer;
}
@end
