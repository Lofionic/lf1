//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
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

-(void)noteOn:(NSInteger)note;
-(void)noteOff:(NSInteger)note;

@end
