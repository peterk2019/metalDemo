//
//  IPContext.m
//  MetalImage
//
//  Created by Volvet Zhang on 16/4/23.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import "IPContext.h"

@implementation IPContext

+ (instancetype) newContext {
    return [[self alloc] initWithDevice:nil];
}

- (instancetype) initWithDevice : (id<MTLDevice>)  device {
    if( self = [super init] ){
        _device = device ? device : MTLCreateSystemDefaultDevice();
        _library = [_device newDefaultLibrary];
        _commandQuene = [_device newCommandQueue];
    }
    return self;
}

@end
