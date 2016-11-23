//
//  GameSceneForGameCenter.h
//  DeepSeaHunt
//
//  Created by Unity on 12-8-21.
//  Copyright (c) 2012年 akn. All rights reserved.
//
#import "cocos2d.h"
#import "UFish.h"
#import "GameDefine.h"
#import "AppDelegate.h"
#import "GCHelper.h"
#import "UConnon.h"
#import "UBullet.h"
#import "UFishSchool.h"
#import "UNet.h"
#import "UMoney.h"
#import "ULaser.h"
#import "UWelcomeScene.h"
//#import "MobClick.h"
//#import "UMSocialSnsService.h"
//#import "UMSocialData.h"

//层  -1  背景   0鱼   1  UI    2炮塔   3菜单

//tag   10-20  炮塔   100+鱼
typedef enum{
    kGameResultForTie=0,
    kGameResultForLose,
    kGameResultForWin,
}GameResult;


@interface GameSceneForGameCenter : CCLayer<GCHelperDelegate>
{

    CCScene *versusModeScene;
    
    
    kDeviceValue deviceValue;               //自己的设备信息
    kDeviceValue otherDeviceValue;          //对方的设备信息
    
    uint32_t ourRandom;
    BOOL isHost;                            //是否主机
    BOOL isChoiceHost;                      //是否选出主机
    GameState gameState;                    //游戏状态
    
    NSString *hostID;                       //主机ID  用于给主机发送数据
    
    NSMutableArray *fishNoUseTag;           //鱼未使用的tag标签
    NSMutableArray *bulletNoUseTag;
    
    NSMutableArray *fishArray;
    NSMutableArray *fishSchoolArray;        //鱼群数组
    
    NSMutableArray *bulletArray;            //子弹数组
    NSMutableArray *fishNetArray;           //渔网
    
//    NSMutableArray *otherBulletArray;       //对方的子弹数组
//    NSMutableArray *otherFishNetArray;      //对方的渔网

    
    UBullet *nextBullet;                   //下个子弹
    UFishSchool *newFishSchool;
    
    UConnon *connon;
    UConnon *otherConnon;
    
    
   
    
    kPlayerID playerID;
    
    NSString *otherPlayerID;
    
    BOOL isInitDone;                        //是否初始化完成
    BOOL otherPlayerIsInitDone;             //其他玩家是否初始化完毕
    
    
    NSString* name;
    NSString* otherPlayerName;
    
    CCLabelTTF *nameLabel;
    CCLabelTTF *otherPlayerNameLabel;
    CCLabelTTF *goldLabel;
    CCLabelTTF *otherGoldLabel;
    CCLabelTTF *scoreLabel;
    CCLabelTTF *otherPlayerScoreLabel;
    
//    CCSprite *myHead;
//    CCSprite *otherPlayerHead;
    CCSprite *myHead2;
    CCSprite *otherPlayerHead2;
    
    CCSprite *localPlayerHead,*rivalPlayerHead;
    UIImage *localPlayerHead_,*rivalPlayerHead_;
    
    CCLayer *infoLayer;
    
    BOOL isActivate;
    ULaser *laser,*rivalLaser;
    GameingState gameingState;
    //gold and score
    int gold,rivalGold,score,rivalScore,showGold,showScore,showRivalGold,showRivalScore;
    CCLabelAtlas *myGoldLabel,*myScoreLabel,*rivalGoldLabel,*rivalScoreLabel;
    CCLabelAtlas *timerLabel;
    int timer;
     CCLabelAtlas *showGetGold;
    //the result layer
    CCMenuItem *itemWeibo_,*itemAffirm_;
    //图片资源
    CCSprite *moneyForGold;                 //金币
    //    CCSprite *fishArr[10];
    NSMutableArray *fishSprireArr;
    CCSpriteBatchNode* fishBatchNode;
    
//    NSString *strForWeibo;
}
@property (assign)BOOL isHost;
@property (assign)kPlayerID playerID;
@property (assign)int gold;
@property (assign)int rivalGold;
//图片资源
@property (assign) CCSprite *moneyForGold;
@property (assign) NSMutableArray *fishSprireArr;


+(CCScene*)scene;
+(GameSceneForGameCenter*)shardScene;
-(void)setStartButtonEnableOK;
-(void)saveActivateData;
- (void)sendData:(NSData *)data;
-(void)addNoUseFishID:(UFish*)fish;
-(NSString*)getPlayerName:(NSString *)pid;
-(void)sendTurnConnonLevel:(int)l playerID:(kPlayerID)pid;
-(void)sendTurnConnonLevelRequest:(int)l;
//create the gold effect
-(void)createGold:(int)num point:(CGPoint)point playerID:(kPlayerID)pid;
//-(void)createButtle:(int)level point:(CGPoint)pos angle:(float)angle;
-(void)createButtle:(int)level point:(CGPoint)pos angle:(float)angle player:(kPlayerID)pid tag:(int)bulletTag;
//create the laser
-(void)laser:(int)angle  point:(CGPoint)point;
-(void)rivalLaser:(int)angle  point:(CGPoint)point;
-(void)sendStoreUpMessage:(double)angle playerID:(kPlayerID)pid;
-(void)sendLaserFireMessage:(double)angle playerID:(kPlayerID)pid;
-(void)sendDataRenewMessage:(int)nowGold score:(int)nowScore sp:(int)nowSp playerID:(kPlayerID)pid;
-(void)playFireEffect;
-(void)showPlayerInfoLoading;
-(void)deletePlayerInfoLoading;
-(void)sendFireMessage:(double)angle level:(int)l playerID:(kPlayerID)pid tag:(int)bulletTag;
@end
