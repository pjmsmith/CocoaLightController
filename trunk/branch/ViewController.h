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
#import "Group.h"
#import <WebKit/WebKit.h>


@interface ViewController : NSObject {

	AMSerialPort *port;
    
    NSMutableArray* channels;
    NSMutableArray* stateChange;
    
    NSMutableArray* lights;
    NSMutableArray* groups;
    NSMutableArray* animations;

    NSMutableDictionary* lightNames;
    NSMutableDictionary* groupNames;
    NSMutableDictionary* animationNames;
    
    NSInteger globalBrightness;
    
    NSString* currentAnimation;
    
    BOOL black_out;
    BOOL isRecording;
    
    NSString* AUTO_NAME;
	
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
- (void)setColor:(NSString *)color selectString:(NSString*)selString selectAnimation:(NSString*)selectedAnimation;
- (void)firstAction:(NSString *)f;
- (void)nextAction:(NSString *)n;
- (void)prevAction:(NSString *)p;
- (void)runAnimation:(NSString *)run;
- (void)threadedRunAnimation:(NSNumber*)startActionIndex;
- (void)blackout:(NSString *)black;
- (void)recover:(NSString *)r;
- (void)toggleRecord:(NSString *)rec;
- (void)toggleLooping:(NSString *)l;
- (void)clearCurrentAnimationActions:(NSString *)selectedAnimations;
- (void)setBrightness:(NSNumber*)brightness selectString:(NSString*)selString selectAnimation:(NSString*)selectedAnimation;
- (NSString*)addGroup:(NSString *)name selected:(NSString *)selectLights;
- (NSString*)addAnimation:(NSString *)name;
- (NSString*)addName:(NSString *)name dict:(NSMutableDictionary *)names;
- (NSString*)addLight:(NSString *)name numChans:(NSNumber *)numberOfChans newLabels:(NSString *)labels;
- (void)addChannels:(NSNumber *)numberOfChans newLabels:(NSArray *)labelArray startingAddr:(NSInteger)addr;
- (void)appendToGroup:(NSString*)name selected:(NSString*)selectLights selectAnimation:(NSString*)selectedAnimation;
- (void)removeGroup:(NSString *)name;
- (void)removeAnimation:(NSString *)name;
- (void)removeLight:(NSNumber *)lightNumber;
- (void)removeLightFromGroup:(NSString*)name selected:(NSString*)selectLights;
- (void)setCurrentAnimation:(NSString*)selectedAnimation;
- (void)setAnimationSpeed:(NSNumber *)speed;

// WebView Methods
-(IBAction)makeTextLarger:(id)sender;
-(IBAction)makeTextSmaller:(id)sender;

//Helper methods
-(void)setColorHelper:(NSMutableArray *) valueList red:(int)r green:(int)g blue:(int)b;
-(NSString*)numberToTriple: (NSNumber*) num;
-(void)displayState:(id)d;
-(Action *)diffChannels;
-(void)changeState:(Action *)action;
-(void)applyState:(Action *)action;
-(NSMutableArray*)getColorChannels:(Light*)l;
-(NSMutableArray*)getBrightnessChannels:(Light*)l;
-(Action*)buildColorAction:(NSMutableArray*)lightArray color:(NSString*)color;
-(Action*)buildBrightnessAction:(NSMutableArray*)lightArray brightness:(NSNumber*)brightness;
-(Animation*)getAnimationByName:(NSString*)name;
- (void)pulse:(NSString*)selectedLights selectAnimation:(NSString*)selectedAnimation lowValue:(NSNumber*)lowVal highValue:(NSNumber*)highVal;


//@property (nonatomic, retain) IBOutlet NSPopUpButton *serialSelectMenu;
//@property (nonatomic, retain) IBOutlet NSTextField	 *textField;

@end