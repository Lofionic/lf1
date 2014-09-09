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
     }
    
    return self;
}

-(void)setWaveform:(Waveform)waveform {
    nextWaveform = waveform;
}

-(SInt16) getNextSampleAndIncrementPhaseBy:(float)increment {

    SInt16 result = [self getNextSample];
    
    [self incrementPhase:increment];
    
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
    
    switch (_waveform) {
        case Sin:
            // Sin generator
            return (SInt16)(sin(phase) * 32767.0f * _amp);
            break;
        case Saw: {
            double modPhase = fmod(phase, M_PI * 2.0);
            return (SInt16)((modPhase / M_PI - 0.5f) * 32767.0 * _amp);
        }
            break;
        case Square: {
            if (sin(phase) > 0.5) {
                return _amp * 32767.0f;
            } else {
                return -_amp * 32767.0f;
            }
        }
            break;
        default:
            return 0;
    }
}


-(void)incrementPhase:(float)phaseIncrement {
    for (int x = 0; x < harmonics; x++) {
        phase += (phaseIncrement * (x + 1));
    }
}

-(void)avoidOverflow {
    if (phase >= M_PI * 2.0) {
        phase -= (M_PI * 2.0);
    }
}

@end
