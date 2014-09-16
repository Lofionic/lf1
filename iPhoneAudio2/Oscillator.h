//
//  oscillator.h
//  iPhoneAudio2
//
//  Created by Chris on 19/05/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "Generator.h"
#import "LFO.h"

typedef enum OscillatorWaveform {
    Sin,
    Saw,
    Square
} OscillatorWaveform;

@interface Oscillator : Generator

@property float freq;
@property OscillatorWaveform waveform;
@property (readonly) OscillatorWaveform nextWaveform;
@property NSInteger octave;

-(void)setWaveform:(OscillatorWaveform)waveform;

@property (weak) LFO* lfo;

@end
