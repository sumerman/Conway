//
//  CWAppDelegate.m
//  Conway
//
//  Created by Valery Meleshkin on 18/06/14.
//  Copyright (c) 2014 Valery Meleshkin. All rights reserved.
//

#import "CWAppDelegate.h"


void CWFileAlert(NSString *msg) {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = msg;
    alert.alertStyle = NSWarningAlertStyle;
    [alert runModal];
}

@implementation CWAppDelegate

@synthesize grid, gridView, updateInterval;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    srandom((unsigned int)time(NULL));
    if (!grid) {
        grid = [CWGrid grid];
    }
    self.updateInterval = [NSNumber numberWithInt:20];
    _updTimer = nil;
    self.window.styleMask |= NSFullSizeContentViewWindowMask;
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.delegate = self;
    [gridView setNeedsDisplay:YES];
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
    NSData *d = [NSData dataWithContentsOfFile:filename];
    if (!d) return NO;
    grid = [CWGrid gridWithData:d];
    return YES;
}

- (NSApplicationPresentationOptions)window:(NSWindow *)window willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions
{
    return (NSApplicationPresentationFullScreen |
            NSApplicationPresentationAutoHideDock |
            NSApplicationPresentationAutoHideMenuBar |
            NSApplicationPresentationAutoHideToolbar);
}

- (void)setUpdateInterval:(NSNumber *)anUpdateInterval {
    if (anUpdateInterval.intValue < 1) return;
    if (anUpdateInterval.intValue > 100) return;
    self->updateInterval = anUpdateInterval;
    if (_updTimer) {
        [self start:self];
    }
}

- (IBAction)start:(id)sender
{
    [self stop:sender];
    _updTimer = [NSTimer scheduledTimerWithTimeInterval: self.updateInterval.floatValue / 100
                                                 target: self
                                               selector: @selector(timerFired:)
                                               userInfo: nil
                                                repeats: YES];
}

- (IBAction)stop:(id)sender
{
    [_updTimer invalidate];
    _updTimer = nil;
}

- (IBAction)clean:(id)sender {
    [grid clean];
    [self stop:self];
    [self updateGrid];
}

- (void)timerFired:(id)sender
{
    [self updateGrid];
}

- (void)updateGrid
{
    [self.grid enumerateObjectsUsingBlock:^BOOL(COORD_INT i, COORD_INT j, BOOL val) {
        __block NSUInteger aliveNeighbours = 0;
        __block CWGrid *sgrid = self.grid;
        CWEnumerateNeighbours(i, j, ^(COORD_INT ni, COORD_INT nj) {
            if ([sgrid atI:ni J:nj]) {
                ++aliveNeighbours;
            }
        });
        if (aliveNeighbours < 2) return NO;
        if (aliveNeighbours > 3) return NO;
        if (!val && aliveNeighbours == 3) return YES;
        return val;
    }];
    [gridView setNeedsDisplay:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (IBAction)faster:(id)sender {
    self.updateInterval = [NSNumber numberWithInt:self.updateInterval.intValue - 10];
}
- (IBAction)slower:(id)sender {
    self.updateInterval = [NSNumber numberWithInt:self.updateInterval.intValue + 10];
}

- (IBAction)newRandom:(id)sender {
    COORD_INT side = random() % 100;
    for (COORD_INT i = -side; i < side; ++i)
        for (COORD_INT j = -side; j < side; ++j) {
            BOOL v = (random() % 10) > 7;
            [self.grid set:v atI:i J:j];
        }    
}

- (IBAction)showSavePanel:(id)sender
{
    NSSavePanel * savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:@[FILE_TYPE]];
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [savePanel orderOut:self];
            if (![[self.grid encode] writeToURL:savePanel.URL atomically:YES]) {
                CWFileAlert(@"Unable to save file");
            }
        }
    }];
}

- (IBAction)showOpenPanel:(id)sender
{
    __block typeof(self) Self = self;
    NSSavePanel * openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowedFileTypes:@[FILE_TYPE]];
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [openPanel orderOut:self];
            NSData *data = [NSData dataWithContentsOfURL:openPanel.URL];
            if (!data) {
                CWFileAlert(@"Unable to load file");
                return;
            }
            Self.grid = [CWGrid gridWithData:data];
            [Self.gridView setNeedsDisplay:YES];
        }
    }];
}

@end
