//
//  RPGOSSearchViewController.m
//  RACPlayground
//
//  Created by Jymn_Chen on 16/1/21.
//  Copyright © 2016年 com.timedancing. All rights reserved.
//

#import "RPGOSSearchViewController.h"


///////////////////////////////////////////////////////////////////////////////////////////


@interface RPGOSSearchViewController () <UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, copy) NSArray *searchTexts;
@property (nonatomic, copy) NSArray *searchResults;
@property (nonatomic, assign, getter=isSearching) BOOL searching;

@end

@implementation RPGOSSearchViewController


///////////////////////////////////////////////////////////////////////////////////////////


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Old School";
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
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
}


///////////////////////////////////////////////////////////////////////////////////////////


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // 这个 delegate 方法触发时，要更新 self.searchResults 并 reload table view
    
    if (searchController.searchBar.text.length > 0) {
        self.searchResults = [self search:searchController.searchBar.text];
    }
    else {
        self.searchResults = self.searchTexts;
    }
    [self.tableView reloadData];
}

- (NSArray *)search:(NSString *)searchText {
    NSMutableArray *results = [NSMutableArray array];
    for (NSString *text in self.searchTexts) {
        if([[text lowercaseString] rangeOfString:[searchText lowercaseString]].location != NSNotFound) {
            [results addObject:text];
        }
    }
    return results;
}

#pragma mark - UISearchControllerDelegate

// willPresentSearchController: 和 willDismissSearchController: 方法触发时，要更新 self.searching

- (void)willPresentSearchController:(UISearchController *)searchController {
    self.searching = YES;
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    self.searching = NO;
    [self.tableView reloadData];
}

- (void)didDismissSearchController:(UISearchController *)searchController
{
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
