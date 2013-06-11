//
//  MGSFeedzillaClient.m
//  RCPlayground
//
//  Created by Michael James on 4/17/13.
//  Copyright (c) 2013 Maple Glen Software. All rights reserved.
//

#import "MGSFeedzillaClient.h"
#import "MGSFeedzillaCulture.h"
#import "MGSFeedzillaCategory.h"
#import "MGSFeedzillaSearchCriteria.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AFNetworking-ReactiveCocoa/AFNetworking-ReactiveCocoa.h>

@implementation MGSFeedzillaClient

+ (instancetype)client
{
    MGSFeedzillaClient* instance = [[MGSFeedzillaClient alloc] init];
    
    return instance;
}

- (instancetype)init
{
    if (self = [super initWithBaseURL: [NSURL URLWithString: @"http://api.feedzilla.com/"]])
    {
        return self;
    }
    
    return nil;
}

- (RACSignal*)fetchCultures
{
    NSLog(@"fetching cultures");
    
    // rac_getPath:parameters: method is from the AFNetworking-ReactiveCocoa project ( https://github.com/uasi/AFNetworking-ReactiveCocoa )
    // It performs an HTTP GET request and returns a signal that provides the AFHTTPRequestOperation and response data wrapped in a RACTuple.
    
    // This method takes that signal and transforms its value into an array by unmarshalling the JSON response data
    return [[self rac_getPath: @"v1/cultures.json" parameters: nil] map: ^id(RACTuple* tuple) {
        RACTupleUnpack(AFHTTPRequestOperation* requestOp, NSData* response) = tuple;
        
        NSLog(@"culture request returned status code: %ld", requestOp.response.statusCode);
        
        NSArray*    responseArray = [NSJSONSerialization JSONObjectWithData: response options: 0 error: nil];
        
        return responseArray;
    }];
}

- (RACSignal*)fetchCategoriesWithCulture: (MGSFeedzillaCulture*)culture
{
    NSLog(@"fetching categories with culture %@", culture.displayName);
    
    // rac_getPath:parameters: method is from the AFNetworking-ReactiveCocoa project ( https://github.com/uasi/AFNetworking-ReactiveCocoa )
    // It performs an HTTP GET request and returns a signal that provides the AFHTTPRequestOperation and response data wrapped in a RACTuple.
    
    // This method takes that signal and transforms its value into an array by unmarshalling the JSON response data
    return [[self rac_getPath: @"v1/categories.json" parameters: @{@"culture_code": culture.code, @"order": @"popular"}] map: ^id(RACTuple* tuple) {
        RACTupleUnpack(AFHTTPRequestOperation* requestOp, NSData* response) = tuple;
        
        NSLog(@"category request returned status code: %ld", requestOp.response.statusCode);
        
        NSArray*    responseArray = [NSJSONSerialization JSONObjectWithData: response options: 0 error: nil];
        
        return responseArray;
    }];
}

- (RACSignal*)fetchSubcategoriesWithCategory: (MGSFeedzillaCategory*)category
{
    NSLog(@"fetching subcategories with category %@", category.displayName);
    
    // rac_getPath:parameters: method is from the AFNetworking-ReactiveCocoa project ( https://github.com/uasi/AFNetworking-ReactiveCocoa )
    // It performs an HTTP GET request and returns a signal that provides the AFHTTPRequestOperation and response data wrapped in a RACTuple.
    
    // This method takes that signal and transforms its value into an array by unmarshalling the JSON response data
    return [[self rac_getPath: [NSString stringWithFormat: @"v1/categories/%d/subcategories.json", [category.ID intValue]] parameters: @{@"order": @"popular"}] map: ^id(RACTuple* tuple) {
        RACTupleUnpack(AFHTTPRequestOperation* requestOp, NSData* response) = tuple;
        
        NSLog(@"subcategory request returned status code: %ld", requestOp.response.statusCode);
        
        NSArray*    responseArray = [NSJSONSerialization JSONObjectWithData: response options: 0 error: nil];
        
        return responseArray;
    }];
}

- (RACSignal*)searchFeedsUsingCriteria: (MGSFeedzillaSearchCriteria*)criteria
{
    NSLog(@"searching feeds with category ID: %d and subcategory ID: %d", [criteria.categoryID intValue], [criteria.subcategoryID intValue]);
    
    // rac_getPath:parameters: method is from the AFNetworking-ReactiveCocoa project ( https://github.com/uasi/AFNetworking-ReactiveCocoa )
    // It performs an HTTP GET request and returns a signal that provides the AFHTTPRequestOperation and response data wrapped in a RACTuple.
    
    // This method takes that signal and transforms its value into an array by unmarshalling the JSON response data
    return [[self rac_getPath: [NSString stringWithFormat: @"v1/categories/%d/subcategories/%d/articles.json", [criteria.categoryID intValue], [criteria.subcategoryID intValue]] parameters: nil] map: ^id(RACTuple* tuple) {
        RACTupleUnpack(AFHTTPRequestOperation* requestOp, NSData* response) = tuple;
        
        NSLog(@"article search request returned status code: %ld", requestOp.response.statusCode);
        
        NSDictionary*    responseDictionary = [NSJSONSerialization JSONObjectWithData: response options: 0 error: nil];
        
        return responseDictionary;
    }];
}

@end
