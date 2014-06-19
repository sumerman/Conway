//
//  CWGrid.h
//  Conway
//
//  Created by Valery Meleshkin on 18/06/14.
//  Copyright (c) 2014 Valery Meleshkin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CWCoord.h"

typedef BOOL(^CWGridUpdBlock)(CWCoord *, BOOL);

@interface CWGrid : NSObject {
    NSMutableDictionary *_coord2v;
}

- (NSData *)encode;
+ (CWGrid *)gridWithData:(NSData *)d;
- (BOOL)atI:(COORD_INT)i J:(COORD_INT)j;
- (void)set:(BOOL)val atI:(COORD_INT)i J:(COORD_INT)j;
- (void)enumerateObjectsUsingBlock:(CWGridUpdBlock)blok;
- (void)clean;

@end
