//
//  InAppPur.m
//  pur
//
//  Created by public on 11-2-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InAppPur.h"
#import "UGameScene.h"
#import "GameSceneForGameCenter.h"


@implementation InAppPur
@synthesize inAppDelegate;

-(id)init:(UIView *)parent delegate:(id<UInAppDelegate>)inApp
{
	if (self = [super init]) {
		_parent = parent;
        inAppDelegate=inApp;
	
	}
	return self;
	
}

- (void)requestProUpgradeProductData
{
    NSLog(@"requestProductData");
	NSSet *productIdentifiers = [NSSet setWithObject:nowProductId ];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
    // we will release the request object in the delegate callback
	/*
	 progressInd.hidden = NO;
	[progressInd startAnimating];
	 */
	[self showWaitting];
}

-(void)showWaitting
{   
    
    //屏幕大小
    
	int width,height;
    if (isPad) {
        width=1024;
        height=768;
    }else {
        width=480;
        height=320;
    }
    int frameW = 100;
	int frameH = 100;
//	CGRect frame = CGRectMake((width-frameW)/2, (height-frameH)/2, frameW, frameH);
	
	
	//frame = CGRectMake(120, 90, width, height);
	UIActivityIndicatorView *progressInds = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((width-frameW)/2, (height-frameH)/2, frameW, frameH)];
	[progressInds startAnimating];
	progressInds.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//	frame = CGRectMake(0, 0, width, height);
// 	UIView *theView = [[UIView alloc] initWithFrame:frame];
    UIView *theView = [[UIView alloc] init];

	theView.backgroundColor = [UIColor blackColor];
    //透明度
	theView.alpha = 0.7;
	[theView addSubview:progressInds];
	[progressInds release];
	
	[theView setTag:123];
	[_parent addSubview:theView];
	[theView release];
	
	
}

-(void)hideWaittiing
{
	[[_parent viewWithTag:123] removeFromSuperview];
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

//收到产品消息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    proUpgradeProduct = [products count] == 1 ? [[products objectAtIndex:0] retain] : nil;
    //proUpgradeProduct =  [[products objectAtIndex:0] retain];
    if (proUpgradeProduct)
    {
        NSLog(@"***********Product title: %@" , proUpgradeProduct.localizedTitle);
        NSLog(@"***********Product description: %@" , proUpgradeProduct.localizedDescription);
		NSLog(@"***********Product price: %@" , proUpgradeProduct.price);
        NSLog(@"***********Product id: %@" , proUpgradeProduct.productIdentifier);
    }else {
        NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
    [productsRequest release];
    
	
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
	
	[self purchaseProUpgrade];
}


- (void)loadStore:(int)ProductId
{
    switch (ProductId) {
        case 1:
            nowProductId=kInAppPurchaseProductIdForPay_6;
            break;
        case 2:
            nowProductId=kInAppPurchaseProductIdForPay_12;
            break;
        case 3:
            nowProductId=kInAppPurchaseProductIdForPay_18;
            break;
        case 4:
            nowProductId=kInAppPurchaseProductIdForPay_25;
            break;
        case 5:
            nowProductId=kInAppPurchaseProductIdForPay_30;
            break;
        case 6:
            nowProductId=kInAppPurchaseProductIdForPay_60;
            break;
        case 7:
            nowProductId=kInAppPurchaseProductIdForPay_128;
            break;
        case 8:
            nowProductId=kInAppPurchaseProductIdForPay_258;
            break;
        case 9:
            nowProductId=kInAppPurchaseProductIdForPay_activate;
            break;
        default:
            break;
    }
   
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    // get the product description (defined in early sections)
    [self requestProUpgradeProductData];
}

//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
// 升级交易开始
- (void)purchaseProUpgrade
{
    NSLog(@"交易开始");
    
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:nowProductId];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
//	[progressInd stopAnimating];
}



