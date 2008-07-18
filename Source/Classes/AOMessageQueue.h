//
//  AOMessageQueue.h
//
//  Created by Reza Jelveh on 2007-09-05.
//  Copyright 2007
//  License: GPL
//

#import <Cocoa/Cocoa.h>
#import "FIFOQueue.h"
@interface AOMessageQueue : NSObject
{
	FIFOQueue * queue;
	id aoChatBinding;
}

- (void)addAOMessage:(SEL)funcSel withObject:(id)firstParam withObject:(id)secondParam;
- (BOOL)hasMessages;
- (void)consumeMessage;
- (id)getLastDate;
- (BOOL)hasItems;

@end
