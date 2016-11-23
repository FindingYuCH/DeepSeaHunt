//
//  ULaser.m
//  DeepSeaHunt
//
//  Created by Unity on 12-11-28.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "ULaser.h"

@implementation ULaser
-(id) init:(NSUInteger)a
{
	return [self initWithTotalParticles:1000 angle:90-a];
}
-(id) init2:(NSUInteger)a
{
    int n=-a-90;
    if (n<0) {
        n+=360;
    }
	return [self initWithTotalParticles:1000 angle:n];
}
-(id) initWithTotalParticles:(NSUInteger)p angle:(NSUInteger)a
{
	if( (self=[super initWithTotalParticles:p]) ) {
        
		// duration
        //		duration = kCCParticleDurationInfinity;
        duration=4.0f;
        self.autoRemoveOnFinish = YES;
		// Gravity Mode
		self.emitterMode = kCCParticleModeGravity;
		// Gravity Mode: gravity
		self.gravity = ccp(0,0);
        
		// Gravity Mode: speed of particles
		self.speed = 500;
		self.speedVar = 0;
        
		// Gravity Mode: radial
		self.radialAccel = 13;
		self.radialAccelVar = 0;
        
		// Gravity Mode: tagential
		self.tangentialAccel = 0;
		self.tangentialAccelVar = 0;
        
		// angle
        NSLog(@"angle:%d",a);
		angle =a;
		angleVar = 0;
        //emitter angle
        
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		posVar = CGPointZero;
        
		// life of particles
		life = 3;
		lifeVar = 1;
        
		// size, in pixels
		startSize = 50.0f;
		startSizeVar = 10.0f;
        //		endSize = kCCParticleStartSizeEqualToEndSize;
        endSize=50.0f;
		// emits per second
		emissionRate = totalParticles/life;
        
		// color of particles
		startColor.r = 0.2f;
		startColor.g = 0.4f;
		startColor.b = 0.7f;
		startColor.a = 1.0f;
		startColorVar.r = 0.0f;
		startColorVar.g = 0.0f;
		startColorVar.b = 0.2f;
		startColorVar.a = 0.5f;
        
        endColor.r = 0.2f;
		endColor.g = 0.4f;
		endColor.b = 0.7f;
		endColor.a = 1.0f;
		endColorVar.r = 0.0f;
		endColorVar.g = 0.0f;
		endColorVar.b = 0.2f;
		endColorVar.a = 1.0f;
        
        
        //		endColor.r = 0.0f;
        //		endColor.g = 0.0f;
        //		endColor.b = 0.0f;
        //		endColor.a = 1.0f;
        //		endColorVar.r = 0.0f;
        //		endColorVar.g = 0.0f;
        //		endColorVar.b = 0.0f;
        //		endColorVar.a = 0.0f;
        
		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
        
		// additive
		self.blendAdditive = YES;
	}
    
	return self;
}
@end
