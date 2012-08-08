//
//  TOTouchView.m
//  Store
//
//  Created by Tennyson Hinds on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LJTouchView.h"

@implementation LJTouchUIView

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