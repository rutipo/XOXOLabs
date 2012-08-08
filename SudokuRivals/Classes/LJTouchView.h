//
//  TOTouchView.h
//  Store
//
//  Created by Tennyson Hinds on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LJTouchUIViewDelegate

- (void) uiViewTouched:(BOOL)wasInside;

@end

@interface LJTouchUIView : UIView 

// Properties
@property (nonatomic, assign) id delegate;

@end