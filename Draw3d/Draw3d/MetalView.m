//
//  MetalView.m
//  Draw3d
//
//  Created by Volvet Zhang on 16/3/20.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import "MetalView.h"


@interface MetalView()

@property (strong) id<CAMetalDrawable>  mCurrentDrawable;
@property (assign) NSTimeInterval       mFrameDuration;
@property (strong) id<MTLTexture>       mDepthTexture;
@property (strong) CADisplayLink       *mDisplayLink;

@end


@implementation MetalView

+ (Class) layerClass {
    return [CAMetalLayer class];
}

- (CAMetalLayer*) metalLayer {
    return (CAMetalLayer*)self.layer;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if( self = [super initWithCoder:aDecoder] ){
        [self mtlInit];
    }
    
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    if( self = [super initWithFrame:frame] ){
        [self mtlInit];
    }
    
    return self;
}

- (void) dealloc {
    [self.mDisplayLink invalidate];
}

- (void) mtlInit {
    self.metalLayer.device = MTLCreateSystemDefaultDevice();
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    self.mClearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0);
    self.mPreferredFramePerSecond = 60;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if( self.window ){
        scale = self.window.screen.scale;
    }
    
    CGSize drawableSize = self.bounds.size;
    drawableSize.width *= scale;
    drawableSize.height *= scale;
    
    self.metalLayer.drawableSize = drawableSize;
    [self makeDepthTexture];
}

- (void) makeDepthTexture {
    CGSize drawableSize = self.metalLayer.drawableSize;
    
    if( ([self.mDepthTexture width] != drawableSize.width)  ||
       ([self.mDepthTexture height] != drawableSize.height) ) {
        MTLTextureDescriptor * textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float width:drawableSize.width height:drawableSize.height mipmapped:NO];
        self.mDepthTexture = [self.metalLayer.device newTextureWithDescriptor:textureDescriptor];
    }
    
    return;
}

- (void) setPixelFormat: (MTLPixelFormat) pixelFormat {
    self.metalLayer.pixelFormat = pixelFormat;
}

- (MTLPixelFormat) pixelFormat {
    return self.metalLayer.pixelFormat;
}

- (void) didMoveToWindow {
    [super didMoveToWindow];
    
    const NSTimeInterval idealFrameDuration = 1.0 / 60.0;
    const NSTimeInterval targetFrameDuration = (1.0 / self.mPreferredFramePerSecond);
    const NSInteger frameInterval = round(targetFrameDuration / idealFrameDuration);
    
    if( self.window ){
        [self.mDisplayLink invalidate];
        self.mDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
        self.mDisplayLink.frameInterval = frameInterval;
        [self.mDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        [self.mDisplayLink invalidate];
        self.mDisplayLink = nil;
    }
}

- (void) displayLinkDidFire: (CADisplayLink*)  displayLink {
    @autoreleasepool {
        self.mCurrentDrawable = self.metalLayer.nextDrawable;
        self.mFrameDuration = self.mDisplayLink.duration;
    
        if( [self.mDelegate respondsToSelector:@selector(drawInView:)] ) {
           [self.mDelegate drawInView:self];
        }
    }
}

- (MTLRenderPassDescriptor *) currentRenderPassDescriptor {
    MTLRenderPassDescriptor * passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    
    passDescriptor.colorAttachments[0].texture = [self.mCurrentDrawable texture];
    passDescriptor.colorAttachments[0].clearColor = self.mClearColor;
    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    
    passDescriptor.depthAttachment.texture = self.mDepthTexture;
    passDescriptor.depthAttachment.clearDepth = 1.0;
    passDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
    passDescriptor.depthAttachment.storeAction = MTLStoreActionDontCare;
    
    return passDescriptor;
}

@end
