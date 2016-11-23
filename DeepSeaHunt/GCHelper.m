//
//  GCHelper.m
//  CatRace
//
//  Created by Ray Wenderlich on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GCHelper.h"
#import "GameSceneForGameCenter.h"
@implementation GCHelper
@synthesize gameCenterAvailable;
@synthesize presentingViewController;
@synthesize match;
@synthesize delegate;
@synthesize playersDict;
@synthesize otherPlayers;
@synthesize pendingInvite;
@synthesize pendingPlayersToInvite;

#pragma mark Initialization

static GCHelper *sharedHelper = nil;
+ (GCHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
	// check for presence of GKLocalPlayer API
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
	// check if the device is running iOS 4.1 or later
	NSString *reqSysVer = @"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer 
                                           options:NSNumericSearch] != NSOrderedAscending);
	
	return (gcClass && osVersionSupported);
}

- (id)init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc = 
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self 
                   selector:@selector(authenticationChanged) 
                       name:GKPlayerAuthenticationDidChangeNotificationName 
                     object:nil];
        }
    }
    return self;
}
-(NSString*)getPlayerName:(NSString *)playerID
{
    GKPlayer *player = [playersDict objectForKey:playerID];
    if (player==nil) {
        return @"玩家不存在";
    }
    
    return player.alias;
}
#pragma mark Internal functions

- (void)authenticationChanged {    
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
       NSLog(@"Authentication changed: player authenticated.");
       userAuthenticated = TRUE;
        NSLog(@"inviting player ...");
        [GKMatchmaker sharedMatchmaker].inviteHandler =^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
            
            NSLog(@"Received invite");
            self.pendingInvite = acceptedInvite;
            self.pendingPlayersToInvite = playersToInvite;
            [delegate inviteReceived];
            
        };
        
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
       NSLog(@"Authentication changed: player not authenticated");
       userAuthenticated = FALSE;
    }
                   
}
// Add new method after authenticationChanged
- (void)lookupPlayers {
    
    NSLog(@"Looking up %d players...", match.playerIDs.count);
    [GKPlayer loadPlayersForIdentifiers:match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        
        if (error != nil) {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
            matchStarted = NO;
            [delegate matchEnded];
        } else {
            otherPlayers=players.copy;
            // Populate players dict
            NSLog(@"player num :%d",players.count);
            self.playersDict = [NSMutableDictionary dictionaryWithCapacity:players.count];
            for (GKPlayer *player in players) {
                NSLog(@"Found player: %@", player.alias);
                [playersDict setObject:player forKey:player.playerID];
            }
            
            //Notify delegate match can begin
            matchStarted = YES;
            [delegate matchStarted];
            
        }
    }];
}

#pragma mark User functions

- (void)authenticateLocalUser { 
    
    if (!gameCenterAvailable) return;
    
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version<6.0) {
        if ([GKLocalPlayer localPlayer].authenticated == NO) {//authenticated
            //        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
            [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error){
                if (error == nil) {
                    //成功处理
//                    NSLog(@"OK");
//                    NSLog(@"1--alias--.%@",[GKLocalPlayer localPlayer].alias);
//                    NSLog(@"2--authenticated--.%d",[GKLocalPlayer localPlayer].authenticated);
//                    NSLog(@"3--isFriend--.%d",[GKLocalPlayer localPlayer].isFriend);
//                    NSLog(@"4--playerID--.%@",[GKLocalPlayer localPlayer].playerID);//1242612230
//                    NSLog(@"5--underage--.%d",[GKLocalPlayer localPlayer].underage);
                }else {
                    //错误处理
//                    NSLog(@"lose:  %@",error);
                }}];
        } else {
            NSLog(@"Already authenticated!");
        }

    }else{
        localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
        {
            if (localPlayer.isAuthenticated) {
                NSLog(@"######Authenticated!");
                if ([CCDirector sharedDirector].isPaused)
                    [[CCDirector sharedDirector] resume];
                
            }else{
                NSLog(@"########The Game Not Authenticated!");
                if (error==nil) {
                    NSLog(@"no  error!");
                    if ([CCDirector sharedDirector].isPaused)
                        [[CCDirector sharedDirector] resume];
                    if (localPlayer.authenticated) {
//                        _gameCenterFeaturesEnabled = YES;
                    } else if(viewController) {
                        [[CCDirector sharedDirector] pause];
                        [self presentViewController:viewController];

                    } else {
//                        _gameCenterFeaturesEnabled = NO;
                    }

                }else{
                    NSLog(@"error%@",error);
                }
            }
        };
    }
    NSLog(@"Authenticating local user...");
}
//-(void)presentViewController:(UIViewController*)vc {
//    AppController *delegate1= (AppController *) [[UIApplication sharedApplication] delegate];
////    self.presentingViewController = delegate1.navController;
//    UIViewController* rootVC = delegate1.navController;
//
////    [rootVC presentViewController:vc animated:YES
////                       completion:nil];
//    [rootVC presentModalViewController:vc animated:YES];
//}

