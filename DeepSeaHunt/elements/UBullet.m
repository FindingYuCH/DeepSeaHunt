//
//  UBullet.m
//  DeepSeaHunt
//
//  Created by Unity on 12-8-30.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "UBullet.h"

@implementation UBullet
@synthesize playerID;
@synthesize level;

-(id)init:(NSString*)file player:(kPlayerID)pid level:(kLevel)lv point:(CGPoint)pos
{
    if (self=[super initWithFile:file]) {
        playerID=pid;
        level=lv;
        bulletEffect=[[ParticleEffectSelfMade alloc] initBulletParticle:20];
        bulletEffect.texture = [[CCTextureCache sharedTextureCache] addImage: @"bb.png"];
        
        bulletEffect.position=ccp(self.contentSize.width/2,0);
        [self addChild:bulletEffect z:-1];
        self.position=pos;
        
    }
    
    return self;
}
-(id)init:(NSString*)file level:(kLevel)lv point:(CGPoint)pos
{
    if (self=[super initWithFile:file]) {
        level=lv;
        bulletEffect=[[ParticleEffectSelfMade alloc] initBulletParticle:20];
        bulletEffect.texture = [[CCTextureCache sharedTextureCache] addImage: @"bb.png"];
        
        bulletEffect.position=ccp(self.contentSize.width/2,0);
        [self addChild:bulletEffect z:-1];
        self.position=pos;
    }
    
    return self;
}
-(void)setBulletRation:(float)angle
{
    self.rotation=angle;
//    bulletEffect.angle=self.rotation;
    bulletEffect.rotation=-self.rotation;
}
-(void)dealloc
{
//    NSLog(@"子弹被清除");
    [bulletEffect release];
    [super dealloc];
}
@end
