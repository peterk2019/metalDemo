//
//  MetalRender.m
//  Draw3d
//
//  Created by Volvet Zhang on 16/3/20.
//  Copyright © 2016年 volvet. All rights reserved.
//


@import QuartzCore;
@import Metal;
@import simd;

#import "MetalRender.h"
#import "MathUtility.h"

const static NSInteger InFlightBufferCount = 3;

typedef uint16_t  VerticeIndex;

typedef struct
{
    vector_float4 position;
    vector_float4 color;
} Vertex;

typedef struct
{
    matrix_float4x4   modelViewProjectionMatrix;
} Uniforms;

@interface MetalRender()

@property (strong)   id<MTLDevice>  mDevice;
@property (strong)   id<MTLBuffer>  mVertexBuffer;
@property (strong)   id<MTLBuffer>  mIndexBuffer;
@property (strong)   id<MTLBuffer>  mUniformBuffer;
@property (strong)   id<MTLCommandQueue>   mCommandQueue;
@property (strong)   id<MTLRenderPipelineState>   mPipeline;
@property (strong)   id<MTLDepthStencilState>   mDepthStencilState;
@property (strong)   dispatch_semaphore_t   mDisplaySemaphore;
@property (assign)   NSInteger   mBufferIndex;
@property (assign)   float  mRotateX,  mRotateY,   mTime;

@end

@implementation MetalRender


- (instancetype) init {
    if( self = [super init] ){
        _mDevice = MTLCreateSystemDefaultDevice();
        _mDisplaySemaphore = dispatch_semaphore_create(InFlightBufferCount);
        
        [self mtlPipelineInit];
        [self mtlBufferInit];
    }
    
    return self;
}

- (void) mtlPipelineInit {
    _mCommandQueue = [_mDevice newCommandQueue];
    
    id<MTLLibrary> library = [_mDevice newDefaultLibrary];
    
    MTLRenderPipelineDescriptor  * pipeDescriptor = [MTLRenderPipelineDescriptor new];
    
    pipeDescriptor.vertexFunction = [library newFunctionWithName:@"vertex_main"];
    pipeDescriptor.fragmentFunction = [library newFunctionWithName:@"fragment_main"];
    pipeDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipeDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    NSError * error = nil;
    _mPipeline = [_mDevice newRenderPipelineStateWithDescriptor:pipeDescriptor error:&error];
    
    MTLDepthStencilDescriptor * depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = YES;
    _mDepthStencilState = [_mDevice newDepthStencilStateWithDescriptor:depthStencilDescriptor];
    
    if( !_mPipeline ){
        NSLog(@"mtlPipelineInit: fail to create render pipeline, error: %@", error);
    }
}

- (void) mtlBufferInit {
    static const Vertex vertices[] =
    {
        { .position = { -1,  1,  1, 1 }, .color = { 0, 1, 1, 1 } },
        { .position = { -1, -1,  1, 1 }, .color = { 0, 0, 1, 1 } },
        { .position = {  1, -1,  1, 1 }, .color = { 1, 0, 1, 1 } },
        { .position = {  1,  1,  1, 1 }, .color = { 1, 1, 1, 1 } },
        { .position = { -1,  1, -1, 1 }, .color = { 0, 1, 0, 1 } },
        { .position = { -1, -1, -1, 1 }, .color = { 0, 0, 0, 1 } },
        { .position = {  1, -1, -1, 1 }, .color = { 1, 0, 0, 1 } },
        { .position = {  1,  1, -1, 1 }, .color = { 1, 1, 0, 1 } }
    };
    
    static const VerticeIndex indices[] =
    {
        3, 2, 6, 6, 7, 3,
        4, 5, 1, 1, 0, 4,
        4, 0, 3, 3, 7, 4,
        1, 5, 6, 6, 2, 1,
        0, 1, 2, 2, 3, 0,
        7, 6, 5, 5, 4, 7
    };
    
    _mVertexBuffer = [_mDevice newBufferWithBytes:vertices
                                             length:sizeof(vertices)
                                            options:MTLResourceOptionCPUCacheModeDefault];
    [_mVertexBuffer setLabel:@"Vertices"];
    
    _mIndexBuffer = [_mDevice newBufferWithBytes:indices
                                            length:sizeof(indices)
                                           options:MTLResourceOptionCPUCacheModeDefault];
    [_mIndexBuffer setLabel:@"Indices"];
    
    _mUniformBuffer = [_mDevice newBufferWithLength:sizeof(Uniforms) * InFlightBufferCount
                                              options:MTLResourceOptionCPUCacheModeDefault];
    [_mUniformBuffer setLabel:@"Uniforms"];
}

