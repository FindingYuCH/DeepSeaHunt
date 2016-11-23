//
//  G.m
//  DeepSeaHunt
//
//  Created by 东海 阮 on 12-8-15.
//  Copyright 2012年 akn. All rights reserved.
//
#import "G.h"


@implementation G
+ (void)drawBox:(CCLayer *)p pos:(CGPoint)pos row:(int)row col:(int)col
{
	
	int curX = pos.x;
	int curY = pos.y;
	CCSprite *spTemp; 
	CCSpriteBatchNode *spbnTemp = [CCSpriteBatchNode batchNodeWithFile:@"com_box.png"];
	//左上
	spTemp = [CCSprite spriteWithFile:@"com_box.png" rect:CGRectMake(0, 17, 8, 8)];
	spTemp.anchorPoint = ccp(0, 1);
	spTemp.position = ccp(curX, curY);
	[spbnTemp addChild:spTemp];
	curX += 8;
	
	//上
	for (int i = 0; i < col; i++) {
		spTemp = [CCSprite spriteWithFile:@"com_box.png" rect:CGRectMake(6, 17, 8, 8)];
		spTemp.anchorPoint = ccp(0, 1);
		spTemp.position = ccp(curX, curY);
		[spbnTemp addChild:spTemp];
		curX += 8;
	}
	
	//右上
	spTemp = [CCSprite spriteWithFile:@"com_box.png" rect:CGRectMake(17, 17, 8, 8)];
	spTemp.anchorPoint = ccp(0, 1);
	spTemp.position = ccp(curX, curY);
	[spbnTemp addChild:spTemp];
	
	//左
	curX = pos.x;
	curY = pos.y + 8;
	for (int i = 0; i < row; i++) {
		spTemp = [CCSprite spriteWithFile:@"com_box.png" rect:CGRectMake(0, 6, 8, 8)];
		spTemp.anchorPoint = ccp(0, 1);
		spTemp.position = ccp(curX, curY);
		[spbnTemp addChild:spTemp];
		curY += 8;
	}
	
	//中
	curX = pos.x + 8;
	curY = pos.y + 8;
	for (int i = 0; i < row; i++) {		
		for (int j = 0; j < col; j++) {
			spTemp = [CCSprite spriteWithFile:@"com_box.png" rect:CGRectMake(6, 6, 8, 8)];
			spTemp.anchorPoint = ccp(0, 1);
			spTemp.position = ccp(curX, curY);
			[spbnTemp addChild:spTemp];
			curX += 8;
		}
		curY += 8;
		curX = pos.x + 8;
	}
	
	//右
	curX = pos.x + 8 + col * 8;
	curY = pos.y + 8;
	for (int i = 0; i < row; i++) {
		spTemp = [CCSprite spriteWithFile:@"com_box.png" rect:CGRectMake(17, 6, 8, 8)];
		spTemp.anchorPoint = ccp(0, 1);
		spTemp.position = ccp(curX, curY);
		[spbnTemp addChild:spTemp];
		curY += 8;
	}
	
	//左下
	curX = pos.x;
	spTemp = [CCSprite spriteWithFile:@"com_box.png" rect:CGRectMake(0, 0, 8, 8)];
	spTemp.anchorPoint = ccp(0, 1);
	spTemp.position = ccp(curX, curY);
	[spbnTemp addChild:spTemp];
	curX += 8;
	
	//下
	for (int i = 0; i < col; i++) {
		spTemp = [CCSprite spriteWithFile:@"com_box.png" rect:CGRectMake(6, 0, 8, 8)];
		spTemp.anchorPoint = ccp(0, 1);
		spTemp.position = ccp(curX, curY);
		[spbnTemp addChild:spTemp];
		curX += 8;
	}
	
	//右下
	spTemp = [CCSprite spriteWithFile:@"com_box.png" rect:CGRectMake(17, 0, 8, 8)];
	spTemp.anchorPoint = ccp(0, 1);
	spTemp.position = ccp(curX, curY);
	[spbnTemp addChild:spTemp];
	[p addChild:spbnTemp];
}
@end