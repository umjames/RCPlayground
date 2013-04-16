//
//  MGSFeedzillaSearchCriteria.h
//  RCPlayground
//
//  Created by Michael James on 4/16/13.
//  Copyright (c) 2013 Maple Glen Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGSFeedzillaSearchCriteria : NSObject

@property (strong, nonatomic) NSString*     cultureCode;
@property (strong, nonatomic) NSNumber*     categoryID;
@property (strong, nonatomic) NSNumber*     subcategoryID;

@end
