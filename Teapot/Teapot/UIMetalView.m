//
//  UIMetalView.m
//  Teapot
//
//  Created by Volvet Zhang on 16/4/2.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import "UIMetalView.h"

@interface UIMetalView()

@property (nonatomic, strong) id<MTLTexture>  depthTexture;

@property (nonatomic)  id<CAMetalDrawable>   currentDrawable;

@property (nonatomic)  NSTimeInterval   frameDuration;

@property (nonatomic, strong)  CADisplayLink * displayLink;

@end


@implementation UIMetalView


+ (Class) layerClass {
    return [CAMetalLayer class];
}

- (CAMetalLayer*)  metalLayer {
    return (CAMetalLayer*)self.metalLayer;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if( self = [super initWithCoder:aDecoder] ){
        [self commonInit];
    }
    
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    if( self = [super initWithFrame:frame] ){
        [self commonInit];
    }
    
    return self;
}

- (void) commonInit {
    self.preferredFramesPerSecond = 60;
    self.clearColor = MTLClearColorMake(1, 1, 1, 1);
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    self.metalLayer.device = MTLCreateSystemDefaultDevice();
}

- (void) setColorPixelFormat:(MTLPixelFormat)colorPixelFormat {
    self.metalLayer.pixelFormat = colorPixelFormat;
}

- (MTLPixelFormat) colorPixelFormat {
    return self.metalLayer.pixelFormat;
}

- (void) makeDepthTexture {
    CGSize drawableSize = self.metalLayer.drawableSize;
    
    if( ([self.depthTexture width] != drawableSize.width) ||
       ([self.depthTexture height] != drawableSize.height) ) {
        MTLTextureDescriptor * descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float width:drawableSize.width height:drawableSize.height mipmapped:NO];
        self.depthTexture = [self.metalLayer.device newTextureWithDescriptor:descriptor];
    }
}

- (void) setFrame :(CGRect)frame {
    [super setFrame :frame];
    
    CGFloat  scale = [UIScreen mainScreen].scale;
    
    if( self.window ){
        scale = self.window.screen.scale;
    }
    
    CGSize drawableSize = self.bounds.size;
    
    drawableSize.width *= scale;
    drawableSize.height *= scale;
    
    self.metalLayer.drawableSize = drawableSize;
    
    [self makeDepthTexture];
}

- (void) displayLinkDidFire :(CADisplayLink*) displayLink {
    self.currentDrawable = [self.metalLayer nextDrawable];
    self.frameDuration = displayLink.duration;
    
    if( [self.delegate respondsToSelector:@selector(drawInView:)] ){
        [self.delegate drawInView:self];
    }
}

- (void) didMoveToWindow {
    const NSTimeInterval idealFrameDuration = (1.0/60);
    const NSTimeInterval targetFrameDuration = (1.0/self.preferredFramesPerSecond);
    const NSInteger frameInterval = round(targetFrameDuration/idealFrameDuration);
    
    if( self.window ){
        [self.displayLink invalidate];
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
        self.displayLink.frameInterval = frameInterval;
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}


@end