////
//// saves a record of the transaction by storing the receipt to disk
////
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:nowProductId])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:nowProductId])
    {
        // enable the pro features
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isProUpgradePurchased" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// removes the transaction from the queue and posts a notification with the transaction result
// 交易结束 根据交易结果发布通知
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    [inAppDelegate finishTransaction:transaction wasSuccessful:wasSuccessful];
    //---------------------------------------------------------------------------
//    NSLog(@"交易结果");
//    [[GameSceneForGameCenter shardScene] setStartButtonEnableOK];
    // remove the transaction from the payment queue.
//    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//    
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
//    if (wasSuccessful)
//    {
//         NSLog(@"交易成功后的处理,交易的ID=%@",transaction.payment.productIdentifier);
////        [UGameScene shardScene].isRemoveAD=YES;
//        if (!isPad) {
//            [UGameScene shardScene].adState=kADStateForNoAD;
//            [[UGameScene shardScene] showHeadAndLevel];
//        }
//        //清除广告
////        if ([UGameScene shardScene].banner!=nil) {
////            [[UGameScene shardScene] deleteBanner];
////        }
//        if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_6]) {
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"6元",@"type",nil];
//            [MobClick event:@"pay_ok" attributes:dict];
//            [[UGameScene shardScene] addMoney:500];//200
//            [[UGameScene shardScene] saveGameData];
//        }
//        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_12]) {
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"12元",@"type",nil];
//            [MobClick event:@"pay_ok" attributes:dict];
//            [[UGameScene shardScene] addMoney:1500];//500
//            [[UGameScene shardScene] saveGameData];
//        }
//        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_18]) {
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"18元",@"type",nil];
//            [MobClick event:@"pay_ok" attributes:dict];
//            [[UGameScene shardScene] addMoney:3500];//1000
//            [[UGameScene shardScene] saveGameData];
//        }
//        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_25]) {
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"25元",@"type",nil];
//            [MobClick event:@"pay_ok" attributes:dict];
//            [[UGameScene shardScene] addMoney:8000];//1500
//            [[UGameScene shardScene] saveGameData];
//        }
//        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_30]) {
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"30元",@"type",nil];
//            [MobClick event:@"pay_ok" attributes:dict];
//            [[UGameScene shardScene] addMoney:10000];//2000
//        }
//        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_60]) {
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"60元",@"type",nil];
//            [MobClick event:@"pay_ok" attributes:dict];
//            [[UGameScene shardScene] addMoney:40000];//5000
//            [[UGameScene shardScene] saveGameData];
//        }
//        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_128]) {
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"128元",@"type",nil];
//            [MobClick event:@"pay_ok" attributes:dict];
//            [[UGameScene shardScene] addMoney:70000];//15000
//            [[UGameScene shardScene] saveGameData];
//        }
//        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_258]) {
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"258元",@"type",nil];
//            [MobClick event:@"pay_ok" attributes:dict];
//            [[UGameScene shardScene] addMoney:120000];//50000
//            [[UGameScene shardScene] saveGameData];
//        }
//        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_activate]){
//            [MobClick event:@"activate"];
//            [[GameSceneForGameCenter shardScene] saveActivateData];
//        }
//        
//        // send out a notification that we’ve finished the transaction
//		//[progressInd stopAnimating];
////		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//		//downNum = -1;
//		//NSNumber *num = [NSNumber numberWithInt:downNum];
//		//[prefs setObject:num forKey:kIsIAPurKey];
//	 
////		[prefs synchronize];
//		
//	//	[ReaderViewController back];
//	//	[SexSafeMainView fun];
//		[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
//    }
//    else
//    {
//        // send out a notification for the failed transaction
//		NSLog(@"交易失败后的处理");
//        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
//        
//    }
}

 

 

//
// called when the transaction was successful
// 交易成功
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];//记录
    [self provideContent:transaction.payment.productIdentifier];//记录
    [self finishTransaction:transaction wasSuccessful:YES];
    NSLog(@"交易成功2");
}

//
// called when a transaction has been restored and and successfully completed
// 交易已经得到恢复，并成功完成
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];//记录
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];//记录
    [self finishTransaction:transaction wasSuccessful:YES];
    NSLog(@"交易已经得到恢复，并成功完成");

}

//
// called when a transaction has failed
// 交易失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"交易失败2");

   //[progressInd stopAnimating];
	if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}	

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
// 交易状态变化
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                NSLog(@"交易成功!!!!!");
//                [[GameSceneForGameCenter shardScene] setStartButtonEnableOK];
                [inAppDelegate payOK];
                [self hideWaittiing];
                break;
            case SKPaymentTransactionStateFailed:
            {
                //dijk 2016-05-21
                //[MobClick event:@"pay_lose"];
            }
                [self failedTransaction:transaction];
                [inAppDelegate payLose];
                NSLog(@"交易失败!!!!!");
//                [[GameSceneForGameCenter shardScene] setStartButtonEnableOK];
                [self hideWaittiing];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                [inAppDelegate restore];
                [self hideWaittiing];
                break;
            default:
                break;
        }
    }
}

// 错误信息提示
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
	UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"Alert" message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:nil];
	
	[alerView show];
	[alerView release];
    [self hideWaittiing];
}

@end
