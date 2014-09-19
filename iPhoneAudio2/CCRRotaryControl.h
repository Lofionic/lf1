//
//  CCRRotaryControl.h
//  RotaryControl
//
//  Created by Chris on 09/09/2014.
//  Copyright (c) 2014 Chris RIvers. All rights reserved.
//
#import "BuildSettings.h"
#import <UIKit/UIKit.h>

@interface CCRRotaryControl : UIControl

@property float value;
@property int exponent;
@property int sensitivity;
@property (assign) float defaultValue;
@property bool enableDefaultValue;
@property (nonatomic, strong) UIImage *spriteSheet;
@property (nonatomic, strong) UIImage *backgroundImage;
@property CGSize spriteSize;

@property bool changeByRotating;

@end
