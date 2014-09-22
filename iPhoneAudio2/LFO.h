//
//  LFO.h
//  iPhoneAudio2
//
//  Created by Chris on 16/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "Generator.h"
#import "CVController.h"

typedef enum LFOWaveform {
    LFOSin,
    LFOSaw,
    LFOSquare,
    LFOSampleHold
} LFOWaveform;

@interface LFO : Generator <CVControllerDelegate>

@property AudioSignalType* buffer;
@property float freq;
@property float amp;
@property float eg_amount;
@property LFOWaveform waveform;
@property (readonly) LFOWaveform nextWaveform;

@end
