//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "BuildSettings.h"
#import "CVComponent.h"
#import "Envelope.h"
#import "EnvelopeControlView.h"
#import "FilterControlView.h"
#import "LFOControlView.h"
#import "OscillatorControlView.h"
#import "VCF.h"
#import "analog_oscillator.h"
#import "oscillator.h"
#import "Mixer2.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <Foundation/Foundation.h>

@interface AudioEngine : NSObject {

    AUGraph mGraph;
    AudioUnit mOutput;
    AudioUnit mConverter;
    
    AudioStreamBasicDescription outputASBD;
}

@property bool IsRunning;

// Synth Components
@property (nonatomic, strong) CVComponent *cvController;
@property (nonatomic, strong) Oscillator *osc1;
@property (nonatomic, strong) Oscillator *osc2;
@property (nonatomic, strong) VCF *vcf;
@property (nonatomic, strong) Envelope *vcfEnvelope;
@property (nonatomic, strong) Envelope *vcoEnvelope;
@property (nonatomic, strong) LFO *lfo1;
@property (nonatomic, strong) Mixer2 *mixer;

-(void)initializeAUGraph;
-(void)startAUGraph;
-(void)stopAUGraph;

-(BOOL)isHostConnected;
-(UIImage*) getAudioUnitIcon;
-(void)toggleRecord;
-(void)togglePlay;
-(void)rewind;
-(void)gotoHost;

@property (nonatomic) bool connected;
@property (nonatomic) bool isHostRecording;
@property (nonatomic) bool isHostPlaying;
@property (nonatomic) bool inForeground;
@property (nonatomic) Float64 playTime;
@property (nonatomic, strong) UIImage *hostAppIcon;

@end
