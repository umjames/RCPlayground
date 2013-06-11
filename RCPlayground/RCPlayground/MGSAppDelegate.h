//
//  MGSAppDelegate.h
//  RCPlayground
//
//  Created by Michael James on 4/14/13.
//  Copyright (c) 2013 Maple Glen Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// app delegate that also acts as controller for application's single window
@interface MGSAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource>

@property (assign) IBOutlet NSWindow*       window;
@property (assign) IBOutlet NSPopUpButton*  culturePopUpButton;
@property (assign) IBOutlet NSPopUpButton*  categoryPopUpButton;
@property (assign) IBOutlet NSPopUpButton*  subcategoryPopUpButton;
@property (assign) IBOutlet NSTableView*    searchResultsTable;
@property (assign) IBOutlet NSButton*       searchButton;

// search button is pressed
- (IBAction)search: (id)sender;

@end
