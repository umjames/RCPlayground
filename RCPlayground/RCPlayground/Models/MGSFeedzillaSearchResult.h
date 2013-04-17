//
//  MGSFeedzillaSearchResult.h
//  RCPlayground
//
//  Created by Michael James on 4/17/13.
//  Copyright (c) 2013 Maple Glen Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGSFeedzillaSearchResult : NSObject

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* author;
@property (strong, nonatomic) NSURL*    URL;

@end
