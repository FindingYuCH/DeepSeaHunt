//
//  GameSceneForGameCenter.m
//  DeepSeaHunt
//
//  Created by Unity on 12-8-21.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "GameSceneForGameCenter.h"

#define kTagDesk 1
#define kTagConnon 2
#define kTagOtherConnon 3
#define kTagForExitAffirmLayer 4
#define kTagForResultLayer 5
#define kTagForResultLayer_GoldLabel 6
#define kTagForResultLayer_ScoreLabel 7
#define kTagForResultLayer_RivalGoldLabel 8
#define kTagForResultLayer_RivalScoreLabel 9
#define kTagForResultLayer_Rim 10
#define kTagForExitAlert 11
#define kTagForMyHeadSprite 12
#define kTagForRivalHeadSprite 13
#define kTagForVSSprite 14
#define kTagForItemStart 15
#define kTagForPlayerInfoLoading 16
#define kTagForPlayerDisconnected 17

#define kFishNumControl 70
#define kScoreTurnToGoldPower 2
#define kGameTimer 300

#define kDeepForActionLayer 0
#define kDeepForUILayer 1
//网的大小


@implementation GameSceneForGameCenter
@synthesize isHost;
@synthesize playerID;
@synthesize gold;
@synthesize rivalGold;
@synthesize moneyForGold;
@synthesize fishSprireArr;

//金币
static int golds[] = { 1, 2, 4, 7, 10, 15, 20, 30, 40, 50 };
//积分
static int scores[] = { 1, 2, 4, 7, 12, 18, 25, 35, 45, 60 };
//能量
static int sps[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 };

static GameSceneForGameCenter *sharedGCScene;

double yu[] = {30,25,20,17,14,10,8,5,3,1};
+(CCScene*)scene
{
    CCScene *scene=[CCScene node];
    GameSceneForGameCenter *layer=[[GameSceneForGameCenter alloc] init];
    [scene addChild:layer];
    return scene;
}
+(GameSceneForGameCenter*)shardScene
{
    return sharedGCScene;
}
-(id)init
{
    if (self=[super init]) {
        [[GCHelper sharedInstance] authenticateLocalUser];
        sharedGCScene=self;
        
        RecordForgameActivate *activate= (RecordForgameActivate *)[USave readGameData:kRecordTypeForGameActivate];
        if (activate) {
            isActivate=activate->isActivate;
        }else{
            isActivate=false;
        }
        
        [self initData];
        [self checkDeviceType];
        playerID=kPlayerID_Null;
        isInitDone=false;
        otherPlayerIsInitDone=false;
        
        //初始化各个数组
        bulletArray=[[NSMutableArray alloc] init];
        fishNetArray=[[NSMutableArray alloc] init];
        fishArray=[[NSMutableArray alloc] init];
        fishSchoolArray=[[NSMutableArray alloc] init];
        fishNoUseTag=[[NSMutableArray alloc] init];
        bulletNoUseTag=[[NSMutableArray alloc] init];
        
        fishBatchNode=[CCSpriteBatchNode batchNodeWithFile:@"fish.png"];
        [self addChild:fishBatchNode z:0];
        
        [self initGameInfoLayer];
//      [self initGame];
        //test
//      isHost=true;
        [self scheduleUpdate];
    }
    return self;
}
-(void)initData{
    timer=kGameTimer;
    gold=rivalGold=showGold=showRivalGold=500;
    score=rivalScore=showScore=showRivalScore=0;
//  score=showScore=500;
//  rivalScore=showRivalScore=1000;
}
-(void)initRes
{
    moneyForGold=[[CCSprite spriteWithFile:@"game_money_icon.png"] retain];
    
    fishSprireArr=[[NSMutableArray alloc] init];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:
     @"fish.plist"];
    
    for (int i=0; i<10; i++) {
        CCSpriteFrame *fishFrame=[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"fish%d.png", i]];
        //        CCSprite *fish=[CCSprite spriteWithFile:[NSString stringWithFormat:@"fish%d.png",i]];
        [fishSprireArr addObject:fishFrame];
    }
//    for (int i=0; i<10; i++) {
//        CCSprite *fish=[CCSprite spriteWithFile:[NSString stringWithFormat:@"fish%d.png",i]];
//        [fishSprireArr addObject:fish];
//    }
}
-(void)initGameInfoLayer
{
    infoLayer=[CCLayer node];
    
    CCSprite *back;
    if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
        back=[CCSprite spriteWithFile:@"gc_info_back-iphone5.png"];
    }else{
        back=[CCSprite spriteWithFile:@"gc_info_back.png"];
    }
    
    back.anchorPoint=CGPointZero;
    back.position=CGPointZero;
    CCSprite *menuRim=[CCSprite spriteWithFile:@"gc_button_ground.png"];
    menuRim.position=ccp(back.contentSize.width/4*3,back.contentSize.height/8);
    CCSprite *temOther=[CCSprite spriteWithFile:@"gc_other_2.png"];
    temOther.position=ccp(menuRim.position.x+menuRim.contentSize.width/2,menuRim.position.y+menuRim.contentSize.height/2);
    temOther.anchorPoint=ccp(0.9f, 0.7f);
    
    CCMenuItem *item_start=[CCMenuItemImage itemWithNormalImage:@"gc_button_start.png" selectedImage:@"gc_button_start_.png" target:self selector:@selector(start:)];
    item_start.tag=kTagForItemStart;
    CCMenuItem *item_return=[CCMenuItemImage itemWithNormalImage:@"gc_button_back.png" selectedImage:@"gc_button_back_.png" target:self selector:@selector(buttonEventForReturn)];
    item_start.position=ccp(back.contentSize.width/4*3,back.contentSize.height/8);
    item_return.position=ccp(back.contentSize.width/8*7,back.contentSize.height/8*7);
    CCMenu *temMenu=[CCMenu menuWithItems:item_start, item_return,nil];
    
    temMenu.position=CGPointZero;
    
    [infoLayer addChild:back z:97 tag:1];
    [infoLayer addChild:menuRim z:98 tag:2];
    [infoLayer addChild:temMenu z:99 tag:3];
    [infoLayer addChild:temOther z:99 tag:5];
    [self addChild:infoLayer z:99];
    
}
-(void)start:(id)sender
{
    NSLog(@"点击开始游戏   开始寻找或邀请对手..");
    isActivate=true;
    if (isActivate) {
        //初始化游戏中心
        [self initGameCenter];

        //清除按钮
//        [sender removeFromParentAndCleanup:YES];
    }else {
        [self gameActivateAlert];
        //屏蔽开始按钮功能
        CCMenuItem *item=(CCMenuItem*)sender;
        item.isEnabled=NO;
    }    
}
//寻找玩家后  等候初始化完成
-(void)showPlayerInfoLoading
{
    //添加加载动画
    CGSize s=[[CCDirector sharedDirector] winSize];
    CCSprite *temLoading=[CCSprite node];
    CCAnimation *animation=[CCAnimation animation];
    animation.delayPerUnit=0.2f;
    
    for (int i=0; i<4; i++) {
        [animation addSpriteFrameWithFilename:[NSString stringWithFormat:@"gc_loading_%d.png",i+1]];
    }
    
    temLoading.position=ccp(s.width/4*3,s.height/8);
    id action = [CCAnimate actionWithAnimation: animation];
    [infoLayer addChild:temLoading z:99 tag:kTagForPlayerInfoLoading];
    [temLoading runAction:[CCRepeatForever actionWithAction:action]];
    
    //隐藏开始按钮
    CCMenuItem *item=(CCMenuItem *)[[infoLayer getChildByTag:3] getChildByTag:kTagForItemStart];
    item.isEnabled=NO;
    item.visible=NO;
    
}

-(void)deletePlayerInfoLoading
{
    CCNode *temNode=[infoLayer getChildByTag:kTagForPlayerInfoLoading];
    [temNode removeFromParentAndCleanup:YES];
}
-(void)setStartButtonEnableOK
{
    CCMenuItem *item=(CCMenuItem *)[[infoLayer getChildByTag:3] getChildByTag:kTagForItemStart];
    item.isEnabled=YES;
    item.visible=YES;
    
}

-(void)gameActivateAlert
{
    UIAlertView* dialog = [[UIAlertView alloc] init];  
    [dialog setDelegate:self];  
    [dialog setTag:301];
    [dialog setTitle:@"激活提示"];  
    [dialog setMessage:@"对不起，你还没有激活联网对战功能。确定需要现在激活吗？\n激活需0.99$"];  
    [dialog addButtonWithTitle:@"激活"];  
    [dialog addButtonWithTitle:@"取消"];  
    
    [dialog show];  
    [dialog release];  
}

-(void)playerDisconnectedAlert
{
    [self deletePlayerInfoLoading];
    [self setStartButtonEnableOK];
    
    UIAlertView* dialog = [[UIAlertView alloc] init];
    [dialog setDelegate:self];
    [dialog setTag:kTagForPlayerDisconnected];
    [dialog setTitle:@"系统提示"];
    [dialog setMessage:@"连接断开"];
    [dialog addButtonWithTitle:@"确定"];
//    [dialog addButtonWithTitle:@"取消"];
    
    [dialog show];
    [dialog release];
}

-(void)buttonEventForReturn
{
    CCScene *scene=[UWelcomeScene scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeBL transitionWithDuration:1 scene:scene]];
}
- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex  
{  
    NSLog(@"窗口的tag=%d",alert.tag);
    
    if (alert.tag==301) {//游戏激活 
        if(buttonIndex==0) {  //yes
            //      [USave deleteRecord:recordName];
//            isActivate=true;
//            UIView *view=[[CCDirector sharedDirector] view];
//            InAppPur *tempObserver = [[InAppPur alloc] init:view];
//            [[SKPaymentQueue defaultQueue] addTransactionObserver:tempObserver];
//            [tempObserver loadStore:9];
            
            NSLog(@"确定激活!");
        }  
        else{  //No
            NSLog(@"取消激活!");
            [self setStartButtonEnableOK];
        }  
    }else if (alert.tag==302) {//是否确定退出
        if(buttonIndex==0) {  //yes
            //      [USave deleteRecord:recordName];
            NSLog(@"确定退出!");
            [self sendExitMessage:kEndReasonPlayerExit];
        }  
        else{  //No
            NSLog(@"取消退出!");
        }  
    }else if (alert.tag==303) {//游戏结束提示
        if (buttonIndex==0) {
            NSLog(@"游戏结束信息确认.");
            //弹出结束统计框
        }        
    }else if (alert.tag==kTagForPlayerDisconnected){
        [self deletePlayerInfoLoading];
        [self setStartButtonEnableOK];
    }
    
}  
//激光
-(void)laser:(int)angle  point:(CGPoint)point
{
    laser=[[ULaser alloc] init:angle];
    [self addChild:laser z:4];
    laser.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];
    if (isHost) {
        [self schedule:@selector(checkLaserCollide) interval:0.5f];
    }
    if( CGPointEqualToPoint(laser.sourcePosition, CGPointZero ) )
        laser.position = point;
    [self scheduleOnce:@selector(turnGravity) delay:3];
    
}
//激光
-(void)rivalLaser:(int)angle  point:(CGPoint)point
{
    rivalLaser=[[ULaser alloc] init2:angle];
    [self addChild:rivalLaser z:4];
    rivalLaser.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];
    if (isHost) {
        [self schedule:@selector(checkRivalLaserCollide) interval:0.5f];
    }
    
    if( CGPointEqualToPoint(rivalLaser.sourcePosition, CGPointZero ) )
        rivalLaser.position = point;
    [self scheduleOnce:@selector(turnRivalGravity) delay:3];
}
-(void)checkLaserCollide
{
    if (connon.connonState==KStateLaser) {
        
        CGPoint laserPos=[connon getFireDot];
        NSMutableArray *toDelete=[[NSMutableArray alloc] init];
        //检测激光与鱼的碰撞
        for (UFish *fish in fishArray) {
            if (fish==nil) {
                continue;
            }
            if (fish.state==kFishStateDeath) {
                continue;
            }
            BOOL isCollide= [UGameTools rectangleCollide:CGRectMake(fish.position.x, fish.position.y, fish.contentSize.width, fish.contentSize.height) angle1:fish.rotation rect2:CGRectMake(laserPos.x, laserPos.y, 50, GAME_SCENE_SIZE.height*3) angle2:90-laser.angle];
            if (isCollide) {
                [toDelete addObject:fish];
            }
        }
        
        for (UFish *fish in toDelete) {
            if (fish==nil) {
                continue;
            }
            //发送鱼死亡消息
            [self sendMessageFishDeath:fish.fishID player:playerID];
            [fish death];
            fish.beKillPlayer=playerID;
            
            [self removeFish:fish isClean:NO];
        }
        
    }else {
        [self unschedule:_cmd];
    }
}
-(void)checkRivalLaserCollide
{
    if (otherConnon.connonState==KStateLaser) {
        
        CGPoint laserPos=[otherConnon getFireDot];
        NSMutableArray *toDelete=[[NSMutableArray alloc] init];
        //检测激光与鱼的碰撞
        for (UFish *fish in fishArray) {
            if (fish==nil) {
                continue;
            }
            if (fish.state==kFishStateDeath) {
                continue;
            }
            BOOL isCollide= [UGameTools rectangleCollide:CGRectMake(fish.position.x, fish.position.y, fish.contentSize.width, fish.contentSize.height) angle1:fish.rotation rect2:CGRectMake(laserPos.x, laserPos.y, 50, GAME_SCENE_SIZE.height*3) angle2:90-rivalLaser.angle];
            if (isCollide) {
                [toDelete addObject:fish];
            }
        }
        
        for (UFish *fish in toDelete) {
            if (fish==nil) {
                continue;
            }
            //发送鱼死亡消息
            [self sendMessageFishDeath:fish.fishID player:otherConnon.playerID];
            [fish death];
            fish.beKillPlayer=otherConnon.playerID;
            
            [self removeFish:fish isClean:NO];
        }
        
    }else {
        [self unschedule:_cmd];
    }
}
//type 网的大小
-(void)createBlast:(CGPoint)point type:(int)type
{
    ParticleEffectSelfMade* particle=[[ParticleEffectSelfMade alloc] init:200 type:type];
    [self addChild:particle z:4];
    particle.texture = [[CCTextureCache sharedTextureCache] addImage: @"bb.png"];
    particle.position = point;
}
-(void)turnGravity
{
    [laser setLife:0.5];
}
-(void)turnRivalGravity
{
    [rivalLaser setLife:0.5];
}
-(void)showPlayerHeadAndName
{
    CGSize s=[[CCDirector sharedDirector] winSize];
    
    CCSprite *temPKBack;
    if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
        temPKBack=[CCSprite spriteWithFile:@"gc_pk_back-iphone5.png"];
    }else{
        temPKBack=[CCSprite spriteWithFile:@"gc_pk_back.png"];
    }
    CCSprite *myHead=[CCSprite spriteWithFile:@"gc_head_frame.png"];
    CCSprite *myHead_=[self getLocalPayerHead];
    CCSprite *otherPlayerHead=[CCSprite spriteWithFile:@"gc_head_frame.png"];
    CCSprite *otherPlayerHead_=[self getRivalPlayerHead];
    
    CCSprite *myHeadEffect=[CCSprite spriteWithFile:@"gc_pk_effect.png"];
    CCSprite *rivalHeadEffect=[CCSprite spriteWithFile:@"gc_pk_effect.png"];
    myHeadEffect.anchorPoint=ccp(0.5f, 0.5f);
    rivalHeadEffect.anchorPoint=ccp(0.5f, 0.5f);
    myHeadEffect.position=ccp(myHead.contentSize.width/2, myHead.contentSize.height/2);
    rivalHeadEffect.position=ccp(otherPlayerHead.contentSize.width/2, otherPlayerHead.contentSize.height/2);
    [myHead addChild:myHeadEffect];
    [otherPlayerHead addChild:rivalHeadEffect];
    
    
    if (myHead_==nil) {
        myHead_=[CCSprite spriteWithFile:@"gc_default_head.png"];
    }
    if (otherPlayerHead_==nil) {
        otherPlayerHead_=[CCSprite spriteWithFile:@"gc_default_head.png"];
    }
    
    if (isPad) {
        myHead_.scale=200/myHead_.contentSize.width;
        otherPlayerHead_.scale=200/otherPlayerHead_.contentSize.width;
    }else{
        myHead_.scale=100/myHead_.contentSize.width;
        otherPlayerHead_.scale=100/otherPlayerHead_.contentSize.width;
    }
    
    myHead_.position=ccp(myHead.contentSize.width/2,myHead.contentSize.height/2);
    otherPlayerHead_.position=ccp(otherPlayerHead.contentSize.width/2,otherPlayerHead.contentSize.height/2);
    
    [myHead addChild:myHead_ z:-1];
    [otherPlayerHead addChild:otherPlayerHead_ z:-1];
    
    CCSprite *text_VS=[CCSprite spriteWithFile:@"gc_vs.png"];
    
    
    myHead.position=ccp(0-myHead.contentSize.width/2,s.height/2);
    otherPlayerHead.position=ccp(s.width+otherPlayerHead.contentSize.width/2,s.height/2);
