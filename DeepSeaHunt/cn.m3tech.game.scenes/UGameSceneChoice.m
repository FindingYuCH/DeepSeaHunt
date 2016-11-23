//
//  UGameSceneChoice.m
//  DeepSeaHunt
//
//  Created by Unity on 13-5-6.
//  Copyright (c) 2013年 akn. All rights reserved.
//

#import "UGameSceneChoice.h"


#define kAlerTagForMoneyAler 10

@implementation UGameSceneChoice
+(CCScene*)scene
{
    CCScene *scene=[CCScene node];
    UGameSceneChoice *layer=[UGameSceneChoice node];
    
    [scene addChild:layer];
    return scene;
}
-(id)init
{
    if (self=[super init]) {
        nowSceneID=0;
        [self initUI];
//      UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
//                                                        initWithTarget:self
//                                                        action:@selector(handlePan:)];
        //计费
        UIView *view=[[CCDirector sharedDirector] view];
        tempObserver = [[InAppPur alloc] init:view delegate:self];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:tempObserver];
       
        
//        UISwipeGestureRecognizer *swipeGestureRescognizer=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        self.isTouchEnabled=YES;
//      [[CCDirector sharedDirector].view addGestureRecognizer:panGestureRecognizer];
//      [[CCDirector sharedDirector].view addGestureRecognizer:swipeGestureRescognizer];
    }
    return self;
}
- (CCNode*)getChoiceItem:(NSInteger)itemID
{
    CCNode *temNode=[self getChildByTag:itemID];
    return temNode;
}
- (void) handlePan:(UIPanGestureRecognizer*)recognizer
{
    
//    CGPoint point= [recognizer velocityInView:[CCDirector sharedDirector].view];
//    CGPoint curPoint = [recognizer locationInView:[CCDirector sharedDirector].view];
//    CGPoint transPoint=[recognizer translationInView:[CCDirector sharedDirector].view];
//    
//    
//    
//    prevPoint=transPoint;
    
//    NSLog(@"滑动...point.x=%f   point.y=%f curPoint.x=%f  curPoint.y=%f  ",point.x,point.y,curPoint.x,curPoint.y);
    
//     NSLog(@"滑动...transPoint.x=%f   transPoint.y=%f  ",transPoint.x,transPoint.y);
}
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
    
    beganPos=location;
    
}
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
    
    nowPos=location;
    
