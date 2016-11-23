//
//  UGameScene.m
//  DeepSeaHunt
//
//  Created by Unity on 12-10-22.
//  Copyright (c) 2012年 akn. All rights reserved.1
//

#import "UGameScene.h"



#define kFishNumControl 70
#define kFishNumControlForIpad 70
#define kTagMenuLayer 11
#define kTagShopLayer 12
#define kTagBulletBatch 13
#define kTagLevelUPLayer 14
#define kTagHeadBack    15
#define kTagForADInfo   16
#define kTagShowGetGoldBatch 17
#define kTagForNoMoneyInfo 18
#define kTagForJailbrokenInfo 19
#define kTagForSharedPhotoLayer 20
#define kTagForUpdateInfo 22

#define kGetFreeTime 600;
@implementation UGameScene

static int gameLevels[] = {100, 500, 1000, 2000, 3500,
	6000, 10000, 20000, 50000, 100000};

//金币
static int golds[] = { 1, 2, 4, 7, 10, 15, 20, 30, 40, 50 };
//能量
static int sps[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 };
//经验
static int exps[] = { 1, 1, 1, 2, 2, 2, 3, 3, 4, 4, 5 };
//每次升级的金币奖励
static int levelUpGold[]={ 200, 250, 300, 400, 500, 600, 700, 800, 900,1000, 2000};
static NSString *gameLevelName[] = {
	@"新手上路", @"江湖小虾", @"明日之星", @"捕鱼能手", @"海上霸主",
	@"隐士高手", @"绝世奇才", @"捕鱼高人", @"捕鱼大师", @"捕鱼达人", @"天下无敌"
};

static UGameScene *sharedGameScene;

@synthesize gold;
@synthesize power;
@synthesize isRemoveAD;
@synthesize adState;
//@synthesize banner;
@synthesize gameState;
@synthesize moneyForGold;
@synthesize fishSprireArr;

#define kAdViewPortraitRect CGRectMake(0, 0, kBaiduAdViewSizeDefaultWidth, kBaiduAdViewSizeDefaultHeight)

+ (id)scene:(int)p{
    CCScene *scene = [CCScene node];
    UGameScene *layer = [[UGameScene alloc] init:p];
    [scene addChild:layer];
	return scene;
}
+(UGameScene*)sharedScene
{
    return sharedGameScene;
}
-(id)init:(int)p
{
    if (self=[super init]) {
        
        adState=kADStateForHide;
        //设置场景倍率
        power=p;
        //记录控制
        [self recordControl];
        //计费
        UIView *view=[[CCDirector sharedDirector] view];
        tempObserver = [[InAppPur alloc] init:view delegate:self];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:tempObserver];
        
        sharedGameScene=self;
        
        gameingState=kGameingStateNormal;
        gameState=kGameStateForGameing;

        bulletArray=[[NSMutableArray alloc] init];
        fishArray=[[NSMutableArray alloc] init];
        fishSchoolArray=[[NSMutableArray alloc] init];
        
        isTiming=false;
        
        
        CCSprite *temBackGround;
         if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
             temBackGround=[CCSprite spriteWithFile:@"gamescene1-iphone5.png"];
         }else{
             temBackGround=[CCSprite spriteWithFile:@"gamescene1.png"];
         }
        temBackGround.anchorPoint=CGPointZero;
        [self addChild:temBackGround z:-1];
        
        CCMenuItem *temPauseItem=[CCMenuItemImage itemWithNormalImage:@"game_pause.png" selectedImage:@"game_pause_.png" target:self selector:@selector(showMenu)];
        
        CCMenuItem *temPhotoItem=[CCMenuItemImage itemWithNormalImage:@"game_photo.png" selectedImage:@"game_photo_.png"  target:self selector:@selector(gamePhoto)];
        
        temPauseItem.position=ccp(GAME_SCENE_SIZE.width-temPauseItem.contentSize.width,GAME_SCENE_SIZE.height-temPauseItem.contentSize.height*1.2);
        
        temPhotoItem.position=ccp(temPauseItem.position.x-temPauseItem.contentSize.width*3/2,GAME_SCENE_SIZE.height-temPauseItem.contentSize.height*1.2);
        
        
        CCMenu *temMenu=[CCMenu menuWithItems:temPauseItem,temPhotoItem, nil];
        temMenu.position=CGPointZero;
        [self addChild:temMenu z:6];
        
        itemPhoto=temPhotoItem;
        itemPause=temPauseItem;

        //初始化头像和等级
        if (isPad) {
            [self initHeadAndLv:CGPointMake(20, 640)];
        }else {
            [self initHeadAndLv:CGPointMake(20, 260)];
        }
        
//        CCSpriteBatchNode* bulletBatch = [CCSpriteBatchNode batchNodeWithFile:@"bullet6.png"];
//        [self addChild:bulletBatch z:4 tag:kTagBulletBatch];
        
        //BatchNode
        CCSpriteBatchNode* showGetGoldBatch = [CCSpriteBatchNode batchNodeWithFile:@"game_money_icon.png"];
        [self addChild:showGetGoldBatch z:4 tag:kTagShowGetGoldBatch];
        
        fishBatchNode=[CCSpriteBatchNode batchNodeWithFile:@"fish.png"];
        [self addChild:fishBatchNode z:0];
        
        
        [self initRes];
        [self initConnon];
        self.isTouchEnabled=TRUE;
        [self schedule:@selector(createFishControl) interval:0.5];
        [self schedule:@selector(upDateFish) interval:1];
        [self scheduleUpdate];
        [self playBackGroundMusic];
        
        
        [self initMenuLayer];
///----去除mogo广告 dijk 2016-05-21
 /*       if (!isRemoveAD) {
//            NSLog(@"没有去除广告!");
            if (isPad) {
                if (banner!=nil) {
                    adState=kADStateForRun;
                    [banner showAd];
                }
            }else{
                if (banner!=nil) {
                    [banner hideAd];
                }
            }
        }else{
//             NSLog(@"已去除广告!");
        }
  */
//       [self getUpDateGoldFor2_2];
    }
  
///----去除mogo广告 dijk 2016-05-21
    
    ///dijk 2016-05-21 百度广告 启动广告，自定义开屏广告
    self.isInVideo = @"1";
    self.customWidth = @"300";
    self.customHeight = @"300";
    [self loadInterAd];
    
    sharedAdView = nil;
    
    return self;
}
//记录控制
//1.读取游戏记录，如果不存在记录则判断是否存在旧版的记录，如果存在则进行转移
- (void)recordControl
{
    //记录处理
    
    RecordForGameData_2_2 *record=[self getGameDataRecord];
    if (record!=nil) {
        nowEXP=record->nowEXP;
        needEXP=record->needEXP;
        playerLevel=record->nowLevel;
        gold=goldShow=record->nowGold;
        sp_1=record->nowSP_1;
        sp_5=record->nowSP_5;
        sp_20=record->nowSP_20;
        sp_50=record->nowSP_50;
        sp_100=record->nowSP_100;
        [self setGoldShow:goldShow];
        if (record->isRemoveAD) {
            isRemoveAD=record->isRemoveAD;
            //去除广告就不初始化广告
            adState=kADStateForNoAD;
        }else
        {
            isRemoveAD=NO;
            ///dijk 2016-05-21
            //banner=[[Mogo_ad alloc] init];
            //[[[CCDirector sharedDirector] view]addSubview:banner.viewController.view];
        }
    }else {
        //该版本的记录不存在的时候  获取旧版记录是否存在  存在则对记录进行转移
        
        if ([self isHaveDataFor2_1]) {
            RecordForGameData *temRecord=(RecordForGameData*)[[USave readGameData:kRecordTypeForGameData] bytes];
            RecordForGameData_2_2 record;
            record.nowLevel=temRecord->nowLevel;
            record.nowGold=temRecord->nowGold+1000;
            record.nowSP_1=temRecord->nowSP;
            record.nowSP_5=0;
            record.nowSP_20=0;
            record.nowSP_50=0;
            record.nowSP_100=0;
            record.nowEXP=temRecord->nowEXP;
            record.needEXP=temRecord->needEXP;
            record.isRemoveAD=temRecord->isRemoveAD;
            //存储新记录
            NSData *data=[NSData dataWithBytes:&record length:sizeof(record)];
            [USave saveGameData:data toFile:kRecordTypeForGameData2_2];
            //删除2.1记录
            [USave deleteRecord:kRecordTypeForGameData];
            
            nowEXP=temRecord->nowEXP;
            needEXP=temRecord->needEXP;
            gold=goldShow=temRecord->nowGold+1000;
            
            //调用新版本更新增加金币函数
            [self showUpdateInfo];
        }else{
            //经验
            nowEXP=0;
            needEXP=gameLevels[playerLevel];
            gold=goldShow=1000;
        }
        
        [self setGoldShow:goldShow];
        
        ///dijk 2016-05-21
        //banner=[[Mogo_ad alloc] init];
        //[[[CCDirector sharedDirector] view]addSubview:banner.viewController.view];
    }
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
}

//-(CCSpriteBatchNode*)getBulletBatch
//{
//    CCNode* node = [self getChildByTag:kTagBulletBatch];
//    NSAssert([node isKindOfClass:[CCSpriteBatchNode class]], @"not a SpriteBatch"); 
//    
//    return (CCSpriteBatchNode*)node;
//}

