//
//  GeneratorComponent.h
//  iPhoneAudio2
//
//  Created by Chris on 9/16/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "SynthComponent.h"
#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>

@interface Generator : SynthComponent

-(void)fillBuffer:(AudioSignalType*)outA samples:(int)numFrames;

@end
