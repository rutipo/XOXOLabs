//
//  LJSDKGameBoard.m
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "LJSDKGameBoard.h"
#import "GKHelperDelegate.h"
#import "LJAlertView.h"
#import "LJAppDelegate.h"
#import "LJMainViewController.h"


static LJSDKDifficulty level = LJSDKDifficultyNone;

static UIColor *mainLineColor;
static UIColor *lineColor;
//static UIColor *playerColor;

static CGSize mainFrameSize;

static int numGrid[3][4] =
{
    {1, 4, 7, 0},
    {2, 5, 8, -1},
    {3, 6, 9, 0},
};

static float gameTime;
static int grid[9][9];
static int playerGrid[9][9];
static int moveList[81];
static int player;
static int player1Score;
static int player2Score;
static int turnNumber = 0;
static BOOL isMultiplayer = false;


#pragma mark C Functions

void SDKDrawText(CGContextRef c, const char *text, const char *fontName, CGFloat fontSize, CGColorRef fontColor, CGPoint point)
{
    CGContextSelectFont(c, fontName, fontSize, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode (c, kCGTextFill);
    
    CGAffineTransform xform = CGAffineTransformMake(
                                                    1.0,  0.0,
                                                    0.0, -1.0,
                                                    0.0,  0.0);
    CGContextSetTextMatrix(c, xform);
    
    CGContextSetFillColorWithColor(c, fontColor);
    CGContextShowTextAtPoint(c, point.x-fontSize/4, point.y+fontSize/3, text, strlen(text));
}

CGPoint SDKGridToCGPoint(CGPoint gridCoord, CGSize gridRef)
{
    CGFloat caseX = gridRef.width/9;
    CGFloat caseY = gridRef.height/9;
    
    return CGPointMake(caseX/2+gridCoord.x*caseX, caseY/2+gridCoord.y*caseY);
}

CGPoint CGPointToSDKGrid(CGPoint point, CGSize gridRef)
{
    CGFloat caseX = gridRef.width/9;
    CGFloat caseY = gridRef.height/9;
    
    return CGPointMake(ceil(point.x/caseX)-1, ceil(point.y/caseY)-1);
}

void SDKRandomizeEmptyGrid(int aGrid[9][9])
{
    int count = 0;
    
    switch (level)
    {
        case LJSDKDifficultyEasy:
            count = 32;
            break;
        case LJSDKDifficultyNormal:
            count = 48;
            break;
        case LJSDKDifficultyHard:
            count = 58;
            break;
        case LJSDKDifficultyExtreme:
            count = 68;
            break;
        case LJSDKDifficultyNone:
            count = 9;
            break;
            
        default:
            count = 50;
            break;
    }
    
    for (int i=0; i<count; i++)
    {
        int xRand, yRand;
        do
        {
            xRand = arc4random() % 9;
            yRand = arc4random() % 9;
        }
        while (aGrid[yRand][xRand] == 0);
        
        playerGrid[yRand][xRand] = 0;
        aGrid[yRand][xRand] = 0;
    }
}

#pragma mark - LJSDKGameBoard

@implementation LJSDKGameBoard

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{    
    self = [super initWithFrame:frame];
    
    if (self)
    {
        CGFloat offsetX = 16;
        CGFloat offsetY = 64;
        CGSize numGridSize = CGSizeMake(132, 132);
        CGFloat mainFontSize = 18;
        CGFloat buttonFontSize = 14;
        CGFloat timerHeight = 18;
        CGFloat buttonWidth = 96;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            offsetY *= 2;
            mainFontSize *= 2;
            buttonFontSize *= 1.5;
            buttonWidth *= 1.5;
            offsetX *= 2;
            numGridSize = CGSizeMake(256, 256);
            timerHeight *= 2;
        }
        
        CGFloat gridSize = frame.size.width-offsetX*2;
        mainGrid = [[LJSDKMainGrid alloc] initWithFrame:CGRectMake(gridSize/2-(gridSize/2-offsetX), offsetY, gridSize, gridSize+48)];
        [self addSubview:mainGrid];
        
        timerField = [[LJSDKTimerField alloc] initWithFrame:CGRectMake(mainGrid.frame.origin.x+mainGrid.frame.size.width-(mainGrid.frame.size.width/2), mainGrid.frame.origin.y-(timerHeight+4), mainGrid.frame.size.width/2, timerHeight)];
        timerField.isRunning = NO;
        [self addSubview:timerField];
        
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:timerField selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
        
        UIFont *buttonFont = [UIFont fontWithName:@"MarkerFelt-Thin" size:buttonFontSize];
        
        UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        resetButton.frame = CGRectMake(mainGrid.frame.origin.x, mainGrid.frame.origin.y+mainGrid.frame.size.height+8, buttonWidth, buttonFont.lineHeight+4);
        resetButton.backgroundColor = [UIColor clearColor];
        resetButton.titleLabel.textColor = [UIColor blackColor];
        resetButton.titleLabel.textAlignment = UITextAlignmentLeft;
        resetButton.titleLabel.font = buttonFont;
        resetButton.imageEdgeInsets = UIEdgeInsetsMake(0,-8,0,0);
        
        UIImage *imageReset = [UIImage imageNamed:@"Reset"];
        [resetButton setImage:imageReset forState:UIControlStateNormal];
        [resetButton addTarget:self action:@selector(resetGrid:) forControlEvents:UIControlEventTouchDown];
        [resetButton setTitle:NSLocalizedString(@"Reset Grid", @"Reset Grid") forState:UIControlStateNormal];
        [resetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self addSubview:resetButton];
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(mainGrid.frame.origin.x+mainGrid.frame.size.width-buttonWidth, resetButton.frame.origin.y, buttonWidth, buttonFont.lineHeight+4);
        backButton.backgroundColor = [UIColor clearColor];
        backButton.titleLabel.textColor = [UIColor blackColor];
        backButton.titleLabel.textAlignment = UITextAlignmentRight;
        backButton.titleLabel.font = buttonFont;
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0,-8,0,0);
        
        UIImage *imageBack = [UIImage imageNamed:@"Return"];
        [backButton setImage:imageBack forState:UIControlStateNormal];
        [backButton addTarget:[LJMainViewController sharedController] action:@selector(doneGame:) forControlEvents:UIControlEventTouchDown];
        [backButton setTitle:NSLocalizedString(@"Main Menu", @"Main Menu") forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self addSubview:backButton];
        
        UIFont *difFont = [UIFont fontWithName:@"Japanese Brush" size:mainFontSize];
        difficultyLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainGrid.frame.origin.x, mainGrid.frame.origin.y-(difFont.lineHeight+4), mainGrid.frame.size.width/2, difFont.lineHeight+4)];
        difficultyLabel.font = difFont;
        difficultyLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:difficultyLabel];
        
        hintsView = [[UIView alloc] initWithFrame:mainGrid.frame];
        hintsView.backgroundColor = [UIColor clearColor];
        hintsView.opaque = NO;
        [self addSubview:hintsView];
        
        selectionCase = [[LJSDKSelection alloc] initWithFrame:CGRectMake(0, 0, mainGrid.frame.size.width/9, mainGrid.frame.size.height/9)];
        [selectionCase setHidden:YES];
        [self addSubview:selectionCase];
        
        numGrid = [[LJSDKNumberGrid alloc] initWithFrame:CGRectMake(0, 0, numGridSize.width, numGridSize.height+numGridSize.height/3)];
        [numGrid setDelegate:self];
        [self addSubview:numGrid];
    }
    
    return self;
}

