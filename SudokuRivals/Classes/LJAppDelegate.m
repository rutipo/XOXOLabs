//
//  LJAppDelegate.m
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LJAppDelegate.h"
#import "LJMainViewController.h"
#import "GKNotification.h"


#pragma mark C Functions

#pragma mark Static Functions

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

#pragma mark - LJAppDelegate

@implementation LJAppDelegate

@synthesize window=_window;
@synthesize achievementsDictionary, achievementsMetadata;
@synthesize presentingViewController;
@synthesize match;
@synthesize playersDict;


+ (BOOL)isVersionSupported:(NSString *)version
{
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:version options:NSNumericSearch] != NSOrderedAscending);
    
    return (osVersionSupported);
}

static LJAppDelegate *sharedHelper = nil;
+ (LJAppDelegate *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[LJAppDelegate alloc] init];
    }
    return sharedHelper;
}


#pragma mark NSAppDelegate
//Implemented to satisfy super deleagte

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
    
    LJMainViewController *controller = [LJMainViewController sharedController];
    
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


//Sent when the application is about to move from active to inactive.
//Pause ongoing tasks, disable timers, throttle down opengl frame rates. Games should use to pause.
- (void)applicationWillResignActive:(UIApplication *)application
{
}

//Used to release shared resources, invalidate timers, and store enough state information to restore.
//If background execution is supported, this method is called instead of applicationWillTerminate
- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

// Called as part of the transition from the background to the inactive state; 
//here you can undo many of the changes made on entering the background.
- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

// Restart any tasks that were paused (or not yet started) while the application was inactive. 
//If the application was previously in the background, optionally refresh the user interface.
- (void)applicationDidBecomeActive:(UIApplication *)application
{

}
// Called when the application is about to terminate. Save data if appropriate. 
// See also applicationDidEnterBackground:.
- (void)applicationWillTerminate:(UIApplication *)application
{
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


#pragma mark - Game Kit

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    [localPlayer authenticateWithCompletionHandler:^(NSError *error)
     {
         if (localPlayer.isAuthenticated)
         {
             NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://loopjoy.com/users/search?gamecenter_id=%@",localPlayer.playerID]]];
             // Perform additional tasks for the authenticated player.
             //[[SDKMainViewController sharedController] ];
             [request setHTTPMethod:@"GET"];
             
             connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
             //Send the emailString to the back end now!
             //NSLog(@"Correct email %@",playerID);
             
             [self loadAchievements];
             [self retrieveAchievementMetadata];
             
         }
     }];
    
}

//-   (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData{
//    NSString *result = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
//    NSLog(@"String sent from server %@",result);
//    if([result isEqualToString:@"NO"]){
//        //edit [[SDKMainViewController sharedController] setRegistered:FALSE];
//        NSLog(@"String set false");
//    }
//    else{
//        //edit [[SDKMainViewController sharedController] setRegistered:TRUE];
//        NSLog(@"String set True");
//    }
//    
//}


- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers   
                 viewController:(UIViewController *)viewController 
                       delegate:(id)theDelegate {
    
    if (!IsGameCenterAPIAvailable) return;
    
    matchStarted = NO;
    self.match = nil;
    self.presentingViewController = viewController;
    delegate = (id)theDelegate;               
    [presentingViewController dismissModalViewControllerAnimated:NO];
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init]; 
    request.minPlayers = minPlayers;     
    request.maxPlayers = maxPlayers;
    
    GKMatchmakerViewController *mmvc = 
    [[GKMatchmakerViewController alloc] initWithMatchRequest:request];    
    mmvc.matchmakerDelegate = self;
    
    [presentingViewController presentModalViewController:mmvc animated:YES];
    
}


- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)theMatch {
    [presentingViewController dismissModalViewControllerAnimated:YES];
    self.match = theMatch;
    match.delegate = delegate;
    if (!matchStarted && match.expectedPlayerCount == 0) {
        NSLog(@"Ready to start match!");
    }
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID{};



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
                                     if ([LJAppDelegate isVersionSupported:@"5.0"])
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

