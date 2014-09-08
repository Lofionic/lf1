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

typedef enum Waveform {
    Sin,
    Saw,
    Square
} Waveform;

@interface oscillator : NSObject


@property float freq;
@property (nonatomic) double fund;
//@property (readonly) double ff;

@property float amp;

@property Waveform waveform;

-(id)initWithFrequency:(float)freq withWaveform:(Waveform)waveform;
-(void)retrigger;
-(void)incrementPhase:(float)phaseIncrement;
-(void)avoidOverflow;
-(double)getPhase:(int)harmonic;
-(int)harmonics;

@end
