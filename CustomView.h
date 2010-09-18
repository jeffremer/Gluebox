//
//  CustomView.h
//  NSStatusItemTest
//
//  Created by Matt Gemmell on 04/03/2008.
//  Copyright 2008 Magic Aubergine. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GlueboxAppDelegate;
@interface CustomView : NSView {
    __weak GlueboxAppDelegate *controller;
    BOOL clicked;
	BOOL draggedOver;
}

- (id)initWithFrame:(NSRect)frame controller:(GlueboxAppDelegate *)ctrlr;
- (id)toggleAttachedWindow;
- (id)reset;
@end
