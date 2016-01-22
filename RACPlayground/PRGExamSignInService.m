//
//  PRGExamSignInService.m
//  RACPlayground
//
//  Created by Jymn_Chen on 16/1/21.
//  Copyright © 2016年 com.timedancing. All rights reserved.
//

#import "PRGExamSignInService.h"

@implementation PRGExamSignInService

- (void)signInWithUsername:(NSString *)username
                  password:(NSString *)password
           completionBlock:(void (^)(BOOL))completionBlock
{
    double delayInSeconds = 2.0f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL success = [username isEqualToString:@"hello"] && [password isEqualToString:@"123456"];
        completionBlock(success);
    });
}

@end