#pragma mark UIViewController stuff

-(UIViewController*) getRootViewController {
    return [UIApplication
            sharedApplication].keyWindow.rootViewController;
}

-(void)presentViewController:(UIViewController*)vc {
    UIViewController* rootVC = [self getRootViewController];
    [rootVC presentViewController:vc animated:NO
                       completion:nil];
    
//    [rootVC addChildViewController:vc];
}

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController delegate:(id<GCHelperDelegate>)theDelegate {
    NSLog(@"find player!");
    if (!gameCenterAvailable) return;
    
    matchStarted = NO;
    self.match = nil;
    self.presentingViewController = viewController;
    delegate= theDelegate;
    
    if (pendingInvite != nil) {
        NSLog(@"invite player!");
        [presentingViewController dismissModalViewControllerAnimated:NO];
        GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithInvite:pendingInvite] autorelease];
        mmvc.matchmakerDelegate = self;
        [presentingViewController presentModalViewController:mmvc animated:YES];
        
        self.pendingInvite = nil;
        self.pendingPlayersToInvite = nil;
        
    } else {
        NSLog(@"auto find player!");
        [presentingViewController dismissModalViewControllerAnimated:NO];
        GKMatchRequest *request = [[[GKMatchRequest alloc] init] autorelease]; 
        request.minPlayers = minPlayers; 
        request.maxPlayers = maxPlayers;
        request.playersToInvite = pendingPlayersToInvite;
        
        GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithMatchRequest:request] autorelease]; 
        mmvc.matchmakerDelegate = self;
        
        [presentingViewController presentModalViewController:mmvc animated:YES];
        
        self.pendingInvite = nil;
        self.pendingPlayersToInvite = nil;
    }
}
#pragma mark GKMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    [presentingViewController dismissModalViewControllerAnimated:YES];
    [[GameSceneForGameCenter shardScene] deletePlayerInfoLoading];
    [[GameSceneForGameCenter shardScene] setStartButtonEnableOK];
    NSLog(@"取消对战");
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    [presentingViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"Error finding match: %@", error.localizedDescription);    
}

// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)theMatch {
    [presentingViewController dismissModalViewControllerAnimated:YES];
    self.match = theMatch;
    match.delegate = self;
    if (!matchStarted && match.expectedPlayerCount == 0) {
        NSLog(@"Ready to start match!");
        [self lookupPlayers];
    }
}

#pragma mark GKMatchDelegate

// The match received data sent from the player.
- (void)match:(GKMatch *)theMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    if (match != theMatch) return;
    [delegate match:theMatch didReceiveData:data fromPlayer:playerID];
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    if (match != theMatch) return;
    switch (state) {
        case GKPlayerStateConnected: 
            // handle a new player connection.
            if (!matchStarted && theMatch.expectedPlayerCount == 0) {
                NSLog(@"Ready to start match!");
                [self lookupPlayers];
            }
            break; 
        case GKPlayerStateDisconnected:
            // a player just disconnected. 
            NSLog(@"Player disconnected!");
            matchStarted = NO;
            [delegate matchEnded];
            break;
    }                 
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    if (match != theMatch) return;
    matchStarted = NO;
    [delegate matchEnded];
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)theMatch didFailWithError:(NSError *)error {
    if (match != theMatch) return;
    NSLog(@"Match failed with error: %@", error.localizedDescription);
    matchStarted = NO;
    [delegate matchEnded];
}

@end
