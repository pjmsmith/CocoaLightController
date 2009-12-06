//
//  Action.h
//  LightController
//
//  Created by Patrick Smith on 11/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Action : NSObject {
    NSMutableString* name;
    NSMutableArray* targetChannels;
    NSMutableArray* targetValues;
}

@property (readwrite, retain) NSMutableString* name;
@property (readwrite, retain) NSMutableArray* targetChannels;
@property (readwrite, retain) NSMutableArray* targetValues;

- (id) initWithDetails:(NSString*)newName numChans:(NSInteger)chans;

@end
