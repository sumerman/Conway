//
//  CWGirdView.h
//  Conway
//
//  Created by Valery Meleshkin on 18/06/14.
//  Copyright (c) 2014 Valery Meleshkin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CWGrid.h"

@protocol CWGridViewProvider <NSObject>

- (CWGrid *)grid;

@end

@interface CWGridView : NSView

@property (assign) IBOutlet id<CWGridViewProvider> gridProvider;
@property (assign) CGFloat i0;
@property (assign) CGFloat j0;
@property (assign) CGFloat zoom;

@end
