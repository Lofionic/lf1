//
//  keyboardView.h
//  iPhoneAudio2
//
//  Created by Chris on 9/9/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVComponent.h"

@interface KeyboardView : UIView

@property (nonatomic, weak) CVComponent *cvController;
@property NSInteger keyboardShift;

@end