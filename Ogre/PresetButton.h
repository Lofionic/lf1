//
//  PresetButton.h
//  Ogre
//
//  Created by Chris on 30/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PresetButton;

@protocol PresetButtonDelegate <NSObject>

-(void)presetButtonWasTapped:(PresetButton*)presetButton;
-(void)presetButtonWasLongPressed:(PresetButton*)presetButton;

@end

@interface PresetButton : UIControl <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<PresetButtonDelegate> delegate;
@property (nonatomic, strong) UIImage *spriteSheet;
@property BOOL LEDOn;
@property (readonly) BOOL flashing;

-(void)flash;

@end
