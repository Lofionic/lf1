//
//  KeyboardShiftTableViewController.m
//  LF1
//
//  Created by Chris on 26/10/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//
#import "Defines.h"
#import "AppDelegate.h"
#import "KeyboardShiftTableViewController.h"

@interface KeyboardShiftTableViewController ()

@end

@implementation KeyboardShiftTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pickerData = @[
                        @"-2 Octaves",
                        @"-1 Octave",
                        @"±0 Octaves",
                        @"+1 Octave",
                        @"+2 Octaves"];
    self.keyboardVew = MAIN_VIEW_CONTROLLER.keyboardView;
    [self.pickerView setSoundsEnabled:NO];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self.pickerView selectRow:self.keyboardVew.keyboardShift inComponent:0 animated:NO];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerData count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.pickerData[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.keyboardVew.keyboardShift = row;
}

@end