-(CCSpriteBatchNode*)getShowGetGoldBatch
{
    CCNode* node = [self getChildByTag:kTagShowGetGoldBatch];
    NSAssert([node isKindOfClass:[CCSpriteBatchNode class]], @"not a SpriteBatch");
    
    return (CCSpriteBatchNode*)node;
}
-(void)initHeadAndLv:(CGPoint)point
{
    playerName=[CCSprite spriteWithFile:@"name.png"];
    [playerName setTextureRect:CGRectMake(0, playerLevel*playerName.contentSize.height/11, playerName.contentSize.width, playerName.contentSize.height/11)];
    CCSprite *headBack=[CCSprite spriteWithFile:@"head_back.png"];
    exp=[[CCSprite spriteWithFile:@"exp.png"] retain];
    CCSprite *headEffect=[CCSprite spriteWithFile:@"effect_head.png"];
    //倒计时
    CCSprite *temGetGoldBack;
    CCLabelAtlas *temTimeLabel;
    BOOL isGiveFreeGold=[self isGetFree];
    NSLog(@"isGiveFreeGold=%d",isGiveFreeGold);
    if (isGiveFreeGold) {
        temGetGoldBack=[CCSprite spriteWithFile:@"gs_getGold_back.png"];
        if (isPad) {
            temTimeLabel=[CCLabelAtlas labelWithString:@"10/00" charMapFile:@"gs_getGold_num.png" itemWidth:23 itemHeight:23 startCharMap:'/'];
        }else{
            temTimeLabel=[CCLabelAtlas labelWithString:@"10/00" charMapFile:@"gs_getGold_num.png" itemWidth:11 itemHeight:11 startCharMap:'/'];
        }
        
        CCMenuItem *temGetGoldItem=[CCMenuItemImage itemWithNormalImage:@"gs_getGold_button.png" selectedImage:@"gs_getGold_button_.png" disabledImage:@"gs_getGold_button_null.png" target:self selector:@selector(getFreeGold)];
        CCMenu *temGetGoldMenu=[CCMenu menuWithItems:temGetGoldItem, nil];
        temGetGoldMenu.anchorPoint=CGPointZero;
        if (isPad) {
            temGetGoldMenu.position=ccp(159, 27);
            temTimeLabel.position=ccp(16, 15);
        }else{
            temGetGoldMenu.position=ccp(76, 14);
            temTimeLabel.position=ccp(8, 8);
        }
        temGetGoldItem.isEnabled=NO;
        
        //----
        getFreeGoldRim=temGetGoldBack;
        getFreeGoldTimeLabel=temTimeLabel;
        getFreeGoldTimeButton=temGetGoldItem;
        
        
        [temGetGoldBack addChild:temTimeLabel];
        [temGetGoldBack addChild:temGetGoldMenu];
    }
    
    
    
    if (isPad) {
        if (isGiveFreeGold) {
            temGetGoldBack.position=ccp(200, -12);
            [headBack addChild:temGetGoldBack];
        }
        
        playerLvLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%d",playerLevel] charMapFile:@"game_level_num.png" itemWidth:42 itemHeight:56 startCharMap:'0'];
        
        playerLvLabel.position=ccp(32,30);
        exp.anchorPoint=CGPointMake(0, 0.5f);
        expSize=exp.contentSize;
        playerName.anchorPoint=CGPointZero;
        playerName.position=ccp(130,30);//ccp(86,274);
        headBack.anchorPoint=CGPointZero;
        headBack.position=point;
        exp.position=ccp(100,43);
        headEffect.anchorPoint=CGPointZero;
        headEffect.position=ccp(0,0);
    }else {
        if (isGiveFreeGold) {
            temGetGoldBack.position=ccp(90, -5);
            [headBack addChild:temGetGoldBack];
        }
        
        playerLvLabel=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%d",playerLevel] charMapFile:@"game_level_num.png" itemWidth:21 itemHeight:28 startCharMap:'0'];
        
        playerLvLabel.position=ccp(15,15);
        exp.anchorPoint=CGPointMake(0, 0.5f);
        expSize=exp.contentSize;
        playerName.anchorPoint=CGPointZero;
        playerName.position=ccp(55,15);//ccp(86,274);
        headBack.anchorPoint=CGPointZero;
        headBack.position=point;
        exp.position=ccp(45,21);
        headEffect.anchorPoint=CGPointZero;
        headEffect.position=ccp(0,0);
    }
    

    
    [exp setTextureRect:CGRectMake(0, 0, nowEXP/needEXP*exp.contentSize.width, exp.contentSize.height)];
    [headBack addChild:exp z:1];
    [headBack addChild:playerName z:2];
    [headBack addChild:playerLvLabel z:2];
    [headBack addChild:headEffect z:3];
    [self addChild:headBack z:5 tag:kTagHeadBack];
    
    //获取当天领取金币的次数,小与3次  再次判断是否时间有进行一半，如果有则继续 如果没有则不需要添加时间倒计时
    
    if (!isGiveFreeGold) {
        return;
    }
    
   NSData* temDate= [USave readGameData:kRecordTypeForGetFreeGold];
    if (temDate!=NULL) {
        RecordForGetFreeGoldData* temGetFreeGoldData=(RecordForGetFreeGoldData*)[temDate bytes];
        if (temGetFreeGoldData) {
            NSLog(@"记录不存在！");
        }
        
        //判断是否是今天  非今天则重新计算  并进行记录
        if (temGetFreeGoldData->date==[self getNowDate]) {
            
            if (temGetFreeGoldData->num<3) {
                getNum=temGetFreeGoldData->num;
                getFreeTimeNum=temGetFreeGoldData->time;
                [getFreeGoldTimeLabel setString:[NSString stringWithFormat:@"%02d/%02d",getFreeTimeNum/60,getFreeTimeNum%60]];
                [self schedule:@selector(getFreeTimeControl) interval:1.0f];
            }else{
            }
        }else{
            getNum=0;
            getFreeTimeNum=kGetFreeTime;
            
            RecordForGetFreeGoldData temRecord;
            temRecord.num=getNum;
            temRecord.time=getFreeTimeNum;
            temRecord.date=[self getNowDate];
            NSData *data=[NSData dataWithBytes:&temRecord length:sizeof(temRecord)];
            [USave saveGameData:data toFile:kRecordTypeForGetFreeGold];
            [getFreeGoldTimeLabel setString:[NSString stringWithFormat:@"%02d/%02d",getFreeTimeNum/60,getFreeTimeNum%60]];
            [self schedule:@selector(getFreeTimeControl) interval:1.0f];
        }
        
       
    }else{//记录为空就重新开始到计时
        getNum=0;
        getFreeTimeNum=kGetFreeTime;
        
        RecordForGetFreeGoldData temRecord;
        temRecord.num=getNum;
        temRecord.time=getFreeTimeNum;
        temRecord.date=[self getNowDate];
        NSData *data=[NSData dataWithBytes:&temRecord length:sizeof(temRecord)];
        [USave saveGameData:data toFile:kRecordTypeForGetFreeGold];
        [getFreeGoldTimeLabel setString:[NSString stringWithFormat:@"%02d/%02d",getFreeTimeNum/60,getFreeTimeNum%60]];
        [self schedule:@selector(getFreeTimeControl) interval:1.0f];
    }

}
//判断是否可以再进行领取免费金币
- (BOOL)isGetFree
{
    /*NSData* temDate= [USave readGameData:kRecordTypeForGetFreeGold];
    if (!temDate) {
        return TRUE;
    }else{
        RecordForGetFreeGoldData* temGetFreeGoldData=(RecordForGetFreeGoldData*)[temDate bytes];
        if (!temGetFreeGoldData) {
            return TRUE;
        }
        //判断是否是今天  非今天则重新计算  并进行记录
        if (temGetFreeGoldData->date==[self getNowDate]) {
            if (temGetFreeGoldData->num<3) {
                return true;
            }else{
                return false;
            }
        }else{
            return true;
        }
    }*/
    return false;
}
//保存当前的倒计时数据
//获取当前时间
- (int)getNowDate
{
    NSDate* now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit;
    NSDateComponents *dd = [cal components:unitFlags fromDate:now];
    int y = [dd year];
    int m = [dd month];
    int d = [dd day];
    
    return y*10000+m*100+d;
}
//再线领取金币计时
- (void)getFreeTimeControl
{
    if (getFreeTimeNum>0) {
        getFreeTimeNum--;
        [getFreeGoldTimeLabel setString:[NSString stringWithFormat:@"%02d/%02d",getFreeTimeNum/60,getFreeTimeNum%60]];
    }else{
        getFreeGoldTimeButton.isEnabled=YES;
        [self unschedule:_cmd];
    }
}

//获取免费金币
- (void)getFreeGold
{
    gold+=200;
    getNum++;
    
    //获得免费金币效果
    if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
        [self freeGoldEffect:200 pos:CGPointMake(80, 260)];
    }else if (isPad) {
        [self freeGoldEffect:200 pos:CGPointMake(200, 640)];
    }else {
        [self freeGoldEffect:200 pos:CGPointMake(80, 260)];
    }
    //判断次数  小于3次就继续倒计时
    getFreeTimeNum=kGetFreeTime;
    getFreeGoldTimeButton.isEnabled=NO;
    
    [self saveGameData];//保存数据
    //记录
    RecordForGetFreeGoldData temRecord;
    temRecord.num=getNum;
    temRecord.time=getFreeTimeNum;
    temRecord.date=[self getNowDate];
    NSData *data=[NSData dataWithBytes:&temRecord length:sizeof(temRecord)];
    [USave saveGameData:data toFile:kRecordTypeForGetFreeGold];
    
    if (getNum<3) {
        //继续倒计时
        [self schedule:@selector(getFreeTimeControl) interval:1.0f];
    }else{
        //隐藏
        getFreeGoldRim.opacity=0;
        [getFreeGoldRim removeFromParentAndCleanup:YES];
    }
    
}
- (void)freeGoldEffect:(int)num pos:(CGPoint)point
{
    int goldW,goldH,timeNum;
    CGPoint destination,moveUp;
    
    if (isPad) {
        goldW=65;
        goldH=75;
        timeNum=450;
        destination= CGPointMake(60, 60);
        
    }else{
        goldW=33;
        goldH=37;
        timeNum=250;
        destination= CGPointMake(20, 20);
        
    }

    for (int i=0; i<5; i++) {//(point+(i-num/2)*goldW)
        if (isPad) {
            moveUp= CGPointMake(0, arc4random()%30+30);
        }else{
            moveUp= CGPointMake(0, arc4random()%20+20);
        }
        CGPoint point2=CGPointMake(point.x+((float)i-2.5)*goldW, point.y);
        UMoney *money=[[UMoney alloc] init:1 point:point2 playerID:kPlayerID_Null] ;
        float time=sqrt((point.x-destination.x)*(point.x-destination.x)+(point.y-destination.y)*(point.y-destination.y))/timeNum;
        id move1=[CCMoveTo actionWithDuration:0.2 position:ccpAdd(point2, moveUp)];
        id delay=[CCDelayTime actionWithDuration:0.5f];
        id move2=[CCMoveTo actionWithDuration:time position:destination];
        id callFun=[CCCallFuncN actionWithTarget:self selector:@selector(deleteGold:)];
        [money runAction:[CCSequence actions:move1,delay,move2,callFun, nil]];
        [self addChild:money z:5];//[self getShowGetGoldBatch]
    }
    
    
    
    int upNum;
    if (isPad) {
        showGetGold=[[CCLabelAtlas alloc]  initWithString:[NSString stringWithFormat:@"/%d",num*power] charMapFile:@"show_get_gold_num.png" itemWidth:40 itemHeight:38 startCharMap:'/'];
        upNum=60;
    }else {
        showGetGold=[[CCLabelAtlas alloc]  initWithString:[NSString stringWithFormat:@"/%d",num*power] charMapFile:@"show_get_gold_num.png" itemWidth:20 itemHeight:19 startCharMap:'/'];
        upNum=30;
    }
    
    showGetGold.position=destination;
    
    
    id moveAction=[CCMoveTo actionWithDuration:3.0f position:ccpAdd(destination, ccp(0,upNum))];
    id fadeOut=[CCFadeOut actionWithDuration:3.0f];
    id callFun2=[CCCallFuncN actionWithTarget:self selector:@selector(deleteShowGetGoldLabel:)];
    
    [showGetGold runAction:[CCSequence actions:[CCSpawn actions:moveAction,fadeOut, nil],callFun2, nil]];
    [self addChild:showGetGold z:5];
}
//广告控制
-(void)ADControl
{
    if (adState==kADStateForBeClose||adState==kADStateForNoAD) {
        return;
    }
    id temMove=[CCMoveTo actionWithDuration:0.5f position:ccp(-[self getChildByTag:kTagHeadBack].contentSize.width*1.5,[self getChildByTag:kTagHeadBack].position.y)];
    id callFun=[CCCallFunc actionWithTarget:self selector:@selector(showAD)];
    
    [[self getChildByTag:kTagHeadBack] runAction:[CCSequence actions:temMove,callFun, nil]];
    
    
}
-(void)showHeadAndLevel
{
    id temMove=[CCMoveTo actionWithDuration:0.5f position:ccp(20,260)];
    [[self getChildByTag:kTagHeadBack] runAction:temMove];
    if (adState==kADStateForBeClose||adState==kADStateForNoAD) {
        return;
    }
    [self scheduleOnce:@selector(ADControl) delay:kTimeWarttingAD];
}
-(void)hideHeadAndLevel
{
    id temMove=[CCMoveTo actionWithDuration:0.5f position:ccp(-[self getChildByTag:kTagHeadBack].contentSize.width*1.5,[self getChildByTag:kTagHeadBack].position.y)];
    [[self getChildByTag:kTagHeadBack] runAction:temMove];
}
-(void)showAD
{
    [self showBannerAD];
    [self hideHeadAndLevel];
    [self scheduleOnce:@selector(hideAD) delay:kTimeShowAD];
}
-(void)hideAD
{
    [self hideBannerAD];
    [self showHeadAndLevel];
}
/// dijk 2016-05-21 去掉mogo广告
-(void)showBannerAD
{
    /*
    if (banner!=nil) {
        if (adState!=kADStateForRun) {
            return;
        }
        
        [banner showAd];
        
        if (!isPad) {
            [self hideHeadAndLevel];
        }
    }
     */
    
    if(sharedAdView == nil){
        ///dijk 2016-05-21 百度广告 启动广告，Banner广告
        //使用嵌入广告的方法实例。
        sharedAdView = [[[BaiduMobAdView alloc] init]autorelease];
        //把在mssp.baidu.com上创建后获得的代码位id写到这里
        sharedAdView.AdUnitTag = @"2015347";
        sharedAdView.AdType = BaiduMobAdViewTypeBanner;
        sharedAdView.frame = kAdViewPortraitRect;
        sharedAdView.delegate = self;
        [[[CCDirector sharedDirector] view] addSubview:sharedAdView];
        [sharedAdView start];
        //[sharedAdView setHidden:true];
    }
    
    ///dijk 2016-05-21 显示Banner广告
    if( sharedAdView != nil){
        //[self hideHeadAndLevel];
        [sharedAdView setHidden:false];
    }
    
}
-(void)hideBannerAD
{
    /*
    if (banner!=nil) {
        if (adState!=kADStateForRun) {
            return;
        }
        [banner hideAd];
        if (!isPad) {
            id temMove=[CCMoveTo actionWithDuration:0.5f position:ccp(20,260)];
            [[self getChildByTag:kTagHeadBack] runAction:temMove];
        }
    }
     */
    ///dijk 2016-05-21 显示Banner广告
    if(sharedAdView != nil){
        [sharedAdView setHidden:true];
        //[self showHeadAndLevel];
    }
    
}
/// dijk 2016-05-21 去掉mogo广告
-(void)initConnon
{
    //炮台背景
    CCSprite *connonBack;
    //雪
    CCSprite *snow;
    if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
        connonBack=[CCSprite spriteWithFile:@"game_cannon_bg-iphone5.png"];
        snow=[CCSprite spriteWithFile:@"snow-iphone5.png"];
    }else{
        connonBack=[CCSprite spriteWithFile:@"game_cannon_bg.png"];
        snow=[CCSprite spriteWithFile:@"snow.png"];
    }
    
    //鹿
    CCSprite *deer=[CCSprite spriteWithFile:@"deer.png"];
    //光效1
    CCSprite *effect_1=[CCSprite spriteWithFile:@"effect_1.png"];
    //光效2
    CCSprite *effect_2=[CCSprite spriteWithFile:@"effect_2.png"];
    //倍率
    CCSprite *temPowerBack=[CCSprite spriteWithFile:@"power_back.png"];
    CCSprite *temPower;
    switch (power) {
        case 1:
            temPower=[CCSprite spriteWithFile:@"power_normal.png"];
            break;
        case 5:
            temPower=[CCSprite spriteWithFile:@"power_5.png"];
            break;
        case 20:
            temPower=[CCSprite spriteWithFile:@"power_20.png"];
            break;
        case 50:
            temPower=[CCSprite spriteWithFile:@"power_50.png"];
            break;
        case 100:
            temPower=[CCSprite spriteWithFile:@"power_100.png"];
            break;
        default:
            break;
    }
    temPower.position=ccp(temPowerBack.contentSize.width/2, temPowerBack.contentSize.height/2);
    [temPowerBack addChild:temPower];
    

    connonBack.anchorPoint=CGPointZero;
    snow.anchorPoint=CGPointZero;
     if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
         temPowerBack.position=ccp(460, 12);
     }else if (isPad){
         temPowerBack.position=ccp(850, 25);
     }else{
         temPowerBack.position=ccp(400, 12);
     }
    
    [connonBack addChild:temPowerBack];
    
    if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
        snow.position=ccp(0,7);
        deer.position=ccp(GAME_SCENE_SIZE.width-deer.contentSize.width,40);
        
    }else if (isPad) {
        snow.position=ccp(0,18);
        deer.position=ccp(GAME_SCENE_SIZE.width-deer.contentSize.width,85);
    }else {
        snow.position=ccp(0,7);
        deer.position=ccp(GAME_SCENE_SIZE.width-deer.contentSize.width,40); 
    }
    
    
    [snow addChild:deer z:1];
    [self addChild:connonBack z:3];
    [connonBack addChild:snow z:2];
    
    //添加2个按钮
    CCMenuItemImage *temItemAdd=[CCMenuItemImage itemWithNormalImage:@"button_add.png" selectedImage:@"button_add_.png" target:self selector:@selector(levelAdd)];
    CCMenuItemImage *temItemDec=[CCMenuItemImage itemWithNormalImage:@"button_dec.png" selectedImage:@"button_dec_.png" target:self selector:@selector(levelDec)];
    
    //添加商城按钮
    CCMenuItemImage *temItemShop=[CCMenuItemImage itemWithNormalImage:@"shop3.png" selectedImage:@"shop1.png" target:self selector:@selector(showShop)];
    
    itemConnonAdd=temItemAdd;
    itemConnonDec=temItemDec;
    itemShop=temItemShop;
    
    //更多推荐按钮