- (void)updateUniformsForView:(MetalView *)view duration:(NSTimeInterval)duration
{
    _mTime += duration;
    _mRotateX += duration * (M_PI / 2);
    _mRotateY += duration * (M_PI / 3);
    float scaleFactor = sinf(5 * _mTime) * 0.25 + 1;
    const vector_float3 xAxis = { 1, 0, 0 };
    const vector_float3 yAxis = { 0, 1, 0 };
    const matrix_float4x4 xRot = matrix_float4x4_rotation(xAxis, _mRotateX);
    const matrix_float4x4 yRot = matrix_float4x4_rotation(yAxis, _mRotateY);
    const matrix_float4x4 scale = matrix_float4x4_uniform_scale(scaleFactor);
    const matrix_float4x4 modelMatrix = matrix_multiply(matrix_multiply(xRot, yRot), scale);
    
    const vector_float3 cameraTranslation = { 0, 0, -5 };
    const matrix_float4x4 viewMatrix = matrix_float4x4_translation(cameraTranslation);
    
    const CGSize drawableSize = view.mMetalLayer.drawableSize;
    const float aspect = drawableSize.width / drawableSize.height;
    const float fov = (2 * M_PI) / 5;
    const float near = 1;
    const float far = 100;
    const matrix_float4x4 projectionMatrix = matrix_float4x4_perspective(aspect, fov, near, far);
    
    Uniforms uniforms;
    uniforms.modelViewProjectionMatrix = matrix_multiply(projectionMatrix, matrix_multiply(viewMatrix, modelMatrix));
    
    const NSUInteger uniformBufferOffset = sizeof(Uniforms) * _mBufferIndex;
    memcpy([_mUniformBuffer contents] + uniformBufferOffset, &uniforms, sizeof(uniforms));
}

- (void)drawInView:(MetalView *)view
{
    dispatch_semaphore_wait(_mDisplaySemaphore, DISPATCH_TIME_FOREVER);
    
    view.mClearColor = MTLClearColorMake(0.95, 0.95, 0.95, 1);
    
    [self updateUniformsForView:view duration:view.mFrameDuration];
    
    id<MTLCommandBuffer> commandBuffer = [_mCommandQueue commandBuffer];
    
    MTLRenderPassDescriptor *passDescriptor = [view currentRenderPassDescriptor];
    
    id<MTLRenderCommandEncoder> renderPass = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
    [renderPass setRenderPipelineState:_mPipeline];
    [renderPass setDepthStencilState:_mDepthStencilState];
    [renderPass setFrontFacingWinding:MTLWindingCounterClockwise];
    [renderPass setCullMode:MTLCullModeBack];
    
    const NSUInteger uniformBufferOffset = sizeof(Uniforms) * _mBufferIndex;
    
    [renderPass setVertexBuffer:_mVertexBuffer offset:0 atIndex:0];
    [renderPass setVertexBuffer:_mUniformBuffer offset:uniformBufferOffset atIndex:1];
    
    [renderPass drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                           indexCount:[_mIndexBuffer length] / sizeof(VerticeIndex)
                            indexType:MTLIndexTypeUInt16
                          indexBuffer:_mIndexBuffer
                    indexBufferOffset:0];
    
    [renderPass endEncoding];
    
    [commandBuffer presentDrawable:view.mCurrentDrawable];
    
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        _mBufferIndex = (_mBufferIndex + 1) % InFlightBufferCount;
        dispatch_semaphore_signal(_mDisplaySemaphore);
    }];
    
    [commandBuffer commit];
}


@end