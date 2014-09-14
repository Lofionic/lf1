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

-(IBAction)valueChanged:(id)sender {
    if (_delegate) {
        CCRRotaryControl *control = (CCRRotaryControl*)sender;
        NSInteger tag = control.tag;
        if (tag == 2) {
            
            [_delegate envelopeControlView:self didChangeParameter:(ADSRParameter)tag toValue:control.value];
        } else {

            
            [_delegate envelopeControlView:self didChangeParameter:(ADSRParameter)tag toValue:powf(10000, control.value)];
        }
    }
}


-(void)initializeParameters {
    
    UIImage *moogA = [UIImage imageNamed:@"moog_a"];
    _attackControl.spriteSheet = moogA;
    _attackControl.spriteSize = CGSizeMake(140, 140);
    _decayControl.spriteSheet = moogA;
    _decayControl.spriteSize = CGSizeMake(140, 140);
    _sustainControl.spriteSheet = moogA;
    _sustainControl.spriteSize = CGSizeMake(140, 140);
    _releaseControl.spriteSheet = moogA;
    _releaseControl.spriteSize = CGSizeMake(140, 140);
    
    _attackControl.value = 0.7;
    _decayControl.value = 0.5;
    _sustainControl.value = 1.0;
    _releaseControl.value = 0.7;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
