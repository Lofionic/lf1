//
//  oscillator.m
//  iPhoneAudio2
//
//  Created by Chris on 19/05/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "oscillator.h"

@implementation oscillator
{
    double phase[10];
}

const int harmonics = 5;

-(id)initWithFrequency:(float)freq withWaveform:(Waveform)waveform {
    
    if (self = [super init]) {
        self.freq = freq;
        self.amp = 1;

        self.fund = 0;
        self.waveform = waveform;
        
        for (int x = 0; x < harmonics; x++) {
            phase[x] = 0;
        }
        
     }
    
    return self;
}

-(void)retrigger {
    
    //self.phase = 0.0;
    
}

-(void)incrementPhase:(float)phaseIncrement {
    
    for (int x = 0; x < harmonics; x++) {
        phase[x] += (phaseIncrement * (x + 1));
        if (phase[x] >= M_PI * 2.0) {
            phase[x] -= (M_PI * 2.0);
        }
    }

}

-(void)avoidOverflow {
    
    for (int x = 0; x < harmonics; x++) {
        
        if (phase[x] >= M_PI * 2.0) {
            phase[x] -= (M_PI * 2.0);
        }
    }

}


-(double)getPhase:(int)harmonic {
    return phase[harmonic];
}

-(int)harmonics {
    return harmonics;
}

@end
