//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
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
@property (assign) LFO *lfo;
@property (assign) Envelope* envelope;

@end
