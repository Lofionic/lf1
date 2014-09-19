//
//  EnvelopeControlView.h
//  iPhoneAudio2
//
//  Created by Chris on 11/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "ControlView.h"
#import "Envelope.h"

typedef enum ADSRParameter {
    Attack,
    Decay,
    Sustain,
    Release
} ADSRParameter;

@class EnvelopeControlView;

@interface EnvelopeControlView : ControlView

@property (nonatomic, weak) Envelope *VCOEnvelope;
@property (nonatomic, weak) Envelope *VCFEnvelope;

@property (nonatomic, strong) IBOutlet CCRRotaryControl *oscAttackControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *oscDecayControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *oscSustainControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *oscReleaseControl;

@property (nonatomic, strong) IBOutlet CCRRotaryControl *filterAttackControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *filterDecayControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *filterSustainControl;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *filterReleaseControl;

@end
