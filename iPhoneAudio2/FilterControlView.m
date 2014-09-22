//
//  FilterControlView.m
//  iPhoneAudio2
//
//  Created by Chris on 14/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "FilterControlView.h"

@implementation FilterControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *filterNib = [[NSBundle mainBundle] loadNibNamed:@"FilterControlView" owner:self options:nil];
        self = filterNib[0];
    }
    return self;
}

-(void)initializeParameters {

    UIImage *zeroTenBackground = [UIImage imageNamed:@"ZeroTen_Background"];
    _resControl.backgroundImage = zeroTenBackground;

    UIImage *cutoffKnob = [UIImage imageNamed:@"CutoffKnob"];
    _freqControl.spriteSheet = cutoffKnob;
    _freqControl.spriteSize = CGSizeMake(150 * SCREEN_SCALE, 150 * SCREEN_SCALE);
    
    UIImage *egBackground = [UIImage imageNamed:@"Osc2Freq_Background"];
    _egControl.backgroundImage = egBackground;
    
}


-(IBAction)valueChanged:(id)sender {
    
    CCRRotaryControl *control = (CCRRotaryControl*)sender;
    float value = control.value;
    
    if (_vcf) {
        if (control == _freqControl) {
            // Scale value
            value = (value * 0.8) + 0.2;
            
            // Return exponential value
            [_vcf setCutoff:powf(value, 4)];
            
        } else if (sender == _resControl) {
            [_vcf setResonance:value];
        } else if (sender == _egControl) {
            [_vcf setEg_amount:value];
        }
    }
}

@end
