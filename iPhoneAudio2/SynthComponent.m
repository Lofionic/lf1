//
//  AudioComponent.m
//  iPhoneAudio2
//
//  Created by Chris on 9/16/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "SynthComponent.h"
#import "BuildSettings.h"

@implementation SynthComponent

- (instancetype)initWithSampleRate:(Float64)sampleRate
{
    self = [super init];
    if (self) {
        _sampleRate = sampleRate;
    }
    return self;
}

@end
