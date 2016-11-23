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

//层  -1  背景   0鱼   1  UI    2炮塔   3菜单

//tag   10-20  炮塔   100+鱼



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
    NSMutableArray *fishArray;
    
    
    NSMutableArray *bulletArray;            //子弹数组
    NSMutableArray *fishNetArray;           //渔网
    
//    NSMutableArray *otherBulletArray;       //对方的子弹数组
//    NSMutableArray *otherFishNetArray;      //对方的渔网

    
    UBullet *nextBullet;                   //下个子弹
    
    UConnon *connon;
    
    UConnon *otherConnon;
    
    
    int gold;
    
    kPlayerID myID;
    
}
@property (assign)BOOL isHost;


+ (GameSceneForGameCenter *)sharedInstance;
+(id)scene;
- (void)sendData:(NSData *)data;
//-(void)createButtle:(int)level point:(CGPoint)pos angle:(float)angle;
-(void)createButtle:(int)level point:(CGPoint)pos angle:(float)angle player:(kPlayerID)pid;
@end
