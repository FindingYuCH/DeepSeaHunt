//
//  ParticleEffectSelfMade.h
//  study
//
//  Created by Unity on 12-11-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h> 
#import "cocos2d.h"
#import "GameDefine.h"

// 为每一个CPU架构指定最佳的粒子系统

// ARMv7, Mac or Simulator use "Quad" particle
#if defined(__ARM_NEON__) || defined(__CC_PLATFORM_MAC) || TARGET_IPHONE_SIMULATOR
#define ARCH_OPTIMAL_PARTICLE_SYSTEM CCParticleSystemQuad

// ARMv6 use "Point" particle
#elif __arm__
#define ARCH_OPTIMAL_PARTICLE_SYSTEM CCParticleSystemPoint
#else
#error(unknown architecture)
#endif

@interface ParticleEffectSelfMade : ARCH_OPTIMAL_PARTICLE_SYSTEM
{
    
}
-(id) init:(int)a;

-(id)init:(int)a type:(int)type;
-(id)initStoreUpWithTotalParticles:(NSUInteger)P;
-(id)initBulletParticle:(NSUInteger) p;
-(id)initGoldParticle:(NSUInteger) p  type:(NSUInteger) type;
@end
