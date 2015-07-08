//
//  ServiceHelper.h
//  SmartPush
//
//  Created by Saurav, Amit on 7/6/15.
//  Copyright (c) 2015 Saurav, Amit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceHelper : NSObject

+ (id) sharedInstance;
- (void) logText:(NSString *) text;

@end
