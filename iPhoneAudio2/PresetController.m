//
//  PresetController.m
//  iPhoneAudio2
//
//  Created by Chris on 9/19/14.
//  Copyright (c) 2014 ccr. All rights reserved.
//

#import "PresetController.h"

@implementation PresetController

- (instancetype)initWithViewController:(UIViewController*)viewController
{
    self = [super init];
    if (self) {
        _viewController = viewController;
        
        // KeyPaths to all the values we want to store in the presets
        _keyPaths = @[
                        @"oscView.osc1vol.value",
                        @"oscView.osc2vol.value",
                        @"oscView.osc2freq.value",
                        @"oscView.osc1wave.index",
                        @"oscView.osc2wave.index",
                        @"oscView.osc1octave.index",
                        @"oscView.osc2octave.index",
                        @"filterView.freqControl.value",
                        @"filterView.resControl.value",
                        @"envView.oscAttackControl.value",
                        @"envView.oscDecayControl.value",
                        @"envView.oscSustainControl.value",
                        @"envView.oscReleaseControl.value",
                        @"envView.filterAttackControl.value",
                        @"envView.filterDecayControl.value",
                        @"envView.filterSustainControl.value",
                        @"envView.filterReleaseControl.value",
                        @"lfoView.rateControl.value",
                        @"lfoView.amountControl.value",
                        @"lfoView.destinationControl.index",
                        @"lfoView.waveformControl.index"
                        ];
    }
    return self;
}

-(void)storePresetAtIndex:(NSInteger)index {

    NSMutableDictionary *presetDictionary = [[NSMutableDictionary alloc] initWithCapacity:[_keyPaths count]];
    
    for (NSString *thisKeyPath in _keyPaths) {
        
        NSValue *thisValue = [_viewController valueForKeyPath:thisKeyPath];
        [presetDictionary setValue:thisValue forKey:thisKeyPath];
        
    }

    NSData *presetData = [NSKeyedArchiver archivedDataWithRootObject:presetDictionary];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *userDefaultsPresetArray = [userDefaults valueForKey:USER_DEFAULTS_PRESETS_KEY];
    
    if (!userDefaultsPresetArray) {
        NSLog(@"No UserDefaults found: creating");
        userDefaultsPresetArray = [[NSMutableArray alloc] initWithCapacity:8];
    } else {
        NSLog(@"UserDefaults found");
        
    }
    
    if ([userDefaultsPresetArray count] >= index) {
        NSLog(@"Overwriting preset at index %i", index);
        [userDefaultsPresetArray replaceObjectAtIndex:index withObject:presetData];
    } else {
        NSLog(@"Inserting preset at index %i", index);
        [userDefaultsPresetArray insertObject:presetData atIndex:index];
    }
    [userDefaults setObject:userDefaultsPresetArray forKey:USER_DEFAULTS_PRESETS_KEY];
    [userDefaults synchronize];
}

-(void)restorePresetAtIndex:(NSInteger)index {
    
    NSLog(@"Loading preset at index %i", index);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *userDefaultsPresetArray = [userDefaults valueForKey:USER_DEFAULTS_PRESETS_KEY];
    
    if (userDefaultsPresetArray) {
        NSLog(@"UserDefaults found: %i",[userDefaultsPresetArray count]);
        
        if ([userDefaultsPresetArray count] <= index) {
            NSLog(@"Index %i out of bounds", index);
            return;
        }
        
        NSData *presetData = [userDefaultsPresetArray objectAtIndex:index];
        NSMutableDictionary *presetDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:presetData];
        
        for (NSString *thisKey in [presetDictionary allKeys]) {
            [_viewController setValue:presetDictionary[thisKey] forKeyPath:thisKey];
        }
        
    }
}

@end
