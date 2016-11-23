//
//  File: AdMoGoAdapterAdChina.m
//  Project: AdsMOGO iOS SDK
//  Version: 1.2.1
//
//  Copyright 2011 AdsMogo.com. All rights reserved.
//

#import "AdMoGoAdapterAdChina.h"
#import "AdMoGoAdNetworkRegistry.h"
#import "AdMoGoAdNetworkAdapter+Helpers.h"
#import "AdMoGoAdNetworkConfig.h" 
#import "AdChinaBannerView.h"
#import "AdChinaUserInfoDelegateProtocol.h"
#import "AdMoGoConfigDataCenter.h"
#import "AdMoGoConfigData.h"
#import "AdMoGoDeviceInfoHelper.h"

@implementation AdMoGoAdapterAdChina

+ (NSDictionary *)networkType {
    return [self makeNetWorkType:AdMoGoAdNetworkTypeAdChina IsSDK:YES isApi:NO isBanner:YES isFullScreen:NO];
}

+ (void)load {
	[[AdMoGoAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {
    
    isStop = NO;
    
     [adMoGoCore adDidStartRequestAd];
    /*
     获取广告类型
     原来代码：AdViewType type = adMoGoView.adType;
     */
    AdMoGoConfigDataCenter *configDataCenter = [AdMoGoConfigDataCenter singleton];
    
    AdMoGoConfigData *configData = [configDataCenter.config_dict objectForKey:adMoGoCore.config_key];
    
    
//
//    AdViewType type = adMoGoView.adType;
    AdViewType type =[configData.ad_type intValue];
    CGSize size = CGSizeZero;
    switch (type) {
        case AdViewTypeNormalBanner:
            size = CGSizeMake(320, 48);
            break;
        case AdViewTypeLargeBanner:
            size = CGSizeMake(728, 90);
            break;
        default:
            [adMoGoCore adapter:self didGetAd:@"adchina"];
            [adMoGoCore adapter:self didFailAd:nil];
            return;
            break;
    }

//    AdChinaBannerView *bannerAd =[AdChinaBannerView requestAdWithAdSpaceId:networkConfig.pubId delegate:self adSize:size];
    AdChinaBannerView *bannerAd =[AdChinaBannerView requestAdWithAdSpaceId:[self.ration objectForKey:@"key"]delegate:self adSize:size];
    [bannerAd setAnimationMask:AnimationMaskNone];
    [bannerAd setViewControllerForBrowser:[adMoGoDelegate viewControllerForPresentingModalView]];
    bannerAd.frame = CGRectMake(0, 0, size.width, size.height);
    [bannerAd setRefreshInterval:DisableRefresh];
    self.adNetworkView = bannerAd;
    [bannerAd release];
    timer = [[NSTimer scheduledTimerWithTimeInterval:AdapterTimeOut15 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];
}

- (void)stopBeingDelegate {
    AdChinaBannerView *adView = (AdChinaBannerView *)self.adNetworkView;
    if(adView != nil)
    {
        [adView setViewControllerForBrowser:nil];
        self.adNetworkView = nil;
    }
}

- (void)stopAd{
    [self stopTimer];
    AdChinaBannerView *adView = (AdChinaBannerView *)self.adNetworkView;
    if(adView != nil)
    {
       [adView setViewControllerForBrowser:nil];
        [self.adNetworkView removeFromSuperview];
        adNetworkView = nil;
    }
    isStop = YES;
}

- (void)dealloc {
    [self stopTimer];
	[super dealloc];
}




#pragma mark AdChinaDelegate required methods
#pragma mark Banner
- (void)didGetBanner:(AdChinaBannerView *)adView {
    if (isStop) {
        return;
    }
    [self stopTimer];
    
    [adMoGoCore adapter:self didGetAd:@"adchina"];
    [adMoGoCore adapter:self didReceiveAdView:self.adNetworkView];
}
- (void)didFailToGetBanner:(AdChinaBannerView *)adView {
    
    if (isStop) {
        return;
    }
    [self stopTimer];
    [adMoGoCore adapter:self didGetAd:@"adchina"];
	[adMoGoCore adapter:self didFailAd:nil];
    [self stopAd];
}

- (void)didEnterFullScreenMode {
    [adMoGoCore stopTimer];
    [self helperNotifyDelegateOfFullScreenModal];
}
- (void)didExitFullScreenMode {
     [adMoGoCore fireTimer];
    [self helperNotifyDelegateOfFullScreenModalDismissal];
}

#pragma mark optional targeting info methods

// user's phone number
- (NSString *)phoneNumber {
    
    if (isStop) {
        return @"";
    }
    
	if ([adMoGoDelegate respondsToSelector:@selector(phoneNumber)]) {
		return [adMoGoDelegate phoneNumber];
	}
	return @"";
}		
// user's gender (@"1" for male, @"2" for female)	
- (Sex)gender {
    
    if (isStop) {
        return SexUnknown;
    }
    
    if ([adMoGoDelegate respondsToSelector:@selector(gender)]) {
        NSUInteger tempInt = [[adMoGoDelegate gender] integerValue];
        switch (tempInt) {
            case 1:
                return SexMale;
            case 2:
                return SexFemale;
            default:
                return SexUnknown;
        }
	}
	return SexUnknown;
}


// user's postal code, e.g. @"200040"
- (NSString *)postalCode {
    
    if (isStop) {
        return @"";
    }
    
	if ([adMoGoDelegate respondsToSelector:@selector(postalCode)]) {
		return [adMoGoDelegate postalCode];
	}
	return @"";
}
// user's date of birth, e.g. @"19820101"
- (NSString *)dateOfBirth {
    
    if (isStop) {
        return @"";
    }
    
	if ([adMoGoDelegate respondsToSelector:@selector(dateOfBirth)]) {
		NSString *Date = [[NSString alloc] init];
		NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
		NSDate *date = [adMoGoDelegate dateOfBirth];
		[dataFormatter setDateFormat:@"YYYYMMdd"];
		[Date stringByAppendingFormat:@"%@",[dataFormatter stringFromDate:date]];
		[Date autorelease];
		[dataFormatter autorelease];
		return Date;
	}
	return @"";
}
// keyword about the type of your app, e.g. @"Business"
- (NSString *)keywords {
    
    if (isStop) {
        return @"";
    }
    
	if ([adMoGoDelegate respondsToSelector:@selector(keywords)]) {
		return [adMoGoDelegate keywords];
	}
	return @"";
}

#pragma mark TimerOut
/*2013*/
- (void)loadAdTimeOut:(NSTimer*)theTimer {
    if (isStop) {
        return;
    }
    [self stopTimer];
    [self stopBeingDelegate];
    [adMoGoCore adapter:self didFailAd:nil];
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
}
@end