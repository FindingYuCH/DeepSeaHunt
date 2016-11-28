//
//  AppDelegate.m
//  DeepSeaHunt
//
//  Created by 东海 阮 on 12-8-16.
//  Copyright 2012年 akn. All rights reserved.
//

#import "cocos2d.h"
#import "GameDefine.h"
#import "AppDelegate.h"
#import "GCHelper.h"
#import "TestMainScene.h"
#import "GameSceneForGameCenter.h"
#import "UWelcomeScene.h"
//#import "MobClick.h"
//#import "UMSocialData.h"
//#import "UMSocialSnsService.h"

#import "UMMobClick/MobClick.h"

@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //友盟集成测试的唯一id获取
    Class cls = NSClassFromString(@"UMANUtil");
    SEL deviceIDSelector = @selector(openUDIDString);
    NSString *deviceID = nil;
    if(cls && [cls respondsToSelector:deviceIDSelector]){
        deviceID = [cls performSelector:deviceIDSelector];
    }
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@{@"oid" : deviceID}
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSLog(@"我的OpenID=====%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
#pragma mrak=== 友盟集成
    
//    [MobClick setLogEnabled:YES];
    UMConfigInstance.appKey = @"5834f070310c934340001895";
//    UMConfigInstance.ChannelId = @"App Store";
//    UMConfigInstance.secret = @"secretstringaldfkals";
        UMConfigInstance.eSType = E_UM_GAME;
    [MobClick startWithConfigure:UMConfigInstance];
    
#pragma mark ====ios8之后的定位授权
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        //调用弹出允许定位框了.
        [_locationManager requestWhenInUseAuthorization];
    
    };
    
    
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    
	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
    
	director_.wantsFullScreenLayout = YES;
    
	// Display FSP and SPF
//	[director_ setDisplayStats:YES];
    
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
    
	// attach the openglView to the director
	[director_ setView:glView];
    
	// for rotation and other messages
	[director_ setDelegate:self];
    
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
    //	[director setProjection:kCCDirectorProjection3D];
    
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
    //判断ipad
//	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//		g_isIpad = YES;
//	}else {
//        if( ! [director_ enableRetinaDisplay:YES] )
//            CCLOG(@"Retina Display Not supported");
//    }
    if (!isPad) {
        if( ! [director_ enableRetinaDisplay:YES] )
            CCLOG(@"Retina Display Not supported");
    }
    
	// Create a Navigation Controller with the Director
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
    
	// set the Navigation Controller as the root view controller
    //	[window_ setRootViewController:rootViewController_];
//	[window_ addSubview:navController_.view];
    //运行时的iOS版本号
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    //ios6.0之前的版本(有所不同)
    if (version<6.0) {
        [window_ addSubview:navController_.view];
    }
    else{
        //ios6.0和之后的版本
        [window_ setRootViewController:navController_];
    }
	// make main window visible
	[window_ makeKeyAndVisible];
    
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
	// When in iPhone RetinaDisplay, iPad, iPad RetinaDisplay mode, CCFileUtils will append the "-hd", "-ipad", "-ipadhd" to all loaded files
	// If the -hd, -ipad, -ipadhd files are not found, it will load the non-suffixed version
	[CCFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[CCFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "" (empty string)
	[CCFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
    
    
    
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
    // Try to start Game Center
    
//    [GCHelper sharedInstance];
    ///dijk 2016-05-21
    //[MobClick startWithAppkey:kUMAPPKEY reportPolicy:REALTIME channelId:nil];
    //[UMSocialData setAppKey:kUMAPPKEY];
    [self applicationLocalNotification:application];
	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	[director_ pushScene: [UWelcomeScene scene]]; 
    
	return YES;
}
///dijk 2016-05-21
/*
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    // 如果你除了使用我们sdk之外还要处理另外的url，你可以把`handleOpenURL:wxApiDelegate:`的实现复制到你的代码里面，再添加你要处理的url。
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}
 */

//本地推送
- (void) applicationLocalNotification:(UIApplication*)application
{

    application.applicationIconBadgeNumber = 0;//应用程序右上角的数字=0（消失）
    [[UIApplication sharedApplication] cancelAllLocalNotifications];//取消所有的通知
    //------通知；
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {//判断系统是否支持本地通知
        
//      notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:10];//本次开启立即执行的周期
        notification.repeatInterval=kCFCalendarUnitDay;//循环通知的周期
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.alertBody=@"到了鱼儿游玩时间啦，趁现在赶紧抓住它们!";//弹出的提示信息
        notification.applicationIconBadgeNumber=0; //应用程序的右上角小数字
        notification.soundName= UILocalNotificationDefaultSoundName;//本地化通知的声音
        notification.alertAction = NSLocalizedString(@"马上就去", nil);  //弹出的提示框按钮
        [[UIApplication sharedApplication]   scheduleLocalNotification:notification];
    }
}
- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return UIInterfaceOrientationMaskLandscape;
    //
    //UIInterfaceOrientationMaskAllButUpsideDown
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationLandscapeLeft;
}

- (BOOL)shouldAutorotate{
    return YES;
}
// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
    [[UGameScene sharedScene] saveGameData];
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window_ release];
	[navController_ release];
    
	[super dealloc];
}
@end
