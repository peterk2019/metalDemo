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

@property (nonatomic, strong)  NSMutableArray  * mutableArray;
@property (nonatomic, weak)    OBJGroup        * currentGroup;
@property (nonatomic, assign)  BOOL              shouldGenerateNormals;

@end

@implementation OBJModel

- (instancetype) initWithContentsOfURL :(NSURL*)fileUrl generateNormals:(BOOL)generateNormals {
    if( self = [super init] ){
        [self parseModelAtURL :fileUrl];
        _shouldGenerateNormals = generateNormals;
        _mutableArray = [NSMutableArray array];
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

- (void) endCurrentGroup {
    if( ! _currentGroup ){
        return;
    }
}

- (void) beginGroupWithName :(NSString*)name {
    
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
    
    
}


@end