//  text_V.position=ccp(s.width/2-text_V.contentSize.width/2,s.height+text_V.contentSize.height/2);
//  text_S.position=ccp(s.width/2+text_S.contentSize.width/2,0-text_S.contentSize.height/2);
    text_VS.position=ccp(s.width/2,s.height/2);
    text_VS.opacity=0;
    text_VS.scale=5;
    
    
    CCLabelTTF *temMyNameLabel=[CCLabelTTF labelWithString:name dimensions:CGSizeMake(250, 40) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:40];
    temMyNameLabel.anchorPoint=ccp(0.5f, 0);
    temMyNameLabel.position=ccp(myHead.position.x, myHead.position.y+myHead.contentSize.height+40);
    temMyNameLabel.position=ccp(myHead.contentSize.width/2, myHead.contentSize.height*1.1);
    
    
    CCLabelTTF *temRivalNameLabel=[CCLabelTTF labelWithString:otherPlayerName dimensions:CGSizeMake(250, 40) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:40];
    temRivalNameLabel.anchorPoint=ccp(0.5f, 0);
    temRivalNameLabel.position=ccp(otherPlayerHead.contentSize.width/2, otherPlayerHead.contentSize.height*1.1);
    
    [myHead addChild:temMyNameLabel z:99];
    [otherPlayerHead addChild:temRivalNameLabel z:99];
    
    id moveTo_head_1=[CCMoveTo actionWithDuration:0.2 position:CGPointMake(s.width/6, s.height/2)];
    id moveTo_head_2=[CCMoveTo actionWithDuration:0.2 position:CGPointMake(s.width/6*5, s.height/2)];
//    id moveTo_text_v=[CCMoveTo actionWithDuration:0.2 position:CGPointMake(text_V.position.x, s.height/2)];
//    id moveTo_text_s=[CCMoveTo actionWithDuration:0.2 position:CGPointMake(text_S.position.x, s.height/2)];
    
    id scale=[CCScaleTo actionWithDuration:0.3 scale:1];
    id opacity=[CCFadeIn actionWithDuration:0.3];
    
    
    [myHead runAction:moveTo_head_1];
    [otherPlayerHead runAction:moveTo_head_2];
    [text_VS runAction:[CCSpawn actions:scale,opacity, nil]];
    
//    [text_V runAction:moveTo_text_v];
//    [text_S runAction:moveTo_text_s];
    
    

    
    temPKBack.anchorPoint=CGPointZero;
    [infoLayer addChild:temPKBack z:99];
    [infoLayer addChild:myHead z:99 tag:kTagForMyHeadSprite];
    [infoLayer addChild:otherPlayerHead z:99 tag:kTagForRivalHeadSprite];
    [infoLayer addChild:text_VS z:99 tag:kTagForVSSprite];
    
    
    
    
    [self scheduleOnce:@selector(hideHead) delay:1.5f];
    
//    [infoLayer addChild:text_V z:2];
//    [infoLayer addChild:text_S z:2];
}
-(void)hideHead
{
    CCSprite *myHead=(CCSprite*)[infoLayer getChildByTag:kTagForMyHeadSprite];
    CCSprite *otherPlayerHead=(CCSprite*)[infoLayer getChildByTag:kTagForRivalHeadSprite];    
    
    CCSprite *text_VS=(CCSprite*)[infoLayer getChildByTag:kTagForVSSprite];
    
    CGSize s=[[CCDirector sharedDirector] winSize];
    
    id moveTo_head_1=[CCMoveTo actionWithDuration:0.2 position:CGPointMake(0-myHead.contentSize.width/2,s.height/2)];
    id moveTo_head_2=[CCMoveTo actionWithDuration:0.2 position:CGPointMake(s.width+otherPlayerHead.contentSize.width/2,s.height/2)];
    id opacity=[CCFadeOut actionWithDuration:0.3];
    
    [myHead runAction:moveTo_head_1];
    [otherPlayerHead runAction:moveTo_head_2];
    [text_VS runAction:opacity];
    [self scheduleOnce:@selector(hideLayer) delay:0.3];
}

-(void)hideLayer
{
    
    id opacity=[CCFadeOut actionWithDuration:0.3];
    id opacity2=[CCFadeOut actionWithDuration:0.3];
    id opacity3=[CCFadeOut actionWithDuration:0.3];
    
    CCSprite *back=(CCSprite*)[infoLayer getChildByTag:1];
    CCSprite *menuRim=(CCSprite*)[infoLayer getChildByTag:2];
    CCSprite *loading=(CCSprite*)[infoLayer getChildByTag:4];
//    
    [back runAction:opacity];
    [menuRim runAction:opacity2];
    [loading runAction:opacity3];
    
    [self scheduleOnce:@selector(deleteInfoLayer) delay:0.5];
//    
//    if (isHost) {
//        [self scheduleOnce:@selector(startGame) delay:0.5];
//    }    
}
-(void)deleteInfoLayer
{
    [self removeChild:infoLayer cleanup:YES];
    if (isHost) {
        [self startGame];
    }
}
-(void)startGame
{
    NSLog(@"开始游戏");
    [self setGameState:kGameStateGameIng];//状态更变为游戏中
    gameingState=kGameingStateNormal;
    [self schedule:@selector(createFishControl) interval:0.2f];
    [self sendGameBegin];
    //start the timer
    [self schedule:@selector(gameTimerUpdate) interval:1.0f];
    [self playBackGroundMusic];
}
-(void)endGame:(EndReason)reason
{
    if (gameState==kGameStateGameOver)return;
    [self setGameState:kGameStateGameOver];
    
    if (isHost) {        
        [self unschedule:@selector(createFishControl)];         //停止鱼的刷新
    }
    
    switch (reason) {
        case kEndReasonPlayerExit:
            break;
        default:
            break;
    }
}
-(void)fishTest
{
//        isHost=true;
    [self createFishSchool:kFishSchoolType_6 fishSpeed:4 fishAngle:60 fishPoint:ccp(200, 200)fishTag:100 playerID:playerID];

    //添加按钮
    
    CCMenuItem *itemSpeedUp=[CCMenuItemImage itemWithNormalImage:@"speed_up.png" selectedImage:nil target:self selector:@selector(fishSpeedUp)];
    CCMenuItem *itemRecover=[CCMenuItemImage itemWithNormalImage:@"recover.png" selectedImage:nil target:self selector:@selector(recoverFishSpeed)];
    
    itemSpeedUp.position=CGPointZero;
    itemRecover.position=ccp(itemSpeedUp.position.x+itemSpeedUp.contentSize.width+10,itemSpeedUp.position.y);
    
    CCMenu *menu=[CCMenu menuWithItems:itemSpeedUp,itemRecover, nil];
        
     
    menu.position=ccp(320,20);
    [self addChild:menu z:1];
    //        UFish *fish = [[UFish alloc] init:5 speed:2 angle:60 state:0 fishPoint:ccp(200, 200) scene:self];
    //        [self addChild:fish z:99 tag:1];    
    //       [self initFish];
}

-(void)recoverFishSpeed
{
    for (UFish *fish in fishArray) {
        fish.speed=fish.speed/2;
    }
}
-(void)fishSpeedUp
{
    for (UFish *fish in fishArray) {
        fish.speed=fish.speed*2;
    }
}
-(void)initGameCenter
{
    ourRandom = arc4random();
    AppController *delegate= (AppController *) [[UIApplication sharedApplication] delegate];                              
    [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.navController delegate:self];
    [self setGameState:kGameStateWaitingForMatch];
}
-(void)setGoldLabel:(int)num
{
    [myGoldLabel setString:[NSString stringWithFormat:@"%05d",num]];
}
-(void)setRivalGoldLabel:(int)num
{
    [rivalGoldLabel setString:[NSString stringWithFormat:@"%05d",num]];
}
-(void)setScoreLabel:(int)num
{
    [myScoreLabel setString:[NSString stringWithFormat:@"%05d",num]];
}
-(void)setRivalScoreLabel:(int)num
{
    [rivalScoreLabel setString:[NSString stringWithFormat:@"%05d",num]];
}
-(void)initGame
{
    [self initRes];
    //底层
    CCSprite *back;
    if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
        back=[CCSprite spriteWithFile:@"gamescene2-iphone5.png"];
    }else{
        back=[CCSprite spriteWithFile:@"gamescene2.png"];
    }
    back.anchorPoint=CGPointZero;
    [self addChild:back z:-1];
    
    if (isPad) {
        CCSprite *desk=[CCSprite spriteWithFile:@"desktops.png"];
        desk.anchorPoint=CGPointZero;
        desk.position=ccp(0,0);
        [self addChild:desk z:kDeepForUILayer tag:kTagDesk];
        //            self.anchorPoint=CGPointZero;
        //            self.position=ccp(32,64);
    }
    
    //==================UI层==================    
    //对方信息测试部分  [GCHelper sharedInstance].match.playerIDs

    //头像框
    CCSprite *temHead=[CCSprite spriteWithFile:@"gc_head_rim.png"];
    CCSprite *temOtherHead=[CCSprite spriteWithFile:@"gc_other_head_rim.png"];
    
    temHead.anchorPoint=CGPointZero;
    temHead.position=ccp(deviceValue.rimWidth,deviceValue.rimHeight);
    temOtherHead.anchorPoint=ccp(1.0f,1.0f);
    temOtherHead.position=ccp(deviceValue.sceneWidth+deviceValue.rimWidth,deviceValue.sceneHeight+deviceValue.rimHeight);
    
    [self addChild:temHead z:kDeepForUILayer];
    [self addChild:temOtherHead z:kDeepForUILayer];
    
    //获取头像
    [self setupHeadPhoto:otherPlayerID];
    //the head effect
    CCSprite *temHeadEffect=[CCSprite spriteWithFile:@"gc_head_effect.png"];
    CCSprite *temRivalHeadEffect=[CCSprite spriteWithFile:@"gc_rival_head_effect.png"];
    temHeadEffect.anchorPoint=CGPointZero;
    temRivalHeadEffect.anchorPoint=ccp(1.0f,1.0f);
    temHeadEffect.position=temHead.position;
    temRivalHeadEffect.position=temOtherHead.position;
    [self addChild:temHeadEffect z:kDeepForUILayer];
    [self addChild:temRivalHeadEffect z:kDeepForUILayer];
    
    
    //1.名称
    [self setupStringsWithOtherPlayerId:otherPlayerID];
    if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
        nameLabel=[CCLabelTTF labelWithString:name dimensions:CGSizeMake(50,13)//50  13
                                    alignment:CCTextAlignmentCenter fontName:@"Marker Felt" fontSize:12];
        otherPlayerNameLabel=[CCLabelTTF labelWithString:otherPlayerName dimensions:CGSizeMake(50,13)
                                               alignment:CCTextAlignmentCenter fontName:@"Marker Felt" fontSize:12];
        nameLabel.anchorPoint=ccp(0.5f, 0.5f);
        otherPlayerNameLabel.anchorPoint=ccp(0.5f, 0.5f);
        
        nameLabel.position=ccp(65,12);
        otherPlayerNameLabel.position=ccp(30,27);
    }else if (isPad) {
        nameLabel=[CCLabelTTF labelWithString:name dimensions:CGSizeMake(98,26)//50  13
                                    alignment:CCTextAlignmentCenter fontName:@"Marker Felt" fontSize:18];
        otherPlayerNameLabel=[CCLabelTTF labelWithString:otherPlayerName dimensions:CGSizeMake(98,26)
                                               alignment:CCTextAlignmentCenter fontName:@"Marker Felt" fontSize:18];
        nameLabel.anchorPoint=ccp(0.5f, 0.5f);
        otherPlayerNameLabel.anchorPoint=ccp(0.5f, 0.5f);
        
        nameLabel.position=ccp(130,21);
        otherPlayerNameLabel.position=ccp(60,51);
    }else{
        nameLabel=[CCLabelTTF labelWithString:name dimensions:CGSizeMake(50,13)//50  13
                                    alignment:CCTextAlignmentCenter fontName:@"Marker Felt" fontSize:12];
        otherPlayerNameLabel=[CCLabelTTF labelWithString:otherPlayerName dimensions:CGSizeMake(50,13)
                                               alignment:CCTextAlignmentCenter fontName:@"Marker Felt" fontSize:12];
        nameLabel.anchorPoint=ccp(0.5f, 0.5f);
        otherPlayerNameLabel.anchorPoint=ccp(0.5f, 0.5f);
        
        nameLabel.position=ccp(65,12);
        otherPlayerNameLabel.position=ccp(30,27);
    }
    
    
