//
//  RPGRACSearchViewController.m
//  RACPlayground
//
//  Created by Jymn_Chen on 16/1/21.
//  Copyright © 2016年 com.timedancing. All rights reserved.
//

#import "RPGRACSearchViewController.h"
#import "UISearchController+ExamSearchDelegate.h"
#import <ReactiveCocoa/ReactiveCocoa.h>


///////////////////////////////////////////////////////////////////////////////////////////


@interface RPGRACSearchViewController ()

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, copy) NSArray *searchTexts;
@property (nonatomic, copy) NSArray *searchResults;
@property (nonatomic, assign, getter=isSearching) BOOL searching;

@end

@implementation RPGRACSearchViewController


///////////////////////////////////////////////////////////////////////////////////////////


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"RAC";
    self.searchTexts = @[
                         @"Guangzhou",
                         @"Foshan",
                         @"Maoming",
                         @"Chaozhou",
                         @"Beijing",
                         @"Shanghai",
                         @"Shenzhen"
                         ];
    self.searchResults = @[];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    @weakify(self)
    
    // 在 rac_textSignal 变化时，也就是 updateSearchResultsForSearchController: 方法触发时
    // 更新 self.searchResults 并 reload self.tableView
    
#warning - 把一个信号分两次用才能做到的事，感觉并不优雅
//    RAC(self, searchResults) = [self rac_liftSelector:@selector(search:) withSignalsFromArray:@[_searchController.rac_textSignal]];
//    [_searchController.rac_textSignal subscribeNext:^(id x) {
//        @strongify(self)
//        [self.tableView reloadData];
//    }];
//
//    // 在 rac_isSearchingSignal 变化时，也就是 willPresentSearchController: 或 willDismissSearchController: 方法触发时
//    // 更新 self.searching 并按需 reload self.tableView
//    RAC(self, searching) = self.searchController.rac_isSearchingSignal;
//    [self.searchController.rac_isSearchingSignal subscribeNext:^(NSNumber *isSearching) {
//        @strongify(self)
//        if (isSearching.boolValue == NO) {
//            [self.tableView reloadData];
//        }
//    }];
  
    /** 我的修改，但是感觉更不优雅了 😂 */
    [_searchController.rac_textSignal subscribeNext:^(NSString *text) {
        @strongify(self)
        self.searchResults = [self search:text];
        [self.tableView reloadData];
    }];
    [_searchController.rac_isSearchingSignal subscribeNext:^(NSNumber *isSearching) {
        @strongify(self)
        self.searching = isSearching.boolValue;
        if (isSearching.boolValue == NO) {
            [self.tableView reloadData];
        }
    }];
}


///////////////////////////////////////////////////////////////////////////////////////////


#pragma mark - Common Methods

- (NSArray *)search:(NSString *)searchText {
    NSMutableArray *results = [NSMutableArray array];
    if (searchText.length > 0) {
        for (NSString *text in self.searchTexts) {
            if([[text lowercaseString] rangeOfString:[searchText lowercaseString]].location != NSNotFound) {
                [results addObject:text];
            }
        }
    } else {
        results = [self.searchTexts copy];
    }
    return results;
}


///////////////////////////////////////////////////////////////////////////////////////////


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return self.searchResults.count;
    }
    else {
        return self.searchTexts.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.isSearching ? self.searchResults[indexPath.row] : self.searchTexts[indexPath.row];
    return cell;
}

@end
