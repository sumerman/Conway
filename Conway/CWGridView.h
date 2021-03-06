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
@property (assign) COORD_INT i0;
@property (assign) COORD_INT j0;
@property (assign, nonatomic) CGFloat zoom;

- (IBAction) stepZoom:(id)sender;

@end
