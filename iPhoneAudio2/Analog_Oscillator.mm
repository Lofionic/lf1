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

-(SInt16) getNextSample {
    
    switch ([self waveform]) {
        case Sin:
            // Sin generator
            return (SInt16)(sin(phase[0]) * 32767.0f);
            break;
        case Saw: {
            
            // Sawtooth generator
            float amp = 0.5f;
            double result = 0;
            for (int i = 0; i < ANALOG_HARMONICS; i++) {
                result += sin(phase[i]) * amp;
                amp /= 2.0;
            }
            return (SInt16)(result * 32767.0f);
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
            return (SInt16)(sum * 32767.0f);
            
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
