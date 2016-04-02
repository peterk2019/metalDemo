//
//  UIMetalView.h
//  Teapot
//
//  Created by Volvet Zhang on 16/4/2.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>

@protocol UIMetalViewDelegate;


@interface UIMetalView : UIView

@property (nonatomic, weak)  id<UIMetalViewDelegate>   delegate;

@property (nonatomic, readonly)   CAMetalLayer    * metalLayer;

@property (nonatomic)   NSInteger   preferredFramesPerSecond;

@property (nonatomic)   MTLPixelFormat   colorPixelFormat;

@property (nonatomic, assign)  MTLClearColor   clearColor;

@property (nonatomic, readonly)  NSTimeInterval   frameDuration;

@property (nonatomic, readonly)  id<CAMetalDrawable>   currentDrawable;

@property (nonatomic, readonly)  MTLRenderPassDescriptor   * currentRenderPassDescriptor;

@end

@protocol UIMetalViewDelegate <NSObject>

- (void) drawInView :(UIMetalView *) view;

@end
