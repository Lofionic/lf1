//
//  MidiInputTableViewController.h
//  LF1
//
//  Created by Chris on 25/10/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//
#import "AudioEngine.h"
#import <UIKit/UIKit.h>
#import "PGMidi.h"
@interface MidiInputTableViewController : UITableViewController

@property (nonatomic, weak) AudioEngine *ae;
@property (nonatomic, weak) PGMidi *midi;
@end
