//
//  IPAViewController.h
//  iPhoneAudio2
//
//  Created by Chris on 22/02/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "controllerView.h"
#import "CCRRotaryControl.h"
#import "OscillatorControlView.h"

@class AudioController;

@interface IPAViewController : UIViewController <ControllerViewDelegate>

@property (nonatomic, strong) AudioController *audioController;

// Parameter controls

@property (nonatomic, strong) IBOutlet controllerView *controller;

@property (nonatomic, strong) OscillatorControlView *oscView;
@property (nonatomic, strong) IBOutlet UIView *controlsView;

@end
