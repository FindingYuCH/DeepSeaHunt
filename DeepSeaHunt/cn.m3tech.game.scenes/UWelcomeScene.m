//
//  UWelcomeScene.m
//  DeepSeaHunt
//
//  Created by Unity on 12-10-18.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "UWelcomeScene.h"
@interface UWelcomeScene()<BaiduMobAdInterstitialDelegate>
@end

@implementation UWelcomeScene

+ (id)scene
{
	CCScene *scene = [CCScene node];
    UWelcomeScene *layer = [UWelcomeScene node];
    [scene addChild:layer];
	return scene;
}
-(id)init
{
    if (self=[super init]) {
        
        
        GAME_SCENE_SIZE = [[CCDirector sharedDirector] winSize];
        
        //背景
        CCSprite *backGound;
        if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
            backGound=[CCSprite spriteWithFile:@"welcome_background-iphone5.png"];
        }else{
            backGound=[CCSprite spriteWithFile:@"welcome_background.png"];
        }
        backGound.anchorPoint=CGPointZero;
        [self addChild:backGound z:-1];
        
        //标题
        CCSprite *title=[CCSprite spriteWithFile:@"title.png"];
        title.position=ccp(GAME_SCENE_SIZE.width/2,GAME_SCENE_SIZE.height*4/5);
        [self addChild:title z:1];

        
        //按钮框
        CCSprite *buttonBack=[CCSprite spriteWithFile:@"button_back.png"];
        CCSprite *buttonBack1=[CCSprite spriteWithFile:@"button_back_1.png"];
        CCSprite *buttonBack2=[CCSprite spriteWithFile:@"button_back_2.png"];
        
        
        //按钮
        CCMenuItem *startGameItem=[CCMenuItemImage itemWithNormalImage:@"button_start.png" selectedImage:@"button_start_.png" target:self selector:@selector(startGame)];
        CCMenuItem *gameSettingItem=[CCMenuItemImage itemWithNormalImage:@"button_setting.png" selectedImage:@"button_setting_.png" target:self selector:@selector(gameSetting)];
        CCMenuItem *gameCenterModeItem=[CCMenuItemImage itemWithNormalImage:@"button_more.png" selectedImage:@"button_more_.png" target:self selector:@selector(gameCenterMode)]; 
        CCMenuItem *gameHelpItem=[CCMenuItemImage itemWithNormalImage:@"button_help.png" selectedImage:@"button_help_.png" target:self selector:@selector(gameHelp)];
        CCMenuItem *gameAboutItem=[CCMenuItemImage itemWithNormalImage:@"button_about.png" selectedImage:@"button_about_.png" target:self selector:@selector(gameAbout)];
        
        
        
        if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
            buttonBack.anchorPoint=ccp(1.0f,0);
            buttonBack.position=ccp(GAME_SCENE_SIZE.width,0);
            buttonBack1.position=ccp(284,167);
            buttonBack2.position=ccp(290,95);
            
            
            //按钮位置
            startGameItem.anchorPoint=ccp(0.5f,0.5f);
            startGameItem.position=ccp(284,163);
            
            
            gameCenterModeItem.anchorPoint=ccp(0.5f,0.5f);
            gameCenterModeItem.position=ccp(287,92);
            
            
            gameAboutItem.position=ccp(542,104);
            gameHelpItem.position=ccp(542,67);
            gameSettingItem.position=ccp(542,32);
            
        }else if (isPad) {
            
            buttonBack.anchorPoint=ccp(1.0f,0);
            buttonBack.position=ccp(GAME_SCENE_SIZE.width,0);
            buttonBack1.position=ccp(512,384);
            buttonBack2.position=ccp(525,230);
            
            
            //按钮位置
            startGameItem.anchorPoint=ccp(0.5f,0.5f);
//            startGameItem.position=ccp(512,236);
            startGameItem.position=ccp(512,370);
            
            
            gameCenterModeItem.anchorPoint=ccp(0.5f,0.5f);
            gameCenterModeItem.position=ccp(517,222);
            
            
            gameAboutItem.position=ccp(969,218);
            gameHelpItem.position=ccp(969,140);
            gameSettingItem.position=ccp(969,65);
            
            
        }else{
            buttonBack.anchorPoint=ccp(1.0f,0);
            buttonBack.position=ccp(GAME_SCENE_SIZE.width,0);
            buttonBack1.position=ccp(240,167);
            buttonBack2.position=ccp(246,95);
            
            
            //按钮位置
            startGameItem.anchorPoint=ccp(0.5f,0.5f);
            startGameItem.position=ccp(240,163);
            
            
            gameCenterModeItem.anchorPoint=ccp(0.5f,0.5f);
            gameCenterModeItem.position=ccp(243,92);
            
            
            gameAboutItem.position=ccp(454,104);
            gameHelpItem.position=ccp(454,67);
            gameSettingItem.position=ccp(454,32);
        }
        
        [self addChild:buttonBack z:2];
        [self addChild:buttonBack1 z:2];
        [self addChild:buttonBack2 z:2];
        
        CCMenu *temMenu=[CCMenu menuWithItems:startGameItem,gameCenterModeItem,gameSettingItem,gameHelpItem,gameAboutItem, nil];
        temMenu.position=CGPointZero;
        
        [self addChild:temMenu z:1];
        
        [self initSound];
        [self playUIMusic];
        
        
        //气泡
		m_spbnBubbles = [CCSpriteBatchNode batchNodeWithFile:@"bubble.png"];
		for (int i = 0; i < 20; i ++) {
			Bubble *bubble = [Bubble bubbleWithFile:@"bubble.png"];
			bubble.visible = NO;
			[m_spbnBubbles addChild:bubble]; 
		}
        [self addChild:m_spbnBubbles z:0];
		
		[self schedule:@selector(update) interval:0.05];
        
    }
    //self.isInVideo = @"1";
    //self.customWidth = @"300";
    //self.customHeight = @"300";
    //[self loadInterAd];
    return self;
}
-(void)readMusicData
{
    RecordForMusicSetting *record=(RecordForMusicSetting*)[[USave readGameData:kRecordTypeForMusicSetting] bytes];
    
    if (record==nil) {
        return;
    }
    
    GAME_IS_PLAY_EFFECT=record->isEffectPlay;
    GAME_IS_PLAY_SOUND=record->isBackMusicPlay;    
}
-(void)startGame
{
//    gameModeType=kModeTypeForOne;
    GAME_IS_FOR_GAMECENTER=NO;
    CCScene *scene=[UGameSceneChoice scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeBL transitionWithDuration:1 scene:scene]];
}
-(void)gameCenterMode
{
//    gameModeType=kModeTypeForGameCenter;
    GAME_IS_FOR_GAMECENTER=YES;
    CCScene *scene=[GameSceneForGameCenter scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeBL transitionWithDuration:1 scene:scene]];
}

