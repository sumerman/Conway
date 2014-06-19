//
//  CWGirdView.m
//  Conway
//
//  Created by Valery Meleshkin on 18/06/14.
//  Copyright (c) 2014 Valery Meleshkin. All rights reserved.
//

#import "CWGridView.h"
#include "math.h"

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

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSRect bounds = [self bounds];
    
    NSColor *bg = [NSColor blackColor];
    NSColor *fg = [NSColor whiteColor];
    NSColor *ct = [NSColor redColor];
    
    NSGraphicsContext* theContext = [NSGraphicsContext currentContext];
    [theContext saveGraphicsState];
    
    [bg set];
    [NSBezierPath fillRect:bounds];
    
    [fg set];
    [[self.gridProvider grid] enumerateObjectsUsingBlock:^BOOL(CWCoord *c, BOOL val) {
        if (val) {
            COORD_INT i = c.i, j = c.j;
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
    CGFloat i1 = i0, j1 = j0;
    i1 += truncf([e deltaX]);
    j1 -= truncf([e deltaY]);
    if (i1 >= [CWCoord min] && i1 < [CWCoord max]) i0 = i1;
    if (j1 >= [CWCoord min] && j1 < [CWCoord max]) j0 = j1;
    
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event
{
    NSPoint p = [event locationInWindow];
    NSPoint downPoint = [self convertPoint:p fromView:nil];
    COORD_INT i = truncf(downPoint.x / zoom) - i0;
    COORD_INT j = truncf(downPoint.y / zoom) - j0;
    
    BOOL val = [[self.gridProvider grid] atI:i J:j];
    val = !val;
    [[self.gridProvider grid] set:val atI:i J:j];
    
    [self setNeedsDisplay:YES];
}

- (void) mouseDragged:(NSEvent *)event
{
    [self mouseDown:event];
}

@end
