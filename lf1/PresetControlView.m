//
//  PresetControlView.m
//  Ogre
//
//  Created by Chris on 30/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "PresetControlView.h"
#import "PresetButton.h"

@implementation PresetControlView

-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *presetNib = [[NSBundle mainBundle] loadNibNamed:@"PresetControlView" owner:self options:nil];
        self = presetNib[0];
    }
    return self;
}

-(void)initializeParameters {
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:8];
    for (UIView *thisView in self.subviews) {
        if ([thisView isKindOfClass:[PresetButton class]]) {
            [buttons addObject:thisView];
        }
    }
    
    self.presetButtons = [NSArray arrayWithArray:buttons];
    
    [self.presetButtons[0] setSpriteSheet:[UIImage imageNamed:@"buttonA"]];
    [self.presetButtons[1] setSpriteSheet:[UIImage imageNamed:@"buttonB"]];
    [self.presetButtons[2] setSpriteSheet:[UIImage imageNamed:@"buttonC"]];
    [self.presetButtons[3] setSpriteSheet:[UIImage imageNamed:@"buttonD"]];
    [self.presetButtons[4] setSpriteSheet:[UIImage imageNamed:@"buttonE"]];
    [self.presetButtons[5] setSpriteSheet:[UIImage imageNamed:@"buttonF"]];
    [self.presetButtons[6] setSpriteSheet:[UIImage imageNamed:@"buttonG"]];
    [self.presetButtons[7] setSpriteSheet:[UIImage imageNamed:@"buttonH"]];
   
    for (PresetButton *thisButton in self.presetButtons) {
        thisButton.delegate = self;
    }
    
    [self selectPresetWithIndex:0];
    
    UIImage *presetsFrame = [UIImage imageNamed:@"presets_frame"];
    presetsFrame = [presetsFrame resizableImageWithCapInsets:UIEdgeInsetsMake(25, 15, 15, 15)];
    [self.backgroundView setImage:presetsFrame];
}



-(void)selectPresetWithIndex:(NSInteger)index  {

    for (int i = 0; i < 8; i++) {
        [self.presetButtons[i] setLEDOn:(i == index)];
    }
    
    [self.presetController restorePresetAtIndex:index];
}

-(void)storePresetAtIndex:(NSInteger)index {
    
    NSLog(@"Storing Preset");
    [self.presetController storePresetAtIndex:index];

    for (int i = 0; i < 8; i++) {
        [self.presetButtons[i] setLEDOn:(i == index)];
    }
    
    for (PresetButton* thisButton in self.presetButtons) {
        [thisButton flash];
    }
}

-(void)presetButtonWasTapped:(PresetButton *)presetButton {
    
    [self selectPresetWithIndex:presetButton.tag];
    
}

-(void)presetButtonWasLongPressed:(PresetButton *)presetButton {

    //[self selectPresetWithIndex:presetButton.tag];

    
    [self storePresetAtIndex:presetButton.tag];
}

@end
