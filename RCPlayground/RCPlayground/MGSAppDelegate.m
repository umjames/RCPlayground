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

- (IBAction)_searchTableRowDoubleClicked: (id)sender;

@end

@implementation MGSAppDelegate

@synthesize window, categoryPopUpButton, culturePopUpButton, subcategoryPopUpButton, searchResultsTable, searchButton;
@synthesize viewModel, searchResults;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.viewModel = [[MGSFeedzillaSearchViewModel alloc] init];
    self.searchResults = [NSMutableArray arrayWithCapacity: 5];
    
    self.searchResultsTable.dataSource = self;
    self.searchResultsTable.doubleAction = @selector(_searchTableRowDoubleClicked:);
    
    @weakify(self);
    
    // when we get another value from the view model's enableSearchSignal,
    // enable/disable the search button based on the signal's new value (UI updating logic)
    [[self.viewModel enableSearchSignal] subscribeNext: ^(NSNumber* enabled) {
        @strongify(self);
        [self.searchButton setEnabled: [enabled boolValue]];
    }];
    
    // when we get cultures from the view model, clear out all of the popup buttons' items
    // and populate the culture popup button with the cultures' names
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
    
    // use a command to send values (remember, commands are signals)
    // when the popup button selection is changed (alternative to normal target/action setup)
    self.culturePopUpButton.rac_command = [RACCommand command];
    
    // when the user chooses a new value for this popup button, tell the view model about it
    [self.culturePopUpButton.rac_command subscribeNext: ^(id sender) {
        @strongify(self);
        [self.viewModel cultureSelected: sender];
    }];
    
    // use a command to send values (remember, commands are signals)
    // when the popup button selection is changed (alternative to normal target/action setup)
    self.categoryPopUpButton.rac_command = [RACCommand command];
    
    // when the user chooses a new value for this popup button, tell the view model about it
    [self.categoryPopUpButton.rac_command subscribeNext: ^(id sender) {
        @strongify(self);
        [self.viewModel categorySelected: sender];
    }];
    
    // use a command to send values (remember, commands are signals)
    // when the popup button selection is changed (alternative to normal target/action setup)
    self.subcategoryPopUpButton.rac_command = [RACCommand command];
    
    // when the user chooses a new value for this popup button, tell the view model about it
    [self.subcategoryPopUpButton.rac_command subscribeNext: ^(id sender) {
        @strongify(self);
        [self.viewModel subcategorySelected: sender];
    }];
    
    // when there are new categories, clear the category and subcategory popup buttons,
    // and populate the category popup button with the new categories
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
    
    // when there are new subcategories, clear the subcategory popup button,
    // and populate it with the new subcategories
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
    
    
    // when there are new search results, update our reference to the new results,
    // and reload the search results table with the new data
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

// open double clicked rows's feed URL in a browser
- (IBAction)_searchTableRowDoubleClicked: (id)sender
{
    NSInteger   row = [sender clickedRow];
    
    if (-1 != row)
    {
        MGSFeedzillaSearchResult*   searchResult = [self.searchResults objectAtIndex: row];
    
        [[NSWorkspace sharedWorkspace] openURL: searchResult.URL];
    }
}

// when the search button is clicked, tell the view model to perform the search
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
