//
//  UNet.h
//  DeepSeaHunt
//
//  Created by Unity on 12-8-31.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "cocos2d.h"
#import "GameDefine.h"



@interface UNet : CCSprite
{
    kPlayerID playerID;
    kLevel  netLevel;
    
    float nowScale;
    CGSize netSize;
}

@property (assign) kPlayerID playerID;
@property (assign) kLevel  netLevel;
@property (assign) CGSize netSize;

-(id)init:(int)level plaerID:(kPlayerID)pid point:(CGPoint)pos;

@end
