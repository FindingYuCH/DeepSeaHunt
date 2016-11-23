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
#define kFishNumControl 50


@implementation GameSceneForGameCenter
@synthesize isHost;


static GameSceneForGameCenter *sharedScene = nil;
+ (GameSceneForGameCenter *) sharedInstance {
    if (!sharedScene) {
        sharedScene = [[GameSceneForGameCenter alloc] init];
    }
    return sharedScene;
}

+(id)scene
{
    CCScene *scene=[CCScene node];
    CCLayer *layer=[GameSceneForGameCenter sharedInstance];
    [scene addChild:layer];
    return scene;
}

-(id)init
{
    if (self=[super init]) {
        [self checkDeviceType];
        
        //初始化各个数组
        bulletArray=[[NSMutableArray alloc] init];
        fishNetArray=[[NSMutableArray alloc] init];
        fishArray=[[NSMutableArray alloc] init];
        fishNoUseTag=[[NSMutableArray alloc] init];
        
        
        
        //鱼的测试
//        [self fishTest];
        //初始化游戏中心
        [self initGameCenter];

        //初始化炮塔
        isHost=true;
        [self initCannon];
        
        if (isPad) {
            CCSprite *desk=[CCSprite spriteWithFile:@"desktops.png"];
            desk.anchorPoint=CGPointZero;
            desk.position=ccp(0,0);
            [self addChild:desk z:99 tag:kTagDesk];
//            self.anchorPoint=CGPointZero;
//            self.position=ccp(32,64);
        }
        
        self.isTouchEnabled=YES;
        
        
        [self schedule:@selector(upData) interval:0.1 ];
        
        
        
    }
    return self;
}
-(void)fishTest
{
//        isHost=true;
        [self createFish:5 fishSpeed:3 fishAngle:60 fishPoint:ccp(200, 200)fishTag:100];
    //        UFish *fish = [[UFish alloc] init:5 speed:2 angle:60 state:0 fishPoint:ccp(200, 200) scene:self];
    //        [self addChild:fish z:99 tag:1];
    
    
    //       [self initFish];
}
-(void)initGameCenter
{
    ourRandom = arc4random();
    
    AppController *delegate= (AppController *) [[UIApplication sharedApplication] delegate];                              
    [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.navController delegate:self];
    [self setGameState:kGameStateWaitingForChoiceHost];
}
-(void)initCannon
{
    
    
    if (isHost) {
        
        connon=[[UConnon alloc] init:kPlayerID_Host layer:self];
        otherConnon=[[UConnon alloc] init:kPlayerID_2 layer:self];
       
        
        connon.position=ccp(deviceValue.sceneWidth/4-connon.contentSize.width/2+deviceValue.rimWidth,deviceValue.rimHeight);
        
        
        otherConnon.position=ccp(deviceValue.sceneWidth/4*3-otherConnon.contentSize.width/2+deviceValue.rimWidth,deviceValue.sceneHeight-deviceValue.rimHeight);
        
        otherConnon.scaleY=-1;
        otherConnon.isScaleY=true;
        NSLog(@" 位置对比:  预计=%f    结果=%f",deviceValue.sceneWidth/4*3-otherConnon.contentSize.width/2+deviceValue.rimWidth,otherConnon.position.x);
        
    }else {
        
        connon=[[UConnon alloc] init:kPlayerID_2 layer:self];
        otherConnon=[[UConnon alloc] init:kPlayerID_Host layer:self];
        
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

-(void)createButtle:(int)level point:(CGPoint)pos angle:(float)angle player:(kPlayerID)pid
{

    nextBullet=[[UBullet alloc] init:@"bullet6.png" player:pid level:level point:pos];
    
//    NSLog(@" 接收到的角度 tan angle=%f",tan(angle*M_PI / 180));
    
    
    if (angle>=90) {
        float realY = deviceValue.sceneHeight+nextBullet.contentSize.height;
        
        float realX = (realY *tan(angle*M_PI / 180));
        
        CGPoint realDest = ccp(pos.x-realX, pos.y-realY);
        
        
        float offRealX = pos.x-realDest.x;
        float offRealY = pos.y-realDest.y;
        float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
        float velocity = 480/1; // 480pixels/1sec
        float realMoveDuration = length/velocity;
        
        [bulletArray addObject:nextBullet];
        
        
        [self addChild:nextBullet z:0];
        
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
        float velocity = 480/1; // 480pixels/1sec
        float realMoveDuration = length/velocity;
        
        [bulletArray addObject:nextBullet];
        
        
        [self addChild:nextBullet z:0];
        
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
    
	CCSprite *sprite=(CCSprite *)sender;
	[self removeChild:sprite cleanup:YES];
	
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
-(void)initGame
{
    switch (gameState) {
        case kGameStateWaitingForChoiceHost:
            
            break;
            
        default:
            break;
    }
}

-(void)initFish
{
    
//    x=3;
//    y=3;
//    UFish *fish = [[UFish alloc] init];
//    fish.position=CGPointMake(100, 100);
//    [self addChild:fish z:1 tag:1];
    
    CGSize s=[[CCDirector sharedDirector] winSize];
    fishArray=[[NSMutableArray alloc] init];
    
    MessageInitData initData;
    initData.message.messageType=kMessageTypeInitData;
    initData.num=300;
    
    for (int i=0; i<300; i++) {
        
        FishData fish;
        fish.fishType=arc4random()%10;
        fish.speed=arc4random()%3+3;
        fish.angle=50;
        fish.state=0;
        fish.tag=100+i;
        fish.point=CGPointMake(arc4random()%(int)s.width, arc4random()%(int)s.height);
                
        UFish *uFish = [[UFish alloc] init:fish.fishType speed:fish.speed angle:fish.angle state:fish.state fishPoint:fish.point scene:self];
        uFish.fishID=100+i;
        [self addChild:uFish z:10 tag:100+i];
        initData.fishArray[i]=fish;
        [fishArray addObject:uFish];
        
    }

    
    NSData *data=[NSData dataWithBytes:&initData length:sizeof(MessageInitData)];
    
    [self sendData:data];
    
}
//更新鱼的状态
-(void)upDataFish
{
    //检查鱼是否有超出屏幕
    
    
    
    
}
//刷鱼控制
-(void)createFishControl
{
    if (fishArray!=nil) {
        if (fishArray.count<kFishNumControl) {
            for (int i=0; i<4; i++) {
            [self createFish:arc4random()%6 fishSpeed:2 fishAngle:30 fishPoint:CGPointMake(200, 200) fishTag:105+fishArray.count];
            }
            
            
        }
        
        
    }

}

int n=0;
-(void)fishUpdata
{
    
    CGSize s=[[CCDirector sharedDirector] winSize];
    int count=fishArray.count;
    
    MessageUpdata message;
    message.message.messageType=kMessageTypeUpdata;
    message.num=300;
    
    
    for (int i=0; i<count; i++) {
        UFish *fish=[fishArray objectAtIndex:i];
        
        if (fish.position.x<=0) {
            fish.x=3;
        }else if (fish.position.x>s.width) {
            fish.x=-3;
        }
        if (fish.position.y<=0) {
            fish.y=3;
        }else if (fish.position.y>s.height) {
            fish.y=-3;
        }
        
        fish.position=ccpAdd(fish.position, ccp(fish.x,fish.y));
        

        message.fishArray[i].speed=fish.speed;
        message.fishArray[i].angle=fish.angle;
        message.fishArray[i].state=fish.state;
        message.fishArray[i].point=fish.position;
        
    }
    
    NSData *data=[NSData dataWithBytes:&message length:sizeof(MessageUpdata)];
    
    
//    NSString *path = @"/Users/unity/Desktop/f1.rtf";	
//    if (n==0) {
//        [data writeToFile:path atomically:YES];
//        n++;
//    }
//    
    
    [self sendData:data];
    [data release];
    
}
-(void)sendFireMessage:(double)angle
{
    MessageFire message;
    message.message.messageType=kMessageTypeFire;
    message.angle=angle;
     NSData *data=[NSData dataWithBytes:&message length:sizeof(MessageFire)];
    [self sendData:data];
    
}
//FishData fish;
//fish.fishType=arc4random()%10;
//fish.speed=arc4random()%3+3;
//fish.angle=50;
//fish.state=0;
//fish.tag=100+i;
//fish.point=CGPointMake(arc4random()%(int)s.width, arc4random()%(int)s.height);
//
//UFish *uFish = [[UFish alloc] init:fish.fishType speed:fish.speed angle:fish.angle state:fish.state fishPoint:fish.point scene:self];
//uFish.fishID=100+i;

-(void)createFish:(int)type fishSpeed:(float)speed fishAngle:(float)angle fishPoint:(CGPoint)point fishTag:(int)tag
{
    NSLog(@"createFish");
    UFish *fish = [[UFish alloc] init:type speed:speed angle:angle state:0 fishPoint:point scene:self];
    fish.fishID=tag;
    [self addChild:fish z:10 tag:tag];
    [fishArray addObject:fish];
    [self sendCreateFish:fish];
    
}
-(void)upData
{   
    
    
    
    //子弹与鱼的碰撞
    
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
	for (UBullet *bullet in bulletArray) {
		CGRect bulletRect = CGRectMake(
										   bullet.position.x - (bullet.contentSize.width/2), 
										   bullet.position.y - (bullet.contentSize.height/2), 
										   bullet.contentSize.width, 
										   bullet.contentSize.height);
		
		NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
		for (UFish *fish in fishArray) {
            //非死亡状态
            if (fish.state!=kFishStateDeath) {
                CGRect fishRect = CGRectMake(
                                             fish.position.x - (fish.contentSize.width/2), 
                                             fish.position.y - (fish.contentSize.height/2), 
                                             fish.contentSize.width, 
                                             fish.contentSize.height);
                
                
                //检测子弹与鱼的碰撞
                if (CGRectIntersectsRect(bulletRect, fishRect)) {
//                    [targetsToDelete addObject:fish]; 
                    [fish death];
                } 

            }
        }
		
		for (UFish *fish in targetsToDelete) {
			[fishArray removeObject:fish];
			[self removeChild:fish cleanup:YES]; 
		}
		
		if (targetsToDelete.count > 0) {
			[projectilesToDelete addObject:bullet];
		}
		[targetsToDelete release];
	}
	
	for (UBullet *bullet in projectilesToDelete) {
		[bulletArray removeObject:bullet];
		[self removeChild:bullet cleanup:YES];
	}
	[projectilesToDelete release];
    
    
    
    
//    CGSize s = [[CCDirector sharedDirector] winSize];
//    
//    if (isHost) {
//        
//        if (gameState==kGameStateGameIng) {
//            NSLog(@"更新鱼的数据");
//            [self fishUpdata];
//            
//        }
//        
//    }
    
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
    
    
   
    
    //判断金币是否大于炮塔等级的需求  满足则发射子弹
    if (true) {
        
        if (isHost) {
            CGPoint gunPoint=ccpAdd(connon.position, connon.turnDot);
            double w = location.x - gunPoint.x;
            double h = location.y - gunPoint.y;
            double radian = atan(w/h);
            double degrees = CC_RADIANS_TO_DEGREES(radian);
            //      NSLog(@"##########gunPoint.x=%f  gunPoint.y=%f  点击的角度:%f  atan1=%f",gunPoint.x, gunPoint.y,degrees,CC_RADIANS_TO_DEGREES(atan(1)));
            
            [connon fire:degrees];
            [self sendFireMessage:degrees];
        }else {
            //非主机屏幕进行旋转后

            CGSize s=[[CCDirector sharedDirector] winSize];
            location=ccp(s.width-location.x, s.height-location.y);
           
            CGPoint gunPoint=ccp(connon.position.x+connon.turnDot.x, connon.position.y-connon.turnDot.y);
            double w = gunPoint.x-location.x;
            double h = gunPoint.y-location.y ;
            double radian = atan(w/h);
            double degrees = CC_RADIANS_TO_DEGREES(radian);
            //      NSLog(@"##########gunPoint.x=%f  gunPoint.y=%f  点击的角度:%f  atan1=%f",gunPoint.x, gunPoint.y,degrees,CC_RADIANS_TO_DEGREES(atan(1)));
            NSLog(@"??? connon.position.x=%f   connon.position.y=%f  w=%f   h=%f",connon.position.x,connon.position.y,w,h);
            NSLog(@"与炮塔的角度=%f",degrees);            
            [connon fire:-degrees];
            [self sendFireMessage:-degrees];
        }
        
        
    }
    NSLog(@"点击的位置：x=%f    y=%f",location.x,location.y);

}
-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
}
- (void)sendData:(NSData *)data {
    NSError *error;
    BOOL success;
    
//    if (!isChoiceHost) {
        success = [[GCHelper sharedInstance].match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
        
        
        if (!success) {
            CCLOG(@"主机发送给其他人失败：Error sending init packet");
            
            [self matchEnded];
        }
//    }else if (isHost) {
//        
//        success = [[GCHelper sharedInstance].match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
//        
//        
//        if (!success) {
//            CCLOG(@"主机发送给其他人失败：Error sending init packet");
//            [self matchEnded];
//        }
//        
//    }else {
//        
//        GKPlayer *player = [[GCHelper sharedInstance].playersDict objectForKey:hostID];
//        NSArray *array=[[NSArray alloc] init];
//        [array setValue:player forKey:hostID];
//        success=[[GCHelper sharedInstance].match sendData:data toPlayers:array withDataMode:GKMatchSendDataReliable error:&error];
//        
//        
//        if (!success) {
//            CCLOG(@"发送给主机失败：Error sending init packet");
//            [self matchEnded];
//        }
//    }

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
-(void)sendGameBegin
{
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)]; 
    [self sendData:data];
}
-(void)sendCreateFish:(UFish*)fish
{
    NSLog(@"send create fish message");
    MessageCreateFish mCreateFish;
    mCreateFish.message.messageType=kMessageTypeCreateFish;
    mCreateFish.fishType=fish.type;
    mCreateFish.speed=fish.speed;
    mCreateFish.angle=fish.angle;
    mCreateFish.state=fish.state;
    mCreateFish.point=fish.position;
    mCreateFish.tag=fish.tag;
    
    NSData *data = [NSData dataWithBytes:&mCreateFish length:sizeof(MessageCreateFish)]; 
    [self sendData:data];
    
}
-(void)sendFishData
{
    
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

-(CGPoint)toThisPosition:(CGPoint)point
{
    
    if (otherDeviceValue.sceneWidth==deviceValue.sceneWidth&&otherDeviceValue.sceneHeight==deviceValue.sceneHeight) {
        return point;
    }else {
        CGPoint temPoint=CGPointMake(point.x*deviceValue.sceneWidth/otherDeviceValue.sceneWidth-otherDeviceValue.rimWidth+deviceValue.rimWidth, point.y*deviceValue.sceneHeight/otherDeviceValue.sceneHeight-otherDeviceValue.rimHeight+deviceValue.rimHeight);
        return temPoint;
    }
    
}
-(float)toThisSpeed:(float)sp
{
    if (otherDeviceValue.speedRatio==deviceValue.speedRatio) {
        return sp;
    }else {
        return sp*deviceValue.speedRatio/otherDeviceValue.speedRatio;
    }


}
- (void)dealloc
{
	[super dealloc];
}
#pragma mark GCHelperDelegate

- (void)matchStarted { 
    
    CCLOG(@"Match started22"); 
//    if (!isChoiceHost) {
//         NSLog(@"发送随机数");
//        [self setGameState:kGameStateWaitingForChoiceHost];
//        
//    }else {
//        
//        NSLog(@"已经选择了主机");
//    }
    
    [self sendRandom];
    
}

- (void)matchEnded { 
    CCLOG(@"Match ended"); 
    
    [[GCHelper sharedInstance].match disconnect];
    [GCHelper sharedInstance].match = nil;
    //[self endScene:kEndReasonDisconnect];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    CCLOG(@"Received data");
    

    
    Message *message = (Message *) [data bytes];
    
    if (message->messageType == kMessageTypeChoiceHost) {
        
        MessageChoiceHost * messageInit = (MessageChoiceHost *) [data bytes];
        otherDeviceValue=messageInit->deviceValue;
        
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
            myID=kPlayerID_Host;
        } else {
            CCLOG(@"We are not host");
            isHost = NO;
            hostID=playerID;
            myID=kPlayerID_2;
            NSLog(@"主机的名字:%@",playerID);
        }
        
        if (!tie) {
            isChoiceHost = YES; 
            [self setGameState:kGameStateInitData];
            
            [self initCannon];
            
            if (isHost) {
                //为主机的话  初始化游戏数据
                [self createFish:3 fishSpeed:2 fishAngle:30 fishPoint:CGPointMake(200, 200) fishTag:100];
                [self createFish:4 fishSpeed:2 fishAngle:60 fishPoint:CGPointMake(200, 250) fishTag:101];
                [self createFish:5 fishSpeed:2 fishAngle:180 fishPoint:CGPointMake(200, 300) fishTag:102];
                [self createFish:6 fishSpeed:2 fishAngle:270 fishPoint:CGPointMake(300, 300) fishTag:103];
//                [self initFish];
                
            }else {
//                CCRotateTo *rotateTo=[CCRotateTo actionWithDuration:0 angle:180];
//                
//                [self runAction:rotateTo];
            }
        }
        
    } else if (message->messageType == kMessageTypeGameBegin) { 
        NSLog(@"收到游戏开始消息");
        [self setGameState:kGameStateGameIng];
        
        //        [self setGameState:kGameStateActive];
        
    } else if (message->messageType == kMessageTypeMove) { 
        
        CCLOG(@"Received move");
        
        MessageMove *message=(MessageMove *)[data bytes];
        
        UFish *fish=(UFish *)[self getChildByTag:1];
        NSLog(@"收到鱼的坐标:x=%f  y=%f",message->x,message->y);
        fish.position=CGPointMake(message->x, message->y);
        
        //        if (isPlayer1) {
        //            [player2 moveForward];
        //        } else {
        //            [player1 moveForward];
        //        } 
    } else if (message->messageType == kMessageTypeGameOver) { 
        
        MessageGameOver * messageGameOver = (MessageGameOver *) [data bytes];
        CCLOG(@"Received game over with player 1 won: %d", messageGameOver->player1Won);
        
        if (messageGameOver->player1Won) {
            //[self endScene:kEndReasonLose]; 
        } else {
            //[self endScene:kEndReasonWin]; 
        }
        
    }else if(message->messageType == kMessageTypeCreateFish) {  
        
        MessageCreateFish *mCreateFish=(MessageCreateFish *)[data bytes];
        NSLog(@"鱼的类型=%d  ,速度：%f  ,位置:x=%f ,  y=%f",mCreateFish->fishType,mCreateFish->speed,mCreateFish->point.x,mCreateFish->point.y);
        
        CGPoint temPoint=[self toThisPosition:mCreateFish->point];
        
        float speed=[self toThisSpeed:mCreateFish->speed];
        
        UFish *fish=[[UFish alloc] init:mCreateFish->fishType speed:speed angle:mCreateFish->angle state:mCreateFish->state fishPoint:temPoint scene:self];
        fish.fishID=mCreateFish->tag;
        [self addChild:fish z:10 tag:mCreateFish->tag];
        
        
        if (gameState!=kGameStateGameIng) {
            [self setGameState:kGameStateGameIng];
            [self sendInitDataDone];
        }
        
        
    }else if(message->messageType == kMessageTypeInitDone) {  
        
        //接收到初始化完成的消息  开始游戏并通知其他玩家游戏开始
        NSLog(@"收到初始化完成消息  进入游戏");
        [self setGameState:kGameStateGameIng];
        [self schedule:@selector(upData) interval:0.1 ];
        //刷鱼控制
        [self schedule:@selector(createFishControl) interval:2 ];
        
        [self sendGameBegin];
        
    }else if (message->messageType==kMessageTypeInitData) {
        
        MessageInitData *initData=(MessageInitData *)[data bytes];
        fishArray=[[NSMutableArray alloc] init];
        int num=initData->num;
        
        for (int i=0; i<num; i++) {
            
            CGPoint temPoint=[self toThisPosition:initData->fishArray[i].point];
            
            float speed=[self toThisSpeed:initData->fishArray[i].speed];
            
            UFish *uFish = [[UFish alloc] 
                            init:initData->fishArray[i].fishType 
                            speed:speed
                            angle:initData->fishArray[i].angle 
                            state:initData->fishArray[i].state 
                            fishPoint:temPoint 
                            scene:self];
            uFish.fishID=initData->fishArray[i].tag;
            [self addChild:uFish z:10 tag:initData->fishArray[i].tag];
            [fishArray addObject:uFish];
            
//            NSLog(@"鱼的类型=%d   速度=%f  角度=%f  状态=%d  位置:x=%f   y=%f",initData->fishArray[i].fishType,initData->fishArray[i].speed,initData->fishArray[i].angle,initData->fishArray[i].state,initData->fishArray[i].point.x,initData->fishArray[i].point.y);

        }
        [self sendInitDataDone];
    }else if (message->messageType==kMessageTypeUpdata) {
        MessageUpdata *mUpdata=(MessageUpdata*)[data bytes];
        
//        NSString *path = @"/Users/unity/Desktop/f1.rtf";	
//        if (n==0) {
//            [data writeToFile:path atomically:YES];
//            n++;
//        }
        
        int count=fishArray.count;
        
        for (int i=0; i<count; i++) {
            UFish *uFish=[fishArray objectAtIndex:i];
            uFish.speed=mUpdata->fishArray[i].speed;
            uFish.angle=mUpdata->fishArray[i].angle;
            uFish.state=mUpdata->fishArray[i].state;
            uFish.position=mUpdata->fishArray[i].point;
        }
        
        
    }else if (message->messageType==kMessageTypeFishTurnAngle) {
        NSLog(@"改变鱼的方向  命令");
        MessageFishTurnAngle *message=(MessageFishTurnAngle*)[data bytes];
            CGPoint temPoint=[self toThisPosition:message->point];
        
        
        UFish *fish=(UFish *)[self getChildByTag:message->tag];
        fish.position=temPoint;
        [fish upDataAngleAndPosition:message->angle];
       
    }else if (message->messageType==kMessageTypeFire) {
        MessageFire *fireMessage=(MessageFire*)[data bytes];
        
        //创建子弹
        [otherConnon fire:fireMessage->angle];

        
    }
    
}
- (void)inviteReceived
{
    NSLog(@"邀请之后的回调函数!");
    
}

@end
