//
//  OscillatorView.m
//  iPhoneAudio2
//
//  Created by Chris on 9/11/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "OscillatorControlView.h"


@implementation OscillatorControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

-(void)initializeParameters {
    
    _osc2freq.value = 1.0;
    _osc2freq.defaultValue = 0.5;
    
    _osc1vol.value = 0.5;
    _osc1vol.defaultValue = 0.5;
    _osc1wave.selectedSegmentIndex = 1;
    [self oscillatorWaveformChanged:_osc1wave];
    
    _osc2vol.value = 0.5;
    _osc2vol.defaultValue = 0.5;
    _osc2wave.selectedSegmentIndex = 2;
    [self oscillatorWaveformChanged:_osc2wave];
    
    _osc1octave.selectedSegmentIndex = 1;
    [self oscillatorOctaveChanged:_osc1octave];
    
    _osc2octave.selectedSegmentIndex = 2;
    [self oscillatorOctaveChanged:_osc2octave];
    
}

-(IBAction)oscillatorVolumeChanged:(id)sender {
    CCRRotaryControl *control = (CCRRotaryControl*)sender;
    NSInteger tag = control.tag;
    
    if (_delegate) {
        [_delegate oscillatorControlView:self oscillator:(int)tag VolumeChangedTo:control.value];
    }
}

-(IBAction)oscillatorFreqChanged:(id)sender {
    if (_delegate) {
        CCRRotaryControl *control = (CCRRotaryControl*)sender;
        NSInteger tag = control.tag;
        
        float inValue = (control.value * 2.0) - 1.0;
        
        float outValue = (powf(powf(2, (1.0 / 12.0)), inValue * 7));
        
        [_delegate oscillatorControlView:self oscillator:(int)tag FreqChangedTo:outValue];
    }
}

-(IBAction)oscillatorWaveformChanged:(id)sender {
    UISegmentedControl *control = (UISegmentedControl*)sender;
    NSInteger tag = control.tag;
    
    if (_delegate) {
        [_delegate oscillatorControlView:self oscillator:(int)tag WaveformChangedTo:(int)control.selectedSegmentIndex];
    }
}

-(IBAction)oscillatorOctaveChanged:(id)sender {
    UISegmentedControl *control = (UISegmentedControl*)sender;
    NSInteger tag = control.tag;

    if (_delegate) {
        [_delegate oscillatorControlView:self oscillator:(int)tag OctaveChangedTo:(int)control.selectedSegmentIndex];
    }
}
@end
