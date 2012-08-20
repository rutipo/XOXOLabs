//
//  LJMainViewController.m
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "LJMainViewController.h"
#import "LJFlipViewController.h"
#import "LJAppDelegate.h"
#import "LJSDKGameBoard.h"
#import "LJPopupView.h"
#import "LoopJoyStore.h"



@interface LJMainViewController (Private)
- (void)replaceOldView:(UIView *)oldView withSubView:(UIView *)newView transition:(UIViewAnimationTransition)transition duration:(CFTimeInterval)duration;
- (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title image:(NSString *)keyPath font:(UIFont *)font textColor:(UIColor *)color target:(id)obj action:(SEL)action;
@end

@implementation LJMainViewController

#pragma mark - Singleton
static LJMainViewController *_sharedController = nil;

+ (LJMainViewController *)sharedController
{
    if (!_sharedController)
        _sharedController = [[LJMainViewController alloc] init];
    
    return _sharedController;
}

#pragma mark - Actions

- (LJSDKGameBoard *)retrieveGameBoard{
    return gameBoard;
}

- (void)startGame:(id)sender
{        
    [self replaceOldView:mainMenu withSubView:gameBoard transition:UIViewAnimationTransitionCurlUp duration:.5];
    
    [gameBoard setNewGrid:[sender tag]];
}


- (void)startMultiplayerGame:(int)player :(BoardArray)gameBoardArray
{   
    gameBoard = nil;
    gameBoard = [[LJSDKGameBoard alloc] initMultiWithFrame:mainMenu.frame];
    [gameBoard setMultiplayer:true];
    
    [self replaceOldView:mainMenu withSubView:gameBoard transition:UIViewAnimationTransitionCurlUp duration:.5];
    [gameBoard setNewGrid:LJSDKDifficultyVersus];
    [gameBoard resetScore];
    
    if(2 == player){[gameBoard setPlayer2Grid:gameBoardArray];}

    NSString *messageString = [NSString stringWithFormat:@"You are player %d", player]; 
    
    alertGameStarting = [[UIAlertView alloc]
                         initWithTitle: @"Game Starting!"
                         message: messageString
                         delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
    [alertGameStarting show];
}

- (void)doneGame:(id)sender
{
    if (![sender isKindOfClass:[UIAlertView class]])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Main Menu",@"Main Menu") message:NSLocalizedString(@"Would you like to quit the current puzzle?",@"Main Menu Alert Message") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") otherButtonTitles:NSLocalizedString(@"OK",@"OK"),nil];
        [alert show];
    }
    else
        [self replaceOldView:gameBoard withSubView:mainMenu transition:UIViewAnimationTransitionCurlDown duration:.4];
}

- (void)showMultiplayer:(id)sender
{
    [[LJAppDelegate sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self delegate:(id)[GKHelperDelegate sharedInstance]];
}

- (void)showStore:(id)sender{
    //[containerView addSubview:[[LJStorePopUpView alloc] initWithFrame:mainMenu.frame]];
}

- (void)showAchievements:(id)sender
{
    
    
    GKAchievementViewController *controller = [[GKAchievementViewController alloc] init];
    if (controller != nil)
    {
        controller.achievementDelegate = self;
        
        if ([LJAppDelegate isVersionSupported:@"5.0"])
            [self presentViewController:controller animated:YES completion:NULL];
        else
            [self presentModalViewController:controller animated: YES];
    }
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    if ([LJAppDelegate isVersionSupported:@"5.0"])
        [self dismissViewControllerAnimated:YES completion:NULL];
    else
        [self dismissModalViewControllerAnimated:YES];
}

- (void)flipViewControllerDidFinish:(UIViewController *)viewController
{
    if ([LJAppDelegate isVersionSupported:@"5.0"])
        [self dismissViewControllerAnimated:YES completion:NULL];
    else
        [self dismissModalViewControllerAnimated:YES];
}

- (void)presentViewController:(id)sender
{
    LJFlipViewController *controller;
    
    if ([sender tag] == 1)
        controller = [[LJPrefsViewController alloc] init];
    else
        controller = [[LJRulesViewController alloc] init];
    
    controller.delegate = self;
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:controller action:@selector(done:)];
    controller.navigationItem.rightBarButtonItem = doneItem;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 2);
    navigationController.navigationBar.layer.shadowOpacity = 0.6;
    navigationController.navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:navigationController.navigationBar.bounds].CGPath;
    navigationController.navigationBar.tintColor = [UIColor blackColor];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    if ([LJAppDelegate isVersionSupported:@"5.0"])
        [self presentViewController:navigationController animated:YES completion:NULL];
    else
        [self presentModalViewController:navigationController animated:YES];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        [self replaceOldView:gameBoard withSubView:mainMenu transition:UIViewAnimationTransitionCurlDown duration:.4];
}