//    [temHead addChild:myHead2];
//    [temOtherHead addChild:otherPlayerHead2];
    
    [temHead addChild:nameLabel];
    [temOtherHead addChild:otherPlayerNameLabel];
    
    //炮台底框
    CCSprite *temConnonBack=[CCSprite spriteWithFile:@"gc_connon_back.png"];
    CCSprite *temOtherConnonBack=[CCSprite spriteWithFile:@"gc_connon_back.png"];
    
    temConnonBack.anchorPoint=CGPointZero;
    temConnonBack.position=ccpAdd(temHead.position,ccp(temHead.contentSize.width,0));
    temOtherConnonBack.anchorPoint=ccp(1.0f,1.0f);
    temOtherConnonBack.position=ccpSub(temOtherHead.position, ccp(temOtherHead.contentSize.width,temOtherConnonBack.contentSize.height));
    temOtherConnonBack.scaleY=-1;
    [self addChild:temConnonBack z:kDeepForUILayer];
    [self addChild:temOtherConnonBack z:kDeepForUILayer];    

    //炮塔等级控制按钮  退出按钮  
    CCMenuItemImage *itemAdd=[CCMenuItemImage itemWithNormalImage:@"gc_b_add.png" selectedImage:@"gc_b_add_.png" target:self selector:@selector(levelAdd)];
    CCMenuItemImage *itemDec=[CCMenuItemImage itemWithNormalImage:@"gc_b_dec.png" selectedImage:@"gc_b_dec_.png" target:self selector:@selector(levelDec)];
    CCMenuItemImage *itemRivalAdd=[CCMenuItemImage itemWithNormalImage:@"gc_b_add.png" selectedImage:@"gc_b_add_.png"];
    CCMenuItemImage *itemRivalDec=[CCMenuItemImage itemWithNormalImage:@"gc_b_dec.png" selectedImage:@"gc_b_dec_.png"];
    CCMenuItem *itemExit=[CCMenuItemImage itemWithNormalImage:@"gc_b_exit.png" selectedImage:@"gc_b_exit_.png" target:self selector:@selector(showExitAffirm)];//exit
    CCMenuItem *itemPhoto=[CCMenuItemImage itemWithNormalImage:@"gc_photo.png" selectedImage:@"gc_photo_.png" target:self selector:@selector(getPhoto)];
    if (isPad) {
        itemAdd.anchorPoint=CGPointZero;
        itemDec.anchorPoint=CGPointZero;
        itemDec.position=ccp(230,64);
        itemAdd.position=ccp(400,64);

        itemRivalAdd.anchorPoint=ccp(1.0f, 1.0f);
        itemRivalDec.anchorPoint=ccp(1.0f, 1.0f);
        itemRivalAdd.position=ccp(797,704);
        itemRivalDec.position=ccp(624,704);
        
        itemExit.anchorPoint=ccp(1.0f,0);
        itemExit.position=ccp(deviceValue.sceneWidth+deviceValue.rimWidth,deviceValue.rimHeight);
        
        itemPhoto.anchorPoint=ccp(1.0f,1.0f);
        itemPhoto.position=ccp(90, 700);
    }else{
        itemAdd.anchorPoint=CGPointZero;
        itemDec.anchorPoint=CGPointZero;
        itemAdd.position=ccp(180,0);
        itemDec.position=ccp(100,0);
        
        itemRivalAdd.anchorPoint=ccp(1.0f, 1.0f);
        itemRivalDec.anchorPoint=ccp(1.0f, 1.0f);
        itemRivalAdd.position=ccp(380,320);
        itemRivalDec.position=ccp(300,320);
        
        itemExit.anchorPoint=ccp(1.0f,0);
        itemExit.position=ccp(deviceValue.sceneWidth+deviceValue.rimWidth,deviceValue.rimHeight);
        
        itemPhoto.anchorPoint=ccp(1.0f,1.0f);
        itemPhoto.position=ccp(25, 320);
    }
    CCMenu *temMenu2=[CCMenu menuWithItems:itemAdd,itemDec,itemRivalAdd,itemRivalDec,itemExit,itemPhoto, nil];
    temMenu2.anchorPoint=CGPointZero;
    temMenu2.position=CGPointZero;
    [self addChild:temMenu2 z:kDeepForUILayer];

    
    //炮台
    if (playerID==kPlayerID_Host) {
        
        connon=[[UConnon alloc] init:kPlayerID_Host ];
        otherConnon=[[UConnon alloc] init:kPlayerID_2 ];
        
    }else {
        connon=[[UConnon alloc] init:kPlayerID_2 ];
        otherConnon=[[UConnon alloc] init:kPlayerID_Host ];
    }
    
    
    
    connon.position=ccpAdd(temConnonBack.position, ccp(temConnonBack.contentSize.width/2,temConnonBack.contentSize.height/2));
    
    otherConnon.position=ccpSub(temOtherConnonBack.position, ccp(temOtherConnonBack.contentSize.width/2, -temOtherConnonBack.contentSize.height/2));
    
    otherConnon.scaleY=-1;
    otherConnon.isScaleY=true;
    
    
    [self addChild:connon z:1 tag:kTagConnon];
    [self addChild:otherConnon z:1 tag:kTagOtherConnon];
    
    //装饰
    CCSprite *temOther_1=[CCSprite spriteWithFile:@"gc_other_1.png"];
    if (isPad) {
        temOther_1.anchorPoint=CGPointZero;
        temOther_1.position=ccp(450, 64);
    }else{
        temOther_1.anchorPoint=CGPointZero;
        temOther_1.position=ccp(205, 0);
    }
    [self addChild:temOther_1 z:kDeepForUILayer];
    //时间倒计时
    CCSprite *temTimer=[CCSprite spriteWithFile:@"gc_timer.png"];
    if (isPad) {
        temTimer.anchorPoint=ccp(1.0f, 1.0f);
        temTimer.position=ccp(570, 704);
    }else{
        temTimer.anchorPoint=ccp(1.0f, 1.0f);
        temTimer.position=ccp(270, 320);
    }
    [self addChild:temTimer z:kDeepForUILayer];
    //时间数字
    
    if (isPad) {
        timerLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%02d:%02d",timer/60,timer%60] charMapFile:@"gc_timer_num.png" itemWidth:20 itemHeight:30 startCharMap:'0'];
        timerLabel.anchorPoint=ccp(0.5f, 0.5f);
        timerLabel.position=ccp(66, 62);
    }else{
        timerLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%02d:%02d",timer/60,timer%60] charMapFile:@"gc_timer_num.png" itemWidth:10 itemHeight:15 startCharMap:'0'];
        timerLabel.anchorPoint=ccp(0.5f, 0.5f);
        timerLabel.position=ccp(33, 32);
    }
    [temTimer addChild:timerLabel];
    
    //金币框   积分框
    CCSprite *temGoldRim=[CCSprite spriteWithFile:@"gc_gold_rim.png"];
    CCSprite *temScoreRim=[CCSprite spriteWithFile:@"gc_score_rim.png"];
    CCSprite *temRivalGoldRim=[CCSprite spriteWithFile:@"gc_gold_rim.png"];
    CCSprite *temRivalScoreRim=[CCSprite spriteWithFile:@"gc_score_rim.png"];
    if (isPad) {
        temGoldRim.anchorPoint=CGPointZero;
        temGoldRim.position=ccp(580, 64);
        temScoreRim.anchorPoint=CGPointZero;
        temScoreRim.position=ccp(740, 64);
        
        temRivalGoldRim.anchorPoint=ccp(1.0f, 1.0f);
        temRivalGoldRim.position=ccp(435, 695);
        temRivalScoreRim.anchorPoint=ccp(1.0f, 1.0f);
        temRivalScoreRim.position=ccp(260, 700);
    }else{
        temGoldRim.anchorPoint=CGPointZero;
        temGoldRim.position=ccp(270, 0);
        temScoreRim.anchorPoint=CGPointZero;
        temScoreRim.position=ccp(350, 0);
        
        temRivalGoldRim.anchorPoint=ccp(1.0f, 1.0f);
        temRivalGoldRim.position=ccp(198, 318);
        temRivalScoreRim.anchorPoint=ccp(1.0f, 1.0f);
        temRivalScoreRim.position=ccp(110, 320);
    }

    [self addChild:temGoldRim z:kDeepForUILayer];
    [self addChild:temScoreRim z:kDeepForUILayer];
    [self addChild:temRivalGoldRim z:kDeepForUILayer];
    [self addChild:temRivalScoreRim z:kDeepForUILayer];
    
    //积分
    if (isPad) {
        myGoldLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%05d",gold] charMapFile:@"gc_gold_score_num.png" itemWidth:20 itemHeight:20 startCharMap:'0'];
        myScoreLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%05d",score] charMapFile:@"gc_gold_score_num.png" itemWidth:20 itemHeight:20 startCharMap:'0'];
        rivalGoldLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%05d",rivalGold] charMapFile:@"gc_gold_score_num.png" itemWidth:20 itemHeight:20 startCharMap:'0'];
        rivalScoreLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%05d",rivalScore] charMapFile:@"gc_gold_score_num.png" itemWidth:20 itemHeight:20 startCharMap:'0'];
    }else{
        myGoldLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%05d",gold] charMapFile:@"gc_gold_score_num.png" itemWidth:10 itemHeight:10 startCharMap:'0'];
        myScoreLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%05d",score]  charMapFile:@"gc_gold_score_num.png" itemWidth:10 itemHeight:10 startCharMap:'0'];
        rivalGoldLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%05d",rivalGold] charMapFile:@"gc_gold_score_num.png" itemWidth:10 itemHeight:10 startCharMap:'0'];
        rivalScoreLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%05d",rivalScore] charMapFile:@"gc_gold_score_num.png" itemWidth:10 itemHeight:10 startCharMap:'0'];
    }
    
    myGoldLabel.anchorPoint=ccp(0.5f, 0.5f);
    myScoreLabel.anchorPoint=ccp(0.5f, 0.5f);
    rivalGoldLabel.anchorPoint=ccp(0.5f, 0.5f);
    rivalScoreLabel.anchorPoint=ccp(0.5f, 0.5f);
    
    myGoldLabel.position=ccp(temGoldRim.contentSize.width/2, temGoldRim.contentSize.height/2);
    myScoreLabel.position=ccp(temScoreRim.contentSize.width/2, temScoreRim.contentSize.height/2);
    rivalGoldLabel.position=ccp(temRivalGoldRim.contentSize.width/2, temRivalGoldRim.contentSize.height/2);
    rivalScoreLabel.position=ccp(temRivalScoreRim.contentSize.width/2, temRivalScoreRim.contentSize.height/2);
    
    
    [temGoldRim addChild:myGoldLabel];
    [temScoreRim addChild:myScoreLabel];
    [temRivalGoldRim addChild:rivalGoldLabel];
    [temRivalScoreRim addChild:rivalScoreLabel];
    
    
    
    //初始化游戏中心
//    [self initGameCenter];
    
    //初始化炮塔
    //        isHost=true;
    //        playerID=kPlayerID_Host;
    //        [self initConnon2];
    
    //鱼的测试
    //        [self fishTest];
    
    
    
    self.isTouchEnabled=YES;
    //测试
    //        [self schedule:@selector(upData) interval:0.1 ];
    //        [self scheduleUpdate];
    //      [self schedule:@selector(createFishControl) interval:0.4];
    
    //炮塔
//    [self initConnon2];
    
    //玩家信息
    
    //1.名称
    nameLabel=[CCLabelTTF labelWithString:name dimensions:CGSizeMake(80,22)
               alignment:CCTextAlignmentLeft fontName:@"Marker Felt" fontSize:18];
    otherPlayerNameLabel=[CCLabelTTF labelWithString:name dimensions:CGSizeMake(80,22)
               alignment:CCTextAlignmentLeft fontName:@"Marker Felt" fontSize:18];
    
    nameLabel.position=ccp(300,300);
    otherPlayerNameLabel.position=ccp(otherConnon.position.x-otherPlayerNameLabel.contentSize.width,otherConnon.position.y-otherPlayerNameLabel.contentSize.height);
    
//    [self addChild:nameLabel];
//    [self addChild:otherPlayerNameLabel];
    
    //2.金币
//    NSString *money=[NSString stringWithFormat:@"%d",gold];
//    goldLabel=[CCLabelTTF labelWithString:money dimensions:CGSizeMake(80,22) 
//                                alignment:CCTextAlignmentLeft fontName:@"Marker Felt" fontSize:18];
    
    
    //3.积分
    
    //4.头像
    
