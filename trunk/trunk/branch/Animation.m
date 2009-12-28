//
//  Animation.m
//  LightController
//
//  Created by Patrick Smith on 11/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Animation.h"


@implementation Animation
@synthesize actions;
@synthesize isLooping;
@synthesize isRunning;
@synthesize lastActionIndex;
@synthesize timeBetweenSteps;

- (id) init
{
    return [self initWithDetails:@"" isLooping:NO time:0.2];
}

- (id) initWithDetails:(NSString*)newName isLooping:(BOOL)loop time:(double)newTime
{
    self = [super initWithDetails:(NSString *)newName numChans:0];
    self.actions = [[NSMutableArray alloc] initWithCapacity:10];
    self.isLooping = loop;
    self.isRunning = NO;
    self.timeBetweenSteps = [[NSNumber alloc] initWithDouble:newTime];
    return self;
}

@end
