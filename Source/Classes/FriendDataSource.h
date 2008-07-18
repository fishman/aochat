//
//  FriendDataSource.h
//  aorc
//
//  Created by Reza Jelveh
//  Copyright 2007
//  License: GPL
//

#import <Cocoa/Cocoa.h>
#import "ChatController.h"

@interface FriendDataSource : NSObject
{	
	IBOutlet id chatController;
	NSMutableArray * friendList; 
	NSImage *statusOnline;
	NSImage *statusOffline;
	NSImage *statusTempOnline;
	NSImage *statusTempOffline;
}

- (id)init;
- (void)addFriend:(NSString *)aString withType:(NSString *)buddyType andState:(int)onlineStatus andID:(int)uid;
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (void)clearFriends;
- (void)removeFriend:(NSString *)aString;
@end
