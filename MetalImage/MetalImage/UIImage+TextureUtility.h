//
//  TextureUtility.h
//  MetalImage
//
//  Created by Volvet Zhang on 16/5/1.
//  Copyright © 2016年 volvet. All rights reserved.
//

#ifndef TextureUtility_h
#define TextureUtility_h

@import UIKit;

@protocol MTLTexture;

@interface UIImage (TextureUtility)

+ (UIImage*) imageWithMTLTexture: (id<MTLTexture>) texture;

@end


#endif /* TextureUtility_h */
