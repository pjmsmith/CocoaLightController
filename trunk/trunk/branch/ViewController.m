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
    testLight = [[Light alloc] initWithDetails:@"newLight" size:[[NSNumber alloc] initWithInt:3] address:[[NSNumber alloc] initWithInt:1]];
    testAnimation = [[Animation alloc] initWithDetails:@"testAnimation" isLooping:YES time:1];
    [[testLight.channels objectAtIndex:0] setLabel:@"RED"];
    [[testLight.channels objectAtIndex:1] setLabel:@"GREEN"];
    [[testLight.channels objectAtIndex:2] setLabel:@"BLUE"];

    black_out = NO;
    isRecording = NO;
    testAnimation.isLooping = NO;
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
			[textField setStringValue:receivedText];			
			
			//TODO: Do something meaningful with the data...
			
			//Typically, I arrange my serial messages coming from the Arduino in chunks, with the
			//data being separated by a comma or semicolon. If you're doing something similar, a 
			//variant of the following command is invaluable. 
			
			//NSArray *dataArray = [receivedText componentsSeparatedByString:@","];

			
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
        [testLight sendState:port]; 
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
    return YES; // disallow everything else
}

- (void) runAnimation:(NSString*) run //string is arbitrary
{
    testAnimation.isRunning = !testAnimation.isRunning;
    if(testAnimation.isRunning && [testAnimation.actions count])
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [self performSelectorInBackground:@selector(threadedRunAnimation) withObject:nil];
        [pool release];
    }
    else {
        printf("animation already running\n");
    }

    
}

- (void) threadedRunAnimation
{
    if(testAnimation.isRunning && [testAnimation.actions count])
    {
        NSArray *immutableActionList = [[NSArray alloc] initWithArray:testAnimation.actions];
        for(id a in immutableActionList)
        {
            testLight.currentAction = (Action*)a;
            [testLight applyAction];
            if(black_out || !testAnimation.isRunning || [testAnimation.actions count] == 0)
            {
                
                break;
            }
            [self send:NULL];
            usleep((int)([testAnimation.timeBetweenSteps doubleValue]*1000000)); //timeInBetweenSteps
        }
        if (testAnimation.isLooping && !black_out)
        {
            [self threadedRunAnimation];
        }
        [immutableActionList dealloc];
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
    testLight.currentAction = tempAction;
    if (isRecording)
    {
        [testAnimation.actions addObject:tempAction];
    }
    [testLight displayState];
    [testLight applyAction];
    [testLight displayState];
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
    testAnimation.timeBetweenSteps = speed;
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
