//
//  UIMetalView.m
//  Teapot
//
//  Created by Volvet Zhang on 16/4/2.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import "UIMetalView.h"

@implementation UIMetalView


+ (Class) layerClass {
    return [CAMetalLayer class];
}

@end
