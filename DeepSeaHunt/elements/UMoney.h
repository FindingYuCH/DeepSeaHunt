//
//  UMoney.h
//  DeepSeaHunt
//
//  Created by Unity on 12-10-15.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "CCSprite.h"
#import "GameDefine.h"
#import "ParticleEffectSelfMade.h"

@interface UMoney : CCSprite
{
    
    kPlayerID playerID;
    int type;
    ParticleEffectSelfMade *goldEffect;
}

@property (assign) int type;

-(id)init:(int)type point:(CGPoint)point playerID:(kPlayerID)pid;
@end
