//
//  CVGenerator.h
//  iPhoneAudio2
//
//  Created by Chris on 9/19/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//
#import "BuildSettings.h"
#import "Generator.h"

@class CVController;

@protocol CVControllerDelegate <NSObject>

-(void)CVControllerDidOpenGate:(CVController*)cvController ;
-(void)CVControllerDidCloseGate:(CVController*)cvController;

@end


@interface CVController : Generator

@property float glide;
@property bool gliss;
@property (nonatomic, strong) NSArray *gateComponents;

-(void)playNote:(NSInteger)note;
-(void)openGate;
-(void)closeGate;

@end