-(void)clear{
    [self replaceOldView:gameBoard withSubView:mainMenu transition:UIViewAnimationTransitionCurlDown duration:.4];
}

#pragma mark - View Lifecycle

- (void)loadView
{    
    [super loadView];
    
    CGFloat offsetX = 20;
    CGFloat offsetY = 32;
    CGFloat shadOffset = 4;
    CGFloat titleFontSize = 17.0;
    CGFloat buttonFontSize = 14.0;
    CGFloat buttonWidth = 150;
    CGFloat gcButtonSize = 32;
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect containerRect = CGRectMake(self.view.frame.size.width/2-(screenRect.size.width-offsetX)/2, -4, screenRect.size.width-offsetX, screenRect.size.height-offsetY);
    CGRect ribbonRect = CGRectMake(16, 0, 32, 256);
    CGRect titleRect = CGRectMake(containerRect.size.width/2-60, 44, 120, 64);
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        titleFontSize = 32.0;
        buttonFontSize = 24.0;
        buttonWidth *= 2;
        offsetX *= 2;
        offsetY *= 2;
        shadOffset *= 3;
        ribbonRect = CGRectMake(32, 0, 128, 512);
        titleRect = CGRectMake(containerRect.size.width/2-120, 96, 240, 128);
        gcButtonSize *= 2;
    }
    
    containerView = [[UIView alloc] initWithFrame:containerRect];
    containerView.backgroundColor= [UIColor clearColor];
    
    NSString *bgString = [[NSUserDefaults standardUserDefaults] objectForKey:UI_BG];
    UIImage *bgImage = [UIImage imageNamed:bgString];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.view.layer.contents = (id)bgImage.CGImage;
    
    mainMenu = [[UIView alloc] initWithFrame:containerView.bounds];
    mainMenu.backgroundColor= [UIColor clearColor];
    
    NSString *imageString = [[NSUserDefaults standardUserDefaults] objectForKey:UI_PAPER];
    UIImage *menuImage = [UIImage imageNamed:imageString];
    
    mainMenu.layer.contents = (id)menuImage.CGImage;
    mainMenu.layer.masksToBounds = NO;
    mainMenu.layer.shadowOffset = CGSizeMake(0, shadOffset);
    mainMenu.layer.shadowOpacity = 0.5;    
    mainMenu.layer.shadowPath = [UIBezierPath bezierPathWithRect:mainMenu.bounds].CGPath;
    
    UIImageView *titleImage = [[UIImageView alloc] initWithFrame:titleRect];
    [titleImage setImage:[UIImage imageNamed:@"Sudoku"]];
    
    UIButton *gameCenterButton = [self createButtonWithFrame:CGRectMake(mainMenu.frame.origin.x+mainMenu.frame.size.width-(gcButtonSize+16),16,gcButtonSize,gcButtonSize) title:nil image:@"GC" font:nil textColor:nil target:self action:@selector(showAchievements:)];
    gameCenterButton.layer.masksToBounds = NO;
    gameCenterButton.layer.shadowOffset = CGSizeMake(0, 1);
    gameCenterButton.layer.shadowOpacity = 0.75;    
    gameCenterButton.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:gameCenterButton.bounds cornerRadius:gcButtonSize/8].CGPath;
    
    [mainMenu addSubview:gameCenterButton];
    
    UIFont *mainLabelFont = [UIFont fontWithName:@"Japanese Brush" size:titleFontSize];
    UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleRect.origin.y+titleRect.size.height+16, mainMenu.frame.size.width, mainLabelFont.lineHeight+4)];
    mainLabel.backgroundColor = [UIColor clearColor];
    mainLabel.textAlignment = UITextAlignmentCenter;
    mainLabel.text = NSLocalizedString(@"New Puzzle",@"New Puzzle");
    mainLabel.font = mainLabelFont;
    
    NSArray *buttonsKeyArray = [NSArray arrayWithObjects:@"Beginner",@"Casual",@"Expert",@"Master",@"Multiplayer",nil];
    NSArray *imageKeyArray = [NSArray arrayWithObjects:@"Kanji_Dream",@"Kanji_Hope",@"Kanji_Protect",@"Kanji_Truth",@"Kanji_Dream",nil];
    
    UIFont *buttonFont = [UIFont fontWithName:@"Japanese Brush" size:buttonFontSize];
    UIColor *buttonColor = [UIColor colorWithRed:0.1 green:0.25 blue:0.4 alpha:1.0];
    CGFloat heightBtn = buttonFont.lineHeight*1.2;
    CGFloat startHeight = mainLabel.frame.origin.y+mainLabel.frame.size.height+heightBtn/2;
    NSUInteger testIndex = [buttonsKeyArray indexOfObject:[buttonsKeyArray lastObject]];
    
    for (NSString *buttonKey in buttonsKeyArray)
    {
        
        NSUInteger index = [buttonsKeyArray indexOfObject:buttonKey];
        if(testIndex == index){
            CGFloat offsetY = startHeight+index*(heightBtn*1.5);
            
            UIButton *button = [self createButtonWithFrame:CGRectMake(mainMenu.frame.size.width/2-buttonWidth/2+8, offsetY, buttonWidth, heightBtn) title:buttonKey image:nil font:buttonFont textColor:buttonColor target:self action:@selector(showMultiplayer:)];
            button.tag = index+1;
            
            UIImage *icon = [UIImage imageNamed:[imageKeyArray objectAtIndex:index]];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(button.frame.origin.x-4, button.frame.origin.y, heightBtn, heightBtn)];
            imageView.image = icon;
            
            [mainMenu addSubview:imageView];
            [mainMenu addSubview:button];
        }
        else{
            
            CGFloat offsetY = startHeight+index*(heightBtn*1.5);
            
            UIButton *button = [self createButtonWithFrame:CGRectMake(mainMenu.frame.size.width/2-buttonWidth/2+8, offsetY, buttonWidth, heightBtn) title:buttonKey image:nil font:buttonFont textColor:buttonColor target:self action:@selector(startGame:)];
            button.tag = index+1;
            
            UIImage *icon = [UIImage imageNamed:[imageKeyArray objectAtIndex:index]];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(button.frame.origin.x-4, button.frame.origin.y, heightBtn, heightBtn)];
            imageView.image = icon;
            
            [mainMenu addSubview:imageView];
            [mainMenu addSubview:button];
        }
    }
    
    
    
    UIFont *otherButtonFont = [UIFont fontWithName:@"Japanese Brush" size:buttonFontSize+2];
    UIButton *rulesButton = [self createButtonWithFrame:CGRectMake(mainMenu.frame.size.width/2-buttonWidth/2, mainMenu.frame.size.height-otherButtonFont.lineHeight*3, buttonWidth, otherButtonFont.lineHeight*1.5) title:@"Rules" image:nil font:otherButtonFont textColor:[UIColor blackColor] target:self action:@selector(presentViewController:)];
    rulesButton.tag = 0;
    
    [mainMenu addSubview:rulesButton];
    
    UIButton *prefsButton = [self createButtonWithFrame:CGRectMake(mainMenu.frame.size.width/2-buttonWidth/2, rulesButton.frame.origin.y-otherButtonFont.lineHeight*2, buttonWidth, otherButtonFont.lineHeight*1.5) title:@"Settings" image:nil font:otherButtonFont textColor:[UIColor blackColor] target:self action:@selector(presentViewController:)];
    prefsButton.tag = 1;
    
    [mainMenu addSubview:prefsButton];
    UIButton *buyNow;
    UIButton *buyLater;
    [LoopJoyStore initWithDevID:@"18" forEnv:LJ_ENV_LIVE];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        buyNow = [[LoopJoyStore sharedInstance] getLJButtonForItem:18 withButtonType:LJ_BUTTON_IPAD_YELLOW];
        buyLater = [[LoopJoyStore sharedInstance] getLJButtonForItem:17 withButtonType:LJ_BUTTON_IPAD_RED];
        UIAlertView *ljAlert = [[LoopJoyStore sharedInstance] getLJAlertForItem:18 withTitle:@"You just unlocked a new hat" andMessage:@"You're such a good sport"];
        [ljAlert show];
        
