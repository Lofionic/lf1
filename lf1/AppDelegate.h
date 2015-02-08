//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Audiobus.h"
#import "MainViewController.h"
#import "AudioEngine.h"
#import "PGMidi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, ABAudiobusControllerStateIODelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) MainViewController *mainViewController;
@property (nonatomic, strong) AudioEngine *audioEngine;
@property (nonatomic, strong) PGMidi *midiEngine;

@end