- (id)initMultiWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        CGFloat offsetX = 16;
        CGFloat offsetY = 64;
        CGSize numGridSize = CGSizeMake(132, 132);
        CGFloat mainFontSize = 18;
        CGFloat playerFontSize = 12;
        CGFloat buttonFontSize = 14;
        CGFloat timerHeight = 18;
        CGFloat buttonWidth = 96;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            offsetY *= 2;
            mainFontSize *= 2;
            buttonFontSize *= 1.5;
            buttonWidth *= 1.5;
            offsetX *= 2;
            numGridSize = CGSizeMake(256, 256);
            timerHeight *= 2;
        }
        
        CGFloat gridSize = frame.size.width-offsetX*2;
        mainGrid = [[LJSDKMainGrid alloc] initWithFrame:CGRectMake(gridSize/2-(gridSize/2-offsetX), offsetY, gridSize, gridSize+48)];
        [self addSubview:mainGrid];
        
        timerField = [[LJSDKTimerField alloc] initWithFrame:CGRectMake(mainGrid.frame.origin.x+mainGrid.frame.size.width-(mainGrid.frame.size.width/2), mainGrid.frame.origin.y-(timerHeight+4), mainGrid.frame.size.width/2, timerHeight)];
        timerField.isRunning = NO;
        timerField.gameClock = YES;
        [self addSubview:timerField];
        
        moveTimerField = [[LJSDKTimerField alloc] initWithFrame:CGRectMake(mainGrid.frame.origin.x+mainGrid.frame.size.width-(mainGrid.frame.size.width/2)-130, mainGrid.frame.origin.y-(timerHeight+4), mainGrid.frame.size.width/2, timerHeight)];
        moveTimerField.isRunning = NO;
        moveTimerField.gameClock = NO;
        [self addSubview:moveTimerField];
        
        //Here is the breakpoint for the timerfield as an image.
        
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:timerField selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:moveTimerField selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
        
        UIFont *buttonFont = [UIFont fontWithName:@"MarkerFelt-Thin" size:buttonFontSize];
        
        UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        resetButton.frame = CGRectMake(mainGrid.frame.origin.x, mainGrid.frame.origin.y+mainGrid.frame.size.height+8, buttonWidth, buttonFont.lineHeight+4);
        resetButton.backgroundColor = [UIColor clearColor];
        resetButton.titleLabel.textColor = [UIColor blackColor];
        resetButton.titleLabel.textAlignment = UITextAlignmentLeft;
        resetButton.titleLabel.font = buttonFont;
        resetButton.imageEdgeInsets = UIEdgeInsetsMake(0,-8,0,0);
        
        UIImage *imageReset = [UIImage imageNamed:@"Reset"];
        [resetButton setImage:imageReset forState:UIControlStateNormal];
        [resetButton addTarget:self action:@selector(resetGrid:) forControlEvents:UIControlEventTouchDown];
        [resetButton setTitle:NSLocalizedString(@"Reset Grid", @"Reset Grid") forState:UIControlStateNormal];
        [resetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self addSubview:resetButton];
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(mainGrid.frame.origin.x+mainGrid.frame.size.width-buttonWidth, resetButton.frame.origin.y, buttonWidth, buttonFont.lineHeight+4);
        backButton.backgroundColor = [UIColor clearColor];
        backButton.titleLabel.textColor = [UIColor blackColor];
        backButton.titleLabel.textAlignment = UITextAlignmentRight;
        backButton.titleLabel.font = buttonFont;
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0,-8,0,0);
        
        UIImage *imageBack = [UIImage imageNamed:@"Return"];
        [backButton setImage:imageBack forState:UIControlStateNormal];
        [backButton addTarget:[LJMainViewController sharedController] action:@selector(doneGame:) forControlEvents:UIControlEventTouchDown];
        [backButton setTitle:NSLocalizedString(@"Main Menu", @"Main Menu") forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self addSubview:backButton];
        
        UIFont *difFont = [UIFont fontWithName:@"Japanese Brush" size:mainFontSize];
        UIFont *playerFont = [UIFont fontWithName:@"Japanese Brush" size:playerFontSize];
        UIFont *scoreFont = [UIFont fontWithName:@"Helvetica" size:18];
        
        difficultyLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainGrid.frame.origin.x, mainGrid.frame.origin.y-(difFont.lineHeight+4), mainGrid.frame.size.width/2, difFont.lineHeight+4)];
        difficultyLabel.font = difFont;
        difficultyLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:difficultyLabel];
        
        
        player1Label = [[UILabel alloc] initWithFrame:CGRectMake(mainGrid.frame.size.width - 187, timerField.frame.origin.y-(playerFont.lineHeight+3), mainGrid.frame.size.width/2, playerFont.lineHeight+4)];
        player1Label.font = playerFont;
        player1Label.backgroundColor = [UIColor clearColor];
        player1Label.text = @"Last Move";
        [self addSubview:player1Label];
        
        player2Label = [[UILabel alloc] initWithFrame:CGRectMake(mainGrid.frame.size.width - 55, moveTimerField.frame.origin.y-(playerFont.lineHeight+3), mainGrid.frame.size.width/2, playerFont.lineHeight+4)];
        player2Label.font = playerFont;
        player2Label.backgroundColor = [UIColor clearColor];
        player2Label.text = @"Game Time";
        [self addSubview:player2Label];
        
        scoreBoxView = [[UIView alloc] initWithFrame:CGRectMake(mainGrid.frame.size.width - 215, timerField.frame.origin.y, mainGrid.frame.size.width/2, 3 * playerFont.lineHeight+4)];
        scoreBoxView.backgroundColor = [UIColor clearColor];
        scoreBoxView.opaque = NO;
        [self addSubview:scoreBoxView];
        
        player1NameLabel = [[UILabel alloc] initWithFrame:CGRectMake(scoreBoxView.frame.origin.x -210, timerField.frame.origin.y-(playerFont.lineHeight+3), mainGrid.frame.size.width/2, playerFont.lineHeight+4)];
        player1NameLabel.font = playerFont;
        player1NameLabel.backgroundColor = [UIColor clearColor];
        player1NameLabel.textColor = [UIColor colorWithRed:0 green:0 blue:.61 alpha:1];
        player1NameLabel.text = @"Player 1";
        [self addSubview:player1NameLabel];
        
        player2NameLabel = [[UILabel alloc] initWithFrame:CGRectMake(scoreBoxView.frame.origin.x - 100, timerField.frame.origin.y-(playerFont.lineHeight+3) , mainGrid.frame.size.width/2, playerFont.lineHeight+4)];
        player2NameLabel.font = playerFont;
        player2NameLabel.backgroundColor = [UIColor clearColor];
        player2NameLabel.text = @"Player 2";
        player2NameLabel.TextColor = [UIColor colorWithRed:.54 green:.09 blue:.09 alpha:1];
        [self addSubview:player2NameLabel];
        
        player1ScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(scoreBoxView.frame.origin.x -180, timerField.frame.origin.y + 9, mainGrid.frame.size.width/2, playerFont.lineHeight+4)];
        player1ScoreLabel.font = scoreFont;
        player1ScoreLabel.backgroundColor = [UIColor clearColor];
        player1ScoreLabel.textColor = [UIColor colorWithRed:0 green:0 blue:.61 alpha:1];
        player1ScoreLabel.text = @"0";
        [self addSubview:player1ScoreLabel];
        
        player2ScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(scoreBoxView.frame.origin.x - 70, timerField.frame.origin.y + 9, mainGrid.frame.size.width/2, playerFont.lineHeight+4)];
        player2ScoreLabel.font = scoreFont;
        player2ScoreLabel.backgroundColor = [UIColor clearColor];
        player2ScoreLabel.TextColor = [UIColor colorWithRed:.54 green:.09 blue:.09 alpha:1];
        player2ScoreLabel.text = @"0";
        [self addSubview:player2ScoreLabel];
        
        hintsView = [[UIView alloc] initWithFrame:mainGrid.frame];
        hintsView.backgroundColor = [UIColor clearColor];
        hintsView.opaque = NO;
        [self addSubview:hintsView];
        
        selectionCase = [[LJSDKSelection alloc] initWithFrame:CGRectMake(0, 0, mainGrid.frame.size.width/9, mainGrid.frame.size.height/9)];
        [selectionCase setHidden:YES];
        [self addSubview:selectionCase];
        
        numGrid = [[LJSDKNumberGrid alloc] initWithFrame:CGRectMake(0, 0, numGridSize.width, numGridSize.height+numGridSize.height/3)];
        [numGrid setDelegate:self];
        [self addSubview:numGrid];
    }
    
    
    return self;
}

