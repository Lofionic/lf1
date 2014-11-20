//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "BuildSettings.h"
#import "Generator.h"

@class CVComponent;

@protocol CVControllerDelegate <NSObject>

-(void)CVControllerDidOpenGate:(CVComponent*)cvController ;
-(void)CVControllerDidCloseGate:(CVComponent*)cvController;

@end

@interface CVComponent : Generator

@property float glide;
@property bool gliss;
@property (nonatomic, strong) NSArray *gateComponents;
@property float pitchbend;
@property NSInteger pitchWheelRange;

-(void)noteOn:(NSInteger)note;
-(void)noteOff:(NSInteger)note;

@end
