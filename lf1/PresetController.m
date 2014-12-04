//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//
#import "Defines.h"
#import "PresetController.h"
@interface PresetController ()

@property (nonatomic) NSInteger currentIndex;

@end


@implementation PresetController

- (instancetype)initWithViewController:(UIViewController*)viewController
{
    self = [super init];
    if (self) {
        self.viewController = viewController;
        
        // KeyPaths to all the values we want to store in the presets
        self.keyPaths = @[
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
                        @"performanceControlView.glideControl.value",
                        @"performanceControlView.glissSwitch.value"
                        ];
    }
    return self;
}

-(void)restoreBank {
 
    // Load default bank
    NSLog(@"Loading default bank");
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *defaultBankPath = [documentsDirectory stringByAppendingPathComponent:@"default.bnk"];
    NSData *defaultBankData = [NSData dataWithContentsOfFile:defaultBankPath];
    if (defaultBankData) {
        self.currentBank = [NSKeyedUnarchiver unarchiveObjectWithData:defaultBankData];
        // Write bank to user defaults
        [self saveBank];
    } else {
        NSLog(@"Default bank not found");
        [self loadFactoryBank];
    }
    
    NSArray *presets = [self.currentBank objectForKey:@"presets"];
    if ([presets count] < 100) {
        [self updateOldBank];
    }
}

-(void)loadFactoryBank {
    
    // Load factory presets
    NSLog(@"Loading factory bank");
    NSString *defaultBankPath = [[NSBundle mainBundle] pathForResource:@"init" ofType:@"bnk"];
    NSData *defaultBankData = [NSData dataWithContentsOfFile:defaultBankPath];
    if (defaultBankData) {
        self.currentBank = [NSKeyedUnarchiver unarchiveObjectWithData:defaultBankData];
        // Write bank to user defaults
        [self saveBank];
    } else {
        NSLog(@"Default bank not found");
        self.currentBank = [[NSMutableDictionary alloc] init];
        
        NSMutableArray *presetsArray = [[NSMutableArray alloc] initWithCapacity:8];
        for (int i = 0; i < 8; i++) {
            [presetsArray addObject:[[NSDictionary alloc] init]];
        }
        [self.currentBank setValue:presetsArray forKey:@"presets"];
        [self.currentBank setValue:@"Unnamed" forKey:@"bankName"];
    }
}

-(void)updateOldBank {
    
    NSLog(@"Updating Old Bank...");
    NSMutableArray *mutableBankData = [[self.currentBank objectForKey:@"presets"] mutableCopy];
    for (NSInteger i = [mutableBankData count]; i < 100; i++) {
        [mutableBankData addObject:[mutableBankData[0] copy]];
    }
    [self.currentBank setObject:[NSArray arrayWithArray:mutableBankData] forKey:@"presets"];
    
    [self saveBank];
}

-(void)saveBank {
    [self exportBankToFileNamed:@"default"];
}


-(void)storePresetAtIndex:(NSInteger)index {

    if (self.currentBank) {
        NSMutableDictionary *presetDictionary = [[NSMutableDictionary alloc] initWithCapacity:[self.keyPaths count]];
        for (NSString *thisKeyPath in self.keyPaths) {
            NSValue *thisValue = [self.viewController valueForKeyPath:thisKeyPath];
            [presetDictionary setValue:thisValue forKey:thisKeyPath];
        }
        
        NSMutableArray *presetsArray = [self.currentBank[@"presets"] mutableCopy];
        
        presetsArray[index] = presetDictionary;
        
        [self.currentBank setObject:presetsArray forKey:@"presets"];
        [self saveBank];
    }
}

-(void)restorePresetAtIndex:(NSInteger)index {
    
    if (!self.currentBank) {
        [self restoreBank];
    }
    
    if (self.currentBank) {

        NSMutableArray *presetsArray = self.currentBank[@"presets"];
        if ([presetsArray count] <= index) {
            NSLog(@"Can't load preset %li : out of bounds", (long)index);
            return;
        }
        NSDictionary *presetDictionary = presetsArray[index];
        
        for (NSString *thisKey in [presetDictionary allKeys]) {
            @try {
                [self.viewController setValue:presetDictionary[thisKey] forKeyPath:thisKey];
            }
            @catch (NSException *e) {
                NSLog(@"Key Path %@ not found", thisKey);
            }
        }
        
        self.currentIndex = index;
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
    NSData *bankData = [NSKeyedArchiver archivedDataWithRootObject:self.currentBank];
    [bankData writeToFile:fullPath atomically:NO];
    
}

@end