#pragma mark - Actions

- (void)setMultiplayer:(BOOL)value{
    isMultiplayer = value;
}

- (void)setPlayer2Grid:(BoardArray)board{
    for (int i = 0; i < 9; i++)
    {
        for (int j = 0; j < 9; j++){
            playerGrid[i][j] = board.array[i][j];
            if(playerGrid[i][j] == 0){
                grid[i][j] =0;
            }
            else{
                grid[i][j] = board.solutionArray[i][j];
            }
        }
    }
    mySolver = [[LJSDKSolver alloc] initWithArray:board.solutionArray];
    
    gridLocation = CGPointZero;
    
    NSString *difString = [NSString string];
    difString = NSLocalizedString(@"Versus", @"Versus!");
    difficultyLabel.text = difString;
    
    [self resetHints];
    bHints = NO;
    
    timerField.isRunning = YES;
    [timerField restart];
    
    moveTimerField.isRunning = YES;
    [moveTimerField restart];
    
    [selectionCase setHidden:YES];
    [numGrid setHidden:YES];
    
    [mainGrid setNeedsDisplay];
    [self setNeedsDisplay];  
}

- (void)setPlayer:(int)playerNumber
{
    player = playerNumber;
}

- (BOOL)isPlayer1{
    return (1 == player);
}

