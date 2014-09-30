//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "SynthComponent.h"

@interface Generator : SynthComponent

@property AudioSignalType* buffer;
@property UInt32 bufferSize;

-(void)prepareBufferWithBufferSize:(UInt32)bufferSize;
-(void)renderBuffer:(AudioSignalType*)outA samples:(UInt32)numFrames;

@end
