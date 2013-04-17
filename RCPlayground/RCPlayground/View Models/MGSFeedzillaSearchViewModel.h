//
//  MGSFeedzillaSearchViewModel.h
//  RCPlayground
//
//  Created by Michael James on 4/17/13.
//  Copyright (c) 2013 Maple Glen Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

@interface MGSFeedzillaSearchViewModel : NSObject

- (IBAction)search: (id)sender;

- (RACSignal*)culturesContentSignal;
- (RACSignal*)categoriesContentSignal;
- (RACSignal*)subcategoriesContentSignal;

@end
