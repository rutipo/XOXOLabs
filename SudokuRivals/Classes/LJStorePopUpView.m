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
#import "PayPalPayment.h"
#import "LJNetworkService.h"

@implementation LJStorePopUpView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        

        
        //UITextField *textField;
        UILabel *label;
        CGFloat yPos;
        int rowCount = 0;
        int heightOffset = 160;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            formView = [[UIView alloc] initWithFrame:CGRectMake(95,155,590,610)];
            touchView = [[LJTouchUIView alloc ] initWithFrame:CGRectMake(95,155,590,610)];
            [touchView setDelegate:self];
            UIImage *backgroundImage = [UIImage imageNamed:@"form_bg_large.png"];
            formView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
            formView.alpha = 1;
            
            //LoopJoy "Get a Shirt!" text
            label = [[UILabel alloc] initWithFrame:CGRectMake(108, 25, 375, 32)];
            label.text = @"Get a LoopJoy T-Shirt!";
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont fontWithName:@"Gotham-Black" size:30];
            label.textAlignment = UITextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            [formView addSubview:label];
            
            //LoopJoy Shirt and Price Tag
            UIView *shirtView = [[UIView alloc] initWithFrame:CGRectMake(185,100,230,226)];
            backgroundImage = [UIImage imageNamed:@"shirt_large.png"];
            shirtView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
            shirtView.alpha = 1;
            [formView addSubview:shirtView];
            
            rowCount ++;
            yPos = 400;
            
            //LoopJoy Size Tag & Button
            label = [[UILabel alloc] initWithFrame:CGRectMake(80, yPos - 30, 110, 30)];
            label.text = @"Size: ";
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:24.];
            label.textAlignment = UITextAlignmentRight;
            label.backgroundColor = [UIColor clearColor];
            [formView addSubview:label];
            
            int xOffset = 0;
            
            sizeButtonXS = [UIButton buttonWithType:UIButtonTypeCustom];
            [sizeButtonXS addTarget:self action:@selector(displayPicker:) forControlEvents:UIControlEventTouchUpInside];
            sizeButtonXS.frame = CGRectMake(195 + xOffset, yPos - 35, 52, 52);
            [sizeButtonXS setTitle:@"XS" forState:UIControlStateNormal];
            sizeButtonXS.titleLabel.textColor = [UIColor whiteColor];
            sizeButtonXS.titleLabel.backgroundColor = [UIColor clearColor];
            sizeButtonXS.titleLabel.font = [UIFont fontWithName:@"Gotham-Black" size:26];
            sizeButtonXS.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad_size_button_selected.png"]];
            sizeButtonXS.titleLabel.textAlignment = UITextAlignmentRight;
            [formView addSubview:sizeButtonXS];
            xOffset += 50;
            
            sizeButtonS = [UIButton buttonWithType:UIButtonTypeCustom];
            [sizeButtonS addTarget:self action:@selector(displayPicker:) forControlEvents:UIControlEventTouchUpInside];
            sizeButtonS.frame = CGRectMake(195 + xOffset, yPos - 35, 52, 52);
            [sizeButtonS setTitle:@"XS" forState:UIControlStateNormal];
            sizeButtonS.titleLabel.textColor = [UIColor whiteColor];
            sizeButtonS.titleLabel.backgroundColor = [UIColor clearColor];
            sizeButtonS.titleLabel.font = [UIFont fontWithName:@"Gotham-Black" size:26];
            [sizeButtonS setBackgroundImage:[UIImage imageNamed:@"ipad_size_button_unselected.png"] forState:UIControlStateNormal];
            sizeButtonS.titleLabel.textAlignment = UITextAlignmentRight;
            [formView addSubview:sizeButtonS];
            xOffset += 50;
            
            sizeButtonM = [UIButton buttonWithType:UIButtonTypeCustom];
            [sizeButtonM addTarget:self action:@selector(displayPicker:) forControlEvents:UIControlEventTouchUpInside];
            sizeButtonM.frame = CGRectMake(195 + xOffset, yPos - 35, 52, 52);
            [sizeButtonM setTitle:@"M" forState:UIControlStateNormal];
            sizeButtonM.titleLabel.textColor = [UIColor whiteColor];
            sizeButtonM.titleLabel.backgroundColor = [UIColor clearColor];
            sizeButtonM.titleLabel.font = [UIFont fontWithName:@"Gotham-Black" size:26];
            [sizeButtonM setBackgroundImage:[UIImage imageNamed:@"ipad_size_button_unselected.png"] forState:UIControlStateNormal];
            sizeButtonM.titleLabel.textAlignment = UITextAlignmentRight;
            [formView addSubview:sizeButtonM];
            xOffset += 50;
            
            sizeButtonL = [UIButton buttonWithType:UIButtonTypeCustom];
            [sizeButtonL addTarget:self action:@selector(displayPicker:) forControlEvents:UIControlEventTouchUpInside];
            sizeButtonL.frame = CGRectMake(195 + xOffset, yPos - 35, 52, 52);
            [sizeButtonL setTitle:@"L" forState:UIControlStateNormal];
            sizeButtonL.titleLabel.textColor = [UIColor whiteColor];
            sizeButtonL.titleLabel.backgroundColor = [UIColor clearColor];
            sizeButtonL.titleLabel.font = [UIFont fontWithName:@"Gotham-Black" size:26];
            [sizeButtonL setBackgroundImage:[UIImage imageNamed:@"ipad_size_button_unselected.png"] forState:UIControlStateNormal];
            sizeButtonL.titleLabel.textAlignment = UITextAlignmentRight;
            [formView addSubview:sizeButtonL];
            xOffset += 50;
            
            sizeButtonXL = [UIButton buttonWithType:UIButtonTypeCustom];
            [sizeButtonXL addTarget:self action:@selector(displayPicker:) forControlEvents:UIControlEventTouchUpInside];
            sizeButtonXL.frame = CGRectMake(195 + xOffset, yPos - 35, 52, 52);
            [sizeButtonXL setTitle:@"XL" forState:UIControlStateNormal];
            sizeButtonXL.titleLabel.textColor = [UIColor whiteColor];
            sizeButtonXL.titleLabel.backgroundColor = [UIColor clearColor];
            sizeButtonXL.titleLabel.font = [UIFont fontWithName:@"Gotham-Black" size:26];
            [sizeButtonXL setBackgroundImage:[UIImage imageNamed:@"ipad_size_button_unselected.png"] forState:UIControlStateNormal];
            sizeButtonXL.titleLabel.textAlignment = UITextAlignmentRight;
            [formView addSubview:sizeButtonXL];
            
            rowCount++;
            
            [PayPal initializeWithAppID:@"APP-09B355920Y2948247" forEnvironment:ENV_LIVE];
            [PayPal getPayPalInst].shippingEnabled = true;
            UIButton *button = [[PayPal getPayPalInst] getPayButtonWithTarget:self andAction:@selector(payWithPayPal) andButtonType:BUTTON_278x43];
            
            CGRect frame = button.frame;
            frame.origin.x = round((formView.frame.size.width - button.frame.size.width) / 2.);
            frame.origin.y = round(yPos + button.frame.size.height/2 + 10);
            button.frame = frame;
            [formView addSubview:button];
            
        }
        else {
        //Initialize Form View
        formView = [[UIView alloc] initWithFrame:CGRectMake(15,60,280,320)];
        touchView = [[LJTouchUIView alloc ] initWithFrame:CGRectMake(15,60,280,320)];
        [touchView setDelegate:self];
        UIImage *backgroundImage = [UIImage imageNamed:@"form_bg.png"];
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
        
        //LoopJoy Shirt and Price Tag
        UIView *shirtView = [[UIView alloc] initWithFrame:CGRectMake(80,60,131,129)];
        backgroundImage = [UIImage imageNamed:@"pop_over_tshirt.png"];
        shirtView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
        shirtView.alpha = 1;
        [formView addSubview:shirtView];
        
        rowCount ++;
        yPos = round((40. * rowCount) + heightOffset + 10);
        
        //LoopJoy Size Tag & Button
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, yPos, 110, 30)];
        label.text = @"Size:";
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14.];
        label.textAlignment = UITextAlignmentRight;
        label.backgroundColor = [UIColor clearColor];
        [formView addSubview:label];
        
        sizeButtonXS = [UIButton buttonWithType:UIButtonTypeCustom];
        [sizeButton addTarget:self action:@selector(displayPicker) forControlEvents:UIControlEventTouchUpInside];
        sizeButton.frame = CGRectMake(115,yPos,126,31);
        [sizeButton setTitle:@"Pick a size | ▾" forState:UIControlStateNormal];
        sizeButton.titleLabel.textColor = [UIColor whiteColor];
        sizeButton.titleLabel.backgroundColor = [UIColor clearColor];
        sizeButton.titleLabel.font = [UIFont fontWithName:@"Gotham" size:14];
        sizeButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"size_background.png"]];
        sizeButton.titleLabel.textAlignment = UITextAlignmentRight;
        [formView addSubview:sizeButton];
        
        rowCount++;
        
        [PayPal initializeWithAppID:@"APP-09B355920Y2948247" forEnvironment:ENV_LIVE];
        [PayPal getPayPalInst].shippingEnabled = true;
        UIButton *button = [[PayPal getPayPalInst] getPayButtonWithTarget:self andAction:@selector(payWithPayPal) andButtonType:BUTTON_194x37];
        
        CGRect frame = button.frame;
        frame.origin.x = round((formView.frame.size.width - button.frame.size.width) / 2.);
        frame.origin.y = round(yPos + button.frame.size.height/2 + 10);
        button.frame = frame;
        [formView addSubview:button];
        }
    
        
        [self addSubview:touchView];
        [self addSubview:formView];
        
    }
    return self;
}

