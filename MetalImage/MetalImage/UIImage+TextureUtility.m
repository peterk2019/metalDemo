//
//  TextureUtility.m
//  MetalImage
//
//  Created by Volvet Zhang on 16/5/1.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "UIImage+TextureUtility.h"


static void ReleaseDataCallback(void * inof, const void * data, size_t size)
{
    free((void*)data);
}

@implementation UIImage(TextureUtility)

+ (UIImage*) imageWithMTLTexture :(id<MTLTexture>)texture {
    NSAssert([texture pixelFormat] == MTLPixelFormatRGBA8Unorm, @"Unexpected pixel format");
    
    CGSize imageSize = CGSizeMake([texture width], [texture height]);
    size_t imageByteCount = imageSize.width * imageSize.height * 4;
    
    void  * imageBytes = malloc(imageByteCount);
    NSUInteger bytesPerRow = imageSize.width * 4;
    MTLRegion   region = MTLRegionMake2D(0, 0, imageSize.width, imageSize.height);
    [texture getBytes :imageBytes bytesPerRow:bytesPerRow fromRegion:region mipmapLevel:0];
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,
                                                              imageBytes,
                                                              imageByteCount,
                                                              ReleaseDataCallback);
    const int bitsPerComponent = 8;
    const int bitsPerPixel = 32;
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(imageSize.width,
                                        imageSize.height,
                                        bitsPerComponent,
                                        bitsPerPixel,
                                        bytesPerRow,
                                        colorspace,
                                        bitmapInfo,
                                        provider,
                                        NULL,
                                        false,
                                        renderingIntent);
    UIImage * img = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:UIImageOrientationDownMirrored];
    CFRelease(provider);
    CFRelease(colorspace);
    CFRelease(imageRef);
    
    return img;
}

@end