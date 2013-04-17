//
//  MGSFeedzillaClient.m
//  RCPlayground
//
//  Created by Michael James on 4/17/13.
//  Copyright (c) 2013 Maple Glen Software. All rights reserved.
//

#import "MGSFeedzillaClient.h"
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
    return [self rac_getPath: @"v1/cultures.json" parameters: nil];
}

@end
