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
    
    _oscAttackControl.value = 0.0;
    _oscDecayControl.value = 0.0;
    _oscSustainControl.value = 1.0;
    _oscReleaseControl.value = 0.75;
    
    _filterAttackControl.value = 0.9;
    _filterDecayControl.value = 0.0;
    _filterSustainControl.value = 1.0;
    _filterReleaseControl.value = 0.75;
}

@end
