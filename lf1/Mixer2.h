//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "Generator.h"

@interface Mixer2 : Generator

@property (assign) Generator* source1;
@property (assign) Generator* source2;
@property (assign) Generator* envelope;

@property float source1Gain;
@property float source2Gain;

@end