//    CCMenuItemImage *itemMore=[CCMenuItemImage itemWithNormalImage:@"more_game.png" selectedImage:@"more_game_.png"  target:self selector:@selector(more)];
    if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
        temItemAdd.position=ccp(344,15);
        temItemDec.position=ccp(224,15);
        temItemShop.anchorPoint=CGPointZero;
        temItemShop.position=CGPointZero;
    }else if (isPad) {
        temItemAdd.position=ccp(640,30);
        temItemDec.position=ccp(380,30);
        temItemShop.anchorPoint=CGPointZero;
        temItemShop.position=CGPointZero;

    }else {
        temItemAdd.position=ccp(300,15);
        temItemDec.position=ccp(180,15);
        temItemShop.anchorPoint=CGPointZero;
        temItemShop.position=CGPointZero;

//        itemMore.anchorPoint=CGPointZero;
//        itemMore.position=ccp(430,3);
    }
    
    
    
    
    
    
    //添加商城图标动画
    CCSprite *shop=[CCSprite node];
    
    CCAnimation *animation=[CCAnimation animation];
    [animation setDelayPerUnit:0.2f];
    for(int i = 0; i < 3; i++) 
    {
        [animation addSpriteFrameWithFilename:[NSString stringWithFormat:@"shop%d.png",i+1]];
    }	
    
    id action = [CCAnimate actionWithAnimation: animation];
    
    
    [shop runAction:[CCRepeatForever actionWithAction:action]];
    shop.anchorPoint=CGPointZero;
    
    [connonBack addChild:shop z:3];
    
    CCMenu *temMenu=[CCMenu menuWithItems:temItemAdd,temItemDec,temItemShop, nil];
    temMenu.anchorPoint=CGPointZero;
    temMenu.position=CGPointZero;
    [connonBack addChild:temMenu z:1];
    
    //添加光效
    effect_1.anchorPoint=CGPointZero;
    effect_1.position=CGPointZero;
    effect_2.anchorPoint=ccp(1.0f,0);
    effect_2.position=ccp(GAME_SCENE_SIZE.width,0);
    
    [connonBack addChild:effect_1 z:2];
    [connonBack addChild:effect_2 z:2];
    
    //显示金币
    CCSprite *temSp=[CCSprite spriteWithFile:@"game_money_num.png"];
    
    goldLabel=[CCLabelAtlas labelWithString:@"0001000" charMapFile:@"game_money_num.png" itemWidth:temSp.contentSize.width/10 itemHeight:temSp.contentSize.height startCharMap:'0'];
    
    goldLabel.anchorPoint=CGPointZero;
    if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
        goldLabel.position=ccp(60,5);
    }else if (isPad) {
        goldLabel.position=ccp(95,12);
    }else {
        goldLabel.position=ccp(45,5);
    }
    
    
    [self setGoldShow:gold];
    
    [connonBack addChild: goldLabel z:1];
    //显示时间
    goldTime=60;
    
    temSp=[CCSprite spriteWithFile:@"game_time_num.png"];
    goldTimeLabel=[CCLabelAtlas labelWithString:@"60" charMapFile:@"game_time_num.png" itemWidth:temSp.contentSize.width/10 itemHeight:temSp.contentSize.height startCharMap:'0'];
    goldTimeLabel.anchorPoint=CGPointZero;
    if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
        goldTimeLabel.position=ccp(150,6);
    }else if (isPad) {
        goldTimeLabel.position=ccp(280,15);
    }else {
        goldTimeLabel.position=ccp(133,6);
    }
    
    [connonBack addChild: goldTimeLabel z:1];
    
    
    
    connon=[[UConnon alloc] init:kPlayerID_Null];
//    connon.anchorPoint=ccp(0.5f,0.2f);
    if (isPad) {
        connon.position=ccp(GAME_SCENE_SIZE.width/2,60);
    }else {
        connon.position=ccp(GAME_SCENE_SIZE.width/2,30);
    }
    
    RecordForGameData_2_2 *record=[self getGameDataRecord];
    if (record!=nil) {
        switch (power) {
            case 1:
             connon.sp=record->nowSP_1;
                break;
            case 5:
                connon.sp=record->nowSP_5;
                break;
            case 20:
                connon.sp=record->nowSP_20;
                break;
            case 50:
                connon.sp=record->nowSP_50;
                break;
            case 100:
                connon.sp=record->nowSP_100;
                break;
            default:
                break;
        }
        
        [connon setSPShow:connon.sp];
    }
    
    [self addChild:connon z:4];

    
}

//增加经验值
-(void)addExp:(int)e
{
    if (playerLevel==10) {
        return;
    }
    nowEXP+=e;
    if (nowEXP>=needEXP) {
        if (playerLevel<10) {
            nowEXP=nowEXP-needEXP;
            nowEXP=0;
            playerLevel++;
            needEXP=gameLevels[playerLevel];
            [self setPlayerLevel:playerLevel];
            [self setPlayerName:playerLevel];
            [self showLevelUp];
        }else {
            nowEXP=needEXP;
        }
        
    }
    if (exp!=nil) {
        [exp setTextureRect:CGRectMake(0,0, nowEXP/needEXP*expSize.width, expSize.height)];
    }else {
//        NSLog(@"exp为空");
    }
}
-(void)addSP:(int)sp
{
    [connon addLaserSP:sp];
}

//激光
-(void)laser:(int)angle  point:(CGPoint)point
{
    laser=[[ULaser alloc] init:angle];
    [self addChild:laser z:4];
    laser.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];
    
    [self schedule:@selector(checkLaserCollide) interval:0.5f];
    
    if( CGPointEqualToPoint(laser.sourcePosition, CGPointZero ) )
        laser.position = point;
    [self scheduleOnce:@selector(turnGravity) delay:3];
    
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

-(void)setPlayerName:(int)level
{
    [playerName setTextureRect:CGRectMake(0, playerLevel*playerName.contentSize.height, playerName.contentSize.width, playerName.contentSize.height)];
}
-(void)setPlayerLevel:(int)level
{
    [playerLvLabel setString:[NSString stringWithFormat:@"%d",playerLevel]];
}
-(void)showShop
{
//    NSLog(@"显示商店");
    if (gameState==kGameStateForShop) {
        [self closeShop];
    }else {
        [self showShopLayer];
        
    }
}

-(void)more
{
//    NSLog(@"更多推荐");
}
-(void)levelAdd
{
        connon.level++;
        if (connon.level>kLevel_7) {
            connon.level=kLevel_1;
        }
        [connon setConnonLevel:connon.level];

//    NSLog(@"等级增加=%d",connon.level);
}
-(void)levelDec
{
        connon.level--;
        if (connon.level<kLevel_1) {
            connon.level=kLevel_7;
        }
        [connon setConnonLevel:connon.level];

//    NSLog(@"等级降低=%d",connon.level);
}
-(void)showShopLayer
{
//    if ([UGameTools isJailbroken]) {
//        [self showJailbrokenInfo];
//        return;
//    }
    ///dijk 2016-05-21
    //[MobClick event:@"open_shop"];
    
    shopLayer=[[UShopLayer alloc] init:self];
    [self addChild:shopLayer z:99];
    
    gameState=kGameStateForShop;
    
    [self gamePause];
    [self hideBannerAD];
    [self pauseAllMenuEnable];
    itemShop.isEnabled=YES;
}
-(void)gamePause{
    [self pauseSchedulerAndActions];
    self.isTouchEnabled=NO;
    for (UFish *fish in fishArray) {
        [fish pauseSchedulerAndActions];
    }
    for (UFishSchool *fishSchool in fishSchoolArray) {
        [fishSchool pauseSchedulerAndActions];
    }
    
}
-(void)gameResume
{
    [self resumeSchedulerAndActions];
    self.isTouchEnabled=YES;
    for (UFish *fish in fishArray) {
        [fish resumeSchedulerAndActions];
    }
    for (UFishSchool *fishSchool in fishSchoolArray) {
        [fishSchool resumeSchedulerAndActions];
    }
}

