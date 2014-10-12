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
        NSArray *envNib = [[NSBundle mainBundle] loadNibNamed:@"EnvelopeControlView" owner:self options:nil];
        self = envNib[0];
    }
    return self;
}

-(IBAction)oscValueChanged:(id)sender {
    
    CCRRotaryControl *control = (CCRRotaryControl*)sender;
    float value = control.value;
    
    if (self.VCOEnvelope) {
        switch (control.tag) {
            case Attack:
                // Limit range
                // value = (value * 0.7) + 0.3;
                // Return exponential value
                value = powf(value, EXPONENTIAL_CONTROL_VALUE);
                [self.VCOEnvelope setEnvelopeAttack:value];
                break;
            case Decay:
                // Limit range
                // value = (value * 0.7) + 0.3;
                // Return exponential value
                value = powf(value, EXPONENTIAL_CONTROL_VALUE);
                [self.VCOEnvelope setEnvelopeDecay:value];
                break;
            case Release:
                // Limit range
                // value = (value * 0.7) + 0.3;
                // Return exponential value
                value = powf(value, EXPONENTIAL_CONTROL_VALUE);
                [self.VCOEnvelope setEnvelopeRelease:value];
                break;
            case Sustain:
                [self.VCOEnvelope setEnvelopeSustain:value];
                break;
            default:
                break;
        }
    }
}

-(IBAction)filterValueChanged:(id)sender {
    CCRRotaryControl *control = (CCRRotaryControl*)sender;
    float value = control.value;
    
    if (self.VCFEnvelope) {
        switch (control.tag) {
            case Attack:// Limit range
                // value = (value * 0.7) + 0.3;
                // Return exponential value
                value = powf(value, EXPONENTIAL_CONTROL_VALUE);
                [self.VCFEnvelope setEnvelopeAttack:value];
                break;
            case Decay:// Limit range
                // value = (value * 0.7) + 0.3;
                // Return exponential value
                value = powf(value, EXPONENTIAL_CONTROL_VALUE);
                [self.VCFEnvelope setEnvelopeDecay:value];
                break;
            case Release:
                // value = (value * 0.7) + 0.3;
                // Return exponential value
                value = powf(value, EXPONENTIAL_CONTROL_VALUE);
                [self.VCFEnvelope setEnvelopeRelease:value];
                break;
            case Sustain:
                [self.VCFEnvelope setEnvelopeSustain:value];
                break;
            default:
                break;
        }
    }
}

-(void)initializeParameters {
    
    UIImage *envBackground = [UIImage imageNamed:@"Env_Background"];
    self.oscAttackControl.backgroundImage = envBackground;
    self.oscDecayControl.backgroundImage = envBackground;
    self.oscReleaseControl.backgroundImage = envBackground;
    
    self.filterAttackControl.backgroundImage = envBackground;
    self.filterDecayControl.backgroundImage = envBackground;
    self.filterReleaseControl.backgroundImage = envBackground;
    
    UIImage *zeroTenBackground = [UIImage imageNamed:@"ZeroTen_Background"];
    self.oscSustainControl.backgroundImage = zeroTenBackground;
    self.filterSustainControl.backgroundImage = zeroTenBackground;

    UIImage *envFrame = [UIImage imageNamed:@"env_frame"];
    envFrame = [envFrame resizableImageWithCapInsets:UIEdgeInsetsMake(25, 0, 0, 15)];
    [self.backgroundView setImage:envFrame];
}

@end
