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

-(void)restoreBank {
 
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _currentBank = [[userDefaults valueForKey:PRESET_BANK_KEY] mutableCopy];
    
    if (!_currentBank) {
        // Load default bank
        NSLog(@"Loading default bank");
        NSString *defaultBankPath = [[NSBundle mainBundle] pathForResource:@"init" ofType:@"bnk"];
        NSData *defaultBankData = [NSData dataWithContentsOfFile:defaultBankPath];
        if (defaultBankData) {
            _currentBank = [NSKeyedUnarchiver unarchiveObjectWithData:defaultBankData];
            // Write bank to user defaults
            [self saveBank];
        } else {
            NSLog(@"Default bank not found");
            _currentBank = [[NSMutableDictionary alloc] init];

            NSMutableArray *presetsArray = [[NSMutableArray alloc] initWithCapacity:8];
            for (int i = 0; i < 8; i++) {
                [presetsArray addObject:[[NSDictionary alloc] init]];
            }
            [_currentBank setValue:presetsArray forKey:@"presets"];
            [_currentBank setValue:@"Unnamed" forKey:@"bankName"];
        }
    }
}

-(void)saveBank {

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults setObject:_currentBank forKey:PRESET_BANK_KEY];
    
    [userDefaults synchronize];
    
    [self exportBankToFileNamed:@"default"];
}


-(void)storePresetAtIndex:(NSInteger)index {

    if (_currentBank) {
        NSMutableDictionary *presetDictionary = [[NSMutableDictionary alloc] initWithCapacity:[_keyPaths count]];
        for (NSString *thisKeyPath in _keyPaths) {
            NSValue *thisValue = [_viewController valueForKeyPath:thisKeyPath];
            [presetDictionary setValue:thisValue forKey:thisKeyPath];
        }
        
        NSMutableArray *presetsArray = [_currentBank[@"presets"] mutableCopy];
        
        presetsArray[index] = presetDictionary;
        
        [_currentBank setObject:presetsArray forKey:@"presets"];
        
        [self saveBank];
    }
}

-(void)restorePresetAtIndex:(NSInteger)index {
    
    [self restoreBank];
    
    if (_currentBank) {

        NSMutableArray *presetsArray = _currentBank[@"presets"];
        if ([presetsArray count] <= index) {
            NSLog(@"Can't load preset %li : out of bounds", (long)index);
            return;
        }
        NSDictionary *presetDictionary = presetsArray[index];
        
        for (NSString *thisKey in [presetDictionary allKeys]) {
            @try {
                [_viewController setValue:presetDictionary[thisKey] forKeyPath:thisKey];
            }
            @catch (NSException *e) {
                NSLog(@"Key Path %@ not found", thisKey);
            }
        }
    }
}

-(void)exportBankToFileNamed:(NSString*)filename {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    if (![[filename pathExtension] isEqualToString:@"bnk"]) {
        
        filename = [filename stringByAppendingPathExtension:@"bnk"];
        
    }
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, filename];
    
    NSLog(@"Writing to: %@", fullPath);
    NSData *bankData = [NSKeyedArchiver archivedDataWithRootObject:_currentBank];
    [bankData writeToFile:fullPath atomically:NO];
    
}

@end
