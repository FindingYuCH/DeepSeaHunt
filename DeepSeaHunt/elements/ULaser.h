//
//  ULaser.h
//  DeepSeaHunt
//
//  Created by Unity on 12-11-28.
//  Copyright (c) 2012年 akn. All rights reserved.
//
#import "cocos2d.h"
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
@interface ULaser : ARCH_OPTIMAL_PARTICLE_SYSTEM
{
    
}
-(id) init:(NSUInteger)angle;
-(id) init2:(NSUInteger)a;
@end
