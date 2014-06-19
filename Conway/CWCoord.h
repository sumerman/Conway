//
//  CW.h
//  Conway
//
//  Created by Valery Meleshkin on 18/06/14.
//  Copyright (c) 2014 Valery Meleshkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdint.h>

typedef int64_t COORD_INT;

@interface CWCoord : NSObject <NSCopying> {
    @private
    COORD_INT _i;
    COORD_INT _j;
}

@property (atomic, readonly) COORD_INT i;
@property (atomic, readonly) COORD_INT j;

- (id)initWithI:(COORD_INT) anI J:(COORD_INT) aJ;
- (void)enumerateNeighboursWithBlock:(void (^)(COORD_INT ni, COORD_INT nj))block;

+ (COORD_INT)max;
+ (COORD_INT)min;



@end
