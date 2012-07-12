//
//  SDKAppDelegate.m
//
//  Created by Charles-André LEDUC on 17/06/11.
//  Copyright 2011. All rights reserved.
//

#import "SDKAppDelegate.h"
#import "SDKMainViewController.h"
#import "GKNotification.h"

#pragma mark C Functions
static int gameStateChange = 0;

static inline BOOL IsGameCenterAPIAvailable()
{
    // Check for presence of GKLocalPlayer class.
    BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
    
    // The device must be running iOS 4.3 or later.
    NSString *reqSysVer = @"4.3";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (localPlayerClassAvailable && osVersionSupported);
}



#pragma mark - SDKAppDelegate

@implementation SDKAppDelegate

@synthesize window=_window;
@synthesize achievementsDictionary, achievementsMetadata;
@synthesize presentingViewController;
@synthesize match;
@synthesize delegate;
@synthesize playersDict;

+ (BOOL)isVersionSupported:(NSString *)version
{
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:version options:NSNumericSearch] != NSOrderedAscending);
    
    return (osVersionSupported);
}

static SDKAppDelegate *sharedHelper = nil;
+ (SDKAppDelegate *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[SDKAppDelegate alloc] init];
    }
    return sharedHelper;
}
#pragma mark - NSApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"Metal_brushed",UI_BG,
                                 @"Paper_plain_main",UI_PAPER,
                                 [NSKeyedArchiver archivedDataWithRootObject:[UIColor darkGrayColor]],UI_COLOR_SELECTION,
                                 @"Helvetica-Bold",UI_FONT_GAME_NAME,
                                 [NSKeyedArchiver archivedDataWithRootObject:[UIColor blackColor]],UI_FONT_GAME_COLOR,
                                 @"Marker Felt Thin",UI_FONT_PLAYER_NAME,
                                 [NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:0.15 green:0.3 blue:0.7 alpha:1.0]],UI_FONT_PLAYER_COLOR,
                                 [NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:0.15 green:0.3 blue:0.7 alpha:1.0]],UI_FONT_PLAYER_COLOR,nil];
    
    [userDefaults registerDefaults:appDefaults];
    
    if (achievementsDictionary == nil)
        achievementsDictionary = [[NSMutableDictionary alloc] init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.92 alpha:1.0];
        
    SDKMainViewController *controller = [SDKMainViewController sharedController];
    
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    
    if (IsGameCenterAPIAvailable)
    {
        [self authenticateLocalPlayer];
        //[self resetAchievements];
    }
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}
#pragma mark GKMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    [presentingViewController dismissModalViewControllerAnimated:YES];
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
            NSLog(@"Player connected!");
            
           
                NSLog(@"Ready to start match!");
                [self lookupPlayers];
            gameStateChange = 0;
            
            
            break; 
        case GKPlayerStateDisconnected:
            // a player just disconnected. 
            NSLog(@"Player disconnected!");
            if(gameStateChange == 0){
            alertWithYesNoButtons = [[UIAlertView alloc] initWithTitle:@"Disconnected"
                                                               message:@"Your opponent has disconnected. Would you like to quit?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                gameStateChange =1;
            }
            [alertWithYesNoButtons show];
            matchStarted = NO;
            [delegate matchEnded];
            break;
    }                     
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    
    if (match != theMatch) return;
    
    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
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

- (void)alertView : (UIAlertView *)alertView clickedButtonAtIndex : (NSInteger)buttonIndex
{
    if(alertView == alertWithYesNoButtons)
    {
        if(buttonIndex == 0)
        {
            NSLog(@"no button was pressed\n");
        }
        else
        {
           [[SDKMainViewController sharedController] clear];
        }
    }
}


#pragma mark - Game Kit

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    [localPlayer authenticateWithCompletionHandler:^(NSError *error)
    {
        if (localPlayer.isAuthenticated)
        {
            // Perform additional tasks for the authenticated player.
            [self loadAchievements];
            [self retrieveAchievementMetadata];
        }
    }];
}

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers   
                 viewController:(UIViewController *)viewController 
                       delegate:(id<SDKAppDelegate>)theDelegate {
    
    if (!IsGameCenterAPIAvailable) return;
    
    matchStarted = NO;
    self.match = nil;
    self.presentingViewController = viewController;
    delegate = theDelegate;               
    [presentingViewController dismissModalViewControllerAnimated:NO];
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init]; 
    request.minPlayers = minPlayers;     
    request.maxPlayers = maxPlayers;
    
    GKMatchmakerViewController *mmvc = 
    [[GKMatchmakerViewController alloc] initWithMatchRequest:request];    
    mmvc.matchmakerDelegate = self;
    
    [presentingViewController presentModalViewController:mmvc animated:YES];
    
}

