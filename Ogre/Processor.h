//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "SynthComponent.h"

@interface Processor : SynthComponent

-(void)processBuffer:(AudioSignalType*)outA samples:(UInt32)numFrames;

@end
