//
//  UConnon.m
//  DeepSeaHunt
//
//  Created by Unity on 12-8-29.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "UConnon.h"
#import "UGameScene.h"
#import "GameSceneForGameCenter.h"
#define kMaxSPNum 1000
@implementation UConnon
@synthesize isFireIng;
//@synthesize layer;
@synthesize turnDot;
@synthesize isScaleY;
@synthesize level;
@synthesize playerID;
@synthesize sp;
@synthesize connonState;
-(id)init:(kPlayerID)pid
{
    NSString *temStatic,*temFire,*temSP;
    if (GAME_IS_FOR_GAMECENTER) {
        temStatic=@"gc_connon_static.png";
        temFire=@"gc_connon_fire.png";
        temSP=@"gc_sp.png";
    }else{
        temStatic=@"connon_static.png";
        temFire=@"connon_fire.png";
        temSP=@"sp.png";
    }
    if (self=[super initWithFile:temStatic]) {//WithFile:@"connon_static.png"
        
        
        
        animation=[[CCAnimation animation] retain];
        [animation setDelayPerUnit:0.1f];
        
        [animation addSpriteFrameWithFilename:temStatic];
        [animation addSpriteFrameWithFilename:temFire];
        
        connonState=KStateNormal;
        
        spSprite=[CCSprite spriteWithFile:temSP];
        spSize=spSprite.contentSize;
        spSprite.anchorPoint=CGPointZero;
        
        if (GAME_IS_FOR_GAMECENTER) {
            if (isPad) {
                spSprite.position=ccp(38,13);
                turnDot=CGPointMake(0, 32.0f);
            }else{
                spSprite.position=ccp(19,6);
                turnDot=CGPointMake(0, 16.0f);
            }
        }else{
            if (isPad) {
                spSprite.position=ccp(55,18);
                turnDot=CGPointMake(self.contentSize.width/2, 47.0f);
            }else{
                spSprite.position=ccp(25,8);
                turnDot=CGPointMake(self.contentSize.width/2, 47.0f);
            }
        }
        
        [self setSPShow:sp];
        [self addChild:spSprite z:-1];
        
//        self.layer=ly;
        playerID=pid;
        level=kLevel_1;


        //显示炮台等级
        if (GAME_IS_FOR_GAMECENTER) {
            levelLabel = [CCSprite spriteWithFile:@"gc_game_cannon_level_num.png"];
        }else{
            levelLabel = [CCSprite spriteWithFile:@"game_cannon_level_num.png"];
        }
        
        //m_sizeGameLevel = [levelLabel contentSize];
        
        levelTextureSize=levelLabel.contentSize;
        
        [levelLabel setTextureRect:CGRectMake(levelLabel.contentSize.width/7*kLevel_1, 0 ,levelLabel.contentSize.width/7, levelLabel.contentSize.height)];
        
        
        levelLabel.anchorPoint = ccp(0.5f, 0.5f);
        if (GAME_IS_FOR_GAMECENTER) {
            if (isPad) {
                levelLabel.position = ccp(self.contentSize.width/2, 32.0f);
            }else {
                levelLabel.position = ccp(self.contentSize.width/2, 16.0f);
            }
            //the rival level label scaley turn to -1...
            if (playerID!=[GameSceneForGameCenter shardScene].playerID) {
                levelLabel.scaleY=-1;
            }
        }else{
            if (isPad) {
                levelLabel.position = ccp(self.contentSize.width/2+1, 47.0f);
            }else {
                levelLabel.position = ccp(self.contentSize.width/2+1, 21.5f);
            }
        }
        
        
        [self addChild:levelLabel z:2];
                
        self.anchorPoint=ccp(0.5f,0.2f);
    }
    
    return self;
}
-(void)addLaserSP:(int)num
{
    sp+=num;
//    sp+=150;
    if (sp>=kMaxSPNum) {
        sp=kMaxSPNum;
        //切换到等待蓄力
        if (connonState==KStateNormal) {
            if (!GAME_IS_FOR_GAMECENTER) {
//                 [[UGameScene shardScene] setPower1];
            }
            connonState=KStateWaitingForStoreUp;
        }
    }
    [self setSPShow:sp];
}
-(void)setSPShow:(int)num
{
    int h=sp/kMaxSPNum*spSize.height;
    [spSprite setTextureRect:CGRectMake(0, spSize.height-h, spSize.width, h)];
}
-(float)getConnonAngle
{
    return [gunBase rotation];
}
//-(void)setSuperLayer:(CCLayer*)l
//{
//    self.layer=l;
//}
-(CGPoint)getMovePoint:(int)angle
{
    float theAngle=angle%360;
    if (theAngle<0) {
        theAngle=360+theAngle;
    }
    
    float temAngle=(int)theAngle%90;
    float length=5;
    float px,py;
    if (theAngle>=0&&theAngle<90) {
        
        px=-length*sin(temAngle* M_PI / 180);
        py=-length*cos(temAngle * M_PI / 180);
        
    }else if (theAngle>=270&&theAngle<360) {
        
        px=length*sin(temAngle* M_PI / 180);
        py=-length*cos(temAngle* M_PI / 180);
    }
//    else if (theAngle>=90&&theAngle<180) {
//        
//        px=-length*sin(temAngle* 3.14159127 / 180);
//        py=-length*cos(temAngle* 3.14159127 / 180);
//        
//    }else if (theAngle>=180&&theAngle<270) {
//        
//        px=-length*cos(temAngle* 3.14159127 / 180);
//        py= length*sin(temAngle* 3.14159127 / 180);
//        
//    }
   
    
//    CGPoint point=ccpAdd(gunMuzzle.position, CGPointMake(px, py));

    return CGPointMake(px, py);
}
-(void)fire:(int)angle 
{
    if (isFireIng) {
        return;
    }
    if (GAME_IS_FOR_GAMECENTER) {
        [[GameSceneForGameCenter shardScene] sendFireMessage:angle level:level playerID:playerID tag:0];
    }
    isFireIng=true;
    [self turnAngle:angle];
    
}
-(void)fireForOther:(int)angle
{
//    [self turnAngleForGetFireMessage:angle];
    
    CCRotateTo *rotate;
    //    =[CCRotateTo actionWithDuration:abs(angle-[self rotation])/360.0f angle:angle];
    if (isScaleY) {
        rotate=[CCRotateTo actionWithDuration:abs(angle-[self rotation])/360.0f angle:-angle];
    }else{
        rotate=[CCRotateTo actionWithDuration:abs(angle-[self rotation])/360.0f angle:angle];
    }
    
    if ([GameSceneForGameCenter shardScene].rivalGold>=(level+1) ) {
        [GameSceneForGameCenter shardScene].rivalGold-=(level+1);
        id acf=[CCCallFunc actionWithTarget:self selector:@selector(muzzleMove)];
        [self runAction:[CCSequence actions:rotate,acf, nil]];
    }else {
        [self runAction:rotate];
        isFireIng=false;
    }
    
}

