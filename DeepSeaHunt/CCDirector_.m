//
//  CCDirector_.m
//  DeepSeaHunt
//
//  Created by 东海 阮 on 12-8-15.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "CCDirector_.h"
@implementation CCDirector (Extension)

-(void) popSceneWithTransition: (Class)transitionClass duration:(ccTime)t
{
	NSAssert( runningScene_ != nil, @"A running Scene is needed");
	
	[scenesStack_ removeLastObject];
	NSUInteger c = [scenesStack_ count];
	if( c == 0 ) {
		[self end];
	} else {
		CCScene* scene = [transitionClass transitionWithDuration:t scene:[scenesStack_ objectAtIndex:c-1]];
		[scenesStack_ replaceObjectAtIndex:c-1 withObject:scene];
		nextScene_ = scene;
	}
}

@end
