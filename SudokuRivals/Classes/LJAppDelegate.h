//
//  LJAppDelegate.h
//
//  Created by Tennyson Hinds on 7/7/12.
//  Copyright 2012. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "GKHelperDelegate.h"

#define kAchievementStart @"448033081_001"
#define kAchievementMaster @"448033081_002"
#define kAchievementTime @"448033081_003"
#define kAchievementNoHints @"448033081_004"
#define kAchievementExpert @"448033081_005"
#define kAchievementOneHundred @"448033081_006"
#define kAchievementTimeUp @"448033081_007"
#define kAchievementAll @"448033081_100"

#define UI_BG @"SDK UI Background"
#define UI_PAPER @"SDK UI Paper"

#define UI_FONT_GAME_NAME @"SDK UI Game Font Name"
#define UI_FONT_PLAYER_NAME @"SDK UI Player Font Name"

#define UI_FONT_GAME_COLOR @"SDK UI Game Font Color"
#define UI_FONT_PLAYER_COLOR @"SDK UI Player Font Color"

#define UI_COLOR_SELECTION @"SDK UI Selection Color"

#define MAINLINE_WIDTH      2
#define LINE_WIDTH          1

#define FONT_SIZE_PLAYER    20
#define FONT_SIZE_GAME      18

static inline BOOL IsGameCenterAPIAvailable();

@protocol LJAppDelegate 
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
@end


@interface LJAppDelegate : NSObject <UIApplicationDelegate, GKMatchmakerViewControllerDelegate, GKMatchDelegate, NSURLConnectionDelegate> {
    GKHelperDelegate *delegate;
    UIViewController *presentingViewController;
    NSURLConnection *connection;
    BOOL matchStarted;
}

@property (retain) GKMatch *match;
@property (retain) UIViewController *presentingViewController;
@property (retain) NSMutableDictionary *playersDict;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSMutableDictionary *achievementsDictionary;
@property (nonatomic, strong) NSMutableDictionary *achievementsMetadata;

+ (LJAppDelegate *) sharedInstance;
+ (BOOL)isVersionSupported:(NSString *)version;
- (void)authenticateLocalPlayer;
- (void)loadAchievements;
- (GKAchievement *)getAchievementForIdentifier:(NSString*)identifier;
- (void)reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent;
- (void)retrieveAchievementMetadata;
- (void)resetAchievements;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers 
                 viewController:(UIViewController *)viewController 
                       delegate:(id<LJAppDelegate>)theDelegate;

void uncaughtExceptionHandler(NSException *exception);

@end