-(void)payWithPayPal{
        [[LJMainViewController sharedController] clear];
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.subTotal = [NSDecimalNumber decimalNumberWithString:@"17"];
    payment.recipient = @"ruti@loopjoy.com";
    payment.merchantName = @"Finger Olympics";
    payment.paymentCurrency = @"USD";
    [[PayPal getPayPalInst] checkoutWithPayment:payment];
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

- (void)radioPicker:(id)sender
{
    switch ([sender tag]){
        case 1:
            break;
        case 2:
            break;
        case 3:
            break;
        case 4: 
            break;
        case 5:
            break;
    }
}

- (void) uiViewTouched:(BOOL)wasInside
{
    if( wasInside ){
    }
    else{
        [[LJMainViewController sharedController] clear];
    }
}

- (void)paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)paymentStatus{[self dismissForm];}

- (void)paymentFailedWithCorrelationID:(NSString *)correlationID{//[self dismissForm];}
}
- (void)paymentCanceled{//[self dismissForm];}
}
- (void)paymentLibraryExit{//[self dismissForm];}
}
- (void)dismissForm{
    NSString *messageString = [NSString stringWithFormat:@"Thanks for your Order! You will recieve a confirmation email shortly"]; 
    LJNetworkService *networkService = [[LJNetworkService alloc] initWithAddress:@"https://localhost:3000/orders" :URLRequestPOST delegate:self];
    
    //{"commit"=>"Create Order", "authenticity_token"=>"7zAlq0lQGtyyD+UVG/pOfViyLGYljWNjykDzpp1SxGQ=", "utf8"=>"✓", "order"=>{"price"=>"1", "street_address"=>"My", "state"=>"Friends", "country"=>"Better", "city"=>"Are", "customer_id"=>"1", "zipcode"=>"1"}}
    
    NSString *order = [NSString stringWithFormat:@"{\"commit\":\"Create Order\",\"order\":{\"price\":\"%@\",\"street_address\":\"%@\",\"state\":\"%@\",\"country\":\"%@\",\"city\":\"%@\",\"zipcode\":\"%@\"}}",@"1",streetAddressFieldText,stateFieldText,@"USA",cityFieldText,zipFieldText];  
    NSLog(@"%@",order);
    [networkService setBody:order];
    [networkService execute];
    
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
