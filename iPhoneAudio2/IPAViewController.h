//
//  IPAViewController.h
//  iPhoneAudio2
//
//  Created by Chris on 22/02/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "keyboardView.h"
#import "CCRRotaryControl.h"
#import "OscillatorControlView.h"
#import "EnvelopeControlView.h"


@class AudioController;

@interface IPAViewController : UIViewController <ControllerViewDelegate>

@property (nonatomic, strong) AudioController *audioController;

// Parameter controls

@property (nonatomic, strong) IBOutlet keyboardView *controller;

@property (nonatomic, strong) OscillatorControlView *oscView;
@property (nonatomic, strong) EnvelopeControlView *envView;
@property (nonatomic, strong) IBOutlet UIScrollView *controlsView;

@end
