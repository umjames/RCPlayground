//
//  MGSFeedzillaSearchViewModel.h
//  RCPlayground
//
//  Created by Michael James on 4/17/13.
//  Copyright (c) 2013 Maple Glen Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

// View model class that provides the controller (here, just the app delegate MGSAppDelegate)
// with an interface to the supported interactions/data needed for the application's only window
@interface MGSFeedzillaSearchViewModel : NSObject

// when search button is clicked
- (IBAction)search: (id)sender;

// when culture popup button selection is changed by the user
- (IBAction)cultureSelected: (id)sender;

// when category popup button selection is changed by the user
- (IBAction)categorySelected: (id)sender;

// when subcategory popup button selection is changed by the user
- (IBAction)subcategorySelected: (id)sender;


// signal that provides values for when the search button should be enabled/disabled
- (RACSignal*)enableSearchSignal;

// signal that provides new values for the content of the culture popup button
- (RACSignal*)culturesContentSignal;

// signal that provides new values for the content of the category popup button
- (RACSignal*)categoriesContentSignal;

// signal that provides new values for the content of the subcategory popup button
- (RACSignal*)subcategoriesContentSignal;

// signal that provides new values for the content of the search results table
- (RACSignal*)searchResultsSignal;

@end
