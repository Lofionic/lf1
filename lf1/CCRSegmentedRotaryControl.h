//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuildSettings.h"
#import "CCRRotaryControl.h"

@interface CCRSegmentedRotaryControl : UIControl

@property NSInteger index;
@property NSInteger segments;
@property (nonatomic, strong) UIImage *spriteSheet;
@property (nonatomic, strong) UIImage *backgroundImage;
@property CGSize spriteSize;

@end
