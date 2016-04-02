//
//  ViewController.m
//  Teapot
//
//  Created by Volvet Zhang on 16/3/27.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import <simd/simd.h>
#import "ViewController.h"
#import "UIMetalView.h"
#import "MetalViewRender.h"


@interface ViewController ()

@property (nonatomic, strong)  MetalViewRender * metalViewRender;

@end

@implementation ViewController

- (UIMetalView*) uiMetalView {
    return (UIMetalView*) self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _metalViewRender = [[MetalViewRender alloc] init];
    self.uiMetalView.delegate = _metalViewRender;
}

- (BOOL) prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
