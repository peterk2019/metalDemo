//
//  MetalView.m
//  ClearTheScreen
//
//  Created by Volvet Zhang on 16/3/13.
//  Copyright © 2016年 Volvet Zhang. All rights reserved.
//

#import "MetalView.h"


@interface MetalView()

@property (nonatomic, strong) id<MTLDevice>  mDevice;
@property (nonatomic, strong) id<MTLCommandQueue>   mCommandQueue;

@end

@implementation MetalView

+ (id) layerClass {
    return [CAMetalLayer class];
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if( self = [super initWithCoder:aDecoder] ){
        self.mDevice = MTLCreateSystemDefaultDevice();
        self.mCommandQueue = [self.mDevice newCommandQueue];
        
        self.metalLayer.device = self.mDevice;
        self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    }
    
    return self;
}

-(CAMetalLayer*) metalLayer {
    return (CAMetalLayer*) self.layer;
}

-(void)didMoveToWindow {
    [self redraw];
}

-(void)redraw {
    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
    id<MTLTexture> texture = drawable.texture;
    
    MTLRenderPassDescriptor  *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    passDescriptor.colorAttachments[0].texture = texture;
    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 0, 1, 1);
    
    
    id<MTLCommandBuffer> commandBuffer = [self.mCommandQueue commandBuffer];
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
    
    [commandEncoder endEncoding];
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}



@end
