//
//  AOChatBinding.m
//  aorc
//
//  Created by Reza Jelveh on 8/28/07.
//  Copyright 2007
//  License: GPL
//

#import "AOChatBinding.h"
#import "CharSelectController.h"
#import "LoginController.h"


@implementation AOChatBinding

- (id)initWithController:(id)controller
{
	if ((self = [super init]) != nil)
	{
		NSUserDefaultsController *sdc = 
		[NSUserDefaultsController sharedUserDefaultsController];
		
		[sdc addObserver:self forKeyPath:@"values.groupJoinMessages" options:nil context:nil];
		[sdc addObserver:self forKeyPath:@"values.showShopping" options:nil context:nil];
		
		chatController = controller;
		[chatController retain];
	}
	
	return self;
}

- (void)dealloc
{
	NSUserDefaultsController *sdc = [NSUserDefaultsController sharedUserDefaultsController];
	[sdc removeObserver:self forKeyPath:@"values.groupJoinMessages"];
	[sdc removeObserver:self forKeyPath:@"values.showShopping"];
	
  [myCharName release];
	[userArray release];
	[userName release];
	[passWord release];
	[chatGroups release];
	[chatController release];
	
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{	
	NSDictionary * defaultsDictionary = [[NSUserDefaultsController sharedUserDefaultsController] values];

	//TODO: properly detect the observed value instead of setting all at once
	groupJoinMessages = [[defaultsDictionary valueForKey:@"groupJoinMessages"] boolValue];
	showShopping = [[defaultsDictionary valueForKey:@"showShopping"] boolValue];
}

- (BOOL)isConnected
{
	return connected;
}

- (NSString*)charName 
{
 return myCharName;
}

- (int)connectedServer
{
  return connectedServer;
}

- (BOOL)initWithUser:(NSString *) user andPassword:(NSString *) pass andServer:(int)server
{
  struct sockaddr_in *addr; 

  connected = NO;

  userName = [NSString stringWithString:user];
  passWord = [NSString stringWithString:pass];

  [userName retain];
  [passWord retain];

  ao_user = [userName cStringUsingEncoding:NSASCIIStringEncoding];
  ao_pass = [passWord cStringUsingEncoding:NSASCIIStringEncoding];

  connectedServer = server;

  /* Look up IPv4 address for chat server */
	switch(server)
	{
		case RK1:
		NSLog(@"Resolving %s...\n", AOC_SERVER_RK1);
		addr = aocMakeAddr(AOC_SERVER_RK1, 7101);
		// addr = aocMakeAddr(AOC_SERVER_RK1, 7500);
		break;

		case RK2:
		NSLog(@"Resolving %s...\n", AOC_SERVER_RK2);
		addr = aocMakeAddr(AOC_SERVER_RK2, 7102);
		break;
		
		default:
		case RK3:
		NSLog(@"Resolving %s...\n", AOC_SERVER_RK3);
		addr = aocMakeAddr(AOC_SERVER_RK3, 7103);
		break;
		
		case RK_TUNNEL:
		addr = aocMakeAddr("localhost", 7101);
		break;
	}

  if(addr == NULL)
  {
		// NSRunCriticalAlertPanelRelativeToWindow(@"Connection Problem",
		// 																				@"DNS Lookup Failure",
		// 																				@"Ok", nil, nil, [[LoginController sharedManager] window]);
    
		[[chatController loginController] performSelectorOnMainThread:@selector(showAlert:)
                                                           withObject:@"DNS Lookup Failure"
                                                        waitUntilDone:NO];
    return FALSE;
  }

  /* Allocate and initialize a new connection */
  aoc = aocInit(NULL);

  /* Connect to chat server */
  if(!aocConnect(aoc, addr))
  {
		[[chatController loginController] performSelectorOnMainThread:@selector(showAlert:)
                                                           withObject:@"Could not create socket."
                                                        waitUntilDone:NO];

    return FALSE;
  }

	/* Initialize the built-in tell queue */
	namelist = aocNameListNew(256);

	aocMsgQueueSetNameList(aoc, namelist);

	chatGroups = [[[NSMutableDictionary alloc] init] autorelease];
	[chatGroups retain];
	
	messageQueue = [[AOMessageQueue alloc] initWithController:self];
	[messageQueue retain];
	
	connected = YES;
	
	/* Set defaults from configuration */
	//groupJoinMessages = [[NSUserDefaults standardUserDefaults] boolForKey:@"groupJoinMessages"];
	NSDictionary * defaultsDictionary = [[NSUserDefaultsController sharedUserDefaultsController] values];

	groupJoinMessages = [[defaultsDictionary valueForKey:@"groupJoinMessages"] boolValue];
	showShopping = [[defaultsDictionary valueForKey:@"showShopping"] boolValue];
	
	/* start the message handle */
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                           target:self 
                                         selector:@selector(handleEvents) 
                                         userInfo:nil 
                                          repeats:YES];
																				
	return YES;
}

