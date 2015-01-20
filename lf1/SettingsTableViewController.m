//
//  SettingsTableViewController.m
//  LF1
//
//  Created by Chris on 25/10/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//
#import "Defines.h"
#import "SettingsTableViewController.h"
#import "AudioEngine.h"
#import "KeyboardView.h"
#import "AppDelegate.h"
#import "PGMidi.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(midiChange)
                                                 name:MIDI_CHANGE_NOTIFICATION
                                               object:nil];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName: [UIFont fontWithName:@"Avenir" size:16]
       }
     forState:UIControlStateNormal];
    
    self.leftHandSwitch = [[UISwitch alloc] init];
    [self.leftHandSwitch setOn:[[[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_KEY_LEFTHANDMODE] boolValue]];
    [self.leftHandSwitch addTarget:self
                            action:@selector(leftHandSwitchChanged)
                  forControlEvents:UIControlEventValueChanged];
    [self.leftHandTableViewCell setAccessoryView:self.leftHandSwitch];
    [self.leftHandTableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
}

-(void)leftHandSwitchChanged {
    [[NSUserDefaults standardUserDefaults] setValue:@(self.leftHandSwitch.isOn) forKey:USER_DEFAULTS_KEY_LEFTHANDMODE];
    NSDictionary *dictionary = @{ @"LeftHandModeOn" : @(self.leftHandSwitch.isOn)} ;
    [[NSNotificationCenter defaultCenter] postNotificationName:LEFT_HAND_MODE_CHANGE_NOTIFICATION object:nil userInfo:dictionary];
}

-(void)midiChange {
    [self updateUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUI];
}

-(void)updateUI {
     AudioEngine *ae = AUDIO_ENGINE;
    
    if (ae.midiSource) {
        self.midiInTableViewCell.detailTextLabel.text = ae.midiSource.name;
    } else {
        self.midiInTableViewCell.detailTextLabel.text = @"None";
    }
    
    NSString *pitchWheelRangeString;
    NSInteger pitchWheelRange = ae.cvController.pitchWheelRange;
    if (pitchWheelRange == 1) {
        pitchWheelRangeString = @"±1 Semitone";
    } else if (pitchWheelRange < 12) {
        pitchWheelRangeString = [NSString stringWithFormat:@"±%li Semitones", (long)pitchWheelRange];
    } else if (pitchWheelRange == 12) {
        pitchWheelRangeString = [NSString stringWithFormat:@"±1 Octave"];
    }
    
    self.pitchwheelTableViewCell.detailTextLabel.text = pitchWheelRangeString;
    
    
    KeyboardView *keyboardView = MAIN_VIEW_CONTROLLER.keyboardView;
    NSString *keyboardShiftString;
    switch (keyboardView.keyboardShift) {
        case 0:
            keyboardShiftString = @"-2 Octaves";
            break;
        case 1:
            keyboardShiftString = @"-1 Octave";
            break;
        case 2:
            keyboardShiftString = @"0 Octaves";
            break;
        case 3:
            keyboardShiftString = @"+1 Octave";
            break;
        case 4:
            keyboardShiftString = @"+2 Octaves";
            break;
        default:
            keyboardShiftString = @"Undefined";
            break;
    }
    self.keyboardShiftTableViewCell.detailTextLabel.text = keyboardShiftString;
}

@end
