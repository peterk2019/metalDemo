//
//  ViewController.m
//  MetalImage
//
//  Created by Volvet Zhang on 16/4/23.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import "ViewController.h"
#import "IPContext.h"
#import "ImageFilter.h"
#import "GaussianBlurFilter.h"
#import "SaturationAdjustmentFilter.h"
#import "UIImage+TextureUtility.h"
#import "MainBoundleTextureProvider.h"

@interface ViewController ()

@property (nonatomic, strong)  IPContext *   context;
@property (nonatomic, strong)  id<TextureProvider>    imageProvider;
@property (nonatomic, strong)  SaturationAdjustmentFilter  *  saturationFilter;
@property (nonatomic, strong)  GaussianBlurFilter * gaussionBlurFilter;

@property (nonatomic, strong)  dispatch_queue_t   renderingQueue;
@property (atomic, assign)     uint64_t           jobIndex;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _renderingQueue = dispatch_queue_create("Rendering", DISPATCH_QUEUE_SERIAL);
    [self buildFilterGraph];
    //[self updateImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildFilterGraph {
    _context = [IPContext newContext];
    _imageProvider = [MainBoundleTextureProvider textureProviderWithImageNamed:@"mandrill" context:_context];
    //_saturationFilter = [SaturationAdjustmentFilter filterWithSaturationFactor:self.saturationSlider.value context:_context];
    //_saturationFilter.provider = _imageProvider;
    //_gaussionBlurFilter = [GaussianBlurFilter filterWithRadius:self.blurRadiusSlider.value :_context];
    //_gaussionBlurFilter.provider = _imageProvider;
    _imageView.image = [UIImage imageWithMTLTexture:_imageProvider.texture];
}

- (void)updateImage {
    ++ _jobIndex;
    
    uint64_t currentJobIndex = _jobIndex;
    float blurRadius = _blurRadiusSlider.value;
    float saturation = _saturationSlider.value;
    
    dispatch_sync(_renderingQueue, ^{
        if( currentJobIndex != _jobIndex ) return;
        _gaussionBlurFilter.radius = blurRadius;
        _saturationFilter.saturationFactor = saturation;
        
        id<MTLTexture>  texture = _imageProvider.texture; //_gaussionBlurFilter.texture;
        UIImage * image = [UIImage imageWithMTLTexture:texture];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            _imageView.image = image;
        });
    });
}

- (IBAction)blurRadiusDidChange:(id)sender {
    //[self updateImage];
}

- (IBAction)saturationDidChange:(id)sender {
    //[self updateImage];
}
@end
