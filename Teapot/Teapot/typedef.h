//
//  typedef.h
//  Teapot
//
//  Created by Volvet Zhang on 16/3/27.
//  Copyright © 2016年 volvet. All rights reserved.
//

#ifndef typedef_h
#define typedef_h


#include <simd/simd.h>
#include <Metal/Metal.h>

#define VertexIndexType  MTLIndexTypeUInt16
typedef uint16_t VertexIndex;

typedef struct __attribute((packed)) {
    vector_float4 position;
    vector_float4 normal;
} Vertex;

typedef struct __attribute((packed)) {
    matrix_float4x4 modelViewProjectionMatrix;
    matrix_float4x4 modelViewMatrix;
    matrix_float4x4 normalMatrix;
} Uniforms;



#endif /* typedef_h */
