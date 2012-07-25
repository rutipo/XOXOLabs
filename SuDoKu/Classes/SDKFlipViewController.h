//
//  SDKFlipViewController.h
//
//  Created by Charles-André LEDUC on 28/06/11.
//  Copyright 2011. All rights reserved.
//

@protocol SDKFlipViewControllerDelegate <NSObject>
- (void)flipViewControllerDidFinish:(UIViewController *)viewController;
@end

@interface SDKFlipViewController : UIViewController <UIScrollViewDelegate>
{      
    UIScrollView *scrollView;
    UIPageControl *pageControl;
	
    BOOL pageControlIsChangingPage;
}
@property(nonatomic, assign) id<SDKFlipViewControllerDelegate> delegate;
- (void)done:(id)sender;
- (void)changePage:(id)sender;
@end

@interface SDKPrefsViewController : SDKFlipViewController
{  
    NSArray *bgArray;
    NSArray *thArray;
}
@end

@interface SDKRulesViewController : SDKFlipViewController
@end

@interface UIPageControl(Gradient)
@end