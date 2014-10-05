//
//  KeyboardControlView.m
//  iPhoneAudio2
//
//  Created by Chris on 22/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "KeyboardControlView.h"

@implementation KeyboardControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *oscNib = [[NSBundle mainBundle] loadNibNamed:@"KeyboardControlView" owner:self options:nil];
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
        _cvController.glide = self.glideControl.value;
    } else if (sender == self.glissSwitch) {
        _cvController.gliss = (self.glissSwitch.value == 1);
    }
    
}

@end
