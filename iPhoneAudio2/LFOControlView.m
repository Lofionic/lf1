//
//  LFOControlView.m
//  iPhoneAudio2
//
//  Created by Chris on 16/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "LFOControlView.h"

@implementation LFOControlView

-(void)initializeParameters {
    
    _amountControl1.value = 1.0;
    _rateControl1.value = 0.8;
    _destinationControl1.selectedSegmentIndex = 1;
    [self changeDestination:_destinationControl1];
    
    _waveformControl1.selectedSegmentIndex = 2;
    [self changeWaveform:_waveformControl1];
    
    UIImage *moogA = [UIImage imageNamed:@"moog_a"];
    _amountControl1.spriteSheet = moogA;
    _amountControl1.spriteSize = CGSizeMake(140, 140);
    _rateControl1.spriteSheet = moogA;
    _rateControl1.spriteSize = CGSizeMake(140, 140);
}

-(IBAction)changeRate:(id)sender {
    
    CCRRotaryControl *control = (CCRRotaryControl*)sender;
    NSInteger tag = control.tag;
    
    if (_delegate) {
        [_delegate LFOControlView:self LFOID:tag didChangeRateTo:control.value];
    }
}

-(IBAction)changeAmount:(id)sender {
    
    CCRRotaryControl *control = (CCRRotaryControl*)sender;
    NSInteger tag = control.tag;
    
    if (_delegate) {
        [_delegate LFOControlView:self LFOID:tag didChangeAmountTo:control.value];
    }
}

-(IBAction)changeDestination:(id)sender {
    
    UISegmentedControl *control = (UISegmentedControl*)sender;
    NSInteger tag = control.tag;
    
    if (_delegate) {
        [_delegate LFOControlView:self LFOID:tag didChangeDestinationTo:control.selectedSegmentIndex];
    }
}

-(IBAction)changeWaveform:(id)sender {
    
    UISegmentedControl *control = (UISegmentedControl*)sender;
    NSInteger tag = control.tag;
    
    if (_delegate) {
        [_delegate LFOControlView:self LFOID:tag didChangeWaveformTo:control.selectedSegmentIndex];
    }
}

@end
