//
//  ViewController.m
//  ArduinoSerial
//
//  Created by Pat O'Keefe on 4/30/09.
//  Copyright 2009 POP - Pat OKeefe Productions. All rights reserved.
//
//	Portions of this code were derived from Andreas Mayer's work on AMSerialPort. 
//	AMSerialPort was absolutely necessary for the success of this project, and for
//	this, I thank Andreas. This is just a glorified adaptation to present an interface
//	for the ambitious programmer and work well with Arduino serial messages.
//  
//	AMSerialPort is Copyright 2006 Andreas Mayer.
//



#import "ViewController.h"
#import "AMSerialPortList.h"
#import "AMSerialPortAdditions.h"
#import "Light.h"


@implementation ViewController

//@synthesize serialSelectMenu;
//@synthesize textField;

- (void)awakeFromNib
{
	
	[sendButton setEnabled:NO];
	
	/// set up notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddPorts:) name:AMSerialPortListDidAddPortsNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemovePorts:) name:AMSerialPortListDidRemovePortsNotification object:nil];
    
	/// initialize port list to arm notifications
	[AMSerialPortList sharedPortList];
    
    lights = [[NSMutableArray alloc] initWithCapacity:1];
    animations = [[NSMutableArray alloc] initWithCapacity:1];
    groups = [[NSMutableArray alloc] initWithCapacity:2];

    channels = [[NSMutableArray alloc] initWithCapacity:7];
    stateChange = [[NSMutableArray alloc] initWithCapacity:7];
    
    lightNames = [[NSMutableDictionary alloc] initWithCapacity:1];
    groupNames = [[NSMutableDictionary alloc] initWithCapacity:2];
    animationNames = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    globalBrightness = 255;
    
    [groups addObject:[[Group alloc] initWithDetails:@"ALL" size:2 brightness:globalBrightness]];
                       
    black_out = NO;
    isRecording = NO;
	
    [self listDevices];

	// Set us up as the delegate of the webView for relevant events.
    [webView setDrawsBackground:YES];
    [webView setUIDelegate:self];
    [webView setFrameLoadDelegate:self];
	
	[webView setEditingDelegate:self];
    
    // Configure webView to let JavaScript talk to this object.
    [[webView windowScriptObject] setValue:self forKey:@"AppController"]; // can be any unique name you want
	
	/*
     Notes: 
	 1. In JavaScript, you can now talk to this object using "window.AppController".
     
	 2. You must explicitly allow methods to be called from JavaScript;
	 See the +isSelectorExcludedFromWebScript: method below for an example.
     
	 3. The method on this class which we call from JavaScript is -showMessage:
	 To call it from JavaScript, we use window.AppController.showMessage_()  <-- NOTE colon becomes underscore!
	 For more on method-name translation, see:
	 http://developer.apple.com/documentation/AppleApplications/Conceptual/SafariJSProgTopics/Tasks/ObjCFromJavaScript.html#
     */
    
    // Load the HTML content.
	NSString* filePath = [[NSBundle mainBundle] pathForResource: @"scalingTest" ofType: @"html"];
	NSURL *url = [NSURL fileURLWithPath:[filePath stringByDeletingLastPathComponent]];
	[[webView mainFrame] loadHTMLString: [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:NULL] baseURL: url];
	
}

