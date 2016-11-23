//
//  GameDefine.h
//  seaHunting_ios
//
//  Created by  on 12-4-5.
//  Copyright 2012 . All rights reserved.
//

#import "SimpleAudioEngine.h"
#import <Foundation/Foundation.h>
#import "cocos2d.h"

#ifdef __CC_PLATFORM_IOS
#define PARTICLE_FIRE_NAME @"fire.pvr"
#define PARTICLE_SNOW_NAME @"snowflake.png"
#elif defined(__CC_PLATFORM_MAC)
#define PARTICLE_FIRE_NAME @"fire.png"
#define PARTICLE_SNOW_NAME @"snowflake.png"
#endif

#pragma mark - enum
typedef enum{
    kModeTypeForOne=0,
    kModeTypeForGameCenter,
}kModeType;

//炮台状态
enum{
    KStateNormal,
    KStateWaitingForStoreUp,
    KStateForStoreUping,
    KStateWaitingForLaser,
    KStateLaser,
}ConnonState;
//设备类型
typedef enum{
    kIphone=0,
    kIphoneHD,
    kIphone5,
    kIpad,
    kIpadHD
}kDeviceType;
//炮的等级
typedef enum{
    kLevel_1=0,
    kLevel_2,
    kLevel_3,
    kLevel_4,
    kLevel_5,
    kLevel_6,
    kLevel_7
}kLevel;
//玩家ID
typedef enum{
    kPlayerID_Null=0,
    kPlayerID_Host,
    kPlayerID_2,
    kPlayerID_3,
    kPlayerID_4
}kPlayerID;
//鱼群类型
typedef enum{
    kFishSchoolType_1=0,
    kFishSchoolType_2,
    kFishSchoolType_3,
    kFishSchoolType_4,
    kFishSchoolType_5,
    kFishSchoolType_6,
    kFishSchoolType_7,
    kFishSchoolType_8,
    kFishSchoolType_9,
    kFishSchoolType_10,
    kFishSchoolType_11,
    kFishSchoolType_12,
}kFishSchoolType;

enum{
    kFishStateMove=0,
    kFishStateHide,
    kFishStateTurnAngle,
    kFishStateDeath
}FishState;
//游戏状态
typedef enum {
    kGameStateWaitingForMatch =0,                       //等待建立连接
    kGameStateInitPlayerData,                           //等待初始话玩家信息
    kGameStateChoiceHost,                               //等待选择主机
    kGameStateInitGameData,                             //初始化UI
    kGameStateStartGame,                                //进入游戏  开场动画
    kGameStateGameIng,                                  //游戏中
    kGameStateGameOver,                                 //游戏结束
    kGameStateDisconnect,
} GameState;
typedef enum{
    kADStateForNoAD=0,//广告已被去除
    kADStateForRun,//广告进行中
    kADStateForHide,//广告被隐藏中
    kADStateForNotGet,//不能被获取
    kADStateForBeClose,//广告被关闭
}ADState;
typedef enum{
    kGameStateForLoading=0,
    kGameStateForGameing,
    kGameStateForMenu,
    kGameStateForShop,
    kGameStateForLevelUp,
}GameStateForSingle;//单人模式


typedef enum{
    kGameingStateNormal=0,
    kGameingStateCleanFish,
    kGameingStateFishSchoolIng,
    kGameingStateForResult,
}GameingState;


//游戏断开原因
typedef enum {
    
    kEndReasonWin,
    kEndReasonLose,
    kEndReasonDisconnect,
    kEndReasonPlayerExit,
    
} EndReason;

//消息类型
typedef enum {
    kMessageTypeChoiceHost =0,
    kMessageTypeInitData,
    kMessageTypeInitDone,
    kMessageTypeStartGame,
    kMessageTypeGameBegin,
    kMessageTypeMove,
    kMessageTypeUpdata,
    kMessageTypeGameOver,
    kMessageTypeTalk,
    kMessageTypeCreateFish,
    kMessageTypeCreateFishSchool,
    kMessageTypeFishMove,
    kMessageTypeFishTurnAngle,
    kMessageTypeFire,
    kMessageTypeStoreUp,
    kMessageTypeLaserFire,
    kMessageTypeFireRequest,
    kMessageTypeRemoveFish,
    kMessageTypeFishDeath,
    kMessageTypeBulletBlast,
    kMessageTypeBulletDelete,
    kMessageTypeTurnConnonLevel,
    kMessageTypeTurnConnonLevelRequest,
    kMessageTypeExit,
    kMessageTypeDataRenew,
    kMessageTypeTimerRenew,
} MessageType;
#pragma mark - 消息定义
typedef struct {
    MessageType messageType;
} Message;

//设备的参数
typedef struct
{
    kDeviceType deviceType;
    float sceneWidth;
    float sceneHeight;
    float rimWidth;
    float rimHeight;
    float speedRatio;
}kDeviceValue;
//发送随机数选择主机  并发送设备的信息
typedef struct {
    Message message;
    uint32_t randomNumber;
    kDeviceValue deviceValue;
} MessageChoiceHost;

typedef struct {
    Message message;
} MessageStartGame;

typedef struct {
    Message message;
} MessageGameBegin;

typedef struct {
    Message message;
    float x;
    float y;
} MessageMove;

typedef struct {
    Message message;
    BOOL player1Won;
} MessageGameOver;

typedef struct{
    NSString *talk;
}MessageTalk2;

typedef struct{
    Message message;
    NSString *talk;
}MessageTalk;



typedef struct{
    float speed;   
    float angle;
    int state;
    CGPoint point;
}FishUpdata;

typedef struct{
    float angle;
    CGPoint point;
}FishTurnAngle;

typedef struct{
    Message message;
    int tag;
    float angle;
    CGPoint point;
}MessageFishTurnAngle;

