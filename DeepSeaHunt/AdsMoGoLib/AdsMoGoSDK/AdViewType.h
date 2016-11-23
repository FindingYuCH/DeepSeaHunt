//
//  AdViewType.h
//  AdsMogo
//
//  Created by MOGO on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


typedef enum {
    AdViewTypeUnknown = 0,          //error
	AdViewTypeNormalBanner = 1,     //e.g. 320 * 50 ; 320 * 48...  iphone banner
    AdViewTypeLargeBanner = 2,      //e.g. 728 * 90 ; 768 * 110    ipad only
    AdViewTypeMediumBanner = 3,     //e.g. 468 * 60 ; 508 * 80     ipad only
    AdViewTypeRectangle = 4,        //e.g. 300 * 250; 320 * 270    ipad only 
    AdViewTypeSky = 5,              //Don't support
    AdViewTypeFullScreen = 6,       //iphone full screen ad
    AdViewTypeVideo = 7,            //Don't support
    AdViewTypeiPadNormalBanner = 8, //ipad use iphone banner
    AdViewTypeiPadFullScreen = 9,   //ipad full screen ad e.g. 1024*768                ipad only

} AdViewType;