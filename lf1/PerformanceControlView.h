//
//  KeyboardControlView.h
//  iPhoneAudio2
//
//  Created by Chris on 22/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "ControlView.h"
#import "CVComponent.h"
#import "SwitchControl.h"
#import "PitchbendWheelControl.h"

@interface PerformanceControlView : ControlView

@property (nonatomic, weak) CVComponent *cvComponent;

@property (nonatomic, strong) IBOutlet CCRRotaryControl *glideControl;
@property (nonatomic, strong) IBOutlet SwitchControl *glissSwitch;
@property (nonatomic, strong) IBOutlet PitchbendWheelControl *pitchbendControl;

@end
