//
//  Fish.m
//  study
//
//  Created by Unity on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UFish.h"
#import "GameSceneForGameCenter.h"
#import "UFishSchool.h"
#import "UGameScene.h"
@implementation UFish
@synthesize  type;
@synthesize  speed;
@synthesize  angle;
@synthesize  oldAngle;
@synthesize  state;
@synthesize  x;
@synthesize  y;
@synthesize fishID;
@synthesize fishSchool;
@synthesize isInScreen;
@synthesize outScreenTime;
@synthesize beKillPlayer;

//帧数
static int frames[] = { 5, 7, 5, 7, 9, 9, 8, 8, 8, 9};

-(id)init:(int)fishType frame:(CCSpriteFrame*)spriteFrame speed:(float)fishSpeed angle:(float)fishAngle state:(int)fishState fishPoint:(CGPoint)point playerID:(kPlayerID)pid;
{
    if( (self=[super initWithTexture:spriteFrame.texture rect:CGRectMake(spriteFrame.rect.origin.x, spriteFrame.rect.origin.y, spriteFrame.originalSize.width, spriteFrame.originalSize.height/frames[type])])) {
//        NSString *file=[NSString stringWithFormat:@"fish%d.png",fishType];        
//        [self initWithFile:file];  GameSceneForGameCenter
//        CCSprite *sp;
//        if (GAME_IS_FOR_GAMECENTER) {
//            sp=[[GameSceneForGameCenter shardScene].fishSprireArr objectAtIndex:fishType];
//        }else{
//            sp=[[UGameScene shardScene].fishSprireArr objectAtIndex:fishType];
//        }
        //初始化属性
        
        self.type=fishType;
        self.speed=fishSpeed;
        self.angle=self.oldAngle=fishAngle;
        self.state=fishState;
        self.rotation=angle;
        [self setPositionWithAngle];
        
        self.anchorPoint=ccp(0.5f,0.5f);
        self.position=ccp(point.x,point.y);

        //执行动作
        animation=[CCAnimation animation];
        [animation setDelayPerUnit:0.10f];
        for(int i = 0; i < frames[type]; i++) 
        {
        [animation addSpriteFrameWithTexture: self.texture
                                      rect:CGRectMake(spriteFrame.rect.origin.x, spriteFrame.rect.origin.y+spriteFrame.originalSize.height/frames[type]* i, spriteFrame.originalSize.width,spriteFrame.originalSize.height/frames[type])];
        }
        
        //鱼的宽高
        self.contentSize=CGSizeMake(spriteFrame.originalSize.width, spriteFrame.originalSize.height/frames[type]);
        id action = [CCAnimate actionWithAnimation: animation];
        
        [self runAction:[CCRepeatForever actionWithAction:action]];
        

//        if (pid==kPlayerID_Host) {
//            int temTime=arc4random()%3+3;
//            [self schedule:@selector(turnFish) interval:temTime];
//        }
        [self schedule:@selector(upDataFish) interval:0.1];
    }
    return self;
}


-(void)upDataFish
{

    switch (state) {
        case kFishStateMove:
            [self fishMove];
            break;
        case kFishStateHide:
            break;
        case kFishStateTurnAngle:
            [self fishMove];
            break;
        case kFishStateDeath:
//            count++;
//            if (count%2==0) {
//                self.visible=false;
//            }else {
//                self.visible=true;
//            }
            break;
        default:
            break;
    }
}
-(void)stopFishSchedule
{
    [self unschedule:@selector(upDataFish)];
}
////开始鱼的控制
//-(void)startFishControl
//{
//    if (self.parent==nil) {
//        NSLog(@"鱼的###为空....");
//    }
//    else {
//        
//    }
//    if ([self.parent isKindOfClass:[GameSceneForGameCenter class]]) {
//        NSLog(@" 鱼获取的playerID=%d",((GameSceneForGameCenter*)self.parent).playerID);
//        if (((GameSceneForGameCenter*)self.parent).playerID==kPlayerID_Host) {
//            
//            int temTime=arc4random()%3+3;
//            [self schedule:@selector(turnFish) interval:temTime];
//        }else {
//            
//        }
//    }
//    
//   
//}

