//
//  SDKMainViewController.m
//
//  Created by Charles-André LEDUC on 21/06/11.
//  Copyright 2011. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SDKMainViewController.h"
#import "SDKAlertView.h"
#import "SDKAppDelegate.h"

static BOOL popUpShown = false;
static BOOL isRegistered = false;

@interface SDKMainViewController (Private)
- (void)replaceOldView:(UIView *)oldView withSubView:(UIView *)newView transition:(UIViewAnimationTransition)transition duration:(CFTimeInterval)duration;
- (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title image:(NSString *)keyPath font:(UIFont *)font textColor:(UIColor *)color target:(id)obj action:(SEL)action;
@end

@implementation SDKMainViewController

#pragma mark - Singleton

+ (SDKMainViewController *)sharedController
{
    static SDKMainViewController *_sharedController = nil;
    if (!_sharedController)
        _sharedController = [[SDKMainViewController alloc] init];
    
    return _sharedController;
}

#pragma mark - Actions

- (void)startGame:(id)sender :(int)Multiplayer
{   
    gameBoard = nil;
    gameBoard = [[SDKGameBoard alloc] initWithFrame:mainMenu.frame :1];
    [gameBoard setMultiplayer:true];     
    [self replaceOldView:mainMenu withSubView:gameBoard transition:UIViewAnimationTransitionCurlUp duration:.5];
    [gameBoard setNewGrid:5];
    [gameBoard resetScore];
    int playernumber;
    if([gameBoard isPlayer1]){
        playernumber = 1;
    }
    else{
        playernumber = 2;
    }
    NSString *messageString = [NSString stringWithFormat:@"You are player %d", playernumber]; 
    alertWithOkButton = [[UIAlertView alloc]
                         initWithTitle: @"Game Starting!"
                         message: messageString
                         delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
    [alertWithOkButton show];
}

- (void)startGame:(id)sender
{        
    [self replaceOldView:mainMenu withSubView:gameBoard transition:UIViewAnimationTransitionCurlUp duration:.5];
    
    [gameBoard setNewGrid:[sender tag]];
}

- (void)startGamePlayer2:(BoardArray)gameBoardSet
{   
    gameBoard = nil;
    gameBoard = [[SDKGameBoard alloc] initWithFrame:mainMenu.frame:1];
    [gameBoard setMultiplayer:true];
    [self replaceOldView:mainMenu withSubView:gameBoard transition:UIViewAnimationTransitionCurlUp duration:.5];
    [gameBoard setPlayer2Grid:gameBoardSet];
    [gameBoard resetScore];
    int playernumber;
    if([gameBoard isPlayer1]){
        playernumber = 1;
    }
    else{
        playernumber = 2;
    }
    NSString *messageString = [NSString stringWithFormat:@"You are player %d", playernumber]; 
    alertWithOkButton = [[UIAlertView alloc]
                         initWithTitle: @"Game Starting!"
                         message: messageString
                         delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
    [alertWithOkButton show];
}


- (void)doneGame:(id)sender
{
    if (![sender isKindOfClass:[UIAlertView class]])
    {
        SDKAlertView *alert = [[SDKAlertView alloc] initWithTitle:NSLocalizedString(@"Main Menu",@"Main Menu") message:NSLocalizedString(@"Would you like to quit the current puzzle?",@"Main Menu Alert Message") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") otherButtonTitles:NSLocalizedString(@"OK",@"OK"),nil];
        [alert show];
    }
    else
        [self replaceOldView:gameBoard withSubView:mainMenu transition:UIViewAnimationTransitionCurlDown duration:.4];
}

- (void)showMultiplayer:(id)sender
{
    [[SDKAppDelegate sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self delegate:(id)self];
}

- (void)showAchievements:(id)sender
{
    

    GKAchievementViewController *controller = [[GKAchievementViewController alloc] init];
    if (controller != nil)
    {
        controller.achievementDelegate = self;
        
        if ([SDKAppDelegate isVersionSupported:@"5.0"])
            [self presentViewController:controller animated:YES completion:NULL];
        else
            [self presentModalViewController:controller animated: YES];
    }
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    if ([SDKAppDelegate isVersionSupported:@"5.0"])
        [self dismissViewControllerAnimated:YES completion:NULL];
    else
        [self dismissModalViewControllerAnimated:YES];
}

- (void)flipViewControllerDidFinish:(UIViewController *)viewController
{
    if ([SDKAppDelegate isVersionSupported:@"5.0"])
        [self dismissViewControllerAnimated:YES completion:NULL];
    else
        [self dismissModalViewControllerAnimated:YES];
}

- (void)presentViewController:(id)sender
{
    SDKFlipViewController *controller;
    
    if ([sender tag] == 1)
        controller = [[SDKPrefsViewController alloc] init];
    else
        controller = [[SDKRulesViewController alloc] init];
    
    controller.delegate = self;
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:controller action:@selector(done:)];
    controller.navigationItem.rightBarButtonItem = doneItem;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 2);
    navigationController.navigationBar.layer.shadowOpacity = 0.6;
    navigationController.navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:navigationController.navigationBar.bounds].CGPath;
    navigationController.navigationBar.tintColor = [UIColor blackColor];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    if ([SDKAppDelegate isVersionSupported:@"5.0"])
        [self presentViewController:navigationController animated:YES completion:NULL];
    else
        [self presentModalViewController:navigationController animated:YES];
}

#pragma mark GCHelperDelegate

- (void)matchStarted {    
    //NSLOG(@"Match started");
    ourRandom = arc4random();
    [self sendRandomNumber];
    [self setGameState:kGameStateWaitingForMatch];
    if (receivedRandom) {
        [self setGameState:kGameStateWaitingForStart];
    } else {
        [self setGameState:kGameStateWaitingForRandomNumber];
    }
}

- (void)matchEnded {    
    //NSLOG(@"Match ended");    
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    
    // Store away other player ID for later
    if (otherPlayerID == nil) {
        otherPlayerID = playerID;
    }
    
    Message *message = (Message *) [data bytes];
    if (message->messageType == kMessageTypeRandomNumber) {
        
        MessageRandomNumber * messageInit = (MessageRandomNumber *) [data bytes];
        bool tie = false;
        
        if (messageInit->randomNumber == ourRandom) {
            tie = true;
            ourRandom = arc4random();
            [self sendRandomNumber];
        } else if (ourRandom > messageInit->randomNumber) {          
            [gameBoard setPlayer:1];
            [self setGameState:kGameStateWaitingForStart];
            //NSLog(@"We are both trying to start %d %d ",ourRandom, messageInit->randomNumber);
            [self tryStartGame];
        } else {
            //NSLog(@"We are NOT both trying to start %d %d ",ourRandom, messageInit->randomNumber);
            
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
                NSString *intString = [NSString stringWithFormat:@"%d", board.solutionArray[i][j]];
                NSLog(@"%@",intString);
            }
        }
        [self startGamePlayer2:board];
        [gameBoard setPlayer2Grid:board];
        [gameBoard setPlayer:2];
        [self setGameState:kGameStateActive];
        
    } else if (message->messageType == kMessageTypeMove) {
        [gameBoard addNumberOnGrid:message->moveNumber :message->player :message->xCoord :message->yCoord :message->score];
    } 
    else if (message -> messageType == kMessageTypeGameBoard){

    }
//    else if (message->messageType == kMessageTypeGameOver) {        
//        
//        MessageGameOver * messageGameOver = (MessageGameOver *) [data bytes];
//        CCLOG(@"Received game over with player 1 won: %d", messageGameOver->player1Won);
//        
//        if (messageGameOver->player1Won) {
//            [self endScene:kEndReasonLose];    
//        } else {
//            [self endScene:kEndReasonWin];    
//        }
//        
//    }    
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


// Add these new methods to the top of the file
- (void)sendData:(NSData *)data {
    NSError *error;
    BOOL success = [[SDKAppDelegate sharedInstance].match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
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

// Add right after sendRandomNumber
- (void)sendGameBegin {
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    BoardArray board = [gameBoard getGameBoard];
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

// Add right after update method
- (void)tryStartGame {
    
    if ([gameBoard isPlayer1] && gameState == kGameStateWaitingForStart) {

        UIButton *button = [self createButtonWithFrame:CGRectMake(0,0,0,0) title:nil image:nil font:nil textColor:nil target:self action:@selector(startGame:)];
        [self startGame:button:1];
        [self sendGameBegin];
    }
    
}

- (void)sendMove :(int)x :(int)y :(int)num :(int)player :(int)turnNumber :(int)score{
    
    Message message;
    message.messageType = kMessageTypeMove;
    message.xCoord = x;
    message.yCoord = y;
    message.player = player;
    message.turnNumber = turnNumber;
    message.moveNumber = num;
    message.score = score;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(Message)];    
    [self sendData:data];
    
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
    
    [mainMenu addSubview:mainLabel];
    [mainMenu addSubview:titleImage];
        
    UIImageView *ribbonView = [[UIImageView alloc] initWithFrame:ribbonRect];
    [ribbonView setImage:[UIImage imageNamed:@"Ribbon"]];        
    [mainMenu addSubview:ribbonView];
    
    gameBoard = [[SDKGameBoard alloc] initWithFrame:mainMenu.frame];
    
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
    
    [self.view addSubview:containerView];
    //=========Footer Code =============================//    
    //Add Footer view to the main app
    UIView *footerView;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    }
    else{footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 400, 320, 60)];}             
    UIImage *backgroundImage = [UIImage imageNamed:@"back_footer.png"];
    footerView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];  
    footerView.alpha = 0.8;
    
    //add Trophie
    UIImageView *trophieView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trophy.png"]];
    trophieView.frame = CGRectMake(10, 0, 50, 60);
    [footerView addSubview:trophieView];
    
    
    //Add static text 
    UILabel *weeklyAward = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, 200, 40)];
    weeklyAward.backgroundColor = [UIColor clearColor];
    weeklyAward.textColor = [UIColor whiteColor];
    weeklyAward.font = [UIFont fontWithName:@"Gotham-Black" size:18];
    weeklyAward.textAlignment = UITextAlignmentLeft;
    NSLog(@"%@",[UIFont familyNames]);
    NSLog(@"%@",[UIFont fontNamesForFamilyName:@"Gotham Condensed"]);
    NSLog(@"%@",[UIFont fontNamesForFamilyName:@"Gotham"]);
    weeklyAward.text = @"Weekly Award Challenge";
    [weeklyAward sizeToFit];
    [footerView addSubview:weeklyAward];
    
    //Add the dynamic text for days left to get the award
    NSString *daysLeftText = @"";
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setFirstWeekday:0]; // Sunday == 1, Saturday == 7
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents *todaysDate = [gregorian components:unitFlags fromDate:[NSDate date]];
    int dayOfWeek = todaysDate.weekday;      
    if (dayOfWeek == 7){
        daysLeftText = @"1 more day left";
    } else if (dayOfWeek == 1){
        daysLeftText = @"last day of the"; 
    } else {        
        
        dayOfWeek = (8 - dayOfWeek);
        daysLeftText = [NSString stringWithFormat:@"%i more days for the", dayOfWeek]; 
        
    }   
    
    //add dynamic label settings
    UILabel *dailyAward = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 200, 30)];
    dailyAward.backgroundColor = [UIColor clearColor];
    dailyAward.textColor = [UIColor whiteColor];
    dailyAward.font = [UIFont fontWithName:@"Gotham-Medium" size:12];
    dailyAward.textAlignment = UITextAlignmentLeft;
    dailyAward.text = [NSString stringWithFormat:@"%@", daysLeftText];    
    [dailyAward sizeToFit];
    [footerView addSubview:dailyAward];
    
    UIButton *clickableButton = [UIButton buttonWithType:UIButtonTypeCustom];     
    clickableButton.frame = CGRectMake(0, 0, 320, 60);
    [clickableButton addTarget:self action:@selector(userClickFooter:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:clickableButton];    
    [self.view addSubview:footerView];   
}

