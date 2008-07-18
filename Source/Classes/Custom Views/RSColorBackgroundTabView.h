//
//  RSColorBackgroundTabView.h
//  FlexTime
//
//  Created by Daniel Jalkut on 10/25/06.
//  Copyright 2006 Red Sweater Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RSColorBackgroundTabView : NSTabView
{
	NSColor* mBackgroundColor;
}

- (NSColor *) backgroundColor;
- (void) setBackgroundColor: (NSColor *) theBackgroundColor;

@end