- (IBAction)attemptConnect:(id)sender {
	
	[serialScreenMessage setStringValue:@"Attempting to Connect..."];
	[self initPort];
	
}

	
# pragma mark Serial Port Stuff
	
	- (void)initPort
	{
		NSString *deviceName = [serialSelectMenu titleOfSelectedItem];
		if (![deviceName isEqualToString:[port bsdPath]]) {
			[port close];
			
			[self setPort:[[[AMSerialPort alloc] init:deviceName withName:deviceName type:(NSString*)CFSTR(kIOSerialBSDModemType)] autorelease]];
			[port setDelegate:self];
			
			if ([port open]) {
				
				//Then I suppose we connected!
				NSLog(@"successfully connected");

				[connectButton setEnabled:NO];
				[sendButton setEnabled:YES];
				[serialScreenMessage setStringValue:@"Connection Successful!"];

				//TODO: Set appropriate baud rate here. 
				
				//The standard speeds defined in termios.h are listed near
				//the top of AMSerialPort.h. Those can be preceeded with a 'B' as below. However, I've had success
				//with non standard rates (such as the one for the MIDI protocol). Just omit the 'B' for those.
			
				[port setSpeed:B9600]; 
				

				// listen for data in a separate thread
				[port readDataInBackground];
				
				
			} else { // an error occured while creating port
				
				NSLog(@"error connecting");
				[serialScreenMessage setStringValue:@"Error Trying to Connect..."];
				[self setPort:nil];
				
			}
		}
	}
	
	
	
	- (void)serialPortReadData:(NSDictionary *)dataDictionary
	{
		
		AMSerialPort *sendPort = [dataDictionary objectForKey:@"serialPort"];
		NSData *data = [dataDictionary objectForKey:@"data"];
		
		if ([data length] > 0) {
			
			NSString *receivedText = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			NSLog(@"%@", receivedText);			

            NSArray *dataArray = [receivedText componentsSeparatedByString:@","];
            if([dataArray count]==3)
            {
                NSInteger cmd = [(NSString*)[dataArray objectAtIndex:0] integerValue];
                if(cmd == 9)
                {
                    //button press
                    NSInteger buttonNum = [(NSString*)[dataArray objectAtIndex:1] integerValue];
                    printf("Button Number: %d\n", buttonNum);
                    NSInteger state = [(NSString*)[dataArray objectAtIndex:2] integerValue];
                    printf("State of Button %d: %d\n", buttonNum, state);
                    
                }
                
            }
            else {
                printf("No buttons\n");
            }
			
			// continue listening
			[sendPort readDataInBackground];

		} else { 
			// port closed
			NSLog(@"Port was closed on a readData operation...not good!");
		}
		
	}
	
	- (void)listDevices
	{
		// get an port enumerator
		NSEnumerator *enumerator = [AMSerialPortList portEnumerator];
		AMSerialPort *aPort;
		[serialSelectMenu removeAllItems];
		
		while (aPort = [enumerator nextObject]) {
			[serialSelectMenu addItemWithTitle:[aPort bsdPath]];
		}
	}

- (IBAction)send:(id)sender
{
        if(!port) {
            [self initPort];
        }
        
        NSMutableString *sendString;
        int i = 0;
        
        Action* sendAction = [self diffChannels];

        for(id c in sendAction.targetChannels)
        {
            sendString = [NSMutableString stringWithFormat:@"1"];
            [sendString appendString:[self numberToTriple:(NSNumber*)c]];
            [sendString appendString:[self numberToTriple:(NSNumber*)[sendAction.targetValues objectAtIndex:i]]];
            [sendString appendString:@"\r"];
            //port will be open
            if([port isOpen]) {
                [port writeString:sendString usingEncoding:NSUTF8StringEncoding error:NULL];
                NSLog(@"Sending %@", [sendString substringToIndex:([sendString length]-1)]);
            }
            else 
            {
                NSLog(@"Error sending data. Check connection.");
            }
            i++;
        }
        [self applyState:sendAction];
        [self displayState:[lights objectAtIndex:0]];
        
    }

	- (AMSerialPort *)port
	{
		return port;
	}
	
	- (void)setPort:(AMSerialPort *)newPort
	{
		id old = nil;
		
		if (newPort != port) {
			old = port;
			port = [newPort retain];
			[old release];
		}
	}
	
	
# pragma mark Notifications
	
	- (void)didAddPorts:(NSNotification *)theNotification
	{
		NSLog(@"A port was added");
		[self listDevices];
        [connectButton setEnabled:YES];
	}
	
	- (void)didRemovePorts:(NSNotification *)theNotification
	{
		NSLog(@"A port was removed");
		[self listDevices];
        [connectButton setEnabled:YES];
	}


