//
//  MGSFeedzillaSearchViewModel.m
//  RCPlayground
//
//  Created by Michael James on 4/17/13.
//  Copyright (c) 2013 Maple Glen Software. All rights reserved.
//

#import "MGSFeedzillaSearchViewModel.h"
#import "MGSFeedzillaClient.h"
#import "MGSFeedzillaCulture.h"
#import "MGSFeedzillaCategory.h"
#import "MGSFeedzillaSubcategory.h"
#import "MGSFeedzillaSearchCriteria.h"
#import "MGSFeedzillaSearchResult.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <EXTScope.h>

@interface MGSFeedzillaSearchViewModel ()
{
    RACSignal*      _culturesContentSignal;
    RACSignal*      _categoriesContentSignal;
    RACSignal*      _subcategoriesContentSignal;
    RACSignal*      _enableSearchSignal;
    RACSignal*      _searchResultsSignal;
    
    RACSignal*      _selectedCultureSignal;
    RACSignal*      _selectedCategorySignal;
    RACSignal*      _selectedSubcategorySignal;
}

@property (strong, nonatomic) MGSFeedzillaClient*       feedzillaClient;
@property (strong, nonatomic) MGSFeedzillaCulture*      selectedCulture;
@property (strong, nonatomic) MGSFeedzillaCategory*     selectedCategory;
@property (strong, nonatomic) MGSFeedzillaSubcategory*  selectedSubcategory;

@property (strong, nonatomic) NSMutableArray*       cultures;
@property (strong, nonatomic) NSArray*              categories;
@property (strong, nonatomic) NSArray*              subcategories;
@property (strong, nonatomic) NSArray*              searchResults;

- (void)_setupInternalSignals;

- (RACSignal*)_selectedCultureSignal;
- (RACSignal*)_selectedCategorySignal;
- (RACSignal*)_selectedSubcategorySignal;

@end

@implementation MGSFeedzillaSearchViewModel

@synthesize feedzillaClient, cultures, selectedCulture;

- (instancetype)init
{
    if (self = [super init])
    {
        _culturesContentSignal = nil;
        _categoriesContentSignal = nil;
        _subcategoriesContentSignal = nil;
        _enableSearchSignal = nil;
        _searchResultsSignal = nil;
        
        _selectedCultureSignal = nil;
        _selectedCategorySignal = nil;
        _selectedSubcategorySignal = nil;
        
        self.feedzillaClient = [MGSFeedzillaClient client];
        self.cultures = [[NSMutableArray alloc] initWithCapacity: 5];
        self.categories = [[NSArray alloc] init];
        self.subcategories = [[NSArray alloc] init];
        self.searchResults = [[NSArray alloc] init];
        
        self.selectedCulture = nil;
        self.selectedCategory = nil;
        self.selectedSubcategory = nil;
        
        [self _setupInternalSignals];
        
        return self;
    }
    
    return nil;
}

