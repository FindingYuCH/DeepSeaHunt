//
//  TestMainScene.m
//  DeepSeaHunt
//
//  Created by Unity on 12-8-17.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "TestMainScene.h"
#import "GameSceneForGameCenter.h"

@implementation TestMainScene

+ (id)scene
{
	CCScene *scene = [CCScene node];
    TestMainScene *layer = [TestMainScene node];
    [scene addChild:layer];
	return scene;
}

- (id)init
{
	if ((self = [super init])) {
        
        
        GAME_SCENE_SIZE = [[CCDirector sharedDirector] winSize];
		
        GAME_IS_PLAY_SOUND = YES;
        CGSize size=[[CCDirector sharedDirector] winSize];
        
        CCSprite *back=[CCSprite spriteWithFile:@"menumain_bg.png"];
        back.anchorPoint=CGPointZero;
        [self addChild:back];
        
        CCMenuItem *m_menuItemStart = [CCMenuItemImage itemWithNormalImage:@"menumain_btn_start.png" selectedImage:@"menumain_btn_start_.png" target: self selector:@selector(onGameStart)];
		m_menuItemStart.position = ccp(0, size.height/2);
        
        CCMenu *menu = [CCMenu menuWithItems:m_menuItemStart, nil];
		menu.position = ccp(size.width/2, - size.height / 4);
		[self addChild:menu z:99 tag:2];
        
        
    }
    return self;
}

-(void)onGameStart
{
//    g_gc=[[GameCenter alloc] init];
    CCScene *scene=[GameSceneForGameCenter scene];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeBL transitionWithDuration:1 scene:scene]];
}
@end
