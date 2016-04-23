//
//  IPContext.h
//  MetalImage
//
//  Created by Volvet Zhang on 16/4/23.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>


@interface IPContext : NSObject

@property (nonatomic, strong) id<MTLDevice>          device;
@property (nonatomic, strong) id<MTLLibrary>         library;
@property (nonatomic, strong) id<MTLCommandQueue>    commandQuene;


+ (instancetype) newContext;

@end