- (void)handleEvents
{
  aocEvent *event;

  if (!connected)
    return;

  /* Poll the connection */
  aocPollVarArg(0, 1, 1, aoc);

	
	if ([messageQueue hasItems])
	{
		NSDate * currentDate = [NSDate date];
		NSDate * date = [messageQueue getLastDate];
		
		if ([currentDate timeIntervalSinceDate:date] > 0.5)
		{
			[messageQueue consumeMessage];
		}
	}
  /* Process events */
  while((event = aocEventGet()))
  {
    switch(event->type)
    {
      case AOC_EVENT_CONNECT:
        NSLog(@"Connected to chat server!\n");
        [chatController addStatusText:[NSString stringWithFormat:@"Connected to chat server"]];
        break;

      case AOC_EVENT_CONNFAIL:
        NSLog(@"Connection failed. (%s)\n",
            strerror((int)event->data));
        [timer invalidate];
        connected = NO;
        break;

      case AOC_EVENT_DISCONNECT:
        NSLog(@"Disconnected from chat server. (%s)\n",
            strerror((int)event->data));
        [chatController addStatusText:[NSString stringWithFormat:@"Disconnected from chat server. (%s)", strerror((int)event->data)]];
        [timer invalidate];
				[[chatController friendDataSource] clearFriends];
        connected = NO;
        break;

      case AOC_EVENT_MESSAGE:
         [self handleMessage:(aocMessage *)event->data];
         break;
    }

    /* Destroy the event */
    aocEventDestroy(event);
  }
}

