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

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MGSFeedzillaSearchViewModel ()

@property (strong, nonatomic) MGSFeedzillaClient*   feedzillaClient;

@end

@implementation MGSFeedzillaSearchViewModel

@synthesize feedzillaClient;

- (instancetype)init
{
    if (self = [super init])
    {
        self.feedzillaClient = [MGSFeedzillaClient client];
        
        return self;
    }
    
    return nil;
}

- (IBAction)search: (id)sender
{
    
}

- (RACSignal*)culturesContentSignal
{
    return [[self.feedzillaClient fetchCultures] map: ^id(RACTuple* tuple) {
        RACTupleUnpack(AFHTTPRequestOperation* requestOp, NSData* response) = tuple;
        
        NSLog(@"request operation is of class %@", NSStringFromClass([requestOp class]));
        
        NSArray*    responseArray = [NSJSONSerialization JSONObjectWithData: response options: 0 error: nil];
        
        return [[responseArray.rac_sequence map: ^id(NSDictionary* cultureDict) {
            MGSFeedzillaCulture* culture = [[MGSFeedzillaCulture alloc] init];
            
            culture.displayName = [cultureDict objectForKey: @"english_culture_name"];
            culture.code = [cultureDict objectForKey: @"culture_code"];
            return culture;
        }] array];
    }];
}

- (RACSignal*)categoriesContentSignal
{
    return nil;
}

- (RACSignal*)subcategoriesContentSignal
{
    return nil;
}

@end