//    itemLayerPos=ccpAdd(nowPos, beganPos);
//    itemLayerPos=ccpAdd(itemLayerPos, ccpSub(nowPos, beganPos));
    itemLayer.position=ccpAdd(itemLayerPos, ccpSub(ccp(nowPos.x, 0), ccp(beganPos.x, 0)));
    
    float a=nowPos.x-beganPos.x;
    NSLog(@"移动了多少：%f",a);
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
    
    itemLayerPos=itemLayer.position;
    
    CGPoint temPos=itemLayer.position;
    if (temPos.x<-itemSpace*4) {
        id move=[CCMoveTo actionWithDuration:0.2 position:ccp(-itemSpace*4, 0)];
        [itemLayer runAction:move];
        itemLayerPos=ccp(-itemSpace*4, 0);
        nowSceneID=4;
    }else if (temPos.x>0){
        id move=[CCMoveTo actionWithDuration:0.2 position:CGPointZero];
        [itemLayer runAction:move];
        itemLayerPos=CGPointZero;
        nowSceneID=0;
    }else if(temPos.x<=0&&temPos.x>-(itemSpace*0.5)){
        id move=[CCMoveTo actionWithDuration:0.2 position:CGPointZero];
        [itemLayer runAction:move];
        itemLayerPos=CGPointZero;
        nowSceneID=0;
    }else if(temPos.x<=-(itemSpace*0.5)&&temPos.x>-(itemSpace*1.5)){
        id move=[CCMoveTo actionWithDuration:0.2 position:ccp(-itemSpace, 0)];
        [itemLayer runAction:move];
        itemLayerPos=ccp(-itemSpace*1, 0);
        nowSceneID=1;
    }else if(temPos.x<=-(itemSpace*1.5)&&temPos.x>-(itemSpace*2.5)){
        id move=[CCMoveTo actionWithDuration:0.2 position:ccp(-itemSpace*2, 0)];
        [itemLayer runAction:move];
        itemLayerPos=ccp(-itemSpace*2, 0);
        nowSceneID=2;
    }else if(temPos.x<=-(itemSpace*2.5)&&temPos.x>-(itemSpace*3.5)){
        id move=[CCMoveTo actionWithDuration:0.2 position:ccp(-itemSpace*3, 0)];
        [itemLayer runAction:move];
        itemLayerPos=ccp(-itemSpace*3, 0);
        nowSceneID=3;
    }else if(temPos.x<=-(itemSpace*3.5)&&temPos.x>-(itemSpace*4.5)){
        id move=[CCMoveTo actionWithDuration:0.2 position:ccp(-itemSpace*4, 0)];
        [itemLayer runAction:move];
        itemLayerPos=ccp(-itemSpace*4, 0);
        nowSceneID=4;
    }
    
}
- (void) handleSwipe:(UIPanGestureRecognizer*) recognizer
{
    NSLog(@"快速滑动...");
}
//初始化UI
- (void) initUI
{
    CCSprite *temBack;
    if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
        temBack=[CCSprite spriteWithFile:@"universal_background-iphone5.png"];
    }else{
        temBack=[CCSprite spriteWithFile:@"universal_background.png"];
    }
    temBack.anchorPoint=CGPointZero;
    [self addChild:temBack z:-1];
    
    CCSprite *temTitle=[CCSprite spriteWithFile:@"sc_title.png"];
    temTitle.position=ccp(GAME_SCENE_SIZE.width/2, GAME_SCENE_SIZE.height/6*5.3);
    [self addChild:temTitle z:1];
    
    //获取当前金币
    if ([USave isHaveRecord:kRecordTypeForGameData]) {
        RecordForGameData *temRecord=(RecordForGameData *)[[USave readGameData:kRecordTypeForGameData] bytes];
        nowGold=temRecord->nowGold;
    }else if([USave isHaveRecord:kRecordTypeForGameData2_2]){
        RecordForGameData_2_2 *temRecord=(RecordForGameData_2_2 *)[[USave readGameData:kRecordTypeForGameData2_2] bytes];
        nowGold=temRecord->nowGold;
    }else{
        nowGold=1000;
    }
    //显示当前金币
    CCSprite *nowGoldRim=[CCSprite spriteWithFile:@"sc_now_gold_rim.png"];
    CCLabelAtlas *goldLabel;
    if (isPad) {
        goldLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%07d",nowGold] charMapFile:@"sc_now_gold.png" itemWidth:22 itemHeight:21 startCharMap:'0'];
        goldLabel.position=ccp(80,20);
    }else{
        goldLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%07d",nowGold] charMapFile:@"sc_now_gold.png" itemWidth:11 itemHeight:11 startCharMap:'0'];
        goldLabel.position=ccp(36, 7);
    }
    nowGoldAtlas=goldLabel;
    [nowGoldRim addChild:goldLabel];
    
    nowGoldRim.position=ccp(nowGoldRim.contentSize.width/2, GAME_SCENE_SIZE.height-nowGoldRim.contentSize.height/2);
    
    [self addChild:nowGoldRim];
    
    //添加按钮
    CCMenuItem *temStartItem=[CCMenuItemImage itemWithNormalImage:@"sc_button_start.png" selectedImage:@"sc_button_start_.png" target:self selector:@selector(eventForStartButton)];
    CCMenuItem *temBackItem=[CCMenuItemImage itemWithNormalImage:@"sc_button_back.png" selectedImage:@"sc_button_back_.png" target:self selector:@selector(eventForBackButton)];
    if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
        temStartItem.position=ccp(GAME_SCENE_SIZE.width/2, 50);
        temBackItem.position=ccp(528, 300);
    }else if (isPad) {
        temStartItem.position=ccp(GAME_SCENE_SIZE.width/2, 100);
        temBackItem.position=ccp(950, 700);
    }else{
        temStartItem.position=ccp(GAME_SCENE_SIZE.width/2, 50);
        temBackItem.position=ccp(440, 300);
    }
    
    itemBack=temBackItem;
    itemStart=temStartItem;
    
    
    CCMenu *temMenu=[CCMenu menuWithItems:temStartItem,temBackItem, nil];
    temMenu.position=CGPointZero;
    [self addChild:temMenu z:1];
    
    
    itemLayer=[CCLayer node];
    [self addChild:itemLayer z:1];
    //添加选项
    choiceArray=[[NSMutableArray alloc] init];
    itemLayerPos=CGPointZero;
    
    
    CCNode *temNode=[self createNewChoiceItem:@"sc_fish_normal.png" textFile:@"sc_text_normal.png" position:ccp(GAME_SCENE_SIZE.width/2, GAME_SCENE_SIZE.height/2)];
    [itemLayer addChild:temNode z:1 ];
    
    //选项的距离及选项层的宽度
    itemSpace=GAME_SCENE_SIZE.width/2+temNode.contentSize.width/2-temNode.contentSize.width/6;
    itemLayerWidth=GAME_SCENE_SIZE.width+itemSpace*4;

    
    [itemLayer addChild:[self createNewChoiceItem:@"sc_fish_5.png" textFile:@"sc_text_5.png" position:ccp(GAME_SCENE_SIZE.width/2+itemSpace, GAME_SCENE_SIZE.height/2)] z:1 ];
    
    [itemLayer addChild:[self createNewChoiceItem:@"sc_fish_20.png" textFile:@"sc_text_20.png" position:ccp(GAME_SCENE_SIZE.width/2+itemSpace*2, GAME_SCENE_SIZE.height/2)] z:1];
    
    [itemLayer addChild:[self createNewChoiceItem:@"sc_fish_50.png" textFile:@"sc_text_50.png" position:ccp(GAME_SCENE_SIZE.width/2+itemSpace*3, GAME_SCENE_SIZE.height/2)] z:1 ];
    
    [itemLayer addChild:[self createNewChoiceItem:@"sc_fish_100.png" textFile:@"sc_text_100.png" position:ccp(GAME_SCENE_SIZE.width/2+itemSpace*4, GAME_SCENE_SIZE.height/2)] z:1 ];
