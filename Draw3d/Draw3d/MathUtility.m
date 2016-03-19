//
//  MathUtility.m
//  Draw3d
//
//  Created by Volvet Zhang on 16/3/19.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import "MathUtility.h"


// build a translation matrix
matrix_float4x4  matrix_float4x4_translation(vector_float3 t)
{
    vector_float4 X = { 1, 0, 0, 0 };
    vector_float4 Y = { 0, 1, 0, 0 };
    vector_float4 Z = { 0, 0, 1, 0 };
    vector_float4 W = { t.x, t.y, t.z, 1 };
    
    matrix_float4x4 mat = { X, Y, Z, W };
    
    return mat;
}

// build a scale matrix
matrix_float4x4  matrix_float4x4_uniform_scale(float scale)
{
    vector_float4 X = { scale, 0, 0, 0 };
    vector_float4 Y = { 0, scale, 0, 0 };
    vector_float4 Z = { 0, 0, scale, 0 };
    vector_float4 W = { 0, 0, 0, 1 };
    
    matrix_float4x4 mat = { X, Y, Z, W };
    
    return mat;
}

// build a rotation matrix
matrix_float4x4  matrix_float4x4_rotation(vector_float3 axis, float angle)
{
    matrix_float4x4 mat;
    
    return mat;
}

// build a symmetric perspective matrix
matrix_float4x4  matrix_float4x4_perspective(float aspect, float fovy, float near, float far)
{
    matrix_float4x4 mat;
    
    return mat;
}