- (void)lookupPlayers {
    
    NSLog(@"Looking up %d players...", match.playerIDs.count);
    [GKPlayer loadPlayersForIdentifiers:match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        
        if (error != nil) {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
            matchStarted = NO;
            [delegate matchEnded];
        } else {
            
            // Populate players dict
            self.playersDict = [NSMutableDictionary dictionaryWithCapacity:players.count];
            for (GKPlayer *player in players) {
                NSLog(@"Found player: %@", player.alias);
                [playersDict setObject:player forKey:player.playerID];
            }
            
            // Notify delegate match can begin
            matchStarted = YES;
            [[SDKMainViewController sharedController] matchStarted];
            
        }
    }];
    
}




- (void)loadAchievements
{
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error)
    {
        if (error == nil)
        {
            for (GKAchievement* achievement in achievements)
                [achievementsDictionary setObject:achievement forKey:achievement.identifier];
            
            if ([[achievementsDictionary allKeys] isEqualToArray:[NSArray arrayWithObjects:kAchievementExpert,kAchievementMaster,kAchievementNoHints,kAchievementOneHundred,kAchievementStart,kAchievementTime,kAchievementTimeUp, nil]])
                [self reportAchievementIdentifier:kAchievementAll percentComplete:100.0f];
        }
    }];
}

- (GKAchievement*)getAchievementForIdentifier:(NSString*)identifier
{
    GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];
    if (achievement == nil)
    {
        achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        [achievementsDictionary setObject:achievement forKey:achievement.identifier];
    }
    return achievement;
}

- (void)reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent
{
    GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
    if (achievement)
    {
        if (achievement.percentComplete < 100.0f)
        {
            achievement.percentComplete = percent;
            [achievement reportAchievementWithCompletionHandler:^(NSError *error)
             {
                 if (error != nil)
                 {
                     // Retain the achievement object and try again later (not shown).
                     NSLog(@"%@",error);
                 }
                 else
                 {
                     if (percent == 100.0f)
                     {
                         achievement.showsCompletionBanner = YES;
                         
                         GKAchievementDescription *desc = [achievementsMetadata objectForKey:achievement.identifier];
                         
                         if (desc)
                         {
                             [desc loadImageWithCompletionHandler:^(UIImage *image, NSError *error) {
                                 if (error != nil)
                                 {
                                     // Retain the achievement object and try again later (not shown).
                                     NSLog(@"%@",error);
                                 }
                                 else
                                 {
                                     if ([SDKAppDelegate isVersionSupported:@"5.0"])
                                         [GKNotificationBanner showBannerWithTitle:desc.title message:desc.achievedDescription completionHandler:NULL];
                                     else
                                         [[GKNotificationHandler defaultHandler] notifyAchievement:desc];
                                 }
                             }];
                         }
                     }
                 }
             }];
        }
    }
}

- (void)retrieveAchievementMetadata
{
    [GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler:^(NSArray *descriptions, NSError *error)
    {
        if (error != nil)
            NSLog(@"%@",error);
        
        if (descriptions != nil)
        {
            for (GKAchievementDescription *description in descriptions)
            {
                if (achievementsMetadata == nil)
                    achievementsMetadata = [[NSMutableDictionary alloc] init];
                
                [achievementsMetadata setObject:description forKey:description.identifier];
            }
        }
    }];
}

- (void)resetAchievements
{
    // Clear all locally saved achievement objects.
    achievementsDictionary = nil;
    //[achievementsDictionary release];
    achievementsDictionary = [[NSMutableDictionary alloc] init];
    
    // Clear all progress saved on Game Center
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
    {
         if (error != nil)
             NSLog(@"%@",error);
    }];
}

void uncaughtExceptionHandler(NSException *exception)
{
    NSString *reasonString = [exception reason];
    NSLog(@"%@",reasonString);
}

@end
