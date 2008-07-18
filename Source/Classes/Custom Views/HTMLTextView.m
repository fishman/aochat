//
//  HTMLTextView.m
//  aorc
//
//  Created by Reza Jelveh on 9/3/07.
//  Copyright 2007
//  License: GPL
//

#import "HTMLTextView.h"
#import <OgreKit/OgreKit.h>

#define SCROLLVIEW_TOLERANCE 40

@implementation HTMLTextView

- (void) layoutManager:(NSLayoutManager *) aLayoutManager 
    didCompleteLayoutForTextContainer:(NSTextContainer *) aTextContainer
    atEnd:(BOOL) flag
{
  if (atBottom)
		[self scrollPoint:NSMakePoint(0, NSMaxY([self bounds]))];
}


- (void)initStringAttributes
{
	NSFont *font = [NSFont fontWithName:@"Lucida Grande" size:12.0];
	[optionDict release];
 	optionDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"UseWebKit", 
																													@"utf-8", @"TextEncodingName", 
																													nil, @"BaseURL",nil];
																													
	[optionDict retain];
	// attributes = [[NSDictionary dictionaryWithObject:font
	//                                             forKey:NSFontAttributeName] retain];
}

- (void)dealloc
{
	NSUserDefaultsController *sdc = [NSUserDefaultsController sharedUserDefaultsController];
	[sdc removeObserver:self forKeyPath:@"values.enableLogging"];
	
	
	[optionDict release];
	[attributes release];
	[super dealloc];
}

- (void)awakeFromNib
{
	// Should scroll to bottom
	atBottom = true;
	// Initialise String attributes
	[self initStringAttributes];

	[[self layoutManager] setDelegate:self];	
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateAtBottom:)
                                               name:@"NSViewBoundsDidChangeNotification"
                                             object:[self superview]];

  // Read Preferences
	NSUserDefaultsController * sdc = [NSUserDefaultsController sharedUserDefaultsController];
	NSDictionary * defaultsDictionary = [sdc values];
	// Add Preference observer, to allow enabling and disabling of logging on the fly
	[sdc addObserver:self forKeyPath:@"values.enableLogging" options:nil context:nil];
	
	enableLogging = [[defaultsDictionary valueForKey:@"enableLogging"] boolValue];
}

// =========================================================================
// = Preferences Observer - Enable/Disable logging of chat texts           =
// =========================================================================
- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{	
	NSDictionary * defaultsDictionary = [[NSUserDefaultsController sharedUserDefaultsController] values];
	enableLogging = [[defaultsDictionary valueForKey:@"enableLogging"] boolValue];
}


// =========================================================================
// = Scroll to end of NSTextView                                           =
// =========================================================================
- (void)scroll
{
	[self scrollRangeToVisible:NSMakeRange([[self string] length]-1, 0)];	
}

- (void) updateAtBottom:(NSNotification *) notif
{
	NSClipView *clipView = (NSClipView *) [self superview];
	NSRect documentRect = [clipView documentRect];
	NSRect clipRect = [clipView documentVisibleRect];
	NSRect documentFrame = [[[self enclosingScrollView] documentView] frame];

	
	float cmax = NSMaxY(clipRect);
	// float dmax = NSMaxY(documentFrame);
	//	atBottom = dmax == cmax;
	
	// Enable autoscroll if visibleRect > framesize - tolerance
	atBottom = cmax > (documentFrame.size.height - SCROLLVIEW_TOLERANCE);
#if 0
	NSLog(@"Enclosing ScrollView %f, documentRect %f, documentVisibleRect %f, blub %f", 
																					NSMaxY([[self enclosingScrollView] documentVisibleRect]), 
																					NSMaxY(documentRect), 
																					NSMaxY(clipRect),
																					documentFrame.size.height);
#endif
}

- (void)insertNormalText:(NSString*)theText
{
	NSTextStorage * textStorage = [self textStorage];
	unsigned int length = [[self string] length];
	
	if(length)
	{
	 	[textStorage replaceCharactersInRange:NSMakeRange(length, 0) withString:@"\n"];
		[textStorage replaceCharactersInRange:NSMakeRange(length+1, 0) withString:theText];
	}
	else 
		[textStorage replaceCharactersInRange:NSMakeRange(length, 0) withString:theText];
}

