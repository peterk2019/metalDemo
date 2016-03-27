//
//  OBJModel.m
//  Teapot
//
//  Created by Volvet Zhang on 16/3/27.
//  Copyright © 2016年 volvet. All rights reserved.
//



#include <map>
#include <vector>
#include <functional>


#import "typedef.h"
#import "OBJModel.h"

struct FaceVertex
{
    FaceVertex() {
        vi = ti = ni = 0;
    }
    
    uint16_t vi, ti, ni;
};

static bool operator < (const FaceVertex & left, const FaceVertex & right) {
    if( left.vi < right.vi ) return true;
    else if( left.vi > right.vi ) return false;
    else if( left.ti < right.ti ) return true;
    else if( left.ti > right.ti ) return false;
    else if( left.ni < right.ni ) return true;
    else if( left.ni > right.ni ) return false;
    else return false;
}

static bool operator > (const FaceVertex & left, const FaceVertex & right) {
    return ! (left < right);
}


@interface OBJModel()
{
    std::vector<vector_float4> vertices;
    std::vector<vector_float4> normals;
    std::vector<vector_float2> texCoords;
    std::vector<Vertex>  groupVertices;
    std::vector<VertexIndex> groupIndices;
    std::map<FaceVertex, VertexIndex> vertexToGrupIndexMap;
}
@end

@implementation OBJModel

@end