- (void)handleMessage:(aocMessage*)msg
{
	uint32_t uid;
	
	switch(msg->type)
  {
    case AOC_SRV_LOGIN_SEED:
      {
        ao_user = [userName cStringUsingEncoding:NSASCIIStringEncoding];
        ao_pass = [passWord cStringUsingEncoding:NSASCIIStringEncoding];

        char *key = aocKeyexGenerateKey(AOC_STR(msg->argv[0]), ao_user, ao_pass);

        if(key == NULL)
        {
          /* This will never happen */
          NSLog(@"Could not generate login key.\n");
          connected = NO;
          break;
        }

        aocSendLoginResponse(aoc, 0, ao_user, key);
				
        aocFree(key);
      }
      break;


    case AOC_SRV_LOGIN_CHARLIST:
      {
        int nchars, i;
        void *user_id, *charname, *level, *online;

        nchars = aocMsgArraySize(msg, 0);

        userArray = [NSMutableArray array];


        NSLog(@"%d characters available:\n", nchars);
        for(i=0; i<nchars; i++)
        {

          NSDictionary * user = [self createUser:msg withIndex:i];
          [userArray addObject:user];

          user_id  = aocMsgArrayValue(msg, 0, i, NULL, NULL);
          charname = aocMsgArrayValue(msg, 1, i, NULL, NULL);
          level    = aocMsgArrayValue(msg, 2, i, NULL, NULL);
          online   = aocMsgArrayValue(msg, 3, i, NULL, NULL);

          // NSLog(@"%10d %15s %10d %10d\n",
          //     user_id  ? (int)AOC_INT(user_id)  : (int)AOC_INVALID_UID,
          //     charname ? AOC_STR(charname)      : "-",
          //     level    ? (int)AOC_INT(level)    : 0,
          //     online   ? (int)AOC_INT(online)   : -1);
        }

        [[chatController charSelectController] setUsers:userArray];
      }
      [userArray retain];
      break;


    case AOC_SRV_LOGIN_ERROR:
			NSLog(@"Login error: %s", AOC_STR(msg->argv[0]));
			NSRunCriticalAlertPanelRelativeToWindow(@"Login Error",
										    		[NSString stringWithFormat:@"%s", AOC_STR(msg->argv[0])],
										    		@"Ok", nil, nil, [[chatController loginController] window]);
      break;
			
			/*
					msg->argv[0] = (Integer) UserID
					msg->argv[1] = (Integer) Status (0 = Offline, 1 = Online)
					msg->argv[2] = (String) Buddy type ('\0' = Temp, '\1' = Perm)
									(AOC_BUDDY_TEMPORARY, AOC_BUDDY_PERMANENT)
			*/
		case AOC_SRV_BUDDY_STATUS:
		{
			uid = AOC_INT(msg->argv[0]);
			
			[[chatController friendDataSource] addFriend:[self getCharName:uid]
                                          withType:AOC_STR(msg->argv[2])[0] ? @"Permanent" : @"Temporary"
                                          andState:AOC_INT(msg->argv[1])
                                             andID:uid];
		}
		break;
		
		case AOC_SRV_BUDDY_REMOVED:
		{
			uid = AOC_INT(msg->argv[0]);
			
			[[chatController friendDataSource] removeFriend:[self getCharName:uid]];
			
			aocNameListDeleteByUID(namelist, uid);
		}
		break; 
		
		
		case AOC_SRV_CLIENT_NAME:
		case AOC_SRV_LOOKUP_RESULT:
		{
			char *charname;
			
			uid = AOC_INT(msg->argv[0]);
			charname = AOC_STR(msg->argv[1]);

			aocNameListInsert(namelist, uid, charname, NULL);
			// NSLog(@"Player %s has user id %d\n", charname, uid);
		}
		break;
		
		case AOC_SRV_PRIVGRP_CLIPART:
		case AOC_SRV_PRIVGRP_CLIJOIN:
		{
			//FIXME: whats the overhead of using theDefaultsController on each join/leave?
			if(groupJoinMessages){
				uid = AOC_INT(msg->argv[1]);
			
				if(myUid == uid)
					break;
			
				uint32_t gid = AOC_INT(msg->argv[0]);
			
				NSString *groupName = [self getCharName:gid];
				NSString *charName = [self getCharName:uid];
				NSString *message = [NSString stringWithFormat:@"<font color=\"grey\" face=\"Lucida Grande\">[<a href=\"chatgroup://%@\" style=\"text-decoration: none\">%@</a>] %@ %s the group.</font>",
				  																										groupName,
																															groupName,
																															charName,
																															msg->type == AOC_SRV_PRIVGRP_CLIPART ? "left" : "joined"];
				[chatController addChatText:message];
			}
			break;
		}
		
		case AOC_SRV_CHAT_NOTICE:
		{
			int type; 
			
			uid = AOC_INT(msg->argv[0]);
			type = AOC_INT(msg->argv[2]);
			// str = AOC_STR(msg->argv[3]);
			// str = aocMsgArrayValue(msg, 3, 2, NULL, NULL);
      
			switch (type)
			{
				case 0xa460d92: // offline tell to me
					// NSLog(@"Offline message from %@ (%s)", [self getCharName:uid], str);
					[chatController addTellStatusMessage:[NSString stringWithFormat:@"Offline message from %@", 
																																		[self getCharName:uid]]];
				break;
				
				case 0x9740ff4: // target is offline
					//NSLog(@"%@ is offline, message has been buffered", [self getCharName:uid]);
					[chatController addTellStatusMessage:[NSString stringWithFormat:@"%@ is offline, message has been buffered", 
																																		[self getCharName:uid]]];
					break; 
				
				case 0x340e245:
				// some error;
				NSLog(@"something bad happened");
				// Could not send message to offline player; the receivers inbox is full
				// Message too large
				break;
				
				default:
				NSLog(@"no idea what happened");
			}

		}
		break;
			
			
    case AOC_SRV_GROUP_JOIN:
      {
        unsigned char *g = AOC_GRP(msg->argv[0]);

        // NSLog(@"Joined group '%s' grpid %02x%02x%02x%02x%02x flags %04x:%08x\n",
        //     AOC_STR(msg->argv[1]), g[0], g[1], g[2], g[3], g[4],
        //     AOC_WRD(msg->argv[2]), AOC_INT(msg->argv[3]));
        NSLog(@"Joined server group '%s'\n",
            AOC_STR(msg->argv[1]));

        // [chatController addStatusText:[NSString stringWithFormat:@"Joined group %s", AOC_STR(msg->argv[1])]];
        [chatController addStatusText:[NSString stringWithFormat:@"Joined group %s", AOC_STR(msg->argv[1])]];

        [chatController addGroup:[NSString stringWithCString:AOC_STR(msg->argv[1])encoding:NSASCIIStringEncoding]
                                         withGID:[NSData dataWithBytes:g length:5]];

				[chatGroups setObject:[NSString stringWithCString:AOC_STR(msg->argv[1])encoding:NSASCIIStringEncoding]
                       forKey:[NSData dataWithBytes:g length:5]];
                       // forKey:[NSString stringWithFormat:@"%02x%02x%02x%02x%02x", g[0], g[1], g[2], g[3], g[4]]];
			//	aocSendGroupDataset(aoc, g, AOC_GROUP_UNMUTE, 0);
			
      }
      break;
		case AOC_SRV_SYSTEM_MSG:
			[chatController addStatusText:[NSString stringWithCString:AOC_STR(msg->argv[0])]];
			break;
			
		case AOC_SRV_PRIVGRP_INVITE:
		{
			NSString * charName = [self getCharName:AOC_INT(msg->argv[0])];
			// NSNumber *uid = [NSNumber numberWithInt:AOC_INT(msg->argv[0])];
			uid = AOC_INT(msg->argv[0]);
			
			[chatController addStatusText:[NSString stringWithFormat:@"Joined private group: %@", charName]];
			[chatController addGroup:charName
			                                       withGID:[NSNumber numberWithInt:uid]];
			[chatGroups setObject:charName
                     forKey:[NSNumber numberWithInt:uid]];
			
																																																						
			aocSendPrivateGroupJoin(aoc, uid);
		}
		break;
		
		case AOC_SRV_PRIVGRP_PART:
		{
			NSString * charName = [self getCharName:AOC_INT(msg->argv[0])];
			uid = AOC_INT(msg->argv[0]);
			
			[chatController addStatusText:[NSString stringWithFormat:@"Left private group: %@", charName]];
			[chatGroups setObject:charName
                     forKey:[NSNumber numberWithInt:uid]];
		}
		break;
			
		case AOC_SRV_PRIVGRP_KICK:
		{
			NSString * charName = [self getCharName:AOC_INT(msg->argv[0])];
			uid = AOC_INT(msg->argv[0]);
			
			[chatController addStatusText:[NSString stringWithFormat:@"Kicked from private group: %@", charName]];
			[chatGroups setObject:charName
                     forKey:[NSNumber numberWithInt:uid]];
		}
		break;
			
		case AOC_SRV_PRIVGRP_MSG:
			{
				uint32_t gid = AOC_INT(msg->argv[0]);
				uid = AOC_INT(msg->argv[1]);
				
				NSString *groupName = [self getCharName:gid];
				NSString *charName = [self getCharName:uid];
				NSString *groupMsg = [NSString stringWithUTF8String:AOC_STR(msg->argv[2])];
				if(groupMsg == nil)
					groupMsg = [NSString stringWithCString:AOC_STR(msg->argv[2]) encoding:NSASCIIStringEncoding];
				
				NSString * message = [NSString stringWithFormat:@"<font color=\"grey\" face=\"Lucida Grande\">[<a href=\"chatgroup://%@\" style=\"text-decoration: none\">%@</a>] %@: %@</font>",
				  																										groupName,
																															groupName,
																															charName,
																															groupMsg];

				[chatController addChatText:message];
				
			}
			break;
			
    case AOC_SRV_GROUP_MSG:
		{
			// argv[1] == grpid
			unsigned char *g = AOC_GRP(msg->argv[0]);

			// NSString * grpid = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x", g[0], g[1], g[2], g[3], g[4]];
			NSData *grpid = [NSData dataWithBytes:g length:5];
			NSString *groupName = [chatGroups objectForKey:grpid];
			NSString *charName = [self getCharName:AOC_INT(msg->argv[1])];
			NSString *groupMsg = [NSString stringWithUTF8String:AOC_STR(msg->argv[2])];
			if(groupMsg == nil)
				groupMsg = [NSString stringWithCString:AOC_STR(msg->argv[2]) encoding:NSASCIIStringEncoding];
			
			NSString *message = [NSString stringWithFormat:@"<font face=\"Lucida Grande\">[<a href=\"chatgroup://%@\" style=\"text-decoration: none\">%@</a>] %@: %@</font>",
			  																										groupName,
																														groupName,
																														charName,
																														groupMsg];
																														
																									
			NSMutableString * fullMessage = [NSMutableString stringWithString:message];
			if ([groupName hasSuffix:@"OOC"]){
				[fullMessage insertString:@"<font color=green>" atIndex:0];
				[fullMessage appendString:@"</font>"];
			}
			else if ([groupName hasPrefix:@"Clan shopping" ]){
				// Check if we want to show shopping channel messages
				if (!showShopping)
					break;
				[fullMessage insertString:@"<font color=blue>" atIndex:0];
				[fullMessage appendString:@"</font>"];
			}
				
			else if ([groupName hasPrefix:@"All Towers"] || [groupName hasPrefix:@"Tower"]){
				[fullMessage insertString:@"<font color=red>" atIndex:0];
				[fullMessage appendString:@"</font>"];
			}
				

			[chatController addChatText:fullMessage];
	  }
		break;
		
		case AOC_SRV_MSG_PRIVATE:
		{
			char *str;
						
			uid = AOC_INT(msg->argv[0]);
			str = AOC_STR(msg->argv[1]);
						
			NSString * tellText = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
			if(tellText == nil)
				tellText = [NSString stringWithCString:str encoding:NSASCIIStringEncoding];
			
			[chatController addTellText:tellText
                         withName:[self getCharName:AOC_INT(msg->argv[0])]
                          andType:NO];
		}
		break;
			
  }



  return;

}