-(void)startStoreUP
{
    connonState=KStateForStoreUping;
    [storeUP removeFromParentAndCleanup:YES];
    storeUP=nil;
    CGPoint turnPos;
    CGPoint buttlePoint;
    turnPos=CGPointMake(self.contentSize.height*0.8*sin([self rotation]*M_PI/180), self.contentSize.height*0.8*cos([self rotation]*M_PI/180));
    buttlePoint=ccpAdd(self.position, ccpAdd(CGPointMake(0, 0), turnPos));
    storeUP=[[ParticleEffectSelfMade alloc] initStoreUpWithTotalParticles:500];
    storeUP.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];
    storeUP.position = buttlePoint;
    [((UGameScene*)self.parent) addChild:storeUP z:4];
    
    isFireIng=false;
}
-(void)startStoreUPForGameCenter
{
    connonState=KStateForStoreUping;
    [storeUP removeFromParentAndCleanup:YES];
    storeUP=nil;
    CGPoint turnPos;
    CGPoint buttlePoint;
//    turnPos=CGPointMake(self.contentSize.height*0.8*sin([self rotation]*M_PI/180), self.contentSize.height*0.8*cos([self rotation]*M_PI/180));
//    buttlePoint=ccpAdd(self.position, ccpAdd(CGPointMake(0, 0), turnPos));
    
    turnPos=CGPointMake(self.contentSize.height*0.8*sin(([self rotation]-180)*M_PI/180), self.contentSize.height*0.8*cos(([self rotation]-180)*M_PI/180));
    buttlePoint=ccpAdd(self.position, ccpAdd(CGPointMake(0, 0), turnPos));
    
    storeUP=[[ParticleEffectSelfMade alloc] initStoreUpWithTotalParticles:500];
    storeUP.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];
    storeUP.position = buttlePoint;
    [[GameSceneForGameCenter shardScene] addChild:storeUP z:4];
    
    isFireIng=false;
    
}
-(void)stateToWattingForLaser
{
     connonState=KStateWaitingForLaser;
    isFireIng=false;
    NSLog(@"状态切换到等待激光发射.!");
}
-(void)endStoreUP
{
    storeUP.duration=0;
    NSLog(@"清除蓄力效果");
    [storeUP removeFromParentAndCleanup:YES];
    storeUP=nil;
}
-(void)storeUp:(int)angle
{
    CCRotateTo *rotate=[CCRotateTo actionWithDuration:abs(angle-[self rotation])/360.0f angle:angle];

    id acf2=[CCCallFunc actionWithTarget:self selector:@selector(startStoreUPForGameCenter)];
    [self runAction:[CCSequence actions:rotate,acf2, nil]];
    [self scheduleOnce:@selector(stateToWattingForLaser) delay:2.0f];
}
-(void)laser:(int)angle
{
    NSLog(@"发射激光");
    sp=0;
    [self setSPShow:sp];
    [self endStoreUP];
    self.rotation=angle;
    CGPoint turnPos;
    CGPoint buttlePoint;
    //            turnPos=CGPointMake(self.contentSize.height*0.8*sin([self rotation]*M_PI/180), self.contentSize.height*0.8*cos([self rotation]*M_PI/180));
    //            buttlePoint=ccpAdd(self.position, ccpAdd(CGPointMake(0, 0), turnPos));
    
    
    turnPos=CGPointMake(self.contentSize.height*0.8*sin(([self rotation]-180)*M_PI/180), self.contentSize.height*0.8*cos(([self rotation]-180)*M_PI/180));
    buttlePoint=ccpAdd(self.position, ccpAdd(CGPointMake(0, 0), turnPos));
    NSLog(@"#####[self rotation]=%f",[self rotation]);
    //点击发射激光
    [[GameSceneForGameCenter shardScene] rivalLaser:[self rotation] point:buttlePoint];
    connonState=KStateLaser;
    //3秒后恢复正常
    [self scheduleOnce:@selector(setStateToNormal) delay:4.0f];
}
//get fire message to fire and create bullet.
-(void)turnAngleForGetFireMessage:(int)angle
{
    CCRotateTo *rotate;
    //    =[CCRotateTo actionWithDuration:abs(angle-[self rotation])/360.0f angle:angle];
    if (isScaleY) {
        rotate=[CCRotateTo actionWithDuration:abs(angle-[self rotation])/360.0f angle:-angle];
    }else{
        rotate=[CCRotateTo actionWithDuration:abs(angle-[self rotation])/360.0f angle:angle];
    }
    switch (connonState) {
        case KStateNormal:
            if ([GameSceneForGameCenter shardScene].rivalGold>=(level+1) ) {
                [GameSceneForGameCenter shardScene].rivalGold-=(level+1);
                id acf=[CCCallFunc actionWithTarget:self selector:@selector(muzzleMove)];
                [self runAction:[CCSequence actions:rotate,acf, nil]];
            }else {
                [self runAction:rotate];
                isFireIng=false;
                //金币不足提示
//              [[GameSceneForGameCenter shardScene] showNoMoneyInfo];
            }
            
            break;
        case KStateWaitingForStoreUp:
        {
            //点击开始蓄力
            id acf2=[CCCallFunc actionWithTarget:self selector:@selector(startStoreUPForGameCenter)];
            [self runAction:[CCSequence actions:rotate,acf2, nil]];
            [self scheduleOnce:@selector(stateToWattingForLaser) delay:2.0f];
            //[[GameSceneForGameCenter shardScene] setPower1];
            NSLog(@"开始蓄力");
        }
            break;
        case KStateForStoreUping:
            break;
        case KStateWaitingForLaser:
            NSLog(@"发射激光");
            sp=0;
            [self setSPShow:sp];
            [self endStoreUP];
            self.rotation=-angle;
            CGPoint turnPos;
            CGPoint buttlePoint;
//            turnPos=CGPointMake(self.contentSize.height*0.8*sin([self rotation]*M_PI/180), self.contentSize.height*0.8*cos([self rotation]*M_PI/180));
//            buttlePoint=ccpAdd(self.position, ccpAdd(CGPointMake(0, 0), turnPos));
            
            
            turnPos=CGPointMake(self.contentSize.height*0.8*sin(([self rotation]-180)*M_PI/180), self.contentSize.height*0.8*cos(([self rotation]-180)*M_PI/180));
            buttlePoint=ccpAdd(self.position, ccpAdd(CGPointMake(0, 0), turnPos));
            NSLog(@"#####[self rotation]=%f",[self rotation]);
            //点击发射激光
            [[GameSceneForGameCenter shardScene] rivalLaser:[self rotation] point:buttlePoint];
            connonState=KStateLaser;
            //3秒后恢复正常
            [self scheduleOnce:@selector(setStateToNormal) delay:4.0f];
            break;
        default:
            break;
    }

    
}
-(void)turnAngle:(int)angle
{
    
//    CCRotateTo *rotate;
//    =[CCRotateTo actionWithDuration:abs(angle-[self rotation])/360.0f angle:angle];
    if (isScaleY) {
        angle=-angle;
//        rotate=[CCRotateTo actionWithDuration:abs(angle-[self rotation])/360.0f angle:-angle];
    }else{
//        rotate=[CCRotateTo actionWithDuration:abs(angle-[self rotation])/360.0f angle:angle];
    }
    NSLog(@"1111");
    if (!GAME_IS_FOR_GAMECENTER) {
        
        switch (connonState) {
            case KStateNormal:
                if (((UGameScene*)self.parent).gold>=(level+1)*[UGameScene sharedScene].power) { 
                    ((UGameScene*)self.parent).gold-=(level+1)*[UGameScene sharedScene].power;
                    self.rotation=angle;
                    [self muzzleMove];
//                    id acf=[CCCallFunc actionWithTarget:self selector:@selector(muzzleMove)];
//                    [self runAction:[CCSequence actions:rotate,acf, nil]];
                }else {
                    self.rotation=angle;
//                    [self runAction:rotate];
                    isFireIng=false;
                    [[UGameScene sharedScene] showNoMoneyInfo];
                }
                
                break;
            case KStateWaitingForStoreUp:
            {
                //点击开始蓄力
                self.rotation=angle;
                [self startStoreUP];
//                id acf2=[CCCallFunc actionWithTarget:self selector:@selector(startStoreUP)];
//                [self runAction:[CCSequence actions:rotate,acf2, nil]];
                
                [self scheduleOnce:@selector(stateToWattingForLaser) delay:2.0f];
//                [[UGameScene shardScene] setPower1];
                
                NSLog(@"开始蓄力");
            }
                break;
            case KStateForStoreUping:
                break;
            case KStateWaitingForLaser:
                NSLog(@"发射激光");
                sp=0;
                [self setSPShow:sp];
                [self endStoreUP];
                self.rotation=angle;
                CGPoint turnPos;
                CGPoint buttlePoint;
                turnPos=CGPointMake(self.contentSize.height*0.8*sin([self rotation]*M_PI/180), self.contentSize.height*0.8*cos([self rotation]*M_PI/180));
                buttlePoint=ccpAdd(self.position, ccpAdd(CGPointMake(0, 0), turnPos));
                
                //点击发射激光
                [((UGameScene*)self.parent) laser:angle point:buttlePoint];
                connonState=KStateLaser;
                //3秒后恢复正常
                [self scheduleOnce:@selector(setStateToNormal) delay:4.0f];
                break;
            default:
                break;
        }
        //你造吗？有兽，为直在想，神兽，我会像间酱紫，古琼气，对饮说，其实，为直都，宣你！宣你恩久了！
        //你知道吗？有时候，我一直在想，什么时候，我会像今天这样子，鼓起勇气，对你说，其实，我一直都，喜欢你！喜欢你N久了！
    }else {
        switch (connonState) {
            case KStateNormal:
                if ([GameSceneForGameCenter shardScene].gold>=(level+1) ) {
                    [GameSceneForGameCenter shardScene].gold-=(level+1);
                    self.rotation=angle;
                    [self muzzleMove];
//                    id acf=[CCCallFunc actionWithTarget:self selector:@selector(muzzleMove)];
//                    [self runAction:[CCSequence actions:rotate,acf, nil]];
                }else {
//                    [self runAction:rotate];
                     self.rotation=angle;
                    isFireIng=false;
                    //金币不足提示
//                    [[GameSceneForGameCenter shardScene] showNoMoneyInfo];
                }
                
                break;
            case KStateWaitingForStoreUp:
            {
                //发送蓄力的消息
                [[GameSceneForGameCenter shardScene] sendStoreUpMessage:angle playerID:playerID];
                //点击开始蓄力
                self.rotation=angle;
                [self startStoreUP];
//                id acf2=[CCCallFunc actionWithTarget:self selector:@selector(startStoreUP)];
//                [self runAction:[CCSequence actions:rotate,acf2, nil]];
                [self scheduleOnce:@selector(stateToWattingForLaser) delay:2.0f];
//              [[GameSceneForGameCenter shardScene] setPower1];
                
                NSLog(@"开始蓄力");
            }
                break;
            case KStateForStoreUping:
                break;
            case KStateWaitingForLaser:
                NSLog(@"发射激光");
                //发射激光的消息
                [[GameSceneForGameCenter shardScene] sendLaserFireMessage :angle playerID:playerID];
                
                sp=0;
                [self setSPShow:sp];
                [self endStoreUP];
                self.rotation=angle;
                CGPoint turnPos;
                CGPoint buttlePoint;
                turnPos=CGPointMake(self.contentSize.height*0.8*sin([self rotation]*M_PI/180), self.contentSize.height*0.8*cos([self rotation]*M_PI/180));
                buttlePoint=ccpAdd(self.position, ccpAdd(CGPointMake(0, 0), turnPos));
                
                
//                turnPos=CGPointMake(self.contentSize.height*0.8*sin(([self rotation]-180)*M_PI/180), self.contentSize.height*0.8*cos(([self rotation]-180)*M_PI/180));
//                buttlePoint=ccpAdd(self.position, ccpAdd(CGPointMake(0, 0), turnPos));
                //点击发射激光
                [[GameSceneForGameCenter shardScene] laser:angle point:buttlePoint];
                connonState=KStateLaser;
                //3秒后恢复正常
                [self scheduleOnce:@selector(setStateToNormal) delay:4.0f];
                break;
            default:
                break;
        }
    }

}
-(CGPoint)getFireDot
{
    CGPoint turnPos;
    CGPoint buttlePoint;
    if (isScaleY) {
        turnPos=CGPointMake(self.contentSize.height*0.8*sin(([self rotation]-180)*M_PI/180), self.contentSize.height*0.8*cos(([self rotation]-180)*M_PI/180));
        buttlePoint=ccpAdd(self.position, ccpAdd(CGPointMake(0, 0), turnPos));
    }else{
        turnPos=CGPointMake(self.contentSize.height*0.8*sin([self rotation]*M_PI/180), self.contentSize.height*0.8*cos([self rotation]*M_PI/180));
        buttlePoint=ccpAdd(self.position, ccpAdd(CGPointMake(0, 0), turnPos));
    }
    return buttlePoint;
}
-(void)setStateToNormal
{
    connonState=KStateNormal;
    isFireIng=false;
    
}
-(void)muzzleMove
{
    if (!GAME_IS_FOR_GAMECENTER) {
        id acf=[CCCallFunc actionWithTarget:self selector:@selector(createButtleByOnce)];
        id action = [CCAnimate actionWithAnimation:animation];
        [self runAction: [CCSequence actions: action, [action reverse],acf, nil]];
    }else{
        id acf=[CCCallFunc actionWithTarget:self selector:@selector(createButtleByGameCenter)];
        id action = [CCAnimate actionWithAnimation:animation];
        [self runAction: [CCSequence actions: action, [action reverse],acf, nil]];
    }
    

}
-(void)setFireStateToStatic
{
    isFireIng=false;
//    [self setTexture:frame_staic.texture];
    [self createButtle];
}
-(void)playFireEffect
{
    if (GAME_IS_PLAY_EFFECT) {
        [GAME_AUDIO playEffect:kSoundTypeForConnonFire];
    }
}
-(void)createButtleByOnce
{
    isFireIng=false;
    [self playFireEffect];
    CGPoint turnPos;
    CGPoint buttlePoint;

    turnPos=CGPointMake(self.contentSize.height*0.8*sin([self rotation]*M_PI/180), self.contentSize.height*0.8*cos([self rotation]*M_PI/180));
    
    buttlePoint=ccpAdd(self.position, ccpAdd(CGPointMake(0, 0), turnPos));
    [[UGameScene sharedScene] createButtle:level point:buttlePoint angle:[self rotation]];

}
-(void)createButtleByGameCenter
{
    isFireIng=false;
    [self playFireEffect];
    CGPoint turnPos;
    CGPoint buttlePoint;
    
//   turnPos=CGPointMake(self.contentSize.height*0.8*sin([self rotation]*M_PI/180), self.contentSize.height*0.8*cos([self rotation]*M_PI/180));
    NSLog(@"!!!connon rotation  for create bullet:%f",[self rotation]);
//    buttlePoint=ccpAdd(self.position, ccpAdd(CGPointMake(0, 0), turnPos));
    if (isScaleY) {
        turnPos=CGPointMake(self.contentSize.height*0.8*sin(([self rotation]-180)*M_PI/180), self.contentSize.height*0.8*cos(([self rotation]-180)*M_PI/180));
        buttlePoint=ccpAdd(self.position, ccpAdd(CGPointMake(0, 0), turnPos));
        [[GameSceneForGameCenter shardScene] createButtle:level point:buttlePoint angle:[self rotation]+180 player:playerID tag:-1];
        
    }else{
        turnPos=CGPointMake(self.contentSize.height*0.8*sin([self rotation]*M_PI/180), self.contentSize.height*0.8*cos([self rotation]*M_PI/180));
        buttlePoint=ccpAdd(self.position, ccpAdd(CGPointMake(0, 0), turnPos));
        [[GameSceneForGameCenter shardScene] createButtle:level point:buttlePoint angle:[self rotation]player:playerID tag:-1];
        
    }
    
    
}
-(void)createButtle
{
    [self playFireEffect];
    if (!GAME_IS_FOR_GAMECENTER) {
        CGPoint turnPos;
        CGPoint buttlePoint;
//        turnPos=CGPointMake(gunBase.contentSize.height*sin([gunBase rotation]*M_PI/180), gunBase.contentSize.height*cos([gunBase rotation]*M_PI/180));
        turnPos=CGPointMake(self.contentSize.height*sin([self rotation]*M_PI/180), self.contentSize.height*cos([self rotation]*M_PI/180));
        //    NSLog(@"turnPos.x =%f   turnPos.y =%f",turnPos.x,turnPos.y);
        
        buttlePoint=ccpAdd(self.position, ccpAdd(self.position, turnPos));
        
        //        [(UGameVersusLayer*)layer createButtle:connonLevel point:buttlePoint angle:[gunBase rotation]player:playerID];
        
        [(UGameScene*)self.parent createButtle:level point:buttlePoint angle:[self rotation]];
    }else {
        //    [(GameSceneForGameCenter*)layer createButtle:connonLevel point:self.position angle:[gunMuzzle rotation]];
        CGPoint turnPos;
        CGPoint buttlePoint;
        if (isScaleY) {
            turnPos=CGPointMake(gunBase.contentSize.height*sin([gunBase rotation]*M_PI/180), gunBase.contentSize.height*cos([gunBase rotation]*M_PI/180));
            
            //    NSLog(@"turnPos.x =%f   turnPos.y =%f",turnPos.x,turnPos.y);
            
            CGPoint tem=ccpAdd(gunBase.position, turnPos);
            
            buttlePoint=ccp(self.position.x+tem.x,self.position.y-tem.y );
            
            
            
            //        [(UGameVersusLayer*)layer createButtle:connonLevel point:buttlePoint angle:180-[gunBase rotation]player:playerID];
            [[GameSceneForGameCenter shardScene] createButtle:level point:buttlePoint angle:180-[gunBase rotation]player:playerID tag:-1];
            
        }else {
            turnPos=CGPointMake(gunBase.contentSize.height*sin([gunBase rotation]*M_PI/180), gunBase.contentSize.height*cos([gunBase rotation]*M_PI/180));
            
            //    NSLog(@"turnPos.x =%f   turnPos.y =%f",turnPos.x,turnPos.y);
            
            buttlePoint=ccpAdd(self.position, ccpAdd(gunBase.position, turnPos));
            
            //        [(UGameVersusLayer*)layer createButtle:connonLevel point:buttlePoint angle:[gunBase rotation]player:playerID];
            
            [[GameSceneForGameCenter shardScene] createButtle:level point:buttlePoint angle:[gunBase rotation]player:playerID tag:-1];
            
        }
    }
    

    
    NSLog(@"gunBase的角度=%f",[gunBase rotation]);
    
    
}
-(void)createButtle:(int)angle level:(int)l tag:(int)bulletTag
{
//    [(GameSceneForGameCenter*)layer createButtle:connonLevel point:self.position angle:[gunMuzzle rotation]];
    
    gunBase.rotation=angle;
    
    CGPoint turnPos;
    CGPoint buttlePoint;
    if (isScaleY) {
         turnPos=CGPointMake(gunBase.contentSize.height*sin([gunBase rotation]*M_PI/180), gunBase.contentSize.height*cos([gunBase rotation]*M_PI/180));
        
        //    NSLog(@"turnPos.x =%f   turnPos.y =%f",turnPos.x,turnPos.y);
        
        CGPoint tem=ccpAdd(gunBase.position, turnPos);
        
         buttlePoint=ccp(self.position.x+tem.x,self.position.y-tem.y );
        
//        [(UGameVersusLayer*)layer createButtle:connonLevel point:buttlePoint angle:180-[gunBase rotation]player:playerID];
        [[GameSceneForGameCenter shardScene] createButtle:l point:buttlePoint angle:180-[gunBase rotation]player:playerID tag:bulletTag];
        
    }else {
        turnPos=CGPointMake(gunBase.contentSize.height*sin([gunBase rotation]*M_PI/180), gunBase.contentSize.height*cos([gunBase rotation]*M_PI/180));
        
        //    NSLog(@"turnPos.x =%f   turnPos.y =%f",turnPos.x,turnPos.y);
        
        buttlePoint=ccpAdd(self.position, ccpAdd(gunBase.position, turnPos));
        
//        [(UGameVersusLayer*)layer createButtle:connonLevel point:buttlePoint angle:[gunBase rotation]player:playerID];
        
        [[GameSceneForGameCenter shardScene] createButtle:l point:buttlePoint angle:[gunBase rotation]player:playerID tag:bulletTag];
        
    }
    NSLog(@"gunBase的角度=%f",[gunBase rotation]);
    
}
-(void)setConnonLevel:(int)l
{
    level=l;
    [levelLabel setTextureRect:CGRectMake(levelTextureSize.width/7*l, 0 ,levelTextureSize.width/7, levelTextureSize.height)];
    
//     [levelLabel setTextureRect:CGRectMake(l * 9, 0, 9, 12)];
}
@end