//    [choiceArray addObject:temNode]
    
}
//添加选项
- (CCNode *)createNewChoiceItem:(NSString*)fishIconFile textFile:(NSString*)textFile position:(CGPoint)position
{
    
    CCNode *choicNode;
    CCSprite *temChoiceBack,*temFishIcon,*temText;
    
    choicNode=[CCNode node];
    temChoiceBack=[CCSprite spriteWithFile:@"sc_choice_back.png"];
    temFishIcon=[CCSprite spriteWithFile:fishIconFile];
    temText=[CCSprite spriteWithFile:textFile];
    
    [choicNode addChild:temChoiceBack z:0];
    [choicNode addChild:temFishIcon z:1];
    [choicNode addChild:temText z:1];
    
    
    if (isPad) {
        temFishIcon.position=ccp(0, 60);
        temText.position=ccp(0, -120);
    }else{
        temFishIcon.position=ccp(0, 30);
        temText.position=ccp(0, -50);
    }
    choicNode.position=ccp(position.x, position.y);
    
    choicNode.contentSize=temChoiceBack.contentSize;
    
//    [self addChild:choicNode z:1];
    return choicNode;
}

- (void) eventForStartButton
{
    //判断游戏金币是否足够
    int temGold;
    if ([USave isHaveRecord:kRecordTypeForGameData]) {
        RecordForGameData *temRecord=(RecordForGameData*)[[USave readGameData:kRecordTypeForGameData] bytes];
        temGold=temRecord->nowGold;
    }else if ([USave isHaveRecord:kRecordTypeForGameData2_2]) {
        RecordForGameData_2_2 *temRecord=(RecordForGameData_2_2*)[[USave readGameData:kRecordTypeForGameData2_2] bytes];
        temGold=temRecord->nowGold;
    }else{
        temGold=0;
    }
    
    int temNeedGoldArr[5]={0,2000,8000,20000,50000};
    if (temGold<temNeedGoldArr[nowSceneID]) {
        [self showMoneyAler];
        return;
    }
    GAME_IS_FOR_GAMECENTER=NO;
    //设置场景的倍率
    int p=0;

    switch (nowSceneID) {
        case 0:
            p=1;
            break;
        case 1:
            p=5;
            break;
        case 2:
            p=20;
            break;
        case 3:
            p=50;
            break;
        case 4:
            p=100;
            break;
        default:
            break;
    }
    CCScene *scene=[UGameScene scene:p];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeBL transitionWithDuration:1 scene:scene]];
    
}
- (void) eventForBackButton
{
    CCScene *scene=[UWelcomeScene scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeBL transitionWithDuration:1 scene:scene]];
}
//金币不足提示
-(void)showMoneyAler
{
    
    UIAlertView* dialog = [[UIAlertView alloc] init];
    dialog.tag=kAlerTagForMoneyAler;
    [dialog setDelegate:self];
    [dialog setTitle:@"系统提示"];
    [dialog setMessage:@"金币不足不能进入该区域，是否进行购买？"];
    [dialog addButtonWithTitle:@"确定"];
    [dialog addButtonWithTitle:@"取消"];
    //    [dialog addButtonWithTitle:@"取消"];
    [dialog show];
    [dialog release];
}
- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alert.tag==kAlerTagForMoneyAler) {
        if(buttonIndex==0) {  //yes
            [self showShop];
        }
        else{  //No
            
        }
    }
}

