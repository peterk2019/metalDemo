//
//  ViewController.m
//  Draw3d
//
//  Created by Volvet Zhang on 16/3/19.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import "ViewController.h"
#import "MetalRender.h"

@interface ViewController ()

@property (nonatomic, strong)  MetalRender * mRender;

@end

@implementation ViewController

- (MetalView*) metalView {
    return (MetalView*)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.mRender = [[MetalRender alloc] init];
    self.metalView.mDelegate = self.mRender;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) prefersStatusBarHidden {
    return YES;
}

@end