- (NSString*)insertAttributedText:(NSString*)theText
{
	NSString *chatText;
	OGRegularExpression *regex;
	NSTextStorage * textStorage = [self textStorage];
	unsigned int length = [[self string] length];
	
	// Capture links - skip text:// links
	// regex = [OGRegularExpression regularExpressionWithString:@"(?:http://)[^(:tell://|chatcmd:///start )]?(\\w+\\.[\\w0-9]+\\.[\\w0-9]+)([a-zA-Z0-9/+?=&=:;.-]*)?"];
/*  regex = [OGRegularExpression regularExpressionWithString:@"(?:chatcmd:/+start http://((?:[\\w-]+\\.)+\\w+[/%\\?\\w=:\\+\\.\\-&;]+)'>([\\w+\\s&#;]+)</a>)|(:http:/+)(((?:[\\w-]+\\.)+\\w+[/%\\?\\w=:\\+\\.\\-&;]+))"];
	NSEnumerator    *enumerator = [regex matchEnumeratorInString:theText];
	OGRegularExpressionMatch    *match;	// マッチ結果
	NSString * reg1, *reg2, *reg3;
	
	while ((match = [enumerator nextObject]) != nil) {	// 順番にマッチ結果を得る	
		if(![[match matchedString] hasPrefix:@"chatcmd"]){
      theText = [regex replaceAllMatchesInString:theText
                                      withString:@"<a href='http://\\1'>\\1</a>"];
			NSLog(@"theText: %@", theText);
    }
	}*/
	// (?:[a-zA-Z][a-zA-Z0-9+.-]*://|www\\.)(?:[\\w-:]+@)?(?:(?:[\\p{L}\\p{N}-]+\\.)+\\w{2,4}\\.?|localhost)(?:\\:\\d+)?(?:[/?][\\p{L}\\p{N}$\\-_.+!*',=:\\|/\\()%@&;#?~]*)*(?=[>}\\]):;,.!?'\"]|\\b)"

	regex    = [OGRegularExpression regularExpressionWithString:@"itemref://(\\d+)/(\\d+)/(\\d+)"];
	chatText = [regex replaceAllMatchesInString:theText
																	 withString:@"http://aomainframe.info/showitem.asp?LowID=\\1&HiID=\\2&QL=\\3"];
	
	
	NSMutableString *string=[chatText mutableCopy];
	// Replace newlines with <br>
	[string replaceOccurrencesOfString:@"\n"
													 withString:@"<br>"
															options:NSLiteralSearch
																range:NSMakeRange(0, [string length])];
	[string replaceOccurrencesOfString:@"\r"
													 withString:@"<br>"
															options:NSLiteralSearch
																range:NSMakeRange(0, [string length])];
  // Replace white fonts
	[string replaceOccurrencesOfString:@"#FFFFFF"
													 withString:@"#689795"
															options:NSLiteralSearch
																range:NSMakeRange(0, [string length])];

	
	NSData *data = [string dataUsingEncoding: NSUTF8StringEncoding];
	
	NSAttributedString *attrString = [[[NSAttributedString alloc] initWithHTML: data
                                                                     options: optionDict
                                                          documentAttributes: nil] autorelease];
	[textStorage beginEditing];
	
	if(length)
	{
	 	[textStorage replaceCharactersInRange:NSMakeRange(length, 0) withString:@"\n"];
		[textStorage replaceCharactersInRange:NSMakeRange(length+1, 0)
                      withAttributedString:attrString];
	}
	else 
		[textStorage replaceCharactersInRange:NSMakeRange(length, 0)
                      withAttributedString:attrString];
		
	[textStorage endEditing];
	
	return [attrString string];
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
	NSString *word;  
	NSMenu *menu;
	return [super menuForEvent:event];
   word = [[self string] substringWithRange:[self selectedRange]];
//   ... do stuff here ...
   // return menu;
}


@end
