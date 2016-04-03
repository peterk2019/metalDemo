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

#import "typedef.h"
#import "MetalViewRender.h"
#import "MathUtility.h"
#import "OBJMesh.h"
#import "OBJModel.h"

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
    NSURL * modelURL = [[NSBundle mainBundle] URLForResource:@"teapot" withExtension:@"obj"];
    OBJModel  * model = [[OBJModel alloc] initWithContentsOfURL:modelURL generateNormals:YES];
    OBJGroup  * group = [model groupForName:@"teapot"];
    
    _mesh = [[OBJMesh alloc] initWithGroup:group device:_device];
    
    _uniformBuffer = [_device newBufferWithLength:sizeof(Uniforms) * InFlightBufferCount options:MTLResourceCPUCacheModeDefaultCache];
}

- (void) updateUniformsForView :(UIMetalView*)view duration:(NSTimeInterval)duration {
    _time += duration;
    _rotationX += duration * (M_PI/2);
    _rotationY += duration * (M_PI/3);
    float scaleFactor = 1;
    static const vector_float3 xAxis = { 1, 0, 0 };
    static const vector_float3 yAxis = { 0, 1, 0 };
    const matrix_float4x4 xRot = matrix_float4x4_rotation(xAxis, _rotationX);
    const matrix_float4x4 yRot = matrix_float4x4_rotation(yAxis, _rotationY);
    const matrix_float4x4 scale = matrix_float4x4_uniform_scale(scaleFactor);
    const matrix_float4x4 modelMatrix = matrix_multiply(matrix_multiply(xRot, yRot), scale);
    
    const vector_float3  cameraTranslation = { 0, 0, -1.5 };
    const matrix_float4x4  viewMatrix = matrix_float4x4_translation(cameraTranslation);
    
    const CGSize drawableSize = view.metalLayer.drawableSize;
    const float aspect = drawableSize.width / drawableSize.height;
    const float fov = 2 * M_PI / 5;
    const float near = 0.1;
    const float far = 100;
    const matrix_float4x4 projectionMatrix = matrix_float4x4_perspective(aspect, fov, near, far);
    
    Uniforms  uniforms;
    uniforms.modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix);
    uniforms.modelViewProjectionMatrix = matrix_multiply(projectionMatrix, uniforms.modelViewMatrix);
    uniforms.normalMatrix = matrix_float4x4_extract_linear(uniforms.modelViewMatrix);
    
    const NSUInteger uniformBufferOffset = sizeof(Uniforms) * _bufferIndex;
    memcpy([_uniformBuffer contents] + uniformBufferOffset, &uniforms, sizeof(uniforms));
}

- (void) drawInView:(UIMetalView *)view {
    dispatch_semaphore_wait(_displaySemaphore, DISPATCH_TIME_FOREVER);
    
    view.clearColor = MTLClearColorMake(0.95, 0.95, 0.95, 1);
    [self updateUniformsForView:view duration:view.frameDuration];
    
    id<MTLCommandBuffer>   commandBuffer = [_commandQueue commandBuffer];
    MTLRenderPassDescriptor * renderPassDescriptor = [view currentRenderPassDescriptor];
    id<MTLRenderCommandEncoder>  renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    
    [renderCommandEncoder setRenderPipelineState:_renderPipelineState];
    [renderCommandEncoder setDepthStencilState:_depthStencilState];
    [renderCommandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [renderCommandEncoder setCullMode:MTLCullModeBack];
    
    const NSUInteger  uniformBufferOffset = sizeof(Uniforms) * _bufferIndex;
    [renderCommandEncoder setVertexBuffer:_mesh.vertexBuffer offset:0 atIndex:0];
    [renderCommandEncoder setVertexBuffer:self.uniformBuffer offset:uniformBufferOffset atIndex:1];
    
    [renderCommandEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:[_mesh.indexBuffer length]/sizeof(VertexIndex) indexType:VertexIndexType indexBuffer:_mesh.indexBuffer indexBufferOffset:0];
    [renderCommandEncoder endEncoding];
    
    [commandBuffer presentDrawable:view.currentDrawable];
    
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        self.bufferIndex = (self.bufferIndex + 1) % InFlightBufferCount;
        dispatch_semaphore_signal(_displaySemaphore);
    }];
    
    [commandBuffer commit];
}

@end
