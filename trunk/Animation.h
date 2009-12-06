//
//  Animation.h
//  LightController
//
//  Created by Patrick Smith on 11/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Action.h"

@interface Animation : Action {
    NSMutableArray* actions;
    NSNumber* timeBetweenSteps;
    BOOL isLooping;
    BOOL isRunning;
}

@property (readwrite, retain) NSMutableArray* actions;
@property (readwrite, retain) NSNumber* timeBetweenSteps;
@property (readwrite) BOOL isLooping;
@property (readwrite) BOOL isRunning;

- (id) initWithDetails:(NSString*)newName isLooping:(BOOL)loop time:(double)newTime;

@end
