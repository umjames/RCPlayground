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

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <EXTScope.h>

@interface MGSFeedzillaSearchViewModel ()
{
    RACSignal*      _culturesContentSignal;
    RACSignal*      _categoriesContentSignal;
    RACSignal*      _subcategoriesContentSignal;
    
    RACSignal*      _selectedCultureSignal;
    RACSignal*      _selectedCategorySignal;
}

@property (strong, nonatomic) MGSFeedzillaClient*   feedzillaClient;
@property (strong, nonatomic) MGSFeedzillaCulture*  selectedCulture;
@property (strong, nonatomic) MGSFeedzillaCategory* selectedCategory;

@property (strong, nonatomic) NSMutableArray*       cultures;
@property (strong, nonatomic) NSArray*              categories;
@property (strong, nonatomic) NSArray*              subcategories;

- (void)_setupInternalSignals;

- (RACSignal*)_selectedCultureSignal;
- (RACSignal*)_selectedCategorySignal;

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
        
        _selectedCultureSignal = nil;
        
        self.feedzillaClient = [MGSFeedzillaClient client];
        self.cultures = [[NSMutableArray alloc] initWithCapacity: 5];
        self.categories = [[NSArray alloc] init];
        self.subcategories = [[NSArray alloc] init];
        
        self.selectedCulture = nil;
        self.selectedCategory = nil;
        
        [self _setupInternalSignals];
        
        return self;
    }
    
    return nil;
}

- (void)_setupInternalSignals
{
    @weakify(self);
    
    [[self culturesContentSignal] subscribeNext: ^(NSArray* culturesFromServer) {
        @strongify(self);
        [self.cultures removeAllObjects];
        [self.cultures addObjectsFromArray: culturesFromServer];
    }];
    
    [[self _selectedCultureSignal] subscribeNext: ^(MGSFeedzillaCulture* culture) {
        @strongify(self);
        
        [[[self.feedzillaClient fetchCategoriesWithCulture: culture] map: ^id(NSArray* categoryJSON) {
            
            return [[categoryJSON.rac_sequence map: ^id(NSDictionary* categoryDict) {
                MGSFeedzillaCategory* category = [[MGSFeedzillaCategory alloc] init];
                
                category.displayName = [categoryDict objectForKey: @"english_category_name"];
                category.ID = [categoryDict objectForKey: @"category_id"];
                
                return category;
            }] array];
        }] subscribeNext: ^(NSArray* categories) {
            self.categories = categories;
        }];
    }];
    
    [[self _selectedCategorySignal] subscribeNext: ^(MGSFeedzillaCategory* category) {
        @strongify(self);
        
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
}

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
}

- (IBAction)search: (id)sender
{
    
}

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

- (RACSignal*)_selectedCultureSignal
{
    if (nil == _selectedCultureSignal)
    {
        _selectedCultureSignal = RACAble(self.selectedCulture);
    }
    
    return _selectedCultureSignal;
}

- (RACSignal*)_selectedCategorySignal
{
    if (nil == _selectedCategorySignal)
    {
        _selectedCategorySignal = RACAble(self.selectedCategory);
    }
    
    return _selectedCategorySignal;
}

- (RACSignal*)categoriesContentSignal
{
    if (nil == _categoriesContentSignal)
    {
        _categoriesContentSignal = RACAble(self.categories);
    }
    
    return _categoriesContentSignal;
}

- (RACSignal*)subcategoriesContentSignal
{
    if (nil == _subcategoriesContentSignal)
    {
        _subcategoriesContentSignal = RACAble(self.subcategories);
    }
    
    return _subcategoriesContentSignal;
}

@end
