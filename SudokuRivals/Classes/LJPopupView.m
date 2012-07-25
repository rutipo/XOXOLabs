//
//  LJPopupView.m
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LJPopupView.h"

@implementation LJPopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
    [self addSubview:footerView];
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