//    [self getRivalPlayerInfo];
    
}
-(void)levelAdd
{
    connon.level++;
    if (connon.level>kLevel_7) {
        connon.level=kLevel_1;
    }
    [connon setConnonLevel:connon.level];
    
    [self sendTurnConnonLevel:connon.level playerID:playerID];
    //    NSLog(@"等级增加=%d",connon.level);
}
-(void)levelDec
{
    connon.level--;
    if (connon.level<kLevel_1) {
        connon.level=kLevel_7;
    }
    [connon setConnonLevel:connon.level];
     [self sendTurnConnonLevel:connon.level playerID:playerID];
    //    NSLog(@"等级降低=%d",connon.level);
}
-(void)gameTimerUpdate
{
    timer--;
    if(isHost)[self sendTimerRenewMessage:timer];
    
    [timerLabel setString:[NSString stringWithFormat:@"%02d:%02d",timer/60,timer%60] ];
    
    if (timer<=0) {
        //停止
        [self unschedule:_cmd];

        //判断双方的金币
//         [self showGameResult];
    }
}
-(void)exit
{
    //退出的2次确认
    UIAlertView* dialog = [[UIAlertView alloc] init];  
    [dialog setDelegate:self];  
    [dialog setTag:302];
    [dialog setTitle:@"是否确定退出?"];  
    [dialog setMessage:@"确定退出 本次游戏便为失败!"];  
    [dialog addButtonWithTitle:@"确定"];  
    [dialog addButtonWithTitle:@"取消"];  
    
    [dialog show];  
    [dialog release];  
    
//    [self sendExitMessage:kEndReasonPlayerExit];
}
-(void)getPhoto
{
//    [self showGameResult];
//    [self showPlayerExitAlert];
    // 设定截图大小
    CCRenderTexture  *target = [CCRenderTexture renderTextureWithWidth:GAME_SCENE_SIZE.width height:GAME_SCENE_SIZE.height];
    [target begin];
    
    // 添加需要截取的CCNode
    [self visit];
    [target end];
    
    UIImageWriteToSavedPhotosAlbum([target getUIImage], self, nil, nil);//getUIImageFromBuffer
    
    CCLayer *temLayer=[CCLayerColor layerWithColor:ccc4(255, 255, 255, 255)];
    id fadeOut=[CCFadeOut actionWithDuration:0.5];
    id callF=[CCCallFuncN actionWithTarget:self selector:@selector(deletePhotoTem:)];
    [temLayer runAction:[CCSequence actions:fadeOut,callF, nil]];
    [self addChild:temLayer z:99];
}
-(void)deletePhotoTem:(id)sender
{
    [sender removeFromParentAndCleanup:YES];
    //    [sender release];
}
-(void)showExitAffirm
{
    CCLayer *exitAffirmLayer=[CCLayer node];
    CCSprite *temRim=[CCSprite spriteWithFile:@"gc_exit_affirm_rim.png"];
    temRim.position=ccp(GAME_SCENE_SIZE.width/2, GAME_SCENE_SIZE.height*0.55);
    [exitAffirmLayer addChild:temRim];
    
    
    CCMenuItem *itemAffirm=[CCMenuItemImage itemWithNormalImage:@"gc_affirm.png" selectedImage:@"gc_affirm_.png" target:self selector:@selector(buttonEventForExitAffirm)];
    CCMenuItem *itemCancel=[CCMenuItemImage itemWithNormalImage:@"gc_cancel.png" selectedImage:@"gc_cancel_.png" target:self selector:@selector(buttonEventForExitCancel)];
    if (isPad) {
        itemAffirm.position=ccp(160, 80);
        itemCancel.position=ccp(370, 80);
    }else{
        itemAffirm.position=ccp(80, 40);
        itemCancel.position=ccp(180, 40);
    }
    
    
    
    CCMenu *temMenu=[CCMenu menuWithItems:itemAffirm,itemCancel, nil];
    temMenu.anchorPoint=CGPointZero;
    temMenu.position=CGPointZero;
    [temRim addChild:temMenu];
    
    [self addChild:exitAffirmLayer z:99 tag:kTagForExitAffirmLayer];
    self.isTouchEnabled=NO;
}
-(void)buttonEventForExitAffirm
{
    [self sendExitMessage:kEndReasonPlayerExit];
    CCScene *scene=[UWelcomeScene scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeBL transitionWithDuration:1 scene:scene]];
}
-(void)buttonEventForExitCancel
{
    CCLayer *layer=(CCLayer *)[self getChildByTag:kTagForExitAffirmLayer];
    [layer removeFromParentAndCleanup:YES];
    self.isTouchEnabled=YES;
}
//show game result  win/lose ,and weibo
-(void)showGameResult
{
    self.isTouchEnabled=NO;
    CCLayer *resultLayer=[CCLayer node];
    [self addChild:resultLayer z:99 tag:kTagForResultLayer];
    
    CCSprite *temRim=[CCSprite spriteWithFile:@"gc_result_frame.png"];
    temRim.position=ccp(GAME_SCENE_SIZE.width/2, GAME_SCENE_SIZE.height/2);
    [resultLayer addChild:temRim z:0 tag:kTagForResultLayer_Rim];
    
    CCLabelTTF *temNameLabel,*temRivalNameLabel;
    CCLabelAtlas *temGoldLabel,*temRivalGoldLabel,*temScoreLabel,*temRivalScoreLabel;
    
    if (isPad) {
        temNameLabel=[CCLabelTTF labelWithString:name dimensions:CGSizeMake(180, 40) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:25];
        temRivalNameLabel=[CCLabelTTF labelWithString:otherPlayerName dimensions:CGSizeMake(180, 40) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:25];
        
        temGoldLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%d",gold] charMapFile:@"gc_result_gold_num.png" itemWidth:26 itemHeight:25 startCharMap:'0'];//abs(gold-rivalGold)
        temRivalGoldLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%d",rivalGold] charMapFile:@"gc_result_gold_num.png" itemWidth:26 itemHeight:25 startCharMap:'0'];
        
        temScoreLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%d",score] charMapFile:@"gc_result_gold_num.png" itemWidth:26 itemHeight:25 startCharMap:'0'];//abs(gold-rivalGold)
        temRivalScoreLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%d",rivalScore] charMapFile:@"gc_result_gold_num.png" itemWidth:26 itemHeight:25 startCharMap:'0'];
        
        
        temNameLabel.position=ccp(188, 270);
        temRivalNameLabel.position=ccp(400, 270);
        
        temScoreLabel.anchorPoint=ccp(0.5f, 0.5f);
        temRivalScoreLabel.anchorPoint=ccp(0.5f, 0.5f);
        temScoreLabel.position=ccp(220, 220);
        temRivalScoreLabel.position=ccp(430, 220);
        
        
        temGoldLabel.anchorPoint=ccp(0.5f, 0.5f);
        temRivalGoldLabel.anchorPoint=ccp(0.5f, 0.5f);
        temGoldLabel.position=ccp(220, 140);
        temRivalGoldLabel.position=ccp(430, 140);
        
    }else{
        temNameLabel=[CCLabelTTF labelWithString:name dimensions:CGSizeMake(90, 20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:12];
        temRivalNameLabel=[CCLabelTTF labelWithString:otherPlayerName dimensions:CGSizeMake(90, 20) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:12];
        
        temGoldLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%d",9999] charMapFile:@"gc_result_gold_num.png" itemWidth:13 itemHeight:13 startCharMap:'0'];//abs(gold-rivalGold)
        temRivalGoldLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%d",100] charMapFile:@"gc_result_gold_num.png" itemWidth:13 itemHeight:13 startCharMap:'0'];
        
        temScoreLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%d",9999] charMapFile:@"gc_result_gold_num.png" itemWidth:13 itemHeight:13 startCharMap:'0'];//abs(gold-rivalGold)
        temRivalScoreLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%d",100] charMapFile:@"gc_result_gold_num.png" itemWidth:13 itemHeight:13 startCharMap:'0'];
        
        temNameLabel.position=ccp(94, 135);
        temRivalNameLabel.position=ccp(200, 135);
        
        temScoreLabel.anchorPoint=ccp(0.5f, 0.5f);
        temRivalScoreLabel.anchorPoint=ccp(0.5f, 0.5f);
        temScoreLabel.position=ccp(110, 108);
        temRivalScoreLabel.position=ccp(215, 108);
        
        temGoldLabel.anchorPoint=ccp(0.5f, 0.5f);
        temRivalGoldLabel.anchorPoint=ccp(0.5f, 0.5f);
        temGoldLabel.position=ccp(110, 68);
        temRivalGoldLabel.position=ccp(220, 68);
    }
    
    [temRim addChild:temNameLabel];
    [temRim addChild:temRivalNameLabel];
    [temRim addChild:temGoldLabel z:0 tag:kTagForResultLayer_GoldLabel];
    [temRim addChild:temRivalGoldLabel z:0 tag:kTagForResultLayer_RivalGoldLabel];
    [temRim addChild:temScoreLabel z:0 tag:kTagForResultLayer_ScoreLabel];
    [temRim addChild:temRivalScoreLabel z:0 tag:kTagForResultLayer_RivalScoreLabel];
    
    CCMenuItem *itemAffirm=[CCMenuItemImage itemWithNormalImage:@"gc_result_affirm.png" selectedImage:@"gc_result_affirm_.png" disabledImage:@"gc_result_affirm__.png" target:self selector:@selector(buttonEventForResultAffirm)];
    CCMenuItem *itemWeibo=[CCMenuItemImage itemWithNormalImage:@"gc_result_weibo.png" selectedImage:@"gc_result_weibo_.png" disabledImage:@"gc_result_weibo__.png" target:self selector:@selector(buttonEventForResultWeibo)];
    
    itemAffirm.isEnabled=NO;
    itemWeibo.isEnabled=NO;
    
    if (isPad) {
        itemAffirm.position=ccp(200, 80);
        itemWeibo.position=ccp(400, 80);
    }else{
        itemAffirm.position=ccp(100, 35);
        itemWeibo.position=ccp(200, 35);
    }
    
    
    itemWeibo_=itemWeibo;
    itemAffirm_=itemAffirm;
    
    CCMenu *temMenu=[CCMenu menuWithItems:itemAffirm,itemWeibo, nil];
    temMenu.anchorPoint=CGPointZero;
    temMenu.position=CGPointZero;
    [temRim addChild:temMenu];
    
    [self schedule:@selector(upDateResult) interval:0.01f];
}
-(void)upDateResult
{
    CCLayer *layer=(CCLayer*)[self getChildByTag:kTagForResultLayer];
    CCSprite *temRim=(CCSprite *)[layer getChildByTag:kTagForResultLayer_Rim];
    
    if (score<=0&&rivalScore<=0) {

        CCLabelAtlas *temGoldLabel=(CCLabelAtlas*)[temRim getChildByTag:kTagForResultLayer_GoldLabel];
        CCLabelAtlas *temRivalGoldLabel=(CCLabelAtlas*)[temRim getChildByTag:kTagForResultLayer_RivalGoldLabel];
        CCLabelAtlas *temScoreLabel=(CCLabelAtlas*)[temRim getChildByTag:kTagForResultLayer_ScoreLabel];
        CCLabelAtlas *temRivalScoreLabel=(CCLabelAtlas*)[temRim getChildByTag:kTagForResultLayer_RivalScoreLabel];;
        
        [temGoldLabel setString:[NSString stringWithFormat:@"%d",gold]];
        [temRivalGoldLabel setString:[NSString stringWithFormat:@"%d",rivalGold]];
        [temScoreLabel setString:[NSString stringWithFormat:@"%d",score]];
        [temRivalScoreLabel setString:[NSString stringWithFormat:@"%d",rivalScore]];
        
        [self unschedule:_cmd];
        itemWeibo_.isEnabled=YES;
        itemAffirm_.isEnabled=YES;
        //判断
        CCSprite *temResult;
        if (gold>rivalGold) {
            temResult=[CCSprite spriteWithFile:@"gc_result_win.png"];
        }else if (gold<rivalGold){
            temResult=[CCSprite spriteWithFile:@"gc_result_lose.png"];
        }else{
            temResult=[CCSprite spriteWithFile:@"gc_result_draw.png"];
        }
        temResult.rotation=-16;
        temResult.scale=3;
        temResult.opacity=0;
        if (isPad) {
            temResult.position=ccp(300,320);
        }else{
            temResult.position=ccp(150,150);
        }
        
        [temRim addChild:temResult z:1];
        
        id actionFadein=[CCFadeIn actionWithDuration:0.2f];
        id actionScale=[CCScaleTo actionWithDuration:0.2f scale:1.0f];
        
        [temResult runAction:[CCSpawn actions:actionFadein,actionScale, nil]];
        
        return;
    }
    if (score>10) {
        score-=4;
        gold+=kScoreTurnToGoldPower*4;
    }else if (score>0) {
        score--;
        gold+=kScoreTurnToGoldPower;
    }
    if (rivalScore>10) {
        rivalScore-=4;
        rivalGold+=kScoreTurnToGoldPower*4;
    }else if (rivalScore>0) {
        rivalScore--;
        rivalGold+=kScoreTurnToGoldPower;
    }
        
    CCLabelAtlas *temGoldLabel=(CCLabelAtlas*)[temRim getChildByTag:kTagForResultLayer_GoldLabel];
    CCLabelAtlas *temRivalGoldLabel=(CCLabelAtlas*)[temRim getChildByTag:kTagForResultLayer_RivalGoldLabel];
    CCLabelAtlas *temScoreLabel=(CCLabelAtlas*)[temRim getChildByTag:kTagForResultLayer_ScoreLabel];
    CCLabelAtlas *temRivalScoreLabel=(CCLabelAtlas*)[temRim getChildByTag:kTagForResultLayer_RivalScoreLabel];;
    
    [temGoldLabel setString:[NSString stringWithFormat:@"%d",gold]];
    [temRivalGoldLabel setString:[NSString stringWithFormat:@"%d",rivalGold]];
    [temScoreLabel setString:[NSString stringWithFormat:@"%d",score]];
    [temRivalScoreLabel setString:[NSString stringWithFormat:@"%d",rivalScore]];
}

-(void)buttonEventForResultAffirm
{
    if (score==0&&rivalScore==0) {
        CCLayer *layer=(CCLayer *)[self getChildByTag:kTagForResultLayer];
        [layer removeFromParentAndCleanup:YES];
        self.isTouchEnabled=YES;
        gameingState=kGameingStateNormal;
        [self unschedule:@selector(upDateResult)];
        //返回主菜单
        CCScene *scene=[UWelcomeScene scene];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeBL transitionWithDuration:1 scene:scene]];
    }else{
        gold+=score*kScoreTurnToGoldPower;
        score=0;
        rivalGold+=rivalScore*kScoreTurnToGoldPower;
        rivalScore=0;
    }
}
-(void)buttonEventForResultWeibo
{
    self.isTouchEnabled=YES;
    [self share];
}
-(void)initConnon
{    
    if (isHost) {
        
        connon=[[UConnon alloc] init:kPlayerID_Host ];
        otherConnon=[[UConnon alloc] init:kPlayerID_2 ];
       
        connon.position=ccp(deviceValue.sceneWidth/4-connon.contentSize.width/2+deviceValue.rimWidth,deviceValue.rimHeight);
        otherConnon.position=ccp(deviceValue.sceneWidth/4*3-otherConnon.contentSize.width/2+deviceValue.rimWidth,deviceValue.sceneHeight-deviceValue.rimHeight);
        
        otherConnon.scaleY=-1;
        otherConnon.isScaleY=true;
        NSLog(@" 位置对比:  预计=%f    结果=%f",deviceValue.sceneWidth/4*3-otherConnon.contentSize.width/2+deviceValue.rimWidth,otherConnon.position.x);
        
    }else {
        
        connon=[[UConnon alloc] init:kPlayerID_2 ];
        otherConnon=[[UConnon alloc] init:kPlayerID_Host ];
        
        connon.position=ccp(deviceValue.sceneWidth/4*3-connon.contentSize.width/2+deviceValue.rimWidth,deviceValue.sceneHeight-deviceValue.rimHeight);
        otherConnon.position=ccp(deviceValue.sceneWidth/4-otherConnon.contentSize.width/2+deviceValue.rimWidth,deviceValue.rimHeight);
        
        connon.scaleY=-1;
        connon.isScaleY=true;
        
        CCRotateTo *rotateTo=[CCRotateTo actionWithDuration:0 angle:180];
        [self runAction:rotateTo];

    }
    
    [self addChild:connon z:1 tag:kTagConnon];
    [self addChild:otherConnon z:1 tag:kTagOtherConnon];
    
}
-(NSString*)getPlayerName:(NSString *)pid
{
    GKPlayer *player = [[GCHelper sharedInstance].playersDict objectForKey:pid];
    if (player==nil) {
        return @"玩家不存在";
    }
    return player.alias;
}
-(void)initConnon2
{
    
    if (playerID==kPlayerID_Host) {
        
        connon=[[UConnon alloc] init:kPlayerID_Host ];
        otherConnon=[[UConnon alloc] init:kPlayerID_2 ];
        
    }else {
        connon=[[UConnon alloc] init:kPlayerID_2 ];
        otherConnon=[[UConnon alloc] init:kPlayerID_Host ];
    }
    connon.position=ccp(deviceValue.sceneWidth/4-connon.contentSize.width/2+deviceValue.rimWidth,deviceValue.rimHeight);
    
    
    otherConnon.position=ccp(deviceValue.sceneWidth/4*3-otherConnon.contentSize.width/2+deviceValue.rimWidth,deviceValue.sceneHeight-deviceValue.rimHeight);
    
    otherConnon.scaleY=-1;
    otherConnon.isScaleY=true;

    
    [self addChild:connon z:1 tag:kTagConnon];
    [self addChild:otherConnon z:1 tag:kTagOtherConnon];
    
}

