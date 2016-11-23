//
//  UGameSceneChoice.h
//  DeepSeaHunt
//
//  Created by Unity on 13-5-6.
//  Copyright (c) 2013年 akn. All rights reserved.
//

#import "cocos2d.h"
#import "GameDefine.h"
#import "UGameScene.h"
#import "UShopLayer.h"

@interface UGameSceneChoice : CCLayer<UShopDelegate,UInAppDelegate>
{
    NSMutableArray *choiceArray;
    int nowSceneID;                                        //选中的场景编号
    int itemSpace,itemLayerWidth;                          //选项间的距离
    
    CGPoint prevPoint;
    CCLayer *itemLayer;
    
    CGPoint beganPos,endPos,nowPos,itemLayerPos;
    InAppPur *tempObserver;
    //按钮
    CCMenuItem *itemBack,*itemStart;
    
    UShopLayer *shopLayer;
    
    int nowGold;
    CCLabelAtlas *nowGoldAtlas;
}
+(CCScene*)scene;

@end
