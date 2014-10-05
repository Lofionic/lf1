//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
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

- (instancetype)initWithSampleRate:(Float64)graphSampleRate
{
    self = [super initWithSampleRate:(Float64)graphSampleRate];
    if (self) {
        _amp = FLT_MIN;
        _freq = FLT_MIN;
        _eg_amount = FLT_MIN;
        _waveform = LFOSin;
        _nextWaveform = LFOSin;
    }
    return self;
}

-(void)renderBuffer:(AudioSignalType*)outA samples:(UInt32)numFrames {
    
    // Fill a buffer with oscillator samples
    for (int i = 0; i < numFrames; i++) {
        float value = [self getNextSample];

        outA[i] = value * _amp;
        
        phase += (M_PI * _freq * 180) / self.sampleRate;
        
        // Change waveform on zero crossover
        if ((value > 0) != (prevResult < 0) || value == 0) {
            if (_waveform != _nextWaveform) {
                _waveform = _nextWaveform;
                phase = 0;
            }
        }
        
    }
    
    // Prevent phase from overloading
    if (phase > M_PI * 2.0) {
        sampleHold = (arc4random_uniform(32767) / 16385.0) - 1;
    }
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
        case LFORamp: {
            double modPhase = fmod(phase, M_PI * 2.0);
            float a = - ((modPhase / (M_PI)) - 1.0f);
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
            return sampleHold;
        }
        default:
            return 0;
    }
}

-(void)CVControllerDidOpenGate:(CVController *)cvController {
    // Re-trigger LFO
    phase = 0;
}

-(void)CVControllerDidCloseGate:(CVController *)cvController {
    // Nothing to do here
}

@end