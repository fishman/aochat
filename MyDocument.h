//
//  MyDocument.h
//  documentbased
//
//  Created by Reza Jelveh on 11/26/07.
//  Copyright 2007
//  License: GPL
//


#import <Cocoa/Cocoa.h>
#import "ChatController.h"
#import "AOChatBinding.h"
#import "FriendDataSource.h"

@interface MyDocument : NSDocument
{
	IBOutlet ChatController *chatController;
	IBOutlet AOChatBinding *aoChatBinding;
	IBOutlet FriendDataSource *friendDataSource;
}
@end
