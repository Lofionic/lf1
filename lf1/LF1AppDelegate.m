//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "LF1AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@implementation LF1AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // Setup view controller
    self.mainViewController = [[MainViewController alloc] init];
    [self.window setRootViewController:self.mainViewController];
    
    // Setup Audio Session
    NSError* __autoreleasing error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];

    return YES;
}


@end
