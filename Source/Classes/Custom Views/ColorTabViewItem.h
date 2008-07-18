//
//  ColorTabViewItem.h
//  aorc
//
//  Created by Reza Jelveh on 9/1/07.
//  Copyright 2007
//  License: GPL
//

#import <Cocoa/Cocoa.h>


@interface ColorTabViewItem : NSTabViewItem {
	NSColor * inactiveColor;
	NSColor * normalColor;
	NSMutableDictionary * textAttributes;
}
- (void)markInactive;
- (void)markActive;

@end
