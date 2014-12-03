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
@property (nonatomic, strong) IBOutlet PresetButton *prevButton;
@property (nonatomic, strong) IBOutlet PresetButton *nextButton;
@property (nonatomic, strong) IBOutlet PresetButton *storeButton;

@property (nonatomic, strong) IBOutlet UIStepper *stepper;

@end
