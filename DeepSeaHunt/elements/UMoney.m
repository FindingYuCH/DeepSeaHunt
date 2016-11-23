//
//  UMoney.m
//  DeepSeaHunt
//
//  Created by Unity on 12-10-15.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "UMoney.h"
#import "UGameScene.h"
#import "GameSceneForGameCenter.h"
@implementation UMoney
@synthesize type;


-(id)init:(int)n point:(CGPoint)point playerID:(kPlayerID)pid
{
    if (self=[super init]) {
        playerID=pid;
        self.position=point;
        CCSprite *sp;
        if (GAME_IS_FOR_GAMECENTER) {
            sp=[GameSceneForGameCenter shardScene].moneyForGold;
        }else{
            sp=[UGameScene sharedScene].moneyForGold;
        }
        CCAnimation *animation=[CCAnimation animation];
        [animation setDelayPerUnit:0.05f];
        
        for (int i=0; i<8; i++) {
            [animation addSpriteFrameWithTexture:sp.texture rect:CGRectMake(i*sp.contentSize.width/8, n*sp.contentSize.height/2, sp.contentSize.width/8, sp.contentSize.height/2)];
        }
        
        id action = [CCAnimate actionWithAnimation: animation];
        
        [self runAction:[CCRepeatForever actionWithAction:action]];
        
        goldEffect=[[ParticleEffectSelfMade alloc] initGoldParticle:20 type:n];
        goldEffect.texture = [[CCTextureCache sharedTextureCache] addImage: @"bb.png"];
        goldEffect.position=ccp(sp.contentSize.width/16,sp.contentSize.height/4);
        [self addChild:goldEffect z:-1];
//        [self addChild:sp];
    }
    return self;
}
-(void)dealloc
{
//    NSLog(@"金币被清除");
    [goldEffect release];
    [super dealloc];
}
@end
