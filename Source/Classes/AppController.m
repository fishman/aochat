//
//  AppController.m
//  aorc
//
//  Created by Reza Jelveh
//  Copyright 2007
//  License: GPL
//

#import "AppController.h"
#import "ChatController.h"
#import "LoginController.h"
#import "AOChatBinding.h"
#import "ChatRefDisplay.h"
#import "PreferencesController.h"

@implementation AppController

- (id)init
{
	[super init];
	NSNotificationCenter *center = 
    [[NSWorkspace sharedWorkspace] notificationCenter];
 
	[center addObserver:self
             selector:@selector(machineWillSleep:)
                 name:NSWorkspaceWillSleepNotification
               object:NULL];
  
  [[NSApplication sharedApplication] setDelegate:self];

	[self registerURLHandler];
	return self;
}

- (void)dealloc
{
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (void)disconnect:(id)sender
{
	ChatController *controller = [[[NSDocumentController sharedDocumentController] currentDocument] chatController];
	
	[controller disconnect:nil];
}

- (IBAction)openPreferences:(id)sender
{
	[[PreferencesController sharedPreferencesController] showWindow:nil];
}

- (IBAction)nextTab:(id)sender
{
	ChatController *controller = [[[NSDocumentController sharedDocumentController] currentDocument] chatController];
	
	[controller selectNextTab];	
}

- (IBAction)previousTab:(id)sender
{
	ChatController *controller = [[[NSDocumentController sharedDocumentController] currentDocument] chatController];
	
	[controller selectPreviousTab];	
}

- (IBAction)showChat:(id)sender
{
	ChatController *controller = [[[NSDocumentController sharedDocumentController] currentDocument] chatController];
	
	[controller selectTab:1];
}

- (IBAction)showLogin:(id)sender
{
	ChatController *controller = [[[NSDocumentController sharedDocumentController] currentDocument] chatController];
	
	[[controller loginController] show];
}

- (IBAction)showStatus:(id)sender
{
	ChatController *controller = [[[NSDocumentController sharedDocumentController] currentDocument] chatController];
	
	[controller selectTab:0];
}

- (IBAction)showTell:(id)sender
{
	ChatController *controller = [[[NSDocumentController sharedDocumentController] currentDocument] chatController];
	
	[controller selectTab:2];	
}

- (IBAction)toggleDrawer:(id)sender
{
	ChatController *controller = [[[NSDocumentController sharedDocumentController] currentDocument] chatController];
	
	[controller toggleDrawer:nil];	
}

- (IBAction)addFriend:(id)sender
{
	ChatController *controller = [[[NSDocumentController sharedDocumentController] currentDocument] chatController];
	
	if ([[controller aoChatBinding] isConnected])
		[controller addFriend:nil];
}

- (void) machineWillSleep:(NSNotification *)notification 
{
	// disconnect all chats on sleep
	NSArray *documents = [[NSDocumentController sharedDocumentController] documents];
	int i;
	
	for(i = 0; i < [documents count]; i++)
	{
		ChatController * chatController = [[documents objectAtIndex:i] chatController];
		if(chatController)
			[chatController disconnect:nil];
	}
}

- (void)registerURLHandler
{
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                     andSelector:@selector(getUrl:withReplyEvent:)
                                                   forEventClass:kInternetEventClass
                                                      andEventID:kAEGetURL];
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	NSMutableString *url = [[[[event paramDescriptorForKeyword:keyDirectObject] stringValue] mutableCopy] autorelease];
	// now you can create an NSURL and grab the necessary parts
	[url replaceOccurrencesOfString:@"%20" withString:@" " options:0 range: NSMakeRange(0,[url length])];
	
	if([url hasPrefix:@"chatgroup"]){
		[url replaceOccurrencesOfString:@"chatgroup://" withString:@"" options:0 range: NSMakeRange(0,[url length])];
		[[[[NSDocumentController sharedDocumentController] currentDocument] chatController] setGroupTarget:url];
	}
	else if([url hasPrefix:@"tell"]){
		[url replaceOccurrencesOfString:@"tell://" withString:@"" options:0 range: NSMakeRange(0, [url length])];
		[[[[NSDocumentController sharedDocumentController] currentDocument] chatController] setTellTargetFromName:url];
	}
	else if([url hasPrefix:@"charref"] || [url hasPrefix:@"text"]){
		[url replaceOccurrencesOfString:@"charref://" withString:@"" options:0 range: NSMakeRange(0,[url length])];
		[url replaceOccurrencesOfString:@"text://" withString:@"" options:0 range: NSMakeRange(0,[url length])];
		[url replaceOccurrencesOfString:@"%3E" withString:@">" options:0 range: NSMakeRange(0,[url length])];
		[url replaceOccurrencesOfString:@"%3C" withString:@"<" options:0 range: NSMakeRange(0,[url length])];
		[url replaceOccurrencesOfString:@"%22" withString:@"\"" options:0 range: NSMakeRange(0,[url length])];
		[url replaceOccurrencesOfString:@"%23" withString:@"#" options:0 range: NSMakeRange(0,[url length])];
		[url replaceOccurrencesOfString:@"%25" withString:@"%" options:0 range: NSMakeRange(0,[url length])];
		[url replaceOccurrencesOfString:@"%BB" withString:@"&raquo;" options:0 range: NSMakeRange(0, [url length])];
		[url replaceOccurrencesOfString:@"%AB" withString:@"&laquo;" options:0 range: NSMakeRange(0, [url length])];
		[url replaceOccurrencesOfString:@"%AF" withString:@"&macr;" options:0 range: NSMakeRange(0, [url length])];
		[url replaceOccurrencesOfString:@"%C2" withString:@"&macr;" options:0 range: NSMakeRange(0, [url length])];
		[url replaceOccurrencesOfString:@"%5B" withString:@"[" options:0 range: NSMakeRange(0, [url length])];
		[url replaceOccurrencesOfString:@"%5C" withString:@"\\" options:0 range: NSMakeRange(0, [url length])];
		[url replaceOccurrencesOfString:@"%5D" withString:@"]" options:0 range: NSMakeRange(0, [url length])];
		[url replaceOccurrencesOfString:@"%C3%BC" withString:@"&uuml;" options:0 range: NSMakeRange(0, [url length])];
		[url replaceOccurrencesOfString:@"%C3%9C" withString:@"&Uuml;" options:0 range: NSMakeRange(0, [url length])];
		[url replaceOccurrencesOfString:@"%C3%B6" withString:@"&ouml;" options:0 range: NSMakeRange(0, [url length])];
		[url replaceOccurrencesOfString:@"%C3%96" withString:@"&Ouml;" options:0 range: NSMakeRange(0, [url length])];
		[url replaceOccurrencesOfString:@"%C3%84" withString:@"&auml;" options:0 range: NSMakeRange(0, [url length])];
		[url replaceOccurrencesOfString:@"%C3%A4" withString:@"&Auml;" options:0 range: NSMakeRange(0, [url length])];
		[[ChatRefDisplay sharedManager] showRef:url];
	}
}
@end
