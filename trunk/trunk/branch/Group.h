//
//  Group.h
//  LightController
//
//  Created by Patrick Smith on 12/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Group : NSObject {
    NSMutableArray* groupLights;
    NSString* name;
}
@property (readwrite, retain) NSString* name;
@property (readwrite, retain) NSMutableArray* groupLights;

- (id) initWithDetails: (NSString*)newName size:(NSInteger)newSize;

@end
