//
//  MGSAppDelegate.h
//  RCPlayground
//
//  Created by Michael James on 4/14/13.
//  Copyright (c) 2013 Maple Glen Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MGSAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow*       window;
@property (assign) IBOutlet NSPopUpButton*  culturePopUpButton;
@property (assign) IBOutlet NSPopUpButton*  categoryPopUpButton;
@property (assign) IBOutlet NSPopUpButton*  subcategoryPopUpButton;
@property (assign) IBOutlet NSTableView*    searchResultsTable;
@property (assign) IBOutlet NSButton*       searchButton;

- (IBAction)search: (id)sender;

@end
