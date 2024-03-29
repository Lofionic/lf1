//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "Generator.h"
#import "CVComponent.h"

typedef enum LFOWaveform {
    LFOSin,
    LFOSaw,
    LFORamp,
    LFOSquare,
    LFOSampleHold
} LFOWaveform;

@interface LFO : Generator <CVControllerDelegate>

@property float freq;
@property float amp;
@property float eg_amount;
@property LFOWaveform waveform;
@property (readonly) LFOWaveform nextWaveform;

@end
