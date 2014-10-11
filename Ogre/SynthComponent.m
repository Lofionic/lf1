//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "SynthComponent.h"
#import "BuildSettings.h"

@implementation SynthComponent

- (instancetype)initWithSampleRate:(Float64)sampleRate
{
    self = [super init];
    if (self) {
        self.sampleRate = sampleRate;
    }
    return self;
}

@end
