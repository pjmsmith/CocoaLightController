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
    serviceStarted=NO;
    
    PULSE_NAME = @"Pulse";
    CHASE_NAME = @"Chase";
    
    button1 = @"";
    button2 = @"";
    button3 = @"";
    
    currentAnimation = [[NSString alloc] initWithString:@""];
	
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
			
				[port setSpeed:B14400]; 
				

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
			//NSLog(@"%@", receivedText);			

            NSArray *dataArray = [receivedText componentsSeparatedByString:@","];
            if([dataArray count]==3)
            {   
#pragma mark button work
                NSInteger cmd = [(NSString*)[dataArray objectAtIndex:0] integerValue];
                if(cmd == 9)
                {
                    //button press
                    NSInteger buttonNum = [(NSString*)[dataArray objectAtIndex:1] integerValue];
                    //printf("Button Number: %d\n", buttonNum);
                    NSInteger state = [(NSString*)[dataArray objectAtIndex:2] integerValue];
                    //printf("State of Button %d: %d\n", buttonNum, state);
                    if(state==1)
                    {
                        NSString* button;
                        switch (buttonNum) 
                        {
                            case 1:
                                button = button1;
                                break;
                            case 2:
                                button = button2;
                                break;
                            case 3:
                                button = button3;
                                break;                                
                            default:
                                break;
                        }
                        
                        if([button caseInsensitiveCompare:PULSE_NAME]==NSOrderedSame)
                        {
                            NSLog(@"Pulse");
                            [self pulseActions:@"g,all" lowValue:(NSNumber*)[webView stringByEvaluatingJavaScriptFromString:@"displayValue('left');"]
                                     highValue:(NSNumber*)[webView stringByEvaluatingJavaScriptFromString:@"displayValue('right');"]
                                          time:(NSNumber*)[webView stringByEvaluatingJavaScriptFromString:@"$('#animationSpeedInput').attr('value');"]];
                        }
                        else if([([([[button componentsSeparatedByString:@":"] objectAtIndex:0]) stringByReplacingOccurrencesOfString:@" " withString:@""]) caseInsensitiveCompare:CHASE_NAME]==NSOrderedSame)
                        {
                            NSLog(@"Chase");
                            button = [button stringByReplacingOccurrencesOfString:@" " withString:@""];

                            NSArray* buttonElements = [button componentsSeparatedByString:@":"];
                            if ([buttonElements count]==4)
                            {
                                NSString* color = [self validateColor:((NSString*)[buttonElements objectAtIndex:1])];
                                NSString* chaseRange = [self getLightStringFromRange:((NSString*)[buttonElements objectAtIndex:2])];
                                NSString* chaseType = (NSString*)[buttonElements objectAtIndex:3];
                                if((color!=nil)&&(chaseRange!=nil))
                                {
                                    [self chaseActions:color range:chaseRange type:chaseType time:(NSNumber*)[webView stringByEvaluatingJavaScriptFromString:@"$('#animationSpeedInput').attr('value');"]];
                                }
                            }
                            else 
                            {
                                NSLog(@"Malformed Chase string. Format: Chase : <color> : [<#-#>|<#,#,#,...>] : <[single|elastic|sweep]>");
                            }

                        }
                        else
                        {
                            Animation* a = [self getAnimationByName: button1];
                            if(a!=nil)
                            {
                                [webView stringByEvaluatingJavaScriptFromString:[@"" stringByAppendingFormat:@"switchToAnimation('%@');", button]];
                            }
                        }
                    } 
                }
            }
            else {
                //printf("No buttons\n");
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
        
        Action* sendAction = [self diffChannels:stateChange with:channels];

        for(id c in sendAction.targetChannels)
        {
            sendString = [NSMutableString stringWithFormat:@"1"];
            [sendString appendString:[self numberToTriple:(NSNumber*)c]];
            [sendString appendString:[self numberToTriple:(NSNumber*)[sendAction.targetValues objectAtIndex:i]]];
            [sendString appendString:@"\r"];
            //port will be open
            if([port isOpen]) {
                [port writeString:sendString usingEncoding:NSUTF8StringEncoding error:NULL];
                //NSLog(@"Sending %@", [sendString substringToIndex:([sendString length]-1)]);
            }
            else 
            {
                NSLog(@"Error sending data. Check connection.");
            }
            i++;
        }
        [self applyState:sendAction];
        //[self displayState:[lights objectAtIndex:0]];
        
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
    if (aSelector == @selector(setColor:selectString:selectAnimation:)) {
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
    if (aSelector == @selector(setBrightness:selectString:selectAnimation:)) {
        return NO; // i.e. setBrightness: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(addLight:numChans:newLabels:)) {
        return NO; // i.e. addLight:numChans:newLabels is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(addGroup:selected:)) {
        return NO; // i.e. addGroup:selected: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(appendToGroup:selected:selectAnimation:)) {
        return NO; // i.e. appendToGroup:selected: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(addAnimation:)) {
        return NO; // i.e. addAnimation: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(removeGroup:)) {
        return NO; // i.e. removeGroup: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(removeAnimation:)) {
        return NO; // i.e. removeAnimation: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(removeLight:)) {
        return NO; // i.e. removeLight: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(removeLightFromGroup:selected:)) {
        return NO; // i.e. removeLightFromGroup:selected: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(setCurrentAnimation:)) {
        return NO; // i.e. setCurrentAnimation: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(pulse:selectAnimation:lowValue:highValue:)) {
        return NO; // i.e. pulse:selectedAnimation:lowValue:highValue: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(setButtonAction:action:)) {
        return NO; // i.e. setButtonAction:action: is NOT _excluded_ from scripting, so it can be called.
    }
    
    return YES; // disallow everything else
}

- (void) firstAction:(NSString*)f
{
    Animation* a = [self getAnimationByName:currentAnimation];
    if(a!=nil)
    {
        a.isRunning = NO;
        [webView stringByEvaluatingJavaScriptFromString:@"deactivatePlaying();"];
        a.lastActionIndex = [[NSNumber alloc] initWithInt:0];
        NSArray *immutableActionList = [[NSArray alloc] initWithArray:a.actions];
        [self changeState:(Action*)[immutableActionList objectAtIndex:[a.lastActionIndex intValue]]];
        [self send:NULL];
    }
}

- (void) nextAction:(NSString*)n
{
    Animation* a = [self getAnimationByName:currentAnimation];
    if(a!=nil)
    {
        a.isRunning = NO;
        [webView stringByEvaluatingJavaScriptFromString:@"deactivatePlaying();"];
        NSInteger prevIndex = [a.lastActionIndex intValue];
        if ((prevIndex+1)<[a.actions count])
        {
            a.lastActionIndex = [[NSNumber alloc] initWithInt:(prevIndex+1)];
        }
        else {
            a.lastActionIndex = [[NSNumber alloc] initWithInt:0];
        }
        
        NSArray *immutableActionList = [[NSArray alloc] initWithArray:a.actions];
        NSLog(@"NEXT");
        [self changeState:(Action*)[immutableActionList objectAtIndex:[a.lastActionIndex intValue]]];
        [self send:NULL];
    }    
}

- (void) prevAction:(NSString*)p
{
    Animation* a = [self getAnimationByName:currentAnimation];
    if(a!=nil)
    {
        a.isRunning = NO;
        [webView stringByEvaluatingJavaScriptFromString:@"deactivatePlaying();"];
        NSInteger prevIndex = [a.lastActionIndex intValue];
        if ((prevIndex-1)<0)
        {
            a.lastActionIndex = [[NSNumber alloc] initWithInt:([a.actions count]-1)];
        }
        else {
            a.lastActionIndex = [[NSNumber alloc] initWithInt:(prevIndex-1)];
        }

        NSArray *immutableActionList = [[NSArray alloc] initWithArray:a.actions];
        [self changeState:(Action*)[immutableActionList objectAtIndex:[a.lastActionIndex intValue]]];
        [self send:NULL];
    }
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
    
    Animation* a = [[Animation alloc] initWithDetails:retString isLooping:NO time:0.5];

    [animations addObject:a];

    return retString;
    
}

- (void)appendToGroup:(NSString*)name selected:(NSString*)selectLights selectAnimation:(NSString*)selectedAnimation
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
        [self setBrightness:[[NSNumber alloc] initWithInt:g.brightness] selectString:[@"l," stringByAppendingString:selectLights] selectAnimation:selectedAnimation];
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
    for(Group* g in groups)
    {
        for(id d in g.groupLights)
        {
            if ([d integerValue]==[lightNumber intValue]) {
                [g.groupLights removeObject:d];
            }
        }
    }
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

    //[self displayState:newLight];

    [((Group*)[groups objectAtIndex:0]).groupLights addObject:[[NSNumber alloc] initWithInt:[lights count]]]; //add to ALL group
    //[self displayState:[groups objectAtIndex:0]];
    [lights addObject:newLight];
    
    return retString;
}