@synthesize touchView;

- (void) userClickFooter:(id) sender{
    
    //Get their stored email here and show a custom popup according to the user
    //if (email) --> show popupView
    //else -->different popup
    UIView *popUpView;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {popUpView = [[UIView alloc] initWithFrame:CGRectMake(275, 350, 278, 190)];}
    else{popUpView = [[UIView alloc] initWithFrame:CGRectMake(20, 50, 278, 190)];}
    if(!popUpShown){
        if(!isRegistered){
        popUpShown = true;
        //Pop up view settings
        
        popUpView.tag = 890;
        UIImage *backgroundImage = [UIImage imageNamed:@"popupbg.png"];
        popUpView.backgroundColor = [[UIColor alloc] initWithPatternImage:backgroundImage];  
        //popUpView.backgroundColor = [UIColor lightGrayColor];
        popUpView.alpha = 0.9;
        //popUpView.layer.borderWidth = 2.0;
        //popUpView.layer.borderColor = [[UIColor grayColor] CGColor];
        //popUpView.layer.cornerRadius = 6.0;
            
            touchView = [[TOTouchUIView alloc ] initWithFrame:CGRectMake(20, 50, 280, 190) ];
            [self.view addSubview:touchView ];
            [touchView setDelegate:self ];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopUpView:)];
        [recognizer setNumberOfTapsRequired:1];
        recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
        [popUpView.window addGestureRecognizer:recognizer];
        
        
        //Add label with information
        //Add static text 
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 260, 40)];
        infoLabel.numberOfLines = 0;
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.textColor = [UIColor whiteColor];
        infoLabel.font = [UIFont fontWithName:@"GothamRounded-Medium" size:12];
        infoLabel.textAlignment = UITextAlignmentCenter;
        infoLabel.lineBreakMode = UILineBreakModeWordWrap;
        infoLabel.text = @"Top GameCenter Achievers win prizes. Enter your email to participate."; 
        [popUpView addSubview:infoLabel];
        
        //add the later button
        UIButton *laterButton = [UIButton buttonWithType:UIButtonTypeCustom];  
        laterButton.backgroundColor = [UIColor clearColor];
        [laterButton setTitle:@"Later" forState:UIControlStateNormal];
        laterButton.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Medium" size:12];
        laterButton.frame = CGRectMake(150, 150, 60, 38);
        [laterButton addTarget:self action:@selector(closePopUpView) forControlEvents:UIControlEventTouchUpInside]; 
        //[laterButton sizeToFit];
        [popUpView addSubview:laterButton];
        
        //add send button
        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [sendButton.layer setCornerRadius:10.0f];