-(void)createButtle:(int)level point:(CGPoint)pos angle:(float)angle player:(kPlayerID)pid tag:(int)bulletTag
{

    nextBullet=[[UBullet alloc] init:@"gc_bullet.png" player:pid level:level point:pos];
    [nextBullet setBulletRation:angle];
//    NSLog(@" 接收到的角度 tan angle=%f",tan(angle*M_PI / 180));
        
    if (angle>=90) {
        float realY = deviceValue.sceneHeight+nextBullet.contentSize.height;
        
        float realX = (realY *tan(angle*M_PI / 180));
        CGPoint realDest = ccp(pos.x-realX, pos.y-realY);
        
        float offRealX = pos.x-realDest.x;
        float offRealY = pos.y-realDest.y;
        float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
        float velocity = 480/2; // 480pixels/1sec
        if (isPad) {
            velocity = 1024/2;
        }
        
        float realMoveDuration = length/velocity;
        
        [bulletArray addObject:nextBullet];
        
        [self addChild:nextBullet z:0 tag:bulletTag];
        
        [nextBullet runAction:[CCSequence actions:
                               [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
                               [CCCallFuncN actionWithTarget:self selector:@selector(bulletMoveFinished:)],
                               nil]];
    }else {
        float realY = deviceValue.sceneHeight+nextBullet.contentSize.height;
        float realX = (realY *tan(angle*M_PI / 180));
        
        CGPoint realDest = ccp(realX+pos.x, realY+pos.y);
        
        float offRealX = pos.x-realDest.x;
        float offRealY = pos.y-realDest.y;
        float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
        float velocity = 480/2; // 480pixels/1sec
        if (isPad) {
            velocity = 1024/2;
        }
        float realMoveDuration = length/velocity;
        
        [bulletArray addObject:nextBullet];
        
        
        [self addChild:nextBullet z:0 tag:bulletTag];
        
        [nextBullet runAction:[CCSequence actions:
                               [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
                               [CCCallFuncN actionWithTarget:self selector:@selector(bulletMoveFinished:)],
                               nil]];
    }    
    
	
    //	realX+=gun.position.x;
    //	realY+=gun.position.y;
}
-(void)bulletMoveFinished:(id)sender
{
    [bulletArray removeObject:sender];
	UBullet *bullet=(UBullet *)sender;
	[self removeChild:bullet cleanup:YES];
//    NSLog(@"子弹超出屏幕   删除!");
        

}
//-(void)createGold:(int)num point:(CGPoint)point playerID:(kPlayerID)pid
//{
//    
//    UMoney *money=[[UMoney alloc] init:num point:point playerID:pid];
//    [self addChild:money];
//    CGPoint destination=CGPointMake(0, 0);
//    id move=[CCMoveTo actionWithDuration:sqrt((point.x-destination.x)*(point.x-destination.x)+(point.y-destination.y)*(point.y-destination.y))/200 position:destination];
//    [money runAction:move];
//    
//}

//-(void)createGold:(int)type point:(CGPoint)point playerID:(kPlayerID)pid
//{
//    
//}
-(void)createGold:(int)type point:(CGPoint)point playerID:(kPlayerID)pid
{
    [self playMoneyEffect];
    
    int num=golds[type];
    int goldW,goldH,timeNum;
    CGPoint destination,moveUp;
    if (isPad) {
        goldW=65;
        goldH=75;
        timeNum=450;
        if (playerID==pid) {
            destination= CGPointMake(600, 90);
        }else{
            destination= CGPointMake(290, 670);
        }
        
        
    }else{
        goldW=33;
        goldH=37;
        timeNum=250;
        if (playerID==pid) {
            destination= CGPointMake(280, 20);
        }else{
            destination= CGPointMake(140, 308);
        }
        
        
    }
    if (num<10) {
        for (int i=0; i<num; i++) {//(point+(i-num/2)*goldW)
            if (isPad) {
                moveUp= CGPointMake(0, arc4random()%30+30);
            }else{
                moveUp= CGPointMake(0, arc4random()%20+20);
            }
            
            CGPoint point2=CGPointMake(point.x+((float)i-(float)num/2)*goldW, point.y);
            UMoney *money=[[UMoney alloc] init:0 point:point2 playerID:pid] ;
            
            float time=sqrt((point.x-destination.x)*(point.x-destination.x)+(point.y-destination.y)*(point.y-destination.y))/timeNum;
            id move1=[CCMoveTo actionWithDuration:0.2 position:ccpAdd(point2, moveUp)];
            id delay=[CCDelayTime actionWithDuration:0.5f];
            id move2=[CCMoveTo actionWithDuration:time position:destination];
            id callFun=[CCCallFuncN actionWithTarget:self selector:@selector(deleteGold:)];
            [money runAction:[CCSequence actions:move1,delay,move2,callFun, nil]];
            [self addChild:money z:5];
        }
    }else{
        for (int i=0; i<num/10; i++) {//(point+(i-num/2)*goldW)
            if (isPad) {
                moveUp= CGPointMake(0, arc4random()%30+30);
            }else{
                moveUp= CGPointMake(0, arc4random()%20+20);
            }
            CGPoint point2=CGPointMake(point.x+((float)i-(float)num/20)*goldW, point.y);
            UMoney *money=[[UMoney alloc] init:1 point:point2 playerID:pid] ;
            float time=sqrt((point.x-destination.x)*(point.x-destination.x)+(point.y-destination.y)*(point.y-destination.y))/timeNum;
            id move1=[CCMoveTo actionWithDuration:0.2 position:ccpAdd(point2, moveUp)];
            id delay=[CCDelayTime actionWithDuration:0.5f];
            id move2=[CCMoveTo actionWithDuration:time position:destination];
            id callFun=[CCCallFuncN actionWithTarget:self selector:@selector(deleteGold:)];
            [money runAction:[CCSequence actions:move1,delay,move2,callFun, nil]];
            [self addChild:money z:5];//[self getShowGetGoldBatch]
        }
    }
    
    
    //    UMoney *money=[[UMoney alloc] init:0 point:point playerID:kPlayerID_Null] ;
    //    CGPoint destination=CGPointMake(0, 0);
    //    float time=sqrt((point.x-destination.x)*(point.x-destination.x)+(point.y-destination.y)*(point.y-destination.y))/200;
    //    id move=[CCMoveTo actionWithDuration:time position:destination];
    //    id callFun=[CCCallFuncN actionWithTarget:self selector:@selector(deleteGold:)];
    //    [money runAction:[CCSequence actions:move,callFun, nil]];
    
    
    
    
    int upNum;
    if (isPad) {
        showGetGold=[[CCLabelAtlas alloc]  initWithString:[NSString stringWithFormat:@"/%d",num] charMapFile:@"show_get_gold_num.png" itemWidth:40 itemHeight:38 startCharMap:'/'];
        upNum=60;
    }else {
        showGetGold=[[CCLabelAtlas alloc]  initWithString:[NSString stringWithFormat:@"/%d",num] charMapFile:@"show_get_gold_num.png" itemWidth:20 itemHeight:19 startCharMap:'/'];
        upNum=30;
    }
    
    showGetGold.position=point;
    
    
    id moveAction=[CCMoveTo actionWithDuration:2.0f position:ccpAdd(point, ccp(0,upNum))];
    id fadeOut=[CCFadeOut actionWithDuration:2.0f];
    id callFun2=[CCCallFuncN actionWithTarget:self selector:@selector(deleteShowGetGoldLabel:)];
    
    [showGetGold runAction:[CCSequence actions:[CCSpawn actions:moveAction,fadeOut, nil],callFun2, nil]];
    [self addChild:showGetGold z:5];
    
    //add the gold and score
    
    if (isHost) {
        if (playerID==pid) {
            gold+=golds[type];
            score+=scores[type];
            [connon addLaserSP:sps[type]*4];
            [self sendDataRenewMessage:gold score:score sp:sps[type]*4 playerID:pid];
        }else{
            rivalGold+=golds[type];
            rivalScore+=scores[type];
            [otherConnon addLaserSP:sps[type]*4];
            [self sendDataRenewMessage:rivalGold score:rivalScore sp:sps[type]*4 playerID:pid];
        }
    }
}

-(void)addSP:(int)sp
{
    [connon addLaserSP:sp];
}
-(void)deleteGold:(id)sender
{
    if ([sender isKindOfClass:[UMoney class]]) {
        [sender removeFromParentAndCleanup:YES];
        [sender release];
    }
}
-(void)deleteShowGetGoldLabel:(id)sender
{
    [sender removeFromParentAndCleanup:YES];
    [sender release];
}
-(void)playMoneyEffect
{
    if (GAME_IS_PLAY_EFFECT) {
        [GAME_AUDIO playEffect:kSoundTypeForMoney];
    }
}
-(void)playFireEffect
{
    if (GAME_IS_PLAY_EFFECT) {
        [GAME_AUDIO playEffect:kSoundTypeForConnonFire];
    }
}
-(void)playBackGroundMusic
{
    if (GAME_IS_PLAY_SOUND) {
        [GAME_AUDIO playBackgroundMusic:kSoundTypeForBackMusic];
    }
}
-(void)checkDeviceType
{
    CGSize s=[[CCDirector sharedDirector] winSize];
    
    NSLog(@"scene width=%f   height=%f",s.width,s.height);
    if (s.width==1024&&s.height==768) {
        deviceValue.deviceType=kIpad;
        deviceValue.sceneWidth=960;
        deviceValue.sceneHeight=640;
        deviceValue.rimWidth=32;
        deviceValue.rimHeight=64;
        deviceValue.speedRatio=2;
        NSLog(@"设备类型:kIpad");
    }else if (s.width==2048&&s.height==1536) {
        deviceValue.deviceType=kIpadHD;
        deviceValue.sceneWidth=1920;
        deviceValue.sceneHeight=1280;
        deviceValue.rimWidth=64;
        deviceValue.rimHeight=128;
        deviceValue.speedRatio=4;
        NSLog(@"设备类型:kIpadHD");
    }else if (s.width==960&&s.height==640) {
        deviceValue.deviceType=kIphoneHD;
        deviceValue.sceneWidth=960;
        deviceValue.sceneHeight=640;
        deviceValue.rimWidth=0;
        deviceValue.rimHeight=0;
        deviceValue.speedRatio=2;
        NSLog(@"设备类型:kIphoneHD");
    }else if (s.width==480&&s.height==320) {
        deviceValue.deviceType=kIphone;
        deviceValue.sceneWidth=480;
        deviceValue.sceneHeight=320;
        deviceValue.rimWidth=0;
        deviceValue.rimHeight=0;
        deviceValue.speedRatio=1;
        NSLog(@"设备类型:kIphone");
    }else if (s.width==1136&&s.height==640) {
        deviceValue.deviceType=kIphone5;
        deviceValue.sceneWidth=1136;
        deviceValue.sceneHeight=640;
        deviceValue.rimWidth=0;
        deviceValue.rimHeight=0;
        deviceValue.speedRatio=2;
        NSLog(@"设备类型:kIphone5");
    }else if (s.width==568&&s.height==320) {
        deviceValue.deviceType=kIphone5;
        deviceValue.sceneWidth=568;
        deviceValue.sceneHeight=320;
        deviceValue.rimWidth=0;
        deviceValue.rimHeight=0;
        deviceValue.speedRatio=1;
        NSLog(@"设备类型:kIphone5");
    }else {
        deviceValue.deviceType=kIphone;
        deviceValue.sceneWidth=480;
        deviceValue.sceneHeight=320;
        deviceValue.rimWidth=0;
        deviceValue.rimHeight=0;
        deviceValue.speedRatio=1;
        NSLog(@"设备类型:kIphone");
    }
}
-(void)setGameState:(int)state
{
    gameState=state;
}

//更新鱼的状态
//-(void)upDateFish
//{
//    
//    NSMutableArray *outFish=[[NSMutableArray alloc] init];
//    //检查鱼是否有超出屏幕
//    for (UFish *fish in fishArray) {
//        
//        if ([self isOut:fish]) {
//            fish.isInScreen=false;
//            if (fish.isInScreen&&fish.outScreenTime>20) {
//                [outFish addObject:fish];
//            }else if(fish.outScreenTime>50){
//                [outFish addObject:fish];
//            }
//        }else {
//            fish.isInScreen=true;
//        }
//    }
//
//    for (UFish *fish in outFish) {
//        [self removeFish:fish isClean:TRUE];
//    }
//    [outFish release];
//}

//更新鱼的状态
-(void)upDateFish
{
    NSMutableArray *outFish=[[NSMutableArray alloc] init];
    //检查鱼是否有超出屏幕
    for (UFish *fish in fishArray) {
        if(fish==nil){
            continue;
        }
        if (fish.state==kFishStateDeath) {
            continue;
        }
        if ([self isInScene:fish]) {
            fish.isInScreen=true;
            fish.outScreenTime=0;
        }else {
            fish.outScreenTime++;
            if(fish.isInScreen){//有进入过屏幕这代表不是刚生成的  而是从屏幕内除去
                [outFish addObject:fish];
                NSLog(@"超出1111");
            }
//            else if(fish.outScreenTime>120&&gameingState!=kGameingStateFishSchoolIng){
//                [outFish addObject:fish];
//                NSLog(@"超出2222");
//            }
            fish.isInScreen=false;
        }
        
    }
    
    for (UFish *fish in outFish) {
        NSLog(@"超出屏幕  删除!");
        [self removeFish:fish isClean:TRUE];
    }
    [outFish release];
}
-(BOOL)isInScene:(UFish*)fish
{
    CGRect sceneRect;
    sceneRect.origin=CGPointMake(deviceValue.rimWidth, deviceValue.rimHeight);
    sceneRect.size=CGSizeMake(deviceValue.sceneWidth, deviceValue.sceneHeight);
    
    //判断坐标是否在屏幕中
    if (CGRectContainsPoint(sceneRect, fish.position)) {
        return true;
    }
    
    //判断4个点是否在屏幕中
    //1
    CGPoint temPoint=ccpRotateByAngle(CGPointMake(fish.position.x-fish.contentSize.width/2, fish.position.y-fish.contentSize.height/2), fish.position, -fish.rotation*M_PI/180);
    if (CGRectContainsPoint(sceneRect, temPoint)) {
        return true;
    }
    //2
    temPoint=ccpRotateByAngle(CGPointMake(fish.position.x+fish.contentSize.width/2, fish.position.y-fish.contentSize.height/2), fish.position, -fish.rotation*M_PI/180);
    if (CGRectContainsPoint(sceneRect, temPoint)) {
        return true;
    }
    //3
    temPoint=ccpRotateByAngle(CGPointMake(fish.position.x+fish.contentSize.width/2, fish.position.y+fish.contentSize.height/2), fish.position, -fish.rotation*M_PI/180);
    if (CGRectContainsPoint(sceneRect, temPoint)) {
        return true;
    }
    //4
    temPoint=ccpRotateByAngle(CGPointMake(fish.position.x-fish.contentSize.width/2, fish.position.y+fish.contentSize.height/2), fish.position, -fish.rotation*M_PI/180);
    if (CGRectContainsPoint(sceneRect, temPoint)) {
        return true;
    }
    
    //判断鱼临近哪个角
    
    CGRect fishRect;
    fishRect.origin=fish.position;
    fishRect.size=fish.contentSize;
    
    if (fish.position.x<=GAME_SCENE_SIZE.width/2) {//在左边
        if (fish.position.y<=GAME_SCENE_SIZE.height/2) {//在下
            if ([self dotWithRotationRectCollide:CGPointMake(deviceValue.rimWidth, deviceValue.rimHeight) rect:fishRect angle:fish.rotation]) {
                return true;
            }
        }else {
            if ([self dotWithRotationRectCollide:CGPointMake(deviceValue.rimWidth, deviceValue.rimHeight+deviceValue.sceneHeight) rect:fishRect angle:fish.rotation]) {
                return true;
            }
        }
    }else {
        if (fish.position.y<=GAME_SCENE_SIZE.height/2) {//在下
            if ([self dotWithRotationRectCollide:CGPointMake(deviceValue.rimWidth+deviceValue.sceneWidth, deviceValue.rimHeight) rect:fishRect angle:fish.rotation]) {
                return true;
            }
        }else {
            if ([self dotWithRotationRectCollide:CGPointMake(deviceValue.rimWidth+deviceValue.sceneWidth, deviceValue.rimHeight+deviceValue.sceneHeight) rect:fishRect angle:fish.rotation]) {
                return true;
            }
        }
    }
    
    return false;
}
//检测点与旋转矩形的碰撞

-(BOOL)dotWithRotationRectCollide:(CGPoint)dot rect:(CGRect)rect angle:(float)angle
{
    CGPoint newDot=ccpRotateByAngle(dot, rect.origin, angle*M_PI/180);
    
    CGRect newRect=CGRectMake(rect.origin.x-rect.size.width/2, rect.origin.y-rect.size.height/2, rect.size.width, rect.size.height);
    
    return CGRectContainsPoint(newRect, newDot);
}
-(int)getRondomFishType
{
    int tem=arc4random()%100;
    int type;
    
    if (tem<19) {
        type=0;
    }else if (tem>=20&&tem<=37) {
        type=1;
    }else if (tem>=38&&tem<=52) {
        type=2;
    }else if (tem>=53&&tem<=64) {
        type=3;
    }else if (tem>=65&&tem<=74) {
        type=4;
    }else if (tem>=75&&tem<=82) {
        type=5;
    }else if (tem>=83&&tem<=88) {
        type=6;
    }else if (tem>=89&&tem<=93) {
        type=7;
    }else if (tem>=94&&tem<=97) {
        type=8;
    }else if (tem>=98&&tem<=99) {
        type=9;
    }else {
        type=0;
    }
    
    return type;
    
}
//刷鱼控制
-(void)createFishControl
{
    if (fishArray!=nil) {
        if (fishArray.count<kFishNumControl) {
            [self createFishSchoolWithWay];
        }
    }
}
//9个方位取num个数字
-(NSMutableArray*)getFishSchoolFishPoint:(int)num
{
    int tem[]={0,1,2,3,4,5,6,7,8};
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    
    for (int i=0; i<num; i++) {
        int n=arc4random()%(sizeof(tem)/sizeof(tem[0])-i);
        NSNumber *number=[NSNumber numberWithInt:tem[n]];
        [arr addObject:number];
        int k=tem[n];
        tem[n]=tem[sizeof(tem)/sizeof(tem[0])-1-i];
        tem[sizeof(tem)/sizeof(tem[0])-1-i]=k;
    }
//    int kk=0;
//    for (NSNumber *number in arr) {
//        int n=[number intValue];
//        NSLog(@"选中的位置 %d=%d",kk,n);
//        kk++;
//    }
    
    return arr;
}

-(void)createFishSchool:(int)type fishSpeed:(float)speed fishAngle:(float)angle fishPoint:(CGPoint)point fishTag:(int)tag  playerID:(kPlayerID)pid
{
        
    int n;//鱼的数量
    int pos;//鱼的方位0-8
    int minNum=1,maxNum=1;
    
    switch (type) {
        case kFishSchoolType_1:
            minNum=3;
            maxNum=3;
            
            break;
        case kFishSchoolType_2:
            minNum=3;
            maxNum=2;
            
            break;
        case kFishSchoolType_3:
            minNum=2;
            maxNum=2;
            
            break;
        case kFishSchoolType_4:
            minNum=1;
            maxNum=3;
            
            break;
        case kFishSchoolType_5:
            minNum=1;
            maxNum=2;
            
            break;
        case kFishSchoolType_6:
            minNum=1;
            maxNum=2;
            
            break;
        default:
            break;
    }
    
    n=arc4random()%maxNum+minNum;
    newFishSchool=[[UFishSchool alloc] init];
    
    NSMutableArray *arr=[self getFishSchoolFishPoint:n];
    for (int i=0; i<n; i++) {
        pos=[[arr objectAtIndex:i] intValue];
       
        UFish *fish = [[UFish alloc] init:type frame:[fishSprireArr objectAtIndex:type] speed:speed angle:angle state:0 fishPoint:CGPointMake(-500,-500) playerID:pid];
//         NSLog(@"创建鱼的位置 %d=%d   鱼的大小 w=%f  h=%f",i,pos,fish.contentSize.width,fish.contentSize.height);
        fish.fishID=[self assignFishTag];
        fish.position=ccp(point.x-pos/3*fish.contentSize.width,point.y-pos%3-fish.contentSize.width);
        
        [fishBatchNode addChild:fish z:0 tag:fish.fishID];
        [fishArray addObject:fish];
        [newFishSchool addFish:fish];
        [fish setMyFishSchool:newFishSchool];
        //                [self sendCreateFish:fish];
        
    }
    [self addChild:newFishSchool];
    [fishSchoolArray addObject:newFishSchool];
    
    
} 

-(void)addNoUseFishID:(UFish*)fish
{
    NSNumber *number=[NSNumber numberWithInt:fish.fishID];
    [fishNoUseTag addObject:number];
}
//分配一个鱼的tag/id  100开始
-(int)assignFishTag
{
    if (fishNoUseTag.count==0) {
        return fishArray.count+100;
    }
    else {
        NSNumber *number=[fishNoUseTag objectAtIndex:0];
        [fishNoUseTag removeObjectAtIndex:0];
        return [number intValue];
    }
}

-(void)addNoUseBulletTag:(int)tag
{
    NSNumber *number=[NSNumber numberWithInt:tag];
    [bulletNoUseTag addObject:number];
}

-(int)assignBulletTag
{

    
    if (bulletNoUseTag.count==0) {
        return bulletArray.count+200;
    }else {
        NSNumber *number=[bulletNoUseTag objectAtIndex:0];
        [bulletNoUseTag removeObjectAtIndex:0];
        if (number!=nil) {
            return [number intValue];
        }else {
            return bulletArray.count+200;
        }
        
    }
}

-(void)createFishSchoolWithWay
{
    //随机在左还是在右
    int way=arc4random()%2;
    //随机鱼的类型
    int type=arc4random()%10;//[self getRondomFishType]
    //角度
    int angle;
    //
    CGPoint point;
    
//    CCSprite *temFishSprite= (CCSprite *)[fishSprireArr objectAtIndex:type];
    CCSpriteFrame *temSpriteFrame=[fishSprireArr objectAtIndex:type];
    switch (way) {
        case 0:
        {
            //鱼从左边出来
            point=ccp(deviceValue.rimWidth-temSpriteFrame.rect.size.width/2,arc4random()%((int)deviceValue.sceneHeight/2)+deviceValue.sceneHeight/4);
            int tem=arc4random()%2;
            if (type==9) {
                angle=0;
            }else if (tem==0) {
                angle=arc4random()%20;
            }else {
                angle=-arc4random()%20;
            }
        }
            break;
        case 1:
        {
            //鱼从右边出来
            point=ccp(deviceValue.sceneWidth+deviceValue.rimWidth+temSpriteFrame.rect.size.width/2,arc4random()%((int)deviceValue.sceneHeight/2)+deviceValue.sceneHeight/4);
            int tem=arc4random()%2;
            if (type==9) {
                angle=180;
            }else if (tem==0) {
                angle=arc4random()%20+180;
            }else {
                angle=180-arc4random()%20;
            }
        }
            break;
        default:
            break;
    }
    int n;//鱼的数量
    int pos;//鱼的方位0-8
    int minNum=1,maxNum=1;
    
    switch (type) {
        case kFishSchoolType_1:
            minNum=3;
            maxNum=3;
            
            break;
        case kFishSchoolType_2:
            minNum=3;
            maxNum=2;
            
            break;
        case kFishSchoolType_3:
            minNum=2;
            maxNum=2;
            
            break;
        case kFishSchoolType_4:
            minNum=1;
            maxNum=3;
            
            break;
        case kFishSchoolType_5:
            minNum=1;
            maxNum=2;
            
            break;
        case kFishSchoolType_6:
            minNum=1;
            maxNum=2;
            
            break;
        default:
            break;
    }
    
    n=arc4random()%maxNum+minNum;
    newFishSchool=[[UFishSchool alloc] init:type];
    
    NSMutableArray *arr=[self getFishSchoolFishPoint:n];
    UFish *fish;
    for (int i=0; i<n; i++) {
        pos=[[arr objectAtIndex:i] intValue];
//      NSLog(@"创建鱼的位置 %d=%d",i,pos);
        int speed=4;
        if (isPad) {
            speed=4;
        }else{
            speed=2;        }
        fish = [[UFish alloc] init:type frame:[fishSprireArr objectAtIndex:type] speed:speed angle:angle state:0 fishPoint:CGPointMake(-500, -500) playerID:playerID];
        
        fish.fishID=[self assignFishTag];
        
        if (way==0) {//左
//            NSLog(@"创建鱼的方向为左");
            fish.position=ccp(point.x-pos/3*fish.contentSize.width-fish.contentSize.width/2,point.y-pos%3*fish.contentSize.width);
        }else {
//            NSLog(@"创建鱼的方向为右");
            fish.position=ccp(point.x+pos/3*fish.contentSize.width+fish.contentSize.width/2,point.y-pos%3*fish.contentSize.width);
        }
        
        [fishBatchNode addChild:fish z:0 tag:fish.fishID];
        [fishArray addObject:fish];
        [newFishSchool addFish:fish];
        //        [fish setFishSchool:newFishSchool];
        //                [self sendCreateFish:fish];
    }
    [self addChild:newFishSchool];
    [fishSchoolArray addObject:newFishSchool];
    
    [self sendCreateFishSchoolMessage:newFishSchool];
}
//
//-(void)createFish:(int)type fishSpeed:(float)speed fishAngle:(float)angle fishPoint:(CGPoint)point fishTag:(int)tag playerID:(kPlayerID)pid
//{
////  NSLog(@"createFish");
//    UFish *fish = [[UFish alloc] init:type speed:speed angle:angle state:0 fishPoint:point playerID:pid];
//    fish.fishID=[self assignFishTag];
//    [self addChild:fish z:0 tag:fish.fishID];
//    [fishArray addObject:fish];
//}
//
//-(void)createFishAndSendData:(int)type fishSpeed:(float)speed fishAngle:(float)angle fishPoint:(CGPoint)point fishTag:(int)tag playerID:(kPlayerID)pid
//{
////  NSLog(@"createFish");
//    UFish *fish = [[UFish alloc] init:type speed:speed angle:angle state:0 fishPoint:point playerID:pid];
//    fish.fishID=[self assignFishTag];
//    [self addChild:fish z:0 tag:fish.fishID];
//    [fishArray addObject:fish];
//    [self sendCreateFish:fish];
//    
//}
-(float)dotLength:(CGPoint)point point2:(CGPoint)point2
{
    return sqrt((point.x-point2.x)*(point.x-point2.x)+(point.y-point2.y)*(point.y-point2.y));
}
-(NSMutableArray*)checkNetIntersects:(CGPoint)dot level:(float)level playerID:(kPlayerID)pid
{
//    CGPoint dot;
    float area;

    if (isPad) {
        if (level<3) {
            area=72;
        }else if (level<6) {
            area=108;
        }else {
            area=144;
        }
    }else{
        if (level<3) {
            area=36;
        }else if (level<6) {
            area=54;
        }else {
            area=72;
        }
    }

    NSMutableArray *toDelete=[[NSMutableArray alloc] init];
//    double yu[] = {30,25,20,17,14,10,8,5,3,1};
//    CGRect netRect=CGRectMake(net.position.x-net.contentSize.width/2, net.position.y-net.contentSize.height/2, net.contentSize.width, net.contentSize.height);
    
    for (UFish *fish in fishArray) {
        if (fish==nil||fish.state==kFishStateDeath) {
            continue;
        }
        double num=yu[fish.type]*(1.0f+level*level/49.0f);
        //判断鱼的坐标在网的范围内则为碰到   并进行捕获的概率计算
        if ([self dotLength:dot point2:fish.position]<=area) {//CGRectContainsPoint(netRect, fish.position)
            double a = (double)(arc4random() % 10000) / 10000 * 100 ;
            if (a<num) {
                [toDelete addObject:fish];
                fish.beKillPlayer=pid;
                //发送鱼死亡消息
                [self sendMessageFishDeath:fish.fishID player:fish.beKillPlayer];
                [fish death];
            }
        }
    }
    return toDelete;
}
-(void)upDataBulletForNoHost
{
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
	for (UBullet *bullet in bulletArray) {
		BOOL isIntersects=false;
		for (UFish *fish in fishArray) {
            
            if (fish==nil||fish.state==kFishStateDeath) {
                continue;
            }
            if (fish.state!=kFishStateDeath) {//非死亡状态
                CGRect fishRect = CGRectMake(fish.position.x, fish.position.y, fish.contentSize.width, fish.contentSize.height);
                if ([self dotWithRotationRectCollide:bullet.position rect:fishRect angle:fish.rotation]) {//检测子弹与鱼的碰撞
                    isIntersects=true;
                    
//                    UNet *net=[[UNet alloc] init:bullet.level plaerID:bullet.playerID point:bullet.position];
                    //                        [self addChild:net];
                    [self createBlast:bullet.position type:bullet.level];
//                    [fishNetArray addObject:net];
                }
            }
        }

		if (isIntersects) {//子弹与鱼有发生碰撞则添加到删除数组
			[projectilesToDelete addObject:bullet];
		}
	}
	
	for (UBullet *bullet in projectilesToDelete) {
		[bulletArray removeObject:bullet];
		[self removeChild:bullet cleanup:YES];
        
	}
	[projectilesToDelete release];
}
-(void)upDataBulletForHost
{
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
	for (UBullet *bullet in bulletArray) {

		BOOL isIntersects=false;
        NSMutableArray *toDelete=[[NSMutableArray alloc] init];
		for (UFish *fish in fishArray) {
            if (fish==nil||fish.state==kFishStateDeath) {
                continue;
            }
            if (fish.state!=kFishStateDeath) {//非死亡状态
                CGRect fishRect = CGRectMake(fish.position.x, fish.position.y, fish.contentSize.width, fish.contentSize.height);
                
                if ([self dotWithRotationRectCollide:bullet.position rect:fishRect angle:fish.rotation]) {//检测子弹与鱼的碰撞
                    isIntersects=true;
                    
//                    UNet *net=[[UNet alloc] init:bullet.level plaerID:bullet.playerID point:bullet.position];
//                    net.anchorPoint=ccp(0.5f,0.5f);
//                    [self addChild:net];
                    [self createBlast:bullet.position type:bullet.level];
//                    [fishNetArray addObject:net];
                    [toDelete addObjectsFromArray:[self checkNetIntersects:bullet.position level:bullet.level playerID:bullet.playerID]];
                    
                } 
            }
        }
        
        
        for (UFish *fish in toDelete) {//被网击中的鱼从数组中去掉
            if (fish==nil) {
                continue;
            }
            [self removeFish:fish isClean:NO];
        }
        [toDelete release];
		
		if (isIntersects) {//子弹与鱼有发生碰撞则添加到删除数组
			[projectilesToDelete addObject:bullet];
		}
	}
	
	for (UBullet *bullet in projectilesToDelete) {
        [bulletArray removeObject:bullet];
		[self removeChild:bullet cleanup:YES];
        [bullet release];
	}
	[projectilesToDelete release];
}

-(void)removeFish:(UFish*)fish isClean:(BOOL)is
{
//  [self addNoUseFishID:fish];//记录删除鱼的ID  用来下次使用
    [fishArray removeObject:fish];//将鱼从数组中删除
    [((UFishSchool*)fish.fishSchool).fishArray removeObject:fish];//将鱼从所属的鱼群中去掉
    if (((UFishSchool*)fish.fishSchool).fishArray.count==0) {//鱼群鱼的数量为0则删除掉鱼群
        [self removeChild:fish.fishSchool cleanup:YES];
    }
    if (is) {
        if (isHost) {
            [self sendMessageRemoveFish:fish.fishID clean:YES];
        }
        
        [self addNoUseFishID:fish];
        [fishBatchNode removeChild:fish cleanup:YES];//从界面上清除并清理掉        
    }
}

//判断鱼是否在界面内
-(BOOL)isOut:(UFish*)fish
{
    if (CGRectContainsPoint(CGRectMake(deviceValue.rimWidth, deviceValue.rimHeight, deviceValue.sceneWidth, deviceValue.sceneHeight), fish.position)) {
        return false;
    }
    return true;
}
-(void)updateGoldAndScore{
    //update the gold and score label
    //my gold show label
    if (showGold<gold) {
        if (gold-showGold>10) {
            showGold+=4;
        }else{
            showGold++;
        }
        [self setGoldLabel:showGold];
    }else if (showGold>gold) {
        if (showGold-gold>10) {
            showGold-=4;
        }else{
            showGold--;
        }
        [self setGoldLabel:showGold];
    }
    //my score show label
    if (showScore<score) {
        if (score-showScore>10) {
            showScore+=4;
        }else{
            showScore++;
        }
        
        [self setScoreLabel:showScore];
    }else if (showScore>score) {
        if (showScore-score>10) {
            showScore-=4;
        }else{
            showScore--;
        }
        [self setScoreLabel:showScore];
    }
    //rival gold show label
    if (showRivalGold<rivalGold) {
        if (rivalGold-showRivalGold>10) {
            showRivalGold+=4;
        }else{
            showRivalGold++;
        }
        [self setRivalGoldLabel:showRivalGold];
    }else if (showRivalGold>rivalGold) {
        if (showRivalGold-rivalGold>10) {
            showRivalGold-=4;
        }else{
            showRivalGold--;
        }
        
        [self setRivalGoldLabel:showRivalGold];
    }
    //rival score show label
    if (showRivalScore<rivalScore) {
        if (rivalScore-showRivalScore>10) {
            showRivalScore+=4;
        }else{
            showRivalScore++;
        }
        [self setRivalScoreLabel:showRivalScore];
    }else if (showRivalScore>rivalScore) {
        if (showRivalScore-rivalScore>10) {
            showRivalScore-=4;
        }else{
            showRivalScore--;
        }
        
        [self setRivalScoreLabel:showRivalScore];
    }
}

-(void) update:(ccTime)delta
{
    
    switch (gameState) {
        case kGameStateWaitingForMatch:
            
            break;
        case kGameStateInitPlayerData:
            //判断初始化玩家完毕   并且选出
            break;
        case kGameStateChoiceHost:
            if (isChoiceHost) {//区分出主机  就进入游戏初始化
                [self setGameState:kGameStateInitGameData];
                [self initGame];
                isInitDone=true;
                if (!isHost) {//非主机
                    [self sendInitDataDone];
                }
            }
            break;
        case kGameStateInitGameData:
            if (isHost) {//为主机  尝试开始游戏
               [self tryStartGame];
            }
            break;
        case kGameStateStartGame:
            break;
        case kGameStateGameIng:
            if (isHost) {
                [self upDateFish];
                //update bullet
                [self upDataBulletForHost];
                //update fish net
            }else{
                [self upDataBulletForNoHost];
            }
            
            //up date the gold and score data
            [self updateGoldAndScore];
            
            if (timer<=0&&gameingState!=kGameingStateForResult) {
                if (bulletArray.count==0) {
                    gameingState=kGameingStateForResult;
                    gameState=kGameStateGameOver;
                    [self showGameResult];
                }
            }
            break;
        case kGameStateGameOver:
            break;
        default:
            break;
    }
    
}
-(void)connonFire2:(CGPoint)location
{

    CGPoint gunPoint=ccpAdd(connon.position, CGPointZero);//connon.turnDot
    double w = location.x - gunPoint.x;
    double h = location.y - gunPoint.y;
    if(h<0){
        h=0;
    }
    double radian = atan(w/h);
    double degrees = CC_RADIANS_TO_DEGREES(radian);

//    int temTag=[self assignBulletTag];
    
    if (degrees>=90) {
        degrees=89.9;
    }else if(degrees<=-90){
        degrees=-89.9;
    }
    
//    if (!connon.isFireIng&&gold>connon.level+1&&connon.connonState==KStateNormal) {
//        [self sendFireMessage:degrees level:connon.level playerID:playerID tag:0];
//        
//    }
    [connon fire:degrees];
//  [connon createButtle:degrees level:connon.level tag:temTag];
    
}

-(void)connonFireRequest:(CGPoint)location
{
    CGPoint gunPoint=ccpAdd(connon.position, CGPointZero);//connon.turnDot
    double w = location.x - gunPoint.x;
    double h = location.y - gunPoint.y;
    double radian = atan(w/h);
    double degrees = CC_RADIANS_TO_DEGREES(radian);
    
    [self sendFireRequsetMessage:degrees level:connon.level pid:playerID];
}
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (timer<=0) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
    
    // location not in the screen ,return
    if (!CGRectContainsPoint(CGRectMake(deviceValue.rimWidth, deviceValue.rimHeight, deviceValue.sceneWidth, deviceValue.sceneHeight), location)) {
        return;
    }
    [self connonFire2:location];
//    if (isHost) {
//        [self connonFire2:location];
//    }else {
////      [self connonFireRequest:location];
//        [self connonFire2:location];
//    }
}
-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
}
#pragma mark -
#pragma mark 消息发送
- (void)sendData:(NSData *)data {
    NSError *error;
    BOOL success;

    success = [[GCHelper sharedInstance].match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (!success) {
        [self matchEnded];
    }
}
//发送清除鱼的消息
-(void)sendMessageRemoveFish:(int)fishID clean:(BOOL)isClean
{
    MessageRemoveFish message;
    message.message.messageType=kMessageTypeRemoveFish;
    message.fishID=fishID;
    message.isClean=isClean;
    
    NSData *data=[NSData dataWithBytes:&message length:sizeof(MessageRemoveFish)];
    
    [self sendData:data];
}
//发送鱼死亡的消息
-(void)sendMessageFishDeath:(int)fishID player:(kPlayerID)pid
{
    MessageFishDeath message;
    message.message.messageType=kMessageTypeFishDeath;
    message.fishID=fishID;
    message.beKillPlayer=pid;
    
    NSData *data=[NSData dataWithBytes:&message length:sizeof(MessageFishDeath)];
    
    [self sendData:data];
}
-(void)sendRandom
{
    MessageChoiceHost message;
    message.message.messageType = kMessageTypeChoiceHost;
    message.randomNumber = ourRandom;
    message.deviceValue=deviceValue;
    
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageChoiceHost)]; 
    [self sendData:data];
    
}

