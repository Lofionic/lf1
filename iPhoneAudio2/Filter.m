//
//  Filter.m
//  iPhoneAudio2
//
//  Created by Chris on 9/16/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "Filter.h"


@implementation Filter {
    
    float f, p, q;             //filter coefficients
    float b0, b1, b2, b3, b4;  //filter buffers (beware denormals!)
    float t1, t2;
    
}


-(instancetype)initWithSampleRate:(Float64)graphSampleRate {
    
    if (self = [super initWithSampleRate:graphSampleRate]) {
        _cutoff = 0.5;
        _resonance = 0.5;
        
        f = p = q = b0 = b1 = b2 = b3 = b4 = t1 = t2 = 0;
    }

    return self;
    
}

-(void)processBuffer:(AudioSignalType*)outA samples:(int)numFrames envelope:(Envelope*)envelope {
    
    // DSP ! http://www.musicdsp.org/showArchiveComment.php?ArchiveID=25
    
    for (int i = 0; i < numFrames; i++) {
        
        float valueIn = (float)outA[i];
        
        if (valueIn > 1) {
            valueIn = 1;
        } else if (valueIn < -1) {
            valueIn = -1;
        }

        float cutoff = _cutoff;
        
        if (envelope) {
            cutoff *= envelope.buffer[i];
        }
        
        if (_lfo) {
            cutoff *= powf(0.5, -_lfo.buffer[i]);
            if (cutoff > 1) {
                cutoff = 1;
            }
        }
        
        q = 1.0f - cutoff;
        p = cutoff + 0.8f * cutoff * q;
        f = p + p - 1.0f;
        q = _resonance * (1.0f + 0.5f * q * (1.0f - q + 5.6f * q * q));
        
        valueIn -= q * b4; //feedback
        
        t1 = b1;  b1 = (valueIn + b0) * p - b1 * f;
        t2 = b2;  b2 = (b1 + t1) * p - b2 * f;
        t1 = b3;  b3 = (b2 + t2) * p - b3 * f;
        b4 = (b3 + t1) * p - b4 * f;
        b4 = b4 - b4 * b4 * b4 * 0.166667f;    //clipping
        b0 = valueIn;
        
        outA[i] = (AudioSignalType)b4;
    
        
    }
}

@end
