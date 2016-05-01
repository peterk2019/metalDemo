//
//  SaturationAdjustmentFilter.m
//  MetalImage
//
//  Created by Volvet Zhang on 16/5/1.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import "SaturationAdjustmentFilter.h"

struct AdjustSaturationUniforms
{
    float saturationFactor;
};

@implementation SaturationAdjustmentFilter

+ (instancetype) filterWithSaturationFactor:(float)saturation context:(IPContext *)context {
    return [[self alloc] initWithSaturationFactor : saturation context:context];
}

- (instancetype) initWithSaturationFactor : (float)saturation context:(IPContext*)context {
    if( self = [super initWithFunctionName:@"adjust_saturation" context:context] ){
        _saturationFactor = saturation;
    }
    return self;
}

- (void) setSaturationFactor:(float)saturationFactor {
    self.dirty = true;
    
    _saturationFactor = saturationFactor;
}

- (void) configureArgumentTableWithCommandEncoder:(id<MTLComputeCommandEncoder>)commandEncoder {
    struct AdjustSaturationUniforms uniforms;
    
    uniforms.saturationFactor = _saturationFactor;
    
    if( !self.uniformBuffer ) {
        self.uniformBuffer = [self.context.device newBufferWithLength:sizeof(uniforms) options:MTLResourceOptionCPUCacheModeDefault];
    }
    
    memcpy( [self.uniformBuffer contents], &uniforms, sizeof(uniforms) );
    [commandEncoder setBuffer:self.uniformBuffer offset:0 atIndex:0];
    
}

@end
