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
        NSArray *oscNib = [[NSBundle mainBundle] loadNibNamed:@"OscillatorControlView" owner:self options:nil];
        self = oscNib[0];
    }
    return self;
}

-(void)initializeParameters {
    
    UIImage *zeroTenBackground = [UIImage imageNamed:@"ZeroTen_Background"];
    self.osc1vol.backgroundImage = zeroTenBackground;
    self.osc2vol.backgroundImage = zeroTenBackground;
    
    UIImage *osc2FreqBackground = [UIImage imageNamed:@"Osc2Freq_Background"];
    self.osc2freq.backgroundImage = osc2FreqBackground;
    self.osc2freq.enableDefaultValue = true;
    self.osc2freq.defaultValue = 0.5;
    
    UIImage *chicken4 = [UIImage imageNamed:@"ChickenKnob_4way"];
    self.osc1octave.spriteSheet = chicken4;
    self.osc1octave.segments = 4;
    
    self.osc2octave.spriteSheet = chicken4;
    self.osc2octave.segments = 4;
    
    UIImage *oscWaveBackground = [UIImage imageNamed:@"OscWave_Background"];
    self.osc1wave.backgroundImage = oscWaveBackground;
    self.osc2wave.backgroundImage = oscWaveBackground;
    
    UIImage *oscOctBackground = [UIImage imageNamed:@"OscOct_Background"];
    self.osc1octave.backgroundImage = oscOctBackground;
    self.osc2octave.backgroundImage = oscOctBackground;
    
    UIImage *oscFrame = [UIImage imageNamed:@"osc_frame"];
    oscFrame = [oscFrame resizableImageWithCapInsets:UIEdgeInsetsMake(25, 15, 15, 15)];
    [self.backgroundView setImage:oscFrame];
}

-(IBAction)oscillatorVolumeChanged:(id)sender {
    CCRRotaryControl *control = (CCRRotaryControl*)sender;
    NSInteger tag = control.tag;
    
    if (self.mixer) {
        if (tag == 0) {
            self.mixer.source1Gain = control.value;
        } else {
            self.mixer.source2Gain = control.value;
        }
    }
}

-(IBAction)oscillatorFreqChanged:(id)sender {
    
    CCRRotaryControl *control = (CCRRotaryControl*)sender;
    NSInteger tag = control.tag;
    float value = control.value;
    
    switch (tag) {
        case 0:
            if (self.osc1) {
                [self.osc1 setFreq_adjust:value];
            }
            break;
        case 1:
            if (self.osc2) {
                [self.osc2 setFreq_adjust:value];
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
            if (self.osc1) {
                [self.osc1 setWaveform:(OscillatorWaveform)value];
            }
            break;
        case 1:
            if (self.osc2) {
                [self.osc2 setWaveform:(OscillatorWaveform)value];
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
            if (self.osc1) {
                [self.osc1 setOctave:value];
            }
            break;
        case 1:
            if (self.osc2) {
                [self.osc2 setOctave:value];
            }
        default:
            break;
    }
}
@end
