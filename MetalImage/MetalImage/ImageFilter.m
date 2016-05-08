//
//  ImageFilter.m
//  MetalImage
//
//  Created by Volvet Zhang on 16/4/24.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import "ImageFilter.h"

@interface ImageFilter()

@property (nonatomic, strong)  id<MTLFunction>  kernalFunction;
@property (nonatomic, strong)  id<MTLTexture>   texture;

@end

@implementation ImageFilter

@synthesize dirty = _dirty;
@synthesize provider = _provider;

- (instancetype) initWithFunctionName:(NSString *)functionName context:(IPContext *)context {
    if( self = [super init] ){
        NSError * error = nil;
        _context = context;
        _kernalFunction = [_context.library newFunctionWithName:functionName];
        _pipeline = [_context.device newComputePipelineStateWithFunction:_kernalFunction error:&error];
        
        if( !_pipeline ){
            NSLog(@"Error occured when building compute pipeline for function %@", functionName);
            return nil;
        }
    }
    
    return self;
}

- (void) configureArgumentTableWithCommandEncoder:(id<MTLComputeCommandEncoder>)commandEncoder {
    
}

- (void) applyFilter {
    id<MTLTexture>  inputTexture = self.provider.texture;
    
    if( (!_internalTexture) || ([_internalTexture width] != [inputTexture width]) ||
       ([_internalTexture height] != [_internalTexture height]) ) {
        MTLTextureDescriptor * textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:[inputTexture pixelFormat] width:[inputTexture width] height:[inputTexture height] mipmapped:NO];
        _internalTexture = [_context.device newTextureWithDescriptor:textureDescriptor];
    }
    
    MTLSize threadgroupCounts = MTLSizeMake(8, 8, 1);
    MTLSize threadgroups = MTLSizeMake([inputTexture width]/threadgroupCounts.width,
                                       [inputTexture height]/threadgroupCounts.height,
                                       1);
    
    id<MTLCommandBuffer>  commandBuffer = [_context.commandQuene commandBuffer];
    id<MTLComputeCommandEncoder> commandEncoder = [commandBuffer computeCommandEncoder];
    [commandEncoder setComputePipelineState: _pipeline];
    [commandEncoder setTexture:inputTexture atIndex:0];
    [commandEncoder setTexture:_internalTexture atIndex:1];
    [self configureArgumentTableWithCommandEncoder:commandEncoder];
    [commandEncoder dispatchThreadgroups:threadgroups threadsPerThreadgroup:threadgroupCounts];
    [commandEncoder endEncoding];
    
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
}

- (id<MTLTexture>)  texture {
    if( _dirty ) {
        [self applyFilter];
        _dirty = NO;
    }
    return self.internalTexture;
}

@end
