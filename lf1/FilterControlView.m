//
//  FilterControlView.m
//  iPhoneAudio2
//
//  Created by Chris on 14/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//
#import "Defines.h"
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
    self.resControl.backgroundImage = zeroTenBackground;

    UIImage *cutoffKnob = [UIImage imageNamed:@"CutoffKnob"];
    self.freqControl.spriteSheet = cutoffKnob;
    self.freqControl.spriteSize = CGSizeMake(150 * SCREEN_SCALE, 150 * SCREEN_SCALE);
    
    
    UIImage *cutoffBackground = [UIImage imageNamed:@"Cutoff_background"];
    self.freqControl.backgroundImage = cutoffBackground;
    
    UIImage *egBackground = [UIImage imageNamed:@"eg_amt_background"];
    self.egControl.backgroundImage = egBackground;

    UIImage *vcfFrame = [UIImage imageNamed:@"vcf_frame"];
    vcfFrame = [vcfFrame resizableImageWithCapInsets:UIEdgeInsetsMake(25, 15, 15, 15)];
    [self.backgroundView setImage:vcfFrame];
}


-(IBAction)valueChanged:(id)sender {
    
    CCRRotaryControl *control = (CCRRotaryControl*)sender;
    float value = control.value;
    
    if (self.vcf) {
        if (control == self.freqControl) {
            // Scale value
            value = (value * 0.8) + 0.2;
            
            // Return exponential value
            [self.vcf setCutoff:powf(value, 4)];
            
        } else if (sender == self.resControl) {
            [self.vcf setResonance:value];
        } else if (sender == self.egControl) {
            [self.vcf setEg_amount:value];
        }
    }
}
@end
