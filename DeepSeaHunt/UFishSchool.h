//
//  UFishSchool.h
//  DeepSeaHunt
//
//  Created by Unity on 12-9-3.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameDefine.h"
#import "UFish.h"

@interface UFishSchool : CCNode
{
    kFishSchoolType fishSchoolType;                     //鱼群的类型
    int fishNum;                                        //鱼群鱼的数量
    
    NSMutableArray *fishArray;                          //鱼群
    
    
} 
@property (assign)  NSMutableArray *fishArray;
@property (assign)  kFishSchoolType fishSchoolType;

-(id)init:(kFishSchoolType)type;
-(void)addFish:(UFish*)fish;
-(void)removeFish:(UFish*)fish;
@end
