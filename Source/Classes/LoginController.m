//
//  LoginController.m
//  aorc
//
//  Created by Reza Jelveh
//  Copyright 2007
//  License: GPL
//

#import "LoginController.h"
#import "AOChatBinding.h"

@implementation LoginController


-(IBAction) login:(id)sender
{
	int server = RK1;
	// ChatController *chatController = [[[NSDocumentController sharedDocumentController] currentDocument] chatController];
	//FIXME: currently only does one document
	// ChatController *chatController = [[[[NSDocumentController sharedDocumentController] documents] objectAtIndex:0] chatController];
	
	if([[chatController aoChatBinding] isConnected]){
		[self showReconnectSheet];
		return;
	}
	if([[serverName titleOfSelectedItem] isEqual:@"Atlantean"])
		server = RK1;
	else if ([[serverName titleOfSelectedItem] isEqual:@"Rimor"])
		server = RK2;
	else if ([[serverName titleOfSelectedItem] isEqual:@"Die Neue Welt"])	
		server = RK3;
	else if ([[serverName titleOfSelectedItem] isEqual:@"SSH Tunnel"])
		server = RK_TUNNEL;
	
	
	if([[chatController aoChatBinding] initWithUser:[userField stringValue] andPassword:[passField stringValue] andServer:server])
		[self hide];	
}

- (void)awakeFromNib
{
	[window setCollectionBehavior:NSWindowCollectionBehaviorMoveToActiveSpace];
}

-(IBAction) hideWindow:(id)sender
{
	[self hide];
}

- (void)showReconnectSheet
{
  NSBeginAlertSheet(
      @"Already Connected",
                              // sheet message
      @"Ok",              // default button label
      nil,                    // no third button
      @"Cancel",              // other button label
      window,                 // window sheet is attached to
      self,                   // we’ll be our own delegate
			// nil,
      @selector(sheetClosed:returnCode:contextInfo:),
                              // did-end selector
      NULL,                   // no need for did-dismiss selector
      nil,                 // context info
      @"Do you want to reconnect anyway?",
                              // additional text
      nil);                   // no parameters in message
  
}

- (void)sheetClosed:(NSWindow *)sheet
         returnCode:(int)returnCode
        contextInfo:(void *)contextInfo
{
	// ChatController *chatController = [[[NSDocumentController sharedDocumentController] currentDocument] chatController];
	
	if (returnCode == NSAlertDefaultReturn) {
		[[chatController aoChatBinding] disconnect];
		[self login:nil];
	}
	else if (returnCode == NSAlertAlternateReturn) {
		[self hide];
	}
}

- (void)showAlert:(NSString*)message
{
  NSBeginAlertSheet(
      @"Connection Problem",
                              // sheet message
      @"Ok",              // default button label
      nil,                    // no third button
      nil,              // other button label
      window,                 // window sheet is attached to
      self,                   // we’ll be our own delegate
			nil,
      // @selector(sheetDidEndShouldDelete:returnCode:contextInfo:),
                              // did-end selector
      NULL,                   // no need for did-dismiss selector
      nil,                 // context info
      message,
                              // additional text
      nil);                   // no parameters in message


}


- (void)hide
{
	[window orderOut:nil];
}

- (void)show
{
	[window makeKeyAndOrderFront:nil];
}

- (id)window
{
	return window;
}


@end