-(void)sendInitDataDone
{
    MessageInitDataDone message;
    message.message.messageType=kMessageTypeInitDone;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageInitDataDone)]; 
    [self sendData:data];
}
-(void)sendStartGame
{
    MessageStartGame message;
    message.message.messageType = kMessageTypeStartGame;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageStartGame)]; 
    [self sendData:data];
}
-(void)sendGameBegin
{
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)]; 
    [self sendData:data];
}
-(void)sendCreateFish:(UFish*)fish
{
//    NSLog(@"send create fish message");
    MessageCreateFish mCreateFish;
    mCreateFish.message.messageType=kMessageTypeCreateFish;
    mCreateFish.fishType=fish.type;
    mCreateFish.speed=fish.speed;
    mCreateFish.angle=fish.angle;
    mCreateFish.state=fish.state;
    mCreateFish.point=fish.position;
    mCreateFish.tag=fish.fishID;
    
    NSData *data = [NSData dataWithBytes:&mCreateFish length:sizeof(MessageCreateFish)]; 
    [self sendData:data];
    
}

-(void)sendFireMessage:(double)angle level:(int)l playerID:(kPlayerID)pid tag:(int)bulletTag
{
    MessageFire message;
    message.message.messageType=kMessageTypeFire;
    message.angle=angle;
    message.level=l;
    message.playerID=pid;
    message.tag=bulletTag;
    NSData *data=[NSData dataWithBytes:&message length:sizeof(MessageFire)];
    [self sendData:data];
}

