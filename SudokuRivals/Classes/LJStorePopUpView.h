
//
//  LJStorePopUpView.h
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


#import "PayPal.h"
#import "LJTouchView.h"

#define STREET_ADDRESS_FIELD_TAG 22
#define CITY_FIELD_TAG 23
#define ZIP_FIELD_TAG 24
#define STATE_FIELD_TAG 25
#define EMAIL_FIELD_TAG 27


@interface LJStorePopUpView : UIView <UITextFieldDelegate, UIPickerViewDelegate, NSURLConnectionDelegate, PayPalPaymentDelegate, LJTouchUIViewDelegate>{
    NSMutableArray *pickerChoices;
    
    NSString *streetAddressFieldText;
    NSString *cityFieldText;
    NSString *stateFieldText;
    NSString *zipFieldText;
    NSString *emailFieldText;
    NSString *sizeChoice;
    
    UIActionSheet *actionSheet;
    
    LJTouchUIView *touchView;
    UIView *formView;
    UIButton *sizeButton;
    UIButton *sizeButtonXS;
    UIButton *sizeButtonS;
    UIButton *sizeButtonM;
    UIButton *sizeButtonL;
    UIButton *sizeButtonXL;
}
- (void)dismissActionSheet;
- (void)dismissForm;
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
-(void)connectionDidFinishLoading:(NSURLConnection *)connection;
@end