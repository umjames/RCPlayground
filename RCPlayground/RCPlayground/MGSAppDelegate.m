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
    
    [[self.viewModel categoriesContentSignal] subscribeNext: ^(NSArray* categories) {
        @strongify(self);
        [self.categoryPopUpButton removeAllItems];
        for (MGSFeedzillaCategory* category in categories)
        {
            [self.categoryPopUpButton addItemWithTitle: category.displayName];
        }
    }
    error: ^(NSError* error) {
        NSLog(@"error occurred populating categories: %@", [error localizedDescription]);
    }];
}

- (IBAction)search: (id)sender
{
    [self.viewModel search: sender];
}

@end
