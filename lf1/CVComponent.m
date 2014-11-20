//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//
#import "Defines.h"
#import "CVComponent.h"

@implementation CVComponent {
    AudioSignalType currentOutputValue;
    AudioSignalType targetOutputValue;
    NSMutableArray *noteOns;
    float prevPitchbend;
}


- (instancetype)initWithSampleRate:(Float64)graphSampleRate
{
    self = [super initWithSampleRate:(Float64)graphSampleRate];
    if (self) {
        currentOutputValue = 0;
        targetOutputValue = 0;
        self.glide =  1;
        self.gliss = false;
        self.pitchbend = 0.5;
        prevPitchbend = 0.5;

        self.pitchWheelRange = 7;
        
        noteOns = [[NSMutableArray alloc] initWithCapacity:10];
        
    }
    return self;
}

-(void)noteOn:(NSInteger)note {
    
    // Note has been added
    NSNumber *noteNumber = [NSNumber numberWithInteger:note];
    
    if (![noteOns containsObject:noteNumber]) {
        
        if (self.gliss) {
            [noteOns addObject:noteNumber];
            // Only open gate on first note
            if ([noteOns count] == 1) {
                [self openGate];
            }
        } else {
            [noteOns addObject:noteNumber];
            //noteOns = [@[noteNumber] mutableCopy];
            [self openGate];
        }
        
        [self setFrequency];
    }
}

-(void)noteOff:(NSInteger)note {
    
    // Note has been removed
    NSNumber *noteNumber = [NSNumber numberWithInteger:note];
    
    if ([noteOns containsObject:noteNumber]) {
        
        NSNumber *lastOn = [noteOns lastObject];
        
        [noteOns removeObject:noteNumber];
        
        if ([noteOns count] == 0) {
            [self closeGate];
        } else {
            [self setFrequency];
            if (!self.gliss && noteNumber == lastOn) {
                [self openGate];
            }
        }
    }
}

-(void)setFrequency {

    // select the note to play
    NSInteger note = [[noteOns lastObject] integerValue];
    
    // set the target freq
    // Calculate note frequency
    //float frequency = (powf(powf(2, (1.0 / 12.0)), note)) * 3.4375;
    float frequency = powf(2, (note - 69) / 12.0) * 220;
    
    // Convert to float in 0-1 range
    targetOutputValue = frequency / CV_FREQUENCY_RANGE;
    
    // currentOutputValue will glide towards targetOutputVale,
    // or jump immediately if glide is zero or it is the first note played
    if (currentOutputValue == 0 || self.glide == 0) {
        currentOutputValue = targetOutputValue;
    }
}

-(void)openGate {
    // Trigger open gate in every gate component
    for (id thisId in self.gateComponents) {
        SynthComponent <CVControllerDelegate> *thisComponent = (SynthComponent <CVControllerDelegate> *)thisId;
        [thisComponent CVControllerDidOpenGate:self];
    }
}

-(void)closeGate {
    // Trigger close gate in every gate component

    for (id thisId in self.gateComponents) {
        SynthComponent <CVControllerDelegate> *thisComponent = (SynthComponent <CVControllerDelegate> *)thisId;
        [thisComponent CVControllerDidCloseGate:self];
    }
}

-(void)renderBuffer:(AudioSignalType *)outA samples:(UInt32)numFrames {

    float pitchbendDelta = (self.pitchbend - prevPitchbend) / numFrames;
    
    for (int i = 0; i < numFrames; i++) {
        
        float pitchbendNormalized = prevPitchbend + (i * pitchbendDelta);
        
        float adjustValue = (pitchbendNormalized * 2.0) - 1.0;
        adjustValue = (powf(powf(2, (1.0 / 12.0)), adjustValue * self.pitchWheelRange));
        
        outA[i] = currentOutputValue * adjustValue;
        [self updateCurrentOutputValueForOneSample];
    }
    
    prevPitchbend = self.pitchbend;
}

-(void)updateCurrentOutputValueForOneSample {
    
    if (targetOutputValue > currentOutputValue) {
        
        // Glide down
        float ellapsedMS = 1000 / self.sampleRate;
        
        currentOutputValue += ((1.1 - self.glide) * ellapsedMS / CV_FREQUENCY_RANGE);
        if (currentOutputValue > targetOutputValue) {
            currentOutputValue = targetOutputValue;
        }
        
    } else if (targetOutputValue < currentOutputValue) {
        
        // Glide down
        float ellapsedMS = 1000 / self.sampleRate;
        
        currentOutputValue -= ((1.1 - self.glide) * ellapsedMS / CV_FREQUENCY_RANGE);
        if (currentOutputValue < targetOutputValue) {
            currentOutputValue = targetOutputValue;
        }
    }
}

@end
