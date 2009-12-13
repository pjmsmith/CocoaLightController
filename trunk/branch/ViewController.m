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
    
    lights = [[NSMutableArray alloc] initWithCapacity:0];
    
    testAnimation = [[Animation alloc] initWithDetails:@"testAnimation" isLooping:NO time:0.5];
    //[self addLight:@"newLight" numChans:[[NSNumber alloc] initWithInt:7] newLabels:@"a,b,c,d,e,f,g"];
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
        for(Light* l in lights)
        {
            [l sendState:port]; 
        }
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
	}
	
	- (void)didRemovePorts:(NSNotification *)theNotification
	{
		NSLog(@"A port was removed");
		[self listDevices];
	}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
    // For security, you must explicitly allow a selector to be called from JavaScript.
    
    if (aSelector == @selector(showMessage:)) {
        return NO; // i.e. showMessage: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(setColor:)) {
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
    if (aSelector == @selector(setBrightness:)) {
        return NO; // i.e. setBrightness: is NOT _excluded_ from scripting, so it can be called.
    }
    if (aSelector == @selector(addLight:)) {
        return NO; // i.e. addLight: is NOT _excluded_ from scripting, so it can be called.
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

- (void) addLight:(NSString *)name numChans:(NSNumber *)numberOfChans newLabels:(NSString *)labels
{
    NSInteger newAddr = 1;
    if([lights count])
    {
        Light *lastLight = (Light*)[lights objectAtIndex:([lights count]-1)];
        newAddr = [lastLight.startingAddress intValue] + [lastLight.sizeOfBlock intValue];
    }
    Light *newLight = [[Light alloc] initWithDetails:name size:numberOfChans address:[[NSNumber alloc] initWithInt:newAddr]];

    //change channel labels
    NSArray *labelArray = [labels componentsSeparatedByString:@","];
    NSInteger i = 0;
    for (Channel* c in newLight.channels)
    {
        c.label = [labelArray objectAtIndex:i];
        i++;
    }
    ((Channel*)[newLight.channels objectAtIndex:6]).value = 255; //change this to reference the global brightness

    
    [lights addObject:newLight];
}

- (void) runAnimation:(NSString*) run //string is arbitrary
{
    testAnimation.isRunning = !testAnimation.isRunning;
    if(testAnimation.isRunning && [testAnimation.actions count])
    {
        
        [self performSelectorInBackground:@selector(threadedRunAnimation:) withObject:0];
        
    }
    else {
        printf("animation already running\n");
    }

    
}

- (void) threadedRunAnimation:(NSNumber*) startActionIndex
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(testAnimation.isRunning && [testAnimation.actions count])
    {
        NSArray *immutableActionList = [[NSArray alloc] initWithArray:testAnimation.actions];
        for(int i = 0; i < [immutableActionList count]; i++)        {
            for(Light* l in lights) 
            {
                l.currentAction = (Action*)[immutableActionList objectAtIndex:i];
                
                [l applyAction];
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
            [self send:NULL];
            usleep((int)([testAnimation.timeBetweenSteps doubleValue]*1000000)); //timeInBetweenSteps
        }
        if (testAnimation.isLooping && !black_out)
        {
            [self threadedRunAnimation:0];
        }
        [immutableActionList dealloc];
    }
    [pool release];
}

- (void) setBrightness:(NSNumber*)brightness
{
    Action* tempAction = [Action alloc];
    [tempAction initWithDetails:@"" numChans:1];
    
    [tempAction.targetChannels addObject:[[NSNumber alloc] initWithInt:([testLight.startingAddress intValue]+6)]];
    [tempAction.targetValues addObject:brightness];
    testLight.currentAction = tempAction;
    [testLight applyAction];
    [testLight displayState];
    if (!testAnimation.isRunning) {
        [self send:NULL];
    }
}

- (void) setColor:(NSString *)color
{
    Action* tempAction = [Action alloc];
    NSLog(@"%@", color);
    [tempAction initWithDetails:@"" numChans:3];
    
    [tempAction.targetChannels addObject:[[NSNumber alloc] initWithInt:([testLight.startingAddress intValue])]];
    [tempAction.targetChannels addObject:[[NSNumber alloc] initWithInt:([testLight.startingAddress intValue]+1)]];
    [tempAction.targetChannels addObject:[[NSNumber alloc] initWithInt:([testLight.startingAddress intValue]+2)]];

    if ([color isEqualToString:@"red"])
    {
        [self setColorHelper:tempAction.targetValues red:255 green:0 blue:0];        
    }
    else if ([color isEqualToString:@"green"])

    {
        [self setColorHelper:tempAction.targetValues red:0 green:255 blue:0];
    }
    else if ([color isEqualToString:@"blue"])

    {
        [self setColorHelper:tempAction.targetValues red:0 green:75 blue:255];        

    }
    else if ([color isEqualToString:@"cyan"])
    {
        [self setColorHelper:tempAction.targetValues red:0 green:255 blue:255];        

    }
    else if ([color isEqualToString:@"magenta"])
    {
        [self setColorHelper:tempAction.targetValues red:255 green:0 blue:255];        

    }
    else if ([color isEqualToString:@"yellow"])
    {
        [self setColorHelper:tempAction.targetValues red:180 green:75 blue:0];        
    }
    
    for(Light* l in lights)
    {
        testLight.currentAction = tempAction;
        [testLight applyAction];
        [testLight displayState];
    }
    if (isRecording)
    {
        [testAnimation.actions addObject:tempAction];
    }
    if (!testAnimation.isRunning) {
        [self send:NULL];
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
    testAnimation.isLooping = !testAnimation.isLooping;
}

- (void) setAnimationSpeed:(NSNumber *)speed
{
    if([speed doubleValue] > 0)
    {
        testAnimation.timeBetweenSteps = speed;
    }
}

- (void)blackout:(NSString *)black
{
    testAnimation.isRunning = NO;
    black_out = YES;
    Action* tempAction = [Action alloc];
    [tempAction initWithDetails:@"" numChans:3];

    [tempAction.targetChannels addObject:[[NSNumber alloc] initWithInt:([testLight.startingAddress intValue])]];
    [tempAction.targetChannels addObject:[[NSNumber alloc] initWithInt:([testLight.startingAddress intValue]+1)]];
    [tempAction.targetChannels addObject:[[NSNumber alloc] initWithInt:([testLight.startingAddress intValue]+2)]];
    
    [self setColorHelper:tempAction.targetValues red:0 green:0 blue:0];
    
    Action* recoverAction = testLight.currentAction;
    testLight.currentAction = tempAction;
    [testLight applyAction];
    [self send:NULL];
    testLight.currentAction = recoverAction;
}

- (void)recover:(NSString *)r
{
    black_out = NO;
    [self runAnimation:@""];    
    [testLight applyAction];
    [self send:NULL];
}

- (void)clearCurrentAnimationActions:(NSString *)c
{
    Action* tempAction = [Action alloc];
    testAnimation.isRunning = NO;
    [tempAction initWithDetails:@"" numChans:3];
    [tempAction.targetChannels addObject:[[NSNumber alloc] initWithInt:([testLight.startingAddress intValue])]];
    [tempAction.targetChannels addObject:[[NSNumber alloc] initWithInt:([testLight.startingAddress intValue]+1)]];
    [tempAction.targetChannels addObject:[[NSNumber alloc] initWithInt:([testLight.startingAddress intValue]+2)]];
    
    [self setColorHelper:tempAction.targetValues red:0 green:0 blue:0];
    
    testLight.currentAction = tempAction;
    [testLight applyAction];
    [self send:NULL];
    
    [testAnimation.actions setArray:[[NSMutableArray alloc] initWithCapacity:10]];
	
	[webView stringByEvaluatingJavaScriptFromString:@"deactivatePlaying();"];
}

- (void)showMessage:(NSString *)message
{
    // This method is called from the JavaScript "onClick" handler of the INPUT element 
    // in the HTML. This shows you how to have HTML form elements call Cocoa methods.
    
    NSRunAlertPanel(@"Message from JavaScript", message, nil, nil, nil);
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
