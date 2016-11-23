//
//  File: AdMoGoAdapterAdChinaFullAdController.m
//  Project: AdsMOGO iOS SDK
//  Version: 1.1.9
//
//  Copyright 2011 AdsMogo.com. All rights reserved.
//

#import "AdMoGoAdapterAdChinaFullAdController.h"
//#import "AdMoGoView.h"
#import "AdMoGoAdNetworkRegistry.h"
#import "AdMoGoAdNetworkAdapter+Helpers.h"
#import "AdMoGoAdNetworkConfig.h" 
#import "AdMoGoAdapterAdChinaFullAd.h"


@implementation AdMoGoAdapterAdChinaFullAdController

-(id)initWithAdChina:(AdMoGoAdapterAdChinaFullAd *)adchina {
    self = [super init];
    if (self) {
        adchina_ = [adchina retain];
    }
    return self;
}

- (void)dealloc
{
    [adchina_ release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSString *)fullScreenAdSpaceId{
	return adchina_.networkConfig.pubId;
}

- (void)didGetFullScreenAd:(AdChinaFullScreenView *)fsView {
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
	[adchina_ helperNotifyDelegateOfFullScreenAdModal];
    [adchina_.adMoGoCore adapter:adchina_ didReceiveAdView:nil];
}

- (void)didFailedToGetFullScreenAd:(AdChinaFullScreenView *)fsView {
	[adchina_.adMoGoCore adapter:adchina_ didFailAd:nil];
}

- (void)didCloseFullScreenAd:(AdChinaFullScreenView *)fsView {
    [self.view removeFromSuperview];
}

- (void)didBeginBrowsingAdWeb:(AdChinaFullScreenView *)fsView {

}

- (void)didFinishBrowsingAdWeb:(AdChinaFullScreenView *)fsView {
	
}

// You may use these methods to count click/watch number by yourself
- (void)didClickFullScreenAd:(AdChinaFullScreenView *)adView{
    [adchina_ sendAdFullClick];
}

// user's phone number
- (NSString *)phoneNumber {
	if ([adchina_.adMoGoDelegate respondsToSelector:@selector(phoneNumber)]) {
		return [adchina_.adMoGoDelegate phoneNumber];
	}
	return @"";
}		
// user's gender (@"1" for male, @"2" for female)
- (NSString *)gender {
	if ([adchina_.adMoGoDelegate respondsToSelector:@selector(gender)]) {
		return [adchina_.adMoGoDelegate gender];
	}
	return @"";
}			
// user's postal code, e.g. @"200040"
- (NSString *)postalCode {
	if ([adchina_.adMoGoDelegate respondsToSelector:@selector(postalCode)]) {
		return [adchina_.adMoGoDelegate postalCode];
	}
	return @"";
}
//// user's date of birth, e.g. @"19820101"
- (NSString *)dateOfBirth {
	if ([adchina_.adMoGoDelegate respondsToSelector:@selector(dateOfBirth)]) {
		NSString *Date = [[NSString alloc] init];
		NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
		NSDate *date = [adchina_.adMoGoDelegate dateOfBirth];
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
	if ([adchina_.adMoGoDelegate respondsToSelector:@selector(keywords)]) {
		return [adchina_.adMoGoDelegate keywords];
	}
	return @"";
}
@end