//
//  OscillatorView.h
//  iPhoneAudio2
//
//  Created by Chris on 9/11/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "ControlView.h"

@class OscillatorControlView;

@protocol OscillatorViewDelegate <NSObject>

-(void)oscillatorControlView:(OscillatorControlView*)view oscillator:(int)oscillatorId WaveformChangedTo:(int)value;
-(void)oscillatorControlView:(OscillatorControlView*)view oscillator:(int)oscillatorId VolumeChangedTo:(float)value;
-(void)oscillatorControlView:(OscillatorControlView*)view oscillator:(int)oscillatorId FreqChangedTo:(float)value;
-(void)oscillatorControlView:(OscillatorControlView *)view oscillator:(int)oscillatorId OctaveChangedTo:(int)value;

@end

@interface OscillatorControlView : ControlView

@property (nonatomic, strong) id<OscillatorViewDelegate> delegate;

@property (nonatomic, strong) IBOutlet CCRRotaryControl *osc1vol;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *osc2vol;
@property (nonatomic, strong) IBOutlet CCRRotaryControl *osc2freq;

@property (nonatomic, strong) IBOutlet CCRSegmentedRotaryControl *osc1wave;
@property (nonatomic, strong) IBOutlet CCRSegmentedRotaryControl *osc2wave;

@property (nonatomic, strong) IBOutlet CCRSegmentedRotaryControl *osc1octave;
@property (nonatomic, strong) IBOutlet CCRSegmentedRotaryControl *osc2octave;

@end
