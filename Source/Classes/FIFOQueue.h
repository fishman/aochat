//
//  FIFOQueue.h
//  aorc
//
//  Created by Reza Jelveh on 9/4/07.
//  Copyright 2007
//  License: GPL
//

#import <Cocoa/Cocoa.h>


@interface FIFOQueue : NSObject {
	NSMutableArray * queue;
	unsigned int size;
	unsigned int currentSize;
}

- (void)push:(id)newObject;
- (id)pop;
- (id)popAndKeep;
- (BOOL)hasItems;

@end
