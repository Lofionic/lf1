//
//  NewPresetControlView.m
//  LF1
//
//  Created by Chris on 03/12/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "NewPresetControlView.h"
#import "Defines.h"

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
    [self.stepper setBackgroundImage:[UIImage imageNamed:@"preset_stepper_highlight"] forState:UIControlStateHighlighted];
    //[self.stepper setIncrementImage:[UIImage imageNamed:@"store_on"] forState:UIControlStateNormal];
    
    [self.stepper setTintColor:[UIColor clearColor]];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(storeLongPressed:)];
    longPressGestureRecognizer.minimumPressDuration = 1;
    [self.storeButton addGestureRecognizer:longPressGestureRecognizer];
}

-(void)initializeParameters {
    [self updateLabel];
    [self.stepper setMaximumValue:[self.presetController presetCount] - 1];
    
    self.isStoring = NO;
}

-(void)updateLabel {
    if (!self.isStoring) {
        [self.presetLabel setText:[NSString stringWithFormat:@"%.2li", (long)self.presetController.currentIndex]];
        self.storeIndex = self.presetController.currentIndex;
    } else {
        if (self.storeIndex >= [self.presetController presetCount]) {
            [self.presetLabel setText:[NSString stringWithFormat:@"%.2li.", (long)self.storeIndex]];
        } else {
            [self.presetLabel setText:[NSString stringWithFormat:@"%.2li", (long)self.storeIndex]];
        }
    }
}

-(IBAction)storeTapped:(id)sender {
    if (!self.isStoring) {
        [self startStoring];
    }
}

-(void)storeLongPressed:(UIGestureRecognizer*)gestureRecognizer {
    if (self.isStoring) {
        [self confirmStoring];
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
    [self.storeButton setImage:[UIImage imageNamed:@"store_on"] forState:UIControlStateNormal];
    [self.stepper setMaximumValue:[self.presetController presetCount]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults valueForKey:USER_DEFAULTS_KEY_1_2_PRESET_TUTORIAL]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Storing Presets" message:PRESET_TUTORIAL_TEXT preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self setIsShowingTutorialAlert:NO];
            //[userDefaults setValue:@YES forKey:USER_DEFAULTS_KEY_1_2_PRESET_TUTORIAL];
        }];
        
        UIAlertAction *dontShowAgainAction= [UIAlertAction actionWithTitle:@"Don't Show Again" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self setIsShowingTutorialAlert:NO];
            [userDefaults setValue:@YES forKey:USER_DEFAULTS_KEY_1_2_PRESET_TUTORIAL];
        }];
        
        [alertController addAction:okAction];
        [alertController addAction:dontShowAgainAction];
        
        [self setIsShowingTutorialAlert:YES];
        [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
        
    }
}

-(void)endStoring {
    self.isStoring = NO;
    [self.presetStepper setValue:self.presetController.currentIndex];
    
    [self updateLabel];
    
    [self.stepper setMaximumValue:[self.presetController presetCount] - 1];
}

-(void)confirmStoring {
    [self.presetController storePresetAtIndex:self.storeIndex];
    [self.presetController restorePresetAtIndex:self.storeIndex];
    [self endStoring];
    
    self.storeConfirmTimeout = 0;
    [self.storeButton setEnabled:NO];
    [self.presetStepper setEnabled:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.presetLabel setHidden:NO];
        [self flashLabelFast];
    });
}

-(void)flashLabel {
    if (self.isStoring) {
        // We are still in storing state
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.presetLabel setHidden:!self.presetLabel.hidden];
            if (!self.isShowingTutorialAlert) {
                self.storeTimeout ++;
            }
            if (self.storeTimeout > 30) {
                [self.storeButton setImage:[UIImage imageNamed:@"store_off"] forState:UIControlStateNormal];

                [self performSelectorOnMainThread:@selector(endStoring) withObject:nil waitUntilDone:NO];
            }
        });
        [self performSelector:@selector(flashLabel) withObject:nil afterDelay:0.2];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.presetLabel setHidden:NO];
        });
    }
}

-(void)flashLabelFast {
    [self.presetLabel setHidden:!self.presetLabel.hidden];
    if (!self.isShowingTutorialAlert) {
        self.storeConfirmTimeout ++;
    }
    if (self.storeConfirmTimeout < 10) {
        [self performSelector:@selector(flashLabelFast) withObject:nil afterDelay:0.1];
    } else {
        [self.storeButton setEnabled:YES];
        [self.presetStepper setEnabled:YES];
        [self.presetLabel setHidden:NO];
        [self.storeButton setImage:[UIImage imageNamed:@"store_off"] forState:UIControlStateNormal];
    }
}


@end