-(void)gameHelp
{
    CCScene *scene=[UHelpScene scene];
    [[CCDirector sharedDirector] pushScene:[CCTransitionFadeBL transitionWithDuration:1 scene:scene]];
}
-(void)gameAbout
{
    CCScene *scene=[UAboutScene scene];
    [[CCDirector sharedDirector] pushScene:[CCTransitionFadeBL transitionWithDuration:1 scene:scene]];
}
-(void)gameSetting
{
    CCScene *scene=[USettigScene scene];
    [[CCDirector sharedDirector] pushScene:[CCTransitionFadeBL transitionWithDuration:1 scene:scene]];
}

-(void)initSound
{
    
    GAME_IS_PLAY_SOUND =YES;
    GAME_IS_PLAY_EFFECT=YES;
    
    [self readMusicData];
    
    //加载音乐
    
    GAME_AUDIO = [SimpleAudioEngine sharedEngine];
    [GAME_AUDIO preloadBackgroundMusic:kSoundTypeForBackMusic];
    [GAME_AUDIO preloadBackgroundMusic:kSoundTypeForUIMusic];
    [GAME_AUDIO preloadEffect:kSoundTypeForConnonFire];
    GAME_AUDIO.backgroundMusicVolume = 5;
    //GAME_AUDIO.effectsVolume = 0.25;
}