//-(void)pauseShopMenu
//{
//    CCMenu *temMenu=(CCMenu *)[[[self getChildByTag:kTagShopLayer] getChildByTag:1] getChildByTag:1];
//    
//    if (temMenu!=nil) {
//        [temMenu setEnabled:NO];
//    }
//    
//}
//-(void)resumeShopMenu
//{
//    CCMenu *temMenu=(CCMenu *)[[[self getChildByTag:kTagShopLayer] getChildByTag:1] getChildByTag:1];
//    
//    if (temMenu!=nil) {
//        [temMenu setEnabled:YES];
//    }
//}
#pragma mark - UShopDelegate
-(void)closeShop
{
    [shopLayer removeFromParentAndCleanup:YES];
    [self resumeAllMenuEneble];
//  [self resumeButtonEvent];
    [self gameResume];
    [self showBannerAD];
//    NSLog(@"关闭商店");
    gameState=kGameStateForGameing;
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
#pragma mark - 付费接口
-(void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    NSLog(@"finishTransaction#######");
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        NSLog(@"交易成功后的处理,交易的ID=%@",transaction.payment.productIdentifier);
        //        [UGameScene shardScene].isRemoveAD=YES;
        if (!isPad) {
//            adState=kADStateForNoAD;
            [self showHeadAndLevel];
        }

        if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_6]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"6元",@"type",nil];
            ///dijk 2016-05-21
            //[MobClick event:@"pay_ok" attributes:dict];
            [self addMoney:500];//200
            [self saveGameData];
        }
        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_12]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"12元",@"type",nil];
            ///dijk 2016-05-21
            //[MobClick event:@"pay_ok" attributes:dict];
            [self addMoney:1500];//500
            [self saveGameData];
        }
        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_18]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"18元",@"type",nil];
            ///dijk 2016-05-21
            //[MobClick event:@"pay_ok" attributes:dict];
            [self addMoney:3500];//1000
            [self saveGameData];
        }
        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_25]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"25元",@"type",nil];
            ///dijk 2016-05-21
            //[MobClick event:@"pay_ok" attributes:dict];
            [self addMoney:8000];//1500
            [self saveGameData];
        }
        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_30]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"30元",@"type",nil];
            ///dijk 2016-05-21
            //[MobClick event:@"pay_ok" attributes:dict];
            [self addMoney:18000];//2000
            [self saveGameData];
        }
        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_60]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"60元",@"type",nil];
            ///dijk 2016-05-21
            //[MobClick event:@"pay_ok" attributes:dict];
            [self addMoney:40000];//5000
            [self saveGameData];
        }
        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_128]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"128元",@"type",nil];
            ///dijk 2016-05-21
            //[MobClick event:@"pay_ok" attributes:dict];
            [self addMoney:70000];//15000
            [self saveGameData];
        }
        else if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProductIdForPay_258]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"258元",@"type",nil];
            ///dijk 2016-05-21
            //[MobClick event:@"pay_ok" attributes:dict];
            [self addMoney:120000];//50000
            [self saveGameData];
        }

        // send out a notification that we’ve finished the transaction
		//[progressInd stopAnimating];
        //		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		//downNum = -1;
		//NSNumber *num = [NSNumber numberWithInt:downNum];
		//[prefs setObject:num forKey:kIsIAPurKey];
        
        //		[prefs synchronize];
		
        //	[ReaderViewController back];
        //	[SexSafeMainView fun];
		[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        // send out a notification for the failed transaction
		NSLog(@"交易失败后的处理");
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
        
    }

}
-(void)payOK{
    NSLog(@"payOK#######");
    [shopLayer resumeShopMenu];
}
-(void)payLose{
    NSLog(@"payLose#######");
    [shopLayer resumeShopMenu];
}
-(void)restore{
    NSLog(@"restore#######");
   [shopLayer resumeShopMenu];
}



-(void)initMenuLayer
{
    CCLayer *temMenuLayer=[CCLayer node];
    
    
    CCSprite *menuBack=[CCSprite spriteWithFile:@"menu_back.png"];
    

    menuBack.position=ccp(GAME_SCENE_SIZE.width/2,GAME_SCENE_SIZE.height/2+GAME_SCENE_SIZE.height/10);
    

    
    CCMenuItemImage *itemResume=[CCMenuItemImage itemWithNormalImage:@"menu_resume.png" selectedImage:@"menu_resume_.png" target:self selector:@selector(resumeButtonEvent)];
    CCMenuItemImage *itemHelp=[CCMenuItemImage itemWithNormalImage:@"menu_help.png" selectedImage:@"menu_help_.png" target:self selector:@selector(helpButtonEvent)];
    CCMenuItemImage *itemSetting=[CCMenuItemImage itemWithNormalImage:@"menu_setting.png" selectedImage:@"menu_setting_.png" target:self selector:@selector(settingButtonEvent)];
    CCMenuItemImage *itemMainMenu=[CCMenuItemImage itemWithNormalImage:@"menu_main.png" selectedImage:@"menu_main_.png" target:self selector:@selector(mainMenuButtonEvent)];
     
    if (isPad) {
        
        itemResume.position=ccpAdd(menuBack.position, ccp(0,140));
        itemMainMenu.position=ccpAdd(menuBack.position, ccp(0,26));
        itemHelp.position=ccpAdd(menuBack.position, ccp(0,-85));
        itemSetting.position=ccpAdd(menuBack.position, ccp(0,-190));
        
    }else{
        
        itemResume.position=ccpAdd(menuBack.position, ccp(0,60));
        itemMainMenu.position=ccpAdd(menuBack.position, ccp(0,12));
        itemHelp.position=ccpAdd(menuBack.position, ccp(0,-35));
        itemSetting.position=ccpAdd(menuBack.position, ccp(0,-81));
       
    }
    
    
    
    CCMenu *temMenu=[CCMenu menuWithItems:itemResume,itemHelp,itemSetting,itemMainMenu, nil];
    temMenu.position=CGPointZero;
    
    
    

    
    [temMenuLayer addChild:menuBack z:0];

    [temMenuLayer addChild:temMenu z:2];
    
//    temMenuLayer.visible=false;
    [self addChild:temMenuLayer z:99 tag:kTagMenuLayer];
     temMenuLayer.visible=false;
}
-(void)showMenuLayer
{
    gameState=kGameStateForMenu;
    CCLayer *temMenuLayer=(CCLayer *)[self getChildByTag:kTagMenuLayer];
    temMenuLayer.visible=true;
    //暂停界面动作
    [self gamePause];
    
}
-(void)hideMenuLayer
{
    gameState=kGameStateForGameing;
    CCLayer *temMenuLayer=(CCLayer *)[self getChildByTag:kTagMenuLayer];
    temMenuLayer.visible=false;
    //重新让界面动起来
    [self gameResume];
    [self showBannerAD];
}

-(void)resumeButtonEvent
{
//    NSLog(@"继续游戏");
    [self hideMenuLayer];
}

-(void)helpButtonEvent
{
//     NSLog(@"帮助");
    [self hideBannerAD];
    
    CCScene *scene=[UHelpScene scene];
    [[CCDirector sharedDirector] pushScene:[CCTransitionFadeBL transitionWithDuration:1 scene:scene]];
    
}
-(void)settingButtonEvent
{
//     NSLog(@"设置");
    [self hideBannerAD];
    
    CCScene *scene=[USettigScene scene];
    [[CCDirector sharedDirector] pushScene:[CCTransitionFadeBL transitionWithDuration:1 scene:scene]];
}
-(void)mainMenuButtonEvent
{
//     NSLog(@"主菜单");
    [self hideBannerAD];
    
    [self saveGameData];//保存数据
    
    //记录
    RecordForGetFreeGoldData temRecord;
    temRecord.num=getNum;
    temRecord.time=getFreeTimeNum;
    temRecord.date=[self getNowDate];
    NSData *data=[NSData dataWithBytes:&temRecord length:sizeof(temRecord)];
    [USave saveGameData:data toFile:kRecordTypeForGetFreeGold];
    
    CCScene *scene=[UWelcomeScene scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeBL transitionWithDuration:1 scene:scene]];
}