+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
    // For security, you must explicitly allow a selector to be called from JavaScript.
    
    if (aSelector == @selector(showMessage:)) {
        return NO; // i.e. showMessage: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(setColor:selectString:)) {
        return NO; // i.e. setColor: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(runAnimation:)) {
        return NO; // i.e. runAnimation: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(blackout:)) {
        return NO; // i.e. blackout: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(recover:)) {
        return NO; // i.e. recover: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(toggleRecord:)) {
        return NO; // i.e. toggleRecord: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(clearCurrentAnimationActions:)) {
        return NO; // i.e. clearCurrentAnimationActions: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(toggleLooping:)) {
        return NO; // i.e. toggleLooping: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(setAnimationSpeed:)) {
        return NO; // i.e. setAnimationSpeed: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(firstAction:)) {
        return NO; // i.e. firstAction: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(nextAction:)) {
        return NO; // i.e. nextAction: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(prevAction:)) {
        return NO; // i.e. prevAction: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(setBrightness:selectString:)) {
        return NO; // i.e. setBrightness: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(addLight:numChans:newLabels:)) {
        return NO; // i.e. addLight:numChans:newLabels is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(addGroup:selected:)) {
        return NO; // i.e. addGroup:selected: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(appendToGroup:selected:)) {
        return NO; // i.e. appendToGroup:selected: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(addAnimation:)) {
        return NO; // i.e. addAnimation: is NOT _excluded_ from scripting, so it can be called.
    }
    
    return YES; // disallow everything else
}

- (void) firstAction:(NSString*)f
{

}

- (void) nextAction:(NSString*)n
{
    
}

- (void) prevAction:(NSString*)p
{
    
}

- (void) addChannels:(NSNumber *)numberOfChans newLabels:(NSArray *)labelArray startingAddr:(NSInteger)addr
{
    NSInteger address = addr;
    for(int i = 0; i<[numberOfChans intValue]; i++)
    {
        [channels addObject:[[Channel alloc] initWithDetails:[labelArray objectAtIndex:i] addr:address val:0]];
        [stateChange addObject:[[Channel alloc] initWithDetails:[labelArray objectAtIndex:i] addr:address val:0]];
        if([(NSString*)[labelArray objectAtIndex:i] caseInsensitiveCompare:@"brightness"]==NSOrderedSame)
        {
            ((Channel*)[channels objectAtIndex:((addr-1)+i)]).value = 0;
            ((Channel*)[stateChange objectAtIndex:((addr-1)+i)]).value = globalBrightness;

        }
        address++; 
    }    
}

- (NSString*)addAnimation:(NSString*)name
{
    NSString* retString = [self addName:name dict:animationNames];
    
    Animation* a = [[Animation alloc] initWithDetails:name numChans:1];
    [animations addObject:a];

    return retString;
    
}

- (void)appendToGroup:(NSString*)name selected:(NSString*)selectLights
{
    NSArray *selectArray = [selectLights componentsSeparatedByString:@","];
    Group* g;

    for(id d in groups)
    {
        g = (Group*)d;
        if ([g.name caseInsensitiveCompare:name]==NSOrderedSame)
        {
            break;
        }
    }

    if([selectArray count] && ([((NSString*)[selectArray objectAtIndex:0]) integerValue]!= -1))
    {
        for(id d in selectArray)
        {
            [g.groupLights addObject:(NSString*)d];
        }
        [self setBrightness:[[NSNumber alloc] initWithInt:g.brightness] selectString:[@"l," stringByAppendingString:selectLights]];
    }    
}

- (void)removeLightFromGroup:(NSString*)name selected:(NSString*)selectLights
{
    NSArray *selectArray = [selectLights componentsSeparatedByString:@","];
    Group* g;
    for(id d in groups)
    {
        g = (Group*)d;
        if ([g.name caseInsensitiveCompare:name]==NSOrderedSame)
        {
            break;
        }
    }
    
    if([selectArray count] && ([((NSString*)[selectArray objectAtIndex:0]) integerValue]!= -1))
    {
        for(id d in g.groupLights)
        {
            for(id s in selectArray)
            {
                if ([((NSString*)d) caseInsensitiveCompare:((NSString*)s)]==NSOrderedSame)
                {
                    [g.groupLights removeObject:d];
                    break;
                }
            }
        }
    }    
}

