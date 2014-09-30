//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef float AudioSignalType;

@interface SynthComponent : NSObject

@property Float64 sampleRate;

- (instancetype)initWithSampleRate:(Float64)graphSampleRate;

@end
