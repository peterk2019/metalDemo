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

+ (Class) layerClass {
    return [CAMetalLayer class];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if( self = [super initWithCoder:aDecoder] ){
        [self mtlDeviceInit];
        [self mtlVertexBufferInit];
        [self mtlPipelineInit];
    }
    
    return self;
}

- (void) dealloc {
    [self.mDisplayLink invalidate];
}

- (CAMetalLayer*) metalLayer {
    return (CAMetalLayer*)self.layer;
}

- (void) mtlDeviceInit {
    self.mDevice = MTLCreateSystemDefaultDevice();
    self.metalLayer.device = self.mDevice;
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
}

- (void) mtlVertexBufferInit {
    static const MetalVertex vertices[] = {
        { .position = { 0.0f, 0.8f, 0.0f, 1.0f }, .color = { 1.0f, 0.0f, 0.0f, 1.0f } },
        { .position = { -0.8, -0.8f, 0.0f, 1.0f }, .color = { 0.0f, 1.0f, 0.0f, 1.0f } },
        { .position = { 0.8f, -0.8f, 0.0f, 1.0f }, .color = { 0.0f, 0.0f, 1.0f, 1.0f } }
    };
    
    self.mVertexBuffer = [self.mDevice newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceCPUCacheModeDefaultCache];
}

- (void) mtlPipelineInit {
    id<MTLLibrary>  library = [self.mDevice newDefaultLibrary];
    id<MTLFunction> vertexFunc = [library newFunctionWithName:@"vertex_main"];
    id<MTLFunction> fragmentFunc = [library newFunctionWithName:@"fragment_main"];
    
    MTLRenderPipelineDescriptor * pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.vertexFunction = vertexFunc;
    pipelineDescriptor.fragmentFunction = fragmentFunc;
    
    NSError * error = nil;
    self.mPipeline = [self.mDevice newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
    
    if( self.mPipeline == nil ){
        NSLog(@"mtlPipelineInit: fail to create pipeline");
    }
    
    self.mCommandQueue = [self.mDevice newCommandQueue];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if( self.subviews ){
        self.mDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
        [self.mDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        [self.mDisplayLink invalidate];
        self.mDisplayLink = nil;
    }
}

- (void)displayLinkDidFire:(CADisplayLink*)displayLink {
    @autoreleasepool {
        [self redraw];
    }
}

- (void) redraw {
    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
    id<MTLTexture> texture = drawable.texture;
    
    if( drawable ) {
        MTLRenderPassDescriptor * passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
        passDescriptor.colorAttachments[0].texture = texture;
        passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.3, 0.3, 0.3, 1.0);
        passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        
        id<MTLCommandBuffer> commandBuffer = [self.mCommandQueue commandBuffer];
        id<MTLRenderCommandEncoder>  commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
        [commandEncoder setRenderPipelineState:self.mPipeline];
        [commandEncoder setVertexBuffer:self.mVertexBuffer offset:0 atIndex:0];
        [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
        [commandEncoder endEncoding];
        
        [commandBuffer presentDrawable:drawable];
        [commandBuffer commit];
    }
}



@end
