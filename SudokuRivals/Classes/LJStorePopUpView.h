//
//  LJStorePopUpView.h
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "PayPal.h"

#define STREET_ADDRESS_FIELD_TAG 22
#define CITY_FIELD_TAG 23
#define ZIP_FIELD_TAG 24
#define STATE_FIELD_TAG 25
#define EMAIL_FIELD_TAG 27


@interface LJStorePopUpView : UIView <UITextFieldDelegate, UIPickerViewDelegate, NSURLConnectionDelegate, PayPalPaymentDelegate>{
    NSMutableArray *pickerChoices;
    
    NSString *streetAddressFieldText;
    NSString *cityFieldText;
    NSString *stateFieldText;
    NSString *zipFieldText;
    NSString *emailFieldText;
    NSString *sizeChoice;
    
    UIActionSheet *actionSheet;
    
    UIView *formView;
    UIButton *sizeButton;
}
- (void)dismissActionSheet;
- (void)dismissForm;
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
-(void)connectionDidFinishLoading:(NSURLConnection *)connection;
@end