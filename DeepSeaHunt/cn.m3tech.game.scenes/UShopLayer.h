//
//  UShopLayer.h
//  DeepSeaHunt
//
//  Created by Unity on 13-5-22.
//  Copyright (c) 2013年 akn. All rights reserved.
//

#import "cocos2d.h"
//#import "MobClick.h"
#import "GameDefine.h"
#import "InAppPur.h"

@protocol UShopDelegate

- (void)closeShop;
- (void) pay1;
- (void) pay2;
- (void) pay3;
- (void) pay4;
- (void) pay5;
- (void) pay6;
- (void) pay7;
- (void) pay8;
@end

@interface UShopLayer : CCLayerColor
{
//    InAppPur *tempObserver;
     id <UShopDelegate> shopDelegate;
}
@property (assign) id <UShopDelegate> shopDelegate;
-(id)init:(id<UShopDelegate>)delegate;
- (void)resumeShopMenu;
@end
