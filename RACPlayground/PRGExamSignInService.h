//
//  PRGExamSignInService.h
//  RACPlayground
//
//  Created by Jymn_Chen on 16/1/21.
//  Copyright © 2016年 com.timedancing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRGExamSignInService : NSObject

- (void)signInWithUsername:(NSString *)username
                  password:(NSString *)password
           completionBlock:(void (^)(BOOL))completionBlock;

@end
