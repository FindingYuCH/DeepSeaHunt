//
//  USave.h
//  Real Mission
//
//  Created by Unity on 12-3-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

typedef struct{
    int num1;
    int num2;
}RecordDemo;



@interface USave : NSObject
{
}
+(void)saveDemoTest;
+(void)saveGameData:(id) data toFile:(NSString*)string;
+(id)readGameData:(NSString*)fromFile;
+(BOOL)isHaveRecord:(NSString*)string;
+(void)deleteRecord:(NSString*)string;
@end
