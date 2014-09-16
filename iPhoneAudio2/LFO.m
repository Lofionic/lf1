//
//  LFO.m
//  iPhoneAudio2
//
//  Created by Chris on 16/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "LFO.h"

@implementation LFO {
    double phase;
    AudioSignalType prevResult;
    
    double sampleHoldPhase;
    float sampleHold;
}

@synthesize waveform = _waveform;

-(void)setWaveform:(LFOWaveform)waveform {
    _nextWaveform = waveform;
}

-(LFOWaveform)waveform {
    return _waveform;
}


-(void)fillBuffer:(AudioSignalType*)outA samples:(int)numFrames {
    
    // Fill a buffer with oscillator samples
    for (int i = 0; i < numFrames; i++) {
        float value = [self getNextSample];

        outA[i] = value * _amp;
        
        phase += (M_PI * _freq * (_waveform == LFOSampleHold ? 2 : 1)) / self.sampleRate;
        
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

-(AudioSignalType)getNextSample {
    
    switch (_waveform) {
        case LFOSin:
            // Sin generator
            return (float)(sin(phase * 2));
            break;
        case LFOSaw: {
            double modPhase = fmod(phase, M_PI * 2.0);
            float a = (modPhase / (M_PI)) - 1.0f;
            return (float)(a);
        }
            break;
        case LFOSquare: {
            if (sin(phase) > 0) {
                return 1.0;
            } else {
                return -1.0;
            }
        }
            break;
        case LFOSampleHold: {
            if (phase < sampleHoldPhase) {
                sampleHold = arc4random_uniform(32767) / 32767.0;
            }
            sampleHoldPhase = phase;
            return sampleHold;
            
        }
        default:
            return 0;
    }
}

-(void)reset {
    
    phase = 0;
    
}

@end
