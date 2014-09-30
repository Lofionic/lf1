//
//  Mixer2.h
//  iPhoneAudio2
//
//  Created by Chris on 30/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "Generator.h"

@interface Mixer2 : Generator

@property Generator* source1;
@property Generator* source2;
@property Generator* envelope;

@property float source1Gain;
@property float source2Gain;

@end
