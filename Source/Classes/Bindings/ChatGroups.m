//
//  Mailbox.m
//  MailDemo
//
//  Created by Scott Stevenson on Wed Apr 21 2004.
//  Copyright (c) 2004 Tree House Ideas. All rights reserved.
//


#import "ChatGroups.h"


@implementation ChatGroups




- (id)init
{
  if (self = [super init]) {
    NSArray *keys = [NSArray arrayWithObjects:@"title", @"icon", @"index", nil];
    NSArray *values = [NSArray arrayWithObjects:@"New Mailbox", [NSImage imageNamed:@"Folder"], [NSNumber numberWithInt:0], nil];
    properties = [[NSMutableDictionary alloc] initWithObjects:values forKeys:keys];

    groups = [[NSMutableArray alloc] init];
  }
  return self;
}




- (void)dealloc
{
  [properties release];
  [groups release];
  [super dealloc];
}




- (NSMutableDictionary *)properties
{
  return properties;
}




- (void)setProperties:(NSDictionary *)newProperties
{
  if (properties != newProperties) {
    [properties autorelease];
    properties = [[NSMutableDictionary alloc] initWithDictionary:newProperties];
  }
}




- (NSString *)title
{
  return [properties valueForKey:@"title"];
}




- (void)setTitle:(NSString *)newTitle
{
  [properties setValue:newTitle
    forKey:@"title"];
}





- (NSMutableArray *)groups
{
  return groups;
}




- (void) setGroups:(NSArray *)newGroups
{
  if (groups != newGroups) {
    [groups autorelease];
    groups = [[NSMutableArray alloc] initWithArray:newGroups];
  }
}

- (NSNumber *)index
{
 return [properties valueForKey:@"index"];
}

- (void)setIndex:(NSNumber*)newIndex
{
  [properties setValue:newIndex
                forKey:@"index"];
}

@end
