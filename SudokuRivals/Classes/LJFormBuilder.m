//
//  LJFormBuilder.m
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LJFormBuilder.h"

@interface LJFormBuilder ()

@end

@implementation LJFormBuilder

- (UITextField *)addTextFieldWithLabel:(NSString *)text tag:(NSUInteger)tag toView:(UIView *)container placeholder:(NSString *)placeholder type:(UIKeyboardType)type delegate:(id<UITextFieldDelegate>)delegate {
	CGFloat yPos = round((40. * container.subviews.count / 2.) + 10.) + 10;
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, yPos, 110, 30)];
	label.text = text;
    label.textColor = [UIColor whiteColor];
	label.font = [UIFont systemFontOfSize:14.];
	label.textAlignment = UITextAlignmentRight;
	label.backgroundColor = [UIColor clearColor];
	[container addSubview:label];
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(120, yPos, 150, 30)];
	textField.tag = tag;
	textField.placeholder = placeholder;
	textField.font = [UIFont systemFontOfSize:14.];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.delegate = delegate;
	textField.keyboardType = type;
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	[container addSubview:textField];
	return textField;
}

- (UITextField *)addTextFieldWithLabel:(NSString *)text tag:(NSUInteger)tag toView:(UIView *)container placeholder:(NSString *)placeholder type:(UIKeyboardType)type {
	return [self addTextFieldWithLabel:text tag:tag toView:container placeholder:placeholder type:type delegate:self];
}

- (UITextField *)addTextFieldWithLabel:(NSString *)text tag:(NSUInteger)tag toView:(UIView *)container placeholder:(NSString *)placeholder {
	return [self addTextFieldWithLabel:text tag:tag toView:container placeholder:placeholder type:UIKeyboardTypeDefault];
}

- (UITextField *)addTextFieldWithLabel:(NSString *)text tag:(NSUInteger)tag toView:(UIView *)container {
	return [self addTextFieldWithLabel:text tag:tag toView:container placeholder:[[NSString alloc] initWithString:@""]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag){
        //case STREET_ADDRESS_FIELD_TAG:
            //Do something.
            [textField resignFirstResponder];
          //  break;
        //case CITY_FIELD_TAG:
            //Do something
            //break;
        //case ZIP_FIELD_TAG:
            //do something
          //  break;
        //case EMAIL_FIELD_TAG:
            //Do something
          //  break;
    }
	return TRUE;
}


@end
