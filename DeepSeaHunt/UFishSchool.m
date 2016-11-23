//
//  UFishSchool.m
//  DeepSeaHunt
//
//  Created by Unity on 12-9-3.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "UFishSchool.h"
#import "GameSceneForGameCenter.h"

@implementation UFishSchool
@synthesize fishArray;
@synthesize fishSchoolType;
-(id)init
{
    
    if (self=[super init]) {
        
        fishArray=[[NSMutableArray alloc] init];
        
//        NSLog(@"创建鱼群");
        switch (fishSchoolType) {
            case kFishSchoolType_10:
            case kFishSchoolType_11:
            case kFishSchoolType_12:
                break;
            default:
            {
                //鱼群的游动控制
                int temTime=arc4random()%3+3;
                [self schedule:@selector(turnFish) interval:temTime];
            }
                break;
        }        
    }
    
    return self;
}
-(id)init:(kFishSchoolType)type
{
    if (self=[super init]) {
        fishSchoolType=type;
        
        fishArray=[[NSMutableArray alloc] init];
        switch (fishSchoolType) {
            case kFishSchoolType_10:
            case kFishSchoolType_11:
            case kFishSchoolType_12:
                break;
            default:
                //鱼群的游动控制
                if (GAME_IS_FOR_GAMECENTER) {
                    if ([GameSceneForGameCenter shardScene].isHost) {
                        [self schedule:@selector(turnFish) interval:arc4random()%3+3];
                    }
                }else{
                    [self schedule:@selector(turnFish) interval:arc4random()%3+3];
                }
                break;
        }
        
        
    }
    
    return self;
}
-(void)turnFish
{
    
//    NSLog(@"鱼群变向!");
    [self unschedule:_cmd];
    
    float angle=arc4random()%45;
    int way=arc4random()%2;
    //判断顺时针还是逆时针
    if (way==0) {
        angle=-angle;
    }
    //使用时间为旋转角度除以20
    int time=abs(angle)/20;
    //每只鱼进行旋转
    for (UFish *fish in fishArray) {
        if (fish.state==kFishStateDeath) {
            continue;
        }
        [fish fishMoveAndRotationControl:angle];
    }
    //下次改变方向的时间
    int temTime=arc4random()%2+2+time;
    [self schedule:@selector(turnFish) interval:temTime];
}

-(void)addFish:(UFish*)fish
{
    [fishArray addObject:fish];
    [fish setFishSchool:self];
}
-(void)removeFish:(UFish*)fish
{
    [fishArray removeObject:fish];
}
-(void)initFishSchool
{
    switch (fishSchoolType) {
        case kFishSchoolType_1:
            
//            UFish *fish = [[UFish alloc] init:type speed:speed angle:angle state:0 fishPoint:point scene:self];
            
            
            break;
            
        default:
            break;
    }
    
    
}

-(void)createFish:(int)type fishSpeed:(float)speed fishAngle:(float)angle fishPoint:(CGPoint)point fishTag:(int)tag playerID:(kPlayerID)pid
{
    NSLog(@"createFish");
//    UFish *fish = [[UFish alloc] init:type speed:speed angle:angle state:0 fishPoint:point scene:self];
//    fish.fishID=tag;
//    [self addChild:fish z:10 tag:tag];
//    [fishArray addObject:fish];
//    [self sendCreateFish:fish];
    
}
-(void)dealloc
{
//    NSLog(@"鱼群被清除");
    [fishArray release];
    fishArray=nil;
    [super dealloc];
}
@end
