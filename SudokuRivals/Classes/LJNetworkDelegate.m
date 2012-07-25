//
//  LJNetworkDelegate.m
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LJNetworkDelegate.h"

@implementation LJNetworkDelegate
- (id)initWithAddress:(NSString *)_address :(URLRequestType)requestType delegate:(id<NSURLConnectionDelegate>)theDelegate{
    address = _address;
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:address]];
    thisDelegate = theDelegate;
    
    switch(requestType){
        case URLRequestPOST:		
            [request setHTTPMethod:@"POST"];
            break;
        case URLRequestPUT:
            break;
        case URLRequestGET:
            break;
        case URLRequestDELETE:
            break;
    }
    
    params = [[NSMutableDictionary alloc] init];
    headers = [[NSMutableDictionary alloc] init];
    

    
    
    return self;
  }
- (void)addParam:(NSString *)name value:(NSString *)value{
    [params setObject:value forKey:name];
}
- (void)addHeader:(NSString *)name value:(NSString *)value{
    [headers setObject:value forKey:name];
}

- (void)setBody:(NSString *)body{
    requestString = body;
    NSLog(@"request string: %@",requestString);
    [request setHTTPBody:[requestString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)buildRequest{
    NSString *body = [[NSString alloc] init];
    for(NSString *key in params) {
        NSString *value = [params objectForKey:key];
        body = [NSString stringWithFormat:@"%@%@%@",key,@"&",value];
    }
}
- (void)execute{
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setValue:[NSString stringWithFormat:@"%d",[requestString length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[requestString dataUsingEncoding:NSUTF8StringEncoding]];
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:thisDelegate];
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{}
- (void)sendInfo:(NSString  *)data{}
@end
