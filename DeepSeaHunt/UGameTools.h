//
//  UGameTools.h
//  DeepSeaHunt
//
//  Created by Unity on 12-10-25.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "cocos2d.h"
typedef struct{
    CGPoint point_1;
    CGPoint point_2;
}Segment;
@interface UGameTools : NSObject

+(BOOL)dotWithRotationRectCollide:(CGPoint)dot rect:(CGRect)rect angle:(float)angle;

+(BOOL)rectangleCollide:(CGRect)rect1 angle1:(float)angle1 rect2:(CGRect)rect2 angle2:(float)angle2;

+ (BOOL)isJailbroken;

+ (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2;
@end
