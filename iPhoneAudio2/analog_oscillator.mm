//
//  analog_oscillator.m
//  iPhoneAudio2
//
//  Created by Chris on 9/9/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "analog_oscillator.h"

@implementation analog_oscillator {

    int harmonics;
    double phase[20];
}

-(id)initWithFrequency:(float)freq withWaveform:(Waveform)waveform {
    self = [super initWithFrequency:freq withWaveform:waveform];
    if (self) {
        harmonics = 15;
        for (int x = 0; x < harmonics; x++) {
            phase[x] = 0;
        }
    }
    return self;
}

-(SInt16) getNextSample {
    
    float env = [self getEnvelopePoint];
    
    switch ([self waveform]) {
        case Sin:
            // Sin generator
            return (SInt16)(sin(phase[0]) * 32767.0f * [self amp] * env);
            break;
        case Saw: {
            
            // Sawtooth generator
            float amp = 0.5f;
            double result = 0;
            for (int i = 0; i < harmonics; i++) {
                result += sin(phase[i]) * amp;
                amp /= 2.0;
            }
            return (SInt16)(result * 32767.0f * [self amp] * env);
        }
            break;
        case Square: {
            
            // Square wave generator
            double sum = 0;
            float count = 0;
            
            for (int i = 0; i < harmonics; i += 2) {
                sum += sin(phase[i]);
                count ++;
            }
            
            sum /= count;
            return (SInt16)(sum * 32767.0f * [self amp] * env);
            
        }
            break;
        default:
            return 0;
    }
}

-(void)trigger {
    for (int x = 0; x < harmonics; x++) {
        phase[x] = 0;
    }
    
    
    [super trigger];
}

-(void)incrementPhase:(float)phaseIncrement {
    for (int x = 0; x < harmonics; x++) {
        phase[x] += (phaseIncrement * (x + 1));
    }
}

-(void)avoidOverflow {
    for (int x = 0; x < harmonics; x++) {
        if (phase[x] >= M_PI * 2.0) {
            phase[x] -= (M_PI * 2.0);
        }
    }
}

@end
