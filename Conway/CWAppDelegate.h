//
//  CWAppDelegate.h
//  Conway
//
//  Created by Valery Meleshkin on 18/06/14.
//  Copyright (c) 2014 Valery Meleshkin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CWGrid.h"
#import "CWGridView.h"

#define FILE_TYPE @"conway"

@interface CWAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, CWGridViewProvider> {
    @private
    NSTimer *_updTimer;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet CWGridView *gridView;
@property CWGrid *grid;

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;

- (IBAction)showSavePanel:(id)sender;
- (IBAction)showOpenPanel:(id)sender;

@end
