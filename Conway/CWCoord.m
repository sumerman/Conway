//
//  CW.m
//  Conway
//
//  Created by Valery Meleshkin on 18/06/14.
//  Copyright (c) 2014 Valery Meleshkin. All rights reserved.
//

#import "CWCoord.h"

@implementation CWCoord

@synthesize i=_i, j=_j;

+ (COORD_INT)max {
    return INT64_MAX;
}

+ (COORD_INT)min {
    return INT64_MIN;
}

-(instancetype)initWithI:(COORD_INT) anI J:(COORD_INT) aJ {
    self = [super init];
    if (!self) return nil;
    
    _i = anI;
    _j = aJ;
    
    return self;
}

- (id)init {
    return [self initWithI:0 J:0];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(%llu,%llu)", self.i, self.j];
}

- (NSUInteger)hash {
    return _i << sizeof(_i) / 2 | _j;
}

- (void)enumerateNeighboursWithBlock:(void (^)(COORD_INT ni, COORD_INT nj))block {
    COORD_INT i1 = 0, j1 = 0;
    for (int di = -1; di < 2; ++di) {
        for (int dj = -1; dj < 2; ++dj) {
            i1 = _i+di;
            j1 = _j+dj;
            if (i1 == _i && j1 == _j) continue;
            block(i1, j1);
        }
    }
}

- (BOOL)isEqual:(__unsafe_unretained id)object {
    /*
    if (![object isMemberOfClass:[CWCoord class]]) {
        return NO;
    }
    */
    CWCoord *c = (CWCoord *)object;
    
    if (_i == c->_i && _j == c->_j) {
        return YES;
    }
    
    return NO;
}

- (id)copyWithZone:(NSZone *)zone {
    //MyObject *objectCopy = [[MyObject allocWithZone:zone] init];
    return self; // Coord is immutable
}

@end