typedef struct{
    Message message;
    int num;
    FishUpdata fishArray[300];
}MessageUpdata;

//typedef struct{
//    int fishType;
//    float speed;
//    float angle;
//    int state;
//    CGPoint point;
//    int tag;
//}FishData;
//
//typedef struct{
//    Message message;
//    int num;
//    FishData fishArray[300];
////    NSMutableArray *fishArray;
//}MessageInitData;

typedef struct{
    Message message;
    
}MessageInitDataDone;

typedef struct{
    Message message;
    int fishType;
    float speed;
    float angle;
    int state;
    CGPoint point;
    int tag;
}MessageCreateFish;

typedef struct{
    int tag;
    CGPoint point;
}FishData;

typedef struct{
    Message message;
    int type;
    int num;
    float speed;
    float angle;
    FishData fishArr[9];
}MessageCreateFishSchool;


typedef struct{
    Message message;
    
}MessageFishMove;

//发射子弹消息
typedef struct{
    Message message;
    kPlayerID playerID;
    int level;
    double angle;
    int tag;
}MessageFire;
//激光蓄力
typedef struct{
    Message message;
    kPlayerID playerID;
    double angle;
}MessageStoreUp;
//发射激光
typedef struct{
    Message message;
    kPlayerID playerID;
    double angle;
}MessageLaserFire;
//发射子弹请求
typedef struct{
    Message message;
    kPlayerID playerID;
    int level;
    double angle;
}MessageFireRequest;

typedef struct{
    Message message;
    int fishID;
    BOOL isClean;
}MessageRemoveFish;

typedef struct{
    Message message;
    int fishID;
    kPlayerID beKillPlayer;
}MessageFishDeath;

typedef struct{
    Message message;
    int bulletTag;
    CGPoint bulletPos;
}MessageBulletBlast;

typedef struct{
    Message message;
    int bulletTag;
}MessageBulletDelete;

//更改炮塔等级
typedef struct{
    Message message;
    kPlayerID pid;
    int level;
}MessageTurnConnonLevel;
//请求更改炮塔等级
typedef struct{
    Message message;
    kPlayerID pid;
    int level;
}MessageTurnConnonLevelRequest;

//退出消息
typedef struct {
    Message message;
    kPlayerID pid;
    EndReason endReason;
}MessageExit;

//金币更新消息
typedef struct{
    Message message;
    kPlayerID pid;
    int nowGold;
    int nowScore;
    int nowSp;
}MessageDataRenew;

typedef struct{
    Message message;
    int timer;
}MessageTimerRenew;


#pragma mark - 消息结构体等

typedef struct{
    BOOL isBackMusicPlay;
    BOOL isEffectPlay;
}RecordForMusicSetting;

//2.1版本记录结构
typedef struct{
    int nowGold;
    int nowLevel;
    int nowSP;
    int nowEXP;
    int needEXP;
    BOOL isRemoveAD;
}RecordForGameData;

//2.2版本记录结构
typedef struct{
    int nowGold;
    int nowLevel;
    int nowSP_1;
    int nowSP_5;
    int nowSP_20;
    int nowSP_50;
    int nowSP_100;
    int nowEXP;
    int needEXP;
    BOOL isRemoveAD;
}RecordForGameData_2_2;
//v2.2 在线领金币记录
typedef struct{
    int time;
    int num;
    int date;
}RecordForGetFreeGoldData;
typedef struct{
    BOOL isActivate;
}RecordForgameActivate;
@interface GameDefine : CCNode {
    
}
@end
#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)



#define kRecordTypeForMusicSetting      @"music setting"
#define kRecordTypeForGameData          @"game data"
#define kRecordTypeForGameData2_2       @"game data2_2"
#define kRecordTypeForGameActivate      @"game activate"
#define kRecordTypeForGetFreeGold       @"get free gold"

#define kSoundTypeForBackMusic			@"game.mp3"
#define kSoundTypeForConnonFire			@"shoot.wav"
#define kSoundTypeForUIMusic            @"menu.mp3"
#define kSoundTypeForMoney              @"money.wav"

#define kUMAPPKEY   @"52c4f32c56240b3fc3010418"

CGSize GAME_SCENE_SIZE;
//BOOL g_isDoubleScore;
//BOOL g_hasInGame;
BOOL GAME_IS_PLAY_SOUND;
BOOL GAME_IS_PLAY_EFFECT;
//BOOL g_isIpad;
//kModeType gameModeType;
BOOL GAME_IS_FOR_GAMECENTER;
//游戏音效
SimpleAudioEngine *GAME_AUDIO;

//产品product id

//200金币
#define  kInAppPurchaseProductIdForPay_6  @"cn.akn.deepSeaHunt.pay_1"
//500金币
#define  kInAppPurchaseProductIdForPay_12  @"cn.akn.deepSeaHunt.pay_2"
//1000金币
#define  kInAppPurchaseProductIdForPay_18  @"cn.akn.deepSeaHunt.pay_3"
//1500金币
#define  kInAppPurchaseProductIdForPay_25  @"cn.akn.deepSeaHunt.pay_4"
//2000金币
#define  kInAppPurchaseProductIdForPay_30  @"cn.akn.deepSeaHunt.pay_5"
//5000金币
#define  kInAppPurchaseProductIdForPay_60  @"cn.akn.deepSeaHunt.pay_6"
//15000金币
#define  kInAppPurchaseProductIdForPay_128  @"cn.akn.deepSeaHunt.pay_7"
//50000金币
#define  kInAppPurchaseProductIdForPay_258  @"cn.akn.deepSeaHunt.pay_8"
//多人模式激活
#define  kInAppPurchaseProductIdForPay_activate  @"cn.akn.deepSeaHunt.pay_9"
