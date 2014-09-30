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
#import "KeyboardControlView.h"
#import <AVFoundation/AVFoundation.h>
#import "PresetController.h"

@class AudioEngine;

@interface IPAViewController : UIViewController

@property (nonatomic, strong) AudioEngine *audioEngine;

// Parameter controls

@property (nonatomic, strong) IBOutlet KeyboardView *keyboardView;

@property (nonatomic, strong) OscillatorControlView *oscView;
@property (nonatomic, strong) EnvelopeControlView *envView;
@property (nonatomic, strong) FilterControlView *filterView;
@property (nonatomic, strong) LFOControlView *lfoView;
@property (nonatomic, strong) KeyboardControlView *keyboardControlView;

@property (nonatomic, strong) IBOutlet UIScrollView *iPhoneControlsView;
@property (nonatomic, strong) IBOutlet UIView *iPadControlsView1;
@property (nonatomic, strong) IBOutlet UIView *iPadControlsView2;
@property (nonatomic, strong) IBOutlet UIView *iPadControlsView3;
@property (nonatomic, strong) IBOutlet UIView *iPadControlsView4;
@property (nonatomic, strong) IBOutlet UIView *iPadControlsView5;

@property (nonatomic, strong) PresetController *presetController;

-(void)handleInterruption: (NSNotification*) aNotification;

@end
