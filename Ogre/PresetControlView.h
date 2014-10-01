//
//  PresetControlView.h
//  Ogre
//
//  Created by Chris on 30/09/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControlView.h"
#import "PresetController.h"
#import "PresetButton.h"

@interface PresetControlView : ControlView <PresetButtonDelegate>

@property (nonatomic, strong) PresetController *presetController;
@property (nonatomic, strong) NSArray *presetButtons;

@end
