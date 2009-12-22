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

- (id) init
{
    return [self initWithDetails:@"" size:1];
}

- (id) initWithDetails: (NSString*)newName size:(NSInteger)newSize
{
    self = [super init];
    self.name = newName;
    self.groupLights = [[NSMutableArray alloc] initWithCapacity:newSize];
    
    return self;
}

@end
