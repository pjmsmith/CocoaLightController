//
//  Channel.m
//  LightController
//
//  Created by Patrick Smith on 11/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Channel.h"


@implementation Channel
@synthesize label;
@synthesize address;
@synthesize value;

- (id) init
{
    return [self initWithDetails:@"" addr:0 val:-1];
}

- (id) initWithDetails:(NSString*)newLabel addr:(NSInteger)newAddress val:(NSInteger)newValue
{
    self = [super init];
    self.label = newLabel;
    self.address = newAddress;
    self.value = newValue;
    return self;
}

- (void) display
{
    NSLog(@"%i\t%@ - %i", address, label, value);
}

- (void) dealloc
{
    self.label = nil;
    [super dealloc];
}
@end
