//
//  ServiceHelper.m
//  SmartPush
//
//  Created by Saurav, Amit on 7/6/15.
//  Copyright (c) 2015 Saurav, Amit. All rights reserved.
//

#import "ServiceHelper.h"

@implementation ServiceHelper

+ (id) sharedInstance {
    static dispatch_once_t onceToken;
    static ServiceHelper *sharedObject = nil;
    dispatch_once(&onceToken, ^{
        sharedObject = [[self alloc] init];
    });

    return sharedObject;
}

- (void) logText:(NSString *) text {

    NSMutableURLRequest *request = [self getRequest:[NSString stringWithFormat:@"%@/%@", @"log", text]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    if (!error) {
        NSLog(@"Service response was: %@", data);
    } else {
        NSLog(@"Service failed was: %@", data);
    }
}

- (NSMutableURLRequest *) getRequest:(NSString *) path {
    NSString *endPoint = @"http://52.24.211.89";
    NSString *encodedUrlString = [[NSString stringWithFormat:@"%@/%@", endPoint, path] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encodedUrlString];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:2];
    [request setURL:url];
    return request;
}
@end