- (void)setNewGrid:(LJSDKDifficulty)diff;
{
    NSString *difString = [NSString string];
    level = diff;
    
    switch (level)
    {
        case LJSDKDifficultyEasy:
            difString = NSLocalizedString(@"Beginner", @"Easy difficulty");
            break;
        case LJSDKDifficultyNormal:
            difString = NSLocalizedString(@"Casual", @"Normal difficulty");
            break;
        case LJSDKDifficultyHard:
            difString = NSLocalizedString(@"Expert", @"Hard difficulty");
            break;
        case LJSDKDifficultyExtreme:
            difString = NSLocalizedString(@"Master", @"Extreme difficulty");
            break;
        case LJSDKDifficultyNone:
            difString = NSLocalizedString(@"Test", @"Test difficulty");
            break;
        case LJSDKDifficultyVersus:
            difString = NSLocalizedString(@"Versus", @"Versus!");
            break;
        default:
            difString = NSLocalizedString(@"Casual", @"Normal difficulty");
            break;
    }
    
    mySolver = [[LJSDKSolver alloc] initWithNewGrid];
    BOOL success = [mySolver solve];
    
    for (int i = 0; i < 9; i++)
    {
        for (int j = 0; j < 9; j++)
            playerGrid[i][j] = -9;
    }
    
    if (success)
    {
        for (int i=0; i<9; i++)
        {
            for (int j=0; j<9; j++)
                grid[i][j]=[mySolver valueAtX:i atY:j];
        }
        
        SDKRandomizeEmptyGrid(grid);
    }
    
    gridLocation = CGPointZero;
    
    [self resetHints];
    bHints = NO;
    
    timerField.isRunning = YES;
    [timerField restart];
    
    if(isMultiplayer){
        moveTimerField.isRunning = YES;
        [moveTimerField restart];
    }
    
    
    difficultyLabel.text = difString;
    
    [selectionCase setHidden:YES];
    [numGrid setHidden:YES];
    
    [mainGrid setNeedsDisplay];
    [self setNeedsDisplay];
}


-(BoardArray)getGameBoard{
    BoardArray board;
    
    for(int i = 0; i < 9;i++){
        for(int j = 0; j < 9; j++){
            board.array[i][j] = playerGrid[i][j];
        }
    }
    
    for(int i = 0; i < 9; i++){
        for(int j = 0; j < 9; j++){
            board.solutionArray[i][j] = [mySolver valueAtX:i atY:j];
        }
    }
    return board;
}


- (void)addNumberOnGrid:(int)num
{
    [selectionCase setHidden:YES];
    
    int x = gridLocation.x;
    int y = gridLocation.y;
    
    playerGrid[x][y] = num;
    
    [mainGrid setNeedsDisplay];
    
    if ([self lastNumberAdded])
    {
        if ([self solvePuzzle])
        {
            timerField.isRunning = NO;
            
            id delegate = [[UIApplication sharedApplication] delegate];
            
            [delegate reportAchievementIdentifier:kAchievementStart percentComplete:100.0f];
            
            if (gameTime < 300)
                [delegate reportAchievementIdentifier:kAchievementTime percentComplete:100.0f];
            
            if (level == LJSDKDifficultyExtreme)
                [delegate reportAchievementIdentifier:kAchievementMaster percentComplete:100.0f];
            
            if (level == LJSDKDifficultyHard)
                [delegate reportAchievementIdentifier:kAchievementExpert percentComplete:100.0f];
            
            if (!bHints)
                [delegate reportAchievementIdentifier:kAchievementNoHints percentComplete:100.0f];
            
            float complete = [delegate getAchievementForIdentifier:kAchievementOneHundred].percentComplete;
            if (complete < 100) complete += 1.0f;
            
            [delegate reportAchievementIdentifier:kAchievementOneHundred percentComplete:complete];
            
            LJAlertView *alert = [[LJAlertView alloc] initWithTitle:NSLocalizedString(@"Congratulations !",@"End Alert Title") message:[NSString stringWithFormat:@"%@ %1.0f %@",NSLocalizedString(@"The puzzle has been solved in",@"Puzzle solved"),gameTime, NSLocalizedString(@"seconds",@"Seconds")] delegate:self cancelButtonTitle:NSLocalizedString(@"Review",@"Review") otherButtonTitles:NSLocalizedString(@"Main Menu",@"Main Menu"), nil];
            alert.tag = 1;
            [alert show];
            //[alert release];
        }
        else
        {
            if (!bHints)
            {
                LJAlertView *alert = [[LJAlertView alloc] initWithTitle:NSLocalizedString(@"Solution",@"Solution Alert Title") message:NSLocalizedString(@"The puzzle has not been solved",@"Puzzle not solved") delegate:self cancelButtonTitle:NSLocalizedString(@"Hints",@"Hints") otherButtonTitles:NSLocalizedString(@"Main Menu",@"Main Menu"), nil];
                alert.tag = 2;
                [alert show];
                //[alert release];
            }
            else
                [self giveHints];
        }
    }
}


