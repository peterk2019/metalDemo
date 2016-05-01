//
//  GaussianBlurFilter.h
//  MetalImage
//
//  Created by Volvet Zhang on 16/5/1.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import "ImageFilter.h"

@interface GaussianBlurFilter : ImageFilter

@property (nonatomic, assign)   float  radius;
@property (nonatomic, assign)   float  sigma;

+ (instancetype) filterWithRadius :(float)radius  :(IPContext*) context;

@end
