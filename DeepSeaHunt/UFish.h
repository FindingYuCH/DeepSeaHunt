//
//  Fish.h
//  study
//
//  Created by Unity on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import <GameKit/GameKit.h>
#import "GameDefine.h"



@interface UFish : CCSprite
{
    int type;
    float speed;
    float angle,oldAngle;
    int state;
    
    int fishID;
    
    kPlayerID beKillPlayer;             //杀死该鱼的玩家
    
    CCNode *fishSchool;                 //所属的鱼群
    
    CCAnimation *animation;
    float x;
    float y;
    
    int count;
    
    int outScreenTime;
    
    BOOL isInScreen;    
}
@property (assign) BOOL isInScreen;
@property (assign) int type;
@property (assign) int outScreenTime;
@property (assign) int fishID;
@property (assign) float speed;
@property (assign) float angle;
@property (assign) float oldAngle;
@property (assign) int state;
@property (assign) float x;
@property (assign) float y;
@property (assign) CCNode *fishSchool;
@property (assign) kPlayerID beKillPlayer;

-(id)init:(int)fishType frame:(CCSpriteFrame*)spriteFrame speed:(float)fishSpeed angle:(float)fishAngle state:(int)fishState fishPoint:(CGPoint)point playerID:(kPlayerID)pid;
-(void)upDataAngleAndPosition:(float)theAngle;
-(void)fishMoveAndRotationControl:(float)theAngle;
-(void)setMyFishSchool:(CCNode*)school;
-(CCNode*)getFishSchool;
-(void)death;
-(void)stopFishSchedule;
@end
