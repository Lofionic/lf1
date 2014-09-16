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

@interface AudioController : NSObject <OscillatorViewDelegate, EnvelopeControlViewDelegate, FilterControlViewDelegate> {

    AUGraph mGraph;
    
    AudioUnit mOutput;
    AudioUnit mConverter;
    
    
    NSArray *oscillators;

    CAStreamBasicDescription outputASBD;

    double sinPhase;
    
    NSTimer *timer;

}

@property bool IsRunning;
@property (nonatomic, strong) Envelope *filterEnvelope;
@property float filterFreq;

@property AudioUnit mFilter;
@property AudioUnit mMixer;

-(void)initializeAUGraph;
-(void)startAUGraph;
-(void)stopAUGraph;

-(void)setMixerInputChannel:(int)channel toLevel:(float)level;
-(void)setMixerOutputLevel:(float)level;

-(void)noteOn:(float)frequency;
-(void)noteOff;

@end
