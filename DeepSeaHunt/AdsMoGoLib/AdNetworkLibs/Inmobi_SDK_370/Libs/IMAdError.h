//
//  IMAdError.h
//  InMobi AdNetwork SDK
//
//  Copyright 2013 InMobi Technology Services Ltd. All rights reserved.
//

#import "IMCommonUtil.h"
#import <Foundation/Foundation.h>

/**
 * IMAdErrorCode enum defines the NSError codes for InMobi ad fetch/click
 * request.
 */
typedef enum {
    /**
     * The ad request is invalid. Typically, this is because the ad did not
     * have the ad unit id or rootViewController set.
     */
    kIMADInvalidRequestError,
    /**
     * An ad request is already in progress.
     */
    kIMAdRequestInProgressError,
    /**
     * Ad request cancelled.
     */
    kIMAdRequestCancelled,
    /**
     * An ad click is in progress.
     */
    kIMAdClickInProgressError,
    /**
     * The ad request was successful, but no ad was returned.
     */
    kIMADNoFillError,
    /**
     * Network error.
     */
    kIMADNetworkError,
    /**
     * The ad fetching timed out.
     */
    kIMAdNetworkFetchTimedOut,
    /**
     * The ad rendering timed out.
     */
    kIMAdNetworkRenderingTimedOut,
    /**
     * The ad server experienced a failure while processing the request.
     */
    kIMADInternalError,
    
} IMAdErrorCode;

/**
 * IMAdError class represents the errors generated during ad request/click
 * failure.
 */
@interface IMAdError : NSError {

}

@end