- (void) setCurrentAnimation:(NSString*)selectedAnimation
{
    Animation* a = [self getAnimationByName:currentAnimation];
    if(a!=nil)
    {
        a.isRunning = NO;
        [webView stringByEvaluatingJavaScriptFromString:@"deactivatePlaying();"];
    }
    
    currentAnimation = [[NSString alloc] initWithString:selectedAnimation];
}

- (void) runAnimation:(NSString*)run
{
    //NSLog(@"%@", currentAnimation);
    Animation* a = [self getAnimationByName:currentAnimation];
    if(a==nil)
    {
        [webView stringByEvaluatingJavaScriptFromString:@"deactivatePlaying();"];
        NSLog(@"No animation on deck. Double-click one to make it active.");
    }
    else 
    {
        a.isRunning = !a.isRunning;
        if(a.isRunning && [a.actions count])
        {
            runThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadedRunAnimation:) object:[self getAnimationByName:currentAnimation]];
            [runThread start];
        }
    }
}

- (void) threadedRunAnimation:(Animation*)a
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL subAnim = NO;
    double timeMod = 1000000.0;
    if(a.isRunning && [a.actions count])
    {
        NSArray *immutableActionList = [[NSArray alloc] initWithArray:a.actions];
        //NSLog(@"%@", a.name);
        if ([a.name caseInsensitiveCompare:PULSE_NAME]==NSOrderedSame)
        {
            timeMod = 1000000.0;
        }
        for(int i = 0; i < [immutableActionList count]; i++)
        {
            if ([[immutableActionList objectAtIndex:i] isKindOfClass:[Animation class]])
            {
                ((Animation*)[immutableActionList objectAtIndex:i]).isRunning = YES;
                [self threadedRunAnimation:(Animation*)[immutableActionList objectAtIndex:i]];
                ((Animation*)[immutableActionList objectAtIndex:i]).isRunning = NO;
                subAnim = YES;
            }
            else
            {
                [self changeState:(Action*)[immutableActionList objectAtIndex:i]];
            }
            if(black_out)
            {
                //testAnimation.lastActionIndex = [[NSNumber alloc] initWithInt:i];
                break;
            }
            if (!a.isRunning || [a.actions count] == 0)
            {
                //testAnimation.lastActionIndex = [[NSNumber alloc] initWithInt:i];
                break;
            }
            [self send:NULL];
            if(!subAnim)
            {
                for(int j = 0; j < (NSInteger)([a.timeBetweenSteps doubleValue]*30.0); j++)
                {
                    if(a.isRunning)
                    {
                        usleep((int)((1.0/15.0)*timeMod)); //timeInBetweenSteps
                    }
                    else
                    {
                        break;
                    }
                }
            }
            else {
                subAnim = NO;
                timeMod = 1000000.0;
            }


        }
        if (a.isLooping && !black_out)
        {
            [self threadedRunAnimation:a];
        }
        else 
        {
            a.isRunning = NO;
            [webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:@"deactivatePlaying();" waitUntilDone:NO];
        }

        [immutableActionList dealloc];
    }
    [pool release];
}

