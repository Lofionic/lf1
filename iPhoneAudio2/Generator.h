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
@property UInt32 bufferSize;

-(void)prepareBufferWithBufferSize:(UInt32)bufferSize;
-(void)renderBuffer:(AudioSignalType*)outA samples:(UInt32)numFrames;

@end
