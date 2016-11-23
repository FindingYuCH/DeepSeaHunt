//
//  UNet.m
//  DeepSeaHunt
//
//  Created by Unity on 12-8-31.
//  Copyright (c) 2012年 akn. All rights reserved.
//

#import "UNet.h"
#define kNetSmallSize 0.5
#define kNetMediumSize 0.75
#define kNetBigSize 1
@implementation UNet

@synthesize playerID;
@synthesize netLevel;
@synthesize netSize;

-(id)init:(int)level plaerID:(kPlayerID)pid point:(CGPoint)pos
{
    if (self=[super initWithFile:@"fishnet.png"]) {
//        Net *net = [Net spriteWithFile:@"fishnet.png"];
//        [self initWithFile:@"fishnet.png"];
        
//        NSLog(@"网的大小  %f   %f",self.contentSize.width,self.contentSize.height);
        
        playerID=pid;
        
        if (level<3) {
            nowScale=kNetSmallSize;
        }else if (level<6) {
            nowScale=kNetMediumSize;
        }else {
            nowScale=kNetBigSize;
        }
        self.scale=nowScale;
        netSize=CGSizeMake(self.contentSize.width*nowScale,self.contentSize.height*nowScale);
//         NSLog(@"缩放之后网的大小  %f   %f",self.contentSize.width,self.contentSize.height);
        [self playAnimation];
        self.position=pos;
        
    }
    return self;
}

-(void)playAnimation 
{
    id toSmall=[CCScaleTo actionWithDuration:0.2 scale:nowScale*0.9];
    id toBig=[CCScaleTo actionWithDuration:0.2 scale:nowScale];
    id fun=[CCCallFunc actionWithTarget:self selector:@selector(delete)];
    [self runAction:[CCSequence actions:toSmall,toBig,toSmall,fun, nil]];
}
-(void)delete
{
    [self removeFromParentAndCleanup:true];
    [self release];
}
-(void)dealloc
{
//    NSLog(@"鱼网被清除");
    [super dealloc];
}
@end
