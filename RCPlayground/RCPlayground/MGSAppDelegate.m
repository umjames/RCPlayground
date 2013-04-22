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

@interface MGSAppDelegate ()

@property (strong, nonatomic) MGSFeedzillaSearchViewModel* viewModel;

@end

@implementation MGSAppDelegate

@synthesize window, categoryPopUpButton, culturePopUpButton, subcategoryPopUpButton, searchResultsTable;
@synthesize viewModel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.viewModel = [[MGSFeedzillaSearchViewModel alloc] init];
    
    @weakify(self);
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
}

- (IBAction)search: (id)sender
{
    [self.viewModel search: sender];
}

@end
