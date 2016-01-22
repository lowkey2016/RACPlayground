//
//  UISearchController+ExamSearchDelegate.m
//  RACPlayground
//
//  Created by Jymn_Chen on 16/1/21.
//  Copyright © 2016年 com.timedancing. All rights reserved.
//

#import "UISearchController+ExamSearchDelegate.h"
#import <objc/runtime.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface UISearchController () <UISearchResultsUpdating, UISearchControllerDelegate>

@end

@implementation UISearchController (ExamSearchDelegate)

- (RACSignal *)rac_textSignal {
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal) {
        return signal;
    }
    
    self.searchResultsUpdater = self;
    signal = [[self rac_signalForSelector:@selector(updateSearchResultsForSearchController:) fromProtocol:@protocol(UISearchResultsUpdating)] map:^id(RACTuple *tuple) {
        
        UISearchController *searchController = tuple.first;
        return searchController.searchBar.text;
    }];
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return signal;
}

- (RACSignal *)rac_isSearchingSignal {
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal) {
        return signal;
    }
    
    self.delegate = self;
    RACSignal *willPresentSignal = [[self rac_signalForSelector:@selector(willPresentSearchController:) fromProtocol:@protocol(UISearchControllerDelegate)] mapReplace:@YES];
    RACSignal *willDismiss = [[self rac_signalForSelector:@selector(willDismissSearchController:) fromProtocol:@protocol(UISearchControllerDelegate)] mapReplace:@NO];
    signal = [RACSignal merge:@[willPresentSignal, willDismiss]];
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return signal;
}

@end
