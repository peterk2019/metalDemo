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

@interface  OBJMesh  : NSObject

@property (nonatomic, readonly)   id<MTLBuffer>   vertexBuffer;
@property (nonatomic, readonly)   id<MTLBuffer>   indexBuffer;

@end

#endif /* OBJMesh_h */
