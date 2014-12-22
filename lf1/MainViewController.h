//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "KeyboardView.h"
#import "OscillatorControlView.h"
#import "EnvelopeControlView.h"
#import "FilterControlView.h"
#import "LFOControlView.h"
#import "PerformanceControlView.h"
#import "PresetController.h"
#import "PresetControlView.h"
#import "NewPresetControlView.h"

@class AudioEngine;

@interface MainViewController : UIViewController

@property (nonatomic, weak) AudioEngine *audioEngine;

@property (nonatomic, strong) IBOutlet KeyboardView *keyboardView;

@property (nonatomic, strong) IBOutlet OscillatorControlView *oscView;
@property (nonatomic, strong) EnvelopeControlView *envView;
@property (nonatomic, strong) FilterControlView *filterView;
@property (nonatomic, strong) LFOControlView *lfoView;
@property (nonatomic, strong) PerformanceControlView *performanceControlView;
@property (nonatomic, strong) NewPresetControlView *presetControlView;

@property (nonatomic, strong) IBOutlet UIScrollView *iPhoneControlsView;
@property (nonatomic, strong) IBOutlet UIView *iPadControlsView1;
@property (nonatomic, strong) IBOutlet UIView *iPadControlsView2;
@property (nonatomic, strong) IBOutlet UIView *iPadControlsView3;
@property (nonatomic, strong) IBOutlet UIView *iPadControlsView4;
@property (nonatomic, strong) IBOutlet UIView *iPadControlsView5;
@property (nonatomic, strong) IBOutlet UIView *iPadControlsView6;

@property (nonatomic ,strong) IBOutlet UIView *transportView;
@property (nonatomic, strong) IBOutlet UILabel *playTimeLabel;
@property (nonatomic, strong) IBOutlet UIImageView *hostIcon;
@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *rewindButon;

@property BOOL inForeground;

@property (nonatomic, strong) PresetController *presetController;

@property (nonatomic, strong) UIPopoverController *settingsPopoverController;
@property (nonatomic, strong) UINavigationController *settingsNavigationController;

@property (nonatomic, strong) IBOutlet UIButton *undoButton;
-(void)updateUndoStatus;

@end
