//
//  ChatRefDisplay.m
//  aorc
//
//  Created by Reza Jelveh
//  Copyright 2007
//  License: GPL
//

#import "ChatRefDisplay.h"

static ChatRefDisplay *sharedChatRefManager = nil;

@implementation ChatRefDisplay

+ (ChatRefDisplay*)sharedManager
{
  @synchronized(self) {
    if (sharedChatRefManager == nil) {
      [[self alloc] init]; // assignment not done here
    }
  }
  return sharedChatRefManager;
}


+ (id)allocWithZone:(NSZone *)zone
{
  @synchronized(self) {
    if (sharedChatRefManager == nil) {
      sharedChatRefManager = [super allocWithZone:zone];
      return sharedChatRefManager;  // assignment and return on first allocation
    }
  }
  return nil; //on subsequent allocation attempts return nil
}

- (void)showRef:(NSString*)refText
{
	[textView setString:@""];
	[textView insertAttributedText:refText];
	[window makeKeyAndOrderFront:nil];
}

@end
