//
//  LJFormBuilder.h
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface LJFormBuilder : UITableViewController<UITextFieldDelegate>
{
}

- (UITextField *)addTextFieldWithLabel:(NSString *)text tag:(NSUInteger)tag toView:(UIView *)container placeholder:(NSString *)placeholder type:(UIKeyboardType)type delegate:(id<UITextFieldDelegate>)delegate;
- (UITextField *)addTextFieldWithLabel:(NSString *)text tag:(NSUInteger)tag toView:(UIView *)container placeholder:(NSString *)placeholder type:(UIKeyboardType)type;
- (UITextField *)addTextFieldWithLabel:(NSString *)text tag:(NSUInteger)tag toView:(UIView *)container placeholder:(NSString *)placeholder;
- (UITextField *)addTextFieldWithLabel:(NSString *)text tag:(NSUInteger)tag toView:(UIView *)container;

@end