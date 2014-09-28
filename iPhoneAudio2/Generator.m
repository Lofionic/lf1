//
//  GeneratorComponent.m
//  iPhoneAudio2
//
//  Created by Chris on 9/16/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "Generator.h"

@implementation Generator

- (instancetype)initWithSampleRate:(Float64)graphSampleRate
{
    self = [super initWithSampleRate:(Float64)graphSampleRate];
    if (self) {
        _buffer = nil;
        _bufferSize = 0;
    }
    return self;
}

-(void)prepareBufferWithBufferSize:(UInt32)bufferSize {
    if (bufferSize != _bufferSize) {
        free(_buffer);
        _buffer = (AudioSignalType*)malloc(bufferSize * sizeof(AudioSignalType));
        _bufferSize = bufferSize;
    }
}

-(void)renderBuffer:(AudioSignalType*)outA samples:(UInt32)numFrames {
    NSLog(@"%@ Warning: renderBuffer method not implemented", self.description);
}


@end
