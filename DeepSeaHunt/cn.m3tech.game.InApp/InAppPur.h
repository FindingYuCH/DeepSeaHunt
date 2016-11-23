//
//  InAppPur.h
//  pur
//
//  Created by public on 11-2-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
//#import "MobClick.h"
#import "GameDefine.h"
@protocol UInAppDelegate

// 交易结束 根据交易结果发布通知
- (void) finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful;
//付费成功时调用的接口
- (void) payOK;
//付费失败时调用的接口
- (void) payLose;
//数据恢复时调用的接口
- (void) restore;
@end

//交易失败通知
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
//交易成功通知
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"
//产品升级
#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"

@interface InAppPur : NSObject <SKProductsRequestDelegate,SKPaymentTransactionObserver> {
	SKProduct *proUpgradeProduct;
	SKProductsRequest	*productsRequest;
	UIView *_parent;
    NSString *nowProductId;
    id<UInAppDelegate> inAppDelegate;
	
}
@property (assign) id <UInAppDelegate> inAppDelegate;

-(id)init:(UIView *)parent delegate:(id<UInAppDelegate>)inApp;
- (void)requestProUpgradeProductData;
-(void)hideWaittiing;
- (void)loadStore:(int)productID;
- (BOOL)canMakePurchases;
- (void)purchaseProUpgrade;
 

@end
