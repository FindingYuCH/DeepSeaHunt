//
//  File: AdMoGoAdapterAdChinaFullAd.m
//  Project: AdsMOGO iOS SDK
//  Version: 1.2.1
//
//  Copyright 2011 AdsMogo.com. All rights reserved.
//

#import "AdMoGoAdapterAdChinaFullAd.h"
#import "AdMoGoAdNetworkRegistry.h"
#import "AdMoGoAdNetworkAdapter+Helpers.h"
#import "AdMoGoAdNetworkConfig.h" 
#import "AdMoGoConfigDataCenter.h"
#import "AdMoGoConfigData.h"

@implementation AdMoGoAdapterAdChinaFullAd

+ (NSDictionary *)networkType {
	return [self makeNetWorkType:AdMoGoAdNetworkTypeAdChina IsSDK:YES isApi:NO isBanner:NO isFullScreen:YES];
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
    
    AdViewType type =[configData.ad_type intValue];
    
	if (type == AdViewTypeFullScreen ||
        type == AdViewTypeiPadFullScreen) {
        
        fullScreenAd = [AdChinaFullScreenView requestAdWithAdSpaceId:[self.ration objectForKey:@"key"]  delegate:self];
        UIViewController *baseviewController = [adMoGoDelegate viewControllerForPresentingModalView];
        [fullScreenAd setViewControllerForBrowser:baseviewController];
        [baseviewController.view addSubview:fullScreenAd];
        timer = [[NSTimer scheduledTimerWithTimeInterval:AdapterTimeOut60 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];
    }
}

- (void)stopBeingDelegate {
    /*2013*/
    if (fullScreenAd) {
        [fullScreenAd removeFromSuperview];
        fullScreenAd = nil;
    }
    
}

- (void)stopAd{
    [self stopBeingDelegate];
    isStop = YES;
}

- (void)dealloc {
    NSLog(@"remove ad");
    [self stopTimer];
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

- (void)sendAdFullClick{
    
    if (isStop) {
        return;
    }
    
    [adMoGoCore specialSendRecordNum];
}

/*
    方案二
 */
#pragma mark 方案二

- (void)didGetFullScreenAd:(AdChinaFullScreenView *)fsView {
//    [[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
	if (isStop) {
        return;
    }
    [self stopTimer];
    [adMoGoCore adapter:self didReceiveAdView:nil];
}

- (void)didFailedToGetFullScreenAd:(AdChinaFullScreenView *)fsView {
    if (isStop) {
        return;
    }
    [self stopTimer];
	[adMoGoCore adapter:self didFailAd:nil];
}

- (void)didCloseFullScreenAd:(AdChinaFullScreenView *)fsView {
    
    [fsView removeFromSuperview];
    [self helperNotifyDelegateOfFullScreenAdModalDismissal];
}

- (void)didBeginBrowsingAdWeb:(AdChinaFullScreenView *)fsView {
    
}

- (void)didFinishBrowsingAdWeb:(AdChinaFullScreenView *)fsView {
	
}

// You may use these methods to count click/watch number by yourself
- (void)didClickFullScreenAd:(AdChinaFullScreenView *)adView{
    [self sendAdFullClick];
}

// user's phone number
- (NSString *)phoneNumber {
	if ([adMoGoDelegate respondsToSelector:@selector(phoneNumber)]) {
		return [adMoGoDelegate phoneNumber];
	}
	return @"";
}		
// user's gender (@"1" for male, @"2" for female)
- (NSString *)gender {
	if ([adMoGoDelegate respondsToSelector:@selector(gender)]) {
		return [adMoGoDelegate gender];
	}
	return @"";
}			
// user's postal code, e.g. @"200040"
- (NSString *)postalCode {
	if ([adMoGoDelegate respondsToSelector:@selector(postalCode)]) {
		return [adMoGoDelegate postalCode];
	}
	return @"";
}
//// user's date of birth, e.g. @"19820101"
- (NSString *)dateOfBirth {
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
	if ([adMoGoDelegate respondsToSelector:@selector(keywords)]) {
		return [adMoGoDelegate keywords];
	}
	return @"";
}


@end
