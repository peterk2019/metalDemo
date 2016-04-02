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
#import "OBJGroup.h"
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

//static bool operator > (const FaceVertex & left, const FaceVertex & right) {
//    return ! (left < right);
//}


@interface OBJModel()
{
    std::vector<vector_float4> vertices;
    std::vector<vector_float4> normals;
    std::vector<vector_float2> texCoords;
    std::vector<Vertex>  groupVertices;
    std::vector<VertexIndex> groupIndices;
    std::map<FaceVertex, VertexIndex> vertexToGrupIndexMap;
}

@property (nonatomic, strong)  NSMutableArray  * mutableGroups;
@property (nonatomic, weak)    OBJGroup        * currentGroup;
@property (nonatomic, assign)  BOOL              shouldGenerateNormals;

@end

@implementation OBJModel

- (instancetype) initWithContentsOfURL :(NSURL*)fileUrl generateNormals:(BOOL)generateNormals {
    if( self = [super init] ){
        [self parseModelAtURL :fileUrl];
        _shouldGenerateNormals = generateNormals;
        _mutableGroups = [NSMutableArray array];
    }
    
    return self;
}

- (OBJGroup*) groupForName :(NSString*)groupName {
    return nil;
}


- (void) addVertexToCurrentGroup :(FaceVertex)fv {
    static const vector_float4 UP = { 0, 1, 0, 0 };
    static const uint16_t    INVALID_INDEX = 0xffff;
    
    uint16_t  groupIndex;
    auto  it = vertexToGrupIndexMap.find(fv);
    if( it != vertexToGrupIndexMap.end() ){
        groupIndex = (*it).second;
    } else {
        Vertex  vertex;
        vertex.position = vertices[fv.vi];
        vertex.normal = (fv.ni != INVALID_INDEX) ? normals[fv.ni] : UP;
        
        groupVertices.push_back(vertex);
        groupIndex = groupVertices.size() - 1;
        vertexToGrupIndexMap[fv] = groupIndex;
    }
    
    groupIndices.push_back(groupIndex);
}

- (void) addFaceWithFaceVertices :(const std::vector<FaceVertex> &)faceVertices {
    for( size_t i = 0; i < faceVertices.size() - 2; i++ ) {
        [self addVertexToCurrentGroup :faceVertices[i]];
        [self addVertexToCurrentGroup :faceVertices[i+1]];
        [self addVertexToCurrentGroup :faceVertices[i+2]];
    }
}

- (void) generateNormalsForCurrentGroup {
    static const vector_float4 ZERO = { 0, 0, 0, 0 };
    
    size_t i;
    size_t vertexCount = groupVertices.size();
    
    for( i=0;i<vertexCount;i++ ){
        groupVertices[i].normal = ZERO;
    }
    
    size_t indexCount = groupIndices.size();
    for( i=0;i<indexCount;i+=3 ){
        uint16_t i0 = groupIndices[i];
        uint16_t i1 = groupIndices[i+1];
        uint16_t i2 = groupIndices[i+2];
        
        Vertex *v0 = &groupVertices[i0];
        Vertex *v1 = &groupVertices[i1];
        Vertex *v2 = &groupVertices[i2];
        
        vector_float3 p0 = v0->position.xyz;
        vector_float3 p1 = v1->position.xyz;
        vector_float3 p2 = v2->position.xyz;
        
        vector_float3 cross = vector_cross(p1-p0, p2-p0);
        vector_float4 cross4 = { cross.x, cross.y, cross.z, 0 };
        
        v0->normal += cross4;
        v1->normal += cross4;
        v2->normal += cross4;
    }
    
    for( i=0;i<vertexCount;i++ ){
        groupVertices[i].normal = vector_normalize(groupVertices[i].normal);
    }
}

- (void) endCurrentGroup {
    if( ! _currentGroup ){
        return;
    }
    
    if( _shouldGenerateNormals ){
        [self generateNormalsForCurrentGroup];
    }
    
    NSData * vertexData = [NSData dataWithBytes:groupVertices.data() length:sizeof(Vertex)*groupVertices.size()];
    _currentGroup.vertexData = vertexData;
    
    NSData * indexData = [NSData dataWithBytes:groupIndices.data() length:sizeof(VertexIndex)*groupIndices.size()];
    _currentGroup.indexData = indexData;
    
    groupVertices.clear();
    groupIndices.clear();
    vertexToGrupIndexMap.clear();
    
    _currentGroup = nil;
}

- (void) beginGroupWithName :(NSString*)name {
    [self endCurrentGroup];
    
    OBJGroup * newGroup = [[OBJGroup alloc] initWithName:name];
    [_mutableGroups addObject:newGroup];
    _currentGroup = newGroup;
}


- (void) parseModelAtURL: (NSURL*) url {
    NSError  * error = nil;
    NSString * contents = [NSString stringWithContentsOfURL :url
                                                    encoding:NSASCIIStringEncoding
                                                       error:&error];
    if( !contents ){
        NSLog(@"OBJModel: Can't load url contents");
        return;
    }
    
    NSScanner * scanner = [NSScanner scannerWithString:contents];
    
    NSCharacterSet * skipSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSCharacterSet * consumeSet = [skipSet invertedSet];
    scanner.charactersToBeSkipped = skipSet;
    NSCharacterSet * endlineSet = [NSCharacterSet newlineCharacterSet];
    
    while( ![scanner isAtEnd] ){
        NSString * token = nil;
        if( ![scanner scanCharactersFromSet:consumeSet intoString:&token] ){
            break;
        }
        
        if( [token isEqualToString:@"v"] ){
            float x, y, z;
            [scanner scanFloat:&x];
            [scanner scanFloat:&y];
            [scanner scanFloat:&z];
            
            vector_float4  v = { x, y, z, 1 };
            vertices.push_back(v);
        } else if( [token isEqualToString:@"vt"] ) {
            float u, v;
            [scanner scanFloat:&u];
            [scanner scanFloat:&v];
            
            vector_float2 vt = { u, v };
            texCoords.push_back(vt);
        } else if( [token isEqualToString:@"vn"] ) {
            float nx, ny, nz;
            
            [scanner scanFloat:&nx];
            [scanner scanFloat:&ny];
            [scanner scanFloat:&nz];
            
            vector_float4 vn = { nx, ny, nz, 0 };
            normals.push_back(vn);
        } else if( [token isEqualToString:@"f"] ){
            std::vector<FaceVertex>  faceVertices;
            faceVertices.reserve(4);
            
            while(true) {
                int32_t  vi = 0, ti = 0, ni = 0;
                if( ![scanner scanInt:&vi] ){
                    break;
                }
                if( [scanner scanString:@"/" intoString:nil] ){
                    [scanner scanInt:&ti];
                    
                    if( [scanner scanString:@"/" intoString:nil] ) {
                        [scanner scanInt:&ni];
                    }
                }
                FaceVertex faceVertex;
                faceVertex.vi = (vi<0) ? (vertices.size() + vi - 1) : (vi - 1);
                faceVertex.ti = (ti<0) ? (texCoords.size() + ti - 1) : (ti - 1);
                faceVertex.ni = (ni<0) ? (vertices.size() + ni - 1) : (ni - 1);
                
                faceVertices.push_back(faceVertex);
            }
            [self addFaceWithFaceVertices:faceVertices];
        } else if( [token isEqualToString:@"g"] ){
            NSString * groupName = nil;
            if( [scanner scanUpToCharactersFromSet:endlineSet intoString:nil] ){
                [self beginGroupWithName:groupName];
            }
        }
    }
    
}


@end
