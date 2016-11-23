//
//  BaiduMobAdVideo.h
//  BaiduMobAdSdk
//
//  Created by lishan04 on 15-6-8.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaiduMobAdVideoDelegate.h"

@interface BaiduMobAdVideoView : UIView

/**
 *  委托对象
 */
@property (nonatomic ,assign) id<BaiduMobAdVideoDelegate> delegate;
/**
 *  设置/获取代码位id
 */
@property (nonatomic,copy) NSString* AdUnitTag;
/**
 *  设置视频广告的时长
 */
@property (nonatomic) int duration;

/**
 *  是否显示倒计时
 */
@property (nonatomic) BOOL showTimeLabel;

/**
 *  请求视频广告
 */
- (void)requestVideoAd;
/**
 *  播放视频广告
 */
- (void)startVideoAd;
/**
 *  关闭视频广告
 */
- (void)closeVideoAd;
@end
