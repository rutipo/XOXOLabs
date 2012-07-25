//
//  LJFlipViewController.m
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "LJFlipViewController.h"
#import "LJMainViewController.h"
#import "LJAppDelegate.h"

#pragma mark SDKFlipViewController

@implementation LJFlipViewController

@synthesize delegate=_delegate;

#pragma mark - Actions

- (void)done:(id)sender
{   
    if ([self.delegate respondsToSelector:@selector(flipViewControllerDidFinish:)])
        [self.delegate flipViewControllerDidFinish:self]; 
}

- (void)changePage:(id)sender 
{
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
	
    [scrollView scrollRectToVisible:frame animated:YES];
    
    pageControlIsChangingPage = YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    if (pageControlIsChangingPage)
        return;
    
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView 
{
    pageControlIsChangingPage = NO;
}

#pragma mark - View lifecycle

- (void)loadView
{    
    [super loadView];
    
    CGRect mainRect = self.view.bounds;
    CGFloat controlHeight = 32;
    
    if (self.navigationController)
        mainRect.size.height -= self.navigationController.navigationBar.bounds.size.height;
    
    CGRect scrollRect = mainRect;
    scrollRect.size.height -= controlHeight;
    
    scrollView = [[UIScrollView alloc] initWithFrame:scrollRect];
    scrollView.delegate = self;
	scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	scrollView.clipsToBounds = NO;
	scrollView.scrollEnabled = YES;
	scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = [UIColor clearColor];
	[scrollView setCanCancelContentTouches:YES];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, mainRect.size.height-controlHeight, mainRect.size.width, controlHeight)];
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.layer.shadowOffset = CGSizeMake(0, -2);
    pageControl.layer.shadowOpacity = 0.6;
    pageControl.layer.shadowPath = [UIBezierPath bezierPathWithRect:pageControl.bounds].CGPath;
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:scrollView];
    [self.view addSubview:pageControl];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

#pragma mark - LJPrefsViewController

@implementation LJPrefsViewController

- (void)done:(id)sender
{    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[bgArray objectAtIndex:pageControl.currentPage] forKey:UI_BG];
    [userDefaults setObject:[thArray objectAtIndex:pageControl.currentPage] forKey:UI_PAPER];
    
    [[LJMainViewController sharedController] setNeedsDisplay];
    
    [super done:sender];
}

- (void)viewDidLoad
{
    if (bgArray == nil)
        bgArray = [NSArray arrayWithObjects:@"Wood_dark", @"Wood_light", @"Metal_brushed", nil];
    
    if (thArray == nil)
        thArray = [NSArray arrayWithObjects:@"Paper_old_main", @"Paper_japanese_main", @"Paper_plain_main", nil];
    
    self.title = NSLocalizedString(@"Theme", @"Theme");
    
	CGFloat cx = 0;
    CGFloat offset = 32;
    CGFloat shadOffset = 2;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        shadOffset *= 3;
        offset *= 3;
    }
    
	for (int i = 0; i < [bgArray count]; i++)
    {
		CGRect rect = scrollView.frame;
		rect.origin.x += cx;
        rect.origin.y = 0;
        
        UIView *contentView = [[UIView alloc] initWithFrame:rect];
        contentView.backgroundColor = [UIColor clearColor];
        contentView.layer.shadowOffset = CGSizeMake(0, shadOffset);
        contentView.layer.shadowOpacity = 0.75;
        
        UIImage *bgImage = [UIImage imageNamed:[bgArray objectAtIndex:i]];
        UIView *newBG = [[UIView alloc] initWithFrame:CGRectMake(offset/2, offset/2, rect.size.width-offset, rect.size.height-offset)];
        newBG.layer.contents = (id)bgImage.CGImage;
        
        contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:newBG.frame].CGPath;
        
        UIImage *themeImage = [UIImage imageNamed:[thArray objectAtIndex:i]];
        UIView *newTheme = [[UIView alloc] initWithFrame:CGRectMake(offset, offset/2, newBG.frame.size.width-(offset*2), newBG.frame.size.height-offset)];
        newTheme.layer.contents = (id)themeImage.CGImage;
        newTheme.backgroundColor = [UIColor clearColor];
        newTheme.layer.shadowOffset = CGSizeMake(0, shadOffset);
        newTheme.layer.shadowOpacity = 0.75;
        newTheme.layer.shadowPath = [UIBezierPath bezierPathWithRect:newTheme.bounds].CGPath;
        
        [newBG addSubview:newTheme];
        [contentView addSubview:newBG];
        [scrollView addSubview:contentView];
        
		cx += scrollView.frame.size.width;
	}
    
    [scrollView setContentSize:CGSizeMake(cx, [scrollView bounds].size.height)];
	
	pageControl.numberOfPages = [bgArray count];
    
    [super viewDidLoad];
}

