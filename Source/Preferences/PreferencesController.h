//
//  PreferencesController.h
//  Simple Preferences
//
//  Created by John Devor on 12/24/06.
//

#import <Cocoa/Cocoa.h>


@interface PreferencesController : NSWindowController 
{
	IBOutlet NSView *generalPreferenceView;
	IBOutlet NSView *personalPreferenceView;
	IBOutlet NSView *updatePreferenceView;
	IBOutlet NSView *displayPreferenceView;
	IBOutlet NSView *networkPreferenceView;
	
	IBOutlet NSView *activeContentView;
}

+ (PreferencesController *)sharedPreferencesController;

- (void)toggleActivePreferenceView:(id)sender;
- (void)setActiveView:(NSView *)view animate:(BOOL)flag;

@end
