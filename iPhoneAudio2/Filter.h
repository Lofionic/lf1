//
//  Filter.h
//  iPhoneAudio2
//
//  Created by Chris on 9/16/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "SynthComponent.h"
#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>

@interface Filter : SynthComponent

-(void)processBuffer:(AudioSignalType*)outA with:(int)numFrames envelope:(AudioSignalType*)envelope;

@property float cutoff;
@property float resonance;

@end
