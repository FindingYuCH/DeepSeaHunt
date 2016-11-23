//
//  UWelcomeScene.h
//  DeepSeaHunt
//
//  Created by Unity on 12-10-18.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "cocos2d.h"
#import "USave.h"
#import "Bubble.h"
#import "UGameScene.h"
#import "GameDefine.h"
#import "UAboutScene.h"
#import "UHelpScene.h"
#import "USettigScene.h"
#import "GameSceneForGameCenter.h"
#import "UGameSceneChoice.h"
#import "BaiduMobAdInterstitial.h"
@interface UWelcomeScene : CCLayer
{
    CCSpriteBatchNode *m_spbnBubbles;
}
+ (id)scene;
//@property (retain, nonatomic) IBOutlet UITextField *isInVideo;
//@property (retain, nonatomic) IBOutlet UITextField *customWidth;
//@property (retain, nonatomic) IBOutlet UITextField *customHeight;
//@property (retain, nonatomic) IBOutlet UIButton *loadInterAd;
@property(nonatomic,retain) NSString *isInVideo;
@property(nonatomic,retain) NSString *customWidth;
@property(nonatomic,retain) NSString *customHeight;

@property (nonatomic, retain) BaiduMobAdInterstitial* adInterstitial;
@property (nonatomic, retain) UIView *customInterView;

@end
