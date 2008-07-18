//
//  CharSelectController.m
//  aorc
//
//  Created by Reza Jelveh
//  Copyright 2007
//  License: GPL
//

#import "CharSelectController.h"
#import "AOChatBinding.h"

@implementation CharSelectController

- (void)awakeFromNib
{
	[window setCollectionBehavior:NSWindowCollectionBehaviorMoveToActiveSpace];
}

- (void)setUsers:(NSArray *)charArray
{
	NSEnumerator *enumerator = [charArray objectEnumerator];
	NSDictionary *currentUser;

	[characterId removeAllItems];
	while (currentUser = [enumerator nextObject]) {
		[characterId addItemWithTitle:[currentUser objectForKey:@"User Name"]];
	}
	
	[self show];
}

- (IBAction)connect:(id)sender
{
	NSString * myUser;
	myUser = [characterId titleOfSelectedItem];
	//FIXME: currently only does one document
	// ChatController *chatController = [[[[NSDocumentController sharedDocumentController] documents] objectAtIndex:0] chatController];
	
	[[chatController aoChatBinding] selectUser:myUser];
	
	[self hide];
}

- (void)hide
{
	[window orderOut:nil]; // to hide it
}

- (void)show
{
	[window makeKeyAndOrderFront:nil];
}
@end
