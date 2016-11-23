//
//  ParticleEffectSelfMade.m
//  study
//
//  Created by Unity on 12-11-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ParticleEffectSelfMade.h"

@implementation ParticleEffectSelfMade
-(id) init:(int)a
{
	return [self initWithTotalParticles:200];
}
-(id)initBulletParticle:(NSUInteger) p
{
    if( (self=[super initWithTotalParticles:p]) ) {
        
		duration=-1.0f;
        //        self.autoRemoveOnFinish = YES;
		// Gravity Mode
		self.emitterMode = kCCParticleModeGravity;
        
		// Gravity Mode: gravity
        self.startSpin=0;
        self.startSpinVar=360;
        
        self.endSpin=0;
        self.endSpinVar=360;
        
		// Gravity Mode: gravity
		self.gravity = ccp(0,0);
        
		// Gravity Mode: speed of particles
        if (isPad) {
            self.speed = 180;
            self.speedVar = 20;
        }else{
            self.speed = 100;
            self.speedVar = 10;
        }
        
        
        
		// Gravity Mode: radial
		self.radialAccel = 10;
		self.radialAccelVar = 0;
        
		// Gravity Mode: tagential
		self.tangentialAccel = 5;
		self.tangentialAccelVar = 0;
        
		// angle
		angle = 0;
		angleVar = 360;
    
		// emitter position
		posVar = CGPointZero;
        
		// life of particles
		life = 0;
        
		// size, in pixels
		
        if (isPad) {
            startSize = 20.0f;
            startSizeVar = 10.0f;
        }else{
            startSize = 10.0f;
            startSizeVar = 5.0f;
        }
        
        lifeVar = 0.5;
        
        //		endSize = kCCParticleStartSizeEqualToEndSize;
        endSize=5.0f;
		// emits per second
		emissionRate = totalParticles/life;
        
        startColor.r = 1.0f;
        startColor.g = 1.0f;
        startColor.b = 1.0f;
        startColor.a = 0.5f;
        startColorVar.r = 0.0f;
        startColorVar.g = 0.0f;
        startColorVar.b = 0.0f;
        startColorVar.a = 0.5f;
        
        endColor.r = 1.0f;
        endColor.g = 1.0f;
        endColor.b = 1.0f;
        endColor.a =1.0f;
        endColorVar.r = 0.0f;
        endColorVar.g = 0.2f;
        endColorVar.b = 0.0f;
        endColorVar.a = 0.2f;

        
		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"bb.png"];
        
		// additive
		self.blendAdditive = YES;
	}
    
	return self;
}
-(id)initGoldParticle:(NSUInteger) p  type:(NSUInteger) type
{
    if( (self=[super initWithTotalParticles:p]) ) {
        
		// duration
        //		duration = kCCParticleDurationInfinity;
        duration=-1.0f;
//        self.autoRemoveOnFinish = YES;
		// Gravity Mode
		self.emitterMode = kCCParticleModeGravity;
        
		// Gravity Mode: gravity
        self.startSpin=0;
        self.startSpinVar=360;
        
        self.endSpin=0;
        self.endSpinVar=360;
        
		// Gravity Mode: gravity
		self.gravity = ccp(0,0);
        
		// Gravity Mode: speed of particles
        if (isPad) {
            self.speed = 200;
            self.speedVar = 20;
        }else{
            self.speed = 100;
            self.speedVar = 10;
        }
        
        

		// Gravity Mode: radial
		self.radialAccel = 10;
		self.radialAccelVar = 0;
        
		// Gravity Mode: tagential
		self.tangentialAccel = 5;
		self.tangentialAccelVar = 0;

		// angle
		angle = 0;
		angleVar = 360;
        
		// emitter position
		posVar = CGPointZero;
        
		// life of particles
		life = 0;
        
		// size, in pixels
		
        if (isPad) {
            startSize = 30.0f;
            startSizeVar = 10.0f;
        }else{
            startSize = 20.0f;
            startSizeVar = 5.0f;
        }
        
        lifeVar = 0.6;

        //		endSize = kCCParticleStartSizeEqualToEndSize;
        endSize=1.0f;
		// emits per second
		emissionRate = totalParticles/life;
        
        startColor.r = 1.0f;
        startColor.g = 1.0f;
        startColor.b = 1.0f;
        startColor.a = 0.5f;
        startColorVar.r = 0.0f;
        startColorVar.g = 0.0f;
        startColorVar.b = 0.0f;
        startColorVar.a = 0.5f;
        
        endColor.r = 1.0f;
        endColor.g = 1.0f;
        endColor.b = 1.0f;
        endColor.a =1.0f;
        endColorVar.r = 0.0f;
        endColorVar.g = 0.2f;
        endColorVar.b = 0.0f;
        endColorVar.a = 0.2f;
        
//        if (type==0) {
//            startColor.r = 1.0f;
//            startColor.g = 1.0f;
//            startColor.b = 1.0f;
//            startColor.a = 0.5f;
//            startColorVar.r = 0.0f;
//            startColorVar.g = 0.0f;
//            startColorVar.b = 0.0f;
//            startColorVar.a = 0.5f;
//            
//            endColor.r = 1.0f;
//            endColor.g = 1.0f;
//            endColor.b = 1.0f;
//            endColor.a =1.0f;
//            endColorVar.r = 0.0f;
//            endColorVar.g = 0.2f;
//            endColorVar.b = 0.0f;
//            endColorVar.a = 0.2f;
//        }else{
//            startColor.r = 0.5f;
//            startColor.g = 0.3f;
//            startColor.b = 0.0f;
//            startColor.a = 0.5f;
//            startColorVar.r = 0.0f;
//            startColorVar.g = 0.0f;
//            startColorVar.b = 0.0f;
//            startColorVar.a = 0.5f;
//            
//            endColor.r = 0.5f;
//            endColor.g = 0.3f;
//            endColor.b = 0.0f;
//            endColor.a =1.0f;
//            endColorVar.r = 0.0f;
//            endColorVar.g = 0.2f;
//            endColorVar.b = 0.0f;
//            endColorVar.a = 0.2f;
//        }
        
        
        
		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"bb.png"];
        
		// additive
		self.blendAdditive = YES;
	}
    
	return self;
}
-(id)init:(int)a type:(int)type
{
    switch (type) {
        case 0:
        case 1:
        case 2:
            return [self initWithTotalParticles3:50 type:type];
        case 3:
        case 4:
            return [self initWithTotalParticles3:100 type:type];
        case 5:
        case 6:
        case 7:
            return [self initWithTotalParticles3:150 type:type];
        default:
            break;
    }
    return [self initWithTotalParticles3:200 type:type];
}
-(id) initWithTotalParticles3:(NSUInteger) p type:(int)type
{
	if( (self=[super initWithTotalParticles:p]) ) {
        
		// duration
        //		duration = kCCParticleDurationInfinity;
        duration=0.3f;
        self.autoRemoveOnFinish = YES;
		// Gravity Mode
		self.emitterMode = kCCParticleModeGravity;
        
		// Gravity Mode: gravity
        self.startSpin=0;
        self.startSpinVar=360;
        
        self.endSpin=180;
        self.endSpinVar=180;
        
		// Gravity Mode: gravity
		self.gravity = ccp(0,0);
        
		// Gravity Mode: speed of particles
        if (isPad) {
            self.speed = 300;
            self.speedVar = 20;
        }else{
            self.speed = 191;
            self.speedVar = 10;
        }
        
        
		
        
		// Gravity Mode: radial
		self.radialAccel = 10;
		self.radialAccelVar = 0;
        
		// Gravity Mode: tagential
		self.tangentialAccel = 5;
		self.tangentialAccelVar = 0;
        
        
        
		// angle
		angle = 0;
		angleVar = 360;
        
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		posVar = CGPointZero;
        
		// life of particles
		life = 0;
		        
		// size, in pixels
		
        
        switch (type) {
            case 0:
            case 1:
            case 2:
                startSize = 30.0f;
                startSizeVar = 10.0f;
                lifeVar = 0.2;
                break;
            case 3:
            case 4:
                startSize = 35.0f;
                startSizeVar = 10.0f;
                lifeVar = 0.3;
                break;
            case 5:
            case 6:
            case 7:
                startSize = 40.0f;
                startSizeVar = 10.0f;
                lifeVar = 0.4;
                break;
                
            default:
                break;
        }
        
        
        //		endSize = kCCParticleStartSizeEqualToEndSize;
        endSize=1.0f;
		// emits per second
		emissionRate = totalParticles/life;
        
        startColor.r = 1.0f;
        startColor.g = 1.0f;
        startColor.b = 1.0f;
        startColor.a = 0.5f;
        startColorVar.r = 0.0f;
        startColorVar.g = 0.0f;
        startColorVar.b = 0.0f;
        startColorVar.a = 0.5f;
        
        endColor.r = 1.0f;
        endColor.g = 1.0f;
        endColor.b = 1.0f;
        endColor.a =1.0f;
        endColorVar.r = 0.0f;
        endColorVar.g = 0.2f;
        endColorVar.b = 0.0f;
        endColorVar.a = 0.2f;
        
//        startColor.r = 1.0f;
//		startColor.g = 0.5f;
//		startColor.b = 1.0f;
//		startColor.a = 0.0f;
//		startColorVar.r = 1.0f;
//		startColorVar.g = 0.12f;
//		startColorVar.b = 0.66f;
//		startColorVar.a = 0.8f;
//        
//        endColor.r = 0.6f;
//		endColor.g = 0.5f;
//		endColor.b = 1.0f;
//		endColor.a =1.0f;
//		endColorVar.r = 0.0f;
//		endColorVar.g = 0.7f;
//		endColorVar.b = 0.0f;
//		endColorVar.a = 0.7f;

        
		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"bb.png"];
        
		// additive
		self.blendAdditive = YES;
	}
    
	return self;
}
-(id)initStoreUpWithTotalParticles:(NSUInteger)P
{
    if( (self=[super initWithTotalParticles:P]) ) {
        
		// duration
        //		duration = kCCParticleDurationInfinity;
        duration=-1.0f;
        self.autoRemoveOnFinish = YES;
		// Gravity Mode
		self.emitterMode = kCCParticleModeRadius;
        
        
        self.startRadius=100;
        self.startRadiusVar=50;
        
        self.endRadius = 0;
        self.endRadiusVar = 0;
        self.rotatePerSecond =0;
        self.rotatePerSecondVar = 0;
        
		// angle
		angle = 0;
		angleVar = 360;
        
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		posVar = CGPointZero;
        
		// life of particles
		life = 0.05;
		lifeVar = 0.5;
        
		// size, in pixels
		startSize = 0.0f;
		startSizeVar = 0.0f;
        //		endSize = kCCParticleStartSizeEqualToEndSize;
        endSize=24.0f;
        endSizeVar=9;
		// emits per second
		emissionRate = totalParticles/life;
        
		// color of particles
//		startColor.r = 0.4f;
//		startColor.g = 0.1f;
//		startColor.b = 1.0f;
//		startColor.a = 0.0f;
//		startColorVar.r = 0.0f;
//		startColorVar.g = 0.0f;
//		startColorVar.b = 0.17f;
//		startColorVar.a = 0.0f;
//        
//        endColor.r = 0.8f;
//		endColor.g = 0.14f;
//		endColor.b = 1.0f;
//		endColor.a = 0.0f;
//		endColorVar.r = 0.0f;
//		endColorVar.g = 0.0f;
//		endColorVar.b = 0.2f;
//		endColorVar.a = 1.0f;
        
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
        

        
		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
        
		// additive
		self.blendAdditive = YES;
	}
    
	return self;
}

-(id) initWithTotalParticles:(NSUInteger) p angle:(int)a
{
	if( (self=[super initWithTotalParticles:p]) ) {
        
		// duration
//		duration = kCCParticleDurationInfinity;
        duration=4.0f;
        self.autoRemoveOnFinish = YES;
		// Gravity Mode
		self.emitterMode = kCCParticleModeGravity;
        
		// Gravity Mode: gravity
//		self.gravity = ccp(200,200);
        int g=300;

        float x=g*sin(a*M_PI/180);
        float y=abs(g*cos(a*M_PI/180));

		// Gravity Mode: gravity
		self.gravity = ccp(x,y);
        
		// Gravity Mode: speed of particles
		self.speed = 20;
		self.speedVar = 0;
        
		// Gravity Mode: radial
		self.radialAccel = 1;
		self.radialAccelVar = 0;
        
		// Gravity Mode: tagential
		self.tangentialAccel = 0;
		self.tangentialAccelVar = 0;
        
		// angle
		angle = 0;
		angleVar = 0;
        
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