- (NSString*)addGroup:(NSString*)name selected:(NSString*)selectLights
{
    NSArray *selectArray = [selectLights componentsSeparatedByString:@","];
    NSString* retString = [self addName:name dict:groupNames];
    Group* g = [[Group alloc] initWithDetails:retString size:0 brightness:globalBrightness];
    
    if([selectArray count] && ([((NSString*)[selectArray objectAtIndex:0]) integerValue]!= -1))
    {
        for(id d in selectArray)
        {
            [g.groupLights addObject:(NSString*)d];
        }
    }
    [groups addObject:g];

    return retString;
    
}

- (void)removeGroup:(NSString *)name
{
    for (Group* g in groups)
    {
        if ([g.name caseInsensitiveCompare:name]==NSOrderedSame) {
            [groups removeObject:g];
        }
    }
}

- (void)removeAnimation:(NSString *)name
{
    for (Animation* a in animations)
    {
        if ([a.name caseInsensitiveCompare:name]==NSOrderedSame) {
            [animations removeObject:a];
        }
    }
}

- (void)removeLight:(NSNumber *)lightNumber
{
    [lights removeObjectAtIndex:[lightNumber intValue]];
}

- (NSString*)addName:(NSString*)name dict:(NSMutableDictionary*)names
{
    if([names objectForKey:name]==nil)
    {
        NSMutableArray* nameList = [[NSMutableArray alloc] initWithCapacity:1];
        [nameList addObject:name];
        [names setObject:nameList forKey:name];
        
        return name;
    }
    else 
    {
        NSString* newName = [[NSString alloc] initWithFormat:@"%@ (%d)", name,([((NSMutableArray*)[names objectForKey:name]) count]+1)]; 
        [((NSMutableArray*)[names objectForKey:name]) addObject:newName];
        
        return newName;
    }
}

- (NSString*)addLight:(NSString *)name numChans:(NSNumber *)numberOfChans newLabels:(NSString *)labels
{
    NSInteger newAddr = 1;
    
    if([lights count])
    {
        Light *lastLight = (Light*)[lights objectAtIndex:([lights count]-1)];
        newAddr = [lastLight.startingAddress intValue] + [lastLight.sizeOfBlock intValue];
    }
    NSString* retString = [self addName:name dict:lightNames];
    
    Light *newLight = [[Light alloc] initWithDetails:retString size:numberOfChans address:[[NSNumber alloc] initWithInt:newAddr]];

    //add channels
    NSArray *labelArray = [labels componentsSeparatedByString:@","];
    [self addChannels:numberOfChans newLabels:labelArray startingAddr:newAddr];

    [self displayState:newLight];

    [((Group*)[groups objectAtIndex:0]).groupLights addObject:[[NSNumber alloc] initWithInt:[lights count]]]; //add to ALL group
    [self displayState:[groups objectAtIndex:0]];
    [lights addObject:newLight];
    
    return retString;
}

- (void) runAnimation:(NSString*) run //string is arbitrary
{
    /*//testAnimation.isRunning = !testAnimation.isRunning;
    if(testAnimation.isRunning && [testAnimation.actions count])
    {
        
        [self performSelectorInBackground:@selector(threadedRunAnimation:) withObject:0];
        
    }
    else 
    {
        printf("animation already running\n");
    }*/

    
}

