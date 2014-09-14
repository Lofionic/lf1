//
//  oscillator.h
//  iPhoneAudio2
//
//  Created by Chris on 19/05/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CAStreamBasicDescription.h"

typedef enum Waveform {
    Sin,
    Saw,
    Square,
    AnalogSaw,
    AnalogSquare
} Waveform;

@interface Oscillator : NSObject

@property float freq;
@property float envelopeAttack;
@property float envelopeDecay;
@property float envelopeSustain;
@property float envelopeRelease;

@property Waveform waveform;
@property NSInteger octave;

-(void)setWaveform:(Waveform)waveform;
-(void)avoidOverflow;
-(SInt16) getNextSampleForSampleRate:(Float64)sampleRate;
-(void)trigger;
-(void)noteRelease;
-(float)getEnvelopePoint;



@end
