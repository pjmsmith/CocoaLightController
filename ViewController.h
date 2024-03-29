//
//  ViewController.h
//  ArduinoSerial
//
//  Created by Pat O'Keefe on 4/30/09.
//  Copyright 2009 POP - Pat OKeefe Productions. All rights reserved.
//
//	Portions of this code were derived from Andreas Mayer's work on AMSerialPort. 
//	AMSerialPort was absolutely necessary for the success of this project, and for
//	this, I thanks Andreas. This is just a glorified adaptation to present an interface
//	for the ambitious programmer and work well with Arduino serial messages.
//  
//	AMSerialPort is Copyright 2006 Andreas Mayer.
//


#import <Cocoa/Cocoa.h>
#import "AMSerialPort.h"
#import "Light.h"
#import <WebKit/WebKit.h>


@interface ViewController : NSObject {

	AMSerialPort *port;
	Light *testLight;
    Animation *testAnimation;
    BOOL black_out;
    BOOL isRecording;
	IBOutlet NSPopUpButton	*serialSelectMenu;
	IBOutlet NSTextField	*textField;
	IBOutlet NSButton		*connectButton, *sendButton,
                            *redButton, *blueButton, *greenButton;
	IBOutlet NSTextField	*serialScreenMessage;
	
	IBOutlet WebView *webView;


}

// Interface Methods
- (IBAction)attemptConnect:(id)sender;
- (IBAction)send:(id)sender;

// Serial Port Methods
- (AMSerialPort *)port;
- (void)setPort:(AMSerialPort *)newPort;
- (void)listDevices;
- (void)initPort;

// This method is called from JavaScript on the web page.
- (void)showMessage:(NSString *)message;
- (void)setColor:(NSString *)color;
- (void)runAnimation:(NSString *)run;
- (void)threadedRunAnimation;
- (void)blackout:(NSString *)black;
- (void)recover:(NSString *)r;
- (void)toggleRecord:(NSString *)rec;
- (void)toggleLooping:(NSString *)l;
- (void)clearCurrentAnimationActions:(NSString *)c;

// WebView Methods
-(IBAction)makeTextLarger:(id)sender;
-(IBAction)makeTextSmaller:(id)sender;

//Helper methods
-(void)setColorHelper:(NSMutableArray *) valueList red:(int)r green:(int)g blue:(int)b;

//@property (nonatomic, retain) IBOutlet NSPopUpButton *serialSelectMenu;
//@property (nonatomic, retain) IBOutlet NSTextField	 *textField;

@end