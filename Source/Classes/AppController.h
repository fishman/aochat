//
//  AppController.h
//  aorc
//
//  Created by Reza Jelveh
//  Copyright 2007
//  License: GPL
//

#import <Cocoa/Cocoa.h>

@interface AppController : NSObject
{
}
- (IBAction)addFriend:(id)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)nextTab:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)previousTab:(id)sender;
- (IBAction)showChat:(id)sender;
- (IBAction)showLogin:(id)sender;
- (IBAction)showStatus:(id)sender;
- (IBAction)showTell:(id)sender;
- (IBAction)toggleDrawer:(id)sender;
- (void)registerURLHandler;

@end
