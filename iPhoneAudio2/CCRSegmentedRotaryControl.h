//
//  CCRSegmentedRotaryControl.h
//  iPhoneAudio2
//
//  Created by Chris on 18/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuildSettings.h"
#import "CCRRotaryControl.h"

@interface CCRSegmentedRotaryControl : UIControl

@property NSInteger selectedSegmentIndex;
@property NSInteger segments;
@property (nonatomic, strong) UIImage *spriteSheet;
@property (nonatomic, strong) UIImage *backgroundImage;
@property CGSize spriteSize;

@end
