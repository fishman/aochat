//
//  AOChatBinding.h
//  aorc
//
//  Created by Reza Jelveh on 8/28/07.
//  Copyright 2007
//  License: GPL
//

#import <Cocoa/Cocoa.h>
#import "aochat.h"
#import "AOMessageQueue.h"
#import "FriendDataSource.h"
#import "ChatController.h"

enum{
	RK1 = 1,
	RK2,
	RK3,
	RK_TUNNEL
};

@interface AOChatBinding : NSObject {
	NSString * userName;
	NSString * passWord;
	const char *ao_user, *ao_pass;
	aocNameList *namelist;
	aocConnection *aoc;
	BOOL connected;
  NSString *myCharName;
  int connectedServer;

	NSMutableArray *userArray;
	NSMutableArray *friendList;
	NSTimer *timer;
	uint32_t myUid;
	NSMutableDictionary * chatGroups;
	
	AOMessageQueue * messageQueue;
	BOOL groupJoinMessages;
	BOOL showShopping;
	id friendDataSource;
	
	id chatController;
}

- (id)initWithController:(id)controller;
- (void)selectUser:(NSString *)myUser;
- (void)handleEvents;
- (BOOL)isConnected;
- (BOOL)initWithUser:(NSString *)user andPassword:(NSString *)pass andServer:(int)server;
- (void)handleMessage:(aocMessage*)msg;
- (NSString *)getCharName:(uint32_t) uid;
- (void)sendTell:(NSString*)aString toChar:(NSString*)uName;
- (void)sendGroup:(NSString*)aString toChar:(NSString*)gName;
- (void)sendCommand:(NSString*)aString withString:(NSString*)uName;
- (NSDictionary *)createUser:(aocMessage*)aoMsg withIndex:(int)index;
- (void)disconnect;

@end
