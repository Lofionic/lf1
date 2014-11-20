//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "Analog_Oscillator.h"
#import "BuildSettings.h"
#import "Defines.h"

#define WAVETABLE_SIZE 8196

@implementation Analog_Oscillator {
    double phase;
    AudioSignalType prevResult;
    AudioSignalType sinWaveTable[WAVETABLE_SIZE];
    AudioSignalType sawWaveTable[WAVETABLE_SIZE];
    AudioSignalType squareWaveTable[WAVETABLE_SIZE];
}

-(id)initWithSampleRate:(Float64)graphSampleRate {
    self = [super initWithSampleRate:graphSampleRate];
    if (self) {
        phase = 0;
        [self generateWavetablels];
    }
    return self;
}

-(void)generateWavetablels {
    
    // Generate Sin wavetable
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        AudioSignalType a = sin(tablePhase);
        sinWaveTable[i] = a;
    }
    
    // Generate Saw wavetable
    
    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        float amp = 0.5f;
        double result = 0;
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        for (int j = 1; j < ANALOG_HARMONICS + 1; j++) {
            result += sin(tablePhase * j) * amp;
            amp /= 2.0;
        }
        sawWaveTable[i] = (AudioSignalType)result;
        
    }
    
    // Generate Square wavetable

    for (int i = 0; i < WAVETABLE_SIZE; i++) {
        double sum = 0;
        float count = 0;
        double tablePhase = (i / (float)WAVETABLE_SIZE + 1.0) * (M_PI * 2);
        for (int j = 1; j < ANALOG_HARMONICS + 1;j += 2) {
            
            sum += sin(tablePhase * j);
            count ++;
        }
        sum /= count;
        squareWaveTable[i] = (AudioSignalType)sum;
    }

}

-(void) renderBuffer:(AudioSignalType*)outA samples:(UInt32)numFrames {
    
    LFO *lfo = self.lfo;
    
    // Fill a buffer with oscillator samples
    for (int i = 0; i < numFrames; i++) {
        
        AudioSignalType value = [self getNextSample];

        outA[i] = value;
        
        // Apply LFO
        AudioSignalType lfoValue = 1;
        
        if (lfo) {
            lfoValue = powf(0.5, -lfo.buffer[i]);
        }
        
        // Apply freq adjustment
        float adjustValue = (self.freq_adjust * 2.0) - 1.0;
        
        adjustValue = (powf(powf(2, (1.0 / 12.0)), adjustValue * 7));
        
        float freq = FLT_MIN;
        if ([self cvController]) {
            freq = [self cvController].buffer[i] * CV_FREQUENCY_RANGE;
        }
    
        // Increment Phase
        phase += ((M_PI * freq * lfoValue * adjustValue * powf(2, self.octave)) / self.sampleRate);
        

        // Prevent overflow
        if (phase > M_PI * 2.0) {
            phase -= M_PI * 2.0;
        }
        
        // Change waveform on zero crossover
        if ((value > 0) != (prevResult < 0) || value == 0) {
            if (self.waveform != self.nextWaveform) {
                [self changeToNextWaveform];
                phase = 0;
            }
        }
        
        prevResult = value;
        
    }
}

-(AudioSignalType) getNextSample {
    
    switch ([self waveform]) {
        case Sin: {
            
            double tPhase = phase;
            float sampleIndexFloat = (tPhase / (M_PI * 2)) * (WAVETABLE_SIZE - 1);
            AudioSignalType sampleIndexLower = sinWaveTable[(int)floor(sampleIndexFloat)];
            AudioSignalType sampleIndexUpper = sinWaveTable[(int)ceil(sampleIndexFloat)];
            float remainder = fmodf(sampleIndexFloat, 1);
            
            AudioSignalType a = sampleIndexLower + (sampleIndexUpper - sampleIndexLower) * remainder;
            
            return a;

        }
        case Saw: {
            
            double tPhase = phase;
            float sampleIndexFloat = (tPhase / (M_PI * 2)) * (WAVETABLE_SIZE - 1);
            AudioSignalType sampleIndexLower = sawWaveTable[(int)floor(sampleIndexFloat)];
            AudioSignalType sampleIndexUpper = sawWaveTable[(int)ceil(sampleIndexFloat)];
            float remainder = fmodf(sampleIndexFloat, 1);
            
            AudioSignalType a = sampleIndexLower + (sampleIndexUpper - sampleIndexLower) * remainder;
            
            return a;

        }
        case Square: {
            
            double tPhase = phase;
            float sampleIndexFloat = (tPhase / (M_PI * 2)) * (WAVETABLE_SIZE -1);
            AudioSignalType sampleIndexLower = squareWaveTable[(int)floor(sampleIndexFloat)];
            AudioSignalType sampleIndexUpper = squareWaveTable[(int)ceil(sampleIndexFloat)];
            float remainder = fmodf(sampleIndexFloat, 1);
            
            AudioSignalType a = sampleIndexLower + (sampleIndexUpper - sampleIndexLower) * remainder;

            return a;
            
        }

        default:
            return 0;
    }
}

@end
