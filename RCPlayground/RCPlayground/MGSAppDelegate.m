//
//  MGSAppDelegate.m
//  RCPlayground
//
//  Created by Michael James on 4/14/13.
//  Copyright (c) 2013 Maple Glen Software. All rights reserved.
//

#import "MGSAppDelegate.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <EXTScope.h>

#import "MGSFeedzillaSearchViewModel.h"
#import "MGSFeedzillaCulture.h"
#import "MGSFeedzillaCategory.h"
#import "MGSFeedzillaSubcategory.h"
#import "MGSFeedzillaSearchResult.h"

@interface MGSAppDelegate ()

@property (strong, nonatomic) MGSFeedzillaSearchViewModel*  viewModel;
@property (strong, nonatomic) NSMutableArray*               searchResults;

- (IBAction)searchTableRowDoubleClicked: (id)sender;

@end

@implementation MGSAppDelegate

@synthesize window, categoryPopUpButton, culturePopUpButton, subcategoryPopUpButton, searchResultsTable, searchButton;
@synthesize viewModel, searchResults;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.viewModel = [[MGSFeedzillaSearchViewModel alloc] init];
    self.searchResults = [NSMutableArray arrayWithCapacity: 5];
    
    self.searchResultsTable.dataSource = self;
    self.searchResultsTable.doubleAction = @selector(searchTableRowDoubleClicked:);
    
    @weakify(self);
    
    [[self.viewModel enableSearchSignal] subscribeNext: ^(NSNumber* enabled) {
        @strongify(self);
        [self.searchButton setEnabled: [enabled boolValue]];
    }];
    
    [[self.viewModel culturesContentSignal] subscribeNext: ^(NSArray* cultures) {
        @strongify(self);
        [self.culturePopUpButton removeAllItems];
        [self.categoryPopUpButton removeAllItems];
        [self.subcategoryPopUpButton removeAllItems];
        
        for (MGSFeedzillaCulture* culture in cultures)
        {
            [self.culturePopUpButton addItemWithTitle: culture.displayName];
        }
    }
    error: ^(NSError* error) {
        NSLog(@"error occurred obtaining cultures: %@", [error localizedDescription]);
    }];
    
    self.culturePopUpButton.rac_command = [RACCommand command];
    [self.culturePopUpButton.rac_command subscribeNext: ^(id sender) {
        @strongify(self);
        [self.viewModel cultureSelected: sender];
    }];
    
    self.categoryPopUpButton.rac_command = [RACCommand command];
    [self.categoryPopUpButton.rac_command subscribeNext: ^(id sender) {
        @strongify(self);
        [self.viewModel categorySelected: sender];
    }];
    
    self.subcategoryPopUpButton.rac_command = [RACCommand command];
    [self.subcategoryPopUpButton.rac_command subscribeNext: ^(id sender) {
        @strongify(self);
        [self.viewModel subcategorySelected: sender];
    }];
    
    [[self.viewModel categoriesContentSignal] subscribeNext: ^(NSArray* categories) {
        @strongify(self);
        [self.categoryPopUpButton removeAllItems];
        [self.subcategoryPopUpButton removeAllItems];
        for (MGSFeedzillaCategory* category in categories)
        {
            [self.categoryPopUpButton addItemWithTitle: category.displayName];
        }
    }
    error: ^(NSError* error) {
        NSLog(@"error occurred populating categories: %@", [error localizedDescription]);
    }];
    
    [[self.viewModel subcategoriesContentSignal] subscribeNext: ^(NSArray* subcategories) {
        @strongify(self);
        [self.subcategoryPopUpButton removeAllItems];
        for (MGSFeedzillaSubcategory* subcategory in subcategories)
        {
            [self.subcategoryPopUpButton addItemWithTitle: subcategory.displayName];
        }
    } error: ^(NSError* error) {
        NSLog(@"error occurred populating subcategories: %@", [error localizedDescription]);
    }];
    
    [[self.viewModel searchResultsSignal] subscribeNext: ^(NSArray* searchResultObjects) {
        @strongify(self);
        [self.searchResults removeAllObjects];
        [self.searchResults addObjectsFromArray: searchResultObjects];
        [self.searchResultsTable reloadData];
    }];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed: (NSApplication*)sender
{
    return YES;
}

- (IBAction)searchTableRowDoubleClicked: (id)sender
{
    NSInteger   row = [sender clickedRow];
    
    if (-1 != row)
    {
        MGSFeedzillaSearchResult*   searchResult = [self.searchResults objectAtIndex: row];
    
        [[NSWorkspace sharedWorkspace] openURL: searchResult.URL];
    }
}

- (IBAction)search: (id)sender
{
    [self.viewModel search: sender];
}

- (NSInteger)numberOfRowsInTableView: (NSTableView*)tableView
{
    return [self.searchResults count];
}

- (id)tableView: (NSTableView*)tableView objectValueForTableColumn: (NSTableColumn*)tableColumn row: (NSInteger)row
{
    NSString*                   columnIdentifier = tableColumn.identifier;
    MGSFeedzillaSearchResult*   searchResult = [self.searchResults objectAtIndex: row];
    
    if ([@"authorColumn" isEqualToString: columnIdentifier])
    {
        return searchResult.author;
    }
    else if ([@"titleColumn" isEqualToString: columnIdentifier])
    {
        return searchResult.title;
    }

    return nil;
}

@end
