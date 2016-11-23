//
//  USettigScene.m
//  DeepSeaHunt
//
//  Created by Unity on 12-10-19.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "USettigScene.h"
#import "CCDirector_.h"
@implementation USettigScene


+ (id)scene{
    CCScene *scene = [CCScene node];
    USettigScene *layer = [USettigScene node];
    [scene addChild:layer];
	return scene;
}

-(id)init
{
    if (self=[super init]) {
        
        CCSprite *temBackGround;
        if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
            temBackGround=[CCSprite spriteWithFile:@"universal_background-iphone5.png"];
        }else{
            temBackGround=[CCSprite spriteWithFile:@"universal_background.png"];
        }
        temBackGround.anchorPoint=CGPointZero;
        [self addChild:temBackGround z:-1];
        
        CCSprite *temRim=[CCSprite spriteWithFile:@"rim.png"];
        temRim.position=ccp(GAME_SCENE_SIZE.width/2,GAME_SCENE_SIZE.height*0.55);
        
        CCSprite *temTitle=[CCSprite spriteWithFile:@"setting_title.png"];
        temTitle.position=ccp(temRim.contentSize.width/5,temRim.contentSize.height*6.5/8);
        [temRim addChild:temTitle z:1];
        
        
        
        CCSprite *temWord=[CCSprite spriteWithFile:@"setting_back_word.png"];
        temWord.position=ccp(GAME_SCENE_SIZE.width*0.40,GAME_SCENE_SIZE.height/2);
        
        
        
        CCSprite *backMusicControl=[CCSprite spriteWithFile:@"setting_choice_flag.png"];
        CCSprite *effectMusicControl=[CCSprite spriteWithFile:@"setting_choice_flag.png"];
        
        [self addChild:temWord z:1];
        [self addChild:temRim z:0];
        
        
        CCMenuItem *temBackMusicItem=[CCMenuItemImage itemWithNormalImage:@"setting_choice_box.png" selectedImage:nil target:self selector:@selector(turnBackMusicON_OFF)];
        CCMenuItem *temEfffectMusicItem=[CCMenuItemImage itemWithNormalImage:@"setting_choice_box.png" selectedImage:nil target:self selector:@selector(turnEffectMusicON_OFF)];
        CCMenuItem *temBackItem=[CCMenuItemImage itemWithNormalImage:@"button_return.png" selectedImage:@"button_return_.png" target:self selector:@selector(backButtonClickEvent)];
        
        if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
            temBackMusicItem.position=ccp(320,188);
            temEfffectMusicItem.position=ccp(320,130);
            temBackItem.position=ccp(404,245);
        }else if (isPad) {
            temBackMusicItem.position=ccp(600,455);
            temEfffectMusicItem.position=ccp(600,315);
            temBackItem.position=ccp(800,600);
        }else {
            temBackMusicItem.position=ccp(270,188);
            temEfffectMusicItem.position=ccp(270,130);
            temBackItem.position=ccp(360,245);
        }
        
        
        
        CCMenu *temMenu=[CCMenu menuWithItems:temBackItem,temBackMusicItem,temEfffectMusicItem, nil];
        temMenu.position=CGPointZero;
        [self addChild:temMenu z:0];
        
        
        backMusicControl.position=temBackMusicItem.position;
        effectMusicControl.position=temEfffectMusicItem.position;
        
        [self addChild:backMusicControl z:1 tag:1];
        [self addChild:effectMusicControl z:1 tag:2];
        
        if (!GAME_IS_PLAY_SOUND) {
            backMusicControl.visible=false;
        }
        if (!GAME_IS_PLAY_EFFECT) {
            effectMusicControl.visible=false;
        }
    }
    return self;
}

-(void)backButtonClickEvent
{
    //记录音乐设定信息
    [self saveMusicData];
    
    [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFadeBL class] duration:1];
}
-(void)saveMusicData
{
    RecordForMusicSetting record;
    record.isBackMusicPlay=GAME_IS_PLAY_SOUND;
    record.isEffectPlay=GAME_IS_PLAY_EFFECT;
    
    NSData *data=[NSData dataWithBytes:&record length:sizeof(record)];
    
    [USave saveGameData:data toFile:kRecordTypeForMusicSetting];
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
-(void)turnBackMusicON_OFF
{
    if (GAME_IS_PLAY_SOUND) {
        GAME_IS_PLAY_SOUND=NO;
        CCSprite *backMusicControl=(CCSprite *)[self getChildByTag:1];
        backMusicControl.visible=false;
        
        [GAME_AUDIO pauseBackgroundMusic];
    }else {
        GAME_IS_PLAY_SOUND=YES;
        CCSprite *backMusicControl=(CCSprite *)[self getChildByTag:1];
        backMusicControl.visible=true;
        [GAME_AUDIO playBackgroundMusic:kSoundTypeForUIMusic];
    }
}
-(void)turnEffectMusicON_OFF
{
    if (GAME_IS_PLAY_EFFECT) {
        GAME_IS_PLAY_EFFECT=NO;
        CCSprite *effectMusicControl=(CCSprite *)[self getChildByTag:2];
        effectMusicControl.visible=false;
    }else {
        GAME_IS_PLAY_EFFECT=YES;
        CCSprite *effectMusicControl=(CCSprite *)[self getChildByTag:2];
        effectMusicControl.visible=true;
    }
}
@end
