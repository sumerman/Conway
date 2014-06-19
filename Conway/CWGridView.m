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
        i0 = frame.size.width / 2 / zoom;
        j0 = frame.size.height / 2 / zoom;
        
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

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSRect bounds = [self bounds];
    
    NSColor *bg = [NSColor whiteColor];
    NSColor *fg = [NSColor blackColor];
    NSColor *ct = [NSColor redColor];
    
    NSGraphicsContext* theContext = [NSGraphicsContext currentContext];
    [theContext saveGraphicsState];
    
    [bg set];
    [NSBezierPath fillRect:bounds];
    
    [fg set];
    [[self.gridProvider grid] enumerateObjectsUsingBlock:^BOOL(COORD_INT i, COORD_INT j, BOOL val) {
        if (val) {
            NSRect cell = NSMakeRect((i + i0) * zoom, (j + j0) * zoom, zoom, zoom);
        
            if (NSContainsRect(bounds, cell) || NSIntersectsRect(bounds, cell)) {
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

- (void)scrollWheel:(NSEvent *)e
{
    COORD_INT i1 = i0, j1 = j0;
    i1 += (COORD_INT)truncf([e deltaX] * zoom);
    j1 -= (COORD_INT)truncf([e deltaY] * zoom);
    if (i1 >= COORD_INT_MIN / 2 && i1 < COORD_INT_MAX / 2) i0 = i1;
    if (j1 >= COORD_INT_MIN / 2 && j1 < COORD_INT_MAX / 2) j0 = j1;
    
    [self setNeedsDisplay:YES];
}

-(void)magnifyWithEvent:(NSEvent *)event
{
    self.zoom += [event magnification];
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event
{
    NSPoint p = [event locationInWindow];
    NSPoint downPoint = [self convertPoint:p fromView:nil];
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
    if (![sender isKindOfClass:[NSSegmentedControl class]]) return;
    NSSegmentedControl *segment = (NSSegmentedControl *)sender;
    CGFloat sign = -1 * (segment.selectedSegment == 0) + (segment.selectedSegment == 1);
    self.zoom += 0.5f*sign;
    [self setNeedsDisplay:YES];
}

@end
