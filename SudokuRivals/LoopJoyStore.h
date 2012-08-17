//
//  Store.h
//  Store
//
//  Created by Tennyson Hinds on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LJItem;

@protocol LoopJoyStoreDelegate

@required
@optional
-(void)unsuccessfulPurchase;
-(void)successfulPurchase;
@end

typedef enum{
    LJ_ENV_LIVE,
    LJ_ENV_SANDBOX,
    LJ_ENV_BETA_SANDBOX
} LJEnvironmentType;

typedef enum{
    LJ_BUTTON_IPAD_BLACK,
    LJ_BUTTON_IPHONE_BLACK,
    LJ_BUTTON_IPAD_BLUE,
    LJ_BUTTON_IPHONE_BLUE,
    LJ_BUTTON_IPAD_GREEN,
    LJ_BUTTON_IPHONE_GREEN,
    LJ_BUTTON_IPAD_RED,
    LJ_BUTTON_IPHONE_RED,
    LJ_BUTTON_IPAD_YELLOW,
    LJ_BUTTON_IPHONE_YELLOW
} LJButtonType;

typedef enum{
    LJ_MODAL_HORIZONTAL,
    LJ_MODAL_VERTICAL,
} LJModalOrientation;

@interface LoopJoyStore : NSObject <NSURLConnectionDelegate>{
    NSString *_developerID;
    NSString *_merchantName;
    LJEnvironmentType _currentEnv;
    LJItem *_currentItem;
    LJModalOrientation _currentOrientation;
}

@property NSMutableDictionary *items;

+(LoopJoyStore *)sharedInstance;
-(void)initializeWithDevID:(NSString *)devID forEnv:(LJEnvironmentType)envType;
-(NSString *)getMerchantName;
-(UIButton *)getLJButtonForItem:(int)itemID withButtonType:(LJButtonType)buttonType;
-(UIButton *)getLJButtonForItem:(int)itemID withButtonType:(LJButtonType)buttonType andAction:(SEL)select;
-(void)showModalForItem:(NSString *)itemID;
@end