-(void)setPositionWithAngle
{
    [self setPositionWithAngle:angle];
     
}
-(void)setPositionWithAngle:(float)theAngle
{
    
    float temAngle=(int)theAngle%90;
    
    if (theAngle>=0&&theAngle<90) {
        
        x= speed*cos(temAngle* M_PI / 180);
        y=-speed*sin(temAngle * M_PI / 180);
        
    }else if (theAngle>=90&&theAngle<180) {
        
        x=-speed*sin(temAngle* M_PI / 180);
        y=-speed*cos(temAngle* M_PI / 180);
        
    }else if (theAngle>=180&&theAngle<270) {
        
        x=-speed*cos(temAngle* M_PI / 180);
        y= speed*sin(temAngle* M_PI / 180);
        
    }else if (theAngle>=270&&theAngle<360) {
        
        x=speed*sin(temAngle* M_PI / 180);
        y=speed*cos(temAngle* M_PI / 180);
    }
}
-(void)fishMove
{

    
    float a=(int)[self rotation]%360;
    if (a<0) {
        a=360+a;
    }
    [self setPositionWithAngle:a];
//    NSLog(@"now angle: %f   angle=%f  x=%f  y=%f",[self rotation],angle,x,y);
    self.position=ccpAdd(self.position, ccp(x, y));
    
    
}
-(void)turnFish
{
    [self unschedule:_cmd];
    oldAngle=angle;
    angle=arc4random()%360;
    
    if (!GAME_IS_FOR_GAMECENTER) {
        int time=abs(angle-oldAngle)/20;
        CCRotateTo *actRotate=[CCRotateTo actionWithDuration:time angle:angle];
        [self runAction:actRotate];
        [self setPositionWithAngle];
        int temTime=arc4random()%2+3+time;
        [self schedule:@selector(turnFish) interval:temTime];
    }else {
        
        MessageFishTurnAngle message;
        message.message.messageType=kMessageTypeFishTurnAngle;
        message.angle=angle;
        message.point=self.position;
        message.tag=fishID;
        
//      self.rotation=angle;
        int time=abs(angle-oldAngle)/20;
        CCRotateTo *actRotate=[CCRotateTo actionWithDuration:time angle:angle];
        [self runAction:actRotate];
        [self setPositionWithAngle];
        
        
        
        
        NSData *data=[NSData dataWithBytes:&message length:sizeof(MessageFishTurnAngle)];
//    [(GameSceneForGameCenter*)gameScene sendData:data];
        [(GameSceneForGameCenter*)self.parent sendData:data];
        
        int temTime=arc4random()%2+3+time;
        [self schedule:@selector(turnFish) interval:temTime];
    }
    
    
   
}

-(void)fishMoveAndRotationControl:(float)theAngle
{
//    NSLog(@"跟随鱼群改变方向");
    oldAngle=angle;
    angle=angle+theAngle;
    
    if (!GAME_IS_FOR_GAMECENTER) {
        
        int time=abs(theAngle)/20;
        CCRotateTo *actRotate=[CCRotateTo actionWithDuration:time angle:angle];
        id acf = [CCCallFunc actionWithTarget:self selector:@selector(stateToMove)];
        [self runAction:[CCSequence actions:actRotate, acf, nil]];
        [self setPositionWithAngle];
        
    }else {
        
        MessageFishTurnAngle message;
        message.message.messageType=kMessageTypeFishTurnAngle;
        message.angle=angle;
        message.point=self.position;
        message.tag=fishID;
        
        int time=abs(theAngle)/20;
        CCRotateTo *actRotate=[CCRotateTo actionWithDuration:time angle:angle];
        
        id acf = [CCCallFunc actionWithTarget:self selector:@selector(stateToMove)];
        
        [self runAction:[CCSequence actions:actRotate, acf, nil]];
        [self setPositionWithAngle];
        
        NSData *data=[NSData dataWithBytes:&message length:sizeof(MessageFishTurnAngle)];
        
        
        [[GameSceneForGameCenter shardScene] sendData:data];
    }
    
}

