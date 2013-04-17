//
//  MGSAppDelegate.m
//  RCPlayground
//
//  Created by Michael James on 4/14/13.
//  Copyright (c) 2013 Maple Glen Software. All rights reserved.
//

#import "MGSAppDelegate.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "MGSFeedzillaSearchViewModel.h"
#import "MGSFeedzillaCulture.h"

@interface MGSAppDelegate ()

@property (strong, nonatomic) MGSFeedzillaSearchViewModel* viewModel;

@end

@implementation MGSAppDelegate

@synthesize window, categoryPopUpButton, culturePopUpButton, subcategoryPopUpButton, searchResultsTable;
@synthesize viewModel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.viewModel = [[MGSFeedzillaSearchViewModel alloc] init];
    
    [[self.viewModel culturesContentSignal] subscribeNext: ^(NSArray* cultures) {
        [self.culturePopUpButton removeAllItems];
        for (MGSFeedzillaCulture* culture in cultures)
        {
            [self.culturePopUpButton addItemWithTitle: culture.displayName];
        }
    }
    error: ^(NSError *error) {
        NSLog(@"error occurred obtaining cultures: %@", [error localizedDescription]);
    }];
}

- (IBAction)search: (id)sender
{
    [self.viewModel search: sender];
}

@end
