//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "VCF.h"


@implementation VCF {
    
    float f, p, q;             //filter coefficients
    float b0, b1, b2, b3, b4;  //filter buffers (beware denormals!)
    float t1, t2;
    
}

-(instancetype)initWithSampleRate:(Float64)graphSampleRate {
    
    if (self = [super initWithSampleRate:graphSampleRate]) {
        _cutoff = 0;
        _resonance = 0;
        _lfo = nil;
        _envelope = nil;
        
        f = p = q = b0 = b1 = b2 = b3 = b4 = t1 = t2 = 0;
    }

    return self;
}

-(void)processBuffer:(AudioSignalType*)outA samples:(UInt32)numFrames {
    
    // DSP ! http://www.musicdsp.org/showArchiveComment.php?ArchiveID=25
    
    for (int i = 0; i < numFrames; i++) {
        
        float valueIn = (float)outA[i];
        

            if (valueIn > 1) {
                valueIn = 1;
            } else if (valueIn < -1) {
                valueIn = -1;
            }

            float cutoff = _cutoff;

        
            if (_envelope) {

                float env = ((_eg_amount - 0.5) * 2.0);
                
                float envValue = _envelope.buffer[i];
                
                if (env < 0) {
                    envValue = 1 - envValue;
                }
                
                float newCutoff = cutoff + (((envValue * cutoff) - cutoff) * fabsf(env));

                
                //NSLog(@"In: %.2f Buffer: %.2f EGAMT: %.2f Env: %.2f Out: %.2f", cutoff, _envelope.buffer[i], _eg_amount, env, newCutoff);
                
                cutoff = newCutoff;
            }
            
            if (_lfo) {
                float buffer = (_lfo.buffer[i] + 1) / 2.0f;
                cutoff *= buffer;
                //cutoff *= powf(0.5, -_lfo.buffer[i]);
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
            
            //printf("b0: %.2f b1: %.2f b2: %.2f b3: %.2f b4: %.2f \n", b0, b1, b2, b3, b4);
        }
    
}

@end
