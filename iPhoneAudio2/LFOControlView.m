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
    
    UIImage *zeroTenBackground = [UIImage imageNamed:@"ZeroTen_Background"];
    _amountControl1.backgroundImage = zeroTenBackground;
 
    UIImage *LFORateBackground = [UIImage imageNamed:@"LFORate_Background"];
    _rateControl1.backgroundImage = LFORateBackground;

    UIImage *chicken4 = [UIImage imageNamed:@"ChickenKnob_4way"];
    _waveformControl1.spriteSheet = chicken4;
    _waveformControl1.segments = 4;
    _waveformControl1.selectedSegmentIndex = 2;
    
    _amountControl1.value = 1.0;
    _rateControl1.value = 0.8;
    _destinationControl1.selectedSegmentIndex = 1;

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
    
    CCRSegmentedRotaryControl *control = (CCRSegmentedRotaryControl*)sender;
    NSInteger tag = control.tag;
    
    NSLog(@"%li", (long)control.selectedSegmentIndex);
    
    if (_delegate) {
        [_delegate LFOControlView:self LFOID:tag didChangeDestinationTo:control.selectedSegmentIndex];
    }
}

-(IBAction)changeWaveform:(id)sender {
    
    CCRSegmentedRotaryControl *control = (CCRSegmentedRotaryControl*)sender;
    NSInteger tag = control.tag;
    
    if (_delegate) {
        [_delegate LFOControlView:self LFOID:tag didChangeWaveformTo:control.selectedSegmentIndex];
    }
}

@end