- (void) showShop
{
    shopLayer=[[UShopLayer alloc] init:self];
//    shopLayer.shopDelegate=self;
//    [shopLayer setInAppDelegate:self];
    [self addChild:shopLayer z:10];
    //暂停其他按钮功能
    itemStart.isEnabled=NO;
    itemBack.isEnabled=NO;
    self.isTouchEnabled=NO;
}
#pragma mark - UShopDelegate
- (void) closeShop
{
    [shopLayer removeFromParentAndCleanup:YES];
    //恢复按钮功能
    itemStart.isEnabled=YES;
    itemBack.isEnabled=YES;
    self.isTouchEnabled=YES;
}
- (void) pay1
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"6元",@"type",nil];
    ///dijk 2016-05-21
    //[MobClick event:@"choice_pay" attributes:dict];
    [tempObserver loadStore:1];
}
-(void)pay2
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"12元",@"type",nil];
    ///dijk 2016-05-21
    //[MobClick event:@"choice_pay" attributes:dict];
    [tempObserver loadStore:2];
}
-(void)pay3
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"18元",@"type",nil];
    ///dijk 2016-05-21
    //[MobClick event:@"choice_pay" attributes:dict];
    [tempObserver loadStore:3];
}
-(void)pay4
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"25元",@"type",nil];
    ///dijk 2016-05-21
    //[MobClick event:@"choice_pay" attributes:dict];
    [tempObserver loadStore:4];
}
-(void)pay5
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"30元",@"type",nil];
    ///dijk 2016-05-21
    //[MobClick event:@"choice_pay" attributes:dict];
    [tempObserver loadStore:5];
}
-(void)pay6
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"60元",@"type",nil];
    ///dijk 2016-05-21
    //[MobClick event:@"choice_pay" attributes:dict];
    [tempObserver loadStore:6];
}
-(void)pay7
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"128元",@"type",nil];
    ///dijk 2016-05-21
    //[MobClick event:@"choice_pay" attributes:dict];
    [tempObserver loadStore:7];
}
-(void)pay8
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"258元",@"type",nil];
    ///dijk 2016-05-21
    //[MobClick event:@"choice_pay" attributes:dict];
    [tempObserver loadStore:8];
}
#pragma mark - UInAppDelegate
-(void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    
    int addGold=0;
    
    if (wasSuccessful)
    {

        if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_6]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"6元",@"type",nil];
            ///dijk 2016-05-21
            //[MobClick event:@"pay_ok" attributes:dict];
            addGold=500;
        }
        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_12]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"12元",@"type",nil];
            ///dijk 2016-05-21
            //[MobClick event:@"pay_ok" attributes:dict];
            addGold=1500;
        }
        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_18]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"18元",@"type",nil];
            ///dijk 2016-05-21
            //[MobClick event:@"pay_ok" attributes:dict];
            addGold=3500;
        }
        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_25]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"25元",@"type",nil];
            ///dijk 2016-05-21
            //[MobClick event:@"pay_ok" attributes:dict];
            addGold=8000;
        }
        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_30]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"30元",@"type",nil];
            ///dijk 2016-05-21
            //[MobClick event:@"pay_ok" attributes:dict];
            addGold=18000;
        }
        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_60]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"60元",@"type",nil];
            ///dijk 2016-05-21
            //[MobClick event:@"pay_ok" attributes:dict];
            addGold=40000;
        }
        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_128]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"128元",@"type",nil];
            ///dijk 2016-05-21
            //[MobClick event:@"pay_ok" attributes:dict];
            addGold=70000;
        }
        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_258]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"258元",@"type",nil];
            ///dijk 2016-05-21
            //[MobClick event:@"pay_ok" attributes:dict];
            addGold=120000;
        }
        [nowGoldAtlas setString:[NSString stringWithFormat:@"%07d",nowGold+addGold]];
        //判断是否有之前版本的记录存在
        if ([USave isHaveRecord:kRecordTypeForGameData]) {
            NSLog(@"aaa");
            RecordForGameData *temOldRecord=(RecordForGameData*)[[USave readGameData:kRecordTypeForGameData] bytes];
            
            RecordForGameData temNewRecord;
            temNewRecord.isRemoveAD=temOldRecord->isRemoveAD;
            temNewRecord.needEXP=temOldRecord->needEXP;
            temNewRecord.nowEXP=temOldRecord->nowEXP;
            temNewRecord.nowGold=temOldRecord->nowGold+addGold;
            temNewRecord.nowLevel=temOldRecord->nowLevel;
            temNewRecord.nowSP=temOldRecord->nowSP;
            
            NSData *temData=[NSData dataWithBytes:&temNewRecord length:sizeof(RecordForGameData)];
            [USave saveGameData:temData toFile:kRecordTypeForGameData];
        }else{
            if ([USave isHaveRecord:kRecordTypeForGameData2_2]) {
                NSLog(@"bbbb");
                RecordForGameData_2_2 *temOldRecord=(RecordForGameData_2_2*)[[USave readGameData:kRecordTypeForGameData2_2] bytes];
                
                RecordForGameData_2_2 temRecord;
                temRecord.nowGold=temOldRecord->nowGold+addGold;
                temRecord.isRemoveAD=temOldRecord->isRemoveAD;
                temRecord.needEXP=temOldRecord->needEXP;
                temRecord.nowEXP=temOldRecord->nowEXP;
                temRecord.nowLevel=temOldRecord->nowLevel;
                temRecord.nowSP_1=temOldRecord->nowSP_1;
                temRecord.nowSP_100=temOldRecord->nowSP_100;
                temRecord.nowSP_20=temOldRecord->nowSP_20;
                temRecord.nowSP_5=temOldRecord->nowSP_5;
                temRecord.nowSP_50=temOldRecord->nowSP_50;
                NSData *temData=[NSData dataWithBytes:&temRecord length:sizeof(RecordForGameData_2_2)];
                [USave saveGameData:temData toFile:kRecordTypeForGameData2_2];
            }else{
                NSLog(@"ccc");
                //不存在旧版和新版记录
                RecordForGameData_2_2 temRecord;
                temRecord.nowGold=1000+addGold;
                temRecord.isRemoveAD=NO;
                temRecord.needEXP=0;
                temRecord.nowEXP=0;
                temRecord.nowLevel=0;
                temRecord.nowSP_1=0;
                temRecord.nowSP_100=0;
                temRecord.nowSP_20=0;
                temRecord.nowSP_5=0;
                temRecord.nowSP_50=0;
                NSData *temData=[NSData dataWithBytes:&temRecord length:sizeof(RecordForGameData_2_2)];
                [USave saveGameData:temData toFile:kRecordTypeForGameData2_2];
            }
            
        }
        

		[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        // send out a notification for the failed transaction
		NSLog(@"交易失败后的处理");
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
        
    }
}
-(void)payOK
{
    [shopLayer resumeShopMenu];
}
-(void)payLose
{
    [shopLayer resumeShopMenu];
}
-(void)restore
{
    [shopLayer resumeShopMenu];
}
-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:tempObserver];
    [tempObserver release];
    tempObserver=nil;
    [super dealloc];
}
@end
