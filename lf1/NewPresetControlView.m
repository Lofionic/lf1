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
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(storeLongPressed:)];
    longPressGestureRecognizer.minimumPressDuration = 1.5;
    [self.storeButton addGestureRecognizer:longPressGestureRecognizer];
}

-(void)initializeParameters {
    [self updateLabel];
    
    self.isStoring = NO;
}

-(void)updateLabel {
    if (!self.isStoring) {
        [self.presetLabel setText:[NSString stringWithFormat:@"%.2li", self.presetController.currentIndex]];
        self.storeIndex = self.presetController.currentIndex;
    } else {
        [self.presetLabel setText:[NSString stringWithFormat:@"%.2li", self.storeIndex]];
    }
}

-(IBAction)storeTapped:(id)sender {
    if (self.isStoring) {
        [self confirmStoring];
    }
}

-(void)storeLongPressed:(UIGestureRecognizer*)gestureRecognizer {
    if (!self.isStoring) {
        [self startStoring];
    }

}

-(IBAction)preset:(id)sender {
    if (!self.isStoring) {
        [self.presetController restorePresetAtIndex:self.presetStepper.value];
    } else {
        self.storeIndex = self.presetStepper.value;
        self.storeTimeout = 0;
    }
    [self updateLabel];
}

-(void)startStoring {
    self.isStoring = YES;
    self.storeTimeout = 0;
    [self flashLabel];
    [self updateLabel];
}

-(void)cancelStoring {
    self.isStoring = NO;
    [self.presetStepper setValue:self.presetController.currentIndex];
    [self updateLabel];
}

-(void)confirmStoring {
    [self.presetController storePresetAtIndex:self.storeIndex];
    [self.presetController restorePresetAtIndex:self.storeIndex];
    [self cancelStoring];
}

-(void)flashLabel {
    if (self.isStoring) {
        // We are still in storing state
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.presetLabel setHidden:!self.presetLabel.hidden];
            self.storeTimeout ++;
            if (self.storeTimeout > 30) {
                [self performSelectorOnMainThread:@selector(cancelStoring) withObject:nil waitUntilDone:NO];
            }
        });
        [self performSelector:@selector(flashLabel) withObject:nil afterDelay:0.2];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.presetLabel setHidden:NO];
        });
    }
}

@end
