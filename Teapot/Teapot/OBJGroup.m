//
//  OBJGroup.m
//  Teapot
//
//  Created by Volvet Zhang on 16/3/27.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import "typedef.h"
#import "OBJGroup.h"


@implementation OBJGroup

- (instancetype) initWithName:(NSString *)name {
    if( self = [super init] ){
        _name = [name copy];
    }
    return self;
}

- (NSString *) description {
    size_t vertCount = _vertexData.length / sizeof(Vertex);
    size_t indexCount = _indexData.length / sizeof(VertexIndex);
    
    return [NSString stringWithFormat:@"<OBJMesh %p, name %@, vertices %zu, indices %zu", self, _name,
            vertCount, indexCount];
}

@end