-(void)stateToMove
{
    if (state==kFishStateDeath) {
        return;
    }
//    NSLog(@"旋转结束");
    [self setState:kFishStateMove];
}
-(void)turnFish:(float)theAngle
{
    [self unschedule:@selector(turnFish)];
    
    oldAngle=angle;
    angle=theAngle;
    
    
    MessageFishTurnAngle message;
    message.message.messageType=kMessageTypeFishTurnAngle;
    message.angle=angle;
    message.point=self.position;
    message.tag=fishID;
    
    int time=abs(angle-oldAngle)/20;
    CCRotateTo *actRotate=[CCRotateTo actionWithDuration:time angle:angle];
    
    id acf = [CCCallFunc actionWithTarget:self selector:@selector(stateToMove)];
        
    [self runAction:[CCSequence actions:actRotate, acf, nil]];
    
    [self setPositionWithAngle];
    
    NSData *data=[NSData dataWithBytes:&message length:sizeof(MessageFishTurnAngle)];
        
    [[GameSceneForGameCenter shardScene] sendData:data];
    
        int temTime=arc4random()%3+3+time;
    [self schedule:@selector(turnFish) interval:temTime];
    
}


-(void)upDataAngleAndPosition:(float)theAngle
{
//    [self stopAllActions];
    oldAngle=angle;
    angle=theAngle;

    
    int time=abs(angle-oldAngle)/20;
    CCRotateTo *actRotate=[CCRotateTo actionWithDuration:time angle:angle];
    id acf = [CCCallFunc actionWithTarget:self selector:@selector(stateToMove)];
    [self runAction:[CCSequence actions:actRotate, acf, nil]];
    [self setPositionWithAngle];
//    int time=abs(angle-oldAngle)/20;
//    CCRotateTo *actRotate=[CCRotateTo actionWithDuration:time angle:angle];
//    [self runAction:actRotate];
}
-(void)setMyFishSchool:(CCNode*)school
{
    fishSchool=school;
}

-(CCNode*)getFishSchool
{
    return fishSchool;
}
-(void)death{
    NSLog(@"鱼被打死咯~~");
    [self stopFishSchedule];
    [self setState:kFishStateDeath];
    if (GAME_IS_FOR_GAMECENTER) {
        [[GameSceneForGameCenter shardScene] addNoUseFishID:self];
        fishID=-1;
        self.tag=-1;
    }

   
    [animation setDelayPerUnit:0.1f];
    id action = [CCAnimate actionWithAnimation: animation];
    id blink=[CCBlink actionWithDuration:1.5 blinks:5];
    [self runAction:[CCRepeatForever actionWithAction:action]];
    [self runAction:blink];
    [self scheduleOnce:@selector(delete) delay:1.5];
        
}
-(void)delete
{
//    NSLog(@"删除掉鱼并生成金币!");
    
    if (!GAME_IS_FOR_GAMECENTER) {
        [[UGameScene sharedScene] createGold:type point:CGPointMake(self.position.x , self.position.y)];
        [self removeFromParentAndCleanup:YES];
    }else {
        [[GameSceneForGameCenter shardScene] createGold:type point:CGPointMake(self.position.x , self.position.y) playerID:beKillPlayer];
        [self removeFromParentAndCleanup:YES];
    }
//    [self stopAllActions];
    
   }
-(void)dealloc
{
//    NSLog(@"鱼被清除");
    [super dealloc];
}
@end
