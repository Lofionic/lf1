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
    _osc2freq.defaultValue = 0.5;
    
    UIImage *chicken4 = [UIImage imageNamed:@"ChickenKnob_4way"];
    _osc1octave.spriteSheet = chicken4;
    _osc1octave.segments = 4;
    
    _osc2octave.spriteSheet = chicken4;
    _osc2octave.segments = 4;
    
}

-(IBAction)oscillatorVolumeChanged:(id)sender {
    CCRRotaryControl *control = (CCRRotaryControl*)sender;
    NSInteger tag = control.tag;
    
    if (_delegate) {
        [_delegate oscillatorControlView:self oscillator:(int)tag VolumeChangedTo:control.value];
    }
}

-(IBAction)oscillatorFreqChanged:(id)sender {
    
    CCRRotaryControl *control = (CCRRotaryControl*)sender;
    NSInteger tag = control.tag;
    float value = control.value;
    
    switch (tag) {
        case 0:
            if (_osc1) {
                [_osc1 setFreq_adjust:value];
            }
            break;
        case 1:
            if (_osc2) {
                [_osc2 setFreq_adjust:value];
            }
        default:
            break;
    }
}

-(IBAction)oscillatorWaveformChanged:(id)sender {
    CCRSegmentedRotaryControl *control = (CCRSegmentedRotaryControl*)sender;
    NSInteger tag = control.tag;
    NSInteger value = control.index;
    
    switch (tag) {
        case 0:
            if (_osc1) {
                [_osc1 setWaveform:(OscillatorWaveform)value];
            }
            break;
        case 1:
            if (_osc2) {
                [_osc2 setWaveform:(OscillatorWaveform)value];
            }
        default:
            break;
    }
}

-(IBAction)oscillatorOctaveChanged:(id)sender {
    CCRSegmentedRotaryControl *control = (CCRSegmentedRotaryControl*)sender;
    NSInteger tag = control.tag;
    NSInteger value = control.index;
    
    switch (tag) {
        case 0:
            if (_osc1) {
                [_osc1 setOctave:(OscillatorWaveform)value];
            }
            break;
        case 1:
            if (_osc2) {
                [_osc2 setOctave:(OscillatorWaveform)value];
            }
        default:
            break;
    }
}
@end
