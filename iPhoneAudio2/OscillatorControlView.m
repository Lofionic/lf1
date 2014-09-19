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
    
    UIImage *zeroTenBackground = [UIImage imageNamed:@"ZeroTen_Background"];
    _osc1vol.backgroundImage = zeroTenBackground;
    _osc2vol.backgroundImage = zeroTenBackground;
    
    UIImage *osc2FreqBackground = [UIImage imageNamed:@"Osc2Freq_Background"];
    _osc2freq.backgroundImage = osc2FreqBackground;
    _osc2freq.enableDefaultValue = true;
    
    _osc2freq.value = 0.0;
    _osc2freq.defaultValue = 0.5;

    _osc1vol.value = 0.5;
    _osc1vol.defaultValue = 0.5;
    _osc1wave.selectedSegmentIndex = 1;
    
    _osc2vol.value = 0.5;
    _osc2vol.defaultValue = 0.5;
    _osc2wave.selectedSegmentIndex = 2;
    
    UIImage *chicken4 = [UIImage imageNamed:@"ChickenKnob_4way"];
    _osc1octave.spriteSheet = chicken4;
    _osc1octave.segments = 4;
    _osc1octave.selectedSegmentIndex = 0;
    
    _osc2octave.spriteSheet = chicken4;
    _osc2octave.segments = 4;
    _osc2octave.selectedSegmentIndex = 2;
    
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
        
        [_delegate oscillatorControlView:self oscillator:(int)tag FreqChangedTo:control.value];
    }
}

-(IBAction)oscillatorWaveformChanged:(id)sender {
    CCRSegmentedRotaryControl *control = (CCRSegmentedRotaryControl*)sender;
    NSInteger tag = control.tag;
    
    
    
    if (_delegate) {
        [_delegate oscillatorControlView:self oscillator:(int)tag WaveformChangedTo:(int)control.selectedSegmentIndex];
    }
}

-(IBAction)oscillatorOctaveChanged:(id)sender {
    CCRSegmentedRotaryControl *control = (CCRSegmentedRotaryControl*)sender;
    NSInteger tag = control.tag;

    if (_delegate) {
        [_delegate oscillatorControlView:self oscillator:(int)tag OctaveChangedTo:(int)control.selectedSegmentIndex];
    }
}
@end
