//
//  UISearchController+ExamSearchDelegate.h
//  RACPlayground
//
//  Created by Jymn_Chen on 16/1/21.
//  Copyright © 2016年 com.timedancing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACSignal;

@interface UISearchController (ExamSearchDelegate)

- (RACSignal *)rac_textSignal;
- (RACSignal *)rac_isSearchingSignal;

@end
