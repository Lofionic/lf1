//
//  NewPresetControlView.h
//  LF1
//
//  Created by Chris on 03/12/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PresetController.h"
#import "ControlView.h"
#import "PresetButton.h"

@interface NewPresetControlView : ControlView

@property (nonatomic, strong) PresetController *presetController;
@property (nonatomic, strong) IBOutlet UILabel *presetLabel;
@property (nonatomic, strong) IBOutlet UIStepper *presetStepper;
@property (nonatomic, strong) IBOutlet UIButton* storeButton;

@property BOOL isStoring;
@property BOOL isShowingTutorialAlert;
@property NSInteger storeIndex;
@property NSInteger storeTimeout;
@property NSInteger storeConfirmTimeout;

@property (nonatomic, strong) IBOutlet UIStepper *stepper;

@end
