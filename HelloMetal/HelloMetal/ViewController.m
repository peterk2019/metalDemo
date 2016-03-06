//
//  ViewController.m
//  HelloMetal
//
//  Created by Volvet Zhang on 16/3/5.
//  Copyright © 2016年 Volvet Zhang. All rights reserved.
//

#import "ViewController.h"
#import "VideoMetalView.h"

@interface ViewController () {
    //AVCaptureSession    *mCaptureSession;
}

@property(nonatomic, strong) VideoMetalView   * mMetalView;

@property(nonatomic, strong) id<MTLCommandQueue>  mMetalCommandQueue;

@property(nonatomic, strong) id<MTLTexture>   mSourceTexture;

@end



@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.mMetalView = (VideoMetalView*) self.view;
    self.mMetalView.device = MTLCreateSystemDefaultDevice();
    
    if( !MPSSupportsMTLDevice(self.mMetalView.device) ){
        NSLog(@"This device can't support Metal Performance Shaders!");
        return;
    }
    
    [self setupView];
    
    [self setupMetal];
    
    [self loadAssets];
    
    //[self startCapture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear :animated];
    //[self stopCapture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView {
    self.mMetalView.delegate = self;
    self.mMetalView.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
    self.mMetalView.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    self.mMetalView.framebufferOnly = FALSE;
}

- (void)setupMetal {
    self.mMetalCommandQueue = [self.mMetalView.device newCommandQueue];
}

- (void)loadAssets {
    MTKTextureLoader  * loader = [[MTKTextureLoader alloc] initWithDevice:self.mMetalView.device];
    NSBundle  * mainBundle = [NSBundle mainBundle];
    
    NSURL *url = [mainBundle URLForResource:@"photo_night" withExtension:@"jpg"];
    
    self.mSourceTexture = [loader newTextureWithContentsOfURL:url options:nil error:nil];
}

- (void)render {
    // Create a new command buffer for each renderpass to the current drawable.
    id<MTLCommandBuffer> commandBuffer = [self.mMetalCommandQueue commandBuffer];
    
    // Initialize MetalPerformanceShaders gaussianBlur with Sigma = 10.0f.
    MPSImageGaussianBlur *gaussianblur = [[MPSImageGaussianBlur alloc] initWithDevice:self.mMetalView.device sigma:1.0f];
    
    // Run MetalPerformanceShader gaussianblur
    [gaussianblur encodeToCommandBuffer:commandBuffer
                          sourceTexture:self.mSourceTexture
                     destinationTexture:self.mMetalView.currentDrawable.texture];
    
    // Schedule a present using the current drawable.
    [commandBuffer presentDrawable:self.mMetalView.currentDrawable];
    
    // Finalize command buffer.
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
}

/*
- (void) startCapture {
    mCaptureSession = [[AVCaptureSession alloc] init];
    
    [mCaptureSession beginConfiguration];
    [mCaptureSession setSessionPreset:AVCaptureSessionPresetHigh];
    
    // Get the a video device with preference to the front facing camera
    AVCaptureDevice* videoDevice = nil;
    NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice* device in devices)
    {
        if ([device position] == AVCaptureDevicePositionFront)
        {
            videoDevice = device;
        }
    }
    
    if(videoDevice == nil)
    {
        videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    if(videoDevice == nil)
    {
        NSLog(@">> ERROR: Couldnt create a AVCaptureDevice");
        assert(0);
    }
    
    NSError *error;
    
    // Device input
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (error)
    {
        NSLog(@">> ERROR: Couldnt create AVCaptureDeviceInput");
        assert(0);
    }
    
    [mCaptureSession addInput:deviceInput];
    
    // Create the output for the capture session.
    AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    // Set the color space.
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                             forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    // Set dispatch to be on the main thread to create the texture in memory and allow Metal to use it for rendering
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    [mCaptureSession addOutput:dataOutput];
    [mCaptureSession commitConfiguration];
    
    // this will trigger capture on its own queue
    [mCaptureSession startRunning];

}

- (void)  stopCapture {
    [mCaptureSession stopRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    //NSLog(@"captureOutput");
}*/

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

- (void)drawInMTKView:(nonnull MTKView *)view {
    @autoreleasepool {
        [self render];
    }
}

@end
