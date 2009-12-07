//
//  Channel.h
//  LightController
//
//  Created by Patrick Smith on 11/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Channel : NSObject {
    NSString* label; 
    NSInteger address; // 1-512
    NSInteger value; //0-255
}
@property (readwrite, retain) NSString* label;
@property (readwrite) NSInteger address;
@property (readwrite) NSInteger value;

- (id) initWithDetails:(NSString*)newLabel addr:(NSInteger)newAddress val:(NSInteger)newValue;
- (void) display;

@end
