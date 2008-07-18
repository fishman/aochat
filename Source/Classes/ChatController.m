//
//  ChatController.m
//  aorc
//
//  Created by Reza Jelveh
//  Copyright 2007
//  License: GPL
//

#import <OgreKit/OgreKit.h>

#import "ChatController.h"
#import "ColorTabViewItem.h"
#import "ChatGroups.h"

@implementation ChatController
/**
 * Growl registration delegate
 */
- (NSDictionary *) registrationDictionaryForGrowl
{
	NSArray *growlNotifications = [NSArray arrayWithObjects:@"Tell message", nil];
	return [NSDictionary dictionaryWithObjectsAndKeys:growlNotifications, GROWL_NOTIFICATIONS_ALL, growlNotifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
}

- (void)dealloc
{
	[tellTarget release];
	[groupTarget release];
	[chatGroups release];
	[inputStack release];

	[aoChatBinding release];
	
	[super dealloc];
}
- (id)aoChatBinding
{
	return aoChatBinding;
}

- (id)loginController
{
	return loginController;
}

- (id)charSelectController
{
	return charSelectController;
}

- (void)selectTab:(int)tabId
{
  // [tabView selectTabViewItemAtIndex:tabId];
  [chatgroupsArrayController setSelectionIndex:tabId];
}

- (void)selectNextTab
{
  // [tabView selectNextTabViewItem:nil];
}

- (void)selectPreviousTab
{
  // [tabView selectPreviousTabViewItem:nil];
}

- (void)addStatusText:(NSString*)aString
{
	[statusView insertNormalText:aString];	

	if (![[[tabView selectedTabViewItem] identifier] isEqual:kTabStatus])
	{
		[(ColorTabViewItem*)[tabView tabViewItemAtIndex:[tabView indexOfTabViewItemWithIdentifier:kTabStatus]] markInactive];		
	}
	
	// [statusView scroll];
}

- (void)addChatText:(NSString*)chatText
{
	// [chatView insertText:@"\n"];
	
	if (![[[tabView selectedTabViewItem] identifier] isEqual:kTabGroup])
	{
		[(ColorTabViewItem*)[tabView tabViewItemAtIndex:[tabView indexOfTabViewItemWithIdentifier:kTabGroup]] markInactive];		
	} 
	
	[chatView insertAttributedText:chatText];
	
	// [chatView scroll];
}

- (void)addTellText:(NSString*)tellText withName:(NSString*)theName andType:(BOOL)wasSent
{
	// [tellView insertText:@"\n"];
	NSString *string, *tell;
	
	if(wasSent == YES)
		string = [NSString stringWithFormat:@"<font color=green face=\"Lucida Grande\">To [<a href=\"tell://%@\" style=\"text-decoration: none\">%@</a>]: %@</font>",
					theName, theName, tellText];
	else 
		string = [NSString stringWithFormat:@"<font color=green face=\"Lucida Grande\">[<a href=\"tell://%@\" style=\"text-decoration: none\">%@</a>]: %@</font>",
					theName, theName, tellText];

	tell = [tellView insertAttributedText:string];

	if (wasSent == NO)
	{
		if (![[[tabView selectedTabViewItem] identifier] isEqual:kTabTell] 
					|| ![NSApp isActive]
					|| ([[NSDocumentController sharedDocumentController] currentDocument] != [[parentWindow windowController] document])){
			
			//FIXME: this is inefficient!
			[GrowlApplicationBridge notifyWithTitle:theName
			                                description:[[[[NSAttributedString alloc] initWithHTML:[tellText dataUsingEncoding: NSUTF8StringEncoding]
                                                                       documentAttributes:nil] autorelease] string]
			                           notificationName:@"Tell message"
			                                   iconData:nil
			                                   priority:0
			                                   isSticky:FALSE
			                               clickContext:nil];
			
		}

		if (![[[tabView selectedTabViewItem] identifier] isEqual:kTabTell]){
			[(ColorTabViewItem*)[tabView tabViewItemAtIndex:[tabView indexOfTabViewItemWithIdentifier:kTabTell]] markInactive];
		}
	}
	
	
	// [tellView scroll];
}

- (void)addTellStatusMessage:(NSString*)tellMessage
{
	// [tellView insertText:@"\n"];
	NSString *string;
	
	string = [NSString stringWithFormat:@"<font color=red face=\"Lucida Grande\">%@</font>", tellMessage];

	if (![[[tabView selectedTabViewItem] identifier] isEqual:kTabTell] 
				|| ![NSApp isActive]){
		[GrowlApplicationBridge notifyWithTitle:@"Offline"
                                description:tellMessage
                           notificationName:@"Tell message"
                                   iconData:nil
                                   priority:0
                                   isSticky:FALSE
                               clickContext:nil];

	}

	if (![[[tabView selectedTabViewItem] identifier] isEqual:kTabTell]){
		[(ColorTabViewItem*)[tabView tabViewItemAtIndex:[tabView indexOfTabViewItemWithIdentifier:kTabTell]] markInactive];
	}
	
	[tellView insertAttributedText:string];
	
	// [tellView scroll];
}



- (void)toggleDrawer:(id)sender
{
	NSDrawerState state = [drawerView state];
	if (NSDrawerOpeningState == state || NSDrawerOpenState == state) {
		[drawerView close];
	} 
	else {
		[drawerView openOnEdge:NSMaxXEdge];
		[[friendTable enclosingScrollView] setNextKeyView:groupInput];
	}
}

- (id)init
{
  if (self = [super init]) {
    // Create Left split view bindings
    _groups = [[NSMutableArray alloc] init];
    
    ChatGroups *chatgroup1 = [[[ChatGroups alloc] init] autorelease];
    [chatgroup1 setTitle:@"Status"];
    [chatgroup1 setIndex:[NSNumber numberWithInt:0]];
    ChatGroups *chatgroup2 = [[[ChatGroups alloc] init] autorelease];
    [chatgroup2 setTitle:@"Chat"];
    [chatgroup2 setIndex:[NSNumber numberWithInt:1]];
    ChatGroups *chatgroup3 = [[[ChatGroups alloc] init] autorelease];
    [chatgroup3 setTitle:@"Tells"];
    [chatgroup3 setIndex:[NSNumber numberWithInt:2]];
    
    NSArray *sampleData = [NSArray arrayWithObjects:chatgroup1,
                           chatgroup2,
                           chatgroup3,
                           nil];
    [self setGroups:sampleData];
  }
  return self;
}

- (id)friendDataSource
{
	return friendDataSource;
}

- (void)awakeFromNib {
	//  [drawerView setMinContentSize:NSMakeSize(100, 100)];
	[drawerView setMaxContentSize:NSMakeSize(165, 0)];
	[drawerView setContentSize:NSMakeSize(165,0)];

	[tabView setDelegate:self];
	[groupInput setDelegate:self];
	[tellInput setDelegate:self];

	[friendTable setTarget:self];
	[friendTable setDoubleAction:@selector(setTellTarget)];

	if([GrowlApplicationBridge isGrowlInstalled]) {
		[GrowlApplicationBridge setGrowlDelegate:self];
	}
	
	// [column setDataCell:[[[NSImageCell alloc] init] autorelease]];
	// [column setDataCell: [[[ImageTextCell alloc] init] autorelease]];

	chatGroups = [[[NSMutableDictionary alloc] init] autorelease];
	[chatGroups retain];

	tellMsgType = kTellTypeNothing;
	groupMsgType = kTellTypeNothing;
	tellTarget = nil;
	groupTarget = nil;


	// Init the attributed strings
	// [chatView initStringAttributes];
	// [tellView initStringAttributes];

	// Init input stack
	inputStack = [[LIFOStack alloc] init];
	[inputStack retain];

	// PSMTabBarControl
	// [tabBar setDisableTabClose:YES];
	// [tabBar setAutomaticallyAnimates:YES];

	[groupInput setNextKeyView:groupInput];
	[tellInput setNextKeyView:tellInput];

	// Set Up initial first responders
	[parentWindow setInitialFirstResponder:tabView];
  [[tabView tabViewItemAtIndex:[tabView indexOfTabViewItemWithIdentifier:kTabTell]] setInitialFirstResponder:tellInput];
  [[tabView tabViewItemAtIndex:[tabView indexOfTabViewItemWithIdentifier:kTabGroup]] setInitialFirstResponder:groupInput];

	// [self addChatText:@"<a href=\"itemref://34554/455\">test </a>"];
	// [self addStatusText:@"test"];
	// [self addTellText:@"testä" withName:@"me" andType:NO];
	aoChatBinding = [[AOChatBinding alloc] initWithController:self];
	[aoChatBinding retain];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	[(ColorTabViewItem*)tabViewItem markActive];
}

- (BOOL)tabIsActive:(NSString*)tabName
{
	return [[[tabView selectedTabViewItem] identifier] isEqual:tabName];
}

- (void)addGroup:(NSString*)gName withGID:(id) gid
{
	[chatGroups setObject:gName forKey:gid];
}


- (void)reloadFriends
{
	[friendTable reloadData];
}

- (void)hide
{
	[parentWindow orderOut:nil]; // to hide it
}

- (void)show
{
	[drawerView openOnEdge:NSMaxXEdge];
	[[friendTable enclosingScrollView] setNextKeyView:groupInput];
	
	[parentWindow makeKeyAndOrderFront:nil];
}

- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
	BOOL result = NO;
	NSString * controlString;
	id *inputField, *target;
	int *msgType;
	
	if([[[tabView selectedTabViewItem] identifier] isEqual:kTabGroup])
	{	
		inputField = &groupInput;
		target = &groupTarget;
		msgType = &groupMsgType;
	}	
	else if([[[tabView selectedTabViewItem] identifier] isEqual:kTabTell])
	{
		inputField = &tellInput;
		target = &tellTarget;
		msgType = &tellMsgType;
	}
	
	
	if (commandSelector == @selector(insertNewline:))
	{
		NSEvent *theEvent = [NSApp currentEvent];
		if ([theEvent type] == NSKeyDown && ([theEvent modifierFlags] & NSShiftKeyMask))
		{
			[textView insertNewlineIgnoringFieldEditor:control];
			return true;
		}
		
		controlString = [*inputField stringValue];
		if (*target == nil) 
			return NO;
		if ([controlString length] == 0)
			return NO;
		
		switch(*msgType)
		{
			case kTellTypeTellMsg:
			[aoChatBinding sendTell:controlString toChar:*target];
			break;
			
			case kTellTypeGroupMsg:
			[aoChatBinding sendGroup:controlString toChar:*target];
			break;
			
			case kTellTypeChatCmd:
			[aoChatBinding sendCommand:*target withString:controlString];
			break;
			
		}
		[inputStack push:controlString];

		[*inputField setStringValue:@""];

		result = YES;
	}
	else if (commandSelector == @selector(moveUp:))
	{
		controlString = [inputStack pop];
		if (controlString != nil)
			[*inputField setStringValue:controlString];
	}
	else if (commandSelector == @selector(insertTab:))
	{
		OGRegularExpression    *regex = [OGRegularExpression regularExpressionWithString:@"^/(\\w+)\\s+(\"?)((?<=\").+(?=\")|\\w+)"];
		NSEnumerator    *enumerator = [regex matchEnumeratorInString:[groupInput stringValue]];
		OGRegularExpressionMatch    *match;	// マッチ結果
		NSString *reg1;
		while ((match = [enumerator nextObject]) != nil) {	// 順番にマッチ結果を得る
			reg1 = [[regex replaceAllMatchesInString:[groupInput stringValue] withString:@"\\3"] lowercaseString];
			
			NSArray * keyEnum = [chatGroups allKeys];
			NSData * key;
		  enumerator = [keyEnum objectEnumerator];
	
			while (key = [enumerator nextObject])
			{
				if ([[[chatGroups objectForKey:key] lowercaseString] hasPrefix:reg1]){
					[groupTarget release];
					groupMsgType = kTellTypeGroupMsg;
					groupTarget = [chatGroups objectForKey:key];
					[groupTargetName setStringValue:[NSString stringWithFormat:@"%@:", groupTarget]];
					[groupInput setStringValue:@""];
					[groupTarget retain];
					return YES;
				}
			}
		}
		
		result = YES;
	}
	return result;
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSTextField **inputField, **targetName;
	NSString **target;
	int *msgType;
	
	if([[[tabView selectedTabViewItem] identifier] isEqual:kTabGroup])
	{	
		inputField = &groupInput;
		target = &groupTarget;
		targetName = &groupTargetName;
		msgType = &groupMsgType;
	}	
	else if([[[tabView selectedTabViewItem] identifier] isEqual:kTabTell])
	{
		inputField = &tellInput;
		target = &tellTarget;
		targetName = &tellTargetName;
		msgType = &tellMsgType;
	}
	
	
	if([[*inputField stringValue] hasPrefix:@"/"])
	{
		// ^/(\w+)\s+"?((?<=")\w+\s+\w+(?=")|\w+)"?\s+(.*)$ <-- full input parsing regexp
		// Ruby syntax default
		// OGRegularExpression    *regex = [OGRegularExpression regularExpressionWithString:@"^/tell\\s*\\a\\s"];

		OGRegularExpression    *regex = [OGRegularExpression regularExpressionWithString:
																														@"^/(\\w+)\\s+(\"?)((?<=\").+(?=\")|\\w+)\\2\\s+(.*)$"];
		NSEnumerator    *enumerator = [regex matchEnumeratorInString:[*inputField stringValue]];
		OGRegularExpressionMatch    *match;	// マッチ結果
		NSString * reg1, *reg2, *reg3;
		NSString * inputString = [*inputField stringValue];
		NSArray * keyEnum = [chatGroups allKeys];
		NSData * key;
	
		
		while ((match = [enumerator nextObject]) != nil) {	// 順番にマッチ結果を得る	
			reg1 = [[regex replaceAllMatchesInString:inputString withString:@"\\1"] lowercaseString];
			reg2 = [[regex replaceAllMatchesInString:inputString withString:@"\\3"] lowercaseString];
			reg3 = [regex replaceAllMatchesInString:inputString withString:@"\\4"];			
			
			if([reg1 isEqual:@"g"])
			{
			  enumerator = [keyEnum objectEnumerator];

				*msgType = kTellTypeNothing;
				
				while (key = [enumerator nextObject]){
					if ([[[chatGroups objectForKey:key] lowercaseString] hasPrefix:reg2]){
						[*target release];
						
						*target = [chatGroups objectForKey:key];
						[*targetName setStringValue:[NSString stringWithFormat:@"%@:", *target]];
						[*inputField setStringValue:reg3];
						*msgType = kTellTypeGroupMsg;
						
						[*target retain];
						return;
					}
				}
			}
			else if ([reg1 isEqual:@"tell"])
			{
				[*target release];
				
				*target = reg2;
				[*targetName setStringValue:[NSString stringWithFormat:@"%@:", [reg2 capitalizedString]]];
				[*inputField setStringValue:reg3];
				*msgType = kTellTypeTellMsg;
				
				[*target retain];
			}
			else if ([reg1 isEqual:@"cc"])
			{
				if ([reg2 isEqual:@"addbuddy"])
				{
					[*target release];
					
					*target = reg2;
					[*targetName setStringValue:[NSString stringWithFormat:@"CC %@", [reg2 uppercaseString]]];
					[*inputField setStringValue:reg3];
					*msgType = kTellTypeChatCmd;
					
					[*target retain];
				}
				else if ([reg2 isEqual:@"rembuddy"])
				{
					[*target release];
					
					*target = reg2;
					[*targetName setStringValue:[NSString stringWithFormat:@"CC %@", [reg2 uppercaseString]]];
					[*inputField setStringValue:reg3];
					*msgType = kTellTypeChatCmd;
					
					[*target retain];
				}
				else
				{
					*msgType = kTellTypeTellMsg;
					return;
				}
			}
			
			return;
		}
	}
}

