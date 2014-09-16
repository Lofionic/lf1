//
//  analog_oscillator.m
//  iPhoneAudio2
//
//  Created by Chris on 9/9/14.
//  Copyright (c) 2014 ccr. All rights reserved.
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

-(void) fillBuffer:(AudioSignalType*)outA samples:(int)numFrames {
    
    // Fill a buffer with oscillator samples
    for (int i = 0; i < numFrames; i++) {
        AudioSignalType value = [self getNextSample];
        outA[i] = value;
        
        // Increment Phase
        for (int j = 0; j < ANALOG_HARMONICS; j++) {
            phase[j] += ((M_PI * self.freq * powf(2, self.octave)) / self.sampleRate) * (j + 1);
            if (phase[j] > M_PI * 2.0) {
                phase[j] -= M_PI * 2.0;
            }
        }
        // Change waveform on zero crossover
        if ((value > 0) != (prevResult < 0) || value == 0) {
            if (self.waveform != self.nextWaveform) {
                //self.waveform = self.nextWaveform;
                for (int j = 0; j <ANALOG_HARMONICS; j++) {
                    //phase[j] = 0;
                }
            }
        }
    }

}

-(AudioSignalType) getNextSample {
    
    switch ([self waveform]) {
        case Sin:
            // Sin generator
            return (AudioSignalType)sin(phase[0]);
            break;
        case Saw: {
            
            // Sawtooth generator
            float amp = 0.5f;
            double result = 0;
            for (int i = 0; i < ANALOG_HARMONICS; i++) {
                result += sin(phase[i]) * amp;
                amp /= 2.0;
            }
            return (AudioSignalType)result;
        }
            break;
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
