//
//  SDKMainViewController.h
//
//  Created by Charles-André LEDUC on 21/06/11.
//  Copyright 2011. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "SDKAppDelegate.h"
#import "SDKGameBoard.h"
#import "SDKFlipViewController.h"


typedef enum {
    kGameStateWaitingForMatch = 0,
    kGameStateWaitingForRandomNumber,
    kGameStateWaitingForBoard,
    kGameStateWaitingForStart,
    kGameStateActive,
    kGameStateDone
} GameState;

typedef enum {
    kEndReasonWin,
    kEndReasonLose,
    kEndReasonDisconnect
} EndReason;

typedef enum {
    kMessageTypeRandomNumber = 0,
    kMessageTypeGameBegin,
    kMessageTypeMove,
    kMessageTypeGameOver,
    kMessageTypeGameBoard
} MessageType;

typedef struct {
    MessageType messageType;
    int moveNumber;
    int xCoord;
    int yCoord;
    int score;
    int player;
    int turnNumber;
} Message;

typedef struct {
    Message message;
    uint32_t randomNumber;
} MessageRandomNumber;

typedef struct {
    Message message;
    int sentGrid[9][9];
    int sentSolutionGrid[9][9];
} MessageGameBegin;

typedef struct {
    Message message;
} MessageMove;

typedef struct {
    Message message;
    BOOL player1Won;
} MessageGameOver;

@protocol TOTouchUIViewDelegate

- (void) uiViewTouched:(BOOL)wasInside;

@end

@interface TOTouchUIView : UIView 

// Properties
@property (nonatomic, assign) id delegate;

@end


@interface SDKMainViewController : UIViewController <UIAlertViewDelegate, GKAchievementViewControllerDelegate, SDKFlipViewControllerDelegate, NSURLConnectionDelegate, TOTouchUIViewDelegate>

{    
    UIView *containerView;
    UIView *mainMenu;
    SDKGameBoard *gameBoard;
    UIAlertView *alertWithOkButton;
    uint32_t ourRandom;   
    BOOL receivedRandom;    
    NSString *otherPlayerID;
    GameState gameState;
    NSURLConnection *connection;
}
@property ( nonatomic , strong ) TOTouchUIView * touchView;

+ (SDKMainViewController *)sharedController;

- (void)clear;
- (void)startGame:(id)sender;
- (void)doneGame:(id)sender;
- (void)matchStarted;
- (void)sendMove:(int)xCoord :(int)yCoord :(int)moveNum :(int)player :(int)turnNumber :(int)score;
- (void)presentViewController:(id)sender;
- (void)setNeedsDisplay;
- (void)showAchievements:(id)sender;
- (void)showMultiplayer:(id)sender;
- (void)userClickFooter:(id) sender;
- (void)closePopUpView;
- (void) sendInfo;
- (void) setRegistered:(BOOL)registered;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

@end
