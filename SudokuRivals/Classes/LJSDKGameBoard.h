//
//  LJSDKGameBoard.h
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LJSDKSolver.h"
#import "LJAppDelegate.h"




typedef struct _LJSDKLine
{
	CGPoint coord[2];
} LJSDKLine;

typedef enum
{
    LJSDKDifficultyEasy = 1,
    LJSDKDifficultyNormal = 2,
    LJSDKDifficultyHard = 3,
    LJSDKDifficultyExtreme = 4,
    LJSDKDifficultyVersus = 5,
    LJSDKDifficultyNone = 9
} LJSDKDifficulty;

typedef struct {
    int array[9][9];
    int solutionArray[9][9];
}BoardArray;


@interface LJSDKMainGrid : UIView{
    LJSDKLine *mainLines;
}

- (BOOL)isCaseEditable:(CGPoint)gridCoord;
@end

@interface LJSDKGrid : UIView
{
    LJSDKLine *lines;
}
@end

@interface LJSDKNumberGrid : UIView
{
    LJSDKLine *lines;
}
@property (nonatomic, assign) id delegate;
@end


@interface LJSDKSelection :UIView
@end

@interface LJSDKTimerField : UIView
{
    BOOL isRunning;
    BOOL gameClock;
    float time;
    NSDate *refDate;
    NSDateFormatter *formatter;
    NSCalendar *gregorian;
    UILabel *mainLabel;
}
@property (assign) BOOL isRunning;
@property (assign) BOOL gameClock;
@property (assign) float time;
- (void)restart;
- (void)formatTime;
@end


@interface LJSDKGameBoard : UIView <UIAlertViewDelegate>
{
    UIView *scoreBoxView;
    UILabel *difficultyLabel;
    UILabel *player1Label;
    UILabel *player2Label;
    UILabel *player1NameLabel;
    UILabel *player2NameLabel;
    UILabel *player1ScoreLabel;
    UILabel *player2ScoreLabel;
    
    
    int sentGrid[10][10];
    LJSDKMainGrid *mainGrid;
    
    LJSDKSolver *mySolver;
    LJSDKNumberGrid *numGrid;
    LJSDKSelection *selectionCase;
    LJSDKTimerField *timerField;
    LJSDKTimerField *moveTimerField;
    
    UIView *hintsView;
    
    CGPoint gridLocation;
    
    BOOL bHints;
}
- (id)initMultiWithFrame:(CGRect)rect;
- (void)setMultiplayer:(BOOL)value;
- (BOOL)isPlayer1;
- (void)resetScore;
- (void)setPlayer:(int)player;
- (BoardArray) getGameBoard;
- (void)setPlayer2Grid:(BoardArray)board;
- (void)setNewGrid:(LJSDKDifficulty)diff;
- (void)addNumberOnGrid:(int)num;
- (void)addNumberOnGrid:(int)num :(int)player :(int)xCoord :(int)yCoord :(int)score;
- (BOOL)lastNumberAdded;
- (BOOL)solvePuzzle;
- (void)giveHints;
- (void)resetHints;
- (void)resetGrid:(id)sender;


@end



























