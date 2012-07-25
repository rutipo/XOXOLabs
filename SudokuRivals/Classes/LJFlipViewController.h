//
//  LJFlipViewController.h
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@protocol LJFlipViewControllerDelegate <NSObject>
- (void)flipViewControllerDidFinish:(UIViewController *)viewController;
@end

@interface LJFlipViewController : UIViewController <UIScrollViewDelegate>
{      
    UIScrollView *scrollView;
    UIPageControl *pageControl;
	
    BOOL pageControlIsChangingPage;
}
@property(nonatomic, assign) id<LJFlipViewControllerDelegate> delegate;
- (void)done:(id)sender;
- (void)changePage:(id)sender;
@end

@interface LJPrefsViewController : LJFlipViewController
{  
    NSArray *bgArray;
    NSArray *thArray;
}
@end

@interface LJRulesViewController : LJFlipViewController
@end

@interface UIPageControl(Gradient)
@end