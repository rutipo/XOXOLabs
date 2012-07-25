//
//  LJStorePopUpView.m
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LJStorePopUpView.h"
#import "LJMainViewController.h"
#import "PayPal.h"

@implementation LJStorePopUpView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UITextField *textField;
        UILabel *label;
        CGFloat yPos;
        int rowCount = 0;
        int heightOffset = 160;
        
        
        //Initialize Form View
        formView = [[UIView alloc] initWithFrame:CGRectMake(15,30,280,420)];
        UIImage *backgroundImage = [UIImage imageNamed:@"form_background.png"];
        formView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
        formView.alpha = 1;
        
        //LoopJoy "Get a Shirt!" text
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 280, 30)];
        label.text = @"Get a LoopJoy T-Shirt!";
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"Gotham-Black" size:18];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        [formView addSubview:label];
        
        
        //LoopJoy Dotted Line Spacer
        UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(20,50,240,10)];
        backgroundImage = [UIImage imageNamed:@"buy_menu_dropshadow.png"];
        spacerView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
        spacerView.alpha = 1;
        [formView addSubview:spacerView];
        
        
        //LoopJoy Shirt and Price Tag
        UIView *shirtView = [[UIView alloc] initWithFrame:CGRectMake(60,60,75,95)];
        backgroundImage = [UIImage imageNamed:@"loopjoy_shirt.png"];
        shirtView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
        shirtView.alpha = 1;
        [formView addSubview:shirtView];
        
        UIView *priceTagView = [[UIView alloc] initWithFrame:CGRectMake(160,70,82,92)];
        backgroundImage = [UIImage imageNamed:@"price_tag.png"];
        priceTagView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
        priceTagView.alpha = 1;
        [formView addSubview:priceTagView];
        
    
        yPos = round((40. * rowCount) + heightOffset + 10);
        
        //LoopJoy Size Tag & Button
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, yPos, 110, 30)];
        label.text = @"Size:";
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14.];
        label.textAlignment = UITextAlignmentRight;
        label.backgroundColor = [UIColor clearColor];
        [formView addSubview:label];
        
        sizeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [sizeButton addTarget:self action:@selector(displayPicker) forControlEvents:UIControlEventTouchUpInside];
        sizeButton.frame = CGRectMake(115,yPos + 3,100,24);
        [sizeButton setTitle:@"Pick a size | ▾" forState:UIControlStateNormal];
        sizeButton.titleLabel.textColor = [UIColor blackColor];
        sizeButton.titleLabel.font = [UIFont systemFontOfSize:14.];
        sizeButton.backgroundColor = [UIColor clearColor];
        sizeButton.titleLabel.textAlignment = UITextAlignmentRight;
        [formView addSubview:sizeButton];
        
        rowCount++;
        
        
        //LJStoreSizePickerView *pickerView = [[LJStoreSizePickerView alloc] initWithFrame:CGRectMake(115,yPos,150,30)];
        //[formView addSubview:pickerView];
        
        
        
        //LoopJoy Ship-To Text & Button
        yPos = round((40. * rowCount) + heightOffset);
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, yPos, 110, 30)];
        label.text = @"Ship To:";
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14.];
        label.textAlignment = UITextAlignmentRight;
        label.backgroundColor = [UIColor clearColor];
        [formView addSubview:label];
        
        textField = [[UITextField alloc] initWithFrame:CGRectMake(115, yPos, 150, 30)];
        textField.tag = STREET_ADDRESS_FIELD_TAG;
        textField.placeholder = @"123 Apple Street";
        textField.font = [UIFont systemFontOfSize:14.];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.delegate = self;
        textField.keyboardType =UIKeyboardTypeDefault;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [formView addSubview:textField];
        rowCount++;
        
        //City Field
        yPos = round((40. * rowCount) + heightOffset);
        textField = [[UITextField alloc] initWithFrame:CGRectMake(115, yPos, 90, 30)];
        textField.tag = CITY_FIELD_TAG;
        textField.placeholder = @"City";
        textField.font = [UIFont systemFontOfSize:14.];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.delegate = self;
        textField.keyboardType =UIKeyboardTypeDefault;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [formView addSubview:textField];
        
        //State Field
        textField = [[UITextField alloc] initWithFrame:CGRectMake(115 + 100, yPos, 50, 30)];
        textField.tag = STATE_FIELD_TAG;
        textField.placeholder = @"State";
        textField.font = [UIFont systemFontOfSize:14.];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.delegate = self;
        textField.keyboardType =UIKeyboardTypeDefault;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [formView addSubview:textField];
        rowCount++;
        
        //Zip Field
        yPos = round((40. * rowCount) + heightOffset);
        textField = [[UITextField alloc] initWithFrame:CGRectMake(115, yPos, 90, 30)];
        textField.tag = ZIP_FIELD_TAG;
        textField.placeholder = @"Zip Code";
        textField.font = [UIFont systemFontOfSize:14.];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.delegate = self;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [formView addSubview:textField];
        rowCount++;
        
        //Email Label & Field
        yPos = round((40. * rowCount) + heightOffset);
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, yPos, 110, 30)];
        label.text = @"Email:";
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14.];
        label.textAlignment = UITextAlignmentRight;
        label.backgroundColor = [UIColor clearColor];
        [formView addSubview:label];
        
        textField = [[UITextField alloc] initWithFrame:CGRectMake(115, yPos, 150, 30)];
        textField.tag = EMAIL_FIELD_TAG;
        textField.placeholder = @"you@example.com";
        textField.font = [UIFont systemFontOfSize:14.];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.delegate = self;
        textField.keyboardType =UIKeyboardTypeEmailAddress;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [formView addSubview:textField];
        
        rowCount ++;
        
        yPos = round((40. * rowCount) + heightOffset);
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buyButton addTarget:self action:@selector(dismissForm) forControlEvents:UIControlEventTouchUpInside];
        buyButton.frame = CGRectMake(115,yPos + 3,100,30);
        [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
        buyButton.titleLabel.font = [UIFont fontWithName:@"Gotham-Black" size:12];
        buyButton.titleLabel.backgroundColor = [UIColor clearColor];
        //buyButton.titleLabel.textColor = [UIColor blackColor];
        //buyButton.titleLabel.font = [UIFont systemFontOfSize:14.];
        buyButton.backgroundColor = [UIColor clearColor];
        buyButton.titleLabel.textAlignment = UITextAlignmentCenter;
        [formView addSubview:buyButton];
        
        
        [self addSubview:formView];
        
    }
    return self;
}

