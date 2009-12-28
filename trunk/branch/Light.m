//
//  Light.m
//  LightController
//
//  Created by Patrick Smith on 11/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Light.h"

@implementation Light
@synthesize name;
@synthesize sizeOfBlock;
@synthesize startingAddress;

- (id) init
{
    return [self initWithDetails:@"UNNAMED_LIGHT" size:0 address:0];
}

- (id) initWithDetails: (NSString*)newName size:(NSNumber*)newSize address:(NSNumber*)newAddress
{
    self = [super init];
    self.name = newName;
    self.sizeOfBlock = newSize;
    self.startingAddress = newAddress;

    return self;
}

- (void) dealloc
{
    self.name = nil;
    self.sizeOfBlock = nil;
    self.startingAddress = nil;    
    [super dealloc];
}

@end
