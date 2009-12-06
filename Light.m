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
@synthesize channels;
@synthesize startingAddress;
@synthesize changed;
@synthesize currentAction;

- (id) init
{
    return [self initWithDetails:@"UNNAMED_LIGHT" size:0 address:0];
}

- (id) initWithDetails: (NSString*)newName size:(NSNumber*)newSize address:(NSNumber*)newAddress
{
    self = [super init];
    self.name = newName;
    self.changed = YES;
    self.sizeOfBlock = newSize;
    self.startingAddress = newAddress;
    self.channels = [[NSMutableArray alloc] initWithCapacity:3];

    int j = [self.startingAddress intValue];
    for(int i = 0; i < [self.sizeOfBlock intValue]; i++, j++)
    {
        [channels addObject:[[Channel alloc] initWithDetails:@"channel" addr:j val:0]];
    }
    return self;
}

/* For debugging purposes */
- (void) displayState
{
    NSLog(@"%@", self.name);
    NSLog(@"--------------");
    for(Channel* c in channels)
    {
        [c display];
    }
    
}

- (NSInteger) sendState: (AMSerialPort*)port
{
    NSMutableString *sendString;
    NSInteger numChan = [startingAddress intValue];
    for(Channel* c in channels)
    {
        sendString = [NSMutableString stringWithFormat:@"1"];
        [sendString appendString:[self numberToTriple:[[NSNumber alloc] initWithInt:numChan]]];
        [sendString appendString:[self numberToTriple:[[NSNumber alloc] initWithInt:c.value]]];
        [sendString appendString:@"\r"];
        NSLog(@"%@", sendString);
        //port will be open
        if([port isOpen]) {
            [port writeString:sendString usingEncoding:NSUTF8StringEncoding error:NULL];
        }
        else 
        {
            return -1;
        }
        numChan++;
    }
    return 0;
}

- (NSString*) numberToTriple: (NSNumber*) num
{
    NSString* triple;
    if ([num intValue] < 10) {
        triple = [NSString stringWithFormat:@"00%d", [num intValue]];
    }
    else if ([num intValue] < 100) {
        triple = [NSString stringWithFormat:@"0%d", [num intValue]];
    }
    else {
        triple = [NSString stringWithFormat:@"%d", [num intValue]];
    }

    return triple;
}


- (void) applyAction
{
    int channelArrayAddress;
    int channelRealAddress;
    for(int i = 0; i < [self.currentAction.targetChannels count]; i++)
    {
        channelRealAddress = [[self.currentAction.targetChannels objectAtIndex:i] intValue];
        channelArrayAddress = channelRealAddress - ([self.startingAddress intValue]-1) - 1;
        ((Channel*)[self.channels objectAtIndex:channelArrayAddress]).value = [[self.currentAction.targetValues objectAtIndex:i] intValue];
    }
}

- (void) dealloc
{
    self.name = nil;
    self.sizeOfBlock = nil;
    self.channels = nil;
    self.startingAddress = nil;
    self.currentAction = nil;
    
    [super dealloc];
}

@end
