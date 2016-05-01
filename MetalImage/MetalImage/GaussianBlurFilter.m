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

- (void) generateBlurWeightTexture {
    NSAssert(_radius > 0.0f, @"Blur radius must > 0");
    
    const float radius = _radius;
    const float sigma = _sigma;
    const int  size = (round(radius) * 2 + 1);
    float delta = 0;
    float expScale = 0;
    
    if( radius > 0.0f ){
        delta = (radius * 2)/(size - 1);
        expScale = -1 / (2 * sigma * sigma);
    }
    
    float * weights = malloc(sizeof(float) * size * size);
    float weightSum = 0;
    float y = - radius;
    for( int j=0;j<size; ++j, y += delta) {
        float x = - radius;
        for( int i=0;i<size; ++i, x += delta) {
            float weight = expf((x*x + y*y) * expScale);
            weights[j*size + i] = weight;
            weightSum += weight;
        }
    }
    const float weightScale = 1/weightSum;
    for( int i=0;i<size * size;i++ ){
        weights[i] *= weightScale;
    }
    
    MTLTextureDescriptor * descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR32Float width:size height:size mipmapped:NO];
    _blurWeightTexture = [self.context.device newTextureWithDescriptor :descriptor];
    
    MTLRegion region = MTLRegionMake2D(0, 0, size, size);
    [_blurWeightTexture replaceRegion:region mipmapLevel:0 withBytes:weights bytesPerRow:sizeof(float)*size];
    
    free(weights);
}

- (void)setRadius:(float)radius {
    self.dirty = true;
    _radius = radius;
    _blurWeightTexture = nil;
}

- (void)setSigma:(float)sigma {
    self.dirty = true;
    _sigma = sigma;
    _blurWeightTexture = nil;
}

- (void)configureArgumentTableWithCommandEncoder:(id<MTLComputeCommandEncoder>)commandEncoder {
    if( !_blurWeightTexture ) {
        [self generateBlurWeightTexture];
    }
    [commandEncoder setTexture:_blurWeightTexture atIndex:2];
}

@end
