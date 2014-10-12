//
//  PitchbendWheelControl.h
//  Ogre
//
//  Created by Chris on 10/10/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PitchbendWheelControl : UIControl

@property (nonatomic, strong) UIImage* spriteSheet;
@property CGSize spriteSize;
@property float value;

@end
