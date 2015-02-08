//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "AppDelegate.h"
#import "PresetController.h"
#import <AVFoundation/AVFoundation.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.midiEngine = [[PGMidi alloc] init];
    [self.midiEngine setNetworkEnabled:YES];
    [self.midiEngine setVirtualSourceEnabled:YES];
    
    self.audioEngine = [[AudioEngine alloc] init];
    [self.audioEngine initializeAUGraph];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // Setup view controller
    self.mainViewController = [[MainViewController alloc] init];
    [self.window setRootViewController:self.mainViewController];
    
    return YES;
}

-(NSDictionary *)audiobusStateDictionaryForCurrentState {
    PresetController *presetController = self.mainViewController.presetController;
    return [presetController getAudiobusPresetDictionary];
}

-(void)loadStateFromAudiobusStateDictionary:(NSDictionary *)dictionary responseMessage:(NSString *__autoreleasing *)outResponseMessage {
    PresetController *presetController = self.mainViewController.presetController;
    [presetController applyAudiobusPresetDictionary:dictionary];
    
    NSString *presetName = [dictionary objectForKey:ABStateDictionaryPresetNameKey];
    *outResponseMessage = [NSString stringWithFormat:@"LF1 restored state for preset '%@'", presetName];
}

@end