- (void) threadedRunAnimation:(NSNumber*) startActionIndex
{
    /*NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(testAnimation.isRunning && [testAnimation.actions count])
    {
        NSArray *immutableActionList = [[NSArray alloc] initWithArray:testAnimation.actions];
        for(int i = 0; i < [immutableActionList count]; i++)        {
            for(Light* l in lights) 
            {
                l.currentAction = (Action*)[immutableActionList objectAtIndex:i];
                
                //[l applyAction];
            }
            if(black_out)
            {
                //testAnimation.lastActionIndex = [[NSNumber alloc] initWithInt:i];
                break;
            }
            if (!testAnimation.isRunning || [testAnimation.actions count] == 0)
            {
                //testAnimation.lastActionIndex = [[NSNumber alloc] initWithInt:i];
                break;
            }
            //[self send:NULL];
            usleep((int)([testAnimation.timeBetweenSteps doubleValue]*1000000)); //timeInBetweenSteps
        }
        if (testAnimation.isLooping && !black_out)
        {
            [self threadedRunAnimation:0];
        }
        [immutableActionList dealloc];
    }
    [pool release];*/
}

- (void) setBrightness:(NSNumber*)brightness selectString:(NSString*)selString
{
    NSLog(@"Setting brightness to %@", brightness);
    
    BOOL error = NO;
    
    NSArray *selectArray = [selString componentsSeparatedByString:@","];
    Action* brightnessAction;
    
    //if you're setting brightness for a light
    if ([(NSString*)[selectArray objectAtIndex:0] caseInsensitiveCompare:@"l"]==NSOrderedSame) 
    {
        NSMutableArray *lightArray = [[NSMutableArray alloc] initWithCapacity:([selectArray count]-1)];
        for(int i = 1; i < [selectArray count]; i++)
        {
            [lightArray addObject:[selectArray objectAtIndex:i]];
        }
        brightnessAction = [self buildBrightnessAction:lightArray brightness:brightness];
    } //if you're setting brightness for a group of lights
    else if ([(NSString*)[selectArray objectAtIndex:0] caseInsensitiveCompare:@"g"]==NSOrderedSame) {
        //find group
        if([selectArray count]==2)
        {
            if ([((NSString*)[selectArray objectAtIndex:1]) caseInsensitiveCompare:@"all"]==NSOrderedSame) {
                globalBrightness = [brightness intValue];
            }
            Group* g;
            for(id d in groups)
            {
                g = (Group*)d;
                if ([g.name caseInsensitiveCompare:(NSString*)[selectArray objectAtIndex:1]]==NSOrderedSame)
                {
                    g.brightness = [brightness intValue];
                    break;
                }
            }
            NSMutableArray *lightArray = [[NSMutableArray alloc] initWithCapacity:([g.groupLights count])];
            for(id h in g.groupLights)
            {
                [lightArray addObject:h];
            }
            brightnessAction = [self buildBrightnessAction:lightArray brightness:brightness];
        }
        else 
        {
            NSLog(@"Error! Only send one group name to setBrightness!");
            error = YES;
        }
        
    }
    else 
    {
        NSLog(@"Wrong string sent to setColor, send 'g' for group and 'l' for lights");
        error = YES;
    }
    
    if(!error && (brightnessAction!=nil) && ([brightnessAction.targetChannels count]>0))
    {
        //check some conditions to see whether to send or not, add to animation, or build a new animation, otherwise just changeState
        [self changeState:brightnessAction];
        [self send:nil];
    }
    
}

- (void) changeState:(Action *)action
{
    for(int i = 0; i < [action.targetChannels count]; i++)
    {
        ((Channel*)[stateChange objectAtIndex:([[action.targetChannels objectAtIndex:i] intValue]-1)]).value = [[action.targetValues objectAtIndex:i] intValue];
    }
}

- (void) applyState:(Action *)action
{
    for(int i = 0; i < [action.targetChannels count]; i++)
    {
        ((Channel*)[channels objectAtIndex:([[action.targetChannels objectAtIndex:i] intValue]-1)]).value = [[action.targetValues objectAtIndex:i] intValue];
    }
}

- (NSMutableArray*)getBrightnessChannels:(Light*)l
{
    NSMutableArray* a = [[NSMutableArray alloc] initWithCapacity:3];
    for(int i = [l.startingAddress intValue]-1; i < (([l.startingAddress intValue]-1)+[l.sizeOfBlock intValue]);i++)
    {
        if ([((Channel*)[channels objectAtIndex:i]).label caseInsensitiveCompare:@"brightness"]==NSOrderedSame)
        {
            [a addObject:[[NSNumber alloc] initWithInt:i+1]];
        }
    }
    if ([a count] < 1)
    {
        NSLog(@"Could not find a brightness channel, check channel configuration");
    }
    return a;
}

