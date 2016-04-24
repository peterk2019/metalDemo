//
//  ImageFilter.h
//  MetalImage
//
//  Created by Volvet Zhang on 16/4/24.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>


#import "IPContext.h"



@protocol TextureProvider <NSObject>

@property (nonatomic, readonly)  id<MTLTexture> texture;

@end

@protocol TextureConsumer <NSObject>

@property (nonatomic, strong)  id<TextureProvider>   provider;

@end


@interface ImageFilter : NSObject <TextureProvider, TextureConsumer>

@property (nonatomic, strong) IPContext  * context;
@property (nonatomic, strong) id<MTLBuffer>    uniformBuffer;
@property (nonatomic, strong) id<MTLComputePipelineState>  pipeline;
@property (nonatomic, strong) id<MTLTexture>   internalTexture;
@property (nonatomic, assign, getter=isDirty)  BOOL   dirty;

- (instancetype)  initWithFunctionName :(NSString*) functionName  context:(IPContext*) context;
- (void)  configureArgumentTableWithCommandEncoder :(id<MTLComputeCommandEncoder>)  commandEncoder;

@end
