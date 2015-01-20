//
//  SettingsTableViewController.h
//  LF1
//
//  Created by Chris on 25/10/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UITableViewCell *midiInTableViewCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *pitchwheelTableViewCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *keyboardShiftTableViewCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *leftHandTableViewCell;
@property (nonatomic, strong) UISwitch *leftHandSwitch;

@end
