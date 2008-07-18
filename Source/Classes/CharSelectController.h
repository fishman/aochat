//
//  CharSelectController.h
//  aorc
//
//  Created by Reza Jelveh
//  Copyright 2007
//  License: GPL
//

#import <Cocoa/Cocoa.h>
#import "ChatController.h"

@interface CharSelectController : NSObject
{
    IBOutlet NSPopUpButton *characterId;
    IBOutlet NSWindow *window;
	IBOutlet ChatController *chatController;
}

+ (CharSelectController*)sharedManager;
+ (id)allocWithZone:(NSZone *)zone;

- (IBAction)connect:(id)sender;
- (void)setUsers:(NSArray *)anArgument;
- (void)show;
- (void)hide;

@end
