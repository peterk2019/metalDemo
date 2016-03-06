//
//  ViewController.h
//  HelloMetal
//
//  Created by Volvet Zhang on 16/3/5.
//  Copyright © 2016年 Volvet Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AVFoundation;
@import Metal;
@import MetalKit;
@import MetalPerformanceShaders;

@interface ViewController :  UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate, MTKViewDelegate>


@end

