//
//  MathUtility.h
//  Draw3d
//
//  Created by Volvet Zhang on 16/3/19.
//  Copyright © 2016年 volvet. All rights reserved.
//

#ifndef MathUtility_h
#define MathUtility_h


@import simd;

// build a translation matrix
matrix_float4x4  matrix_float4x4_translation(vector_float3 t);

// build a scale matrix
matrix_float4x4  matrix_float4x4_uniform_scale(float scale);

// build a rotation matrix
matrix_float4x4  matrix_float4x4_rotation(vector_float3 axis, float angle);

// build a symmetric perspective matrix
matrix_float4x4  matrix_float4x4_perspective(float aspect, float fovy, float near, float far);


matrix_float3x3  matrix_float4x4_extract_linear(matrix_float4x4 matrix);


#endif /* MathUtility_h */