-(void)sendStoreUpMessage:(double)angle playerID:(kPlayerID)pid
{
    MessageStoreUp message;
    message.message.messageType=kMessageTypeStoreUp;
    message.angle=angle;
    message.playerID=pid;
    
    NSData *data=[NSData dataWithBytes:&message length:sizeof(MessageStoreUp)];
    [self sendData:data];
}
-(void)sendLaserFireMessage:(double)angle playerID:(kPlayerID)pid
{
    MessageLaserFire message;
    message.message.messageType=kMessageTypeLaserFire;
    message.angle=angle;
    message.playerID=pid;
    
    NSData *data=[NSData dataWithBytes:&message length:sizeof(MessageLaserFire)];
    [self sendData:data];
}

-(void)sendFireRequsetMessage:(double)angle level:(int)connonLevel pid:(kPlayerID)pid
{
    MessageFireRequest message;
    message.message.messageType=kMessageTypeFireRequest;
    message.level=connonLevel;
    message.playerID=pid;
    message.angle=angle;
    NSData *data=[NSData dataWithBytes:&message length:sizeof(MessageFireRequest)];
    [self sendData:data];
    
}

-(void)sendCreateFishSchoolMessage:(UFishSchool*)fishSchool
{
//    NSLog(@"发送创建鱼群消息");
    MessageCreateFishSchool message;
    message.message.messageType=kMessageTypeCreateFishSchool;
    UFish *fish=[fishSchool.fishArray objectAtIndex:0];
    message.angle=fish.angle;
    message.speed=fish.speed;
    message.type=fish.type;
    message.num=fishSchool.fishArray.count;
    
    int i=0;
    for (UFish *fish in fishSchool.fishArray) {
        message.fishArr[i].point=fish.position;
        message.fishArr[i].tag=fish.fishID;
        i++;
    }
    
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageCreateFishSchool)]; 
    [self sendData:data];
    
}

-(void)sendFishMove:(CGPoint)point
{
    MessageMove message;
    message.message.messageType=kMessageTypeMove;
    message.x=point.x;
    message.y=point.y;
    
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageMove)]; 
    [self sendData:data];
}
-(void)sendTurnConnonLevel:(int)l playerID:(kPlayerID)pid
{
    MessageTurnConnonLevel message;
    message.message.messageType=kMessageTypeTurnConnonLevel;
    message.pid=pid;
    message.level=l;
    
    NSData *data=[NSData dataWithBytes:&message length:sizeof(MessageTurnConnonLevel)];
    [self sendData:data];
}
-(void)sendTurnConnonLevelRequest:(int)l
{
    MessageTurnConnonLevelRequest message;
    message.message.messageType=kMessageTypeTurnConnonLevelRequest;
    message.pid=playerID;
    message.level=l;
    
    NSData *data=[NSData dataWithBytes:&message length:sizeof(MessageTurnConnonLevelRequest)];
    [self sendData:data];
}
//发送退出游戏的消息
-(void)sendExitMessage:(EndReason)reason
{
    MessageExit message;
    message.message.messageType=kMessageTypeExit;
    message.pid=playerID;
    message.endReason=reason;
    NSData *data=[NSData dataWithBytes:&message length:sizeof(MessageExit)];
    [self sendData:data];
}
//发送金币及积分更新消息
-(void)sendDataRenewMessage:(int)nowGold score:(int)nowScore sp:(int)nowSp playerID:(kPlayerID)pid
{
    MessageDataRenew message;
    message.message.messageType=kMessageTypeDataRenew;
    message.nowGold=nowGold;
    message.nowScore=nowScore;
    message.nowSp=nowSp;
    message.pid=pid;
    
    NSData *data=[NSData dataWithBytes:&message length:sizeof(MessageDataRenew)];
    [self sendData:data];
}

-(void)sendTimerRenewMessage:(int)time
{
    MessageTimerRenew message;
    message.message.messageType=kMessageTypeTimerRenew;
    message.timer=time;
    
    NSData *data=[NSData dataWithBytes:&message length:sizeof(MessageDataRenew)];
    [self sendData:data];
}

#pragma mark -
#pragma mark 数值转换
-(CGPoint)toThisPosition:(CGPoint)point
{
//    return point;    
    if (otherDeviceValue.sceneWidth==deviceValue.sceneWidth
        &&otherDeviceValue.sceneHeight==deviceValue.sceneHeight
        &&otherDeviceValue.rimWidth==deviceValue.rimWidth
        &&otherDeviceValue.rimHeight==deviceValue.rimHeight) {
        return point;
    }else {
        CGPoint temPoint=CGPointMake((point.x-otherDeviceValue.rimWidth)*(deviceValue.sceneWidth/otherDeviceValue.sceneWidth)+deviceValue.rimWidth, (point.y-otherDeviceValue.rimHeight)*(deviceValue.sceneHeight/otherDeviceValue.sceneHeight)+deviceValue.rimHeight);
        return temPoint;
    }
    
}
-(float)toThisSpeed:(float)sp
{
//    NSLog(@"!!!!the fish speed=%f",sp);
    return sp/otherDeviceValue.speedRatio*deviceValue.speedRatio;
//    if (otherDeviceValue.speedRatio==deviceValue.speedRatio) {
//        return sp;
//    }else {
//        return sp*deviceValue.speedRatio/otherDeviceValue.speedRatio;
//    }
}

//接收之后进行坐标的转换
-(CGPoint)positionToAngleTurn:(CGPoint)point
{
    CGSize s=[[CCDirector sharedDirector] winSize];
    
    return ccp(s.width-point.x,s.height-point.y);//ccp(s.width-point.x,s.height-point.y)
    
}
//接收之后进行角度的转换
-(float)angleToAngleTurn:(float)angle
{
    return angle+180;//angle+180
}
-(void)tryStartGame
{
    if (!isHost)return;
//    NSLog(@"尝试开始游戏!!");
    if (isInitDone&&otherPlayerIsInitDone) {
        //进入游戏
        [self setGameState:kGameStateStartGame];
        //发送进入游戏的消息
        [self sendStartGame];
        //
        [self showPlayerHeadAndName];
        //初始化头像
//        NSLog(@"主机进入游戏状态!!!");
    }    
}
-(void)getPlayerHeadForUImage
{
    [[GKLocalPlayer localPlayer] loadPhotoForSize:GKPhotoSizeNormal withCompletionHandler:^(UIImage *photo, NSError *error) {
        if (error==nil) {
            localPlayerHead_=photo;
        }
    }];
    GKPlayer *player = [[GCHelper sharedInstance].playersDict objectForKey:otherPlayerID];
    [player loadPhotoForSize:GKPhotoSizeNormal withCompletionHandler:^(UIImage *photo, NSError *error) {
        if (error==nil) {
            rivalPlayerHead_=photo;
        }
        
    }];
}
-(CCSprite*)getLocalPayerHead{
    
    if (localPlayerHead!=nil) {
        return localPlayerHead;
    }
    if (localPlayerHead_!=nil) {
        localPlayerHead=[self convertImageToSprite:localPlayerHead_];
        return localPlayerHead;
    }
    [[GKLocalPlayer localPlayer] loadPhotoForSize:GKPhotoSizeNormal withCompletionHandler:^(UIImage *photo, NSError *error) {
            if (error==nil) {
            localPlayerHead=[[self convertImageToSprite:photo] retain];
        }else {
            NSLog(@"load photo for error:%@",error);
            localPlayerHead=[[CCSprite spriteWithFile:@"gc_default_head.png"] retain];
        }
        
    }];
    
    return localPlayerHead;
}
//获取对方的信息[GCHelper sharedInstance].match.playerIDs
-(void)getRivalPlayerInfo
{
    GKPlayer *player = [[GCHelper sharedInstance].playersDict objectForKey:[[GCHelper sharedInstance].match.playerIDs objectAtIndex:0]];
     NSLog(@"###########get rival player info \n 1.playerIDS:%d \n 2.rival player id:%@ \n 3.rival player name:%@  \n4.id=?  %@",[GCHelper sharedInstance].match.playerIDs.count,player.playerID,player.alias,[[GCHelper sharedInstance].match.playerIDs objectAtIndex:0]);
    
    for (GKPlayer *temPlayer in [GCHelper sharedInstance].otherPlayers) {
        NSLog(@"*************get rival player info \n 1. player id=%@ \n 2. player name=%@",temPlayer.playerID,temPlayer.alias);
    }
    
}
-(CCSprite*)getRivalPlayerHead{
    
    if (rivalPlayerHead!=nil) {
        return rivalPlayerHead;
    }
    if (rivalPlayerHead_!=nil) {
        rivalPlayerHead=[self convertImageToSprite:rivalPlayerHead_];
        return rivalPlayerHead;
    }
    GKPlayer *player = [[GCHelper sharedInstance].playersDict objectForKey:otherPlayerID];
    [player loadPhotoForSize:GKPhotoSizeNormal withCompletionHandler:^(UIImage *photo, NSError *error) {
        
        if (error==nil) {
            rivalPlayerHead=[[self convertImageToSprite:photo] retain];
        }else {
            NSLog(@"load photo for error:%@",error);
            rivalPlayerHead=[[CCSprite spriteWithFile:@"gc_default_head.png"] retain];
        }
        
    }];
    return rivalPlayerHead;
}
//加载双方头像
-(void)setupHeadPhoto:(NSString*)otherID
{
    if (isHost) {
        
        [[GKLocalPlayer localPlayer] loadPhotoForSize:GKPhotoSizeNormal withCompletionHandler:^(UIImage *photo, NSError *error) {
            
            if (error==nil) {
                myHead2=[[self convertImageToSprite:photo] retain];
            }else {
                NSLog(@"load photo for error:%@",error);
                myHead2=[[CCSprite spriteWithFile:@"gc_default_head.png"] retain];
            }
            if (isPad) {
                myHead2.scale=60/myHead2.contentSize.width;
                myHead2.anchorPoint=CGPointZero;
                myHead2.position=ccp(42,73);
            }else{
                myHead2.scale=30/myHead2.contentSize.width;
                myHead2.anchorPoint=CGPointZero;
                myHead2.position=ccp(5,5);
            }
            
            
            [self addChild:myHead2 z:kDeepForUILayer];
//            CCSprite *headPhoto=[self convertImageToSprite:photo];
//            headPhoto.scale=80/headPhoto.contentSize.width;
//            headPhoto.position=ccp(50,100);
//            [self addChild:headPhoto];
            
        }];
        
        GKPlayer *player = [[GCHelper sharedInstance].playersDict objectForKey:otherID];
        
        [player loadPhotoForSize:GKPhotoSizeNormal withCompletionHandler:^(UIImage *photo, NSError *error) {
            
            if (error==nil) {
                otherPlayerHead2=[[self convertImageToSprite:photo] retain];
            }else {
                NSLog(@"load photo for error:%@",error);
                otherPlayerHead2=[[CCSprite spriteWithFile:@"gc_default_head.png"] retain];
            }
            if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
                otherPlayerHead2.scale=30/otherPlayerHead2.contentSize.width;
                otherPlayerHead2.anchorPoint=CGPointZero;
                otherPlayerHead2.position=ccp(444+88,286);
            }else if (isPad) {
                otherPlayerHead2.scale=60/otherPlayerHead2.contentSize.width;
                otherPlayerHead2.anchorPoint=CGPointZero;
                otherPlayerHead2.position=ccp(919,635);
            }else{
                otherPlayerHead2.scale=30/otherPlayerHead2.contentSize.width;
                otherPlayerHead2.anchorPoint=CGPointZero;
                otherPlayerHead2.position=ccp(444,286);
            }
            
            [self addChild:otherPlayerHead2 z:kDeepForUILayer];
//            CCSprite *headPhoto=[self convertImageToSprite:photo];
//            headPhoto.scale=80/headPhoto.contentSize.width;
//            headPhoto.position=ccp(150,100);
//            [self addChild:headPhoto];
            
        }];
        
    } else {
        
        [[GKLocalPlayer localPlayer] loadPhotoForSize:GKPhotoSizeNormal withCompletionHandler:^(UIImage *photo, NSError *error) {
            
            if (error==nil) {
                myHead2=[[self convertImageToSprite:photo] retain];
            }else {
                NSLog(@"load photo for error:%@",error);
                myHead2=[[CCSprite spriteWithFile:@"gc_default_head.png"] retain];
            }
            if (isPad) {
                myHead2.scale=60/myHead2.contentSize.width;
                myHead2.anchorPoint=CGPointZero;
                myHead2.position=ccp(42,73);
            }else{
                myHead2.scale=30/myHead2.contentSize.width;
                myHead2.anchorPoint=CGPointZero;
                myHead2.position=ccp(5,5);
            }
            [self addChild:myHead2 z:kDeepForUILayer];
//            CCSprite *headPhoto=[self convertImageToSprite:photo];
//            headPhoto.scale=80/headPhoto.contentSize.width;
//            headPhoto.position=ccp(150,100);
//            [self addChild:headPhoto];
            
        }];
        
        GKPlayer *player = [[GCHelper sharedInstance].playersDict objectForKey:otherID];
        
        [player loadPhotoForSize:GKPhotoSizeNormal withCompletionHandler:^(UIImage *photo, NSError *error) {
            
            if (error==nil) {
                otherPlayerHead2=[[self convertImageToSprite:photo] retain];
            }else {
                NSLog(@"load photo for error:%@",error);
                otherPlayerHead2=[[CCSprite spriteWithFile:@"gc_default_head.png"] retain];
            }
            if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
                otherPlayerHead2.scale=30/otherPlayerHead2.contentSize.width;
                otherPlayerHead2.anchorPoint=CGPointZero;
                otherPlayerHead2.position=ccp(444+88,286);
            }else if (isPad) {
                otherPlayerHead2.scale=60/otherPlayerHead2.contentSize.width;
                otherPlayerHead2.anchorPoint=CGPointZero;
                otherPlayerHead2.position=ccp(919,635);
            }else{
                otherPlayerHead2.scale=30/otherPlayerHead2.contentSize.width;
                otherPlayerHead2.anchorPoint=CGPointZero;
                otherPlayerHead2.position=ccp(444,286);
            }
            [self addChild:otherPlayerHead2 z:kDeepForUILayer];
//            CCSprite *headPhoto=[self convertImageToSprite:photo];
//            headPhoto.scale=80/headPhoto.contentSize.width;
//            headPhoto.position=ccp(50,100);
//Users/dijk/Downloads/DeepSeaHunt v2.2/DeepSeaHunt/AdsMoGoLib/AdNetworkLibs/Baidu_3.2_SDK/Juhe/lib/ZipArchive/minizip/unzip.c:982:9: Add explicit braces to avoid dangling else/            [self addChild:headPhoto];
            
        }];        
    }
    
}
- (void)setupStringsWithOtherPlayerId:(NSString *)otherPlayer {
    
    name=[GKLocalPlayer localPlayer].alias;
    GKPlayer *player = [[GCHelper sharedInstance].playersDict objectForKey:otherPlayer];
    //GKPlayer *player=[GKPlayer ];
    otherPlayerName=player.alias;
    NSLog(@"==========other player name=%@   other player:%@",otherPlayerName,otherPlayer);
    
}
-(CCSprite *) convertImageToSprite:(UIImage *) image {
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addCGImage:image.CGImage forKey:kCCResolutionUnknown];
    CCSprite    *sprite = [CCSprite spriteWithTexture:texture];
    return sprite;
}

