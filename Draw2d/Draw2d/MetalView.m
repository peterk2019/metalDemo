//
//  MetalView.m
//  Draw2d
//
//  Created by Volvet Zhang on 16/3/18.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import "MetalView.h"

@import simd;

typedef struct {
    vector_float4  position;
    vector_float4  color;
} MetalVertex;

@interface MetalView()

@property (nonatomic, strong)  CADisplayLink * mDisplayLink;
@property (nonatomic, strong)  id<MTLDevice>   mDevice;
@property (nonatomic, strong)  id<MTLRenderPipelineState>  mPipeline;
@property (nonatomic, strong)  id<MTLCommandQueue>   mCommandQueue;
@property (nonatomic, strong)  id<MTLBuffer>     mVertexBuffer;

@end

@implementation MetalView


@end
