//
//  AudioController.h
//  iPhoneAudio2
//
//  Created by Chris on 22/02/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "BuildSettings.h"
#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CAStreamBasicDescription.h"
#import "oscillator.h"
#import "analog_oscillator.h"
#import "Envelope.h"
#import "VCF.h"
#import "OscillatorControlView.h"
#import "EnvelopeControlView.h"
#import "FilterControlView.h"
#import "LFOControlView.h"

@interface AudioController : NSObject <OscillatorViewDelegate, EnvelopeControlViewDelegate, FilterControlViewDelegate, LFOControlViewDelegate> {

    AUGraph mGraph;
    AudioUnit mOutput;
    AudioUnit mConverter;
    
    CAStreamBasicDescription outputASBD;

}

@property bool IsRunning;

// Synth Components
@property (nonatomic, strong) Oscillator *osc1;
@property (nonatomic, strong) Oscillator *osc2;
@property (nonatomic, strong) VCF *filter;
@property (nonatomic, strong) Envelope *filterEnvelope;
@property (nonatomic, strong) Envelope *vcoEnvelope;
@property (nonatomic, strong) LFO *lfo1;

@property float osc1vol;
@property float osc2vol;


-(void)initializeAUGraph;
-(void)startAUGraph;
-(void)stopAUGraph;

-(void)noteOn:(float)frequency;
-(void)noteOff;

@end