- (void)_setupInternalSignals
{
    // since we will be referencing self in the signal's subscription blocks, we first make a weak reference to it
    // and then ensure its presence inside the block with strongify
    @weakify(self);
    
    // when we get new cultures from the API, store them in the cultures mutable array
    [[self culturesContentSignal] subscribeNext: ^(NSArray* culturesFromServer) {
        @strongify(self);
        [self.cultures removeAllObjects];
        [self.cultures addObjectsFromArray: culturesFromServer];
    }];
    
    // when the selected culture changes, fetch that culture's categories from the API
    [[self _selectedCultureSignal] subscribeNext: ^(MGSFeedzillaCulture* culture) {
        @strongify(self);
        
        // perform API call
        [[[self.feedzillaClient fetchCategoriesWithCulture: culture] map: ^id(NSArray* categoryJSON) {
            
            // use the JSON array to create an array of MGSFeedzillaCategory model objects
            // in order to use the map function on an NSArray, we have to turn it into a RACSequence first
            // with the rac_sequence category method
            return [[categoryJSON.rac_sequence map: ^id(NSDictionary* categoryDict) {
                MGSFeedzillaCategory* category = [[MGSFeedzillaCategory alloc] init];
                
                category.displayName = [categoryDict objectForKey: @"english_category_name"];
                category.ID = [categoryDict objectForKey: @"category_id"];
                
                return category;
            }] array]; // we call -array on the sequence to get an NSArray of the sequence's values
        }] subscribeNext: ^(NSArray* categories) {
            // then we store that array of model objects which causes the
            // categoriesContentSignal to send these new objects to its subscribers
            self.categories = categories;
        }];
    }];
    
    // when the selected category changes, fetch that category's subcategories from the API
    [[self _selectedCategorySignal] subscribeNext: ^(MGSFeedzillaCategory* category) {
        @strongify(self);
        
        // just like with categories above, we make the API call, turn its results into
        // model objects, and store them, which triggers the subcategoriesContentSignal to send them
        // to its subscribers
        [[[self.feedzillaClient fetchSubcategoriesWithCategory: category] map: ^id(NSArray* subcategoryJSON) {
            return [[subcategoryJSON.rac_sequence map: ^id(NSDictionary* subcategoryDict) {
                MGSFeedzillaSubcategory* subcategory = [[MGSFeedzillaSubcategory alloc] init];
                
                subcategory.displayName = [subcategoryDict objectForKey: @"english_subcategory_name"];
                subcategory.ID = [subcategoryDict objectForKey: @"subcategory_id"];
                
                return subcategory;
            }] array];
        }] subscribeNext: ^(NSArray* subcategories) {
            self.subcategories = subcategories;
        }];
    }];
}

// when the user selects a culture, we just change our selected culture reference and
// clear the selected category and subcategory which triggers the signals tied to
// those keypaths
- (IBAction)cultureSelected: (id)sender
{
    NSInteger   selectedIndex = [sender indexOfSelectedItem];
    
    if (-1 == selectedIndex)
    {
        self.selectedCulture = nil;
    }
    else
    {
        self.selectedCulture = [self.cultures objectAtIndex: selectedIndex];
    }
    
    self.selectedCategory = nil;
    self.selectedSubcategory = nil;
}

// when the user selects a category, we just change our selected category reference and
// clear the selected subcategory which triggers the signals tied to
// those keypaths
- (IBAction)categorySelected: (id)sender
{
    NSInteger   selectedIndex = [sender indexOfSelectedItem];
    
    if (-1 == selectedIndex)
    {
        self.selectedCategory = nil;
    }
    else
    {
        self.selectedCategory = [self.categories objectAtIndex: selectedIndex];
    }
    
    self.selectedSubcategory = nil;
}

// when the user selects a subcategory, we just change our selected subcategory reference
// which triggers the signal tied to that keypath
- (IBAction)subcategorySelected: (id)sender
{
    NSInteger   selectedIndex = [sender indexOfSelectedItem];
    
    if (-1 == selectedIndex)
    {
        self.selectedSubcategory = nil;
    }
    else
    {
        self.selectedSubcategory = [self.subcategories objectAtIndex: selectedIndex];
    }
}

// When the search button is clicked, we get the IDs of the selected category and subcategory
// and use them to make an API call to search for feeds.  The results of the API call are turned
// into an array of MGSFeedzillaSearchResult model objects.  Finally we assign this array to our
// searchResults property which also triggers the searchResultsSignal
- (IBAction)search: (id)sender
{
    MGSFeedzillaSearchCriteria* searchCriteria = [[MGSFeedzillaSearchCriteria alloc] init];
    
    searchCriteria.categoryID = self.selectedCategory.ID;
    searchCriteria.subcategoryID = self.selectedSubcategory.ID;
    
    @weakify(self);
    [[self.feedzillaClient searchFeedsUsingCriteria: searchCriteria] subscribeNext: ^(NSDictionary* searchResult) {
        @strongify(self);
        if (nil == searchCriteria || nil == [searchResult objectForKey: @"articles"])
        {
            self.searchResults = [NSArray array];
        }
        else
        {
            NSMutableArray* results = [NSMutableArray arrayWithCapacity: 5];
            NSArray*    articles = [searchResult objectForKey: @"articles"];
            
            for (NSDictionary* articleJSON in articles)
            {
                MGSFeedzillaSearchResult*   tempSearchResult = [[MGSFeedzillaSearchResult alloc] init];
                
                tempSearchResult.author = [articleJSON objectForKey: @"author"];
                tempSearchResult.title = [articleJSON objectForKey: @"title"];
                tempSearchResult.URL = [NSURL URLWithString: [articleJSON objectForKey: @"url"]];
                
                [results addObject: tempSearchResult];
            }
            
            self.searchResults = [NSArray arrayWithArray: results];
        }
    } error: ^(NSError* error) {
        NSLog(@"error searching for feeds: %@", [error localizedDescription]);
    }];
}

