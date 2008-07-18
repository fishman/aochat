//
//  ChatController.h
//  aorc
//
//  Created by Reza Jelveh
//  Copyright 2007
//  License: GPL
//

#import <Growl/Growl.h>

#import <Cocoa/Cocoa.h>
#import "HTMLTextView.h"
#import "LIFOStack.h"
#import "PSMTabBarControl/PSMTabBarControl.h"
#import "AOChatBinding.h"

enum{
	kTellTypeNothing = 0,
	kTellTypeTellMsg,
	kTellTypeGroupMsg,
	kTellTypeChatCmd
};

#define kTabTell @"Tells"
#define kTabStatus @"Status"
#define kTabGroup @"Chat"

@interface ChatController : NSObject <GrowlApplicationBridgeDelegate>
{
	IBOutlet NSTextField *addFriendInput;
	IBOutlet NSWindow *addFriendSheet;
	IBOutlet HTMLTextView *chatView;
	IBOutlet NSDrawer *drawerView;
	IBOutlet NSTableView *friendTable;
	IBOutlet NSTextField *groupInput;
	IBOutlet NSTextField *tellInput;
	IBOutlet NSWindow *parentWindow;
	IBOutlet HTMLTextView *statusView;
	IBOutlet PSMTabBarControl *tabBar;
	IBOutlet NSTabView *tabView;
	IBOutlet NSTextField *groupTargetName;
	IBOutlet NSTextField *tellTargetName;
	IBOutlet HTMLTextView *tellView;
	IBOutlet id charSelectController;
	NSMutableDictionary * chatGroups;
	NSString * tellTarget;
	NSString * groupTarget;
	int tellMsgType;
	int groupMsgType;
	LIFOStack *inputStack;
	id aoChatBinding;
	IBOutlet id friendDataSource;
	IBOutlet id loginController;
	
	IBOutlet NSArrayController *chatgroupsArrayController;
	
		// Instance Variables
	NSMutableArray *_groups;
	
}
- (IBAction)addFriend:(id)sender;
- (IBAction)closeFriendSheetCancel:(id)sender;
- (IBAction)closeFriendSheetOk:(id)sender;
- (IBAction)delFriend:(id)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)toggleDrawer:(id)sender;
- (void)selectTab:(int)tabId;
- (void)selectNextTab;
- (void)addGroup:(NSString*)gName withGID:(id) gid;
- (void)selectPreviousTab;
- (void)addStatusText:(NSString*)aString;
- (void)addChatText:(NSString*)aString;
- (void)addTellText:(NSString*)tellText withName:(NSString*)theName andType:(BOOL)wasSent;
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;
- (void)reloadFriends;
- (void)setTellTarget;
- (void)hide;
- (void)show;
- (void)setGroupTarget:(NSString*)sTarget;
- (void)setTellTargetFromName:(NSString*)sTarget;
- (void)addTellStatusMessage:(NSString*)tellMessage;
@end
