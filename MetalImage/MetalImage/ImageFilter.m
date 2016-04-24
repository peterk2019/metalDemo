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

@end