//        CGRect frame = buyNow.frame;
//        frame.size = CGSizeMake(99, 136);
//        frame.origin.x = mainMenu.frame.origin.x + 550;
//        frame.origin.y = mainMenu.frame.size.height-250; //
//        buyNow.frame = frame;
        [mainMenu addSubview:buyNow];
        
//        CGRect frame2 = buyLater.frame;
//        frame2.size = CGSizeMake(99, 136);
//        frame2.origin.x = mainMenu.frame.origin.x + 550;
//        frame2.origin.y = mainMenu.frame.size.height-150; //
//        buyLater.frame = frame2;
//        [mainMenu addSubview:buyLater];
     //   buyNow = [self createButtonWithFrame:CGRectMake(mainMenu.frame.origin.x + 10, mainMenu.frame.size.height-250, (85) * 3, (75) * 3) title:nil image:@"buynowlarge.png" font:otherButtonFont textColor:[UIColor blackColor] target:self action:@selector(showStore:)];
    }
    else{
        buyNow = [[LoopJoyStore sharedInstance] getLJButtonForItem:18 withButtonType:LJ_BUTTON_IPHONE_YELLOW];
        
        CGRect frame = buyNow.frame;
        frame.size = CGSizeMake(40, 120);
//        frame.origin.x = mainMenu.frame.origin.x + 10;
//        frame.origin.y = mainMenu.frame.size.height - 110; //
        buyNow.frame = frame;
        [mainMenu addSubview:buyNow];
        //buyNow = [self createButtonWithFrame:CGRectMake(mainMenu.frame.origin.x + 10, mainMenu.frame.size.height - 110, 85, 75) title:nil image:@"buynow.png" font:otherButtonFont textColor:[UIColor blackColor] target:self action:@selector(showStore:)];
    }

    
    
    [mainMenu addSubview:mainLabel];
    [mainMenu addSubview:titleImage];
    
    UIImageView *ribbonView = [[UIImageView alloc] initWithFrame:ribbonRect];
    [ribbonView setImage:[UIImage imageNamed:@"Ribbon"]];        
    [mainMenu addSubview:ribbonView];
    
    gameBoard = [[LJSDKGameBoard alloc] initWithFrame:mainMenu.frame];
    
    imageString = [imageString stringByReplacingOccurrencesOfString:@"_main" withString:@""];
    UIImage *gameImage = [UIImage imageNamed:imageString];
    
    gameBoard.backgroundColor= [UIColor clearColor];
    gameBoard.layer.contents = (id)gameImage.CGImage;
    gameBoard.layer.masksToBounds = NO;
    gameBoard.layer.shadowOffset = CGSizeMake(0, shadOffset);
    gameBoard.layer.shadowOpacity = mainMenu.layer.shadowOpacity;    
    gameBoard.layer.shadowPath = [UIBezierPath bezierPathWithRect:gameBoard.bounds].CGPath;
    
    [containerView addSubview:mainMenu];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[containerView addSubview:[[LJPopupView alloc] initWithFrame:mainMenu.frame]];
    //[containerView addSubview:[[LJStorePopUpView alloc] initWithFrame:mainMenu.frame]];
    
    [self.view addSubview:containerView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    mainMenu = nil;
    gameBoard = nil;
    containerView = nil;
}

