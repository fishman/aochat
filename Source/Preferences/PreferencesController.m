//
//  PreferencesController.m
//  Simple Preferences
//
//  Created by John Devor on 12/24/06.
//

#import "PreferencesController.h"

#define WINDOW_TITLE_HEIGHT 78

static NSString *GeneralToolbarItemIdentifier  = @"General";
static NSString *PersonalToolbarItemIdentifier = @"Personal";
static NSString *UpdateToolbarItemIdentifier   = @"Update";
static NSString *DisplayToolbarItemIdentifier  = @"Displays";
static NSString *NetworkToolbarItemIdentifier  = @"Network";

static PreferencesController *sharedPreferencesController = nil;

@implementation PreferencesController

+ (PreferencesController *)sharedPreferencesController
{
	if (!sharedPreferencesController) {
		sharedPreferencesController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
	}
	return sharedPreferencesController;
}

- (void)awakeFromNib
{
	id toolbar = [[[NSToolbar alloc] initWithIdentifier:@"preferences toolbar"] autorelease];
	[toolbar setAllowsUserCustomization:NO];
	[toolbar setAutosavesConfiguration:NO];
	[toolbar setSizeMode:NSToolbarSizeModeDefault];
	[toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
	[toolbar setDelegate:self];
	[toolbar setSelectedItemIdentifier:GeneralToolbarItemIdentifier];
	[[self window] setToolbar:toolbar];

	[self setActiveView:generalPreferenceView animate:NO];
	[[self window] setTitle:GeneralToolbarItemIdentifier];
}

- (IBAction)showWindow:(id)sender 
{
	if (![[self window] isVisible])
		[[self window] center];
	[super showWindow:sender];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects:
		GeneralToolbarItemIdentifier,
		PersonalToolbarItemIdentifier,
		UpdateToolbarItemIdentifier,
		DisplayToolbarItemIdentifier,
		NetworkToolbarItemIdentifier,
		nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar 
{
	return [NSArray arrayWithObjects:
		GeneralToolbarItemIdentifier,
		PersonalToolbarItemIdentifier,
		UpdateToolbarItemIdentifier,
		DisplayToolbarItemIdentifier,
		NetworkToolbarItemIdentifier,
		nil];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
		GeneralToolbarItemIdentifier,
		PersonalToolbarItemIdentifier,
		UpdateToolbarItemIdentifier,
		DisplayToolbarItemIdentifier,
		NetworkToolbarItemIdentifier,
		nil];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)identifier willBeInsertedIntoToolbar:(BOOL)willBeInserted 
{
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
	if ([identifier isEqualToString:GeneralToolbarItemIdentifier]) {
		[item setLabel:GeneralToolbarItemIdentifier];
		[item setImage:[NSImage imageNamed:@"general"]];
		[item setTarget:self];
		[item setAction:@selector(toggleActivePreferenceView:)];
	} else if ([identifier isEqualToString:PersonalToolbarItemIdentifier]) {
		[item setLabel:PersonalToolbarItemIdentifier];
		[item setImage:[NSImage imageNamed:@"person"]];
		[item setTarget:self];
		[item setAction:@selector(toggleActivePreferenceView:)];
	} else if ([identifier isEqualToString:UpdateToolbarItemIdentifier]) {
		[item setLabel:UpdateToolbarItemIdentifier];
		[item setImage:[NSImage imageNamed:@"update"]];
		[item setTarget:self];
		[item setAction:@selector(toggleActivePreferenceView:)];
	} else if ([identifier isEqualToString:DisplayToolbarItemIdentifier]) {
		[item setLabel:DisplayToolbarItemIdentifier];
		[item setImage:[NSImage imageNamed:@"display"]];
		[item setTarget:self];
		[item setAction:@selector(toggleActivePreferenceView:)];
	} else if ([identifier isEqualToString:NetworkToolbarItemIdentifier]) {
		[item setLabel:NetworkToolbarItemIdentifier];
		[item setImage:[NSImage imageNamed:@"network"]];
		[item setTarget:self];
		[item setAction:@selector(toggleActivePreferenceView:)];
	} else
		item = nil;
	return item; 
}

- (void)toggleActivePreferenceView:(id)sender
{
	NSView *view;

	if ([[sender itemIdentifier] isEqualToString:GeneralToolbarItemIdentifier])
		view = generalPreferenceView;
	else if ([[sender itemIdentifier] isEqualToString:PersonalToolbarItemIdentifier])
		view = personalPreferenceView;
	else if ([[sender itemIdentifier] isEqualToString:UpdateToolbarItemIdentifier])
		view = updatePreferenceView;
	else if ([[sender itemIdentifier] isEqualToString:DisplayToolbarItemIdentifier])
		view = displayPreferenceView;
	else if ([[sender itemIdentifier] isEqualToString:NetworkToolbarItemIdentifier])
		view = networkPreferenceView;

	[self setActiveView:view animate:YES];
	[[self window] setTitle:[sender itemIdentifier]];
}

- (void)setActiveView:(NSView *)view animate:(BOOL)flag
{
	// set the new frame and animate the change
	NSRect windowFrame = [[self window] frame];
	windowFrame.size.height = [view frame].size.height + WINDOW_TITLE_HEIGHT;
	windowFrame.size.width = [view frame].size.width;
	windowFrame.origin.y = NSMaxY([[self window] frame]) - ([view frame].size.height + WINDOW_TITLE_HEIGHT);

	if ([[activeContentView subviews] count] != 0)
		[[[activeContentView subviews] objectAtIndex:0] removeFromSuperview];
	[[self window] setFrame:windowFrame display:YES animate:flag];

	[activeContentView setFrame:[view frame]];
	[activeContentView addSubview:view];
}

@end
