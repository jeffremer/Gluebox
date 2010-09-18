//
//  GlueboxAppDelegate.m
//  Gluebox
//
//  Created by Jeff Remer on 9/16/10.
//  Copyright 2010 Widgetbox, Inc. All rights reserved.
//

#import "GlueboxAppDelegate.h"
#import "CustomView.h"
#import "MAAttachedWindow.h"
#import "YRKSpinningProgressIndicator.h"
#import "JSON.h"
#import "Note.h"

@implementation GlueboxAppDelegate

#pragma mark -
#pragma mark Properties

@synthesize attachedWindow;
@synthesize	mainView;
@synthesize settingsView;
@synthesize	textField;
@synthesize	saveButton;
@synthesize	actionSegments;
@synthesize	progressBar;
@synthesize	statusItem;
@synthesize	responseData;
@synthesize	currentNote;

#pragma mark -
#pragma mark App Delegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

- (void)awakeFromNib {
	float width = 30.0;
	float height = [[NSStatusBar systemStatusBar] thickness];
	NSRect viewFrame = NSMakeRect(0, 0, width, height);
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:width];
	[statusItem setView:[[CustomView alloc] initWithFrame:viewFrame controller: self]];
	[self.progressBar setForeColor:[NSColor whiteColor]];
}

#pragma mark -
#pragma mark Save Button

- (IBAction) save:(id)sender {
	if(!self.currentNote) {
		NSLog(@"Creating new note");
		self.currentNote = [[[Note alloc] init] retain];
		self.currentNote.key = @"";
		self.currentNote.secret = @"";
	}
	NSLog(@"Setting note value");	
	self.currentNote.note = [self.textField stringValue];

	[sender setEnabled:NO];
	[self toggleActionSegments:NO];
	[self.progressBar setHidden:NO];
	[self.progressBar startAnimation:self];
	
	// Save note
	NSString *params = [NSString stringWithFormat:@"key=%@&secret=%@&note=%@", 
						self.currentNote.key, 
						self.currentNote.secret, 
						[self.currentNote.note stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	
	NSString *url = [NSString stringWithFormat:@"http://cmdv.me/write?%@",params];
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
	
	NSURLConnection *connectionResponse = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	
	if (!connectionResponse) {
		NSLog(@"Failed to submit request");
	} else {
		NSLog(@"Request submitted");
		responseData = [[NSMutableData alloc] init];
	}
}

#pragma mark -
#pragma mark Clear Button

- (IBAction) clear:(id)sender {
	self.currentNote = nil;
	[self.textField setStringValue:@""];
}

#pragma mark -
#pragma mark Open Action Button Set

- (IBAction) open:(id)sender {
	NSInteger index = [sender selectedSegment];
	NSString *action = [[sender cell] toolTipForSegment:index];
	if([self respondsToSelector:NSSelectorFromString([action lowercaseString])]) {
		[self performSelector:NSSelectorFromString([action lowercaseString])];
	} else {
		NSLog(@"%@ not yet implemented", action);
	}
}

- (void) openUrl:(NSString *) URL {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:URL]];
	[attachedWindow orderOut:self];
	[attachedWindow release];
	attachedWindow = nil;
	[(CustomView *) [statusItem view] reset];	
}

- (void) edit {
	NSLog(@"Opening edit page, secret: %@, key: %@", self.currentNote.secret, self.currentNote.key);
	[self openUrl: [NSString stringWithFormat:@"http://cmdv.me/%@/%@", self.currentNote.secret, self.currentNote.key]];
}

- (void) share {
	NSLog(@"Opening edit page");
	[self openUrl: [NSString stringWithFormat:@"http://cmdv.me/note/%@", self.currentNote.key]];
}

- (void) raw {
	NSLog(@"Opening edit page");
	[self openUrl: [NSString stringWithFormat:@"http://cmdv.me/note/%@.raw", self.currentNote.key]];
}

- (void)toggleActionSegments:(BOOL)Enabled {
	int length = [self.actionSegments segmentCount], ix;
	for(ix = 0; ix < length; ix++) {
		[self.actionSegments setEnabled:Enabled forSegment:ix];
	}
}

#pragma mark -
#pragma mark Attached Window

- (void)toggleAttachedWindowAtPoint:(NSPoint)pt withSender:(id) sender {
	if (!attachedWindow) {
		attachedWindow = [[MAAttachedWindow alloc] initWithView:mainView 
												attachedToPoint:pt 
													   inWindow:nil 
														 onSide:MAPositionBottom 
													 atDistance:5.0];
		[attachedWindow setLevel:NSFloatingWindowLevel];
	}

	if(![attachedWindow isVisible]) {
		[attachedWindow makeKeyAndOrderFront:self];
	} else {
		[attachedWindow orderOut:self];
	}    
}
#pragma mark -
#pragma mark Note Downloader/Parser
- (void) parseResponse:(NSData *) data {
	NSLog(@"Parsing response: %@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	NSDictionary *json = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] JSONValue];
	
	if([json valueForKey:@"success"]) {		
		self.currentNote.key = [json valueForKey:@"key"];
		self.currentNote.secret = [json valueForKey:@"secret"];
		NSLog(@"Got response, secret: %@, key: %@", self.currentNote.secret, [json valueForKey:@"key"]);
	} else {
		NSLog(@"Problem saving note!");
	}
	
	[self.progressBar stopAnimation:self];
	[self.progressBar setHidden:YES];
	[self.saveButton setEnabled:YES];
	[self toggleActionSegments:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [connection release];
    [responseData release];
	NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self parseResponse: responseData];
    [connection release];
}

@end