- (void)selectUser:(NSString *)myUser
{
  NSDictionary * userDict;
  NSEnumerator * enumerator = [userArray objectEnumerator];

  [myCharName release];
  while(userDict = [enumerator nextObject])
  {
    myCharName = [userDict objectForKey:@"User Name"];
    if([myCharName isEqual:myUser])
      break;
  }
  [myCharName retain];
	myUid = [[userDict objectForKey:@"User ID"] intValue];
	
	//FIXME:synchronizeWindowTitleWithDocumentName
  aocSendLoginSelectChar(aoc, myUid);
	[chatController show];
}

- (NSDictionary *)createUser:(aocMessage*)aoMsg withIndex:(int)index
{	
  NSMutableDictionary * user = [[[NSMutableDictionary alloc] init] autorelease];

  void *user_id, *charname, *level, *online;

  user_id  = aocMsgArrayValue(aoMsg, 0, index, NULL, NULL);
  charname = aocMsgArrayValue(aoMsg, 1, index, NULL, NULL);
  level    = aocMsgArrayValue(aoMsg, 2, index, NULL, NULL);
  online   = aocMsgArrayValue(aoMsg, 3, index, NULL, NULL);

  [user setObject:[NSNumber numberWithInt:user_id  ? (int)AOC_INT(user_id)  : (int)AOC_INVALID_UID] forKey:@"User ID"];
  [user setObject:[NSNumber numberWithInt:level    ? (int)AOC_INT(level)    : 0] forKey:@"Level"];
  [user setObject:[NSNumber numberWithInt:online   ? (int)AOC_INT(online)   : -1] forKey:@"Online"];
  [user setObject:[NSString stringWithCString:charname ? AOC_STR(charname)  : "-" encoding:NSASCIIStringEncoding] forKey:@"User Name"];

  return user;
}

