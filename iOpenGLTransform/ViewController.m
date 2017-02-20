//
//  ViewController.m
//  iOpenGLTransform
//
//  Created by Ethan Guo on 17/2/16.
//  Copyright © 2017年 com.bjdv. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)dealloc {
    
    self.openGLView = nil;
    self.controlView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)xSliderValueChanged:(id)sender {
    UISlider *xSlider = (UISlider *)sender;
    float currentXValue = xSlider.value;
    
    [self.openGLView setXPos:currentXValue];
}

- (IBAction)ySliderValueChanged:(id)sender {
    UISlider *ySlider = (UISlider *)sender;
    float currentYValue = ySlider.value;
    
    [self.openGLView setYPos:currentYValue];
}

- (IBAction)zSliderValueChanged:(id)sender {
    UISlider *zSlider = (UISlider *)sender;
    float currentZValue = zSlider.value;
    NSLog(@"zvalue: %f", currentZValue);
    
    [self.openGLView setZPos:currentZValue];
}

- (IBAction)resetButtonClicked:(id)sender {
    [self.openGLView resetTransform];
    [self.xPosSlider setValue:self.openGLView.xPos];
    [self.yPosSlider setValue:self.openGLView.yPos];
    [self.zPosSlider setValue:self.openGLView.zPos];
}
@end
