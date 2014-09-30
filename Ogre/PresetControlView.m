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
    _presetButtons = [NSArray arrayWithArray:buttons];
    [_presetButtons[0] setSpriteSheet:[UIImage imageNamed:@"buttonA"]];
    [_presetButtons[1] setSpriteSheet:[UIImage imageNamed:@"buttonB"]];
    [_presetButtons[2] setSpriteSheet:[UIImage imageNamed:@"buttonC"]];
    [_presetButtons[3] setSpriteSheet:[UIImage imageNamed:@"buttonD"]];
    [_presetButtons[4] setSpriteSheet:[UIImage imageNamed:@"buttonE"]];
    [_presetButtons[5] setSpriteSheet:[UIImage imageNamed:@"buttonF"]];
    [_presetButtons[6] setSpriteSheet:[UIImage imageNamed:@"buttonG"]];
    [_presetButtons[7] setSpriteSheet:[UIImage imageNamed:@"buttonH"]];
    
    [_presetButtons[6] setLEDOn:YES];
}

@end