- (Action*) combineAction:(Action*)a with:(Action*)b
{
    Action* comboAction;
    for(id addr in b.targetChannels)
    {
        [a.targetChannels addObject:addr];
    }
    for(id val in b.targetValues)
    {
        [a.targetValues addObject:val];
    }
    comboAction = a;
    comboAction.name = [[NSMutableString alloc] initWithString:@"Combo"];
    return comboAction;
}

- (NSMutableArray*) chaseActions:(NSString*)color range:(NSString*)chaseRange type:(NSString*)chaseType time:(NSNumber*)timeBetweenSteps
{
    Animation* subAnimation = [[Animation alloc] initWithDetails:CHASE_NAME isLooping:NO time:[timeBetweenSteps doubleValue]];
    if([chaseType caseInsensitiveCompare:@"single"]==NSOrderedSame)
    {
        NSArray* lightList = [chaseRange componentsSeparatedByString:@","];
        NSString* lightString = @"";
        lightString = [lightString stringByAppendingFormat:@"l,%@", [lightList objectAtIndex:0]];
        [subAnimation.actions addObject:[self setColor:color selectString:lightString selectAnimation:CHASE_NAME]];
        lightString = @"";
        for(int i = 1; i < [lightList count]; i++)
        {
            Action* comboAction;
            lightString = [lightString stringByAppendingFormat:@"l,%@", [lightList objectAtIndex:i-1]];
            comboAction = [self setColor:@"black" selectString:lightString selectAnimation:CHASE_NAME];
            lightString = @"";
            lightString = [lightString stringByAppendingFormat:@"l,%@", [lightList objectAtIndex:i]];
            [self combineAction:comboAction with:[self setColor:color selectString:lightString selectAnimation:CHASE_NAME]];
            lightString = @"";
            [subAnimation.actions addObject:comboAction];
        }
        lightString = [lightString stringByAppendingFormat:@"l,%@", [lightList objectAtIndex:([lightList count]-1)]];
        [subAnimation.actions addObject:[self setColor:@"black" selectString:lightString selectAnimation:CHASE_NAME]];
        
        subAnimation.isRunning = YES;

        [self performSelectorInBackground:@selector(threadedRunAnimation:) withObject:subAnimation];
    }
    else if([chaseType caseInsensitiveCompare:@"elastic"]==NSOrderedSame)
    {
        NSArray* lightList = [chaseRange componentsSeparatedByString:@","];
        NSString* lightString = @"";
        for(int i = 0; i < [lightList count]; i++)
        {
            lightString = [lightString stringByAppendingFormat:@"l,%@", [lightList objectAtIndex:i]];
            [subAnimation.actions addObject:[self setColor:color selectString:lightString selectAnimation:CHASE_NAME]];
            lightString = @"";

        }
        for(int i = ([lightList count]-1); i >= 0; i--)
        {
            lightString = [lightString stringByAppendingFormat:@"l,%@", [lightList objectAtIndex:i]];
            [subAnimation.actions addObject:[self setColor:@"black" selectString:lightString selectAnimation:CHASE_NAME]];
            lightString = @"";
        }
        subAnimation.isRunning = YES;

        [self performSelectorInBackground:@selector(threadedRunAnimation:) withObject:subAnimation];
    }
    else if([chaseType caseInsensitiveCompare:@"sweep"]==NSOrderedSame)
    {
        NSArray* lightList = [chaseRange componentsSeparatedByString:@","];
        NSString* lightString = @"";
        for(int i = 0; i < [lightList count]; i++)
        {
            lightString = [lightString stringByAppendingFormat:@"l,%@", [lightList objectAtIndex:i]];
            [subAnimation.actions addObject:[self setColor:color selectString:lightString selectAnimation:CHASE_NAME]];
            lightString = @"";
        }
        for(int i = 0; i < [lightList count]; i++)
        {
            lightString = [lightString stringByAppendingFormat:@"l,%@", [lightList objectAtIndex:i]];
            [subAnimation.actions addObject:[self setColor:@"black" selectString:lightString selectAnimation:CHASE_NAME]];
            lightString = @"";
        }
        subAnimation.isRunning = YES;

        [self performSelectorInBackground:@selector(threadedRunAnimation:) withObject:subAnimation];
    }
    if(![subAnimation.actions count])
    {
        NSLog(@"Malformed chase type. Options are: single, elastic, sweep");
    }
    
    return subAnimation.actions;
}

