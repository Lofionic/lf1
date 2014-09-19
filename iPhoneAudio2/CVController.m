//
//  CVGenerator.m
//  iPhoneAudio2
//
//  Created by Chris on 9/19/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "CVController.h"

@implementation CVController {
    AudioSignalType currentOutputValue;
    AudioSignalType targetOutputValue;
    float portamento;
}


- (instancetype)initWithSampleRate:(Float64)graphSampleRate
{
    self = [super initWithSampleRate:(Float64)graphSampleRate];
    if (self) {
        currentOutputValue = 0;
        targetOutputValue = 0;
        _glide =   1.0;
    }
    return self;
}

-(void)playNote:(NSInteger)note {
    
    // Received a note
    
    // Calculate note frequency
    float frequency = (powf(powf(2, (1.0 / 12.0)), note)) * 55.0;
    
    // Convert to float in 0-1 range
    targetOutputValue = frequency / CV_FREQUENCY_RANGE;
    
    if (currentOutputValue == 0 || _glide == 0) {
        currentOutputValue = targetOutputValue;
    }
}

-(void)openGate {
    // Trigger open gate in every gate component
    for (id thisId in _gateComponents) {
        SynthComponent <CVControllerDelegate> *thisComponent = (SynthComponent <CVControllerDelegate> *)thisId;
        [thisComponent CVControllerDidOpenGate:self];
    }
}

-(void)closeGate {
    // Trigger close gate in every gate component
    for (id thisId in _gateComponents) {
        SynthComponent <CVControllerDelegate> *thisComponent = (SynthComponent <CVControllerDelegate> *)thisId;
        [thisComponent CVControllerDidCloseGate:self];
    }
}

-(void)renderBuffer:(AudioSignalType *)outA samples:(int)numFrames {
    for (int i = 0; i < numFrames; i++) {
        outA[i] = currentOutputValue;
        [self updateCurrentOutputValueForOneSample];
    }
}

-(void)updateCurrentOutputValueForOneSample {
    
    if (targetOutputValue > currentOutputValue) {
        // Glide down
        float ellapsedMS = 1000 / self.sampleRate;
        
        currentOutputValue += ((1.1 - _glide) * ellapsedMS / CV_FREQUENCY_RANGE);
        if (currentOutputValue > targetOutputValue) {
            currentOutputValue = targetOutputValue;
        }
        
    } else if (targetOutputValue < currentOutputValue) {
        
        // Glide down
        float ellapsedMS = 1000 / self.sampleRate;
        
        currentOutputValue -= ((1.1 - _glide) * ellapsedMS / CV_FREQUENCY_RANGE);
        if (currentOutputValue < targetOutputValue) {
            currentOutputValue = targetOutputValue;
        }
    }
}

@end