//
//  CWGrid.mm
//  Conway
//
//  Created by Valery Meleshkin on 18/06/14.
//  Copyright (c) 2014 Valery Meleshkin. All rights reserved.
//

#import "CWGrid.h"

#include <unordered_set>
#include <vector>

typedef struct _CWCoordStruct {
    COORD_INT i, j;
    BOOL v;
    
    bool operator == (const _CWCoordStruct &rhs) const {
        return i == rhs.i && j == rhs.j;
    }
} CWCoordStruct;

typedef std::unordered_set<CWCoordStruct> coords_hash;
typedef std::vector<CWCoordStruct> ops_vec;

namespace std
{
    template<>
    struct hash<CWCoordStruct>
    {
        typedef CWCoordStruct argument_type;
        typedef std::size_t value_type;
        
        value_type operator()(argument_type const& s) const
        {
            return s.i << (sizeof(s.i) / 2) | s.j;
        }
    };
}

void CWEnumerateNeighbours(COORD_INT _i, COORD_INT _j,
                           CWEnumerateNeighboursBlock block) {
    COORD_INT i1 = 0, j1 = 0;
    for (COORD_INT di = -1; di < 2; ++di) {
        for (COORD_INT dj = -1; dj < 2; ++dj) {
            i1 = _i + di;
            j1 = _j + dj;
            if (i1 == _i && j1 == _j) continue;
            block(i1, j1);
        }
    }
}

void CWExecBlock(const CWCoordStruct &c,
                 ops_vec &inserts,
                 ops_vec &deletes,
                 __unsafe_unretained CWGridUpdBlock block) {
    BOOL val1 = block(c.i, c.j, c.v);
    if (c.v == val1) return;
    if (val1) {
        inserts.push_back(c);
    } else {
        deletes.push_back(c);
    }
}


@interface CWGridImpl : NSObject {
    coords_hash *_coord2p;
    NSMutableDictionary *_coord2v;
}
@end

@implementation CWGrid

+ (id)grid {
    return [[CWGridImpl alloc] init];
};

+ (instancetype)gridWithData:(NSData *)d {
    CWGrid *grid = [CWGrid grid];
    CWCoordStruct *bytes = (CWCoordStruct *)[d bytes];
    NSUInteger len = [d length];
    for (; len >= sizeof(bytes); ++bytes, len -= sizeof(bytes)) {
        [grid set:bytes->v atI:bytes->i J:bytes->j];
    }
    return grid;
}

- (NSData *)encode {
    return nil; //stub
}

- (BOOL)atI:(COORD_INT)i J:(COORD_INT)j {
    return NO; // stub
}

- (void)set:(BOOL)val atI:(COORD_INT)i J:(COORD_INT)j {
    // stub
}

- (void)enumerateObjectsUsingBlock:(CWGridUpdBlock)block {
    // stub
}

- (void)clean {
    // stub
}

@end

@implementation CWGridImpl

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    _coord2p = new std::unordered_set<CWCoordStruct>();
    
    return self;
}

- (void)dealloc {
    delete _coord2p;
}

- (NSData *)encode {
    NSUInteger sz = [_coord2v count] * sizeof(CWCoordStruct);
    NSMutableData *d = [NSMutableData dataWithCapacity:sz];
    for (const CWCoordStruct &c : *_coord2p) {
        if (c.v) {
            [d appendBytes:&c length:sizeof(c)];
        }
    }
    return d;
}

- (void)clean {
    _coord2p->clear();
}

- (BOOL)atI:(COORD_INT)i J:(COORD_INT)j { //! may wrap coords on overflow
    CWCoordStruct cs = { .i = i, .j = j, .v = YES };
    return _coord2p->count(cs) > 0;
}

- (void)set:(BOOL)val atI:(COORD_INT)i J:(COORD_INT)j {
    CWCoordStruct cs = { .i = i, .j = j, .v = YES };
    if (val) {
        _coord2p->insert(cs);
    } else {
        _coord2p->erase(cs);
    }
}

- (void)enumerateObjectsUsingBlock:(CWGridUpdBlock)block {
    __block ops_vec ins;
    __block ops_vec del;
    for (const CWCoordStruct &c : *_coord2p) {
        CWExecBlock(c, ins, del, block);
        CWEnumerateNeighbours(c.i, c.j, ^(COORD_INT i1, COORD_INT j1) {
            CWCoordStruct c1 = { .i = i1, .j = j1, .v = NO };
            if (_coord2p->count(c1) == 0) {
                CWExecBlock(c1, ins, del, block);
            }
        });
    }
    for (const CWCoordStruct &c : del) {
        _coord2p->erase(c);
    }
    for (CWCoordStruct c : ins) {
        c.v = YES;
        _coord2p->insert(c);
    }
}


@end