- (NSString*) validateColor:(NSString *)color
{
    NSString* retString;
    if([color caseInsensitiveCompare:@"red"]==NSOrderedSame)
    {
        retString = color;
    }
    if([color caseInsensitiveCompare:@"green"]==NSOrderedSame)
    {
        retString = color;
    }
    if([color caseInsensitiveCompare:@"blue"]==NSOrderedSame)
    {
        retString = color;
    }
    if([color caseInsensitiveCompare:@"cyan"]==NSOrderedSame)
    {
        retString = color;
    }
    if([color caseInsensitiveCompare:@"magenta"]==NSOrderedSame)
    {
        retString = color;
    }
    if([color caseInsensitiveCompare:@"yellow"]==NSOrderedSame)
    {
        retString = color;
    }
    if([color caseInsensitiveCompare:@"white"]==NSOrderedSame)
    {
        retString = color;
    }
    
    return retString;
}

- (NSString*) getLightStringFromRange:(NSString *)range
{
    NSString* retString;
    if([[range componentsSeparatedByString:@"-"] count] == 2)
    {
        NSArray* hyphenRange = [range componentsSeparatedByString:@"-"];

        if([self validateNumberList:hyphenRange])
        {
            //build list of strings in range
            NSInteger lowIndex = [[hyphenRange objectAtIndex:0] integerValue];
            NSInteger highIndex = [[hyphenRange objectAtIndex:1] integerValue];
            NSMutableString* tempString = [[NSMutableString alloc] initWithString:@""];
            if(highIndex < lowIndex)
            {
                for(int i = lowIndex; i>=highIndex; i--)//6-1 = 6,5,4,3,2,1
                {
                    [tempString appendFormat:@"%d,", i];
                }
            }
            else 
            {
                for(int i = lowIndex; i<=highIndex; i++)//1-6 = 1,2,3,4,5,6
                {
                    [tempString appendFormat:@"%d,", i];
                }
            }
            retString = [tempString substringToIndex:([tempString length]-1)];
        }
        else 
        {
            NSLog(@"Malformed number range.");
            retString = nil;
        }

    }
    else //check comma separated
    {
        NSArray* commaRange = [range componentsSeparatedByString:@","];

        if([self validateNumberList:commaRange])
        {
            retString = range;
            NSLog(@"%@", retString);
        }
        else
        {
            NSLog(@"Malformed number range.");
            retString = nil;
        }
    }
    return retString;
}
               
