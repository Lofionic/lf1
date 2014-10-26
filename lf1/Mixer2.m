//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "Mixer2.h"

@implementation Mixer2 {
    
float source1GainContinuous;
float source2GainContinuous;

}

-(instancetype)initWithSampleRate:(Float64)graphSampleRate {
    if (self = [super initWithSampleRate:graphSampleRate]) {
        self.source1Gain = 1.0;
        self.source2Gain = 1.0;
        source1GainContinuous = 0;
        source2GainContinuous = 0;
    }
    return self;
}

-(void)renderBuffer:(AudioSignalType *)outA samples:(UInt32)numFrames {
    
    float source1GainDelta = (self.source1Gain - source1GainContinuous) / numFrames;
    float source2GainDelta = (self.source2Gain - source2GainContinuous) / numFrames;
    
    for (int i = 0; i < numFrames;i++) {
        
        float source1Gain = source1GainContinuous + (i * source1GainDelta);
        float source2Gain = source2GainContinuous + (i * source2GainDelta);
        
        //AudioSignalType mixedSignal = ((self.source1.buffer[i] * source1Gain) + (self.source2.buffer[i] * source2Gain)) / 2.0;
        
        AudioSignalType mixedSignal = tanhf(((self.source1.buffer[i] * source1Gain) + (self.source2.buffer[i] * source2Gain)) * 4.0);
        mixedSignal = mixedSignal * self.envelope.buffer[i];
        outA[i] = mixedSignal;
    }
    source1GainContinuous = self.source1Gain;
    source2GainContinuous = self.source2Gain;
}
@end
