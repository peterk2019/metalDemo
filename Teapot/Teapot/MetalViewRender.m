//
//  MentalViewRender.m
//  Teapot
//
//  Created by Volvet Zhang on 16/4/2.
//  Copyright © 2016年 volvet. All rights reserved.
//

@import Metal;
@import simd;
@import QuartzCore;

#import "MetalViewRender.h"
#import "OBJMesh.h"

static const NSInteger   InFlightBufferCount = 3;

@interface MetalViewRender()

@property (nonatomic, strong)    Mesh            *mesh;
@property (nonatomic, strong)    id<MTLDevice>   device;
@property (nonatomic, strong)    id<MTLBuffer>   uniformBuffer;
@property (nonatomic, strong)    id<MTLCommandQueue>   commandQueue;
@property (nonatomic, strong)    id<MTLRenderPipelineState>   renderPipelineState;
@property (nonatomic, strong)    id<MTLDepthStencilState>     depthStencilState;
@property (nonatomic, strong)    dispatch_semaphore_t        displaySemaphore;
@property (nonatomic, assign)    NSInteger      bufferIndex;
@property (nonatomic, assign)    float     rotationX, rotationY, rotionZ, time;

@end

@implementation MetalViewRender

- (instancetype)  init {
    if( self = [super init] ){
        _device = MTLCreateSystemDefaultDevice();
        _displaySemaphore = dispatch_semaphore_create(InFlightBufferCount);
        [self makePipeline];
        [self makeResource];
    }
    
    return self;
}

- (void) makePipeline {
    _commandQueue = [_device newCommandQueue];
    id<MTLLibrary> library = [_device newDefaultLibrary];
    
    
    MTLRenderPipelineDescriptor  * descriptor = [MTLRenderPipelineDescriptor new];
    descriptor.vertexFunction = [library newFunctionWithName:@"vertex_main"];
    descriptor.fragmentFunction = [library newFunctionWithName:@"fragment_main"];
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    MTLDepthStencilDescriptor  * depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = YES;
    _depthStencilState = [_device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
    
    NSError * error = nil;
    _renderPipelineState = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
    
    if( !_renderPipelineState ){
        NSLog(@"Fail to create pipeline");
    }
}

- (void) makeResource {
    
}

- (void) drawInView:(UIMetalView *)view {
    
}

@end
