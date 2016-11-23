//
//  AdMoGoAdapterAdermob.h
//  TestMOGOSDKAPP
//
//  Created on 13-2-16.
//
//

#import "AdMoGoAdNetworkAdapter.h"
#import "AderDelegateProtocal.h"
#import "AderSDK.h"

@interface AdMoGoAdapterAdermob : AdMoGoAdNetworkAdapter <AderDelegateProtocal>{
    BOOL isStop;
    NSTimer *timer;
    BOOL isLoaded;
}

+ (NSDictionary *)networkType;
@end
