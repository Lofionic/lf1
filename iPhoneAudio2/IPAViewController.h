//
//  IPAViewController.h
//  iPhoneAudio2
//
//  Created by Chris on 22/02/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "controllerView.h"

@class AudioController;

@interface IPAViewController : UIViewController <ControllerViewDelegate>

@property (nonatomic, strong) AudioController *audioController;
@property (nonatomic, strong) IBOutlet UISlider *oscBalance;
@property (nonatomic, strong) IBOutlet UISegmentedControl *osc1Wave;
@property (nonatomic, strong) IBOutlet UISegmentedControl *osc2Wave;

@property (nonatomic, strong) IBOutlet UISlider *masterVolume;

@property (nonatomic, strong) IBOutlet controllerView *controller;

@property (nonatomic, strong) IBOutlet UISwitch *engineSwitch;

@end
