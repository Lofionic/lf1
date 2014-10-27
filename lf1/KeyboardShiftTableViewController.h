//
//  KeyboardShiftTableViewController.h
//  LF1
//
//  Created by Chris on 26/10/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//
#import "KeyboardView.h"
#import "SilentPickerView.h"
#import <UIKit/UIKit.h>

@interface KeyboardShiftTableViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) IBOutlet SilentPickerView *pickerView;
@property (nonatomic, weak) KeyboardView *keyboardVew;

@property (nonatomic, strong) NSArray *pickerData;

@end
