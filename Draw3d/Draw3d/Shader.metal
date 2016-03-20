//
//  Shader.metal
//  Draw3d
//
//  Created by Volvet Zhang on 16/3/20.
//  Copyright © 2016年 volvet. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4  position[[position]];
    float4  color;
};

struct Uniforms {
    float4x4 modelViewProjectionMatrix;
};

vertex Vertex vertex_main(device Vertex * vertices[[buffer(0)]], constant Uniforms * uniforms[[buffer(1)]],
                          uint vid[[vertex_id]])
{
    Vertex vertexOut;
    
    vertexOut.position = uniforms->modelViewProjectionMatrix * vertices[vid].position;
    vertexOut.color = vertices[vid].color;
    
    return vertexOut;
}


fragment half4 fragment_main(Vertex vertexIn[[stage_in]])
{
    return half4(vertexIn.color);
}