- (NSString *)getCharName:(uint32_t) uid
{
	char *charname;
	NSString *charStr;
	
	charname = aocNameListLookupByUID(namelist, uid, NULL);
	if(charname == NULL)
		charStr = [NSString stringWithString:@"Unknown"];
	else
		charStr = [NSString stringWithCString:charname encoding:NSASCIIStringEncoding];
	
	return [charStr capitalizedString];
}

- (void)sendTell:(NSString*)aString toChar:(NSString*)uName
{
	// some handling
	if(uName == nil) 
		return;
	
	char blob[] = "";
	
	NSMutableString *theTell=[aString mutableCopy];
	[theTell replaceOccurrencesOfString:@"&"
	                         withString:@"&amp;"
	                            options:NSLiteralSearch
	                              range:NSMakeRange(0, [theTell length])];
	[theTell replaceOccurrencesOfString:@"<"
	                         withString:@"&lt;"
	                            options:NSLiteralSearch
	                              range:NSMakeRange(0, [theTell length])];
	[theTell replaceOccurrencesOfString:@"<"
	                         withString:@"&lt;"
	                            options:NSLiteralSearch
	                              range:NSMakeRange(0, [theTell length])];

	
	uint32_t uid = aocNameListLookupByName(namelist, [uName cStringUsingEncoding:NSASCIIStringEncoding], NULL);
	const char * tell = [theTell UTF8String];
	if(uid!=AOC_INVALID_UID){
		aocSendPrivateMessage(aoc, uid, tell , -1, blob, 1);
		[chatController addTellText:aString
	                                     withName:uName
	                                      andType:YES];
	}
	else{
		aocSendNameLookup(aoc, [uName cStringUsingEncoding:NSASCIIStringEncoding]);
		[messageQueue addAOMessage:@selector(queueSendTell:withObject:) withObject:theTell withObject:uName];
	}
}

