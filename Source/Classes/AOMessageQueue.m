//
//  AOMessageQueue.mm
//
//  Created by Reza Jelveh on 2007-09-05.
//  Copyright 2007
//  License: GPL
//

#import "AOMessageQueue.h"
#import "AOChatBinding.h"


@implementation AOMessageQueue

- (id)initWithController:(id)binding
{
	self = [super init];
	if (self)
	{
		// .
		queue = [[FIFOQueue alloc] init];
		aoChatBinding = binding;
		[aoChatBinding retain];
		[queue retain];
	}
	return self;
}

- (void)dealloc
{
	[aoChatBinding release];
	[queue release];
	[super dealloc];
}

- (void)addAOMessage:(SEL)funcSel withObject:(id)firstParam withObject:(id)secondParam
{
	NSString *funcName = [NSString stringWithUTF8String:sel_getName(funcSel)];

	NSDictionary *newObject = [NSDictionary dictionaryWithObjectsAndKeys:
																					funcName, @"selector", 
																					firstParam, @"firstParam", 
																					secondParam, @"secondParam", 
																					[NSDate date], @"currentDate", nil];
																					
	[queue push:newObject];
}

- (void)consumeMessage
{
	NSDictionary * message = [queue pop];
	
	if (message)	
	{
		id funcName    = [message objectForKey:@"selector"];
		id firstParam  = [message objectForKey:@"firstParam"];
		id secondParam = [message objectForKey:@"secondParam"];
		SEL func = sel_getUid([funcName UTF8String]);
		
		[aoChatBinding performSelector:func withObject:firstParam withObject:secondParam];		
	}
}

- (id)getLastDate
{
	NSDictionary * message = [queue popAndKeep];
	id date = nil;
	
	if (message)	
		date = [message objectForKey:@"currentDate"];

	return date;
}

- (BOOL)hasItems
{
	return [queue hasItems];
}
@end