- (void)setTellTarget
{
	NSTableColumn *column;
	NSString *name;

	column = [friendTable tableColumnWithIdentifier:@"User Name"];
	name = [[friendTable dataSource] tableView:friendTable
                   objectValueForTableColumn:column
                                         row:[friendTable selectedRow]];
	
	// name = [[column dataCellForRow:row] stringValue];
	// NSIndexSet * currentSet = [friendTable selectedRowIndexes];
	// NSLog(@"Current Set: %d\n",[currentSet firstIndex]);
	// NSCell * currentCell = [[[friendTable tableColumns] objectAtIndex:1] dataCellForRow:[currentSet firstIndex]];
	// NSLog(@"Current Cell: %@\n", [currentCell stringValue]);
	// NSLog(@"You have clicked row number: %d", row);	
	
	[tellTarget release];
	[tellTargetName setStringValue:[NSString stringWithFormat:@"%@:", name]];
	tellTarget = [name lowercaseString];
	[tellTarget retain];
	tellMsgType = kTellTypeTellMsg;
	
	// focus groupInput
	[self selectTab:[tabView indexOfTabViewItemWithIdentifier:kTabTell]];
	[parentWindow makeFirstResponder:tellInput];
}

- (void)setGroupTarget:(NSString*)sTarget
{
	[groupTarget release];
	groupTarget = [NSString stringWithString:sTarget];
	[groupTargetName setStringValue:[NSString stringWithFormat:@"%@:", groupTarget]];
	[groupTarget retain];
	groupMsgType = kTellTypeGroupMsg;
	
	// focus groupInput
	[parentWindow makeFirstResponder:groupInput];
}

