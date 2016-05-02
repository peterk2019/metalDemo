//
//  MainBoundleTextureProvider.h
//  MetalImage
//
//  Created by Volvet Zhang on 16/5/2.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageFilter.h"

@interface MainBoundleTextureProvider : NSObject<TextureProvider>

+ (instancetype)  textureProviderWithImageNamed :(NSString*)imageName context:(IPContext*)context;

@end
