//
//  LJNetworkDelegate.h
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+URLEncodedString.h"

typedef enum
{
    URLRequestPOST = 1,
    URLRequestPUT = 2,
    URLRequestGET = 3,
    URLRequestDELETE = 4,
} URLRequestType;

@interface LJNetworkService : NSObject{
    NSString *address;
    NSString *requestString;
    NSURLConnection *connection;
    NSMutableURLRequest *request;
    
    NSMutableDictionary *params;
    NSMutableDictionary *headers;
    
    id thisDelegate;
    
    CFArrayRef certs;
}
- (id)initWithAddress:(NSString *)address :(URLRequestType)requestType delegate:(id<NSURLConnectionDelegate>)theDelegate;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)sendInfo:(NSString  *)data;
- (void)setBody:(NSString *)body;
- (void)buildRequest;
- (void)execute;
@end
