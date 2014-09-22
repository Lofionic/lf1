//
//  Filter.h
//  iPhoneAudio2
//
//  Created by Chris on 9/16/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Envelope.h"
#import "LFO.h"
#import "Processor.h"

@interface VCF : Processor


@property float cutoff;
@property float resonance;
@property float eg_amount;
@property (weak) LFO *lfo;
@property (weak) Envelope* envelope;

@end
