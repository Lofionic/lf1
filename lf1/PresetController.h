//
//  Created by Chris Rivers on 22/02/2014.
//  Copyright (c) 2014 Lofionic. All rights reserved.
//

#import "BuildSettings.h"
#import <Foundation/Foundation.h>

@interface PresetController : NSObject

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, strong) NSArray *keyPaths;
@property (nonatomic, strong) NSMutableDictionary *currentBank;
@property (nonatomic, readonly) NSInteger currentIndex;

@property (nonatomic, strong) NSMutableArray *undos;

-(instancetype)initWithViewController:(UIViewController*)viewController;
-(void)storePresetAtIndex:(NSInteger)index;
-(void)restorePresetAtIndex:(NSInteger)index;

-(void)exportBankToFileNamed:(NSString*)filename;

-(void)storeUndo;
-(void)recallUndo;
-(BOOL)canUndo;

-(NSInteger)presetCount;
@end