//-(void)createBulletWithConnon:(int)angle level:(int)l tag:(int)bulletTag
//{
//    [connon createButtle];
//}
//-(void)createBulletWithOtherConnon:(int)angle level:(int)l tag:(int)bulletTag
//{
//    [otherConnon createButtle];
//}
- (void)dealloc
{
	[super dealloc];
}
#pragma mark GCHelperDelegate

- (void)matchStarted { 
    
    CCLOG(@"Match started"); 
    [self showPlayerInfoLoading];
    [self setGameState:kGameStateChoiceHost];

    [self sendRandom];
}

- (void)matchEnded { 
    CCLOG(@"Match ended"); 
    [self showPlayerExitAlert];
    [[GCHelper sharedInstance].match disconnect];
    [GCHelper sharedInstance].match = nil;
    //[self endScene:kEndReasonDisconnect];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)fromID {
//    CCLOG(@"Received data");
    
    if (otherPlayerID == nil) {
        otherPlayerID = [fromID retain];
//        [self getLocalPayerHead];
//        [self getRivalPlayerHead];
        NSLog(@"==========otherPlayerID and form id:%@  ",fromID);
    }
    Message *message = (Message *) [data bytes];
    if (message->messageType == kMessageTypeChoiceHost&&!isChoiceHost) {
        MessageChoiceHost * messageInit = (MessageChoiceHost *) [data bytes];
        CCLOG(@"Received random number: %ud, ours %ud", messageInit->randomNumber, ourRandom);
        bool tie =false;
        if (messageInit->randomNumber == ourRandom) {
            CCLOG(@"TIE!");
            tie =true;
            ourRandom = arc4random();
            [self sendRandom];
        } else if (ourRandom > messageInit->randomNumber) { 
            CCLOG(@"We are host");
            isHost = YES; 
            playerID=kPlayerID_Host;
        } else {
            CCLOG(@"We are not host");
            isHost = NO;
            hostID=fromID;
            playerID=kPlayerID_2;
            NSLog(@"主机的名字:%@",fromID);
        }
        if (!tie) {
            //设定为选择主机完成
            isChoiceHost = YES; 
            //获取对方设备信息
            otherDeviceValue=messageInit->deviceValue;
            //获取双方名字
            [self setupStringsWithOtherPlayerId:fromID];

        }
    } else if (message->messageType == kMessageTypeGameBegin) { 
        NSLog(@"收到游戏开始消息");
        [self setGameState:kGameStateGameIng];
        //get the start message ,start timer
        [self schedule:@selector(gameTimerUpdate) interval:1.0f];
        [self playBackGroundMusic];
        NSLog(@"非主机进入游戏状态!!!");
    }else if (message->messageType == kMessageTypeGameOver) { 
        
        MessageGameOver * messageGameOver = (MessageGameOver *) [data bytes];
        CCLOG(@"Received game over with player 1 won: %d", messageGameOver->player1Won);
        
        if (messageGameOver->player1Won) {
            //[self endScene:kEndReasonLose]; 
        } else {
            //[self endScene:kEndReasonWin]; 
        }
        
    }
//    else if(message->messageType == kMessageTypeCreateFish) {
//
//        MessageCreateFish *mCreateFish=(MessageCreateFish *)[data bytes];
//  
//        CGPoint temPoint=[self toThisPosition:mCreateFish->point];
//
//        float speed=[self toThisSpeed:mCreateFish->speed];
//        
////        CGPoint tem2=[self positionToAngleTurn:temPoint];
//        [self createFish:mCreateFish->fishType fishSpeed:speed fishAngle:[self angleToAngleTurn:mCreateFish->angle] fishPoint:[self positionToAngleTurn:temPoint] fishTag:mCreateFish->tag playerID:kPlayerID_Null];
//
//    }
    else if(message->messageType == kMessageTypeInitDone) {
        otherPlayerIsInitDone=true;
    }else if (message->messageType==kMessageTypeFishTurnAngle) {

        MessageFishTurnAngle *message=(MessageFishTurnAngle*)[data bytes];
        CGPoint temPoint=[self toThisPosition:message->point];
        CCNode *node=[fishBatchNode getChildByTag:message->tag];
        
//        NSAssert([node isKindOfClass:[UFish class]],@"not a fish!");
        
        UFish *fish=(UFish *)node;
        
        fish.position=[self positionToAngleTurn:temPoint];
        
//        CGPoint tem2=[self positionToAngleTurn:temPoint];
//        NSLog(@"改变鱼的坐标22 x=%f    y=%f",tem2.x,tem2.y);
        
        [fish upDataAngleAndPosition:[self angleToAngleTurn:message->angle]];//[self angleToAngleTurn:message->angle]
       
    }else if (message->messageType==kMessageTypeFire) {
        MessageFire *fireMessage=(MessageFire*)[data bytes];
        
        if (fireMessage->playerID==playerID) {//自己的
            [connon fireForOther:fireMessage->angle];
        }else {
            [otherConnon fireForOther:-fireMessage->angle];
            [otherConnon setConnonLevel:fireMessage->level];
        }
        //创建子弹
//      [otherConnon fire:-fireMessage->angle level:otherConnon.level tag:(int)];

    }else if (message->messageType==kMessageTypeCreateFishSchool) {//创建鱼群消息
        MessageCreateFishSchool *fishSchoolMessage=(MessageCreateFishSchool *)[data bytes];
        
        int type=fishSchoolMessage->type;
        float speed=[self toThisSpeed:fishSchoolMessage->speed];
        float angle=[self angleToAngleTurn:fishSchoolMessage->angle];
        int num=fishSchoolMessage->num;
        
//      newFishSchool=[[UFishSchool alloc] init];
        
        for (int i=0; i<num; i++) {
            FishData fishData= fishSchoolMessage->fishArr[i];
            
            CGPoint temPoint=[self toThisPosition:fishData.point];
            
            UFish *fish = [[UFish alloc] init:type frame:[fishSprireArr objectAtIndex:type] speed:speed angle:angle state:0 fishPoint:[self positionToAngleTurn:temPoint] playerID:playerID];//speed==4
            fish.fishID=fishData.tag;
            
            [fishArray addObject:fish];
            
            [fishBatchNode addChild:fish z:0 tag:fish.fishID];
//          [newFishSchool addFish:fish];
        }

//        [self addChild:newFishSchool];
//        [fishSchoolArray addObject:newFishSchool];
    }else if (message->messageType==kMessageTypeStartGame) {
        [self showPlayerHeadAndName];

    }else if (message->messageType==kMessageTypeRemoveFish) {
//        NSLog(@"接收到清除鱼的消息!");
        MessageRemoveFish *messageRemoveFish=(MessageRemoveFish*)[data bytes];
        CCNode *node=[fishBatchNode getChildByTag:messageRemoveFish->fishID];
//        NSAssert([node isKindOfClass:[UFish class]],@"not a fish!");
        UFish *fish=(UFish *)node;
//      [self removeFish:fish isClean:YES];
        [fishArray removeObject:fish];//将鱼从数组中删除
        [fishBatchNode removeChild:fish cleanup:YES];//从界面上清除并清理掉
    }else if (message->messageType==kMessageTypeFishDeath) {
//        NSLog(@"接收到鱼死亡消息!");
        MessageFishDeath *messageFishDeath=(MessageFishDeath*)[data bytes];
        CCNode *node=[fishBatchNode getChildByTag:messageFishDeath->fishID];
//        NSAssert([node isKindOfClass:[UFish class]],@"not a fish!");
        UFish *fish=(UFish *)node;
        
        fish.beKillPlayer=messageFishDeath->beKillPlayer;
        [fishArray removeObject:fish];
        [fish death];
        
    }else if (message->messageType==kMessageTypeTurnConnonLevel) {
        MessageTurnConnonLevel *turnConnonLevelMessage=(MessageTurnConnonLevel*)[data bytes];
        if (turnConnonLevelMessage->pid==playerID) {
//            connon.level=turnConnonLevelMessage->level;
            [connon setConnonLevel:turnConnonLevelMessage->level];
        }else {
//            otherConnon.level=turnConnonLevelMessage->level;
             [otherConnon setConnonLevel:turnConnonLevelMessage->level];
        }
        
    }else if (message->messageType==kMessageTypeTurnConnonLevelRequest) {
        MessageTurnConnonLevelRequest *turnConnonLevelRequestMessage=(MessageTurnConnonLevelRequest*)[data bytes];
        if (turnConnonLevelRequestMessage->pid==otherConnon.playerID) {
//            otherConnon.level=turnConnonLevelRequestMessage->level;
            [otherConnon setConnonLevel:turnConnonLevelRequestMessage->level];
        }
        [self sendTurnConnonLevel:turnConnonLevelRequestMessage->level playerID:turnConnonLevelRequestMessage->pid];
    }else if (message->messageType==kMessageTypeExit) {
        NSLog(@"游戏结束!");
        [self showPlayerExitAlert];

    }else if (message->messageType==kMessageTypeStoreUp) {
        MessageStoreUp *mStoreUp=(MessageStoreUp *)[data bytes];
        if (playerID!=mStoreUp->playerID) {
            [otherConnon storeUp:mStoreUp->angle];
        }
    }else if (message->messageType==kMessageTypeLaserFire) {
        MessageLaserFire *mLaserFire=(MessageLaserFire*)[data bytes];
        if (playerID!=mLaserFire->playerID) {
            [otherConnon laser:mLaserFire->angle];
        }
    }else if(message->messageType==kMessageTypeDataRenew){
        MessageDataRenew *mRenew=(MessageDataRenew *)[data bytes];
        if (playerID==mRenew->pid) {
            gold=mRenew->nowGold;
            score=mRenew->nowScore;
            [connon addLaserSP:mRenew->nowSp];
        }else{
            rivalGold=mRenew->nowGold;
            rivalScore=mRenew->nowScore;
            [otherConnon addLaserSP:mRenew->nowSp];
        }
    }else if (message->messageType==kMessageTypeTimerRenew){
        MessageTimerRenew *mTimerRenew=(MessageTimerRenew *)[data bytes];
        timer=mTimerRenew->timer;
    }
    
}
- (void)inviteReceived
{
    NSLog(@"邀请之后的回调函数!");
}
//微博部分

-(void)share
{
    [self shareForGameResult];
    //检查网络
//    if ([CheckNetwork isExistenceNetwork]) {
//        [self shareMethod];
//    }
}

- (void) shareForGameResult
{
    // 设定截图大小
    CCRenderTexture  *target = [CCRenderTexture renderTextureWithWidth:GAME_SCENE_SIZE.width height:GAME_SCENE_SIZE.height];
    [target begin];
    
    // 添加需要截取的CCNode
    [self visit];
    [target end];
    UIImage *sharedImage=[[target getUIImage] retain];
    
    ///dijk 2016-05-21
    /*UMSocialIconActionSheet *iconActionSheet = [[UMSocialControllerService defaultControllerService] getSocialIconActionSheetInController:[CCDirector sharedDirector]];
    //    UIViewController *rootViewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
    //    [iconActionSheet showInView:rootViewController.view];
    [iconActionSheet showInView:[[CCDirector sharedDirector] view]];
    [UMSocialData defaultData].shareImage = sharedImage;//[UIImage imageNamed:@"Icon.png"]
    [UMSocialData defaultData].shareText =[NSString stringWithFormat:@"刚刚我在捕鱼达人中与高手进行了一次世纪大对决，现在向你发起挑战，你敢接战吗？下载地址%@",@"https://itunes.apple.com/cn/app/bu-yu-da-ren-mian-fei-ban/id447330270?mt=8"];
    */
}

#pragma mark - the player exit 

-(void)showPlayerExitAlert
{
    if (gameState==kGameStateWaitingForMatch||gameState==kGameStateInitPlayerData
        ||gameState==kGameStateChoiceHost||gameState==kGameStateInitGameData) {
        [self playerDisconnectedAlert];
        gameState=kGameStateDisconnect;
        return;
    }
    
    
    if (gameState==kGameStateDisconnect||gameState==kGameStateGameOver) {
        return;
    }
    gameState=kGameStateDisconnect;

    self.isTouchEnabled=NO;
    CCLayer *temLayer=[CCLayer node];
    [self addChild:temLayer z:99 tag:kTagForExitAlert];
    CCSprite *temFrame=[CCSprite spriteWithFile:@"gc_game_end.png"];
    temFrame.position=ccp(GAME_SCENE_SIZE.width/2, GAME_SCENE_SIZE.height/2);
    [temLayer addChild:temFrame];
    
    CCLabelTTF *temNameLabel;
    
    if (isPad) {
        temNameLabel=[CCLabelTTF labelWithString:otherPlayerName dimensions:CGSizeMake(200, 30) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:30];
        temNameLabel.anchorPoint=ccp(0.5f, 0);
        temNameLabel.position=ccp(290, 200);
    }else{
        temNameLabel=[CCLabelTTF labelWithString:otherPlayerName dimensions:CGSizeMake(100, 15) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:15];
        temNameLabel.anchorPoint=ccp(0.5f, 0);
        temNameLabel.position=ccp(145, 100);
    }
    
    [temFrame addChild:temNameLabel];
    
    CCMenuItem *temAffirm=[CCMenuItemImage itemWithNormalImage:@"gc_result_affirm.png" selectedImage:@"gc_result_affirm_.png" target:self selector:@selector(buttonEventForExitAlertOK)];
    if (isPad) {
        temAffirm.position=ccp(temFrame.contentSize.width/2, 70);
    }else{
        temAffirm.position=ccp(temFrame.contentSize.width/2, 35);
    }
    
    CCMenu *temMenu=[CCMenu menuWithItems:temAffirm, nil];
    temMenu.anchorPoint=CGPointZero;
    temMenu.position=CGPointZero;
    [temFrame addChild:temMenu];
}

-(void)buttonEventForExitAlertOK
{
    self.isTouchEnabled=YES;
    CCScene *scene=[UWelcomeScene scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeBL transitionWithDuration:1 scene:scene]];
}

-(void)saveActivateData{
    RecordForgameActivate activate;
    isActivate=YES;
    activate.isActivate=YES;
    NSData *data=[NSData dataWithBytes:&activate length:sizeof(activate)];
    [USave saveGameData:data toFile:kRecordTypeForGameActivate];
}

@end
