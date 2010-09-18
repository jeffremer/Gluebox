//
//  GlueboxAppDelegate.h
//  Gluebox
//
//  Created by Jeff Remer on 9/16/10.
//  Copyright 2010 Widgetbox, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MAAttachedWindow;
@class YRKSpinningProgressIndicator;
@class Note;

@interface GlueboxAppDelegate : NSObject <NSApplicationDelegate> {
}

@property (assign) MAAttachedWindow *attachedWindow;
@property (assign) IBOutlet NSView *mainView;
@property (assign) IBOutlet NSView *settingsView;
@property (assign) IBOutlet NSTextField *textField;
@property (assign) IBOutlet NSStatusItem *statusItem;
@property (assign) IBOutlet NSButton *saveButton;
@property (assign) IBOutlet NSSegmentedControl *actionSegments;
@property (assign) IBOutlet YRKSpinningProgressIndicator *progressBar;
@property (assign) NSMutableData *responseData;
@property (assign) Note *currentNote;

- (void)toggleAttachedWindowAtPoint:(NSPoint)pt withSender:(id)sender;
- (void)toggleActionSegments:(BOOL)Enabled;

- (IBAction) save:(id)sender;
- (IBAction) clear:(id)sender;
- (IBAction) open:(id)sender;

@end