-(void)showMenu
{

    if (gameState==kGameStateForShop||gameState==kGameStateForLevelUp) {
        return;
    }
//     NSLog(@"显示菜单");
    CCLayer *temMenuLayer=(CCLayer*)[self getChildByTag:kTagMenuLayer];
        
    if (temMenuLayer.visible==false) {
//        NSLog(@"暂停状态");
        [self showMenuLayer];
        [self hideBannerAD];
    }else{
//        NSLog(@"菜单状态");
        [self hideMenuLayer];
        [self showBannerAD];
    }
    
    
}
- (UIImage *)captureView:(UIView *)view withArea:(CGRect)screenRect {
    
    UIGraphicsBeginImageContext(screenRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
    [view.layer renderInContext:ctx];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
#pragma mark - 截图及分享
-(void)gamePhoto
{

    
    // 设定截图大小
    CCRenderTexture  *target = [CCRenderTexture renderTextureWithWidth:GAME_SCENE_SIZE.width height:GAME_SCENE_SIZE.height];
    [target begin];
    
    // 添加需要截取的CCNode
    [self visit];
    [target end];
    
    UIImageWriteToSavedPhotosAlbum([target getUIImage], self, nil, nil);//getUIImageFromBuffer
    sharedImage=[[target getUIImage] retain];
    
    CCLayer *temLayer=[CCLayerColor layerWithColor:ccc4(255, 255, 255, 255)];
    id fadeOut=[CCFadeOut actionWithDuration:0.5];
    id callF=[CCCallFuncN actionWithTarget:self selector:@selector(deletePhotoTem:)];
    [temLayer runAction:[CCSequence actions:fadeOut,callF, nil]];
    [self addChild:temLayer z:99];
    
    [self showSharedPhoto:[target getUIImage]];
//     NSLog(@"拍照");
//    [self cleanFish];
//    [self showLevelUp];
}
-(CCSprite *) convertImageToSprite:(UIImage *) image {
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addCGImage:image.CGImage forKey:kCCResolutionUnknown];
    CCSprite    *sprite = [CCSprite spriteWithTexture:texture];
    return sprite;
}
- (void)pauseAllMenuEnable
{
   
    //暂停及截屏按钮
    itemShop.isEnabled=NO;
    itemConnonAdd.isEnabled=NO;
    itemConnonDec.isEnabled=NO;
    itemPhoto.isEnabled=NO;
    itemPause.isEnabled=NO;
}
- (void)resumeAllMenuEneble
{
    //暂停及截屏按钮
    itemShop.isEnabled=YES;
    itemConnonAdd.isEnabled=YES;
    itemConnonDec.isEnabled=YES;
    itemPhoto.isEnabled=YES;
    itemPause.isEnabled=YES;
}
- (void)showSharedPhoto:(UIImage*)image
{
    [self gamePause];
    
    //暂定界面上按钮的功能
    [self pauseAllMenuEnable];
    
    CCLayerColor *sharedLayer=[CCLayerColor layerWithColor:ccc4(0, 0, 0, 80)];
    
    CCSprite *sharedFrame=[CCSprite spriteWithFile:@"shared_photo_frame.png"];
    CCSprite *photo=[self convertImageToSprite:image];
    
    if (isPad) {
        photo.rotation=-6.5f;
        photo.position=ccp(sharedFrame.contentSize.width/2-5, sharedFrame.contentSize.height/2+20);
        photo.scale=500/photo.contentSize.width;
        sharedFrame.position=ccp(GAME_SCENE_SIZE.width/2, 420);
    }else{
        photo.rotation=-6.5f;
        photo.position=ccp(sharedFrame.contentSize.width/2-3, sharedFrame.contentSize.height/2+10);
        photo.scale=200/photo.contentSize.width;
        sharedFrame.position=ccp(GAME_SCENE_SIZE.width/2, 190);
    }
    [sharedFrame addChild:photo];
    
    
    CCMenuItem *temItem_return=[CCMenuItemImage itemWithNormalImage:@"shared_b_return.png" selectedImage:@"shared_b_return_.png" target:self selector:@selector(sharedReturnButtonEvent)];
    CCMenuItem *temItem_shared=[CCMenuItemImage itemWithNormalImage:@"shared_b_shared.png" selectedImage:@"shared_b_shared_.png" target:self selector:@selector(sharedPhotoButtonEvent)];
    
    
    CCMenu *temMenu=[CCMenu menuWithItems:temItem_return,temItem_shared, nil];
    if (isPad) {
        temMenu.position=ccp(0, 0);
        temItem_return.position=ccp(160, -5);
        temItem_shared.position=ccp(440,-5);
    }else{
        temMenu.position=ccp(0, 0);
        temItem_return.position=ccp(70, -5);
        temItem_shared.position=ccp(180,-5);
    }
    [sharedFrame addChild:temMenu];
    [sharedLayer addChild:sharedFrame];
    [self addChild:sharedLayer z:99 tag:kTagForSharedPhotoLayer];
    
}
- (void)sharedReturnButtonEvent
{
    [self gameResume];
    [self resumeAllMenuEneble];
    CCLayerColor *temLayer=(CCLayerColor *)[self getChildByTag:kTagForSharedPhotoLayer];
    [temLayer removeFromParentAndCleanup:YES];
    
    NSLog(@"关闭分享界面");
}
- (void)sharedPhotoButtonEvent
{
//    [self gameResume];
//    [self resumeAllMenuEneble];
    ///dijk 2016-05-21
    /*
     UMSocialIconActionSheet *iconActionSheet = [[UMSocialControllerService defaultControllerService] getSocialIconActionSheetInController:[CCDirector sharedDirector]];    
//    UIViewController *rootViewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
//    [iconActionSheet showInView:rootViewController.view];
    [iconActionSheet showInView:[[CCDirector sharedDirector] view]];
    [UMSocialData defaultData].shareImage = sharedImage;//[UIImage imageNamed:@"Icon.png"]
    [UMSocialData defaultData].shareText = @"捕鱼达人，当前最受欢迎的手机游戏之一，大家一起来玩呀。游戏下载地址：https://itunes.apple.com/cn/app/bu-yu-da-ren-mian-fei-ban/id447330270?mt=8";
    */
    NSLog(@"进入分享");
}

-(void)deletePhotoTem:(id)sender
{
    [sender removeFromParentAndCleanup:YES];
//    [sender release];
}
#pragma mark - 在线领取金币

- (void)showOnlineGoldReward
{
    
}

-(void)connonFire:(CGPoint)location
{
    CGPoint gunPoint=ccpAdd(connon.position, CGPointZero);//connon.turnDot
    double w = location.x - gunPoint.x;
    double h = abs(location.y - gunPoint.y);
    double radian = atan(w/h);
    double degrees = CC_RADIANS_TO_DEGREES(radian);
//    NSLog(@"radian =%f   degrees=%f",radian,degrees);
    [connon fire:degrees];
//    [connon createButtle:degrees level:connon.level tag:temTag];
    
}
-(void)createButtle:(int)level point:(CGPoint)pos angle:(float)angle
{
    
        UBullet *nextBullet=[[UBullet alloc] init:@"bullet6.png" level:level point:pos];
//        nextBullet.rotation=angle;
        [nextBullet setBulletRation:angle];
    //   NSLog(@" 接收到的角度 tan angle=%f",tan(angle*M_PI / 180));

        float realY = GAME_SCENE_SIZE.height+nextBullet.contentSize.height;
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
        
        
        [self addChild:nextBullet z:4];
        
        [nextBullet runAction:[CCSequence actions:
                               [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
                               [CCCallFuncN actionWithTarget:self selector:@selector(bulletMoveFinished:)],
                               nil]];

        //	realX+=gun.position.x;
        //	realY+=gun.position.y;

}
-(void)bulletMoveFinished:(id)sender
{
    
    [bulletArray removeObject:sender];
    [sender removeFromParentAndCleanup:YES];
    [sender release];
    //    NSLog(@"子弹超出屏幕   删除!");
    
}
//更新鱼的状态
-(void)upDateFish
{
    NSMutableArray *outFish=[[NSMutableArray alloc] init];
    //检查鱼是否有超出屏幕
    for (UFish *fish in fishArray) {
        
        if ([self isInScene:fish]) {
            fish.isInScreen=true;
            fish.outScreenTime=0;
        }else {
            fish.outScreenTime++;
            if(fish.isInScreen){//有进入过屏幕这代表不是刚生成的  而是从屏幕内除去
                [outFish addObject:fish];
            }else if(fish.outScreenTime>3&&gameingState!=kGameingStateFishSchoolIng){
                [outFish addObject:fish];
            }
            fish.isInScreen=false;
        }
        
    }
    
    for (UFish *fish in outFish) {
        [self removeFish:fish isClean:TRUE];
    }
    [outFish release];
}


-(BOOL)isInScene2:(UFish*)fish
{
    CGRect rect_1,rect_2;
    
    rect_1.size=fish.contentSize;
    rect_2.size=[[CCDirector sharedDirector] winSize];
    
    
    rect_1.origin=fish.position;
    rect_2.origin=CGPointMake(rect_2.size.width/2, rect_2.size.height/2);
    
    
    return [UGameTools rectangleCollide:rect_1 angle1:fish.rotation rect2:rect_2 angle2:0];
}
-(BOOL)isInScene:(UFish*)fish
{
    CGRect sceneRect;
    sceneRect.origin=CGPointZero;
    sceneRect.size=GAME_SCENE_SIZE;
    
    
    
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
            if ([self dotWithRotationRectCollide:CGPointZero rect:fishRect angle:fish.rotation]) {
                return true;
            }
        }else {
            if ([self dotWithRotationRectCollide:CGPointMake(0, GAME_SCENE_SIZE.height) rect:fishRect angle:fish.rotation]) {
                return true;
            }
        }        
    }else {
        if (fish.position.y<=GAME_SCENE_SIZE.height/2) {//在下
            if ([self dotWithRotationRectCollide:CGPointMake(GAME_SCENE_SIZE.width, 0) rect:fishRect angle:fish.rotation]) {
                return true;
            }
        }else {
            if ([self dotWithRotationRectCollide:CGPointMake(GAME_SCENE_SIZE.width, GAME_SCENE_SIZE.height) rect:fishRect angle:fish.rotation]) {
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
    
//    NSLog(@"点与矩形的碰撞检测:x=%f   y=%f  temRect:x=%f  y=%f  w=%f  h=%f",newDot.x,newDot.y,newRect.origin.x,newRect.origin.y,newRect.size.width,newRect.size.height);
    
    return CGRectContainsPoint(newRect, newDot);
}

-(void)removeFish:(UFish*)fish isClean:(BOOL)is
{

    [fishArray removeObject:fish];//将鱼从数组中删除
    
    [((UFishSchool*)fish.fishSchool).fishArray removeObject:fish];//将鱼从所属的鱼群中去掉
    if (((UFishSchool*)fish.fishSchool).fishArray.count==0) {//鱼群鱼的数量为0则删除掉鱼群
        [fishSchoolArray removeObject:fish.fishSchool];
        [self removeChild:fish.fishSchool cleanup:YES];
        [fish.fishSchool release]; 
    }

    if (is) {
        //从界面上清除并清理掉
        [fish removeFromParentAndCleanup:YES];
        [fish release];
    }else {
        [fish autorelease];
    }

}
-(void)checkLaserCollide
{
    if (connon.connonState==KStateLaser) {
        
        CGPoint laserPos=[connon getFireDot];
         NSMutableArray *toDelete=[[NSMutableArray alloc] init];
        //检测激光与鱼的碰撞
        for (UFish *fish in fishArray) {
           BOOL isCollide= [UGameTools rectangleCollide:CGRectMake(fish.position.x, fish.position.y, fish.contentSize.width, fish.contentSize.height) angle1:fish.rotation rect2:CGRectMake(laserPos.x, laserPos.y, 50, GAME_SCENE_SIZE.height*3) angle2:90-laser.angle];
            if (isCollide) {
                [toDelete addObject:fish];
            }
        }
        
        for (UFish *fish in toDelete) {
            [fish death];
            [self removeFish:fish isClean:NO];
        }
        
    }else {
        [self unschedule:_cmd];
    }
}
-(void)upDataBullet
{
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
	for (UBullet *bullet in bulletArray) {
//		CGRect bulletRect = CGRectMake(bullet.position.x - (bullet.contentSize.width/2), 
//                                       bullet.position.y - (bullet.contentSize.height/2), 
//                                       bullet.contentSize.width, 
//                                       bullet.contentSize.height);
//		CGSize s=[[CCDirector sharedDirector] winSize];
//        if (!CGRectIntersectsRect(bulletRect,CGRectMake(0, 0, s.width, s.height))) {
//            [projectilesToDelete addObject:bullet];
//            continue;
//        }
//        
		BOOL isIntersects=false;
        NSMutableArray *toDelete=[[NSMutableArray alloc] init];
		for (UFish *fish in fishArray) {
            if (fish==nil) {
                continue;
            }
            if (fish.state==kFishStateDeath) {
                continue;
            }
            CGRect fishRect = CGRectMake(fish.position.x, fish.position.y, fish.contentSize.width, fish.contentSize.height);
            
            if ([self dotWithRotationRectCollide:bullet.position rect:fishRect angle:fish.rotation]) {//检测子弹与鱼的碰撞
                isIntersects=true;
                UNet *net=[[UNet alloc] init:bullet.level plaerID:kPlayerID_Null point:bullet.position];
//                net.anchorPoint=ccp(0.5f,0.5f);
                [self createBlast:bullet.position type:bullet.level];
//                [self addChild:net];
                [toDelete addObjectsFromArray:[self checkNetIntersects:net]];
                break;
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
-(NSMutableArray*)checkNetIntersects:(UNet*)net
{
    NSMutableArray *toDelete=[[NSMutableArray alloc] init];
    double yu[] = {40,30,25,20,15,10,8,5,3,1};
    CGRect netRect=CGRectMake(net.position.x-net.contentSize.width/2, net.position.y-net.contentSize.height/2, net.netSize.width, net.netSize.height);
    
    for (UFish *fish in fishArray) {
        if (fish==nil) {
            continue;
        }
        if (fish.state==kFishStateDeath) {
            continue;
        }
        double n=1;
        if (isPad) {
            switch (power) {
                case 1:
                    n=1.2;
                    break;
                case 5:
                    n=1.2;
                    break;
                case 20:
                    n=1.1;
                    break;
                case 50:
                    n=1.1;
                    break;
                case 100:
                    n=1.0;
                    break;
                default:
                    break;
            }
//            n=1.5;
        }else{
//            n=1;
            switch (power) {
                case 1:
                    n=1.2;
                    break;
                case 5:
                    n=1.2;
                    break;
                case 20:
                    n=1.1;
                    break;
                case 50:
                    n=1.1;
                    break;
                case 100:
                    n=1.0;
                    break;
                default:
                    break;
            }
        }
        double num=yu[fish.type]*(n+net.netLevel*net.netLevel/49);
        //判断鱼的坐标在网的范围内则为碰到   并进行捕获的概率计算
        if (CGRectContainsPoint(netRect, fish.position)) {
            double a = (double)(arc4random() % 10000) / 10000 * 100 ;
            if (a<num) {
                [toDelete addObject:fish];
                [fish death];
            }
        }
    }
    return toDelete;
}
-(void)createFish:(int)type frame:(CCSpriteFrame*)spriteFrame fishSpeed:(float)speed fishAngle:(float)angle fishPoint:(CGPoint)point
{
    UFish *fish = [[UFish alloc] init:type frame:spriteFrame speed:speed angle:angle state:0 fishPoint:point playerID:kPlayerID_Null];
    [fishBatchNode addChild:fish z:0];
    [fishArray addObject:fish];
}
- (CCSpriteFrame*)getFishSpriteFrame:(int)type
{
    if (!fishArray) {
        return [fishArray objectAtIndex:0];
    }
    return nil;
}
//鱼阵型的刷出
-(void)createFishSchool:(kFishSchoolType)type
{
    UFish *fish;
    newFishSchool=[[UFishSchool alloc] init:type];
    switch (type) {
        case kFishSchoolType_11:
            //20条一级鱼
            //20条4级鱼
            //4条10级鱼
            //20条4级鱼
            //20条一级鱼
            for (int i=0; i<20; i++) {
                fish = [[UFish alloc] init:0 frame:[fishSprireArr objectAtIndex:0] speed:4 angle:0 state:0 fishPoint:CGPointMake(-i*40, GAME_SCENE_SIZE.height/4*3) playerID:kPlayerID_Null];
                
                [fishBatchNode addChild:fish z:0];
                [fishArray addObject:fish];
                [newFishSchool addFish:fish];
                
            }
            for (int i=0; i<20; i++) {
                fish = [[UFish alloc] init:3 frame:[fishSprireArr objectAtIndex:3] speed:4 angle:0 state:0 fishPoint:CGPointMake(-i*40, GAME_SCENE_SIZE.height/4*3-20) playerID:kPlayerID_Null];
                
                [fishBatchNode addChild:fish z:0];
                [fishArray addObject:fish];
                [newFishSchool addFish:fish];
                
            }
            
            for (int i=0; i<4; i++) {
                fish = [[UFish alloc] init:9 frame:[fishSprireArr objectAtIndex:9]  speed:4 angle:0 state:0 fishPoint:CGPointMake(50-i*200, GAME_SCENE_SIZE.height/2) playerID:kPlayerID_Null];
                
                [fishBatchNode addChild:fish z:0];
                [fishArray addObject:fish];
                [newFishSchool addFish:fish];
            }
            
            for (int i=0; i<20; i++) {
                fish = [[UFish alloc] init:0  frame:[fishSprireArr objectAtIndex:0] speed:4 angle:0 state:0 fishPoint:CGPointMake(-i*40, GAME_SCENE_SIZE.height/4) playerID:kPlayerID_Null];
                
                [fishBatchNode addChild:fish z:0];
                [fishArray addObject:fish];
                [newFishSchool addFish:fish];
            }
            for (int i=0; i<20; i++) {
                fish = [[UFish alloc] init:3 frame:[fishSprireArr objectAtIndex:3] speed:4 angle:0 state:0 fishPoint:CGPointMake(-i*40, GAME_SCENE_SIZE.height/4+20) playerID:kPlayerID_Null];
                
                [fishBatchNode addChild:fish z:0];
                [fishArray addObject:fish];
                [newFishSchool addFish:fish];
            }
            [self addChild:newFishSchool];
            [fishSchoolArray addObject:newFishSchool];
            
            break;
        case kFishSchoolType_12:
            [self fishSchoolCreate_12];
            [self schedule:@selector(fishSchoolCreate_12) interval:1.5f repeat:30 delay:1.0f];

            [self addChild:newFishSchool];
            [fishSchoolArray addObject:newFishSchool];

            break;
        default:
            break;
    }
}
-(void)fishSchoolCreate_12
{
    id delay;
    id turn;
    
    id delay2;
    id turn2;
    
    //添加鱼
    UFish *fish;
    UFish *fish2;
    
    if (isPad) {
        
        delay=[CCDelayTime actionWithDuration:11];
        turn=[CCRotateBy actionWithDuration:26 angle:-540];
        
        delay2=[CCDelayTime actionWithDuration:8];
        turn2=[CCRotateBy actionWithDuration:30 angle:-540];
        
        fish = [[UFish alloc] init:0 frame:[fishSprireArr objectAtIndex:0] speed:5 angle:0 state:0 fishPoint:CGPointMake(-20, GAME_SCENE_SIZE.height/4+20) playerID:kPlayerID_Null];
        fish2 = [[UFish alloc] init:4 frame:[fishSprireArr objectAtIndex:4] speed:7 angle:180 state:0 fishPoint:CGPointMake(GAME_SCENE_SIZE.width+40, GAME_SCENE_SIZE.height/4*3+10) playerID:kPlayerID_Null];

    }else{
        
        delay=[CCDelayTime actionWithDuration:6];
        turn=[CCRotateBy actionWithDuration:13 angle:-540];
        
        delay2=[CCDelayTime actionWithDuration:5];
        turn2=[CCRotateBy actionWithDuration:15 angle:-540];
        
        fish = [[UFish alloc] init:0 frame:[fishSprireArr objectAtIndex:0] speed:5 angle:0 state:0 fishPoint:CGPointMake(-20, GAME_SCENE_SIZE.height/4+20) playerID:kPlayerID_Null];
        fish2 = [[UFish alloc] init:4 frame:[fishSprireArr objectAtIndex:4] speed:6 angle:180 state:0 fishPoint:CGPointMake(GAME_SCENE_SIZE.width+40, GAME_SCENE_SIZE.height/4*3+10) playerID:kPlayerID_Null];
    }

    
    [fish runAction:[CCSequence actions:delay,turn,nil]];
    [fish2 runAction:[CCSequence actions:delay2,turn2,nil]];
    
    [fishBatchNode addChild:fish z:0];
    [fishBatchNode addChild:fish2 z:0];
    
    [fishArray addObject:fish];
    [fishArray addObject:fish2];
    
    [newFishSchool addFish:fish];
    [newFishSchool addFish:fish2];
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
    CCSpriteFrame *temSpriteFrame=[fishSprireArr objectAtIndex:type];
    switch (way) {
        case 0:
        {
            //鱼从左边出来
            point=ccp(-temSpriteFrame.rect.size.width/2,arc4random()%((int)GAME_SCENE_SIZE.height/2)+GAME_SCENE_SIZE.height/4);
//            point=ccp(50,arc4random()%((int)GAME_SCENE_SIZE.height/2)+GAME_SCENE_SIZE.height/4);
            int tem=arc4random()%2;
            if (type==9) {
                angle=0;
            }else if (tem==0) {
                angle=arc4random()%30;
            }else {
                angle=-arc4random()%30;
            }
        }
            break;
        case 1:
        {
            //鱼从右边出来
            point=ccp(GAME_SCENE_SIZE.width+temSpriteFrame.rect.size.width/2,arc4random()%((int)GAME_SCENE_SIZE.height/2)+GAME_SCENE_SIZE.height/4);
            int tem=arc4random()%2;
            if (type==9) {
                angle=180;
            }else if (tem==0) {
                angle=arc4random()%45+180;
            }else {
                angle=180-arc4random()%45;
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
        //        NSLog(@"创建鱼的位置 %d=%d",i,pos);
        if(isPad)
        {
            fish = [[UFish alloc] init:type frame:[fishSprireArr objectAtIndex:type] speed:6 angle:angle state:0 fishPoint:CGPointMake(250, 250) playerID:kPlayerID_Null];

        }else{
            fish = [[UFish alloc] init:type frame:[fishSprireArr objectAtIndex:type] speed:4 angle:angle state:0 fishPoint:CGPointMake(250, 250) playerID:kPlayerID_Null];

        }
        
        if (way==0) {//左
            fish.position=ccp(point.x-pos/3*fish.contentSize.width-fish.contentSize.width/2,point.y-pos%3*fish.contentSize.width);
        }else {
            fish.position=ccp(point.x+pos/3*fish.contentSize.width+fish.contentSize.width/2,point.y-pos%3*fish.contentSize.width);
        }
        
        [fishBatchNode addChild:fish z:0];
        [fishArray addObject:fish];
        [newFishSchool addFish:fish];
//      [fish setFishSchool:newFishSchool];
//      [self sendCreateFish:fish];
    }
    [self addChild:newFishSchool];
    [fishSchoolArray addObject:newFishSchool];
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
//刷鱼控制
-(void)createFishControl
{
    int num=kFishNumControl;
    if (isPad) {
        num=kFishNumControlForIpad;
    }else{
        num=kFishNumControl;
    }
    if (fishArray!=nil) {
        if (fishArray.count<num) {
            [self createFishSchoolWithWay];
        }
    }
}

-(void)createGold:(int)type point:(CGPoint)point
{
    [self playMoneyEffect];
    
    int num=golds[type];
    int goldW,goldH,timeNum;
    CGPoint destination,moveUp;
    
    if (isPad) {
        goldW=65;
        goldH=75;
        timeNum=450;
        destination= CGPointMake(60, 60);
        
    }else{
        goldW=33;
        goldH=37;
        timeNum=250;
        destination= CGPointMake(20, 20);
        
    }
    if (num<10) {
        for (int i=0; i<num; i++) {//(point+(i-num/2)*goldW)
            if (isPad) {
                moveUp= CGPointMake(0, arc4random()%30+30);
            }else{
                moveUp= CGPointMake(0, arc4random()%20+20);
            }
            
            CGPoint point2=CGPointMake(point.x+((float)i-(float)num/2)*goldW, point.y);
            UMoney *money=[[UMoney alloc] init:0 point:point2 playerID:kPlayerID_Null] ;
           
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
            UMoney *money=[[UMoney alloc] init:1 point:point2 playerID:kPlayerID_Null] ;
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
        showGetGold=[[CCLabelAtlas alloc]  initWithString:[NSString stringWithFormat:@"/%d",num*power] charMapFile:@"show_get_gold_num.png" itemWidth:40 itemHeight:38 startCharMap:'/'];
        upNum=60;
    }else {
        showGetGold=[[CCLabelAtlas alloc]  initWithString:[NSString stringWithFormat:@"/%d",num*power] charMapFile:@"show_get_gold_num.png" itemWidth:20 itemHeight:19 startCharMap:'/'];
        upNum=30;
    }
    
    showGetGold.position=point;
    
    
    id moveAction=[CCMoveTo actionWithDuration:3.0f position:ccpAdd(point, ccp(0,upNum))];
    id fadeOut=[CCFadeOut actionWithDuration:3.0f];
    id callFun2=[CCCallFuncN actionWithTarget:self selector:@selector(deleteShowGetGoldLabel:)];
    
    [showGetGold runAction:[CCSequence actions:[CCSpawn actions:moveAction,fadeOut, nil],callFun2, nil]];
    [self addChild:showGetGold z:5];
    
    gold+=golds[type]*power;
    [self addExp:exps[type]];
    [self addSP:sps[type]];
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


-(void)setGoldShow:(int)num
{    
    NSString *tem=[NSString stringWithFormat:@"%07d",num];
//    tem=[NSString stringWithFormat:@"%@%d",[@"000000" substringWithRange:NSMakeRange(1,6-tem.length)],num];
    [goldLabel setString:tem];
}

-(void)giveGold
{
    isTiming=true;
    [self schedule:@selector(goldTimeControl) interval:1.0f];
}
-(void)goldTimeControl
{
    goldTime--;
    [self setGoldTime:goldTime];
    if (goldTime==0) {
        goldTime=60;
        //1分钟送币100
        gold+=100;
        isTiming=false;
    }
}
-(void)setGoldTime:(int)num
{
    NSString *tem=[NSString stringWithFormat:@"%02d",num];
    [goldTimeLabel setString:tem];
}

-(int)getPlaceNum:(int)num point:(int)pos
{
//    NSLog(@"num=%d  pow(10,pow)=%d  pow(10,num-1)=%d ",num,(int)pow(10, pos),(int)pow(10, num-1));
    return num%(int)pow(10, pos)/(int)pow(10, pos-1);
}

//控制显示的金币滚动
-(void)turnGoldShow
{
    if (goldShow!=gold) 
    {
        int n=abs(goldShow-gold);
        NSString *tem=[NSString stringWithFormat:@"%d",n];
        int length=tem.length;
        int value=0;
        if (goldShow<gold) 
        {
            value=1;
        }else if (goldShow>gold) 
        {
            value=-1;
        }
        for (int i=0; i<length; i++) 
        {
            int num=value;
            for (int j=0; j<i; j++) 
            {
                num*=10;
            }
            goldShow+=num;
        }
//        NSString *gold=[NSString stringWithFormat:@"%d",goldShow];
//        [labelMoney setString:gold];
    }
    
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
    
    //判断金币是否大于炮塔等级的需求  满足则发射子弹
    
    if (isPad) {
        if (location.y<=80) {
            return;
        }
    }else {
        if (location.y<=50) {
            return;
        }
    }
    
    [self connonFire:location];
    
    
//    NSLog(@"点击的位置：x=%f    y=%f",location.x,location.y);
    
}
-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
}
-(void) update:(ccTime)delta
{    
    switch (gameState) {
        case kGameStateForGameing:
            
            switch (gameingState) {
                case kGameingStateNormal:
                    
                    break;
                case kGameingStateCleanFish:
                    if (fishArray.count==0) {
//                        NSLog(@"fish be clean!");
                        gameingState=kGameingStateFishSchoolIng;
                        //刷出鱼群
                        [self createFishSchool:kFishSchoolType_12];
                        
                    }else {
//                        NSLog(@"fish num=%d",fishArray.count);
                    }
                    break;
                case kGameingStateFishSchoolIng:
                    if (fishArray.count==0) {
                        gameingState=kGameingStateNormal;
                        [self schedule:@selector(createFishControl) interval:0.5];
//                        NSLog(@"fish school end!");
                    }
                    break;
                default:
                    break;
            }
        case kGameStateForMenu:
            
            break;
        case kGameStateForLoading:
            
            break;
        case kGameStateForShop:
            
            break;
        default:
            break;
    }
    if (goldShow<gold) {
        if (gold-goldShow>1000) {
            goldShow+=400;
        }
        else if (gold-goldShow>300) {
            goldShow+=100;
        }
        else if (gold-goldShow>100) {
            goldShow+=25;
        }
        else if (gold-goldShow>50) {
            goldShow+=10;
        }
        else if(gold-goldShow>10){
            goldShow+=4;
        }else{
            goldShow++;
        }
        
        [self setGoldShow:goldShow];
    }else if (goldShow>gold) {
        if (goldShow-gold>1000) {
            goldShow-=400;
        }
        else if (goldShow-gold>300) {
            goldShow-=100;
        }
        else if (goldShow-gold>100) {
            goldShow-=25;
        }
        else if (goldShow-gold>50) {
            goldShow-=10;
        }
        else if(goldShow-gold>10){
            goldShow-=4;
        }else{
            goldShow--;
        }
        [self setGoldShow:goldShow];
    }
    
    /*if (gold<100&&!isTiming) {
        [self giveGold];
    }*/
    if (!isTiming) {
        [self giveGold];
    }
    
//        [self upDateFish];
        //更新子弹
        [self upDataBullet];
        //更新渔网
    
}
//让鱼都加速游出屏幕
-(void)cleanFish
{
    gameingState=kGameingStateCleanFish;
    [self unschedule:@selector(createFishControl)];
    for (UFishSchool *fishSchool in fishSchoolArray) {
        if (fishSchool!=nil) {
            [fishSchool pauseSchedulerAndActions];
        }
    }
    int speed;
    if (isPad) {
        speed=40;
    }else{
        speed=20;
    }
    for (UFish *fish in fishArray) {
        fish.speed=speed;
    }
//    NSLog(@"fish num=%d  gameState=%d  gameingState=%d",fishArray.count,gameState,gameingState);
}
-(void)showLevelUp
{
    gameState=kGameStateForLevelUp;
//    strForWeibo=@"捞大鱼,捞大鱼…我在最流行的游戏捕鱼达人里已经成为一个出色捕鱼人,荣封我为《江湖小虾》的称号,来挑战我呀! https://itunes.apple.com/cn/app/bu-yu-da-ren-mian-fei-ban/id447330270?mt=8";
    
    strForWeibo=[NSString stringWithFormat:@"捞大鱼,捞大鱼…我在最流行的游戏捕鱼达人里已经成为一个出色捕鱼人,荣封我为《%@》的称号,来挑战我呀!%@",@"江湖小虾",@"https://itunes.apple.com/cn/app/bu-yu-da-ren-mian-fei-ban/id447330270?mt=8"];
    
//    NSLog(@"%@",strForWeibo);
//    strForWeibo=@"测试啊  测试..";
    [self gamePause];
    [self hideBannerAD];
    CCLayer *levelUpLayer=[CCLayer node];
    
    CCSprite *temBack=[CCSprite spriteWithFile:@"levelup_back.png"];
    temBack.position=ccp(GAME_SCENE_SIZE.width/2,GAME_SCENE_SIZE.height*0.63);
    
    
    CCSprite *temName=[CCSprite spriteWithFile:@"levelup_name.png"];
//    CCSprite *temNum=[CCSprite spriteWithFile:@"levelup_num.png"];
    CCSprite *temWord=[CCSprite spriteWithFile:@"levelup_word.png"];
    
    CCLabelAtlas *temNum;
    
    if (isPad) {
        temNum=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%d",levelUpGold[playerLevel]] charMapFile:@"levelup_num.png" itemWidth:25 itemHeight:25 startCharMap:'0'];
    }else {
        temNum=[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%d",levelUpGold[playerLevel]] charMapFile:@"levelup_num.png" itemWidth:11 itemHeight:11 startCharMap:'0'];
    }
    
    [temName setTextureRect:CGRectMake(0, temName.contentSize.height/11*playerLevel, temName.contentSize.width, temName.contentSize.height/11)];
    
    CCMenuItem *temItem_OK=[CCMenuItemImage itemWithNormalImage:@"levelup_button_1.png" selectedImage:@"levelup_button_1_.png" target:self selector:@selector(levelUPButton_OK)];
    CCMenuItem *temItem_WB=[CCMenuItemImage itemWithNormalImage:@"levelup_button_2.png" selectedImage:@"levelup_button_2_.png" target:self selector:@selector(levelUPButton_WEIBO)];
    
    temItem_OK.position=ccp(temBack.contentSize.width/4*1.3,temBack.contentSize.height/8);
    temItem_WB.position=ccp(temBack.contentSize.width/4*2.7,temBack.contentSize.height/8);
    temName.position=ccp(temBack.contentSize.width*0.6,temBack.contentSize.height*0.48);
    temNum.position=ccp(temBack.contentSize.width*0.38,temBack.contentSize.height*0.38);
    CCMenu *temMenu=[CCMenu menuWithItems:temItem_OK,temItem_WB, nil];
    
    
    temMenu.position=CGPointZero;
    temWord.position=ccp(temBack.contentSize.width/2,temBack.contentSize.height/5*2);
    
    
    [temBack addChild:temWord z:0];
    [temBack addChild:temNum z:0];
    [temBack addChild:temName z:0];
    [temBack addChild:temMenu z:0];
    
    temBack.scale=0;
    
    id scale=[CCScaleTo actionWithDuration:0.2 scale:1];
    id scale2=[CCScaleTo actionWithDuration:0.1 scale:0.9];
    id scale3=[CCScaleTo actionWithDuration:0.1 scale:1];
    
    [temBack runAction:[CCSequence actions:scale,scale2,scale3, nil]];
    
    [levelUpLayer addChild:temBack z:0 tag:1];
    [self addChild:levelUpLayer z:99 tag:kTagLevelUPLayer];
    
    gold+=levelUpGold[playerLevel];
    
}
-(void)closeLevelUp
{
    gameState=kGameStateForGameing;
    [self gameResume];
    [self showBannerAD];
    CCLayer *temLayer=(CCLayer*)[self getChildByTag:kTagLevelUPLayer];
    [temLayer removeFromParentAndCleanup:YES];
    
    [self cleanFish];
}
-(void)levelUPButton_OK
{
    CCLayer *temLayer=(CCLayer*)[self getChildByTag:kTagLevelUPLayer];
    CCNode *node=[temLayer getChildByTag:1];
    
    id scale=[CCScaleTo actionWithDuration:0.2 scale:0];
    id callFun=[CCCallFunc actionWithTarget:self selector:@selector(closeLevelUp)];
    [node runAction:[CCSequence actions:scale,callFun, nil]];
}
-(void)levelUPButton_WEIBO
{
    [self share];
}
#pragma mark - 版本更新金币奖励
- (void)getUpDateGoldFor2_2
{
    
    updateGiveGoldArr=[[NSMutableArray alloc] init];
    int goldW,goldH,timeNum;
    CGPoint destination,moveUp;
    
    if (isPad) {
        goldW=65;
        goldH=75;
        timeNum=450;
        destination= CGPointMake(60, 60);
         moveUp= CGPointMake(0, arc4random()%30+30);
    }else{
        goldW=33;
        goldH=37;
        timeNum=250;
        destination= CGPointMake(20, 20);
        moveUp= CGPointMake(0, arc4random()%20+20);
    }
    
    CGPoint p=ccp(240, 220);
    
    CGPoint goldPoint[20]=
    {
        p,
        ccp(p.x+30, p.y+20),
        ccp(p.x+60, p.y+40),
        ccp(p.x+90, p.y+20),
        ccp(p.x+120, p.y),
        ccp(p.x+110, p.y-30),
        ccp(p.x+90, p.y-60),
        ccp(p.x+60, p.y-90),
        ccp(p.x+30, p.y-120),
        ccp(p.x, p.y-140),
        ccp(p.x-30, p.y+20),
        ccp(p.x-60, p.y+40),
        ccp(p.x-90, p.y+20),
        ccp(p.x-120, p.y),
        ccp(p.x-110, p.y-30),
        ccp(p.x-90, p.y-60),
        ccp(p.x-60, p.y-90),
        ccp(p.x-30, p.y-120),
    };
    //创建金币 并排成心形在画面中间
    for (int i=0; i<18; i++) {
        UMoney *money=[[UMoney alloc] init:1 point:goldPoint[i] playerID:kPlayerID_Null];
        [updateGiveGoldArr addObject:money];
        [self addChild:money z:5];
    }
    //显示金币的数字
    //版本升级奖励提示文字
    CCSprite *updateWord=[CCSprite spriteWithFile:@"update_word.png"];
    updateWord.anchorPoint=ccp(0.5f, 0.0f);
    updateWord.position=ccp(GAME_SCENE_SIZE.width/2, GAME_SCENE_SIZE.height/5*4);
    [self addChild:updateWord z:99];
    giveGoldWord=updateWord;
    //领取奖励按钮
    CCMenuItem *temItem=[CCMenuItemImage itemWithNormalImage:@"update_button.png" selectedImage:@"update_button.png" target:self selector:@selector(updateButtonEvent)];
    CCMenu *temMenu=[CCMenu menuWithItems:temItem, nil];
    temMenu.anchorPoint=ccp(0.5f, 0.5f);
    temMenu.position=ccp(GAME_SCENE_SIZE.width/2, GAME_SCENE_SIZE.height/5);
    [self addChild:temMenu z:99];
    giveGoldMenu=temMenu;
}
-(void)updateButtonEvent
{
    CGPoint destination,moveUp;
     int goldW,goldH,timeNum;
    
    if (isPad) {
        goldW=65;
        goldH=75;
        timeNum=450;
        destination= CGPointMake(60, 60);
        moveUp= CGPointMake(0, arc4random()%30+30);
    }else{
        goldW=33;
        goldH=37;
        timeNum=250;
        destination= CGPointMake(20, 20);
        moveUp= CGPointMake(0, arc4random()%20+20);
    }
    
    for (UMoney* money in updateGiveGoldArr) {
        float time=sqrt((money.position.x-destination.x)*(money.position.x-destination.x)+(money.position.y-destination.y)*(money.position.y-destination.y))/timeNum;
        id move1=[CCMoveTo actionWithDuration:0.2 position:ccpAdd(money.position, moveUp)];
        id delay=[CCDelayTime actionWithDuration:0.5f];
        id move2=[CCMoveTo actionWithDuration:time position:destination];
        id callFun=[CCCallFuncN actionWithTarget:self selector:@selector(deleteGold:)];
        [money runAction:[CCSequence actions:move1,delay,move2,callFun, nil]];
    }
    
    id fadeOut=[CCFadeOut actionWithDuration:1.0f];
    [giveGoldWord runAction:fadeOut];
    
    [giveGoldMenu removeFromParentAndCleanup:YES];
    
    gold+=1000;
    [self saveGameData];
}
#pragma mark - 记录操作
//将2.1版本的数据记录转移到2.2版本的记录结构中并删除2.1的记录
//另增加版本更新送与的1000金币.
- (void)recordRransfer
{
    //存在新版本的记录  说明不需要再进行转移
    if ([USave isHaveRecord:kRecordTypeForGameData2_2]) {
        return;
    }
    
    if ([self isHaveDataFor2_1]) {
        if (![USave isHaveRecord:kRecordTypeForGameData2_2]) {
            RecordForGameData *temRecord=(RecordForGameData*)[[USave readGameData:kRecordTypeForGameData] bytes];
            RecordForGameData_2_2 record;
            record.nowLevel=temRecord->nowLevel;
            record.nowGold=temRecord->nowGold;
            record.nowSP_1=temRecord->nowSP;
            record.nowSP_5=0;
            record.nowSP_20=0;
            record.nowSP_50=0;
            record.nowSP_100=0;
            record.nowEXP=temRecord->nowEXP;
            record.needEXP=temRecord->needEXP;
            record.isRemoveAD=temRecord->isRemoveAD;
            //存储新记录
            NSData *data=[NSData dataWithBytes:&record length:sizeof(record)];
            [USave saveGameData:data toFile:kRecordTypeForGameData2_2];
            //删除2.1记录
//          [USave deleteRecord:kRecordTypeForGameData];
            //调用新版本更新增加金币函数
        }
    }
}

- (BOOL)isHaveDataFor2_1
{
   return  [USave isHaveRecord:kRecordTypeForGameData];
}
-(void)saveGameData
{
    
    RecordForGameData_2_2 record;
    record.nowLevel=playerLevel;
    record.nowGold=gold;
    record.nowSP_1=sp_1;
    record.nowSP_5=sp_5;
    record.nowSP_20=sp_20;
    record.nowSP_50=sp_50;
    record.nowSP_100=sp_100;
    switch (power) {
        case 1:
            record.nowSP_1=connon.sp;
            break;
        case 5:
            record.nowSP_5=connon.sp;
            break;
        case 20:
            record.nowSP_20=connon.sp;
            break;
        case 50:
            record.nowSP_50=connon.sp;
            break;
        case 100:
            record.nowSP_100=connon.sp;
            break;
        default:
            break;
    }    
    record.nowEXP=nowEXP;
    record.needEXP=needEXP;
    record.isRemoveAD=isRemoveAD;
    NSData *data=[NSData dataWithBytes:&record length:sizeof(record)];
    
    [USave saveGameData:data toFile:kRecordTypeForGameData2_2];
}
-(RecordForGameData_2_2*)getGameDataRecord
{
    return (RecordForGameData_2_2*)[[USave readGameData:kRecordTypeForGameData2_2] bytes];
}
-(void)readGameData
{
    RecordForGameData *record=(RecordForGameData*)[[USave readGameData:kRecordTypeForGameData2_2] bytes];
    if (record==nil) {
//        NSLog(@"游戏没有数据记录!");
        return;
    }
    
}
-(void)addMoney:(int)num
{
    gold+=num;
    goldShow=gold;
    [self setGoldShow:goldShow];
}

-(void)deleteBanner
{
    ///dijk 2016-05-21
    /*if (banner!=nil) {
        [banner release];
        banner=nil;
    }
     */
}

-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:tempObserver];
    [tempObserver release];
    tempObserver=nil;
    //[banner release];
    [super dealloc];
}
//微博部分
-(void)share
{
    [self shareForLevel];
//    //检查网络
//    if ([CheckNetwork isExistenceNetwork]) {
//        [self shareMethod];
//    }
}
-(void)shareForLevel
{
    // 设定截图大小
    CCRenderTexture  *target = [CCRenderTexture renderTextureWithWidth:GAME_SCENE_SIZE.width height:GAME_SCENE_SIZE.height];
    [target begin];
    
    // 添加需要截取的CCNode
    [self visit];
    [target end];
    sharedImage=[[target getUIImage] retain];
    ///dijk 2016-05-21
    /*
    UMSocialIconActionSheet *iconActionSheet = [[UMSocialControllerService defaultControllerService] getSocialIconActionSheetInController:[CCDirector sharedDirector]];
    //    UIViewController *rootViewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
    //    [iconActionSheet showInView:rootViewController.view];
    [iconActionSheet showInView:[[CCDirector sharedDirector] view]];
    [UMSocialData defaultData].shareImage = sharedImage;//[UIImage imageNamed:@"Icon.png"]
    [UMSocialData defaultData].shareText =[NSString stringWithFormat:@"捞大鱼,捞大鱼…我在最流行的游戏捕鱼达人里已经成为一个出色捕鱼人,荣封我为《%@》的称号,来挑战我呀!%@",gameLevelName[playerLevel],@"https://itunes.apple.com/cn/app/bu-yu-da-ren-mian-fei-ban/id447330270?mt=8"];
     */
}
-(void)showUpdateInfo
{
    
    UIAlertView* dialog = [[UIAlertView alloc] init];
    dialog.tag=kTagForUpdateInfo;
    [dialog setDelegate:self];
    [dialog setTitle:@"游戏更新奖励"];
    [dialog setMessage:@"恭喜你获得了1000金币的更新奖励!"];
    [dialog addButtonWithTitle:@"确定"];
//    [dialog addButtonWithTitle:@"取消"];
    [dialog show];
    [dialog release];
}
-(void)showNoMoneyInfo
{

    UIAlertView* dialog = [[UIAlertView alloc] init];
    dialog.tag=kTagForNoMoneyInfo;
    [dialog setDelegate:self];
    [dialog setTitle:@"金币不足提示!"];
    [dialog setMessage:@"金币不足,是否进入商店购买!"];
    [dialog addButtonWithTitle:@"确定"];
    [dialog addButtonWithTitle:@"取消"];
    [dialog show];
    [dialog release];
}
-(void)showJailbrokenInfo
{
    
    UIAlertView* dialog = [[UIAlertView alloc] init];
    dialog.tag=kTagForJailbrokenInfo;
    [dialog setDelegate:self];
    [dialog setTitle:@"系统提示!"];
    [dialog setMessage:@"越狱设备不支持!"];
    [dialog addButtonWithTitle:@"确定"];
//    [dialog addButtonWithTitle:@"取消"];
    [dialog show];
    [dialog release];
}
- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alert.tag==kTagForNoMoneyInfo) {
        if(buttonIndex==0) {  //yes
           [self showShopLayer];
        }
        else{  //No
            
        }
    }else if (alert.tag==kTagForJailbrokenInfo){
        
    }else if (alert.tag==kTagForUpdateInfo){
        
    }
}

///dijk 2016-05-21 百度广告
-(BOOL) enableLocation
{
    //启用location会有一次alert提示,请根据系统进行相关配置
    return YES;
}

- (IBAction)loadInterAd {
    self.adInterstitial = [[BaiduMobAdInterstitial alloc] init];
    self.adInterstitial.delegate = self;
    //把在mssp.baidu.com上创建后获得的代码位id写到这里
    self.adInterstitial.AdUnitTag = @"2058554";
    if ([self.isInVideo isEqualToString:@"1"]) {
        // 视频前贴片5s，倒计时
        self.adInterstitial.interstitialType = BaiduMobAdViewTypeInterstitialBeforeVideo;
        
    } else {
        //视频暂停贴片
        self.adInterstitial.interstitialType = BaiduMobAdViewTypeInterstitialPauseVideo;
    }
    NSString *w = self.customWidth;
    NSString *h = self.customHeight;
    //NSInteger screenW = [[CCDirector sharedDirector] view].frame.size.width;
    //NSInteger screenH = [[CCDirector sharedDirector] view].frame.size.height;
    
    [self.adInterstitial loadUsingSize:CGRectMake(0,0, [w floatValue], [h floatValue])];
}

- (NSString *)publisherId {
    return @"ccb60059"; //your_own_app_id
}

/**
 *  广告预加载成功
 */
- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)interstitial
{
    NSLog(@"interstitialSuccessToLoadAd");
    NSString *w = self.customWidth;
    NSString *h = self.customHeight;
    if (!self.customInterView) {
        NSInteger screenW = [[CCDirector sharedDirector] view].frame.size.width;
        NSInteger screenH = [[CCDirector sharedDirector] view].frame.size.height;
        UIView *customInterView = [[[UIView alloc]initWithFrame:CGRectMake((screenW-[w floatValue])/2, (screenH-[h floatValue])/2, [w floatValue], [h floatValue])]autorelease];
        self.customInterView = customInterView;
    }
    //[self.view addSubview:self.customInterView];
    [[[CCDirector sharedDirector] view] addSubview:self.customInterView];
    [interstitial presentFromView:self.customInterView];
}

/**
 *  广告预加载失败
 */
- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)interstitial
{
    NSLog(@"interstitialFailToLoadAd");
    ///dijk 2016-05-21 显示banner广告
    [self showAD];
}

/**
 *  广告即将展示
 */
- (void)interstitialWillPresentScreen:(BaiduMobAdInterstitial *)interstitial
{
    NSLog(@"interstitialWillPresentScreen");
}

/**
 *  广告展示成功
 */
- (void)interstitialSuccessPresentScreen:(BaiduMobAdInterstitial *)interstitial
{
    NSLog(@"interstitialSuccessPresentScreen");
}

/**
 *  广告展示失败
 */
- (void)interstitialFailPresentScreen:(BaiduMobAdInterstitial *)interstitial withError:(BaiduMobFailReason) reason
{
    NSLog(@"interstitialFailPresentScreen, withError: %d",reason);
    ///dijk 2016-05-21 显示banner广告
    [self showAD];
}

/**
 *  广告展示结束
 */
- (void)interstitialDidDismissScreen:(BaiduMobAdInterstitial *)interstitial
{
    NSLog(@"interstitialDidDismissScreen");
    [self.customInterView removeFromSuperview];
    ///dijk 2016-05-21 显示banner广告
    [self showAD];
}

///dijk 2016-05-21 Banner广告
/**
 *  广告将要被载入
 */
-(void) willDisplayAd:(BaiduMobAdView*) adview
{
    NSLog(@"will display ad");
}

/**
 *  广告载入失败
 */
-(void) failedDisplayAd:(BaiduMobFailReason) reason;
{
    NSLog(@"failedDisplayAd %d", reason);
}

/**
 *  本次广告展示成功时的回调
 */
-(void) didAdImpressed
{
    NSLog(@"didAdImpressed");
}

/**
 *  本次广告展示被用户点击时的回调
 */
-(void) didAdClicked
{
    NSLog(@"didAdClicked");
}

/**
 *  在用户点击完广告条出现全屏广告页面以后，用户关闭广告时的回调
 */
-(void) didDismissLandingPage
{
    NSLog(@"didDismissLandingPage");
    ///dijk 2016-05-21 显示banner广告
    [self showAD];
}

//人群属性接口
/**
 *  - 关键词数组
 */
-(NSArray*) keywords{
    NSArray* keywords = [NSArray arrayWithObjects:@"测试",@"关键词", nil];
    return keywords;
}

/**
 *  - 用户性别
 */
-(BaiduMobAdUserGender) userGender{
    return BaiduMobAdMale;
}

/**
 *  - 用户生日
 */
-(NSDate*) userBirthday{
    NSDate* birthday = [NSDate dateWithTimeIntervalSince1970:0];
    return birthday;
}

/**
 *  - 用户城市
 */
-(NSString*) userCity{
    return @"上海";
}


/**
 *  - 用户邮编
 */
-(NSString*) userPostalCode{
    return @"435200";
}


/**
 *  - 用户职业
 */
-(NSString*) userWork{
    return @"程序员";
}

/**
 *  - 用户最高教育学历
 *  - 学历输入数字，范围为0-6
 *  - 0表示小学，1表示初中，2表示中专/高中，3表示专科
 *  - 4表示本科，5表示硕士，6表示博士
 */
-(NSInteger) userEducation{
    return  5;
}

/**
 *  - 用户收入
 *  - 收入输入数字,以元为单位
 */
-(NSInteger) userSalary{
    return 10000;
}

/**
 *  - 用户爱好
 */
-(NSArray*) userHobbies{
    NSArray* hobbies = [NSArray arrayWithObjects:@"测试",@"爱好", nil];
    return hobbies;
}

/**
 *  - 其他自定义字段
 */
-(NSDictionary*) userOtherAttributes{
    NSMutableDictionary* other = [[[NSMutableDictionary alloc] init] autorelease];
    [other setValue:@"测试" forKey:@"测试"];
    return other;
}

///dijk 2016-05-21 释放广告资源
-(void) onExit{
    if (self.adInterstitial) {
        self.adInterstitial.delegate = nil;
        self.adInterstitial = nil;
    }
}

@end
