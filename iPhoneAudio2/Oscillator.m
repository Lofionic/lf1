//
//  oscillator.m
//  iPhoneAudio2
//
//  Created by Chris on 19/05/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "Oscillator.h"

@implementation Oscillator
{
    double phase;
    AudioSignalType prevResult;
}

-(id)initWithSampleRate:(Float64)graphSampleRate {
    
    if (self = [super initWithSampleRate:graphSampleRate]) {
        _freq = 0;
        _octave = 1;
        
        _waveform = Sin;
        _nextWaveform = Sin;
        phase = 0;
         }
    
    return self;
}

@synthesize waveform = _waveform;

-(void)setWaveform:(OscillatorWaveform)waveform {
    _nextWaveform = waveform;
}

-(OscillatorWaveform)waveform {
    return _waveform;
}


-(void)fillBuffer:(AudioSignalType*)outA samples:(int)numFrames {
    
    // Fill a buffer with oscillator samples
    for (int i = 0; i < numFrames; i++) {
        float value = [self getNextSample];
        outA[i] = value;
        
        // Increment Phase
        float lfo = 1;
        
        if (_lfo) {
            lfo = powf(0.5, -_lfo.buffer[i]);
        }
        
        phase += (M_PI * _freq * lfo * powf(2, _octave)) / self.sampleRate;
        
        // Change waveform on zero crossover
        if ((value > 0) != (prevResult < 0) || value == 0) {
            if (_waveform != _nextWaveform) {
                _waveform = _nextWaveform;
                phase = 0;
            }
        }
    }
    
    // Prevent phase from overloading
    phase = fmod(phase, M_PI * 2.0);
}


-(float)getNextSample {
    
    switch (_waveform) {
        case Sin:
            // Sin generator
            return (float)(sin(phase * 2));
            break;
        case Saw: {
            double modPhase = fmod(phase, M_PI * 2.0);
            float a = (modPhase / (M_PI)) - 1.0f;
            return (float)(a);
        }
            break;
        case Square: {
            if (sin(phase) > 0) {
                return 1.0;
            } else {
                return -1.0;
            }
        }
            break;
        default:
            return 0;
    }
}


@end
