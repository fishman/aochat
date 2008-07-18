//
//  ChatRefDisplay.h
//  aorc
//
//  Created by Reza Jelveh
//  Copyright 2007
//  License: GPL
//

#import <Cocoa/Cocoa.h>

@interface ChatRefDisplay : NSObject
{
    IBOutlet NSTextView *textView;
    IBOutlet NSWindow *window;
}

+ (ChatRefDisplay*)sharedManager;
- (void)showRef:(NSString*)refText;
@end
