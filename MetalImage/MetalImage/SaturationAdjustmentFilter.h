//
//  SaturationAdjustmentFilter.h
//  MetalImage
//
//  Created by Volvet Zhang on 16/5/1.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import "ImageFilter.h"

@interface SaturationAdjustmentFilter : ImageFilter

@property (nonatomic, assign)    float  saturationFactor;

+ (instancetype) filterWithSaturationFactor : (float)saturation  context:(IPContext*)context;

@end
