//
//  UAboutScene.m
//  DeepSeaHunt
//
//  Created by Unity on 12-12-12.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "UAboutScene.h"
#import "CCDirector_.h"

@implementation UAboutScene
+ (id)scene{
    CCScene *scene = [CCScene node];
    UAboutScene *layer = [UAboutScene node];
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
        [self addChild:temRim z:0];
        
        CCSprite *temAboutTitle=[CCSprite spriteWithFile:@"about_title.png"];
        temAboutTitle.position=ccp(temRim.contentSize.width*0.3,temRim.contentSize.height*6.5/8);
        [temRim addChild:temAboutTitle z:1];
        
        
        CCMenuItem *temBackItem=[CCMenuItemImage itemWithNormalImage:@"button_return.png" selectedImage:@"button_return_.png" target:self selector:@selector(backButtonClickEvent)];
        
        if (GAME_SCENE_SIZE.width==568&&GAME_SCENE_SIZE.height==320) {
            temBackItem.position=ccp(404,245);
        }else if (isPad) {
            temBackItem.position=ccp(800,600);
        }else {
            temBackItem.position=ccp(360,245);
        }
        
        
        CCMenu *temMenu=[CCMenu menuWithItems:temBackItem, nil];
        temMenu.position=CGPointZero;
        [self addChild:temMenu z:0];
        
       CCSprite *wordImage=[CCSprite spriteWithFile:@"about_word.png"];
        //        wordImageSize=wordImage.contentSize;
        NSLog(@"宽=%f,高=%f",wordImage.contentSize.width,wordImage.contentSize.height);
        //        [wordImage setTextureRect:CGRectMake(0, 0, 100, 100)];
        wordImage.anchorPoint=CGPointZero;
        wordImage.position=ccp(temRim.contentSize.width/5,temRim.contentSize.height/6);
        [temRim addChild:wordImage z:1 tag:1];

        
    }
    return self;
}


-(void)backButtonClickEvent
{
    [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFadeBL class] duration:1];
}
@end
