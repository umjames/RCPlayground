//
//  MGSFeedzillaClient.h
//  RCPlayground
//
//  Created by Michael James on 4/17/13.
//  Copyright (c) 2013 Maple Glen Software. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@class RACSignal;
@class MGSFeedzillaCulture;
@class MGSFeedzillaCategory;
@class MGSFeedzillaSearchCriteria;

/*
    AFNetworking-compliant client class for communicating with the Feedzilla API ( http://code.google.com/p/feedzilla-api/wiki/RestApi )
*/
@interface MGSFeedzillaClient : AFHTTPClient

+ (instancetype)client;

- (instancetype)init;

// returns a signal that supplies the result of the Feedzilla API to retrieve cultures
- (RACSignal*)fetchCultures;

// returns a signal that supplies the result of the Feedzilla API to retrieve a culture's categories
- (RACSignal*)fetchCategoriesWithCulture: (MGSFeedzillaCulture*)culture;

// returns a signal that supplies the result of the Feedzilla API to retrieve a category's subcategories
- (RACSignal*)fetchSubcategoriesWithCategory: (MGSFeedzillaCategory*)category;

// returns a signal that supplies the result of the Feedzilla API to search for feeds with the given category and subcategory
- (RACSignal*)searchFeedsUsingCriteria: (MGSFeedzillaSearchCriteria*)criteria;

@end
