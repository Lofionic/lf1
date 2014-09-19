//
//  GeneratorComponent.h
//  iPhoneAudio2
//
//  Created by Chris on 9/16/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "SynthComponent.h"

@interface Generator : SynthComponent

@property AudioSignalType* buffer;

-(void)renderBuffer:(AudioSignalType*)outA samples:(int)numFrames;

@end
