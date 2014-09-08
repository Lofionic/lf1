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

@interface AudioController : NSObject {

    AUGraph mGraph;
    AudioUnit mMixer;
    AudioUnit mOutput;
    
    CAStreamBasicDescription outputASBD;

    double sinPhase;

}

@property bool IsRunning;

@property oscillator *osc1;
@property oscillator *osc2;

-(void)initializeAUGraph;
-(void)initializeComponents;
-(void)startAUGraph;
-(void)stopAUGraph;

-(void)setMixerInputChannel:(int)channel toLevel:(float)level;
-(void)setMixerOutputLevel:(float)level;

@end
