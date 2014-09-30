//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
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
                        @"filterView.egControl.value",
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
                        @"lfoView.waveformControl.index",
                        @"keyboardControlView.glideControl.value",
                        @"keyboardControlView.glissSwitch.value"
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
    NSMutableArray *userDefaultsPresetArray = [NSMutableArray arrayWithArray:[userDefaults valueForKey:USER_DEFAULTS_PRESETS_KEY]];
    
    if ([userDefaultsPresetArray count] > 0) {
        NSLog(@"UserDefaults found");
        
        if ([userDefaultsPresetArray count] > index) {
            NSLog(@"Overwriting preset at index %li", (long)index);
            [userDefaultsPresetArray replaceObjectAtIndex:index withObject:presetData];
        } else {
            NSLog(@"Inserting preset at index %li", (long)index);
            [userDefaultsPresetArray insertObject:presetData atIndex:index];
        }
    } else {
        NSLog(@"No UserDefaults found: creating");
        userDefaultsPresetArray = [[NSMutableArray alloc] initWithObjects:presetData, nil];
    }
    
    [userDefaults setObject:userDefaultsPresetArray forKey:USER_DEFAULTS_PRESETS_KEY];
    [userDefaults synchronize];
    
    userDefaultsPresetArray = nil;
}

-(void)restorePresetAtIndex:(NSInteger)index {
    
    NSLog(@"Loading preset at index %li", (long)index);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *userDefaultsPresetArray = [userDefaults valueForKey:USER_DEFAULTS_PRESETS_KEY];
    
    if (userDefaultsPresetArray) {
        NSLog(@"UserDefaults found: %lu",(unsigned long)[userDefaultsPresetArray count]);
        
        if ([userDefaultsPresetArray count] <= index) {
            NSLog(@"Index %li out of bounds", (long)index);
            return;
        }
        
        NSData *presetData = [userDefaultsPresetArray objectAtIndex:index];
        NSMutableDictionary *presetDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:presetData];
        
        for (NSString *thisKey in [presetDictionary allKeys]) {
            @try {
                [_viewController setValue:presetDictionary[thisKey] forKeyPath:thisKey];
            }
            @catch (NSException *e) {
                NSLog(@"Key Path %@ not found", thisKey);
            }
        }
    } else {
        NSLog(@"No UserDefaults found");
    }
}

@end