- (void)addNumberOnGrid:(int)num :(int)playerNum :(int)xThing :(int)yThing :(int)score
{
    [selectionCase setHidden:YES];
    
    int x = gridLocation.x;
    int y = gridLocation.y;
    
    if(playerNum != player){
        x = xThing;
        y = yThing;
        if(player ==  1){
            player2Score = score;
        }
        else if(player == 2) {
            player1Score = score;
        }
    }
    
    NSLog(@"Received move from %d , of %d , at %d x %d", playerNum, num, xThing, yThing);
    moveList[x + 10*y] = playerNum;
    
    playerGrid[x][y] = num;
    int realnum = [mySolver valueAtX:x atY:y];
    
    if(playerNum == player){
        if([mySolver valueAtX:x atY:y] == num){
            if(player == 1){
                player1Score += (int) moveTimerField.time;
            }
            else if (player == 2){
                player2Score += (int) moveTimerField.time;
            }
        }
        
        else{
            if(player == 1){
                player1Score -= (int) moveTimerField.time;
            }
            else if(player == 2){
                player2Score -= (int) moveTimerField.time;
            }
        }
    }
    
    
    
    player1ScoreLabel.text = [NSString stringWithFormat:@"%d", player1Score, realnum];
    player2ScoreLabel.text = [NSString stringWithFormat:@"%d", player2Score, realnum];
    
    if(playerNum == player){
        int score;
        if(player == 1){
            score = player1Score;
        }
        else {
            score = player2Score;
        }
        [[GKHelperDelegate sharedInstance] sendMove:x yCoordinate:y placedNumber:num fromPlayer:playerNum turnNumber:turnNumber score:score];
    }
    
    [mainGrid setNeedsDisplay];
    [scoreBoxView setNeedsDisplay];
    
    
    
    [moveTimerField restart];
    
    
    if ([self lastNumberAdded])
    {
        if ([self solvePuzzle])
        {
            timerField.isRunning = NO;
            
            id delegate = [[UIApplication sharedApplication] delegate];
            
            [delegate reportAchievementIdentifier:kAchievementStart percentComplete:100.0f];
            
            if (gameTime < 300)
                [delegate reportAchievementIdentifier:kAchievementTime percentComplete:100.0f];
            
            if (level == LJSDKDifficultyExtreme)
                [delegate reportAchievementIdentifier:kAchievementMaster percentComplete:100.0f];
            
            if (level == LJSDKDifficultyHard)
                [delegate reportAchievementIdentifier:kAchievementExpert percentComplete:100.0f];
            
            if (!bHints)
                [delegate reportAchievementIdentifier:kAchievementNoHints percentComplete:100.0f];
            
            float complete = [delegate getAchievementForIdentifier:kAchievementOneHundred].percentComplete;
            if (complete < 100) complete += 1.0f;
            
            [delegate reportAchievementIdentifier:kAchievementOneHundred percentComplete:complete];
            
            LJAlertView *alert = [[LJAlertView alloc] initWithTitle:NSLocalizedString(@"Congratulations !",@"End Alert Title") message:[NSString stringWithFormat:@"%@ %1.0f %@",NSLocalizedString(@"The puzzle has been solved in",@"Puzzle solved"),gameTime, NSLocalizedString(@"seconds",@"Seconds")] delegate:self cancelButtonTitle:NSLocalizedString(@"Review",@"Review") otherButtonTitles:NSLocalizedString(@"Main Menu",@"Main Menu"), nil];
            alert.tag = 1;
            [alert show];
            //[alert release];
        }
        else
        {
            if (!bHints)
            {
                LJAlertView *alert = [[LJAlertView alloc] initWithTitle:NSLocalizedString(@"Solution",@"Solution Alert Title") message:NSLocalizedString(@"The puzzle has not been solved",@"Puzzle not solved") delegate:self cancelButtonTitle:NSLocalizedString(@"Hints",@"Hints") otherButtonTitles:NSLocalizedString(@"Main Menu",@"Main Menu"), nil];
                alert.tag = 2;
                [alert show];
                //[alert release];
            }
            else
                [self giveHints];
        }
    }
}

- (BOOL)lastNumberAdded
{
    BOOL last = YES;
    for (int i=0; i<9; i++)
    {
        for (int j=0; j<9; j++)
        {
            if (playerGrid[i][j]>-9)
            {
                if (playerGrid[i][j]<1)
                    last = NO;
            }
        }
    }
    
    return last;
}

- (BOOL)solvePuzzle
{
    [self resetHints];
    
    BOOL success = YES;
    for (int i=0; i<9; i++)
    {
        for (int j=0; j<9; j++)
        {
            if (playerGrid[i][j]>-9)
            {
                if (playerGrid[i][j]!=[mySolver valueAtX:i atY:j])
                    success = NO;
            }
        }
    }
    
    return success;
}


- (void)giveHints
{    
    for (int i=0; i<9; i++)
    {
        for (int j=0; j<9; j++)
        {
            if (playerGrid[i][j]>-9)
            {
                if (playerGrid[i][j]!=[mySolver valueAtX:i atY:j])
                {
                    CGPoint point = SDKGridToCGPoint(CGPointMake(i, j), mainFrameSize);
                    point.x -= selectionCase.frame.size.width / 2;
                    point.y -= selectionCase.frame.size.height / 2;
                    
                    UIView *hint = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, selectionCase.frame.size.width, selectionCase.frame.size.height)];
                    hint.backgroundColor = [UIColor blueColor];
                    hint.alpha = 0.2;
                    
                    [hintsView addSubview:hint];
                    
                    //[hint release];
                }
            }
        }
    }    
}

