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
        
        
        //Initialize Form View
        formView = [[UIView alloc] initWithFrame:CGRectMake(15,60,280,320)];
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
        
        sizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
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
        
        [PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_SANDBOX];
        [PayPal getPayPalInst].shippingEnabled = true;
        UIButton *button = [[PayPal getPayPalInst] getPayButtonWithTarget:self andAction:@selector(payWithPayPal) andButtonType:BUTTON_194x37];
        
        CGRect frame = button.frame;
        frame.origin.x = round((formView.frame.size.width - button.frame.size.width) / 2.);
        frame.origin.y = round(yPos + button.frame.size.height/2 + 10);
        button.frame = frame;
        [formView addSubview:button];
    
        
    
        
        
        [self addSubview:formView];
        
    }
    return self;
}

-(void)payWithPayPal{
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.subTotal = [NSDecimalNumber decimalNumberWithString:@"10"];
    payment.recipient = @"jimbea_1343242678_biz@gmail.com";
    payment.merchantName = @"LoopJoy";
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

- (void)paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)paymentStatus{[self dismissForm];}
- (void)paymentFailedWithCorrelationID:(NSString *)correlationID{[self dismissForm];}
- (void)paymentCanceled{[self dismissForm];}
- (void)paymentLibraryExit{[self dismissForm];}

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
