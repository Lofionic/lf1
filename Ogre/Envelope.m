//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "Envelope.h"
#define DECLICK_THRESHOLD 0.01

@implementation Envelope {
    
    double envelopePosition;
    bool envelopeTriggered;
    float envelopeDecayFrom;
    float prevEnv;
    bool noteOn;
    float attackMS;
    float decayMS;
    float releaseMS;
}

- (id)init
{
    self = [super init];
    if (self) {
        envelopeTriggered = false;
        envelopeDecayFrom = 0;
        prevEnv = 0;
        noteOn = false;
        
        self.envelopeAttack = 0;
        self.envelopeDecay = 0;
        self.envelopeSustain = 0;
        self.envelopeRelease = 0;
    }
    return self;
}

// Input values of time based parameters need to be turned into ms

-(void)CVControllerDidOpenGate:(CVComponent *)cvController {
    envelopePosition = 0;
    envelopeDecayFrom = 0;
    envelopeTriggered = true;
    noteOn = true;
}

-(void)CVControllerDidCloseGate:(CVComponent *)cvController {
    noteOn = false;
    envelopePosition = 0;
}

-(void) renderBuffer:(AudioSignalType*)outA samples:(UInt32)numFrames {

    attackMS = (self.envelopeAttack * 10000) + 1;
    decayMS = (self.envelopeDecay * 10000) + 1;
    releaseMS = (self.envelopeRelease * 10000) + 1;

    // Fill a buffer with envelope samples
    for (int i = 0; i < numFrames; i++) {
        
        outA[i]= [self getEnvelopePoint];
        
        // Increment the position of the envelope
        if (envelopeTriggered) {
            envelopePosition += 1000 / self.sampleRate;
        }
    }
}

-(AudioSignalType)getEnvelopePoint {
    
    AudioSignalType result = 0;
    
    // Return the current value of the envelope
    if (noteOn) {
        if (envelopePosition <= attackMS) {
            // Envelope is _envelopeAttacking
            result = envelopePosition / attackMS;
        } else if (envelopePosition <= attackMS + decayMS) {
            // Envelope is decaying
            result = 1 - ((envelopePosition - attackMS) / (decayMS) * (1 - self.envelopeSustain));
        } else {
            // Envelope is sustaining
            result = self.envelopeSustain;
        }
        
        envelopeDecayFrom = result;
        
    } else {
        if (self.envelopeRelease > 0 && envelopePosition <= releaseMS) {
            // Envelope is releasing
            result = MAX(envelopeDecayFrom - (envelopePosition / releaseMS) * envelopeDecayFrom, 0);
        } else {
            result = 0;
        }
    }
    
    // Limit the change of envelope amp per sample
    // Reduces clicks
    float delta = result - prevEnv;
    if (fabsf(delta) > DECLICK_THRESHOLD) {
        result = prevEnv + (DECLICK_THRESHOLD * ((delta < 0) ? -1 : 1));
    }

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
@end
