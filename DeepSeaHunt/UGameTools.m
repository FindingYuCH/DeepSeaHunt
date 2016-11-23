//
//  UGameTools.m
//  DeepSeaHunt
//
//  Created by Unity on 12-10-25.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "UGameTools.h"

@implementation UGameTools


//检测点与旋转矩形的碰撞

+(BOOL)dotWithRotationRectCollide:(CGPoint)dot rect:(CGRect)rect angle:(float)angle
{
    CGPoint newDot=ccpRotateByAngle(dot, rect.origin, angle*M_PI/180);
    
    CGRect newRect=CGRectMake(rect.origin.x-rect.size.width/2, rect.origin.y-rect.size.height/2, rect.size.width, rect.size.height);
    
    NSLog(@"点与矩形的碰撞检测:x=%f   y=%f  temRect:x=%f  y=%f  w=%f  h=%f",newDot.x,newDot.y,newRect.origin.x,newRect.origin.y,newRect.size.width,newRect.size.height);
    
    return CGRectContainsPoint(newRect, newDot);
}

//检测2个旋转矩形的碰撞

+(BOOL)rectangleCollide:(CGRect)rect1 angle1:(float)angle1 rect2:(CGRect)rect2 angle2:(float)angle2
{
    //都位垂直的矩形时
    if ((int)angle1%90==0&&(int)angle2%90==0) {
        return CGRectIntersectsRect(CGRectMake(rect1.origin.x-rect1.size.width/2, rect1.origin.y-rect1.size.height/2, rect1.size.width, rect1.size.height), CGRectMake(rect2.origin.x-rect2.size.width/2, rect2.origin.y-rect2.size.height/2, rect2.size.width, rect2.size.height));
    }
    
    
    //判断中心点是否有在矩形区域内
    if ([self dotWithRotationRectCollide:rect1.origin rect:rect2 angle:angle2]) {
        return true;
    }
    
    if ([self dotWithRotationRectCollide:rect2.origin rect:rect1 angle:angle1]) {
        return true;
    }
    
    
    //    NSLog(@"角度1=%f 角度2=%f ",angle1,angle2);
    
    BOOL isCollide=false;
    Segment segment1[4],segment2[4];
    
    CGPoint point_1[4],point_2[4];
    
    point_1[0]=ccpRotateByAngle(CGPointMake(rect1.origin.x-rect1.size.width/2, rect1.origin.y-rect1.size.height/2), rect1.origin, -angle1*M_PI/180);
    
    //    NSLog(@"第一个点的值:   x=%f   y=%f",point_1[0].x,point_1[0].y);
    
    point_1[1]=ccpRotateByAngle(CGPointMake(rect1.origin.x+rect1.size.width/2, rect1.origin.y-rect1.size.height/2), rect1.origin, -angle1*M_PI/180);

    //     NSLog(@"第二个点的值:   x=%f   y=%f",point_1[1].x,point_1[1].y);

    point_1[2]=ccpRotateByAngle(CGPointMake(rect1.origin.x+rect1.size.width/2, rect1.origin.y+rect1.size.height/2), rect1.origin, -angle1*M_PI/180);
    
    point_1[3]=ccpRotateByAngle(CGPointMake(rect1.origin.x-rect1.size.width/2, rect1.origin.y+rect1.size.height/2), rect1.origin, -angle1*M_PI/180);
    
    //4条线段
    //1
    segment1[0].point_1=point_1[0];
    segment1[0].point_2=point_1[1];
    //2
    segment1[1].point_1=point_1[1];
    segment1[1].point_2=point_1[2];
    //3
    segment1[2].point_1=point_1[2];
    segment1[2].point_2=point_1[3];
    //4
    segment1[3].point_1=point_1[3];
    segment1[3].point_2=point_1[0];
    
    
    point_2[0]=ccpRotateByAngle(CGPointMake(rect2.origin.x-rect2.size.width/2, rect2.origin.y-rect2.size.height/2), rect2.origin, -angle2*M_PI/180);
    
    point_2[1]=ccpRotateByAngle(CGPointMake(rect2.origin.x+rect2.size.width/2, rect2.origin.y-rect2.size.height/2), rect2.origin, -angle2*M_PI/180);
    
    point_2[2]=ccpRotateByAngle(CGPointMake(rect2.origin.x+rect2.size.width/2, rect2.origin.y+rect2.size.height/2), rect2.origin, -angle2*M_PI/180);
    
    point_2[3]=ccpRotateByAngle(CGPointMake(rect2.origin.x-rect2.size.width/2, rect2.origin.y+rect2.size.height/2), rect2.origin, -angle2*M_PI/180);
    
    
    //4条线段
    //1
    segment2[0].point_1=point_2[0];
    segment2[0].point_2=point_2[1];
    //2
    segment2[1].point_1=point_2[1];
    segment2[1].point_2=point_2[2];
    //3
    segment2[2].point_1=point_2[2];
    segment2[2].point_2=point_2[3];
    //4
    segment2[3].point_1=point_2[3];
    segment2[3].point_2=point_2[0];


    
    int n=0;
    for (int i=0; i<4; i++) {
        for (int j=0; j<4; j++) {
            if ( ccpSegmentIntersect(segment1[i].point_1, segment1[i].point_2, segment2[j].point_1, segment2[j].point_2)) {
                n++;
                
                NSLog(@"i=%d   j=%d",i,j);
                isCollide= true;
            }            
        }
    }
    
    
    //    ccpSegmentIntersect//2条线段是否相交
    
    return isCollide;
}