- (void)setTellTargetFromName:(NSString*)sTarget
{
	[tellTarget release];
	tellTarget = [NSString stringWithString:sTarget];
	[tellTargetName setStringValue:[NSString stringWithFormat:@"%@:", tellTarget]];
	[tellTarget retain];
	tellMsgType = kTellTypeTellMsg;
	
	// focus groupInput
	[parentWindow makeFirstResponder:tellInput];
}

- (void)disconnect:(id)sender
{
	[aoChatBinding disconnect];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	// Check if we're the delete sheet delegate
	// FIXME: this is a hack only works because the addfriendsheet does not have context info
	if(contextInfo!=nil){
		if (returnCode == NSAlertDefaultReturn)
			[aoChatBinding sendCommand:@"rembuddy" withString:[(NSString*)contextInfo lowercaseString]];
	}
	// Add Friend Sheet
	else{	
		if (returnCode == NSAlertDefaultReturn) {
			NSString * friendName;
					
			friendName = [addFriendInput stringValue];
			if(friendName){
				[aoChatBinding sendCommand:@"addbuddy" withString:[friendName lowercaseString]];
				[addFriendInput setStringValue:@""];
			}
		}
		
		[sheet orderOut:self];
	}
}

- (void)showAddFriendSheet
{
	// if (!addFriendSheet)
	//     [NSBundle loadNibNamed: @"AddFriendSheet" owner: self];

	[NSApp beginSheet: addFriendSheet
     modalForWindow: parentWindow
      modalDelegate: self
     didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
        contextInfo: nil];
}