- (NSMutableArray*)getColorChannels:(Light*)l
{
    NSMutableArray* a = [[NSMutableArray alloc] initWithCapacity:3];
    for(int i = [l.startingAddress intValue]-1; i < (([l.startingAddress intValue]-1)+[l.sizeOfBlock intValue]);i++)
    {
        if ([((Channel*)[channels objectAtIndex:i]).label caseInsensitiveCompare:@"red"]==NSOrderedSame)
        {
            [a addObject:[[NSNumber alloc] initWithInt:i+1]];
        }
        if ([((Channel*)[channels objectAtIndex:i]).label caseInsensitiveCompare:@"green"]==NSOrderedSame)
        {
            [a addObject:[[NSNumber alloc] initWithInt:i+1]];
        }
        if ([((Channel*)[channels objectAtIndex:i]).label caseInsensitiveCompare:@"blue"]==NSOrderedSame)
        {
            [a addObject:[[NSNumber alloc] initWithInt:i+1]];
        }
    }
    if ([a count] < 3)
    {
        NSLog(@"Could not find all 3 colors, check channel configuration");
    }
    return a;
}

- (Action*) buildColorAction:(NSMutableArray*)lightArray color:(NSString*)color
{
    Action* colorAction = [Action alloc]; 
    [colorAction initWithDetails:@"Set Color" numChans:(3*[lightArray count])];
    //add the RGB channels of each light in lightArray
    //set values appropriately
    for (id i in lightArray)
    {
        Light* l = [lights objectAtIndex:[(NSString*)i integerValue]];
        [colorAction.targetChannels addObjectsFromArray:[self getColorChannels:l]];
        
        if ([color isEqualToString:@"red"])
        {
            [self setColorHelper:colorAction.targetValues red:255 green:0 blue:0];        
        }
        else if ([color isEqualToString:@"green"])
        {
            [self setColorHelper:colorAction.targetValues red:0 green:255 blue:0];
        }
        else if ([color isEqualToString:@"blue"])
        {
            [self setColorHelper:colorAction.targetValues red:0 green:75 blue:255];        
        }
        else if ([color isEqualToString:@"cyan"])
        {
            [self setColorHelper:colorAction.targetValues red:0 green:255 blue:255];        
        }
        else if ([color isEqualToString:@"magenta"])
        {
            [self setColorHelper:colorAction.targetValues red:255 green:0 blue:255];        
        }
        else if ([color isEqualToString:@"yellow"])
        {
            [self setColorHelper:colorAction.targetValues red:180 green:75 blue:0];        
        }
        else if ([color isEqualToString:@"white"])
        {
            [self setColorHelper:colorAction.targetValues red:255 green:255 blue:255];        
        }
        else if ([color isEqualToString:@"black"])
        {
            [self setColorHelper:colorAction.targetValues red:0 green:0 blue:0];        
        }
    }
    
    return colorAction;
}


- (Action*) buildBrightnessAction:(NSMutableArray*)lightArray brightness:(NSNumber*)brightness
{
    Action* brightnessAction = [Action alloc]; 
    [brightnessAction initWithDetails:@"Set Color" numChans:(3*[lightArray count])];

    for (id i in lightArray)
    {
        Light* l = [lights objectAtIndex:[(NSString*)i integerValue]];
        [brightnessAction.targetChannels addObjectsFromArray:[self getBrightnessChannels:l]];
        [brightnessAction.targetValues addObject:brightness];
    }
    
    return brightnessAction;
}

