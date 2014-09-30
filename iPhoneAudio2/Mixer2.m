//
//  Mixer2.m
//  iPhoneAudio2
//
//  Created by Chris on 30/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "Mixer2.h"

@implementation Mixer2

-(instancetype)initWithSampleRate:(Float64)graphSampleRate {
    
    if (self = [super initWithSampleRate:graphSampleRate]) {
        _source1Gain = 1.0;
        _source2Gain = 1.0;
    }
    
    return self;
}

-(void)renderBuffer:(AudioSignalType *)outA samples:(UInt32)numFrames {
    
    for (int i = 0; i < numFrames;i++) {
        
        AudioSignalType mixedSignal = ((_source1.buffer[i] * _source1Gain) + (_source2.buffer[i] * _source2Gain) / 2.0);
        mixedSignal = mixedSignal * _envelope.buffer[i];
        
        outA[i] = mixedSignal;
    }
}
@end
