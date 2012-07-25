//
//  LJStorePopUpView.h
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LJNetworkDelegate.h"

#define STREET_ADDRESS_FIELD_TAG 22
#define CITY_FIELD_TAG 23
#define ZIP_FIELD_TAG 24
#define STATE_FIELD_TAG 25
#define EMAIL_FIELD_TAG 27


@interface LJStorePopUpView : UIView <UITextFieldDelegate, UIPickerViewDelegate, NSURLConnectionDelegate>{
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
@end