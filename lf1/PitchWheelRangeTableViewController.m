//
//  PitchWheelRangeTableViewController.m
//  LF1
//
//  Created by Chris on 26/10/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//
#import "AppDelegate.h"
#import "Defines.h"

#import "PitchWheelRangeTableViewController.h"

@interface PitchWheelRangeTableViewController ()

@end

@implementation PitchWheelRangeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.ae = AUDIO_ENGINE;
}

-(void)viewWillAppear:(BOOL)animated {

    [self.pickerView selectRow:self.ae.cvController.pitchWheelRange - 1 inComponent:0 animated:NO];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 12;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) {
        return @"±1 Semitone";
    } else if (row < 11) {
        return [NSString stringWithFormat:@"±%li Semitones", (long)row + 1];
    } else if (row == 11) {
        return [NSString stringWithFormat:@"±1 Octave"];
    }
    
    return [self.pickerViewData objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.ae.cvController.pitchWheelRange = row + 1;
}

@end
