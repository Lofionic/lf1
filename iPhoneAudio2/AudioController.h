//
//  AudioController.h
//  iPhoneAudio2
//
//  Created by Chris on 22/02/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CAStreamBasicDescription.h"
#import "oscillator.h"
#import "analog_oscillator.h"
#import "OscillatorControlView.h"
#import "EnvelopeControlView.h"
#import "FilterControlView.h"
#import "Envelope.h"
#import "Filter.h"
#import "BuildSettings.h"
#import "SynthComponent.h"

@interface AudioController : NSObject <OscillatorViewDelegate, EnvelopeControlViewDelegate, FilterControlViewDelegate> {

    AUGraph mGraph;
    
    AudioUnit mOutput;
    AudioUnit mConverter;
    
    CAStreamBasicDescription outputASBD;

}

@property bool IsRunning;

@property AudioUnit mFilter;
@property AudioUnit mMixer;

// Synth Components
@property NSArray *oscillators;
@property Filter *filter;
@property (nonatomic, strong) Envelope *filterEnvelope;
@property (nonatomic, strong) Envelope *vcoEnvelope;

@property float osc1vol;
@property float osc2vol;


-(void)initializeAUGraph;
-(void)startAUGraph;
-(void)stopAUGraph;

-(void)setMixerInputChannel:(int)channel toLevel:(float)level;
-(void)setMixerOutputLevel:(float)level;

-(void)noteOn:(float)frequency;
-(void)noteOff;

@end
