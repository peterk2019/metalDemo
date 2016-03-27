//
//  OBJMesh.m
//  Teapot
//
//  Created by Volvet Zhang on 16/3/27.
//  Copyright © 2016年 volvet. All rights reserved.
//


#import "OBJMesh.h"
#import "OBJGroup.h"


@implementation Mesh

@end


@implementation OBJMesh

@synthesize vertexBuffer;
@synthesize indexBuffer;

- (instancetype) initWithGroup:(OBJGroup *)group device:(id<MTLDevice>)device {
    if( self = [super init] ){
        vertexBuffer = [device newBufferWithBytes:[group.vertexData bytes] length:[group.vertexData length] options:MTLResourceCPUCacheModeDefaultCache];
        
        [vertexBuffer setLabel:group.name];
        
        indexBuffer = [device newBufferWithBytes:[group.indexData bytes] length:[group.indexData length] options:MTLResourceCPUCacheModeDefaultCache];
        
        [indexBuffer setLabel:group.name];
    }
    
    return self;
}

@end