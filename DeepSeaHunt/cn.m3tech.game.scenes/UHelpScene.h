//
//  UHelpScene.h
//  DeepSeaHunt
//
//  Created by Unity on 12-10-19.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "cocos2d.h"
#import "GameDefine.h"
@interface UHelpScene : CCLayer
{
    CCSprite *wordImage;
    CGPoint point;
    CGSize wordImageSize;
}
+ (id)scene;
@end
