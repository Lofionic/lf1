//
//  PresetController.h
//  iPhoneAudio2
//
//  Created by Chris on 9/19/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//
#import "BuildSettings.h"
#import <Foundation/Foundation.h>

@interface PresetController : NSObject

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, strong) NSArray *keyPaths;

-(instancetype)initWithViewController:(UIViewController*)viewController;
-(void)storePresetAtIndex:(NSInteger)index;
-(void)restorePresetAtIndex:(NSInteger)index;

@end
