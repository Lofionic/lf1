//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SynthComponent.h"
#import "Generator.h"
#import "CVController.h"

@interface Envelope : Generator <CVControllerDelegate>

@property float envelopeAttack;
@property float envelopeDecay;
@property float envelopeSustain;
@property float envelopeRelease;

@end

