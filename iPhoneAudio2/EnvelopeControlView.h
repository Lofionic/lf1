//
//  EnvelopeControlView.h
//  iPhoneAudio2
//
//  Created by Chris on 11/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCRRotaryControl.h"

typedef enum ADSRParameter {
    Attack,
    Decay,
    Sustain,
    Release
} ADSRParameter;

@class EnvelopeControlView;

@protocol EnvelopeControlViewDelegate

-(void)envelopeControlView:(EnvelopeControlView*)view didChangeParameter:(ADSRParameter)parameter toValue:(float)value;

@end

@interface EnvelopeControlView : UIView

@property (nonatomic, weak) id<EnvelopeControlViewDelegate> delegate;

@property (nonatomic, strong) IBOutlet CCRRotaryControl *attackControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *decayControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *sustainControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *releaseControl;

-(void)initializeParameters;

@end
