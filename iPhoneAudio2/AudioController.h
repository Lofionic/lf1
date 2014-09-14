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

@interface AudioController : NSObject <OscillatorViewDelegate, EnvelopeControlViewDelegate, FilterControlViewDelegate> {

    AUGraph mGraph;
    AudioUnit mMixer;
    AudioUnit mOutput;
    AudioUnit mConverter;
    AudioUnit mFilter;
    
    CAStreamBasicDescription outputASBD;

    double sinPhase;

}

@property bool IsRunning;

-(void)initializeAUGraph;
-(void)startAUGraph;
-(void)stopAUGraph;

-(void)setMixerInputChannel:(int)channel toLevel:(float)level;
-(void)setMixerOutputLevel:(float)level;

-(void)noteOn:(float)frequency;
-(void)noteOff;

@end
