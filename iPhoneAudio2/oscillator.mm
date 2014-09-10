//
//  oscillator.m
//  iPhoneAudio2
//
//  Created by Chris on 19/05/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "oscillator.h"

@implementation oscillator
{
    Waveform nextWaveform;
    double phase;
    bool prevResultPositive;

    double envelopePosition;
    bool envelopeTriggered;
    
    AudioTimeStamp envelopeTriggerTime;
    
    SInt16 prevResult;
}

const int harmonics = 1;

-(id)initWithFrequency:(float)freq withWaveform:(Waveform)waveform {
    
    if (self = [super init]) {
        self.freq = freq;
        self.amp = 0;

        _waveform = waveform;
        nextWaveform = waveform;
        
        phase = 0;
     
        envelopePosition = 0;
        envelopeTriggered = false;
    }
    
    return self;
}

-(void)setWaveform:(Waveform)waveform {
    nextWaveform = waveform;
}

-(SInt16) getNextSampleForSampleRate:(Float64)sampleRate {

    // Calculate the next sample
    SInt16 result = [self getNextSample];

    // phaseIncrement is the amount the phase changes in a single sample
    float phaseIncrement = M_PI * _freq / sampleRate;
    [self incrementPhase:phaseIncrement];
    
    // timeIncrement is the amount the envelope moves in a single sample
    float timeIncrement = 1000 / sampleRate;
    [self incrementEnvelope:timeIncrement];
    
    // Change waveform on zero crossover
    if ((result > 0) != prevResultPositive || result == 0) {
        if (_waveform != nextWaveform) {
            _waveform = nextWaveform;
            phase = 0;
        }
    }

    prevResultPositive = result > 0;
    
    return result;
}

-(SInt16) getNextSample {
    
    float env = [self getEnvelopePoint];
    
    switch (_waveform) {
        case Sin:
            // Sin generator
            return (SInt16)(sin(phase) * 32767.0f * _amp * env);
            break;
        case Saw: {
            double modPhase = fmod(phase, M_PI * 2.0);
            float a = (modPhase / (M_PI)) - 1.0f;
            
            return (SInt16)(a * 32767.0f * _amp * env);
        }
            break;
        case Square: {
            if (sin(phase) > 0.5) {
                return _amp * 32767.0f * env;
            } else {
                return -_amp * 32767.0f * env;
            }
        }
            break;
            
        default:
            return 0;
    }
}

-(void)trigger {
    // Trigger envelope from start
    phase = 0;
    envelopePosition = 0;
    envelopeTriggered = true;
}

-(float)getEnvelopePoint {
    // Return the current value of the envelope
    if (envelopePosition < 1000.0) {
        return envelopePosition / 1000.0;
    } else {
            return 1.0;
    }
}

-(void)incrementPhase:(float)phaseIncrement {
    // Increment the phase of the oscillator
    for (int x = 0; x < harmonics; x++) {
        phase += (phaseIncrement * (x + 1));
    }
}

-(void)incrementEnvelope:(float)milliseconds {
    // Increment the position of the envelope
    if (envelopeTriggered) {
        envelopePosition += milliseconds;
    }
}

-(void)avoidOverflow {
    // Prevent phase from overloading
    phase = fmod(phase, M_PI * 2.0);

}

@end
