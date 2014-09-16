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

-(void)envelopeControlView:(EnvelopeControlView*)view didChangeParameter:(ADSRParameter)parameter forEnvelopeId:(int)envelopeId toValue:(float)value;

@end

@interface EnvelopeControlView : UIView

@property (nonatomic, weak) id<EnvelopeControlViewDelegate> delegate;

@property (nonatomic, strong) IBOutlet CCRRotaryControl *oscAttackControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *oscDecayControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *oscSustainControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *oscReleaseControl;

@property (nonatomic, strong) IBOutlet CCRRotaryControl *filterAttackControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *filterDecayControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *filterSustainControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *filterReleaseControl;

-(void)initializeParameters;

@end