- (void) setColor:(NSString *)color selectString:(NSString*) selString
{
    NSLog(@"Setting color to %@", color);
    
    BOOL error = NO;

    NSArray *selectArray = [selString componentsSeparatedByString:@","];
    Action* colorAction;

    //if you're setting color for a light
    if ([(NSString*)[selectArray objectAtIndex:0] caseInsensitiveCompare:@"l"]==NSOrderedSame) 
    {
        NSMutableArray *lightArray = [[NSMutableArray alloc] initWithCapacity:([selectArray count]-1)];
        for(int i = 1; i < [selectArray count]; i++)
        {
            [lightArray addObject:[selectArray objectAtIndex:i]];
        }
        colorAction = [self buildColorAction:lightArray color:color];
    } //if you're setting color for a group of lights
    else if ([(NSString*)[selectArray objectAtIndex:0] caseInsensitiveCompare:@"g"]==NSOrderedSame) {
        //find group
        if([selectArray count]==2)
        {
            if ([((NSString*)[selectArray objectAtIndex:1]) caseInsensitiveCompare:@"all"]==NSOrderedSame) {
                [self setBrightness:[[NSNumber alloc] initWithInt:globalBrightness] selectString:selString];
            }
            
            Group* g;
            for(id d in groups)
            { 
                g = (Group*)d;
                if ([g.name caseInsensitiveCompare:(NSString*)[selectArray objectAtIndex:1]]==NSOrderedSame)
                {
                    [self setBrightness:[[NSNumber alloc] initWithInt:g.brightness] selectString:selString];
                    break;
                }
            }
            NSMutableArray *lightArray = [[NSMutableArray alloc] initWithCapacity:([g.groupLights count])];
            for(id h in g.groupLights)
            {
                [lightArray addObject:h];
            }
            colorAction = [self buildColorAction:lightArray color:color];
            [self displayState:colorAction];
            [self displayState:g];
        }
        else 
        {
            NSLog(@"Error! Only send one group name to setColor!");
            error = YES;
        }

    }
    else 
    {
        NSLog(@"Wrong string sent to setColor, send 'g' for group and 'l' for lights");
        error = YES;
    }

    if(!error && (colorAction!=nil) && ([colorAction.targetChannels count]>0))
    {
        //check some conditions to see whether to send or not, add to animation, or build a new animation, otherwise just changeState
        if(isRecording)
        {
            if (currentAnimation != nil)
            {
                //add color action to current animation's action list, send if not playing
            }
            else {
                //new animation, set new to current, send (can't be playing if no animation is current
            }

        }
        [self changeState:colorAction];
        [self send:nil];
    }
}

- (void) setColorHelper:(NSMutableArray *)valueList red:(int)r green:(int)g blue:(int)b
{
    [valueList addObject:[[NSNumber alloc] initWithInt:r]];
    [valueList addObject:[[NSNumber alloc] initWithInt:g]];
    [valueList addObject:[[NSNumber alloc] initWithInt:b]];
    
}

- (void) toggleRecord:(NSString *)rec
{
    isRecording = !isRecording;
}

- (void) toggleLooping:(NSString *)l
{
    //testAnimation.isLooping = !testAnimation.isLooping;
}

- (void) setAnimationSpeed:(NSNumber *)speed
{
    if([speed doubleValue] > 0)
    {
        //testAnimation.timeBetweenSteps = speed;
    }
}

- (void)blackout:(NSString *)black
{
    /*testAnimation.isRunning = NO;
    black_out = YES;
    Action* tempAction = [Action alloc];
    [tempAction initWithDetails:@"" numChans:3];

    [tempAction.targetChannels addObject:[[NSNumber alloc] initWithInt:([testLight.startingAddress intValue])]];
    [tempAction.targetChannels addObject:[[NSNumber alloc] initWithInt:([testLight.startingAddress intValue]+1)]];
    [tempAction.targetChannels addObject:[[NSNumber alloc] initWithInt:([testLight.startingAddress intValue]+2)]];
    
    [self setColorHelper:tempAction.targetValues red:0 green:0 blue:0];
    
    Action* recoverAction = testLight.currentAction;
    testLight.currentAction = tempAction;
    //[testLight applyAction];
    //[self send:NULL];
    testLight.currentAction = recoverAction;*/
}

- (void)recover:(NSString *)r
{
    black_out = NO;
    [self runAnimation:@""];    
    //[testLight applyAction];
    //[self send:NULL];
}

