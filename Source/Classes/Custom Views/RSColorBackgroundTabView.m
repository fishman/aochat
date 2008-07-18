//
//  RSColorBackgroundTabView.m
//  FlexTime
//
//  Created by Daniel Jalkut on 10/25/06.
//  Copyright 2006 Red Sweater Software. All rights reserved.
//

#import "RSColorBackgroundTabView.h"


@implementation RSColorBackgroundTabView

- (id)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:frameRect])
	{
		mBackgroundColor = [[NSColor whiteColor] retain];
	}

	return self;
}

- (void) dealloc
{
	[mBackgroundColor release];
	[super dealloc];
}

- (void) drawRect:(NSRect)rect
{
	if (([self drawsBackground] == YES) && ([self tabViewType] == NSNoTabsNoBorder))
	{
		// Draw our own background - which is all a "no tabs no border" box ever draws, so 
		// we don't need to worry about calling through to super.
		[mBackgroundColor set];
		NSRectFill([self bounds]);
	}
	else
	{
		[super drawRect:rect];
	}
}

//  backgroundColor 
- (NSColor *) backgroundColor
{
	return mBackgroundColor; 
}

- (void) setBackgroundColor: (NSColor *) theBackgroundColor
{
	if (mBackgroundColor != theBackgroundColor)
	{
		[mBackgroundColor release];
		mBackgroundColor = [theBackgroundColor retain];

		[self setNeedsDisplay:YES];
	}
}

@end
