//
//  ViewController.h
//  MetalImage
//
//  Created by Volvet Zhang on 16/4/23.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UISlider *blurRadiusSlider;

@property (weak, nonatomic) IBOutlet UISlider *saturationSlider;

- (IBAction)blurRadiusDidChange:(id)sender;


- (IBAction)saturationDidChange:(id)sender;

@end

