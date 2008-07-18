//
//  FIFOQueue.m
//  aorc
//
//  Created by Reza Jelveh on 9/4/07.
//  Copyright 2007
//  License: GPL
//

#import "FIFOQueue.h"


@implementation FIFOQueue
- (id)init
{
	self = [super init];
	if (self)
	{
		queue = [[NSMutableArray alloc] init];
		[queue retain];
		size = 15;
		currentSize = 0;
	}
	return self;
}

- (void)dealloc
{
	[queue release];
	[super dealloc];
}

- (void)push:(id)newObject
{
	[newObject retain];
	
	if(currentSize < size)
		currentSize++;
	else
		[queue removeObjectAtIndex:(currentSize-1)];
		
	[queue insertObject:newObject atIndex:0];
}

- (id)pop
{
	id object = nil;
	if (currentSize)
	{
		currentSize--;
		object = [queue objectAtIndex:currentSize];
		[queue removeObjectAtIndex:currentSize];
	}
	return object;
}

- (BOOL)hasItems
{
	return (currentSize ? YES : NO);
}

- (id)popAndKeep
{
	id object = nil;
	if (currentSize)
		object = [queue objectAtIndex:currentSize-1];

	return object;
}
@end
