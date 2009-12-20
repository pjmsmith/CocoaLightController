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

    return self;
}



- (NSInteger) sendState: (AMSerialPort*)port
{
    /*NSMutableString *sendString;
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
    }*/
    return 0;
}

- (void) applyAction
{
    /*int channelArrayAddress;
    int channelRealAddress;
    for(int i = 0; i < [self.currentAction.targetChannels count]; i++)
    {
        channelRealAddress = [[self.currentAction.targetChannels objectAtIndex:i] intValue];
        channelArrayAddress = channelRealAddress - ([self.startingAddress intValue]-1) - 1;
        ((Channel*)[self.channels objectAtIndex:channelArrayAddress]).value = [[self.currentAction.targetValues objectAtIndex:i] intValue];
    }*/
}

- (void) dealloc
{
    self.name = nil;
    self.sizeOfBlock = nil;
    self.startingAddress = nil;
    self.currentAction = nil;
    
    [super dealloc];
}

@end
