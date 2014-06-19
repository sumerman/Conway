//
//  CWGrid.m
//  Conway
//
//  Created by Valery Meleshkin on 18/06/14.
//  Copyright (c) 2014 Valery Meleshkin. All rights reserved.
//

#import "CWGrid.h"

typedef struct _CWSerStruct {
    COORD_INT i, j;
    BOOL v;
} CWSerStruct;

void CWExecBlock(__unsafe_unretained CWCoord *c, BOOL val,
                 __unsafe_unretained NSMutableArray *inserts,
                 __unsafe_unretained NSMutableArray *deletes,
                 __unsafe_unretained CWGridUpdBlock block) {
    BOOL val1 = block(c, val);
    if (val == val1) return;
    if (val1) {
        [inserts addObject:c];
    } else {
        [deletes addObject:c];
    }
}

@implementation CWGrid

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    _coord2v = [NSMutableDictionary dictionary];
    
    return self;
}

- (NSString *)description {
    return [_coord2v description];
}

- (void)clean {
    [_coord2v removeAllObjects];
}

- (NSData *)encode {
    NSUInteger sz = [_coord2v count] * sizeof(CWSerStruct);
    NSMutableData *d = [NSMutableData dataWithCapacity:sz];
    [self enumerateObjectsUsingBlock:^(CWCoord *c, BOOL val) {
        if (val) {
            CWSerStruct s = { .i = c.i, .j = c.j, .v = val };
            [d appendBytes:&s length:sizeof(CWSerStruct)];
        }
        return val;
    }];
    return d;
}

+ (CWGrid *)gridWithData:(NSData *)d {
    CWGrid *grid = [[CWGrid alloc] init];
    CWSerStruct *bytes = (CWSerStruct *)[d bytes];
    NSUInteger len = [d length];
    for (; len >= sizeof(bytes); ++bytes, len -= sizeof(bytes)) {
        [grid set:bytes->v atI:bytes->i J:bytes->j];
    }
    return grid;
}

- (BOOL)atI:(COORD_INT)i J:(COORD_INT)j { //! may wrap coords on overflow
    CWCoord *c = [[CWCoord alloc] initWithI:i J:j];
    if ([_coord2v objectForKey:c]) {
        return YES;
    }
    return NO;
}

- (void)set:(BOOL)val atI:(COORD_INT)i J:(COORD_INT)j {
    CWCoord *c = [[CWCoord alloc] initWithI:i J:j];
    if (val) {
        [_coord2v setObject:[NSNull null] forKey:c];
    } else {
        [_coord2v removeObjectForKey:c];
    }
}

- (void)enumerateObjectsUsingBlock:(CWGridUpdBlock)block {
    @autoreleasepool {
        NSMutableArray *inserts = [NSMutableArray array];
        NSMutableArray *deletes = [NSMutableArray array];
        NSMutableArray *neighbours = [NSMutableArray array];
        [_coord2v enumerateKeysAndObjectsUsingBlock:^(CWCoord *c, id obj, BOOL *stop) {
            [c enumerateNeighboursWithBlock:^(COORD_INT i1, COORD_INT j1) {
                if (![self atI:i1 J:j1]) {
                    [neighbours addObject:[[CWCoord alloc] initWithI:i1 J:j1]];
                }
            }];
            BOOL val = obj != nil;
            CWExecBlock(c, val, inserts, deletes, block);
        }];
        [neighbours enumerateObjectsUsingBlock:^(CWCoord *c, NSUInteger idx, BOOL *stop) {
            CWExecBlock(c, NO, inserts, deletes, block);
        }];
        [deletes enumerateObjectsUsingBlock:^(CWCoord *c, NSUInteger idx, BOOL *stop) {
            [_coord2v removeObjectForKey:c];
        }];
        [inserts enumerateObjectsUsingBlock:^(CWCoord *c, NSUInteger idx, BOOL *stop) {
            [_coord2v setObject:[NSNull null] forKey:c];
        }];
    }
}


@end
