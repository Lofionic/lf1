//
//  LFOControlView.h
//  iPhoneAudio2
//
//  Created by Chris on 16/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "ControlView.h"
#import "LFO.h"
#import "Oscillator.h"
#import "VCF.h"

@class LFOControlView;

@interface LFOControlView : ControlView

@property (nonatomic, weak) LFO* lfo;
@property (nonatomic, weak) Oscillator *osc1;
@property (nonatomic, weak) Oscillator *osc2;
@property (nonatomic, weak) VCF *vcf;

@property (nonatomic, strong) IBOutlet CCRRotaryControl *rateControl1;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *amountControl1;
@property (nonatomic, strong) IBOutlet CCRSegmentedRotaryControl *destinationControl1;
@property (nonatomic, strong) IBOutlet CCRSegmentedRotaryControl *waveformControl1;

@end
