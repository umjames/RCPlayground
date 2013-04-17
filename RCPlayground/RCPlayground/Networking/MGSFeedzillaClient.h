//
//  MGSFeedzillaClient.h
//  RCPlayground
//
//  Created by Michael James on 4/17/13.
//  Copyright (c) 2013 Maple Glen Software. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@class RACSignal;

@interface MGSFeedzillaClient : AFHTTPClient

+ (instancetype)client;

- (instancetype)init;

- (RACSignal*)fetchCultures;

@end
