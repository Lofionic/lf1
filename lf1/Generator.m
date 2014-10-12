//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "Generator.h"

@implementation Generator

- (instancetype)initWithSampleRate:(Float64)graphSampleRate
{
    self = [super initWithSampleRate:(Float64)graphSampleRate];
    if (self) {
        self.buffer = nil;
        self.bufferSize = 0;
    }
    return self;
}

-(void)prepareBufferWithBufferSize:(UInt32)bufferSize {
    if (bufferSize != self.bufferSize) {
        NSLog(@"Preparing buffer of size: %i for component:%@", (unsigned int)bufferSize, self.description);
        free(_buffer);
        self.buffer = (AudioSignalType*)malloc(bufferSize * sizeof(AudioSignalType));
        self.bufferSize = bufferSize;
    }
}

-(void)renderBuffer:(AudioSignalType*)outA samples:(UInt32)numFrames {
    NSLog(@"%@ Warning: renderBuffer method not implemented", self.description);
}


@end
