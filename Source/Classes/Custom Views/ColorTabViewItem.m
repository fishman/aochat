//
//  ColorTabViewItem.m
//  aorc
//
//  Created by Reza Jelveh on 9/1/07.
//  Copyright 2007
//  License: GPL
//

#import "ColorTabViewItem.h"


@implementation ColorTabViewItem

- (void)dealloc
{
	[inactiveColor release];
	[normalColor release];
	[super dealloc];
}
- (void)drawLabel:(BOOL)shouldTruncateLabel inRect:(NSRect)tabRect
{
	if(!inactiveColor)
	{
		inactiveColor = [NSColor redColor];
		normalColor = [NSColor blackColor];
		NSMutableParagraphStyle *parrafo = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
		textAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
			normalColor, NSForegroundColorAttributeName,
			parrafo, NSParagraphStyleAttributeName, 
			[NSFont menuFontOfSize:0], NSFontAttributeName, nil];
		
		[textAttributes retain];
		[inactiveColor retain];
		[normalColor retain];
	}

				
	NSMutableAttributedString * attributedLabel = [[NSAttributedString alloc] initWithString:[self label] attributes:textAttributes];
	
	
	[attributedLabel drawInRect: tabRect];
}

- (void)markInactive
{
	[textAttributes setObject:inactiveColor forKey:NSForegroundColorAttributeName];
	[[self tabView] setNeedsDisplay:YES];
}

- (void)markActive
{
	[textAttributes setObject:normalColor forKey:NSForegroundColorAttributeName];
}

@end
