//
//  Action.m
//  LightController
//
//  Created by Patrick Smith on 11/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Action.h"


@implementation Action
@synthesize name;
@synthesize targetChannels;
@synthesize targetValues;

- (id) init
{
    return [self initWithDetails:@"" numChans:0];
}

- (id) initWithDetails:(NSString*)newName numChans:(NSInteger)chans
{
    self = [super init];
    self.name = [NSMutableString stringWithString:newName];
    self.targetChannels = [[NSMutableArray alloc]initWithCapacity:chans];
    self.targetValues = [[NSMutableArray alloc]initWithCapacity:chans];
    return self;
}


@end
