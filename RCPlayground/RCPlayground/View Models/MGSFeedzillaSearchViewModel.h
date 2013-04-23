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
- (IBAction)cultureSelected: (id)sender;
- (IBAction)categorySelected: (id)sender;
- (IBAction)subcategorySelected: (id)sender;

- (RACSignal*)enableSearchSignal;

- (RACSignal*)culturesContentSignal;
- (RACSignal*)categoriesContentSignal;
- (RACSignal*)subcategoriesContentSignal;

@end
