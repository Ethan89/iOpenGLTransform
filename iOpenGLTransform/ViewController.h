//
//  ViewController.h
//  iOpenGLTransform
//
//  Created by Ethan Guo on 17/2/16.
//  Copyright © 2017年 com.bjdv. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OpenGLView.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet OpenGLView *openGLView;

@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet UISlider *xPosSlider;
@property (weak, nonatomic) IBOutlet UISlider *yPosSlider;
@property (weak, nonatomic) IBOutlet UISlider *zPosSlider;

- (IBAction)xSliderValueChanged:(id)sender;
- (IBAction)ySliderValueChanged:(id)sender;
- (IBAction)zSliderValueChanged:(id)sender;
- (IBAction)resetButtonClicked:(id)sender;
@end

