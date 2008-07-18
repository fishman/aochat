//
//  ChatWindow.h
//  aorc
//
//  Created by Reza Jelveh
//  Copyright 2007
//  License: GPL
//

#import <Cocoa/Cocoa.h>
#import "DBSourceView.h"

@interface ChatWindow : NSWindow
{
  IBOutlet NSView *sourceViewPlaceholder;
  IBOutlet DBSourceView *sourceView;
  
  NSTabView *tabView;
}
@end
