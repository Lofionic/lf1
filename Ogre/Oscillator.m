//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "Oscillator.h"

@implementation Oscillator
{
    double phase;
    AudioSignalType prevResult;
}

-(id)initWithSampleRate:(Float64)graphSampleRate {
    
    if (self = [super initWithSampleRate:graphSampleRate]) {
        _freq_adjust = 0.5; // freq_adjust of 0.5 = no adjust
        _octave = 0;
        
        _waveform = Sin;
        _nextWaveform = Sin;
        phase = DBL_MIN;
        prevResult = DBL_MIN;
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


-(void)renderBuffer:(AudioSignalType*)outA samples:(UInt32)numFrames {
    
    // Fill a buffer with oscillator samples
    for (int i = 0; i < numFrames; i++) {
        float value = [self getNextSample];
        outA[i] = value;
        
        // Apply LFO
        float lfo = 1;
        if (_lfo) {
            lfo = powf(0.5, -_lfo.buffer[i]);
        }
        
        // Apply freq adjustment
        float adjustValue = (_freq_adjust * 2.0) - 1.0;

        adjustValue = (powf(powf(2, (1.0 / 12.0)), adjustValue * 7));

        float freq = FLT_MIN;
        if (_cvController) {
            freq = _cvController.buffer[i] * CV_FREQUENCY_RANGE;
        }
        
        // Increment Phase
        phase += (M_PI * freq * lfo * powf(2, _octave) * adjustValue) / self.sampleRate;
        
        // Change waveform on zero crossover
        if ((value > 0) != (prevResult < 0) || value == 0) {
            if (_waveform != _nextWaveform) {
                [self changeToNextWaveform];
                phase = 0;
            }
        }
    }
    
    // Prevent phase from overloading
    phase = fmod(phase, M_PI * 2.0);
}

-(void)changeToNextWaveform {

    _waveform = _nextWaveform;
    
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