- (BOOL) validateNumberList:(NSArray*)list
{
    BOOL isValid = YES;
    for(id d in list)
    {
        NSString* value = (NSString*)d;
        isValid &= [[NSScanner scannerWithString:value] scanInt:nil];
    }
    return isValid;
}

- (NSMutableArray*) pulseActions:(NSString *)selectedLights lowValue:(NSNumber*)lowVal highValue:(NSNumber*)highVal time:(NSNumber*)timeBetweenSteps
{
    Animation* subAnimation = [[Animation alloc] initWithDetails:PULSE_NAME isLooping:NO time:(double)(1.0/15.0)];
    NSInteger low = [lowVal intValue];
    NSInteger high = [highVal intValue];
    NSInteger difference = abs(high-low);
    
    NSInteger frames = [timeBetweenSteps doubleValue]*30.0;
    if(frames>0)
    {
        difference /= frames;
    }
    
    if (high < low)
    {
        for (int i = high; i < low; i+=difference)
        {
            [subAnimation.actions addObject:[self setBrightness:[[NSNumber alloc] initWithInt:i] selectString:selectedLights selectAnimation:@""]];
        }
    }
    else 
    {
        for (int i = high; i > low; i-=difference)
        {            
            [subAnimation.actions addObject:[self setBrightness:[[NSNumber alloc] initWithInt:i] selectString:selectedLights selectAnimation:@""]];
        }
    }
    [self performSelectorInBackground:@selector(threadedRunAnimation:) withObject:subAnimation];

    return subAnimation.actions;
}

- (void) pulse:(NSString*)selectedLights selectAnimation:(NSString*)selectedAnimation lowValue:(NSNumber*)lowVal highValue:(NSNumber*)highVal
{
    NSInteger low = [lowVal intValue];
    NSInteger high = [highVal intValue];
    NSInteger difference = abs(high-low);
    Animation* a = [self getAnimationByName:selectedAnimation];
    Animation* subAnimation = [[Animation alloc] initWithDetails:PULSE_NAME isLooping:NO time:(double)(1.0/15.0)];
    
    subAnimation.selectedLights = [[NSString alloc] initWithString:selectedLights];
    subAnimation.highValue = highVal;
    subAnimation.lowValue = lowVal;
    if (a!=nil) 
    {
        subAnimation.actions = [self pulseActions:selectedLights lowValue:lowVal highValue:highVal time:a.timeBetweenSteps];
    }
    else 
    {
        difference = 20;
        if (high < low)
        {
            for (int i = high; i < low; i+=difference)
            {
                [subAnimation.actions addObject:[self setBrightness:[[NSNumber alloc] initWithInt:i] selectString:selectedLights selectAnimation:@""]];
            }
        }
        else 
        {
            for (int i = high; i > low; i-=difference)
            {
                NSLog(@"Frame: %d", i);

                [subAnimation.actions addObject:[self setBrightness:[[NSNumber alloc] initWithInt:i] selectString:selectedLights selectAnimation:@""]];
            }
        }
    }

    if(a!=nil && isRecording)
    {
        [a.actions addObject:subAnimation];
    }
    else
    {
        [subAnimation dealloc];
    }
}

