//
//  UConnon.h
//  DeepSeaHunt
//
//  Created by Unity on 12-8-29.
//  Copyright (c) 2012年 akn. All rights reserved.
//
#import "CCSprite.h"
#import "GameDefine.h"
#import "ParticleEffectSelfMade.h"



@interface UConnon : CCSprite
{
    //gun muzzle
    CCSprite *gunMuzzle;
    CCSprite *gunBase;

    int  level;
    int connonState;
    //能量
    float sp;
    CCSprite *levelLabel;
    
    kPlayerID playerID;
    
    
    BOOL  isScaleY;
    
    CGPoint turnDot;
    
//    CCLayer *layer;
    
    BOOL isFireIng;
    
    CGSize levelTextureSize;
    

    CCAnimation *animation;
    
    CCSprite *spSprite;
    CGSize spSize;
    
    ParticleEffectSelfMade *storeUP;
}

//@property (assign) CCLayer *layer;
@property (assign) kPlayerID playerID;
@property (assign) BOOL isFireIng;
@property (assign) CGPoint turnDot;
@property (assign) BOOL  isScaleY;
@property (assign) int level;
@property (assign) float sp;
@property (assign) int connonState;
-(CGPoint)getFireDot;
-(id)init:(kPlayerID)pid ;
-(void)turnAngle:(int)angle;
-(void)createButtle;
-(void)setSPShow:(int)num;
-(void)createButtle:(int)angle level:(int)l tag:(int)bulletTag;
-(void)fire:(int)angle;
//接收到的子弹发射消息   不考虑CD
-(void)fireForOther:(int)angle;
//-(void)setSuperLayer:(CCLayer*)l;
-(float)getConnonAngle;
//-(void)fire:(int)angle level:(int)l tag:(int)bulletID;

//-(void)levelAdd;
//
//-(void)levelDec;
-(void)addLaserSP:(int)num;
-(void)setConnonLevel:(int)l;
-(void)storeUp:(int)angle;
-(void)laser:(int)angle;
@end
