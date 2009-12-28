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
}
@property (readwrite, retain) NSString* name;
@property (readwrite, retain) NSNumber* sizeOfBlock;
@property (readwrite, retain) NSNumber* startingAddress;

- (id) initWithDetails: (NSString*)newName size:(NSNumber*)newSize address:(NSNumber*)newAddress;

@end