- (void)resetGrid:(id)sender
{
    LJAlertView *alert = [[LJAlertView alloc] initWithTitle:NSLocalizedString(@"Start over",@"Reset Grid Alert Title") message:NSLocalizedString(@"Would you like to reset the grid?",@"Reset Grid Alert Message") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") otherButtonTitles:NSLocalizedString(@"OK",@"OK"),nil];
    alert.tag = 0;
    [alert show];
}

- (void)resetScore{
    player1Score = 0;
    player2Score = 0;
}

- (void)resetHints
{
    UIView *oldView = nil;
    
	if ([[hintsView subviews] count] > 0)
    {
		NSEnumerator *subviewsEnum = [[hintsView subviews] reverseObjectEnumerator];
		
        // The first one (last one added) is our visible view.
		oldView = [subviewsEnum nextObject];
        
        // Remove any others.
		UIView *olderView = nil;
		while ((olderView = [subviewsEnum nextObject]) != nil)
            [olderView removeFromSuperview];
	}
    
    if (oldView)
        [oldView removeFromSuperview];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if (buttonIndex == 1)
        {
            [selectionCase setHidden:YES];
            [numGrid setHidden:YES];
            
            [timerField restart];
            [[LJMainViewController sharedController] doneGame:alertView];
        }            
    }
    else if (alertView.tag == 2)
    {
        [selectionCase setHidden:YES];
        [numGrid setHidden:YES];
        
        if (buttonIndex == 1)
        {
            timerField.isRunning = NO;
            [timerField restart];
            
            [[LJMainViewController sharedController] doneGame:self];
        }
        else
        {
            [self giveHints];
            bHints = YES;
        }
    }
    else
    {
        if (buttonIndex == 1)
        {
            for (int i = 0; i < 9; i++)
            {
                for (int j = 0; j < 9; j++)
                {
                    if (playerGrid[i][j]>-9)
                        playerGrid[i][j] = 0;
                }
            } 
            
            timerField.isRunning = YES;
            [mainGrid setNeedsDisplay];
            [self resetHints];
            bHints = NO;
            
            [selectionCase setHidden:YES];
            [numGrid setHidden:YES];
        }
    }
}

#pragma mark - UITouchEvents

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (timerField.isRunning)
    {
        UITouch *touch = [touches anyObject];
        
        CGPoint location = [touch locationInView:mainGrid];
        UIView *myGrid = [mainGrid hitTest:location withEvent:event];
        
        if (myGrid)
        {
            gridLocation = CGPointToSDKGrid(location, mainFrameSize);
            
            [numGrid setHidden:![numGrid isHidden]];
            
            if ([mainGrid isCaseEditable:gridLocation])
            {
                if (![numGrid isHidden])
                {                
                    CGPoint point = SDKGridToCGPoint(gridLocation, mainFrameSize);
                    point.x += mainGrid.frame.origin.x;
                    point.y += mainGrid.frame.origin.y;
                    
                    CGRect rect = numGrid.frame;
                    rect.origin.x = point.x;
                    rect.origin.y = point.y;
                    
                    if (gridLocation.x > 4)
                        rect.origin.x -= numGrid.frame.size.width+8;
                    
                    if (gridLocation.y > 5)
                        rect.origin.y -= numGrid.frame.size.height;
                    
                    [numGrid setFrame:rect];
                    
                    point.x -= selectionCase.frame.size.width/2;
                    point.y -= selectionCase.frame.size.height/2;
                    
                    [selectionCase setFrame:CGRectMake(point.x, point.y, selectionCase.frame.size.width, selectionCase.frame.size.height)];
                    [selectionCase setHidden:NO];
                }
                else
                    [selectionCase setHidden:YES];
            }
            else
            {
                [selectionCase setHidden:YES];
                [numGrid setHidden:YES];
            }
        }
        else
        {
            [selectionCase setHidden:YES];
            [numGrid setHidden:YES];
        }
    }
}

@end

#pragma mark - SDKMainGrid

