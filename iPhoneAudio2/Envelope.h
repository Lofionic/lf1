//
//  Envelope.h
//  iPhoneAudio2
//
//  Created by Chris on 15/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Envelope : NSObject

@property float envelopeAttack;
@property float envelopeDecay;
@property float envelopeSustain;
@property float envelopeRelease;
@property float clickless;

-(void)triggerNote;
-(void)releaseNote;
-(float)getEnvelopePoint;
-(void)incrementEnvelopeBy:(float)milliseconds;

@end
