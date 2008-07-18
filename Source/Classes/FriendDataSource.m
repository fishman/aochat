//
//  FriendDataSource.m
//  aorc
//
//  Created by Reza Jelveh
//  Copyright 2007
//  License: GPL
//

#import "FriendDataSource.h"
#import "AOChatBinding.h"
#import "FriendItem.h"


@implementation FriendDataSource

- (id)init 
{
	[super init]; 

	friendList = [NSMutableArray array];
	statusOnline = [NSImage imageNamed:@"available.png"];
	statusOffline = [NSImage imageNamed:@"away.png"];
	statusTempOnline = [NSImage imageNamed:@"idle.png"];
	statusTempOffline = [NSImage imageNamed:@"offline.png"];
	
	
	[statusOnline retain];
	[statusOffline retain];
	[statusTempOnline retain];
	[statusTempOffline retain];
	[friendList retain];
	return self; 
}

- (void)removeFriend:(NSString *)aString 
{
	NSEnumerator *enumerator = [friendList objectEnumerator];
 	FriendItem * currentFriend;
	
	while (currentFriend = [enumerator nextObject]) {
		if([[currentFriend name] isEqual:aString]){			
			[friendList removeObject:currentFriend];
			[chatController reloadFriends];
			return;
		}
	}
}

- (void)clearFriends
{
	[friendList release];
	friendList = [NSMutableArray array];
	[friendList retain];
	
	[chatController reloadFriends];	
}


- (void)addFriend:(NSString*)aString
         withType:(NSString*)buddyType
         andState:(int)onlineStatus
            andID:(int)uid
{
	NSImage * status;
	FriendItem * newFriend;
	
	NSEnumerator *enumerator = [friendList objectEnumerator];
 	FriendItem * currentFriend;
	
	// If the friend already exist don't create a new one and alter online status
	// FIXME: this code should only set the icon and the status actually
	while (currentFriend = [enumerator nextObject]) {
		if([[currentFriend name] isEqual:aString]){
			// Found the name in the list
			if([buddyType isEqual:@"Temporary"])
				status = onlineStatus ? statusTempOnline : statusTempOffline;
			else
				status = onlineStatus ? statusOnline : statusOffline;

			[currentFriend setName:aString];
			[currentFriend setUID:uid];
			[currentFriend setType:buddyType];
			[currentFriend setStatus:onlineStatus];
			[currentFriend setIcon:status];
			
			[friendList sortUsingSelector:@selector(compareName:)];          
			[chatController reloadFriends];
			return;
		}
	}	
	
	newFriend = [[[FriendItem alloc] init] autorelease];
	if([buddyType isEqual:@"Temporary"])
		status = onlineStatus ? statusTempOnline : statusTempOffline;
	else
		status = onlineStatus ? statusOnline : statusOffline;

	[newFriend setName:aString];
	[newFriend setUID:uid];
	[newFriend setType:buddyType];
	[newFriend setStatus:onlineStatus];
	[newFriend setIcon:status];
	
  [friendList addObject:newFriend];

  [friendList sortUsingSelector:@selector(compareName:)];

	// Reload the friend table when done
	[chatController reloadFriends];	
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView         
{ 	
	return [friendList count];
}

- (id)tableView:(NSTableView*)tableView
objectValueForTableColumn:(NSTableColumn*)tableColumn
            row:(int)row
{ 
	NSString * identifier = [tableColumn identifier];
	// FoodItem * item = [items objectAtIndex:row];
	// return [item valueForKey:identifier];

	int count = [friendList count];
	if (count == 0) return @"nothing";
	
	FriendItem * friend = [friendList objectAtIndex:row];
	// NSDictionary *friend = [friendList objectAtIndex:row];	
	// return [friend objectForKey:identifier];
	if([identifier isEqual:@"Online"])
		return [friend icon];
	return [friend name];
}

@end 