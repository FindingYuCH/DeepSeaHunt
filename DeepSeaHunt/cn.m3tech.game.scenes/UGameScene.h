//
//  UGameScene.h
//  DeepSeaHunt
//
//  Created by Unity on 12-10-22.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "cocos2d.h"
#import "GameDefine.h"
#import "USave.h"
#import "UConnon.h"
#import "UBullet.h"
#import "UFish.h"
#import "UFishSchool.h"
#import "UNet.h"
#import "UMoney.h"
#import "UGameTools.h"
#import "UWelcomeScene.h"
#import "ULaser.h"
#import "ParticleEffectSelfMade.h"
#import "InAppPur.h"
//#import "Mogo_ad.h"
//#import "MobClick.h"
#import "UShopLayer.h"
//#import "UMSocialSnsService.h"
//#import "UMSocialData.h"
#import "BaiduMobAdInterstitial.h"
#import "BaiduMobAdDelegateProtocol.h"
#import "BaiduMobAdView.h"
#define kTimeShowAD 20
#define kTimeWarttingAD 20

#define kAppKey             @"3941824814"
#define kAppSecret          @"791cc3d937f2e7fa8809a163ef25e559"
#define kAppRedirectURI     @"http://"

//typedef struct{
//    int playerLv;
//    int nowExp;
//    int needExp;
//    int gold;
//    
//}GameInfoRecord;

@interface UGameScene : CCLayer<UShopDelegate,UInAppDelegate,BaiduMobAdInterstitialDelegate,BaiduMobAdViewDelegate>
{
    int  connonLevel;
    CGSize levelTextureSize;
    CCSprite *levelLabel;
    
    GameStateForSingle gameState;
    GameingState gameingState;
    
    UConnon *connon;
    
    int gold,goldShow;
    
    UFishSchool *newFishSchool;
    
    NSMutableArray *fishArray;
    NSMutableArray *fishSchoolArray;        //鱼群数组
    
    NSMutableArray *bulletArray;            //子弹数组
    CCLabelAtlas *goldLabel;
    CCLabelAtlas *goldTimeLabel;            //时间
//    CCLabelAtlas *playerNameLabel;
    CCLabelAtlas *playerLvLabel;
    int goldTime;
    CGSize golTextureSize;
    //经验 等级
    CCSprite *exp;
    float nowEXP,needEXP;
    CGSize expSize;
    int playerLevel;
    CCSprite *playerName;
    BOOL isTiming;
    
    
    InAppPur *tempObserver;
    //倍率
    int power;
    
    ULaser *laser;
    
//    InAppPur *tempObserver;
    
    CCMenuItemImage *itemPower_1,*itemPower_2;
    
//    Mogo_ad *banner;
    //Mogo_ad *banner;
    BOOL isGetAD;//是否获取广告成功
    BOOL isRemoveAD;//是否去除广告
    ADState adState;
    

    NSString *strForWeibo;
    
    CCLabelAtlas *showGetGold;
    
    //图片资源
    CCSprite *moneyForGold;                 //金币
//    CCSprite *fishArr[10];
    NSMutableArray *fishSprireArr;
    
    CCSpriteBatchNode* fishBatchNode;
    //不同场景SP的数据
    int sp_1,sp_5,sp_20,sp_50,sp_100;
    
    //更新金币获取
    NSMutableArray *updateGiveGoldArr;
    CCSprite *giveGoldWord;
    CCMenu *giveGoldMenu;
    
    //倒计时
    CCSprite *getFreeGoldRim;
    CCLabelAtlas *getFreeGoldTimeLabel;
    CCMenuItem *getFreeGoldTimeButton;
    int getFreeTimeNum;
    int getNum;//已经领取的次数
    
    //分享用图
    UIImage *sharedImage;
    
    //各个按钮的
    CCMenuItem *itemPhoto,*itemPause,*itemShop,*itemConnonAdd,*itemConnonDec;
    
    //商店界面
    UShopLayer *shopLayer;
    
    ///dijk 2016-05-21 百度广告
    BaiduMobAdView* sharedAdView;
   
}
@property (assign) int gold;
@property (assign) int power;
@property (assign) BOOL isRemoveAD;
@property (assign) ADState adState;
//@property (assign) Mogo_ad *banner;
@property (assign) GameStateForSingle gameState;

//图片资源
@property (assign) CCSprite *moneyForGold;
@property (assign) NSMutableArray *fishSprireArr;

+(id)scene:(int)p;

-(id)init:(int)p;
+(UGameScene*)sharedScene;

-(void)addExp:(int)e;
-(void)addMoney:(int)num;
-(void)saveGameData;
//-(void)pauseShopMenu;
//-(void)resumeShopMenu;
-(void)showHeadAndLevel;
-(void)deleteBanner;
-(void)showNoMoneyInfo;
-(void)laser:(int)angle  point:(CGPoint)point;
-(void)createGold:(int)num point:(CGPoint)point;
-(void)createButtle:(int)level point:(CGPoint)pos angle:(float)angle;
-(void)playFireEffect;

///dijk 2016-05-21 百度广告
@property(nonatomic,retain) NSString *isInVideo;
@property(nonatomic,retain) NSString *customWidth;
@property(nonatomic,retain) NSString *customHeight;

@property (nonatomic, retain) BaiduMobAdInterstitial* adInterstitial;
@property (nonatomic, retain) UIView *customInterView;
@end
