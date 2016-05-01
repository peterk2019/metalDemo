//
//  GaussianBlurFilter.m
//  MetalImage
//
//  Created by Volvet Zhang on 16/5/1.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import "Metal/Metal.h"
#import "GaussianBlurFilter.h"

@interface GaussianBlurFilter()

@property (nonatomic, strong)  id<MTLTexture> blurWeightTexture;

@end

@implementation GaussianBlurFilter


+ (instancetype) filterWithRadius:(float)radius :(IPContext *)context {
    return [[self alloc] initWithRadius :radius context:context];
}

- (instancetype) initWithRadius :(float)radius context:(IPContext*)context {
    if( self = [super initWithFunctionName:@"gaussian_blur" context:context] ){
        _radius = radius;
    }
    return self;
}

@end
