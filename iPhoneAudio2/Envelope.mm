//
//  Envelope.m
//  iPhoneAudio2
//
//  Created by Chris on 15/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "Envelope.h"

@implementation Envelope {
    
    double envelopePosition;
    bool envelopeTriggered;
    float envelopeDecayFrom;
    float prevEnv;
    bool noteOn;
}

- (id)init
{
    self = [super init];
    if (self) {
        envelopeTriggered = false;
        envelopeDecayFrom = 0;
        prevEnv = 0;
        noteOn = false;
        
        _envelopeAttack = 10;
        _envelopeDecay = 10;
        _envelopeSustain = 1;
        _envelopeRelease = 10;
    }
    return self;
}

-(void)triggerNote {
    envelopePosition = 0;
    envelopeDecayFrom = 0;
    envelopeTriggered = true;
    noteOn = true;
}

-(void)releaseNote {
    noteOn = false;
    envelopePosition = 0;
}

-(AudioSignalType)getEnvelopePoint {
    
    AudioSignalType result = 0;
    
    // Return the current value of the envelope
    if (noteOn) {
        if (envelopePosition <= _envelopeAttack) {
            // Envelope is _envelopeAttacking
            result = envelopePosition / _envelopeAttack;
        } else if (envelopePosition <= _envelopeAttack + _envelopeDecay) {
            // Envelope is decaying
            result = 1 - ((envelopePosition - _envelopeAttack) / (_envelopeDecay) * (1 - _envelopeSustain));
        } else {
            // Envelope is sustaining
            result = _envelopeSustain;
        }
        
        envelopeDecayFrom = result;
        
    } else {
        if (_envelopeRelease > 0 && envelopePosition <= _envelopeRelease) {
            // Envelope is releasing
            result = MAX(envelopeDecayFrom - (envelopePosition / _envelopeRelease) * envelopeDecayFrom, 0);
        } else {
            result = 0;
        }
    }
    
    // Limit the change of envelope amp per sample
    // Reduces clicks
    //if (_clickless > 0) {
    float delta = result - prevEnv;
        if (fabs(delta) > 0.01) {
           result = prevEnv + (0.01 * ((delta < 0) ? -1 : 1));
       }
     //}
    
    prevEnv = result;
    
    if (result <= 0 && envelopePosition > 0) {
        // Envelope has finished
        envelopePosition = 0;
        envelopeDecayFrom = 0;
        envelopeTriggered = false;
        result = 0;
    }
    
    return result;
}

-(void) fillBuffer:(AudioSignalType*)outA samples:(int)numFrames {
    
    // Fill a buffer with envelope samples
    for (int i = 0; i < numFrames; i++) {
        
        outA[i]= [self getEnvelopePoint];
        
        // Increment the position of the envelope
        if (envelopeTriggered) {
            envelopePosition += 1000 / self.sampleRate;
        }
    }
}
@end
