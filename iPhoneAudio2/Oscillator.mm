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
    bool noteOn;
    bool noteWaiting;
    
    Waveform nextWaveform;
    float nextFreq;
    
    double phase;
    
    SInt16 prevResult;
}

-(id)init {
    
    if (self = [super init]) {
        _freq = 0;
        _octave = 1;
        
        _waveform = Sin;
        nextWaveform = Sin;
        phase = 0;
     
        _envelope = [[Envelope alloc] init];
        _envelope.clickless = 0.01;

    }
    
    return self;
}

@synthesize waveform = _waveform;

-(void)setWaveform:(Waveform)waveform {
    nextWaveform = waveform;
}

-(Waveform)waveform {
    return _waveform;
}

@synthesize freq = _freq;

-(void)setFreq:(float)freq {
    _freq = freq;
}

-(float)freq {
    return _freq;
}

-(SInt16) getNextSampleForSampleRate:(Float64)sampleRate {

    // Calculate the next sample
    SInt16 result = [self getNextSample];

    // Smooth out result
    
    // phaseIncrement is the amount the phase changes in a single sample
    float phaseIncrement = (M_PI * _freq * powf(2, _octave)) / sampleRate;
    [self incrementPhase:phaseIncrement];
    
    // timeIncrement is the amount the envelope moves in a single sample
    float timeIncrement = 1000 / sampleRate;
    [_envelope incrementEnvelopeBy:timeIncrement];
    
    // Change waveform on zero crossover
    if ((result > 0) != (prevResult < 0) || result == 0) {
        if (_waveform != nextWaveform) {
            _waveform = nextWaveform;
            phase = 0;
        }
    }

    prevResult = result;
    
    return result;
}

-(SInt16) getNextSample {
    
    float env = [_envelope getEnvelopePoint];
    //env = 1;
    if (env > 0) {
        switch (_waveform) {
            case Sin:
                // Sin generator
                return (SInt16)(sin(phase) * 32767.0f * env);
                break;
            case Saw: {
                double modPhase = fmod(phase, M_PI * 2.0);
                float a = (modPhase / (M_PI)) - 1.0f;
                return (SInt16)(a * 32767.0f * env);
            }
                break;
            case Square: {
                if (sin(phase) > 0.5) {
                    return (SInt16)(32767.0f * env);
                } else {
                    return (SInt16)(32767.0f * -env);
                }
            }
                break;
            default:
                return 0;
        }
    } else {
        return 0;
    }
}

-(void)incrementPhase:(float)phaseIncrement {
    // Increment the phase of the oscillator
    phase += (phaseIncrement);
}

-(void)avoidOverflow {
    // Prevent phase from overloading
    phase = fmod(phase, M_PI * 2.0);
}

@end
