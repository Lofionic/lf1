//
//  Processor.h
//  iPhoneAudio2
//
//  Created by Chris on 9/19/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "SynthComponent.h"

@interface Processor : SynthComponent

-(void)processBuffer:(AudioSignalType*)outA samples:(int)numFrames;

@end