- (void)sendGroup:(NSString*)aString toChar:(NSString*)gName
{
	NSEnumerator * enumerator;
	char blob[] = "";	

	if(gName == nil)
	// some handling
		;
	
	NSMutableString *theTell=[aString mutableCopy];
	[theTell replaceOccurrencesOfString:@"&"
	                         withString:@"&amp;"
	                            options:NSLiteralSearch
	                              range:NSMakeRange(0, [theTell length])];
	[theTell replaceOccurrencesOfString:@"<"
	                         withString:@"&lt;"
	                            options:NSLiteralSearch
	                              range:NSMakeRange(0, [theTell length])];
	[theTell replaceOccurrencesOfString:@">"
	                         withString:@"&gt;"
	                            options:NSLiteralSearch
	                              range:NSMakeRange(0, [theTell length])];

	id key;
  NSArray * keyEnum = [chatGroups allKeys];
  enumerator = [keyEnum objectEnumerator];
	char * message = [theTell UTF8String] ;
		
	while (key = [enumerator nextObject])
	{
		if ([[chatGroups objectForKey:key] isEqual:gName])
		{
			if([key isKindOfClass:[NSData class]])
				aocSendGroupMessage(aoc, [key bytes], message, -1, blob, 1);
			else if([key isKindOfClass:[NSNumber class]])
				aocSendPrivateGroupMessage(aoc, [key intValue],  message, -1, blob, 1);
			return;
		}
	}
	
		
}

- (void)sendCommand:(NSString*)aCommand withString:(NSString*)theString
{	
	uint32_t uid = aocNameListLookupByName(namelist, [theString UTF8String], NULL);
	if(uid!=AOC_INVALID_UID)
	{
		if([aCommand isEqual:@"addbuddy"])
			aocSendBuddyAdd(aoc, uid, AOC_BUDDY_PERMANENT, 1);
		else if([aCommand isEqual:@"rembuddy"])
			aocSendBuddyRemove(aoc, uid);
	}
	else{
		aocSendNameLookup(aoc, [theString UTF8String]);
		[messageQueue addAOMessage:@selector(queueBuddyAdd:withObject:) withObject:aCommand withObject:theString];
	}
}

- (void)disconnect
{
	if (connected == NO)
		return;
	connected = NO;
	[chatController addStatusText:[NSString stringWithString:@"Disconnected from chat server."]];
	[[chatController friendDataSource] clearFriends];
	if(timer)
		[timer invalidate];
	aocDisconnect(aoc);
}

- (void)queueBuddyAdd:(id)aCommand withObject:(id)theString
{
	NSLog(@"queueBuddyAdd");
	uint32_t uid = aocNameListLookupByName(namelist, [theString UTF8String], NULL);
	if(uid!=AOC_INVALID_UID){
		if([aCommand isEqual:@"addbuddy"])
			aocSendBuddyAdd(aoc, uid, AOC_BUDDY_PERMANENT, 1);
		else if([aCommand isEqual:@"rembuddy"])
			aocSendBuddyRemove(aoc, uid);
	}
}

- (void)queueSendTell:(id)theTell withObject:(id)uName
{
	NSLog(@"queueSendTell");
	char blob[] = "";	
	uint32_t uid = aocNameListLookupByName(namelist, [uName UTF8String], NULL);
	char * tell = [theTell UTF8String];
	
	if(uid!=AOC_INVALID_UID){
		aocSendPrivateMessage(aoc, uid, tell , -1, blob, 1);
		[chatController addTellText:theTell
	                                     withName:uName
	                                      andType:YES];
	}

}


@end
