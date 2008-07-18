//
//  Mailbox.h
//  MailDemo
//
//  Created by Scott Stevenson on Wed Apr 21 2004.
//  Copyright (c) 2004 Tree House Ideas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ChatGroups : NSObject {
	
    NSMutableDictionary *properties;
    NSMutableArray *groups;
}

- (NSMutableDictionary *)properties;
- (void)setProperties:(NSDictionary *)newProperties;

- (NSString *)title;
- (void)setTitle:(NSString *)newTitle;

- (NSMutableArray *)groups;
- (void)setGroups:(NSArray *) newEmails;

- (NSNumber *)index;
- (void)setIndex:(NSNumber*)newIndex;

@end
