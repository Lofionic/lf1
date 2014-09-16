//
//  AudioComponent.h
//  iPhoneAudio2
//
//  Created by Chris on 9/16/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef float AudioSignalType;

@interface SynthComponent : NSObject

@property Float64 sampleRate;

- (instancetype)initWithSampleRate:(Float64)graphSampleRate;

@end
