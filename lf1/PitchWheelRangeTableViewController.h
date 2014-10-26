//
//  PitchWheelRangeTableViewController.h
//  LF1
//
//  Created by Chris on 26/10/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//
#import "AudioEngine.h"
#import <UIKit/UIKit.h>

@interface PitchWheelRangeTableViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) IBOutlet UIPickerView* pickerView;
@property (nonatomic, strong) NSArray *pickerViewData;
@property (nonatomic, strong) AudioEngine *ae;

@end
