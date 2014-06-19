//
//  CWGrid.h
//  Conway
//
//  Created by Valery Meleshkin on 18/06/14.
//  Copyright (c) 2014 Valery Meleshkin. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <stdint.h>

typedef int64_t COORD_INT;
#define COORD_INT_MAX INT64_MAX
#define COORD_INT_MIN INT64_MIN

typedef BOOL(^CWGridUpdBlock)(COORD_INT i, COORD_INT j, BOOL);
typedef void (^CWEnumerateNeighboursBlock) (COORD_INT ni, COORD_INT nj);

#ifdef __cplusplus
extern "C" {
#endif

void CWEnumerateNeighbours(COORD_INT _i, COORD_INT _j,
                           CWEnumerateNeighboursBlock block);

@interface CWGrid : NSObject

- (NSData *)encode;
+ (id)gridWithData:(NSData *)d;
+ (id)grid;
- (BOOL)atI:(COORD_INT)i J:(COORD_INT)j;
- (void)set:(BOOL)val atI:(COORD_INT)i J:(COORD_INT)j;
- (void)enumerateObjectsUsingBlock:(CWGridUpdBlock)block;
- (void)clean;

@end

#ifdef __cplusplus
}
#endif
