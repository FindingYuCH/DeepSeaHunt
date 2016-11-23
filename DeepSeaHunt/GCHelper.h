//
//  GCHelper.h
//  CatRace
//
//  Created by Ray Wenderlich on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "AppDelegate.h"
@protocol GCHelperDelegate 
- (void)matchStarted;
- (void)matchEnded;
- (void)inviteReceived;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
@end


@interface GCHelper : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate,GKGameCenterControllerDelegate> {
    
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    
    UIViewController *presentingViewController;
    GKMatch *match;
    BOOL matchStarted;
    id <GCHelperDelegate> delegate;
    NSArray *otherPlayers;
    NSMutableDictionary *playersDict;
    
    
    GKInvite *pendingInvite;
    NSArray  *pendingPlayersToInvite;
    
}
@property (retain) NSMutableDictionary *playersDict;
@property (retain) NSArray *otherPlayers;
@property (assign, readonly) BOOL gameCenterAvailable;
@property (retain) UIViewController *presentingViewController;
@property (retain) GKMatch *match;
@property (assign) id <GCHelperDelegate> delegate;

@property (retain) GKInvite *pendingInvite;
@property (retain) NSArray *pendingPlayersToInvite;


+ (GCHelper *)sharedInstance;
- (void)authenticateLocalUser;
- (NSString*)getPlayerName:(NSString *)playerID;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController delegate:(id<GCHelperDelegate>)theDelegate;

@end