//        [sendButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
//        [sendButton.layer setBorderWidth:1.5f];
//        [sendButton.layer setShadowColor:[UIColor blackColor].CGColor];
//        [sendButton.layer setShadowOpacity:0.8];
//        [sendButton.layer setShadowRadius:3.0];
//        [sendButton.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
        //sendButton.backgroundColor = [UIColor colorWithRed:0.12 green:0.34 blue:0.87 alpha:1.0];
        UIImage *backgroundSendImage = [UIImage imageNamed:@"DoneButton.png"];
        sendButton.backgroundColor = [[UIColor alloc] initWithPatternImage:backgroundSendImage]; 
        //[sendButton setTitleEdgeInsets:UIEdgeInsetsMake(3.0, 4.0, 0.0, 0.0)];
        //[sendButton setTitle:@"Done" forState:UIControlStateNormal];
        //sendButton.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Medium" size:16];
        sendButton.frame = CGRectMake(200, 140, 60, 38);
        [sendButton addTarget:self action:@selector(sendInfo) forControlEvents:UIControlEventTouchUpInside]; 
        
        //[sendButton sizeToFit];
        [popUpView addSubview:sendButton];
        
        //add the UITextField
        UITextField *emailField = [[UITextField alloc] initWithFrame:CGRectMake(10, 90, 260, 45)];   
        emailField.delegate = (id) self;
        emailField.tag = 666;
        emailField.textColor = [UIColor blackColor];    
        emailField.font = [UIFont fontWithName:@"GothamRounded-Medium" size:14];    
        emailField.placeholder = @"Enter your email";            
        emailField.keyboardType = UIKeyboardTypeDefault;    
        emailField.returnKeyType = UIReturnKeyDone;        
        emailField.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0  alpha:1.0];    
        emailField.layer.borderColor = [[UIColor grayColor] CGColor];    
        emailField.layer.borderWidth =2.0;    
        emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter; 
        [popUpView addSubview:emailField];
        [self.view addSubview:popUpView]; 
        }
        else {
            popUpShown = true;
            //Pop up view settings
            popUpView.tag = 890;
            UIImage *backgroundImage = [UIImage imageNamed:@"popupbg.png"];
            popUpView.backgroundColor = [[UIColor alloc] initWithPatternImage:backgroundImage];  
            //popUpView.backgroundColor = [UIColor lightGrayColor];
            popUpView.alpha = 0.9;
            //popUpView.layer.borderWidth = 2.0;
            //popUpView.layer.borderColor = [[UIColor grayColor] CGColor];
            //popUpView.layer.cornerRadius = 6.0;
            
            
            touchView = [[TOTouchUIView alloc ] initWithFrame:CGRectMake(20, 50, 280, 190) ];
            [self.view addSubview:touchView ];
            [touchView setDelegate:self ];
            
//            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopUpView:)];
//            [recognizer setNumberOfTapsRequired:1];
//            recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
//            [popUpView.window addGestureRecognizer:recognizer];
//            
            UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 260, 40)];
            infoLabel.numberOfLines = 2;
            infoLabel.backgroundColor = [UIColor clearColor];
            infoLabel.textColor = [UIColor whiteColor];
            infoLabel.font = [UIFont fontWithName:@"Gotham-Black" size:16];
            infoLabel.textAlignment = UITextAlignmentCenter;
            infoLabel.lineBreakMode = UILineBreakModeWordWrap;
            infoLabel.text = @"Royal Sudoku is holding a Weekly Award Challenge"; 
            [popUpView addSubview:infoLabel];
            
            UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 75, 260, 60)];
            secondLabel.numberOfLines = 3;
            secondLabel.backgroundColor = [UIColor clearColor];
            secondLabel.textColor = [UIColor whiteColor];
            secondLabel.font = [UIFont fontWithName:@"Gotham-Black" size:12];
            secondLabel.textAlignment = UITextAlignmentCenter;
            secondLabel.lineBreakMode = UILineBreakModeWordWrap;
            secondLabel.text = @"Top GameCenter Achievements and Leaderboards can now award physical prizes"; 
            [popUpView addSubview:secondLabel];
            
            UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *backgroundSendImage = [UIImage imageNamed:@"greenbutton.png"];
            sendButton.backgroundColor = [[UIColor alloc] initWithPatternImage:backgroundSendImage]; 
            sendButton.frame = CGRectMake(58, 140, 180, 21);
            [sendButton setTitle:@"Play now to win the weekly prize!" forState:UIControlStateNormal];
            sendButton.titleLabel.font = [UIFont fontWithName:@"Gotham-Black" size:10];
            [sendButton addTarget:self action:@selector(linkButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [popUpView addSubview:sendButton];
            [self.view addSubview:popUpView];
        }
        
         
    }
    
}