//检测2个旋转矩形的碰撞  判断

+(BOOL)rectangleCollide2:(CGRect)rect1 angle1:(float)angle1 rect2:(CGRect)rect2 angle2:(float)angle2
{
    //都位垂直的矩形时
    if ((int)angle1%90==0&&(int)angle2%90==0) {
        return CGRectIntersectsRect(CGRectMake(rect1.origin.x-rect1.size.width/2, rect1.origin.y-rect1.size.height/2, rect1.size.width, rect1.size.height), CGRectMake(rect2.origin.x-rect2.size.width/2, rect2.origin.y-rect2.size.height/2, rect2.size.width, rect2.size.height));
    }
    
    
    //判断中心点是否有在矩形区域内
    if ([self dotWithRotationRectCollide:rect1.origin rect:rect2 angle:angle2]) {
        return true;
    }
    
    if ([self dotWithRotationRectCollide:rect2.origin rect:rect1 angle:angle1]) {
        return true;
    }
    
    
    //    NSLog(@"角度1=%f 角度2=%f ",angle1,angle2);
    
    BOOL isCollide=false;
    Segment segment1[4],segment2[4];
    
    CGPoint point_1[4],point_2[4];
    
    point_1[0]=ccpRotateByAngle(CGPointMake(rect1.origin.x-rect1.size.width/2, rect1.origin.y-rect1.size.height/2), rect1.origin, -angle1*M_PI/180);
    
    //    NSLog(@"第一个点的值:   x=%f   y=%f",point_1[0].x,point_1[0].y);
    
    point_1[1]=ccpRotateByAngle(CGPointMake(rect1.origin.x+rect1.size.width/2, rect1.origin.y-rect1.size.height/2), rect1.origin, -angle1*M_PI/180);
    
    
    //     NSLog(@"第二个点的值:   x=%f   y=%f",point_1[1].x,point_1[1].y);
    
    
    
    point_1[2]=ccpRotateByAngle(CGPointMake(rect1.origin.x+rect1.size.width/2, rect1.origin.y+rect1.size.height/2), rect1.origin, -angle1*M_PI/180);
    
    point_1[3]=ccpRotateByAngle(CGPointMake(rect1.origin.x-rect1.size.width/2, rect1.origin.y+rect1.size.height/2), rect1.origin, -angle1*M_PI/180);
    
    //4条线段
    //1
    segment1[0].point_1=point_1[0];
    segment1[0].point_2=point_1[1];
    //2
    segment1[1].point_1=point_1[1];
    segment1[1].point_2=point_1[2];
    //3
    segment1[2].point_1=point_1[2];
    segment1[2].point_2=point_1[3];
    //4
    segment1[3].point_1=point_1[3];
    segment1[3].point_2=point_1[0];
    
    
    point_2[0]=ccpRotateByAngle(CGPointMake(rect2.origin.x-rect2.size.width/2, rect2.origin.y-rect2.size.height/2), rect2.origin, -angle2*M_PI/180);
    
    point_2[1]=ccpRotateByAngle(CGPointMake(rect2.origin.x+rect2.size.width/2, rect2.origin.y-rect2.size.height/2), rect2.origin, -angle2*M_PI/180);
    
    point_2[2]=ccpRotateByAngle(CGPointMake(rect2.origin.x+rect2.size.width/2, rect2.origin.y+rect2.size.height/2), rect2.origin, -angle2*M_PI/180);
    
    point_2[3]=ccpRotateByAngle(CGPointMake(rect2.origin.x-rect2.size.width/2, rect2.origin.y+rect2.size.height/2), rect2.origin, -angle2*M_PI/180);
    
    
    //4条线段
    //1
    segment2[0].point_1=point_2[0];
    segment2[0].point_2=point_2[1];
    //2
    segment2[1].point_1=point_2[1];
    segment2[1].point_2=point_2[2];
    //3
    segment2[2].point_1=point_2[2];
    segment2[2].point_2=point_2[3];
    //4
    segment2[3].point_1=point_2[3];
    segment2[3].point_2=point_2[0];
    
    
    
    int n=0;
    for (int i=0; i<4; i++) {
        for (int j=0; j<4; j++) {
            if ( ccpSegmentIntersect(segment1[i].point_1, segment1[i].point_2, segment2[j].point_1, segment2[j].point_2)) {
                n++;
                
                NSLog(@"i=%d   j=%d",i,j);
                isCollide= true;
            }            
        }
    }
    
    
    //    ccpSegmentIntersect//2条线段是否相交
    
    return isCollide;
}
-(float)dotLength:(CGPoint)point point2:(CGPoint)point2
{
    return sqrt((point.x-point2.x)*(point.x-point2.x)+(point.y-point2.y)*(point.y-point2.y));
}
//判断是否越狱
+ (BOOL)isJailbroken

{
    
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    
    NSString *aptPath = @"/private/var/lib/apt/";
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath])
        
    {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath])
        
    {
        jailbroken = YES;
    }
    return jailbroken;
    
}
//判断日期是否同一天
+ (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}
@end
