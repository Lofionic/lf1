//
//  IPAViewController.h
//  iPhoneAudio2
//
//  Created by Chris on 22/02/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardView.h"
#import "OscillatorControlView.h"
#import "EnvelopeControlView.h"
#import "FilterControlView.h"
#import "LFOControlView.h"

@class AudioController;

@interface IPAViewController : UIViewController <ControllerViewDelegate>

@property (nonatomic, strong) AudioController *audioController;

// Parameter controls

@property (nonatomic, strong) IBOutlet KeyboardView *controller;

@property (nonatomic, strong) OscillatorControlView *oscView;
@property (nonatomic, strong) EnvelopeControlView *envView;
@property (nonatomic, strong) FilterControlView *filterView;
@property (nonatomic, strong) LFOControlView *lfoView;

@property (nonatomic, strong) IBOutlet UIScrollView *iPhoneControlsView;
@property (nonatomic, strong) IBOutlet UIView *iPadControlsView1;
@property (nonatomic, strong) IBOutlet UIView *iPadControlsView2;
@property (nonatomic, strong) IBOutlet UIView *iPadControlsView3;
@property (nonatomic, strong) IBOutlet UIView *iPadControlsView4;

@end
