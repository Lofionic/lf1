//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "VCF.h"


@implementation VCF {
    
    float f, p, q;             //filter coefficients
    float b0, b1, b2, b3, b4;  //filter buffers (beware denormals!)
    float t1, t2;
    
    float cutoffContinuous;
    float resContinous;
    float egContinuous;
}

-(instancetype)initWithSampleRate:(Float64)graphSampleRate {
    
    if (self = [super initWithSampleRate:graphSampleRate]) {
        self.cutoff = 0;
        self.resonance = 0;
        self.lfo = nil;
        self.envelope = nil;
        
        f = p = q = b0 = b1 = b2 = b3 = b4 = t1 = t2 = 0;
        
        cutoffContinuous = 0;
        resContinous = 0;
        egContinuous = 0;
    }

    return self;
}

-(void)processBuffer:(AudioSignalType*)outA samples:(UInt32)numFrames {
    
    // DSP ! http://www.musicdsp.org/showArchiveComment.php?ArchiveID=25
    
    float cutoffDelta = (self.cutoff - cutoffContinuous) / numFrames;
    float resDelta = (self.resonance - resContinous) / numFrames;
    float egDelta = (self.eg_amount - egContinuous) / numFrames;
    
    LFO *lfo = self.lfo;
    
    for (int i = 0; i < numFrames; i++) {
        
        float valueIn = (float)outA[i];
        

            if (valueIn > 1) {
                valueIn = 1;
            } else if (valueIn < -1) {
                valueIn = -1;
        }

        float cutoff = cutoffContinuous + (cutoffDelta * i);

        
        if (self.envelope) {

            float egAmount = egContinuous + (egDelta * i);
            
            float env = ((egAmount - 0.5) * 2.0);
            
            float envValue = self.envelope.buffer[i];
            
            if (env < 0) {
                envValue = 1 - envValue;
            }
            
            float newCutoff = cutoff + (((envValue * cutoff) - cutoff) * fabsf(env));

            cutoff = newCutoff;
        }
        
        if (lfo) {
            float buffer = (lfo.buffer[i] + 1) / 2.0f;
            
            //cutoff *= powf(0.5, -self.lfo.buffer[i]);
            if (cutoff > 1) {
                cutoff = 1;
            } else if (cutoff < 0) {
                cutoff = 0;
            }
            cutoff *= buffer;
        }
    
        
        q = 1.0f - cutoff;
        p = cutoff + 0.8f * cutoff * q;
        f = p + p - 1.0f;
        
        float res = resContinous + (resDelta * i);
        q = res * (1.0f + 0.5f * q * (1.0f - q + 5.6f * q * q));
        
        valueIn -= q * b4; //feedback
        
        t1 = b1;  b1 = (valueIn + b0) * p - b1 * f;
        t2 = b2;  b2 = (b1 + t1) * p - b2 * f;
        t1 = b3;  b3 = (b2 + t2) * p - b3 * f;
        b4 = (b3 + t1) * p - b4 * f;
        b4 = b4 - b4 * b4 * b4 * 0.166667f;    //clipping
        b0 = valueIn;

        outA[i] = (AudioSignalType)b4;
        
    }
    
    cutoffContinuous = self.cutoff;
    resContinous = self.resonance;
    egContinuous = self.eg_amount;
    
}

@end
