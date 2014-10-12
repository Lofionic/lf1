//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "LFO.h"
#define DECLICK_THRESHOLD 0.001

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
        self.amp = FLT_MIN;
        self.freq = FLT_MIN;
        self.eg_amount = FLT_MIN;
        self.waveform = LFOSin;
        _nextWaveform = LFOSin;
    }
    return self;
}

-(void)renderBuffer:(AudioSignalType*)outA samples:(UInt32)numFrames {
    
    // Fill a buffer with oscillator samples
    for (int i = 0; i < numFrames; i++) {
        float value = [self getNextSample];

        AudioSignalType outValue = value * self.amp;
        
        // Declicker
        AudioSignalType delta = outValue - prevResult;
        if (fabsf(delta) > DECLICK_THRESHOLD) {
            outValue = prevResult + (DECLICK_THRESHOLD * ((delta < 0) ? -1 : 1));
        }
        
        outA[i] = outValue;
        
        phase += (M_PI * self.freq * 180) / self.sampleRate;
        
        // Change waveform on zero crossover
        if ((value > 0) != (prevResult < 0) || value == 0) {
            if (self.waveform != self.nextWaveform) {
                _waveform = self.nextWaveform;
                phase = 0;
            }
        }
        
        prevResult = outValue;
        
    }
    
    // Prevent phase from overloading
    if (phase > M_PI * 2.0) {
        sampleHold = (arc4random_uniform(32767) / 16385.0) - 1;
    }
    
    phase = fmod(phase, M_PI * 2.0);
}

-(AudioSignalType)getNextSample {
    
    switch (self.waveform) {
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

-(void)CVControllerDidOpenGate:(CVComponent *)cvController {
    // Re-trigger LFO
    phase = 0;
}

-(void)CVControllerDidCloseGate:(CVComponent *)cvController {
    // Nothing to do here
}

@end