- (Action*) setBrightness:(NSNumber*)brightness selectString:(NSString*)selString selectAnimation:(NSString*)selectedAnimation
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
        NSLog(@"Wrong string sent to setBrightness, send 'g' for group and 'l' for lights");
        error = YES;
    }
    
    if(!error && (brightnessAction!=nil) && ([brightnessAction.targetChannels count]>0))
    {
        //check some conditions to see whether to send or not, add to animation, or build a new animation, otherwise just changeState
        if([selectedAnimation caseInsensitiveCompare:PULSE_NAME]!=NSOrderedSame)
        {
            Animation* selected = [self getAnimationByName:selectedAnimation];
            if(isRecording)
            {
                if (selected!=nil)
                {
                    //add to selected animation
                    [selected.actions addObject:brightnessAction];
                    
                    Animation* current = [self getAnimationByName:currentAnimation];
                    BOOL currentRunning = NO;
                    if (current!=nil) {
                        currentRunning = current.isRunning;
                    }
                    if (!selected.isRunning && !currentRunning)
                    {
                        [self changeState:brightnessAction];
                        [self send:nil];
                    }
                }
                else {
                    //add to a new animation, select that animation
                    ///call javascript
                    [self changeState:brightnessAction];
                    [self send:nil];
                }
            }
            else {
                [self changeState:brightnessAction];
                [self send:nil];
            }
        }
    }
    return brightnessAction;
    
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
        if([(NSString*)i integerValue]>=[lights count])
        {
            NSLog(@"Light out of range");
            break;
        }
        else
        {
            Light* l = [lights objectAtIndex:[(NSString*)i integerValue]];
            [colorAction.targetChannels addObjectsFromArray:[self getColorChannels:l]];
            
            if ([color caseInsensitiveCompare:@"red"]==NSOrderedSame)
            {
                [self setColorHelper:colorAction.targetValues red:255 green:0 blue:0];        
            }
            else if ([color caseInsensitiveCompare:@"green"]==NSOrderedSame)
            {
                [self setColorHelper:colorAction.targetValues red:0 green:255 blue:0];
            }
            else if ([color caseInsensitiveCompare:@"blue"]==NSOrderedSame)
            {
                [self setColorHelper:colorAction.targetValues red:0 green:75 blue:255];        
            }
            else if ([color caseInsensitiveCompare:@"cyan"]==NSOrderedSame)
            {
                [self setColorHelper:colorAction.targetValues red:0 green:255 blue:255];        
            }
            else if ([color caseInsensitiveCompare:@"magenta"]==NSOrderedSame)
            {
                [self setColorHelper:colorAction.targetValues red:255 green:0 blue:255];        
            }
            else if ([color caseInsensitiveCompare:@"yellow"]==NSOrderedSame)
            {
                [self setColorHelper:colorAction.targetValues red:180 green:75 blue:0];        
            }
            else if ([color caseInsensitiveCompare:@"white"]==NSOrderedSame)
            {
                [self setColorHelper:colorAction.targetValues red:255 green:255 blue:255];        
            }
            else if ([color caseInsensitiveCompare:@"black"]==NSOrderedSame)
            {
                [self setColorHelper:colorAction.targetValues red:0 green:0 blue:0];        
            }
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

- (Action*) setColor:(NSString *)color selectString:(NSString*) selString selectAnimation:(NSString*)selectedAnimation 
{
    //NSLog(@"Setting color to %@", color);

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
                //[self setBrightness:[[NSNumber alloc] initWithInt:globalBrightness] selectString:selString selectAnimation:selectedAnimation];
            }
            
            Group* g;
            for(id d in groups)
            { 
                g = (Group*)d;
                if ([g.name caseInsensitiveCompare:(NSString*)[selectArray objectAtIndex:1]]==NSOrderedSame)
                {
                    //[self setBrightness:[[NSNumber alloc] initWithInt:g.brightness] selectString:selString selectAnimation:selectedAnimation];
                    break;
                }
            }
            NSMutableArray *lightArray = [[NSMutableArray alloc] initWithCapacity:([g.groupLights count])];
            for(id h in g.groupLights)
            {
                [lightArray addObject:h];
            }
            colorAction = [self buildColorAction:lightArray color:color];
            //[self displayState:colorAction];
            //[self displayState:g];
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
        if ([selectedAnimation caseInsensitiveCompare:CHASE_NAME]!=NSOrderedSame)
        {   
            Animation* selected = [self getAnimationByName:selectedAnimation];
            if(isRecording)
            {
                if (selected!=nil)
                {
                    //add to selected animation
                    [selected.actions addObject:colorAction];
                    
                    Animation* current = [self getAnimationByName:currentAnimation];
                    BOOL currentRunning = NO;
                    if (current!=nil) {
                        currentRunning = current.isRunning;
                    }
                    if (!selected.isRunning && !currentRunning)
                    {
                        [self changeState:colorAction];
                        [self send:nil];
                    }
                }
                else {
                    //add to a new animation, select that animation
                    //call javascript
                    [self changeState:colorAction];
                    [self send:nil];
                }
            }
            else {
                //NSLog(@"No animation selected still sending");
                [self changeState:colorAction];
                [self send:nil];
            }
        }
    }
    return colorAction;
}

