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
    }
    return self;
}

-(void)renderBuffer:(AudioSignalType*)outA samples:(int)numFrames {
    NSLog(@"%@ Warning: fillBuffer method not implemented", self.description);
}


@end
