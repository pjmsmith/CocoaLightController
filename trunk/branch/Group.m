//
//  Group.m
//  LightController
//
//  Created by Patrick Smith on 12/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Group.h"


@implementation Group
@synthesize name;
@synthesize groupLights;
@synthesize brightness;

- (id) init
{
    return [self initWithDetails:@"" size:1 brightness:255];
}

- (id) initWithDetails: (NSString*)newName size:(NSInteger)newSize brightness:(NSInteger)b
{
    self = [super init];
    self.name = newName;
    self.groupLights = [[NSMutableArray alloc] initWithCapacity:newSize];
    self.brightness = b;
    return self;
}

@end
