//
//  MetalView.h
//  Draw2d
//
//  Created by Volvet Zhang on 16/3/18.
//  Copyright © 2016年 volvet. All rights reserved.
//

@import UIKit;
@import Metal;
@import QuartzCore;

@interface MetalView : UIView

@property (nonatomic, readonly) CAMetalLayer   *mMetalLayer;

@end