- (void)setNeedsDisplay
{
    NSString *bgString = [[NSUserDefaults standardUserDefaults] objectForKey:UI_BG];
    UIImage *bgImage = [UIImage imageNamed:bgString];
    self.view.layer.contents = (id)bgImage.CGImage;
    
    NSString *imageString = [[NSUserDefaults standardUserDefaults] objectForKey:UI_PAPER];
    UIImage *menuImage = [UIImage imageNamed:imageString];
    mainMenu.layer.contents = (id)menuImage.CGImage;
    
    imageString = [imageString stringByReplacingOccurrencesOfString:@"_main" withString:@""];
    UIImage *gameImage = [UIImage imageNamed:imageString];
    gameBoard.layer.contents = (id)gameImage.CGImage;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private functions

- (void)replaceOldView:(UIView *)oldView withSubView:(UIView *)newView transition:(UIViewAnimationTransition)transition duration:(CFTimeInterval)duration
{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:duration];
	[UIView setAnimationTransition:transition forView:containerView cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
	[oldView removeFromSuperview];
    [containerView addSubview:newView];
	
	[UIView commitAnimations];
}

- (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title image:(NSString *)keyPath font:(UIFont *)font textColor:(UIColor *)color target:(id)obj action:(SEL)action
{
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    aButton.frame = frame;
    aButton.backgroundColor = [UIColor clearColor];
    
    if (keyPath)
    {
        UIImage *image = [UIImage imageNamed:keyPath];
        [aButton setImage:image forState:UIControlStateNormal];
    }
    
    [aButton addTarget:obj action:action forControlEvents:UIControlEventTouchDown];
    
    if (title)
    {
        [aButton setTitle:NSLocalizedString(title, title) forState:UIControlStateNormal];
        [aButton setTitleColor:color forState:UIControlStateNormal];
        aButton.titleLabel.textColor = color;
        aButton.titleLabel.font = font;
    }
    
    return aButton;
}

@end