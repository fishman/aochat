//
//  ChatWindow.m
//  aorc
//
//  Created by Reza Jelveh
//  Copyright 2007
//  License: GPL
//

#import "ChatWindow.h"
#import "ChatController.h"

@implementation ChatWindow
- (void)sendEvent:(NSEvent *)theEvent
{
	NSTextField * inputTextField;
 	if(!tabView) 
    tabView = (NSTabView*)[self initialFirstResponder];
	
	
	inputTextField = [[tabView selectedTabViewItem] initialFirstResponder];
		

	if ([theEvent type] != NSKeyDown) {
		[super sendEvent:theEvent];
		return;
	}
	
	if([[self firstResponder] isKindOfClass:[NSTableView class]]){
		// See if the return key was pressed inside the tableView
		if ([[theEvent characters] isEqual:@"\r"]){
			[[[[self windowController] document] chatController] setTellTarget];
			return;
		}
		// If tab key pressed set input to the current textInput
		else if([[theEvent characters] isEqual:@"\t"]){
			[super sendEvent:theEvent];
			return;
		}
	}
	if ([theEvent modifierFlags] & NSNumericPadKeyMask) {
		[super sendEvent:theEvent];
		return;
  }
	else if (![theEvent modifierFlags]){
		// no modifier set
		if(![[self firstResponder] respondsToSelector:@selector(isDescendantOf:)] || ![[self firstResponder] isDescendantOf:inputTextField])
			[self makeFirstResponder:inputTextField];
	}
	[super sendEvent:theEvent];
}

- (void)performClose:(id)sender
{
	// don't allow the chat window to be closed ...
	[self showCloseSheet];
}

- (void)showCloseSheet
{
  NSBeginAlertSheet(
      @"Close Window",
                              // sheet message
      @"Ok",              // default button label
      nil,                    // no third button
      @"Cancel",              // other button label
      self,                 // window sheet is attached to
      self,                   // we’ll be our own delegate
			// nil,
      @selector(sheetClosed:returnCode:contextInfo:),
                              // did-end selector
      nil,                   // no need for did-dismiss selector
      nil,                 // context info
      @"Are you sure that you want to close the window?",
                              // additional text
      nil);                   // no parameters in message
  
}

- (void)sheetClosed:(NSWindow *)sheet
         returnCode:(int)returnCode
        contextInfo:(void *)sender
{	
	if (returnCode == NSAlertDefaultReturn) {
		// [super performClose:sender];
		[super close];
	}
	else if (returnCode == NSAlertAlternateReturn) {
	}
}

- (void)awakeFromNib
{
		// Place the source list view in the left panel.
	[sourceView setFrameSize:[sourceViewPlaceholder frame].size];
	[sourceViewPlaceholder addSubview:sourceView];

}
@end
