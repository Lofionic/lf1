//
//  EnvelopeControlView.m
//  iPhoneAudio2
//
//  Created by Chris on 11/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "EnvelopeControlView.h"

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
    if (_delegate) {
        CCRRotaryControl *control = (CCRRotaryControl*)sender;
        NSInteger tag = control.tag;
        [_delegate envelopeControlView:self didChangeParameter:(ADSRParameter)tag forEnvelopeId:0 toValue:control.value];

    }
}

-(IBAction)filterValueChanged:(id)sender {
    if (_delegate) {
        CCRRotaryControl *control = (CCRRotaryControl*)sender;
        NSInteger tag = control.tag;
        [_delegate envelopeControlView:self didChangeParameter:(ADSRParameter)tag forEnvelopeId:1 toValue:control.value];
    }
}

-(void)initializeParameters {
    
    UIImage *moogA = [UIImage imageNamed:@"moog_a"];
    _oscAttackControl.spriteSheet = moogA;
    _oscAttackControl.spriteSize = CGSizeMake(140, 140);
    _oscDecayControl.spriteSheet = moogA;
    _oscDecayControl.spriteSize = CGSizeMake(140, 140);
    _oscSustainControl.spriteSheet = moogA;
    _oscSustainControl.spriteSize = CGSizeMake(140, 140);
    _oscReleaseControl.spriteSheet = moogA;
    _oscReleaseControl.spriteSize = CGSizeMake(140, 140);
    
    _filterAttackControl.spriteSheet = moogA;
    _filterAttackControl.spriteSize = CGSizeMake(140, 140);
    _filterDecayControl.spriteSheet = moogA;
    _filterDecayControl.spriteSize = CGSizeMake(140, 140);
    _filterSustainControl.spriteSheet = moogA;
    _filterSustainControl.spriteSize = CGSizeMake(140, 140);
    _filterReleaseControl.spriteSheet = moogA;
    _filterReleaseControl.spriteSize = CGSizeMake(140, 140);
    
    _oscAttackControl.value = 0.0;
    _oscDecayControl.value = 0.0;
    _oscSustainControl.value = 1.0;
    _oscReleaseControl.value = 0.75;
    
    _filterAttackControl.value = 0.0;
    _filterDecayControl.value = 0.0;
    _filterSustainControl.value = 1.0;
    _filterReleaseControl.value = 0.75;
}

@end
