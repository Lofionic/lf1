//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "Generator.h"
#import "LFO.h"
#import "CVController.h"

typedef enum OscillatorWaveform {
    Sin,
    Saw,
    Square
} OscillatorWaveform;

@interface Oscillator : Generator

@property float freq_adjust;
@property OscillatorWaveform waveform;
@property (readonly) OscillatorWaveform nextWaveform;
@property NSInteger octave;

-(void)setWaveform:(OscillatorWaveform)waveform;

@property (weak) LFO* lfo;
@property (weak) CVController* cvController;

@end
