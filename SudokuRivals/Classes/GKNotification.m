//
//  GKNotification.m
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GKNotification.h"
#import "LJAppDelegate.h"
//#import "SDKMainViewController.h"

static GKNotificationHandler *defaultHandler = nil;

@interface GKNotification(private)
- (void)animationInDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)animationOutDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
@end

@interface GKNotificationHandler(private)
- (void)displayNotification:(GKNotification *)notification;
@end

#pragma mark GKNotificationHandler

@implementation GKNotificationHandler

#pragma mark - Singleton

+ (GKNotificationHandler *)defaultHandler
{
    if (!defaultHandler) defaultHandler = [[self alloc] init];
    return defaultHandler;
}

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self)
    {
        _queue = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Notifications

- (void)notifyAchievement:(GKAchievementDescription *)achievement
{
    GKNotification *notification = [[GKNotification alloc] initWithAchievementDescription:achievement];
    notification.frame = kGKAchievementFrameStart;
    notification.handlerDelegate = self;
    
    [_queue addObject:notification];
    if ([_queue count] == 1)
    {
        [self displayNotification:notification];
    }
}

- (void)didHideAchievementNotification:(GKNotification *)notification
{
    [_queue removeObjectAtIndex:0];
    if ([_queue count] > 0)
    {
        [self displayNotification:(GKNotification *)[_queue objectAtIndex:0]];
    }
}

@end

#pragma mark - GKNotification

@implementation GKNotification

@synthesize handlerDelegate=_handlerDelegate;

#pragma mark - Init

- (id)initWithAchievementDescription:(GKAchievementDescription *)achievement
{
    self = [super initWithFrame:kGKAchievementDefaultSize];
    if (self)
    {
        self.opaque = NO;
        self.layer.shadowOffset = CGSizeMake(0, 4);
        self.layer.shadowRadius = 4.0f;        
        self.layer.shadowOpacity = 0.6;        
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        
        // create the text label
        UILabel *textLabel = [[UILabel alloc] initWithFrame:kGKAchievementText1];
        textLabel.textAlignment = UITextAlignmentCenter;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f];
        textLabel.text = NSLocalizedString(@"Achievement Unlocked", @"Achievemnt Unlocked Message");
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:kGKAchievementText2];
        detailLabel.textAlignment = UITextAlignmentCenter;
        detailLabel.adjustsFontSizeToFitWidth = YES;
        detailLabel.minimumFontSize = 10.0f;
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.textColor = [UIColor whiteColor];
        detailLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
        
        UIImageView *logo = [[UIImageView alloc] initWithFrame:kGKAchievementLogo];
        logo.contentMode = UIViewContentModeScaleToFill;
        
        if (achievement)
        {
            textLabel.text = achievement.title;
            detailLabel.text = achievement.achievedDescription;
            
            if (achievement.image)
            {
                textLabel.frame = kGKAchievementText1WLogo;
                detailLabel.frame = kGKAchievementText2WLogo;
                
                logo.image = achievement.image;
                
            }
            else
                logo.image = [UIImage imageNamed:@"Achievement"];
            
            [self addSubview:logo];
        }
        else
        {
            textLabel.text = NSLocalizedString(@"Achievement Unlocked", @"Achievemnt Unlocked Message");
            detailLabel.text = @"";
        }
        
        [self addSubview:textLabel];
        [self addSubview:detailLabel];
        
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
	CGContextSetAllowsAntialiasing(context, true);
	CGContextSetAlpha(context, 0.5); 
	CGContextSetLineWidth(context, 1.0);
	CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    
    // Draw background
	CGFloat backOffset = 2.0f;
    CGFloat radius = 4.0f;
	CGRect backRect = CGRectMake(rect.origin.x + backOffset, 
                                 rect.origin.y + backOffset, 
                                 rect.size.width - backOffset*2, 
                                 rect.size.height - backOffset*2);
    
    CGContextBeginPath (context);
    
	CGFloat minx = CGRectGetMinX(backRect), midx = CGRectGetMidX(backRect), 
    maxx = CGRectGetMaxX(backRect);
    
	CGFloat miny = CGRectGetMinY(backRect), midy = CGRectGetMidY(backRect), 
    maxy = CGRectGetMaxY(backRect);
    
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    
	CGContextClosePath(context);
    
    CGContextDrawPath(context, kCGPathFillStroke);
}

#pragma mark - Animations

- (void)animateIn
{
    if ([self.handlerDelegate respondsToSelector:@selector(willShowAchievementNotification:)])
        [self.handlerDelegate willShowAchievementNotification:self];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kGKAchievementAnimeTime];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDidStopSelector:@selector(animationInDidStop:finished:context:)];
    self.frame = kGKAchievementFrameEnd;
    [UIView commitAnimations];
}

- (void)animateOut
{
    if ([self.handlerDelegate respondsToSelector:@selector(willHideAchievementNotification:)])
        [self.handlerDelegate willHideAchievementNotification:self];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kGKAchievementAnimeTime];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDidStopSelector:@selector(animationOutDidStop:finished:context:)];
    self.frame = kGKAchievementFrameStart;
    [UIView commitAnimations];
}

@end

#pragma mark - Private Functions

@implementation GKNotificationHandler(private)

- (void)displayNotification:(GKNotification *)notification
{
    LJAppDelegate *delegateApp = (LJAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIWindow *window = delegateApp.window;
    
    if (window)
    {
        [window.rootViewController.view addSubview:notification];
        [notification animateIn];
    }
}

@end

@implementation GKNotification(private)

- (void)animationInDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([self.handlerDelegate respondsToSelector:@selector(didShowAchievementNotification:)])
        [self.handlerDelegate didShowAchievementNotification:self];
    
    [self performSelector:@selector(animateOut) withObject:nil afterDelay:kGKAchievementDisplayTime];
}

- (void)animationOutDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([self.handlerDelegate respondsToSelector:@selector(didHideAchievementNotification:)])
        [self.handlerDelegate didHideAchievementNotification:self];
    
    [self removeFromSuperview];
}

@end
