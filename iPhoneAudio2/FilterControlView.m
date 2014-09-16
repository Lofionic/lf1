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
    }
    return self;
}

-(void)initializeParameters {
    
    UIImage *moogA = [UIImage imageNamed:@"moog_a"];
    _freqControl.spriteSheet = moogA;
    _freqControl.spriteSize = CGSizeMake(140, 140);
    _resControl.spriteSheet = moogA;
    _resControl.spriteSize = CGSizeMake(140, 140);

    _freqControl.value = 0.5;
    _freqControl.defaultValue = 0.5;
    _resControl.value = 0.75;
    _resControl.defaultValue = 0;
    
}

-(IBAction)valueChanged:(id)sender {
    
    CCRRotaryControl *control = (CCRRotaryControl*)sender;
    
    if (_delegate) {
        if (control == _freqControl) {
            [_delegate filterControlView:self didChangeFrequencyTo:control.value];
        } else if (sender == _resControl) {
            [_delegate filterControlView:self didChangeResonanceTo:control.value];
        }
    }
}

@end
