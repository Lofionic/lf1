//
//  MidiInputTableViewController.m
//  LF1
//
//  Created by Chris on 25/10/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//
#import "Defines.h"
#import "MidiInputTableViewController.h"
#import "AppDelegate.h"

@interface MidiInputTableViewController ()

@end

@implementation MidiInputTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.title = @"MIDI Input";
    self.ae = AUDIO_ENGINE;
    self.midi = MIDI_ENGINE;
    
    self.tableView.rowHeight = 60;
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(midiChange)
                                                 name:MIDI_CHANGE_NOTIFICATION
                                               object:nil];
}

-(void)midiChange {
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [self.midi.sources count] + 1;
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"None";
        if (!self.ae.midiSource) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.imageView.image = [UIImage imageNamed:@"cross"];
        
    } else {
        PGMidiSource *source = self.midi.sources[indexPath.row -1];
        cell.textLabel.text = source.name;
        
        if (source == self.ae.midiSource) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if (source.isNetworkSession) {
            cell.imageView.image = [UIImage imageNamed:@"wifi"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"plug"];
        }
    }

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        self.ae.midiSource = nil;
    } else {
        self.ae.midiSource = self.midi.sources[indexPath.row - 1];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
