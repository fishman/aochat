//
//  FriendItem.h
//  aorc
//
//  Created by Reza Jelveh on 9/1/07.
//  Copyright 2007
//  License: GPL
//

#import <Cocoa/Cocoa.h>


@interface FriendItem : NSObject {
	NSString * userName;
	NSNumber * userID;
	NSString * friendType;
	NSImage * statusIcon;
	BOOL online;
}

- (NSString*)name;
- (void)setName:(NSString *)uName;
- (void)setUID:(int)uid;
- (NSString*)type;
- (void)setType:(NSString *)type;
- (BOOL)status;
- (void)setStatus:(int)isOnline;
- (NSImage*)icon;
- (void)setIcon:(NSImage*)newIcon;
- (NSComparisonResult)compareNames:(FriendItem *)anotherFriend;
@end
