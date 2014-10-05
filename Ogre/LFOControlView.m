//
//  LFOControlView.m
//  iPhoneAudio2
//
//  Created by Chris on 16/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "LFOControlView.h"

@implementation LFOControlView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *lfoNib = [[NSBundle mainBundle] loadNibNamed:@"LFOControlView" owner:self options:nil];
        self = lfoNib[0];
    }
    return self;
}

-(void)initializeParameters {
    
    UIImage *zeroTenBackground = [UIImage imageNamed:@"ZeroTen_Background"];
    _amountControl.backgroundImage = zeroTenBackground;
 
    UIImage *LFORateBackground = [UIImage imageNamed:@"LFORate_Background"];
    _rateControl.backgroundImage = LFORateBackground;

    UIImage *chicken5 = [UIImage imageNamed:@"ChickenKnob_5way"];
    UIImage *waveBackground = [UIImage imageNamed:@"lfowave_background"];
    _waveformControl.spriteSheet = chicken5;
    _waveformControl.segments = 5;
    _waveformControl.backgroundImage = waveBackground;
    
    UIImage *destBackground = [UIImage imageNamed:@"LFODest_Background"];
    _destinationControl.backgroundImage = destBackground;
    
    UIImage *lfoFrame = [UIImage imageNamed:@"lfo_frame"];
    lfoFrame = [lfoFrame resizableImageWithCapInsets:UIEdgeInsetsMake(25, 15, 15, 15)];
    [self.backgroundView setImage:lfoFrame];
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
        switch (control.index) {
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
    NSInteger value = control.index;
    
    if (_lfo) {
        [_lfo setWaveform:(LFOWaveform)value];
    }
}

@end