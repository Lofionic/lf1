//
//  GeneratorComponent.m
//  iPhoneAudio2
//
//  Created by Chris on 9/16/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "Generator.h"

@implementation Generator

-(void)fillBuffer:(AudioSignalType*)outA with:(int)numFrames {
    for (int i = 0; i < numFrames; i++) {
        outA[i] = 0;
    }
}


@end
