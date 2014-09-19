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
    
    _amountControl1.value = 0.2;
    _rateControl1.value = 0.7;
    _destinationControl1.selectedSegmentIndex = 0;

}

-(IBAction)changeRate:(id)sender {
    CCRRotaryControl *control = (CCRRotaryControl*)sender;
    float value = control.value;
    
    if (_lfo) {
        // Scale value
        value = (value * 0.999) + 0.001;
        
        // Return exponential value
        [_lfo setFreq:(powf(value, 4))];
    }
}

-(IBAction)changeAmount:(id)sender {
    CCRRotaryControl *control = (CCRRotaryControl*)sender;
    float value = control.value;
    
    if (_lfo) {
        // Return exponential value
        [_lfo setAmp:(powf(value, 2))];
    }
}

-(IBAction)changeDestination:(id)sender {
    
    CCRSegmentedRotaryControl *control = (CCRSegmentedRotaryControl*)sender;
    if (_lfo) {
        switch (control.selectedSegmentIndex) {
            case 0:
                [_osc1 setLfo:_lfo];
                [_osc2 setLfo:_lfo];
                [_vcf setLfo:nil];
                break;
            case 1:
                [_osc1 setLfo:nil];
                [_osc2 setLfo:_lfo];
                [_vcf setLfo:nil];
                break;
            case 2:
                [_osc1 setLfo:nil];
                [_osc2 setLfo:nil];
                [_vcf setLfo:_lfo];
            default:
                break;
        }
    }
    
}

-(IBAction)changeWaveform:(id)sender {
    CCRSegmentedRotaryControl *control = (CCRSegmentedRotaryControl*)sender;
    NSInteger value = control.selectedSegmentIndex;
    
    if (_lfo) {
        [_lfo setWaveform:(LFOWaveform)value];
    }
}

@end
