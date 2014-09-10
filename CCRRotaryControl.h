//
//  CCRRotaryControl.h
//  RotaryControl
//
//  Created by Chris on 09/09/2014.
//  Copyright (c) 2014 Chris RIvers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCRRotaryControl : UIControl

@property (assign) float value;
@property (assign) float rotaryRange;
@property (assign) float rotaryOffset;
@property (assign) float defaultValue;
@property (assign) float precisionModeScale;
@property (nonatomic, strong) UIImage *dialImage;
@property (nonatomic, strong) UIImage *dialHighlightImage;
@property (assign) NSInteger rotaryHighlightSegments;

@property bool enableZoom;
@property bool enablePrecision;

@end
