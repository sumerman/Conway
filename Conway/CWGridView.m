//
//  CWGirdView.m
//  Conway
//
//  Created by Valery Meleshkin on 18/06/14.
//  Copyright (c) 2014 Valery Meleshkin. All rights reserved.
//

#import "CWGridView.h"
#include <math.h>

@implementation CWGridView

@synthesize gridProvider, i0, j0, zoom;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        zoom = 4.0f;
        i0 = 0;
        j0 = 0;
        
    }
    return self;
}

- (void)setZoom:(CGFloat)z {
    if (z < 0.5f) {
        zoom = 0.5f;
    }
    else {
        zoom = z;
    }
}

- (NSAffineTransform *)centeringTransform {
    NSRect bounds = self.bounds;
    NSAffineTransform* xform = [NSAffineTransform transform];
    [xform translateXBy:bounds.size.width / 2 yBy:bounds.size.height / 2];
    
    return xform;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSRect bounds = self.bounds;
    
    NSColor *bg = [NSColor whiteColor];
    NSColor *fg = [NSColor blackColor];
    NSColor *ct = [NSColor redColor];
    
    NSGraphicsContext* theContext = [NSGraphicsContext currentContext];
    [theContext saveGraphicsState];
    
    [bg set];
    [NSBezierPath fillRect:bounds];
    
    NSAffineTransform* xform = [self centeringTransform];
    [xform concat];
    
    [fg set];
    [[self.gridProvider grid] enumerateObjectsUsingBlock:^BOOL(COORD_INT i, COORD_INT j, BOOL val) {
        if (val) {
            NSRect cell = NSMakeRect((i + i0) * zoom, (j + j0) * zoom, zoom, zoom);
            NSRect clipCell = cell;
            clipCell.origin = [xform transformPoint:clipCell.origin];
            clipCell.size = [xform transformSize:clipCell.size];
        
            if (NSContainsRect(bounds, clipCell) || NSIntersectsRect(bounds, clipCell)) {
                [NSBezierPath fillRect:cell];
            }
        }
        return val;
    }];
    
    [ct set];
    NSRect ctr = NSMakeRect(i0 * zoom, j0 * zoom, zoom, zoom);
    [NSBezierPath fillRect:ctr];
    
    [theContext restoreGraphicsState];
}

- (void) scrollDx:(CGFloat)dx Dy:(CGFloat)dy {
    COORD_INT i1 = i0, j1 = j0;
    i1 += (COORD_INT)truncf(dx * zoom);
    j1 -= (COORD_INT)truncf(dy * zoom);
    if (i1 >= COORD_INT_MIN / 2 && i1 < COORD_INT_MAX / 2) i0 = i1;
    if (j1 >= COORD_INT_MIN / 2 && j1 < COORD_INT_MAX / 2) j0 = j1;
    
    [self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)e
{
    NSString *arr = [e charactersIgnoringModifiers];
    unichar keyChar = 0;
    if ([arr length] == 0) {
        [super keyDown:e];
        return;
    }
    if ([arr length] == 1) {
        keyChar = [arr characterAtIndex:0];
        if (keyChar == NSLeftArrowFunctionKey) {
            [self scrollDx:5.0f/zoom Dy:0.0f];
        } else if (keyChar == NSRightArrowFunctionKey) {
            [self scrollDx:-5.0f/zoom Dy:0.0f];
        } else if (keyChar == NSUpArrowFunctionKey) {
            [self scrollDx:0.0f Dy:5.0f/zoom];
        } else if (keyChar == NSDownArrowFunctionKey) {
            [self scrollDx:0.0f Dy:-5.0f/zoom];
        } else {
            [super keyDown:e];
        }
    }
}

- (void)scrollWheel:(NSEvent *)e
{
    [self scrollDx:[e deltaX] Dy:[e deltaY]];
}

- (void)magnifyWithEvent:(NSEvent *)event
{
    self.zoom += [event magnification];
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event
{
    NSAffineTransform* xform = [self centeringTransform];
    [xform invert];
    NSPoint p = [event locationInWindow];
    NSPoint downPoint = [xform transformPoint:[self convertPoint:p fromView:nil]];
    COORD_INT i = (COORD_INT)truncf(downPoint.x / zoom) - i0;
    COORD_INT j = (COORD_INT)truncf(downPoint.y / zoom) - j0;
    
    BOOL val = [[self.gridProvider grid] atI:i J:j];
    val = !val;
    [[self.gridProvider grid] set:val atI:i J:j];
    
    [self setNeedsDisplay:YES];
}

- (void) mouseDragged:(NSEvent *)event
{
    [self mouseDown:event];
}

- (IBAction) stepZoom:(id)sender {
    NSInteger tag = -1;
    if ([sender isKindOfClass:[NSSegmentedControl class]]) {
        NSSegmentedControl *segment = (NSSegmentedControl *)sender;
        tag = segment.selectedSegment;
    } else if ([sender respondsToSelector:@selector(tag)]) {
        tag = [sender tag];
    }
    CGFloat sign = -1 * (tag == 0) + (tag > 0);
    self.zoom += 0.5f*sign;
    [self setNeedsDisplay:YES];
}

@end