@implementation LJSDKMainGrid

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        if (mainLineColor == nil)
            mainLineColor = [UIColor blackColor];
        if (lineColor == nil)
            lineColor = [UIColor darkGrayColor];
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        CGFloat w = self.frame.size.width / 3;
        CGFloat h = self.frame.size.height / 3;
        
        mainLines = malloc(sizeof(LJSDKLine) * 4);
        
        mainLines[0].coord[0] = CGPointMake(w, 0);
        mainLines[0].coord[1] = CGPointMake(w, self.frame.size.height);
        mainLines[1].coord[0] = CGPointMake(w*2, 0);
        mainLines[1].coord[1] = CGPointMake(w*2, self.frame.size.height);
        mainLines[2].coord[0] = CGPointMake(0, h);
        mainLines[2].coord[1] = CGPointMake(self.frame.size.width, h);
        mainLines[3].coord[0] = CGPointMake(0, h*2);
        mainLines[3].coord[1] = CGPointMake(self.frame.size.width, h*2);
        
        CGPoint origin[9] = 
        {
            CGPointMake(0, 0),
            CGPointMake(w, 0),
            CGPointMake(w*2, 0),
            CGPointMake(0, h),
            CGPointMake(w, h),
            CGPointMake(w*2, h),
            CGPointMake(0, h*2),
            CGPointMake(w, h*2),
            CGPointMake(w*2, h*2),
        };
        
        for (int i = 0; i < 9; i++)
        {
            LJSDKGrid *sdkGrid = [[LJSDKGrid alloc] initWithFrame:CGRectMake(origin[i].x, origin[i].y, w, h)];
            [self addSubview:sdkGrid];
        }
        
        mainFrameSize = self.frame.size;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if(isMultiplayer){
        //Get the CGContext from this view
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetStrokeColorWithColor(context, mainLineColor.CGColor);
        CGContextSetLineWidth(context, MAINLINE_WIDTH);
        
        for (int k = 0; k < 4; k++)
            CGContextAddLines(context,mainLines[k].coord,2);
        
        CGContextAddRect(context, rect);
        
        BOOL isDevicePad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)?YES:NO;
        
        for (int i = 0; i < 9; i++)
        {
            for (int j = 0; j < 9; j++)
            {
                CGPoint textPos = SDKGridToCGPoint(CGPointMake(j, i), mainFrameSize);
                if (grid[j][i] > 0)
                {
                    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:UI_FONT_GAME_COLOR]];
                    
                    char buffer[8];
                    sprintf(buffer,"%d",grid[j][i]);
                    
                    SDKDrawText(context, buffer, [[[NSUserDefaults standardUserDefaults] objectForKey:UI_FONT_GAME_NAME] UTF8String], isDevicePad?FONT_SIZE_GAME*1.5:FONT_SIZE_GAME, color.CGColor, textPos);
                }
                
                if (playerGrid[j][i] > 0)
                {
                    int play = moveList[j + (10*i)];
                    NSLog(@"Inside set color %d",play);
                    UIColor *color = [self setPlayerColor:play];
                    
                    char buffer[8];
                    sprintf(buffer,"%d",playerGrid[j][i]);
                    SDKDrawText(context, buffer, [[[NSUserDefaults standardUserDefaults] objectForKey:UI_FONT_PLAYER_NAME] UTF8String], isDevicePad?FONT_SIZE_PLAYER*1.5:FONT_SIZE_PLAYER, color.CGColor, textPos);
                }
            }
        }
        
        //Draw it
        CGContextStrokePath(context);
    }
    else{
        //Get the CGContext from this view
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetStrokeColorWithColor(context, mainLineColor.CGColor);
        CGContextSetLineWidth(context, MAINLINE_WIDTH);
        
        for (int k = 0; k < 4; k++)
            CGContextAddLines(context,mainLines[k].coord,2);
        
        CGContextAddRect(context, rect);
        
        BOOL isDevicePad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)?YES:NO;
        
        for (int i = 0; i < 9; i++)
        {
            for (int j = 0; j < 9; j++)
            {
                CGPoint textPos = SDKGridToCGPoint(CGPointMake(j, i), mainFrameSize);
                if (grid[j][i] > 0)
                {
                    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:UI_FONT_GAME_COLOR]];
                    
                    char buffer[8];
                    sprintf(buffer,"%d",grid[j][i]);
                    
                    SDKDrawText(context, buffer, [[[NSUserDefaults standardUserDefaults] objectForKey:UI_FONT_GAME_NAME] UTF8String], isDevicePad?FONT_SIZE_GAME*1.5:FONT_SIZE_GAME, color.CGColor, textPos);
                }
                
                if (playerGrid[j][i] > 0)
                {
                    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:UI_FONT_PLAYER_COLOR]];
                    
                    char buffer[8];
                    sprintf(buffer,"%d",playerGrid[j][i]);
                    SDKDrawText(context, buffer, [[[NSUserDefaults standardUserDefaults] objectForKey:UI_FONT_PLAYER_NAME] UTF8String], isDevicePad?FONT_SIZE_PLAYER*1.5:FONT_SIZE_PLAYER, color.CGColor, textPos);
                }
            }
        }
        
        //Draw it
        CGContextStrokePath(context);
        
    }
}

- (BOOL)isCaseEditable:(CGPoint)gridCoord
{    
    int x = gridCoord.x;
    int y = gridCoord.y;
    
    if (grid[x][y] == 0)
        return YES;
    
    return NO;
}

- (UIColor*)setPlayerColor:(int)play{
    if(play == 1){
        return [UIColor colorWithRed:0 green:0 blue:.61 alpha:1];
    }
    else{
        return [UIColor colorWithRed:.54 green:.09 blue:.09 alpha:1];
    }
}

@end


@implementation LJSDKGrid

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        CGFloat w = frame.size.width / 3;
        CGFloat h = frame.size.height / 3;
        
        lines = malloc(sizeof(LJSDKLine) * 4);
        
        lines[0].coord[0] = CGPointMake(w, 0);
        lines[0].coord[1] = CGPointMake(w, frame.size.height);
        lines[1].coord[0] = CGPointMake(w*2, 0);
        lines[1].coord[1] = CGPointMake(w*2, frame.size.height);
        lines[2].coord[0] = CGPointMake(0, h);
        lines[2].coord[1] = CGPointMake(frame.size.width, h);
        lines[3].coord[0] = CGPointMake(0, h*2);
        lines[3].coord[1] = CGPointMake(frame.size.width, h*2);
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	//Get the CGContext from this view
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
	CGContextSetLineWidth(context, LINE_WIDTH);
    
    for (int i = 0; i < 4; i++)
        CGContextAddLines(context,lines[i].coord,2);
    
    //Draw it
	CGContextStrokePath(context);    
}

@end

#pragma mark - LJSDKNumberGrid

