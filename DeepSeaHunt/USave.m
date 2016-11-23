//
//  USave.m
//  Real Mission
//
//  Created by Unity on 12-3-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "USave.h"

@implementation USave


-(void)saveDemo1
{
//    //=================NSUserDefaults========================  
//    NSString *saveStr1 = @"我是";  
//    NSString *saveStr2 = @"数据";  
//    NSArray *array = [NSArray arrayWithObjects:saveStr1, saveStr2, nil];           
//    //Save  
//    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];  
//    [saveDefaults setObject:array forKey:@"SaveKey"];  
//    //用于测试是否已经保存了数据  
//    saveStr1 = @"ooooooooo";  
//    saveStr2 = @"xxxxxxxxx";    
//    //---Load  
//    array = [saveDefaults objectForKey:@"SaveKey"];  
//    saveStr1 = [array objectAtIndex:0];  
//    saveStr2 = [array objectAtIndex:1];  
//    CCLOG(@"str:%@",saveStr1);  
//    CCLOG(@"astr:%@",saveStr2);  
}

+(void)saveDemoTest
{
    RecordDemo record;
    record.num1=5;
    record.num2=3;
    
    NSData *data=[NSData dataWithBytes:&record length:sizeof(record)];
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    [saveDefaults setObject:data forKey:@"saveTest"];
    
    NSData *readData=[saveDefaults objectForKey:@"saveTest"];
    RecordDemo *record2=(RecordDemo*)[readData bytes];
    NSLog(@"***************num1=%d  num2=%d ",record2->num1,record2->num2);
    NSLog(@"***************num2=%d  num1=%d ",record2->num2,record2->num1);
    
}

+(void)saveGameData:(id)data toFile:(NSString*)string
{
    //Save  
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];  
    [saveDefaults setObject:data forKey:string]; 
}
+(id)readGameData:(NSString*)fromFile
{
    //---Load  
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults]; 
    id data = [saveDefaults objectForKey:fromFile];
    if (data==nil) {
        NSLog(@"记录为空!");
    }else {
        NSLog(@"记录不为空!");
    }
    return data;
}
+(BOOL)isHaveRecord:(NSString*)string
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];     
    id data = [saveDefaults objectForKey:string];  
    if (data==nil) {
        NSLog(@"记录为空!");
        return false;
    }else {
        NSLog(@"记录不为空!");
        return true;
    }
}
+(void)deleteRecord:(NSString*)string
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];   
    //[saveDefaults setObject:nil forKey:@"SaveKey"]; 
    [saveDefaults removeObjectForKey:string];
}
@end
