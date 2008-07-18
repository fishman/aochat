//
//  HTMLTextView.h
//  aorc
//
//  Created by Reza Jelveh on 9/3/07.
//  Copyright 2007
//  License: GPL
//

#import <Cocoa/Cocoa.h>


@interface HTMLTextView : NSTextView {
	NSMutableDictionary * optionDict;
	NSDictionary *attributes;
	bool        atBottom;
	bool				enableLogging;
}
- (void)initStringAttributes;
- (void)scroll;
- (void)insertNormalText:(NSString*)theText;
- (NSString*)insertAttributedText:(NSString*)theText;

@end
