//
//  KeyboardControlView.h
//  iPhoneAudio2
//
//  Created by Chris on 22/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "ControlView.h"
#import "CVController.h"
#import "SwitchControl.h"


@interface KeyboardControlView : ControlView

@property (nonatomic, weak) CVController *cvController;

@property (nonatomic, strong) IBOutlet CCRRotaryControl *glideControl;
@property (nonatomic, strong) IBOutlet SwitchControl *glissSwitch;

@end