- (void)clearCurrentAnimationActions:(NSString *)c
{
    /*Action* tempAction = [Action alloc];
    testAnimation.isRunning = NO;
    [tempAction initWithDetails:@"" numChans:3];
    [tempAction.targetChannels addObject:[[NSNumber alloc] initWithInt:([testLight.startingAddress intValue])]];
    [tempAction.targetChannels addObject:[[NSNumber alloc] initWithInt:([testLight.startingAddress intValue]+1)]];
    [tempAction.targetChannels addObject:[[NSNumber alloc] initWithInt:([testLight.startingAddress intValue]+2)]];
    
    [self setColorHelper:tempAction.targetValues red:0 green:0 blue:0];
    
    testLight.currentAction = tempAction;
    //[testLight applyAction];
    //[self send:NULL];
    
    [testAnimation.actions setArray:[[NSMutableArray alloc] initWithCapacity:10]];
	
	[webView stringByEvaluatingJavaScriptFromString:@"deactivatePlaying();"];*/
}

- (void)showMessage:(NSString *)message
{
    // This method is called from the JavaScript "onClick" handler of the INPUT element 
    // in the HTML. This shows you how to have HTML form elements call Cocoa methods.
    
    NSRunAlertPanel(@"Message from JavaScript", message, nil, nil, nil);
}

/* For debugging purposes */
- (void) displayState:(id)d
{
    if([d isKindOfClass:[Light class]])
    {
        Light* l = (Light*)d;
        NSLog(@"Light: %@", l.name);
        NSLog(@"--------------");
        for(int i = 0; i < [l.sizeOfBlock intValue]; i++)
        {
            [((Channel*)[channels objectAtIndex:(([l.startingAddress intValue]-1)+i)]) display];
        }
    }
    else if([d isKindOfClass:[Group class]])
    {
        Group* g = (Group*)d;
        NSLog(@"Group: %@", g.name);
        NSLog(@"--------------");
        NSLog(@"Child Lights:");
        for(int i = 0; i < [g.groupLights count]; i++)
        {
            NSLog(@"%d", [[g.groupLights objectAtIndex:i] intValue]);
        }
    }
    else if([d isKindOfClass:[Action class]])
    {
        Action* a = (Action*)d;
        NSLog(@"Action: %@", a.name);
        NSLog(@"--------------");
        NSLog(@"Chan - Val:");
        for(int i = 0; i < [a.targetChannels count]; i++)
        {
            NSLog(@"%d      %d", [[a.targetChannels objectAtIndex:i] intValue], [[a.targetValues objectAtIndex:i] intValue]);
        }
        
    }
}

- (Action *)diffChannels
{
    Action* diff = [[Action alloc] initWithDetails:@"DIFF" numChans:3];
    
    for(int i = 0; i < [channels count]; i++)
    {
        if(((Channel*)[channels objectAtIndex:i]).value != ((Channel*)[stateChange objectAtIndex:i]).value)
        {
            [diff.targetChannels addObject:[[NSNumber alloc] initWithInt:((Channel*)[stateChange objectAtIndex:i]).address]];
            [diff.targetValues addObject:[[NSNumber alloc] initWithInt:(((Channel*)[stateChange objectAtIndex:i]).value)]];
        }
    }
 
    return diff;
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

//Added methods to disable functions:


- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element 
    defaultMenuItems:(NSArray *)defaultMenuItems
{
    // disable right-click context menu
    return NO;
}

- (BOOL)webView:(WebView *)webView shouldChangeSelectedDOMRange:(DOMRange *)currentRange 
	 toDOMRange:(DOMRange *)proposedRange 
	   affinity:(NSSelectionAffinity)selectionAffinity 
 stillSelecting:(BOOL)flag
{
    // disable text selection
    return YES;
}

-(IBAction)makeTextLarger:(id)sender
{
	[webView makeTextLarger:sender];
}
-(IBAction)makeTextSmaller:(id)sender
{
	[webView makeTextSmaller:sender];
}

@end
