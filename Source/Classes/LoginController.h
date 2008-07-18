//
//  LoginController.h
//  aorc
//
//  Created by Reza Jelveh
//  Copyright 2007
//  License: GPL
//

#import <Cocoa/Cocoa.h>
#import "ChatController.h"

@interface LoginController : NSObject
{
    IBOutlet NSSecureTextField *passField;
    IBOutlet NSTextField *userField;
    IBOutlet NSWindow *window;
	IBOutlet NSPopUpButton *serverName;
	IBOutlet ChatController *chatController;
}

+ (LoginController*)sharedManager;
+ (id)allocWithZone:(NSZone *)zone;

- (NSString *)windowNibName;
- (IBAction)hideWindow:(id)sender;
- (IBAction)login:(id)sender;
- (void)showReconnectSheet;

- (void)awakeFromNib;
- (void)show;
- (void)hide;
- (id)window;

@end