#pragma mark TextField Delegate Implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    switch (textField.tag){
        case STREET_ADDRESS_FIELD_TAG:
            streetAddressFieldText = textField.text;
            NSLog(@"%@", streetAddressFieldText);
            break;
        case CITY_FIELD_TAG:
            cityFieldText = textField.text;
            break;
        case STATE_FIELD_TAG:
            stateFieldText = textField.text;
            break;
        case ZIP_FIELD_TAG:
            zipFieldText = textField.text;
            break;
        case EMAIL_FIELD_TAG:
            emailFieldText = textField.text;
            break;
    }
    [textField resignFirstResponder];
    return true;
}

-(void)displayPicker
{
//    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,480,320,200)];
//    pickerView.delegate = self;
//    pickerView.showsSelectionIndicator = TRUE;
//    pickerView.alpha = 0;
//    
//    pickerChoices = [[NSMutableArray alloc] init];
//    [pickerChoices addObject:@"Small"];
//    [pickerChoices addObject:@"Medium"];
//    [pickerChoices addObject:@"Large"];
//    [pickerChoices addObject:@"Extra-Large"];
//    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.6];
//    CGAffineTransform transfrom = CGAffineTransformMakeTranslation(0, -200);
//    pickerView.transform = transfrom;
//    pickerView.alpha = 1;
//    [self addSubview:pickerView];
//    [UIView commitAnimations];
    
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.delegate = self;
    
    pickerChoices = [[NSMutableArray alloc] init];
    [pickerChoices addObject:@"Small"];
    [pickerChoices addObject:@"Medium"];
    [pickerChoices addObject:@"Large"];
    [pickerChoices addObject:@"Extra-Large"];
    
    [actionSheet addSubview:pickerView];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(dismissActionSheet) forControlEvents:UIControlEventValueChanged];
    [actionSheet addSubview:closeButton];
    
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    
    [actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
    
    
    
    
}

- (void)dismissForm{
    NSString *messageString = [NSString stringWithFormat:@"Thanks for your Order! You will recieve a confirmation email shortly"]; 
    LJNetworkDelegate *networkDelegate = [[LJNetworkDelegate alloc] initWithAddress:@"http://localhost:3000/orders" :URLRequestPOST delegate:self];
    
    //{"commit"=>"Create Order", "authenticity_token"=>"7zAlq0lQGtyyD+UVG/pOfViyLGYljWNjykDzpp1SxGQ=", "utf8"=>"✓", "order"=>{"price"=>"1", "street_address"=>"My", "state"=>"Friends", "country"=>"Better", "city"=>"Are", "customer_id"=>"1", "zipcode"=>"1"}}
    
    NSString *order = [NSString stringWithFormat:@"{\"commit\":\"Create Order\",\"order\":{\"price\":\"%@\",\"street_address\":\"%@\",\"state\":\"%@\",\"country\":\"%@\",\"city\":\"%@\",\"zipcode\":\"%@\"}}",@"1",streetAddressFieldText,stateFieldText,@"USA",cityFieldText,zipFieldText];  
    NSLog(@"%@",order);
    [networkDelegate setBody:order];
    [networkDelegate execute];
    
    UIAlertView *alertGameStarting = [[UIAlertView alloc]
                         initWithTitle: @"Thanks!"
                         message: messageString
                         delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
    [alertGameStarting show];
    [formView removeFromSuperview];
    [[LJMainViewController sharedController] clear];
}

- (void)dismissActionSheet{
    [sizeButton setTitle:sizeChoice forState:UIControlStateNormal];
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    sizeChoice = [pickerChoices objectAtIndex:row];
    [pickerView resignFirstResponder];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [pickerChoices count];
}

// tell the picker how many components it will have. A component is basically a column
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [pickerChoices objectAtIndex:row];
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    return sectionWidth;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"did fail in here: %@",[error localizedDescription]);
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"did receive data: %@",string);
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"did receive response ");
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"did finish loading");
}

@end