- (Animation*)getAnimationByName:(NSString*)name
{
    if(name!=nil)
    {
        for(id a in animations)
        {
            Animation* target = (Animation*)a;
            if ([target.name caseInsensitiveCompare:name]==NSOrderedSame)
            {
                return target;
            }
        }
    }
    return nil;
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
    Animation* selected = [self getAnimationByName:currentAnimation];
    if(selected!=nil)
    {
        selected.isLooping = !selected.isLooping;
    }
}

- (void)setAnimationSpeed:(NSNumber *)speed
{
    Animation* a = [self getAnimationByName:currentAnimation];
    
    if(a!=nil && [a.actions count])
    {
        if([speed doubleValue] > 0)
        {
            a.timeBetweenSteps = speed;
        }
        for(id action in a.actions)
        {
            if([action isKindOfClass:[Animation class]] && ([((Animation*)action).name caseInsensitiveCompare:PULSE_NAME]==NSOrderedSame))
            {
                //get high and low values, call pulseActions and replace previous actions
                [((Animation*)action).actions removeAllObjects];
                ((Animation*)action).actions = [self pulseActions:((Animation*)action).selectedLights lowValue:((Animation*)action).lowValue highValue:((Animation*)action).highValue time:a.timeBetweenSteps];
            }
        }
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

- (void)clearCurrentAnimationActions:(NSString *)selectedAnimation
{
    Animation* selected = [self getAnimationByName:selectedAnimation];
    selected.isRunning = NO;
    [selected.actions setArray:[[NSMutableArray alloc] initWithCapacity:10]];
	[webView stringByEvaluatingJavaScriptFromString:@"deactivatePlaying();"];
}

- (void) setButtonAction:(NSNumber*)button action:(NSString*)a
{
    switch ([button intValue]) {
        case 1:
            button1 = [[NSString alloc] initWithString:a];
            break;
        case 2:
            button2 = [[NSString alloc] initWithString:a];
            break;
        case 3:
            button3 = [[NSString alloc] initWithString:a];
            break;
        default:
            break;
    }
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

- (Action *)diffChannels:(NSMutableArray*)a with:(NSMutableArray*)b
{
    Action* diff = [[Action alloc] initWithDetails:@"DIFF" numChans:3];
    
    for(int i = 0; i < [channels count]; i++)
    {
        if(((Channel*)[b objectAtIndex:i]).value != ((Channel*)[a objectAtIndex:i]).value)
        {
            [diff.targetChannels addObject:[[NSNumber alloc] initWithInt:((Channel*)[a objectAtIndex:i]).address]];
            [diff.targetValues addObject:[[NSNumber alloc] initWithInt:(((Channel*)[a objectAtIndex:i]).value)]];
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

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    [webView stringByEvaluatingJavaScriptFromString:@"changeDisplay('center', 1);"]; 
    [webView stringByEvaluatingJavaScriptFromString:@"addAnimationWithName('Pulse');"]; 
    [webView stringByEvaluatingJavaScriptFromString:@"$(\"select\").blur();"];
    [webView stringByEvaluatingJavaScriptFromString:@"$('#groupList > .lightGroup[name=\"all\"]').addClass('selected');"];
    
    [self startServer];
}

#pragma mark Networking
- (void)connectionReceived:(NSNotification *)aNotification 
{
    NSFileHandle *incomingConnection = [[aNotification userInfo] objectForKey:NSFileHandleNotificationFileHandleItem];
	
    [[aNotification object] acceptConnectionInBackgroundAndNotify];
	
    NSData *receivedData = [incomingConnection availableData];
    NSString* receivedString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    if ([[receivedString componentsSeparatedByString:@","] count] == 2) {
        NSString* color = [[receivedString componentsSeparatedByString:@","] objectAtIndex:1];
        [self setColor:color selectString:@"g,all" selectAnimation:@""];
    }
    else if([receivedString caseInsensitiveCompare:PULSE_NAME]==NSOrderedSame)
    {
        NSLog(@"Pulse");
        [self pulseActions:@"g,all" lowValue:(NSNumber*)[webView stringByEvaluatingJavaScriptFromString:@"displayValue('left');"]
                 highValue:(NSNumber*)[webView stringByEvaluatingJavaScriptFromString:@"displayValue('right');"]
                      time:(NSNumber*)[webView stringByEvaluatingJavaScriptFromString:@"$('#animationSpeedInput').attr('value');"]];
    }
    else {
        NSString* speedString = [[NSString alloc] initWithFormat:@"setAnimationSpeedInputText('%@');",receivedString];
        NSLog(@"%@", speedString);
        [webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:speedString waitUntilDone:NO];
        [self setAnimationSpeed:[[NSNumber alloc] initWithDouble:[receivedString doubleValue]]];
    }

    [incomingConnection closeFile];
}

-(void) startServer
{
	uint16_t chosenPort = 0;
    
    if(!listeningSocket) {
        // Here, create the socket from traditional BSD socket calls, and then set up an NSFileHandle with that to listen for incoming connections.
        int fdForListening;
        struct sockaddr_in serverAddress;
        socklen_t namelen = sizeof(serverAddress);
		
        // In order to use NSFileHandle's acceptConnectionInBackgroundAndNotify method, we need to create a file descriptor that is itself a socket, bind that socket, and then set it up for listening. At this point, it's ready to be handed off to acceptConnectionInBackgroundAndNotify.
        if((fdForListening = socket(AF_INET, SOCK_STREAM, 0)) > 0) {
            memset(&serverAddress, 0, sizeof(serverAddress));
            serverAddress.sin_family = AF_INET;
            serverAddress.sin_addr.s_addr = htonl(INADDR_ANY);
            serverAddress.sin_port = 0; // allows the kernel to choose the port for us.
			
            if(bind(fdForListening, (struct sockaddr *)&serverAddress, sizeof(serverAddress)) < 0) {
                close(fdForListening);
                return;
            }
			
            // Find out what port number was chosen for us.
            if(getsockname(fdForListening, (struct sockaddr *)&serverAddress, &namelen) < 0) {
                close(fdForListening);
                return;
            }
			
            chosenPort = ntohs(serverAddress.sin_port);
            
            if(listen(fdForListening, 1) == 0) {
                listeningSocket = [[NSFileHandle alloc] initWithFileDescriptor:fdForListening closeOnDealloc:YES];
            }
        }
    }
    
    if(!netService) {
        // lazily instantiate the NSNetService object that will advertise on our behalf.
        SCDynamicStoreContext context = { 0, NULL, NULL, NULL };
        SCDynamicStoreRef store = SCDynamicStoreCreate(kCFAllocatorDefault, CFSTR("testStrings"), NULL, &context);
        NSString* name = (NSString*)SCDynamicStoreCopyLocalHostName(store);
        netService = [[NSNetService alloc] initWithDomain:@"" type:@"_lightctrl._tcp." name:name port:chosenPort];
        [netService setDelegate:self];
    }
    
    if(netService && listeningSocket) {
        if(!serviceStarted) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionReceived:) name:NSFileHandleConnectionAcceptedNotification object:listeningSocket];
            [listeningSocket acceptConnectionInBackgroundAndNotify];
            [netService publish];
			serviceStarted = YES;
			
        } else {
            [netService stop];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleConnectionAcceptedNotification object:listeningSocket];
            // There is at present no way to get an NSFileHandle to -stop- listening for events, so we'll just have to tear it down and recreate it the next time we need it.
            [listeningSocket release];
            listeningSocket = nil;
			serviceStarted = NO;
        }
    }
	
}



@end

