//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "Analog_Oscillator.h"
#import "BuildSettings.h"

@implementation Analog_Oscillator {

    double phase[ANALOG_HARMONICS];
    AudioSignalType prevResult;
}

-(id)init {
    self = [super init];
    if (self) {
        for (int x = 0; x < ANALOG_HARMONICS; x++) {
            phase[x] = 0;
        }
    }
    return self;
}

-(void) renderBuffer:(AudioSignalType*)outA samples:(UInt32)numFrames {
    
    // Fill a buffer with oscillator samples
    for (int i = 0; i < numFrames; i++) {
        AudioSignalType value = [self getNextSample];
        outA[i] = value;
        
        // Apply freq adjustment
        float adjustValue = (self.freq_adjust * 2.0) - 1.0;
        
        adjustValue = (powf(powf(2, (1.0 / 12.0)), adjustValue * 7));
        
        float freq = FLT_MIN;
        if (self.cvController) {
            freq = self.cvController.buffer[i] * CV_FREQUENCY_RANGE;
        }
        
        // Increment Phase
        for (int j = 0; j < ANALOG_HARMONICS; j++) {
            phase[j] += ((M_PI * freq * adjustValue * powf(2, self.octave)) / self.sampleRate) * (j + 1);
            
            if (phase[j] > M_PI * 2.0) {
                phase[j] -= M_PI * 2.0;
            }
            
        }
        
        // Change waveform on zero crossover
        if ((value > 0) != (prevResult < 0) || value == 0) {
            if (self.waveform != self.nextWaveform) {
                self.waveform = self.nextWaveform;
                for (int j = 0; j <ANALOG_HARMONICS; j++) {
                    phase[j] = 0;
                }
            }
        }
        
        
    }
    
    [self avoidOverflow];

}

-(AudioSignalType) getNextSample {
    
    switch ([self waveform]) {
        case Sin: {
            // Sin generator
            AudioSignalType a = (AudioSignalType)sin(phase[0]);

            return a;
            break;
        }
        case Saw: {
            
            // Sawtooth generator
            float amp = 0.5f;
            double result = 0;
            for (int i = 0; i < ANALOG_HARMONICS; i++) {
                result += sin(phase[i]) * amp;
                amp /= 2.0;
            }
            return (AudioSignalType)result;
        
            break;
        }
        case Square: {
            
            // Square wave generator
            double sum = 0;
            float count = 0;
            
            for (int i = 0; i < ANALOG_HARMONICS; i += 2) {
                sum += sin(phase[i]);
                count ++;
            }
            
            sum /= count;
            return (AudioSignalType)sum;
            
        }
            break;
        default:
            return 0;
    }
}

-(void)incrementPhase:(float)phaseIncrement {
    for (int x = 0; x < ANALOG_HARMONICS; x++) {
        phase[x] += (phaseIncrement * (x + 1));
    }
}

-(void)avoidOverflow {
    for (int x = 0; x < ANALOG_HARMONICS; x++) {
        if (phase[x] >= M_PI * 2.0) {
            phase[x] -= (M_PI * 2.0);
        }
    }
}

@end