@end

#pragma mark - SDKRulesViewController

@implementation LJRulesViewController

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"Rules", @"Rules");
    
    CGFloat offset = 16;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        offset *= 4;
    
    CGRect insetRect = scrollView.bounds;
    insetRect.origin.x += offset;
    insetRect.size.width -= offset*2;
    CGFloat fontSize = 13.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        fontSize = 20.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        insetRect.size.height /= 2;
    
    UIView *pageOneView = [[UIView alloc] initWithFrame:scrollView.bounds];
    
    UILabel *pageOneText = [[UILabel alloc] initWithFrame:insetRect];
    pageOneText.backgroundColor = [UIColor clearColor];
    pageOneText.numberOfLines = 0;
    pageOneText.text = NSLocalizedString(@"'Sudoku' is a logic-based, combinatorial number-placement puzzle. The objective is to fill a 9×9 grid with digits so that each column, each row, and each of the nine 3×3 sub-grids that compose the grid (also called 'blocks' or 'regions') contains all of the digits from 1 to 9.\n\nCompleted puzzles are always a type of Latin square with an additional constraint on the contents of individual regions. For example, the same single integer may not appear twice in the same 9x9 playing board row or column or in any of the nine 3x3 subregions of the 9x9 playing board.\n\nThe puzzle was popularized in 1986 by the Japanese puzzle company Nikoli under the name 'Sudoku', meaning 'single number', and became an international hit in 2005.", @"Page One Text");
    pageOneText.font = [UIFont boldSystemFontOfSize:fontSize];
    
    UILabel *pageTwoText = [[UILabel alloc] initWithFrame:insetRect];
    pageTwoText.backgroundColor = [UIColor clearColor];
    pageTwoText.numberOfLines = 0;
    pageTwoText.text = NSLocalizedString(@"The objective of the game is to fill all the blank squares in a game with the correct numbers. There are three very simple constraints to follow.\n\nIn a 9 by 9 square Sudoku game:\n\n✓ Every row of 9 numbers must include all digits 1 through 9 in any order\n\n✓ Every column of 9 numbers must include all digits 1 through 9 in any order\n\n✓ Every 3 by 3 subsection of the 9 by 9 square must include all digits 1 through 9", @"Page Two Text");
    pageTwoText.font = [UIFont boldSystemFontOfSize:fontSize];
    
    UIImage *staticBG = [UIImage imageNamed:@"Rules.png"];
    self.view.layer.contents = (id)staticBG.CGImage;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        UIView *pageTwoView = [[UIView alloc] initWithFrame:scrollView.bounds];
        
        [pageOneView addSubview:pageOneText];
        [pageTwoView addSubview:pageTwoText];
        
        NSArray *views = [NSArray arrayWithObjects:pageOneView, pageTwoView, nil];
        
        CGFloat cx = 0;
        
        for (UIView *view in views)
        {
            CGRect rect = scrollView.frame;
            rect.origin.x += cx;
            rect.origin.y = 0;
            
            [view setFrame:rect];
            
            [scrollView addSubview:view];
            
            cx += scrollView.frame.size.width;
        } 
        
        [scrollView setContentSize:CGSizeMake(cx, [scrollView bounds].size.height)];
        
        pageControl.numberOfPages = [views count];
    }
    else
    {
        CGRect textOffset = pageTwoText.frame;
        textOffset.origin.y += textOffset.size.height;
        pageTwoText.frame = textOffset;
        
        [scrollView addSubview:pageOneView];
        
        [pageOneView addSubview:pageOneText];
        [pageOneView addSubview:pageTwoText];
        
        pageControl.numberOfPages = 1;
    }
    
    [super viewDidLoad];
}

@end

#pragma mark - UIPageControl(Gradient)

@implementation UIPageControl(Gradient)

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef myColorspace=CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 1.0, 0.0 };
    CGFloat components[8] = { .1, .1, .1, 1.0,    .3, .3, .3, 1.0 };
    
    CGGradientRef myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, num_locations);
	
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = 0.0;
	myStartPoint.y = 0.0;
	myEndPoint.x = 0.0;
	myEndPoint.y = rect.size.height/2;
    
    CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(myGradient);
}

@end
