//
//  FriendItem.m
//  aorc
//
//  Created by Reza Jelveh on 9/1/07.
//  Copyright 2007
//  License: GPL
//

#import "FriendItem.h"


@implementation FriendItem

- (void)dealloc
{
	[userName release];
	[userID release];
	[friendType release];
	[statusIcon release];
	[super dealloc];
}

- (NSString *)name
{
	return userName;
}

- (void)setName:(NSString *)uName
{
	[uName retain];
	[userName release];
	userName = uName;
}

- (void)setUID:(int)uid{
	[userID release];
	userID = [NSNumber numberWithInt:uid];
	[userID retain];
}

- (NSString*)type
{
	return friendType;
}

- (void)setType:(NSString *)type{
	[type retain];
	[friendType release];
	friendType = type;
}

- (BOOL)status
{
	return online;
}

- (void)setStatus:(int)isOnline{
	online = isOnline ? YES : NO;
}

- (NSImage*)icon
{
	return statusIcon;
}
- (void)setIcon:(NSImage *)newIcon
{
	[newIcon retain];
	[statusIcon release];
	statusIcon = newIcon;
}

- (NSComparisonResult)compareName:(FriendItem *)anotherFriend
{
	if(online == NO){
		if([anotherFriend status] == YES)
			return NSOrderedDescending;
	}	
	else{
		if([anotherFriend status] == NO)
			return NSOrderedAscending;
	}
	
	if([friendType isEqual:@"Temporary"]){
		if([[anotherFriend type] isEqual:@"Permanent"])
		{
			return NSOrderedDescending;
		}
	}
	else{
		if([[anotherFriend type] isEqual:@"Temporary"])
		{
			return NSOrderedAscending;
		}
	}
	
	return [userName caseInsensitiveCompare:[anotherFriend name]];
}


@end
