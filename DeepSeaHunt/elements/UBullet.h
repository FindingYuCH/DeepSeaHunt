//
//  UBullet.h
//  DeepSeaHunt
//
//  Created by Unity on 12-8-30.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "cocos2d.h"
#import "GameDefine.h"
#import "ParticleEffectSelfMade.h"

@interface UBullet : CCSprite
{
    kPlayerID playerID;                 //用来区分子弹属于哪个玩家
    
    kLevel  level;                //子弹等级
    ParticleEffectSelfMade *bulletEffect;
}

@property (assign) kPlayerID playerID;
@property (assign) kLevel  level;

//-(id)init:(kPlayerID)pid level:(kLevel)lv file:(NSString*)file;
-(id)init:(NSString*)file player:(kPlayerID)pid level:(kLevel)lv point:(CGPoint)pos;
-(id)init:(NSString*)file level:(kLevel)lv point:(CGPoint)pos;
-(void)setBulletRation:(float)angle;
@end