-(IBAction)linkButtonClick:(id)sender {
    NSString* launchUrl = @"http://loopjoy.com";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
    [self closePopUpView];
}

- (void) uiViewTouched:(BOOL)wasInside
{
    if( wasInside ){}
        // Your code for inside touches...
        else
            // Your code for outside touches...
        {[self closePopUpView];}
}


- (void) sendInfo {
    
    UITextField *emailField = (UITextField *)[self.view viewWithTag:666];
    NSString *emailString = emailField.text;    
    NSLog(@"EMAIL %@", emailString);
    if (![self validateInputWithString:emailString]) {           
        emailField.text= @"";        
        emailField.placeholder = @"Please enter a valid email";
        
    } else {
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://loopjoy.com/users"]];
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        NSString *playerID = localPlayer.playerID;
        
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        
        NSString *xmlString = [NSString stringWithFormat:@"{ \"user\": { \"email\": \"%@\", \"gamecenter_id\": \"%@\", \"facebook_id\": \"none\" } }",emailString,playerID];
        NSLog(@"%@",xmlString);
        
        [request setValue:[NSString stringWithFormat:@"%d",[xmlString length]] forHTTPHeaderField:@"Content-length"];
        
        [request setHTTPBody:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
        
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        //Send the emailString to the back end now!
        NSLog(@"Correct email %@",playerID);
        
    }    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    [self closePopUpView];
}

- (void) closePopUpView {
    
    popUpShown = false;
    UIView *thePopUp = [self.view viewWithTag:890];
    [thePopUp removeFromSuperview];
    
}

- (BOOL)validateInputWithString:(NSString *)aString {
    
    NSString * const regularExpression = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";    
    NSError *error = NULL;    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpression                                  
                                                                           options:NSRegularExpressionCaseInsensitive                                  
                                                                             error:&error];    
    if (error) {        
        NSLog(@"error %@", error);        
    }
    
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:aString                                  
                                                        options:0                                  
                                                          range:NSMakeRange(0, [aString length])];
    
    return numberOfMatches > 0;    
}

//method for the next button in the keyboard
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    NSString *emailString = textField.text;    
    NSLog(@"EMAIL %@", emailString);
    if (![self validateInputWithString:emailString]) {           
        textField.text= @"";        
        textField.placeholder = @"Please enter a valid email";
        
    } else {
        //Send the emailString to the back end now!
        NSLog(@"Correct email");
        [textField resignFirstResponder];
        [self sendInfo];
        [self closePopUpView];
        
    }
    
    return NO;
}

- (void) setRegistered:(BOOL)registration {
    isRegistered = registration;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    mainMenu = nil;
    gameBoard = nil;
    containerView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

@implementation TOTouchUIView

#pragma mark - Synthesize
@synthesize delegate;

#pragma mark - Touches
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if( point.x > 0 && point.x < self.frame.size.width && point.y > 0 && point.y < self.frame.size.height )
    {
        [delegate uiViewTouched:YES ];
        return YES;
    }
    
    [delegate uiViewTouched:NO ];
    return NO;
}
@end
