//
//  KeyboardControlView.m
//  iPhoneAudio2
//
//  Created by Chris on 22/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "PerformanceControlView.h"

@implementation PerformanceControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *oscNib = [[NSBundle mainBundle] loadNibNamed:@"PerformanceControlView" owner:self options:nil];
        self = oscNib[0];
    }
    return self;
}

-(void)initializeParameters {
    self.glideControl.value = 0;
    
    [self.backgroundView setImage:nil];
}

-(IBAction)controlChanged:(id)sender {
    
    if (sender == self.glideControl) {
        self.cvComponent.glide = self.glideControl.value;
    } else if (sender == self.glissSwitch) {
        self.cvComponent.gliss = (self.glissSwitch.value == 1);
    } else if (sender == self.pitchbendControl) {
        self.cvComponent.pitchbend = self.pitchbendControl.value;
    }
    
}

@end
