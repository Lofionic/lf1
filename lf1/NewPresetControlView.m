//
//  NewPresetControlView.m
//  LF1
//
//  Created by Chris on 03/12/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "NewPresetControlView.h"

@implementation NewPresetControlView

-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *presetNib = [[NSBundle mainBundle] loadNibNamed:@"NewPresetControlView" owner:self options:nil];
        self = presetNib[0];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    UIImage *presetsFrame = [UIImage imageNamed:@"presets_frame"];
    presetsFrame = [presetsFrame resizableImageWithCapInsets:UIEdgeInsetsMake(25, 15, 15, 15)];
    [self.backgroundView setImage:presetsFrame];
    
    [self.presetLabel setFont:[UIFont fontWithName:@"Liquid Crystal" size:20]];
    
    [self.stepper setBackgroundImage:[UIImage imageNamed:@"preset_stepper"] forState:UIControlStateNormal];
    [self.stepper setTintColor:[UIColor clearColor]];
}

-(void)initializeParameters {
    [self updateLabel];
}

-(void)updateLabel {
    
    [self.presetLabel setText:[NSString stringWithFormat:@"%.2li", self.presetController.currentIndex]];
    
}

-(IBAction)nextPreset:(id)sender {
    
    if (self.presetController.currentIndex < 99) {
        [self.presetController restorePresetAtIndex:self.presetController.currentIndex + 1];
    }
    
    [self updateLabel];
}

-(IBAction)prevPreset:(id)sender {
    if (self.presetController.currentIndex > 0) {
        [self.presetController restorePresetAtIndex:self.presetController.currentIndex - 1];
    }
    
    [self updateLabel];
}

-(IBAction)preset:(id)sender {
    UIStepper *stepper = (UIStepper*)sender;
    [self.presetController restorePresetAtIndex:stepper.value];
    [self updateLabel];
    
}

@end
