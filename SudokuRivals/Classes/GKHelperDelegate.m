//
//  GKHelperDelegate.m
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GKHelperDelegate.h"
#import "LJMainViewController.h"

@implementation GKHelperDelegate

@synthesize match;
@synthesize playersDict;

static int gameStateChange = 0;
static GKHelperDelegate *sharedHelper = nil;
+ (GKHelperDelegate *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GKHelperDelegate alloc] init];
    }
    return sharedHelper;
}

#pragma mark GKMatchDelegate


// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {   
    match = theMatch;
    
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
                alertDisconnectQuit = [[UIAlertView alloc] initWithTitle:@"Disconnected"
                                                                   message:@"Your opponent has disconnected. Would you like to quit?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                gameStateChange =1;
            }
            [alertDisconnectQuit show];
            matchStarted = NO;
            [self matchEnded];
            break;
    }                     
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    
    if (match != theMatch) return;
    
    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
    matchStarted = NO;
    [self matchEnded];
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)theMatch didFailWithError:(NSError *)error {
    
    if (match != theMatch) return;
    
    NSLog(@"Match failed with error: %@", error.localizedDescription);
    matchStarted = NO;
    [self matchEnded];
}

- (void)alertView : (UIAlertView *)alertView clickedButtonAtIndex : (NSInteger)buttonIndex
{
    if(alertView == alertDisconnectQuit)
    {
        if(buttonIndex == 0)
        {
            NSLog(@"no button was pressed\n");
        }
        else
        {
            [[LJMainViewController sharedController] clear];
        }
    }
}


- (void)matchStarted {    
    NSLog(@"Match started");
    
    ourRandom = arc4random();
    [self sendRandomNumber];
    [self setGameState:kGameStateWaitingForMatch];
    if (receivedRandom) {
        [self setGameState:kGameStateWaitingForStart];
    } else {
        [self setGameState:kGameStateWaitingForRandomNumber];
    }
    gameBoardController = [LJMainViewController sharedController];
}

- (void)matchEnded {    
    NSLog(@"Match ended");    
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    
    if (otherPlayerID == nil) { otherPlayerID = playerID; }
    
    Message *message = (Message *) [data bytes];
    if (message->messageType == kMessageTypeRandomNumber) {
        MessageRandomNumber * messageInit = (MessageRandomNumber *) [data bytes];
        bool tie = false;
        
        if (messageInit->randomNumber == ourRandom){
            tie = true;
            ourRandom = arc4random();
            [self sendRandomNumber];
        } else if (ourRandom > messageInit->randomNumber){
            NSLog(@"Starting game as Player 1");

            [[gameBoardController retrieveGameBoard] setPlayer:1];            
            [self setGameState:kGameStateWaitingForStart];
            [self tryStartGame];
        } else {
            NSLog(@"Acting as Player 2, waiting for board and game start command");
            
        }
        
        if (!tie) {
            receivedRandom = YES;    
            if (gameState == kGameStateWaitingForRandomNumber) {
                [self setGameState:kGameStateWaitingForStart];
            }      
        }
        
    } else if (message->messageType == kMessageTypeGameBegin) {        
        
        MessageGameBegin * messageInit = (MessageGameBegin *) [data bytes];
        BoardArray board;
        for(int i = 0; i <9; i++){
            for(int j= 0; j < 9; j++){
                board.array[i][j] = messageInit->sentGrid[i][j];
                board.solutionArray[i][j] = messageInit->sentSolutionGrid[i][j];
            }
        }
        
        [gameBoardController startMultiplayerGame:2 :board];
        [[gameBoardController retrieveGameBoard] setPlayer:2];
        
        [self setGameState:kGameStateActive];
        
    } else if (message->messageType == kMessageTypeMove) {
        MessageMove * messageMove = (MessageMove *) [data bytes];
        [[gameBoardController retrieveGameBoard] addNumberOnGrid:messageMove->moveNumber :messageMove->player :messageMove->xCoord :messageMove->yCoord :messageMove->score];
    } 
    else if (message -> messageType == kMessageTypeGameBoard){
        
    }
    else if (message -> messageType == kMessageTypeGameOver){
        MessageGameOver * messageGameOver = (MessageGameOver *) [data bytes];
        NSLog(@"Received game over message");
        if(messageGameOver->winner == 1){ NSLog (@"Player 1 wins");}
            else if (messageGameOver->winner == 2) {NSLog(@"Player 2 wins");}
                else { NSLog(@"Nobody wins, Everybody loses");}
    }             
}

- (void)lookupPlayers {
    
    NSLog(@"Looking up %d players...", match.playerIDs.count);
    [GKPlayer loadPlayersForIdentifiers:match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        
        if (error != nil) {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
            matchStarted = NO;
            [self matchEnded];
        } else {
            
            // Populate players dict
            self.playersDict = [NSMutableDictionary dictionaryWithCapacity:players.count];
            for (GKPlayer *player in players) {
                NSLog(@"Found player: %@", player.alias);
                [playersDict setObject:player forKey:player.playerID];
            }
            
            // Notify delegate match can begin
            matchStarted = YES;
            [[GKHelperDelegate sharedInstance] matchStarted];
            
        }
    }];
    
}

- (void)setGameState:(GameState)state {
    
    gameState = state;
    if (gameState == kGameStateWaitingForMatch) {
        //[debugLabel setString:@"Waiting for match"];
    } else if (gameState == kGameStateWaitingForRandomNumber) {
        //[debugLabel setString:@"Waiting for rand #"];
    } else if (gameState == kGameStateWaitingForStart) {
        //[debugLabel setString:@"Waiting for start"];
    } else if (gameState == kGameStateActive) {
        //[debugLabel setString:@"Active"];
    } else if (gameState == kGameStateDone) {
        //[debugLabel setString:@"Done"];
    } 
    
}


- (void)sendData:(NSData *)data {
    NSError *error;
    BOOL success = [[LJAppDelegate sharedInstance].match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (!success) {
        [self matchEnded];
    }
}

- (void)sendRandomNumber {
    
    MessageRandomNumber message;
    message.message.messageType = kMessageTypeRandomNumber;
    message.randomNumber = ourRandom;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];    
    [self sendData:data];
    [self setGameState:kGameStateWaitingForRandomNumber];
}


- (void)sendMove:(int)x yCoordinate:(int)y placedNumber:(int)num fromPlayer:(int)player turnNumber:(int)turnNumber score:(int)score{
    MessageMove message;
    message.message.messageType = kMessageTypeMove;
    message.xCoord = x;
    message.yCoord = y;
    message.player = player;
    message.turnNumber = turnNumber;
    message.score = score;
    message.moveNumber = num;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageMove)];    
    [self sendData:data];    
}


- (void)sendGameBegin {
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    BoardArray board = [[gameBoardController retrieveGameBoard] getGameBoard];
    for(int i = 0; i < 9;i++){
        for(int j = 0; j < 9; j++){
            message.sentGrid[i][j] = board.array[i][j];
        }
    }
    for(int i = 0; i < 9;i++){
        for(int j = 0; j < 9; j++){
            message.sentSolutionGrid[i][j] = board.solutionArray[i][j];
        }
    }
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)];
    [self setGameState:kGameStateActive];
    [self sendData:data];
}

- (void)tryStartGame {
    
    if ([[gameBoardController retrieveGameBoard] isPlayer1] && gameState == kGameStateWaitingForStart) {
        BoardArray board;
        [gameBoardController startMultiplayerGame:1 :board];
        [self sendGameBegin];
    }
}

@end
