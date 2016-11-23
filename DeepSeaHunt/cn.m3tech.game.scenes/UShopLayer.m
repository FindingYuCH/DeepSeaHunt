//
//  UShopLayer.m
//  DeepSeaHunt
//
//  Created by Unity on 13-5-22.
//  Copyright (c) 2013年 akn. All rights reserved.
//

#import "UShopLayer.h"

@implementation UShopLayer
@synthesize shopDelegate;

-(id)init:(id<UShopDelegate>)delegate
{
    
    if (self=[super initWithColor:ccc4(0, 0, 0, 100)]) {
        ////dijk 22016-05-21
        //[MobClick event:@"open_shop"];
        
        //计费
//        UIView *view=[[CCDirector sharedDirector] view];
//        tempObserver = [[InAppPur alloc] init:view delegate:delegate];
        shopDelegate=delegate;
//        tempObserver.inAppDelegate=delegate;
//        [[SKPaymentQueue defaultQueue] addTransactionObserver:tempObserver];
        
//        CCLayer *temShopLayer=[CCLayer node];
        
        
        CCSprite *shop=[CCSprite spriteWithFile:@"pay_back.png"];
        shop.anchorPoint=CGPointZero;
        shop.position=ccp(GAME_SCENE_SIZE.width/2-shop.contentSize.width/2,GAME_SCENE_SIZE.height/2-shop.contentSize.height/2+30);
        
        //    if (!isRemoveAD) {
        //        CCSprite *removeADWord=[CCSprite spriteWithFile:@"shop_removeAD_word.png"];
        //        removeADWord.position=ccp(shop.contentSize.width*0.55,removeADWord.contentSize.height*2.5);
        //        [shop addChild:removeADWord];
        //    }
        
        
        
        CCMenuItem *item_close=[CCMenuItemImage itemWithNormalImage:@"pay_close.png" selectedImage:@"pay_close_.png" target:self selector:@selector(closeShop)];
        CCMenuItem *item_pay_1=[CCMenuItemImage itemWithNormalImage:@"pay_1.png" selectedImage:@"pay_1_.png" target:self selector:@selector(pay1)];
        CCMenuItem *item_pay_2=[CCMenuItemImage itemWithNormalImage:@"pay_2.png" selectedImage:@"pay_2_.png" target:self selector:@selector(pay2)];
        CCMenuItem *item_pay_3=[CCMenuItemImage itemWithNormalImage:@"pay_3.png" selectedImage:@"pay_3_.png" target:self selector:@selector(pay3)];
        CCMenuItem *item_pay_4=[CCMenuItemImage itemWithNormalImage:@"pay_4.png" selectedImage:@"pay_4_.png" target:self selector:@selector(pay4)];
        CCMenuItem *item_pay_5=[CCMenuItemImage itemWithNormalImage:@"pay_5.png" selectedImage:@"pay_5_.png" target:self selector:@selector(pay5)];
        CCMenuItem *item_pay_6=[CCMenuItemImage itemWithNormalImage:@"pay_6.png" selectedImage:@"pay_6_.png" target:self selector:@selector(pay6)];
        CCMenuItem *item_pay_7=[CCMenuItemImage itemWithNormalImage:@"pay_7.png" selectedImage:@"pay_7_.png" target:self selector:@selector(pay7)];
        CCMenuItem *item_pay_8=[CCMenuItemImage itemWithNormalImage:@"pay_8.png" selectedImage:@"pay_8_.png" target:self selector:@selector(pay8)];
        
        if (isPad) {
            item_close.position=ccp(680,480);
            item_pay_1.position=ccp(160,330);
            item_pay_2.position=ccp(300,330);
            item_pay_3.position=ccp(440,330);
            item_pay_4.position=ccp(580,330);
            item_pay_5.position=ccp(160,150);
            item_pay_6.position=ccp(300,150);
            item_pay_7.position=ccp(440,150);
            item_pay_8.position=ccp(580,150);
        }else {
            item_close.position=ccp(280,200);
            item_pay_1.position=ccp(72,135);
            item_pay_2.position=ccp(127,135);
            item_pay_3.position=ccp(182,135);
            item_pay_4.position=ccp(237,135);
            item_pay_5.position=ccp(72,70);
            item_pay_6.position=ccp(127,70);
            item_pay_7.position=ccp(182,70);
            item_pay_8.position=ccp(237,70);
        }
        
        CCMenu *temMenu=[CCMenu menuWithItems:item_close,item_pay_1,item_pay_2,item_pay_3,item_pay_4,item_pay_5,item_pay_6,item_pay_7,item_pay_8, nil];
        
        temMenu.position=CGPointZero;
        
        [shop addChild:temMenu z:1 tag:1];
        [self addChild:shop z:1 tag:1];
//        [self addChild:temShopLayer z:99 tag:kTagShopLayer];
    }
    
    return self;
}
- (void) closeShop
{
    [shopDelegate closeShop];
}

- (void) pay1
{
    [shopDelegate pay1];
    [self pauseShopMenu];
}
-(void)pay2
{
    [shopDelegate pay2];
    [self pauseShopMenu];
}
-(void)pay3
{
    [shopDelegate pay3];
    [self pauseShopMenu];
}
-(void)pay4
{
    [shopDelegate pay4];
    [self pauseShopMenu];
}
-(void)pay5
{
    [shopDelegate pay5];
    [self pauseShopMenu];
}
-(void)pay6
{
    [shopDelegate pay6];
    [self pauseShopMenu];
}
-(void)pay7
{
    [shopDelegate pay7];
    [self pauseShopMenu];
}
-(void)pay8
{
    [shopDelegate pay8];
    [self pauseShopMenu];
}

-(void)pauseShopMenu
{
    CCMenu *temMenu=(CCMenu *)[[self getChildByTag:1] getChildByTag:1];
    
    if (temMenu!=nil) {
        [temMenu setEnabled:NO];
    }
    
}
-(void)resumeShopMenu
{
    CCMenu *temMenu=(CCMenu *)[[self getChildByTag:1] getChildByTag:1];
    
    if (temMenu!=nil) {
        [temMenu setEnabled:YES];
    }
}

@end
