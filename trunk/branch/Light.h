//
//  Light.h
//  LightController
//
//  Created by Patrick Smith on 11/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMSerialPort.h"
#import "AMSerialPortAdditions.h"
#import "Action.h"
#import "Animation.h"
#import "Channel.h"

@interface Light : NSObject {
    NSString* name;
    NSNumber* sizeOfBlock; //# of channels
    NSNumber* startingAddress;
    NSMutableArray* channels; //list of channels
    BOOL changed;
    Action* currentAction; //current action
}
@property (readwrite, retain) NSString* name;
@property (readwrite, retain) NSNumber* sizeOfBlock;
@property (readwrite, retain) NSNumber* startingAddress;
@property (readwrite, retain) NSMutableArray* channels;
@property (readwrite, assign) BOOL changed;
@property (readwrite, retain) Action* currentAction;

- (id) initWithDetails: (NSString*)newName size:(NSNumber*)newSize address:(NSNumber*)newAddress;
- (void) displayState;
- (NSInteger) sendState: (AMSerialPort*) port; //needs to know which port to send to
- (NSString*) numberToTriple: (NSNumber*) num;
- (void) applyAction;

@end
