//
//  GKNotification.h
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <QuartzCore/QuartzCore.h>

#define kGKAchievementAnimeTime     0.4f
#define kGKAchievementDisplayTime   1.75f

#define kGKAchievementDefaultSize   CGRectMake(0.0f, 0.0f, 284.0f, 52.0f)
#define kGKAchievementFrameStart    CGRectMake(18.0f, -53.0f, 284.0f, 52.0f)
#define kGKAchievementFrameEnd      CGRectMake(18.0f, 8.0f, 284.0f, 52.0f)

#define kGKAchievementText1         CGRectMake(10.0, 6.0f, 264.0f, 22.0f)
#define kGKAchievementText2         CGRectMake(10.0, 20.0f, 264.0f, 22.0f)
#define kGKAchievementText1WLogo    CGRectMake(45.0, 6.0f, 229.0f, 22.0f)
#define kGKAchievementText2WLogo    CGRectMake(45.0, 20.0f, 229.0f, 22.0f)
#define kGKAchievementLogo          CGRectMake(8.0f, 8.0f, 34.0f, 34.0f)

@protocol GKNotificationDelegate;

@interface GKNotification : UIView
{   
    id<GKNotificationDelegate> _handlerDelegate;
}

@property (nonatomic, retain) id<GKNotificationDelegate> handlerDelegate;

- (id)initWithAchievementDescription:(GKAchievementDescription *)achievement;

- (void)animateIn;
- (void)animateOut;

@end

@protocol GKNotificationDelegate <NSObject>

@optional
- (void)didHideAchievementNotification:(GKNotification *)notification;
- (void)didShowAchievementNotification:(GKNotification *)notification;
- (void)willHideAchievementNotification:(GKNotification *)notification;
- (void)willShowAchievementNotification:(GKNotification *)notification;

@end

@interface GKNotificationHandler : NSObject <GKNotificationDelegate>
{
    NSMutableArray *_queue;
}

+ (GKNotificationHandler *)defaultHandler;
- (void)notifyAchievement:(GKAchievementDescription *)achievement;

@end