- (void)showDeleteConfirmation
{
	NSTableColumn *column;
	NSString *name, *message;
	
	column = [friendTable tableColumnWithIdentifier:@"User Name"];
	name = [[friendTable dataSource] tableView:friendTable
                   objectValueForTableColumn:column
                                         row:[friendTable selectedRow]];
	// name = [[column dataCellForRow:[friendTable selectedRow]] stringValue];
	
	message = [NSString stringWithFormat:@"Are you sure that you want to remove %@ from your Friendlist?", name];
	
	NSBeginAlertSheet(
      @"Delete Friend",				// sheet message
      @"Ok",                  // default button label
      nil,                    // no third button
      @"Cancel",              // other button label
      parentWindow,           // window sheet is attached to
      self,                   // we’ll be our own delegate
			// nil,
      @selector(didEndSheet:returnCode:contextInfo:),
                              // did-end selector
      NULL,                   // no need for did-dismiss selector
      name,                		// context info
      message,								// additional text
      nil);                   // no parameters in message
}

- (IBAction)addFriend:(id)sender
{
	[self showAddFriendSheet];
}

- (IBAction)delFriend:(id)sender
{
	[self showDeleteConfirmation];
}

- (void)closeFriendSheetOk: (id)sender
{
	[NSApp endSheet:addFriendSheet returnCode: NSAlertDefaultReturn];
}

- (void)closeFriendSheetCancel: (id)sender
{
	[NSApp endSheet:addFriendSheet];
}

- (void) setGroups:(NSArray *)newGroups
{
    if (_groups != newGroups) {
        [_groups autorelease];
        _groups = [[NSMutableArray alloc] initWithArray: newGroups];
    }
}

- (NSMutableArray *) groups
{
    return _groups;
}

- (BOOL)isConnected
{
  BOOL isConnected = NO;
  
  if(aoChatBinding)
    isConnected = [aoChatBinding isConnected];
}

- (NSString *)connectedServer
{
  int server = [aoChatBinding connectedServer];
  switch(server)
  {
    case RK1:
      return @"RK1";
    case RK2:
      return @"RK2";
    case RK3:
      return @"RK3";
    default:
      return @"Other";
  }
}
@end
