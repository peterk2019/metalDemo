//
//  MainBoundleTextureProvider.m
//  MetalImage
//
//  Created by Volvet Zhang on 16/5/2.
//  Copyright © 2016年 volvet. All rights reserved.
//

@import Metal;
@import UIKit;

#import "MainBoundleTextureProvider.h"


@interface MainBoundleTextureProvider()

@property (nonatomic, strong) id<MTLTexture>  texture;

@end

@implementation MainBoundleTextureProvider

+ (instancetype) textureProviderWithImageNamed:(NSString *)imageName context:(IPContext *)context {
    return [[self alloc] initWithImageNamed:imageName  context:context];
}


- (instancetype) initWithImageNamed :(NSString*)imageName context:(IPContext*)context {
    if( self = [super init] ){
        UIImage * image = [UIImage imageNamed:imageName];
        _texture = [self textureForImage:image context:context];
    }
    
    return self;
}

- (id<MTLTexture>)  textureForImage :(UIImage*)image context:(IPContext*)context {
    CGImageRef imageRef = [image CGImage];
    
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    uint8_t * rawData = (uint8_t*)malloc(width * height * 4);
    const NSUInteger bytesPerPixel = 4;
    const NSUInteger bytesPerRow = bytesPerPixel * width;
    const NSUInteger bitsPerComponent = 8;
    CGContextRef bitmapContext = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorspace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorspace);
    
    CGContextTranslateCTM(bitmapContext, 0, height);
    CGContextScaleCTM(bitmapContext, 1, -1);
    
    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(bitmapContext);
    
    MTLTextureDescriptor * descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm width:width height:height mipmapped:NO];
    
    id<MTLTexture> texture = [context.device newTextureWithDescriptor:descriptor];
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    [texture replaceRegion:region mipmapLevel:0 withBytes:rawData bytesPerRow:bytesPerRow];
    
    free(rawData);
    return texture;
}


- (void) provideTexture :(void (^) (id<MTLTexture>)) textureBlock {
    if( textureBlock ){
        textureBlock(_texture);
    }
}

@end
