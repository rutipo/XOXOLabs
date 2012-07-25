//
//  GKHelperDelegate.h
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <GameKit/GameKit.h>



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
    int moveNumber;
    int xCoord;
    int yCoord;
    int score;
    int player;
    int turnNumber;
} MessageMove;

typedef struct {
    Message message;
    int winner;
} MessageGameOver;

@class LJMainViewController;

@interface GKHelperDelegate : NSObject<GKMatchDelegate, UIAlertViewDelegate>{
    BOOL matchStarted;
    uint32_t ourRandom;
    BOOL receivedRandom;
    NSString *otherPlayerID;
    GameState gameState;
    UIAlertView *alertDisconnectQuit;
    GKMatch *match;
    NSMutableDictionary *playersDict;
    LJMainViewController *gameBoardController;
}
@property (retain) GKMatch *match;
@property (retain) NSMutableDictionary *playersDict;

+ (GKHelperDelegate *) sharedInstance;
-(void)matchStarted;
-(void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
-(void)lookupPlayers;
-(void)setGameState:(GameState)state;
-(void)sendData:(NSData *)data;
-(void)sendRandomNumber;
-(void)sendGameBegin;
-(void)sendMove:(int)x yCoordinate:(int)y placedNumber:(int)num fromPlayer:(int)player turnNumber:(int)turnNumber score:(int)score;

@end
