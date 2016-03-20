//
//  MetalView.h
//  Draw3d
//
//  Created by Volvet Zhang on 16/3/20.
//  Copyright © 2016年 volvet. All rights reserved.
//

@import UIKit;
@import Metal;
@import QuartzCore;


@protocol MetalViewDelegate;


@interface MetalView : UIView

@property (nonatomic, weak)   id<MetalViewDelegate>   mDelegate;

@property (nonatomic, readonly)  CAMetalLayer  * mMetalLayer;

@property (nonatomic)  NSInteger   mPreferredFramePerSecond;

@property (nonatomic)  MTLPixelFormat   mPixelFormat;

@property (nonatomic, assign)  MTLClearColor    mClearColor;

@property (nonatomic, readonly) NSTimeInterval   mFrameDuration;

@property (nonatomic, readonly) id<CAMetalDrawable>  mCurrentDrawable;

@property (nonatomic, readonly)  MTLRenderPassDescriptor  * mCurrentRenderPassDescriptor;

@end


@protocol MetalViewDelegate <NSObject>

- (void) drawInView:(MetalView*)view;

@end