//
//  OBJMesh.h
//  Teapot
//
//  Created by Volvet Zhang on 16/3/27.
//  Copyright © 2016年 volvet. All rights reserved.
//

#ifndef OBJMesh_h
#define OBJMesh_h

@import Metal;
@import UIKit;

@class OBJGroup;

@interface  Mesh  : NSObject

@property (nonatomic, readonly)   id<MTLBuffer>   vertexBuffer;
@property (nonatomic, readonly)   id<MTLBuffer>   indexBuffer;

@end

@interface OBJMesh : Mesh

- (instancetype) initWithGroup :(OBJGroup*) group  device:(id<MTLDevice>)device;

@end

#endif /* OBJMesh_h */