// Returns a signal that takes the current values of the selected culture, category, and subcategory
// and returns a BOOL (wrapped in an NSNumber) that is YES if there are values for all 3 and NO otherwise.
// This is the logic that controls whether the search button should be enabled.
- (RACSignal*)enableSearchSignal
{
    if (nil == _enableSearchSignal)
    {
        _enableSearchSignal = [RACSignal combineLatest: @[[self _selectedCultureSignal], [self _selectedCategorySignal], [self _selectedSubcategorySignal]] reduce: ^NSNumber*(MGSFeedzillaCulture* culture, MGSFeedzillaCategory* category, MGSFeedzillaSubcategory* subcategory) {
            return [NSNumber numberWithBool: (nil != culture && nil != category && nil != subcategory)];
        }];
    }
    
    return _enableSearchSignal;
}

// returns a signal that fetches the cultures from the API, turns them into an array of
// MGSFeedzillaCulture model objects and returns that array as its value
- (RACSignal*)culturesContentSignal
{
    if (nil == _culturesContentSignal)
    {
        _culturesContentSignal = [[self.feedzillaClient fetchCultures] map: ^id(NSArray* cultureJSON) {
            
            return [[cultureJSON.rac_sequence map: ^id(NSDictionary* cultureDict) {
                MGSFeedzillaCulture* culture = [[MGSFeedzillaCulture alloc] init];
                
                culture.displayName = [cultureDict objectForKey: @"english_culture_name"];
                culture.code = [cultureDict objectForKey: @"culture_code"];
                return culture;
            }] array];
        }];
    }
    
    return _culturesContentSignal;
}

// returns a signal that sends the values of the selected culture as they are changed (cleaner way to handle KVO)
- (RACSignal*)_selectedCultureSignal
{
    if (nil == _selectedCultureSignal)
    {
        _selectedCultureSignal = RACAble(self.selectedCulture);
    }
    
    return _selectedCultureSignal;
}

// returns a signal that sends the values of the selected category as they are changed (cleaner way to handle KVO)
- (RACSignal*)_selectedCategorySignal
{
    if (nil == _selectedCategorySignal)
    {
        _selectedCategorySignal = RACAble(self.selectedCategory);
    }
    
    return _selectedCategorySignal;
}

// returns a signal that sends the values of the selected subcategory as they are changed (cleaner way to handle KVO)
- (RACSignal*)_selectedSubcategorySignal
{
    if (nil == _selectedSubcategorySignal)
    {
        _selectedSubcategorySignal = RACAble(self.selectedSubcategory);
    }
    
    return _selectedSubcategorySignal;
}

// returns a signal that sends the values of the search results as they are changed (cleaner way to handle KVO)
- (RACSignal*)searchResultsSignal
{
    if (nil == _searchResultsSignal)
    {
        _searchResultsSignal = RACAble(self.searchResults);
    }
    
    return _searchResultsSignal;
}

// returns a signal that sends the values of the current categories as they are changed (cleaner way to handle KVO)
- (RACSignal*)categoriesContentSignal
{
    if (nil == _categoriesContentSignal)
    {
        _categoriesContentSignal = RACAble(self.categories);
    }
    
    return _categoriesContentSignal;
}

// returns a signal that sends the values of the current subcategories as they are changed (cleaner way to handle KVO)
- (RACSignal*)subcategoriesContentSignal
{
    if (nil == _subcategoriesContentSignal)
    {
        _subcategoriesContentSignal = RACAble(self.subcategories);
    }
    
    return _subcategoriesContentSignal;
}

@end
