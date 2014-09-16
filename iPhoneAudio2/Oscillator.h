//
//  oscillator.h
//  iPhoneAudio2
//
//  Created by Chris on 19/05/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CAStreamBasicDescription.h"
#import "Generator.h"

typedef enum Waveform {
    Sin,
    Saw,
    Square,
    AnalogSaw,
    AnalogSquare
} Waveform;

@interface Oscillator : Generator

@property float freq;
@property Waveform waveform;
@property (readonly) Waveform nextWaveform;
@property NSInteger octave;

-(void)setWaveform:(Waveform)waveform;

@end
