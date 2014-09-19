//
//  OscillatorView.h
//  iPhoneAudio2
//
//  Created by Chris on 9/11/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "ControlView.h"
#import "Oscillator.h"

@class OscillatorControlView;

@protocol OscillatorViewDelegate <NSObject>

-(void)oscillatorControlView:(OscillatorControlView*)view oscillator:(int)oscillatorId VolumeChangedTo:(float)value;

@end

@interface OscillatorControlView : ControlView

// TODO: Replace osc volume controls with mixer module to remove need for this delegate
@property (nonatomic, strong) id<OscillatorViewDelegate> delegate;

@property (nonatomic, weak) Oscillator* osc1;
@property (nonatomic, weak) Oscillator* osc2;

@property (nonatomic, strong) IBOutlet CCRRotaryControl *osc1vol;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *osc2vol;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *osc2freq;

@property (nonatomic, strong) IBOutlet CCRSegmentedRotaryControl *osc1wave;
@property (nonatomic, strong) IBOutlet CCRSegmentedRotaryControl *osc2wave;

@property (nonatomic, strong) IBOutlet CCRSegmentedRotaryControl *osc1octave;
@property (nonatomic, strong) IBOutlet CCRSegmentedRotaryControl *osc2octave;

@end
