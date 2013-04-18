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

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <EXTScope.h>

@interface MGSFeedzillaSearchViewModel ()
{
    RACSignal*      _culturesContentSignal;
    RACSignal*      _categoriesContentSignal;
    
    RACSignal*      _selectedCultureSignal;
}

@property (strong, nonatomic) MGSFeedzillaClient*   feedzillaClient;
@property (strong, nonatomic) MGSFeedzillaCulture*  selectedCulture;

@property (strong, nonatomic) NSMutableArray*       cultures;
@property (strong, nonatomic) NSMutableArray*       categories;

- (void)_setupInternalSignals;

@end

@implementation MGSFeedzillaSearchViewModel

@synthesize feedzillaClient, cultures, selectedCulture;

- (instancetype)init
{
    if (self = [super init])
    {
        _culturesContentSignal = nil;
        _categoriesContentSignal = nil;
        
        _selectedCultureSignal = nil;
        
        self.feedzillaClient = [MGSFeedzillaClient client];
        self.cultures = [[NSMutableArray alloc] initWithCapacity: 5];
        self.categories = [[NSMutableArray alloc] initWithCapacity: 5];
        
        self.selectedCulture = nil;
        
        [self _setupInternalSignals];
        
        return self;
    }
    
    return nil;
}

- (void)_setupInternalSignals
{
    @weakify(self);
    
    [[self categoriesContentSignal] subscribeNext: ^(NSArray* categoriesFromServer) {
        @strongify(self);
        [self.categories removeAllObjects];
        [self.categories addObjectsFromArray: categoriesFromServer];
    }];
    
    [[self culturesContentSignal] subscribeNext: ^(NSArray* culturesFromServer) {
        @strongify(self);
        [self.cultures removeAllObjects];
        [self.cultures addObjectsFromArray: culturesFromServer];
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

- (RACSignal*)selectedCultureSignal
{
    if (nil == _selectedCultureSignal)
    {
        _selectedCultureSignal = RACAbleWithStart(self.selectedCulture);
    }
    
    return _selectedCultureSignal;
}

- (RACSignal*)categoriesContentSignal
{
    if (nil == _categoriesContentSignal)
    {
        _categoriesContentSignal = [[self.feedzillaClient fetchCategoriesWithCulture: self.selectedCulture] map: ^id(NSArray* categoryJSON) {
            
            return [[categoryJSON.rac_sequence map: ^id(NSDictionary* categoryDict) {
                MGSFeedzillaCategory* category = [[MGSFeedzillaCategory alloc] init];
                
                category.displayName = [categoryDict objectForKey: @"english_category_name"];
                category.ID = [categoryDict objectForKey: @"category_id"];
                
                return category;
            }] array];
        }];
    }
    
    return _categoriesContentSignal;
}

- (RACSignal*)subcategoriesContentSignal
{
    return nil;
}

@end
