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
#import "Envelope.h"

typedef enum Waveform {
    Sin,
    Saw,
    Square,
    AnalogSaw,
    AnalogSquare
} Waveform;

@interface Oscillator : NSObject

@property float freq;
@property Waveform waveform;
@property NSInteger octave;
@property Envelope *envelope;

-(void)setWaveform:(Waveform)waveform;
-(void)avoidOverflow;
-(SInt16) getNextSampleForSampleRate:(Float64)sampleRate;


@end
