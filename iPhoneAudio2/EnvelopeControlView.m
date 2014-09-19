//
//  EnvelopeControlView.m
//  iPhoneAudio2
//
//  Created by Chris on 11/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "EnvelopeControlView.h"

#define EXPONENTIAL_CONTROL_VALUE 8

@implementation EnvelopeControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(IBAction)oscValueChanged:(id)sender {
    
    CCRRotaryControl *control = (CCRRotaryControl*)sender;
    float value = control.value;
    
    if (_VCOEnvelope) {
        switch (control.tag) {
            case Attack:
                // Limit range
                // value = (value * 0.7) + 0.3;
                // Return exponential value
                value = powf(value, EXPONENTIAL_CONTROL_VALUE);
                [_VCOEnvelope setEnvelopeAttack:value];
                break;
            case Decay:
                // Limit range
                // value = (value * 0.7) + 0.3;
                // Return exponential value
                value = powf(value, EXPONENTIAL_CONTROL_VALUE);
                [_VCOEnvelope setEnvelopeDecay:value];
                break;
            case Release:
                // Limit range
                // value = (value * 0.7) + 0.3;
                // Return exponential value
                value = powf(value, EXPONENTIAL_CONTROL_VALUE);
                [_VCOEnvelope setEnvelopeRelease:value];
                break;
            case Sustain:
                [_VCOEnvelope setEnvelopeSustain:value];
                break;
            default:
                break;
        }
    }
}

-(IBAction)filterValueChanged:(id)sender {
    CCRRotaryControl *control = (CCRRotaryControl*)sender;
    float value = control.value;
    
    if (_VCFEnvelope) {
        switch (control.tag) {
            case Attack:// Limit range
                // value = (value * 0.7) + 0.3;
                // Return exponential value
                value = powf(value, EXPONENTIAL_CONTROL_VALUE);
                [_VCFEnvelope setEnvelopeAttack:value];
                break;
            case Decay:// Limit range
                // value = (value * 0.7) + 0.3;
                // Return exponential value
                value = powf(value, EXPONENTIAL_CONTROL_VALUE);
                [_VCFEnvelope setEnvelopeDecay:value];
                break;
            case Release:
                // value = (value * 0.7) + 0.3;
                // Return exponential value
                value = powf(value, EXPONENTIAL_CONTROL_VALUE);
                [_VCFEnvelope setEnvelopeRelease:value];
                break;
            case Sustain:
                [_VCFEnvelope setEnvelopeSustain:value];
                break;
            default:
                break;
        }
    }
}

-(void)initializeParameters {
    
    UIImage *envBackground = [UIImage imageNamed:@"Env_Background"];
    _oscAttackControl.backgroundImage = envBackground;
    _oscDecayControl.backgroundImage = envBackground;
    _oscReleaseControl.backgroundImage = envBackground;
    
    _filterAttackControl.backgroundImage = envBackground;
    _filterDecayControl.backgroundImage = envBackground;
    _filterReleaseControl.backgroundImage = envBackground;
    
    UIImage *zeroTenBackground = [UIImage imageNamed:@"ZeroTen_Background"];
    _oscSustainControl.backgroundImage = zeroTenBackground;
    _filterSustainControl.backgroundImage = zeroTenBackground;
    
}

@end