-(void)playUIMusic
{
    if (GAME_IS_PLAY_SOUND) {
        [GAME_AUDIO playBackgroundMusic:kSoundTypeForUIMusic];
    }
}
- (void)update
{
    
	CCArray* bubbles = [m_spbnBubbles children];	
	int count = 0;
	for (int i = 0; i < 20; i ++) {
		CCNode* node = [bubbles objectAtIndex:i];
		NSAssert([node isKindOfClass:[Bubble class]],@"not a bubble!");
		Bubble *bubble = (Bubble *)node;
		if (bubble.visible == YES) {
			count ++;
		}
	}
	
	if (count < 15) {
		for (int i = 0; i < 20; i ++) {
			CCNode* node = [bubbles objectAtIndex:i];
			NSAssert([node isKindOfClass:[Bubble class]],@"not a bubble!");
			Bubble *bubble = (Bubble *)node;
			if (bubble.visible == NO) {
				bubble.visible = YES;
				[bubble setActions];
				return;
			}
		}
	}
	
}

-(BOOL) enableLocation
{
    //启用location会有一次alert提示,请根据系统进行相关配置
    return YES;
}

- (IBAction)loadInterAd {
    self.adInterstitial = [[BaiduMobAdInterstitial alloc] init];
    self.adInterstitial.delegate = self;
    //把在mssp.baidu.com上创建后获得的代码位id写到这里
    self.adInterstitial.AdUnitTag = @"2058554";
    if ([self.isInVideo isEqualToString:@"1"]) {
        // 视频前贴片5s，倒计时
        self.adInterstitial.interstitialType = BaiduMobAdViewTypeInterstitialBeforeVideo;
        
    } else {
        //视频暂停贴片
        self.adInterstitial.interstitialType = BaiduMobAdViewTypeInterstitialPauseVideo;
    }
    NSString *w = self.customWidth;
    NSString *h = self.customHeight;
    //NSInteger screenW = [[CCDirector sharedDirector] view].frame.size.width;
    //NSInteger screenH = [[CCDirector sharedDirector] view].frame.size.height;
    
    [self.adInterstitial loadUsingSize:CGRectMake(0,0, [w floatValue], [h floatValue])];
}

- (NSString *)publisherId {
    return @"ccb60059"; //your_own_app_id
}

/**
 *  广告预加载成功
 */
- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)interstitial
{
    NSLog(@"interstitialSuccessToLoadAd");
    NSString *w = self.customWidth;
    NSString *h = self.customHeight;
    if (!self.customInterView) {
        NSInteger screenW = [[CCDirector sharedDirector] view].frame.size.width;
        NSInteger screenH = [[CCDirector sharedDirector] view].frame.size.height;
        UIView *customInterView = [[[UIView alloc]initWithFrame:CGRectMake((screenW-[w floatValue])/2, (screenH-[h floatValue])/2, [w floatValue], [h floatValue])]autorelease];
        self.customInterView = customInterView;
    }
    //[self.view addSubview:self.customInterView];
    [[[CCDirector sharedDirector] view] addSubview:self.customInterView];
    [interstitial presentFromView:self.customInterView];
}

/**
 *  广告预加载失败
 */
- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)interstitial
{
    NSLog(@"interstitialFailToLoadAd");
}

/**
 *  广告即将展示
 */
- (void)interstitialWillPresentScreen:(BaiduMobAdInterstitial *)interstitial
{
    NSLog(@"interstitialWillPresentScreen");
}

/**
 *  广告展示成功
 */
- (void)interstitialSuccessPresentScreen:(BaiduMobAdInterstitial *)interstitial
{
    NSLog(@"interstitialSuccessPresentScreen");
}

/**
 *  广告展示失败
 */
- (void)interstitialFailPresentScreen:(BaiduMobAdInterstitial *)interstitial withError:(BaiduMobFailReason) reason
{
    NSLog(@"interstitialFailPresentScreen, withError: %d",reason);
}

/**
 *  广告展示结束
 */
- (void)interstitialDidDismissScreen:(BaiduMobAdInterstitial *)interstitial
{
    NSLog(@"interstitialDidDismissScreen");
    [self.customInterView removeFromSuperview];
}

@end
