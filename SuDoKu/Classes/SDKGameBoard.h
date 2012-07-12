//
//  SDKGameBoard.h
//
//  Created by Charles-André LEDUC on 18/06/11.
//  Copyright 2011. All rights reserved.
//

#import "SDKSolver.h"
#import "SDKMainViewController.h"

#define MAINLINE_WIDTH      2
#define LINE_WIDTH          1

#define FONT_SIZE_PLAYER    20
#define FONT_SIZE_GAME      18

typedef struct _SDKLine
{
	CGPoint coord[2];
} SDKLine;

typedef enum
{
    SDKDifficultyEasy = 1,
    SDKDifficultyNormal = 2,
    SDKDifficultyHard = 3,
    SDKDifficultyExtreme = 4,
    SDKDifficultyVersus = 5,
    SDKDifficultyNone = 9
} SDKDifficulty;

typedef struct {
    int array[9][9];
    int solutionArray[9][9];
}BoardArray;



@interface SDKMainGrid : UIView
{
    SDKLine *mainLines;
    UIColor *playerColor;
}
- (BOOL)isCaseEditable:(CGPoint)gridCoord;
- (UIColor*)setPlayerColor:(int)play;
@end

@interface SDKGrid : UIView
{
    SDKLine *lines;
}
@end

@interface SDKNumberGrid : UIView
{
    SDKLine *lines;
}
- (UIColor*)setPlayerColor:(int)play;
@property (nonatomic, assign) id delegate;
@end

@interface SDKSelection : UIView
@end

@interface SDKTimerField : UIView
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

@interface SDKGameBoard : UIView <UIAlertViewDelegate>
{
    UILabel *difficultyLabel;
    UILabel *player1Label;
    UILabel *player2Label;
    UIView *scoreBoxView;
    UILabel *player1NameLabel;
    UILabel *player2NameLabel;
    UILabel *player1ScoreLabel;
    UILabel *player2ScoreLabel;
    

    int sentGrid[10][10];
    SDKMainGrid *mainGrid;
    
    SDKSolver *mySolver;
    SDKNumberGrid *numGrid;
    SDKSelection *selectionCase;
    SDKTimerField *timerField;
    SDKTimerField *moveTimerField;
    
    UIView *hintsView;
        
    CGPoint gridLocation;
    
    BOOL bHints;
}
- (id)initWithFrame:(CGRect)rect :(int)value;
- (void)setMultiplayer:(BOOL)value;
- (BOOL)isGameMultiplayer;
- (BOOL)isPlayer1;
- (void)resetScore;
- (void)setPlayer:(int)player;
- (BoardArray) getGameBoard;
- (void)setPlayer2Grid:(BoardArray)board;
- (void)setNewGrid:(SDKDifficulty)diff;
- (void)addNumberOnGrid:(int)num;
- (void)addNumberOnGrid:(int)num :(int)player :(int)xCoord :(int)yCoord :(int)score;
- (BOOL)lastNumberAdded;
- (BOOL)solvePuzzle;
- (void)giveHints;
- (void)resetHints;
- (void)resetGrid:(id)sender;


@end