@implementation LJSDKNumberGrid

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;        
        self.layer.shadowOffset = CGSizeMake(-2, 8);
        self.layer.shadowOpacity = 1.0;        
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        
        
        CGFloat w = frame.size.width / 3;
        CGFloat h = frame.size.height / 4;
        
        lines = malloc(sizeof(LJSDKLine) * 5);
        
        lines[0].coord[0] = CGPointMake(w, 0);
        lines[0].coord[1] = CGPointMake(w, frame.size.height-h);
        lines[1].coord[0] = CGPointMake(w*2, 0);
        lines[1].coord[1] = CGPointMake(w*2, frame.size.height-h);
        lines[2].coord[0] = CGPointMake(0, h);
        lines[2].coord[1] = CGPointMake(frame.size.width, h);
        lines[3].coord[0] = CGPointMake(0, h*2);
        lines[3].coord[1] = CGPointMake(frame.size.width, h*2);
        lines[4].coord[0] = CGPointMake(0, h*3);
        lines[4].coord[1] = CGPointMake(frame.size.width, h*3);
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	//Get the CGContext from this view
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
	CGContextSetLineWidth(context, LINE_WIDTH);
    
    for (int k = 0; k < 5; k++)
        CGContextAddLines(context,lines[k].coord,2);
    
    CGContextAddRect(context, rect);
    
    CGFloat caseX = self.frame.size.width/3;
    CGFloat caseY = self.frame.size.height/4;
    
    BOOL isDevicePad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)?YES:NO;
    
    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 4; j++)
        {
            if (numGrid[i][j] > 0)
            {
                UIColor *color;
                if(isMultiplayer){
                    color = [self setPlayerColor:player];
                }
                
                else{
                    color = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:UI_FONT_PLAYER_COLOR]];
                }
                char buffer[8];
                sprintf(buffer,"%d",numGrid[i][j]);
                SDKDrawText(context, buffer, [[[NSUserDefaults standardUserDefaults] objectForKey:UI_FONT_PLAYER_NAME] UTF8String], isDevicePad?FONT_SIZE_PLAYER*1.5:FONT_SIZE_PLAYER+2, color.CGColor, CGPointMake(caseX/2+i*caseX, caseY/2+j*caseY));
            }
            else if (numGrid[i][j] == -1)
                [[UIImage imageNamed:@"Eraser"] drawInRect:CGRectMake(rect.size.width/2-(caseX/2-8), rect.size.height-(caseY-8), caseX-16, caseY-16)];
        }
    }
    
    //Draw it
	CGContextStrokePath(context);    
}

- (UIColor*)setPlayerColor:(int)play{
    if(play == 1){
        return [UIColor colorWithRed:0 green:0 blue:.61 alpha:1];
    }
    else{
        return [UIColor colorWithRed:.54 green:.09 blue:.09 alpha:1];
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    CGPoint loc = [[touches anyObject] locationInView:self];
    UIView *mySelf = [self hitTest:loc withEvent:event];
    
    if (mySelf)
    {
        CGFloat caseX = self.frame.size.width/3;
        CGFloat caseY = self.frame.size.height/4;
        
        CGPoint gridCoord = CGPointMake(ceil(loc.x/caseX)-1, ceil(loc.y/caseY)-1);
        
        int x = gridCoord.x;
        int y = gridCoord.y;
        
        if(isMultiplayer){
            [self.delegate addNumberOnGrid:(int)numGrid[x][y] :player :x :y :0];
        }
        else{
            [self.delegate addNumberOnGrid:numGrid[x][y]];
        }
        
        
        [self setHidden:YES];
    }
}

@end

#pragma mark - LJSDKSelection

@implementation LJSDKSelection

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
        self.alpha = 0.5;
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
	//Get the CGContext from this view
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] dataForKey:UI_COLOR_SELECTION]];
    
    CGContextSetFillColorWithColor(context, color.CGColor);
	CGContextAddRect(context, rect);
    
    //Draw it
	CGContextFillPath(context);    
}

@end


#pragma mark - LJSDKTimerField

@implementation LJSDKTimerField

@synthesize isRunning;
@synthesize gameClock;
@synthesize time;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        [self setAutoresizesSubviews:NO];
        
        CGFloat fontSize = 14;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            fontSize *= 1.5;
        
        UIImageView *clockView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-16, self.frame.size.height/2-8, 16, 16)];
        [clockView setImage:[UIImage imageNamed:@"Clock"]];
        
        [self addSubview:clockView];
        
        mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-20, frame.size.height)];
        mainLabel.backgroundColor = [UIColor clearColor];
        mainLabel.textAlignment = UITextAlignmentRight;
        mainLabel.font = [UIFont fontWithName:@"Helvetica" size:fontSize];
        
        [self addSubview:mainLabel];
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"H:mm:ss"];
        
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        isRunning = NO;
        
        time = 0;
        
        if(gameClock) {gameTime = 0;}
    }
    return self;
}


- (void)restart
{
    time = 0;
    if(gameClock) { gameTime = 0;}
    
    [self formatTime];
}

- (void)formatTime
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setSecond:time];
    [components setMinute:0],
    [components setHour:0];
    [components setDay:1];
    [components setMonth:1];
    [components setYear:1970];
    
    [formatter setDefaultDate:[gregorian dateFromComponents:components]];
    
    mainLabel.text = [formatter stringFromDate:[formatter defaultDate]];
}

- (void)timerFireMethod:(NSTimer *)theTimer
{
    if (self.isRunning)
    {
        time += [theTimer timeInterval];
        if(gameClock) {gameTime = time;};
        
        if (gameTime > 32400)
        {
            LJAppDelegate *delegateApp = (LJAppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegateApp reportAchievementIdentifier:kAchievementTimeUp percentComplete:100.0f];
            
            [[LJMainViewController sharedController] doneGame:self];
        }
        [self formatTime];
    }
}




@end


