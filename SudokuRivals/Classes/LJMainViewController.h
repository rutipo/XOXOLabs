//
//  LJMainViewController.h
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "LJSDKGameBoard.h"
#import "LJFlipViewController.h"

@class LJSDKGameBoard;

@interface LJMainViewController : UIViewController <UIAlertViewDelegate, GKAchievementViewControllerDelegate, LJFlipViewControllerDelegate>
{
    UIView *containerView;
    UIView *mainMenu;
    
    LJSDKGameBoard *gameBoard;
    UIAlertView *alertGameStarting;
}

+ (LJMainViewController *)sharedController;
- (void) clear;
- (void) startGame:(id)sender;
- (void) startMultiplayerGame:(int)player :(BoardArray)board;
- (void) presentViewController:(id)sender;
- (void) setNeedsDisplay;
- (void) doneGame:(id)sender;
- (void) showAchievements:(id)sender;
- (void) showMultiplayer:(id)sender;
- (void) showStore:(id)sender;
- (LJSDKGameBoard *) retrieveGameBoard;

@end
