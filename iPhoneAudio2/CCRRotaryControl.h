//
//  CCRRotaryControl.h
//  RotaryControl
//
//  Created by Chris on 09/09/2014.
//  Copyright (c) 2014 Chris RIvers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCRRotaryControl : UIControl

@property float value;
@property (assign) float rotaryRange;
@property (assign) float rotaryOffset;
@property (assign) float defaultValue;
@property (assign) float precisionModeScale;
@property (assign) CGFloat lineWidth;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *dialImage;
@property (nonatomic, strong) UIImage *dialHighlightImage;
@property (nonatomic, strong) UIImage *spriteSheet;
@property CGSize spriteSize;

@property (assign) NSInteger rotaryHighlightSegments;

@property (nonatomic, strong) UIColor *dialBackgroundColor;
@property (nonatomic, strong) UIColor *dialSelectedBackgroundColor;
@property (nonatomic, strong) UIColor *dialPrecisionBackroundColor;

@property bool zoomEnabled;
@property bool precisionModeEnabled;
@property bool changeByRotating;

@end
